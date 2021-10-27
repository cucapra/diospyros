#![allow(dead_code)]
extern crate llvm_sys as llvm;
use dioslib::{config, rules, veclang::VecLang};
use egg::*;
use libc::size_t;
use llvm::{core::*, prelude::*, LLVMOpcode::*, LLVMRealPredicate};
use std::{
  cmp,
  collections::{BTreeMap, BTreeSet},
  ffi::CStr,
  os::raw::c_char,
  slice::from_raw_parts,
};

extern "C" {
  fn llvm_index(val: LLVMValueRef, index: i32) -> i32;
  fn llvm_name(val: LLVMValueRef) -> *const c_char;
  fn isa_unop(val: LLVMValueRef) -> bool;
  fn isa_bop(val: LLVMValueRef) -> bool;
  fn isa_constant(val: LLVMValueRef) -> bool;
  fn isa_gep(val: LLVMValueRef) -> bool;
  fn isa_load(val: LLVMValueRef) -> bool;
  fn isa_store(val: LLVMValueRef) -> bool;
  fn isa_argument(val: LLVMValueRef) -> bool;
  fn isa_call(val: LLVMValueRef) -> bool;
  fn isa_fptrunc(val: LLVMValueRef) -> bool;
  fn isa_alloca(val: LLVMValueRef) -> bool;
  fn get_constant_float(val: LLVMValueRef) -> f32;
  fn dfs_llvm_value_ref(val: LLVMValueRef, match_val: LLVMValueRef) -> bool;
  fn build_constant_float(n: f64, context: LLVMContextRef) -> LLVMValueRef;
}

// Note: We use BTreeMaps to enforce ordering in the map
// Without ordering, tests become flaky and start failing a lot more often
// We do not use HashMaps for this reason as ordering is not enforced.
// GEPMap : Maps the array name and array offset as symbols to the GEP
// LLVM Value Ref that LLVM Generated
type GEPMap = BTreeMap<(Symbol, Symbol), LLVMValueRef>;
// VarMap : Maps a symbol to a llvm value ref representing a variable
type VarMap = BTreeMap<Symbol, LLVMValueRef>;
// BopMap : Maps a binary oeprator llvm value ref to an ID, indicating a
// binary operator has been seen. Binary Operators be ordered in the order
// they were generated in LLVM, which is earliest to latest in code.
type BopMap = BTreeMap<LLVMValueRef, Id>;
// ValueVec : A vector of LLVM Value Refs for which we must do extract element
// for after vectorization.
type ValueVec = Vec<LLVMValueRef>;

const SQRT_OPERATOR: i32 = 3;
const BINARY_OPERATOR: i32 = 2;
static mut SYMBOL_IDX: i32 = 0;
static mut ARG_IDX: i32 = 0;
static mut CALL_IDX: i32 = 0;

unsafe fn gen_symbol_name() -> String {
  SYMBOL_IDX += 1;
  let string = "SYMBOL".to_string();
  let result = format!("{}{}", string, SYMBOL_IDX.to_string());
  result
}

unsafe fn gen_arg_name() -> String {
  ARG_IDX += 1;
  let string = "ARGUMENT".to_string();
  let result = format!("{}{}", string, ARG_IDX.to_string());
  result
}

unsafe fn gen_call_name() -> String {
  CALL_IDX += 1;
  let string = "CALL".to_string();
  let result = format!("{}{}", string, CALL_IDX.to_string());
  result
}

/// Converts LLVMValueRef binop to equivalent VecLang Binop node
unsafe fn choose_binop(bop: &LLVMValueRef, ids: [Id; 2]) -> VecLang {
  match LLVMGetInstructionOpcode(*bop) {
    LLVMFAdd => VecLang::Add(ids),
    LLVMFMul => VecLang::Mul(ids),
    LLVMFSub => VecLang::Minus(ids),
    LLVMFDiv => VecLang::Div(ids),
    _ => panic!("Choose_Binop: Opcode Match Error"),
  }
}

/// Convert the sqrt into a unique symbol, which maps to the sqet argument LLVMValueRef
/// And then Make sqrt point to that unique symbol.
/// On the other side, the symbol gets retranslted to the LLVMValueRef argument that came in
/// and then the sqrt takes the square root of it.
unsafe fn to_expr_sqrt(
  sqrt_ref: &LLVMValueRef,
  var_map: &mut VarMap,
  enode_vec: &mut Vec<VecLang>,
) -> () {
  let symbol = Symbol::from(gen_symbol_name());
  enode_vec.push(VecLang::Symbol(symbol));
  let symbol_idx = enode_vec.len() - 1;
  var_map.insert(symbol, *sqrt_ref);
  enode_vec.push(VecLang::Sqrt([Id::from(symbol_idx)]));
}

/// Converts LLVMValueRef constant to a VecLang Num.
unsafe fn to_expr_constant(
  operand: &LLVMValueRef,
  vec: &mut Vec<VecLang>,
  ids: &mut [egg::Id; 2],
  id_index: usize,
) -> () {
  let value = get_constant_float(*operand);
  vec.push(VecLang::Num(value as i32));
  ids[id_index] = Id::from(vec.len() - 1);
}

/// Converts LLVMValueRef GEP to a VecLang Symbol with variable name.
unsafe fn to_expr_var(
  var_operand: &LLVMValueRef,
  enode_vec: &mut Vec<VecLang>,
  ids: &mut [egg::Id; 2],
  id_index: usize,
  var_map: &mut VarMap,
) -> () {
  let var_name = CStr::from_ptr(llvm_name(*var_operand)).to_str().unwrap();
  let symbol = Symbol::from(var_name);
  enode_vec.push(VecLang::Symbol(symbol));
  ids[id_index] = Id::from(enode_vec.len() - 1);
  (*var_map).insert(symbol, *var_operand);
}

/// Converts LLVMValueRef GEP to a VecLang Get and VecLang Symbol for array
/// and VecLang Symbol for offset.
unsafe fn to_expr_gep(
  gep_operand: &LLVMValueRef,
  ids: &mut [egg::Id; 2],
  id_index: usize,
  enode_vec: &mut Vec<VecLang>,
  gep_map: &mut GEPMap,
) -> () {
  let array_var_name = CStr::from_ptr(llvm_name(*gep_operand)).to_str().unwrap();
  enode_vec.push(VecLang::Symbol(Symbol::from(array_var_name)));
  let array_var_idx = enode_vec.len() - 1;
  // --- get offsets for multidimensional arrays ----
  let num_gep_operands = LLVMGetNumOperands(*gep_operand);
  let mut indices = Vec::new();
  for operand_idx in 1..num_gep_operands {
    let array_offset = llvm_index(*gep_operand, operand_idx);
    indices.push(array_offset);
  }
  let offsets_string: String = indices.into_iter().map(|i| i.to_string() + ",").collect();
  let offsets_symbol = Symbol::from(&offsets_string);
  enode_vec.push(VecLang::Symbol(offsets_symbol));
  let array_offset_idx = enode_vec.len() - 1;

  enode_vec.push(VecLang::Get([
    Id::from(array_var_idx),
    Id::from(array_offset_idx),
  ]));

  ids[id_index] = Id::from(enode_vec.len() - 1);

  let array_name_symbol = Symbol::from(array_var_name);
  gep_map.insert((array_name_symbol, offsets_symbol), *gep_operand);
}

/// Makes binary operators as "used", which means that no extract is needed
/// for these binary operators.
///
/// For example:
/// x = (3 + z) + (2 + y)
/// will record 3 + z, 2 + y as used in the final addition (3 + z) + (2 + y)/
/// Only 1 extraction is needed (to assign to x's location). Not 3.
unsafe fn mark_used_bops(
  operand: &LLVMValueRef,
  ids: &mut [egg::Id; 2],
  id_index: usize,
  bop_map: &mut BopMap,
  used_bop_ids: &mut Vec<Id>,
) -> bool {
  let mut changed = false;
  for (&prev_used_bop, &mut prev_used_id) in bop_map {
    if dfs_llvm_value_ref(*operand, prev_used_bop) {
      ids[id_index] = prev_used_id;
      used_bop_ids.push(prev_used_id);
      changed |= true;
    }
  }
  return changed;
}

/// Converts LLVMValueRef operand to corresponding VecLang node
unsafe fn to_expr_operand(
  operand: &LLVMValueRef,
  bop_map: &mut BopMap,
  ids: &mut [egg::Id; 2],
  id_index: usize,
  used_bop_ids: &mut Vec<Id>,
  enode_vec: &mut Vec<VecLang>,
  gep_map: &mut GEPMap,
  var_map: &mut VarMap,
) -> () {
  let removed_bops = mark_used_bops(operand, ids, id_index, bop_map, used_bop_ids);
  if removed_bops {
    return ();
  }
  if bop_map.contains_key(&operand) {
    let used_id = *bop_map.get(&operand).expect("Expected key in map");
    ids[id_index] = used_id;
    used_bop_ids.push(used_id);
  } else if isa_bop(*operand) {
    // println!("Here");
  } else if isa_constant(*operand) {
    to_expr_constant(&operand, enode_vec, ids, id_index);
  } else if isa_load(*operand) {
    let inner_operand = LLVMGetOperand(*operand, 0);
    if isa_gep(inner_operand) {
      to_expr_gep(&inner_operand, ids, id_index, enode_vec, gep_map);
    } else {
      // assume load of some temporary/global variable
      to_expr_var(operand, enode_vec, ids, id_index, var_map);
    }
  } else {
    panic!("Cannot handle LLVM IR Operand.")
  }
}

/// Pads a vector to be always the Vector Lane Width.
fn pad_vector(binop_vec: &Vec<Id>, enode_vec: &mut Vec<VecLang>) -> () {
  let width = config::vector_width();
  let mut length = binop_vec.len();
  let mut vec_indices = Vec::new();
  let mut idx = 0;
  while length > width {
    let mut width_vec = Vec::new();
    for _ in 0..width {
      width_vec.push(binop_vec[idx]);
      idx += 1;
      length -= 1;
    }
    enode_vec.push(VecLang::Vec(width_vec.into_boxed_slice()));
    vec_indices.push(enode_vec.len() - 1);
  }
  // wrap up extras at end
  let diff = width - length;
  let mut extras = Vec::new();
  for _ in 0..diff {
    enode_vec.push(VecLang::Num(0));
    extras.push(enode_vec.len() - 1);
  }
  let mut final_vec = Vec::new();
  let original_length = binop_vec.len();
  for i in idx..original_length {
    final_vec.push(binop_vec[i]);
  }
  for id in extras.iter() {
    final_vec.push(Id::from(*id));
  }
  enode_vec.push(VecLang::Vec(final_vec.into_boxed_slice()));
  vec_indices.push(enode_vec.len() - 1);
  // create concats
  let mut num_concats = vec_indices.len() - 1;
  let mut idx = 0;
  let mut prev_id = Id::from(vec_indices[idx]);
  idx += 1;
  while num_concats > 0 {
    let concat = VecLang::Concat([prev_id, Id::from(vec_indices[idx])]);
    enode_vec.push(concat);
    prev_id = Id::from(enode_vec.len() - 1);
    idx += 1;
    num_concats -= 1;
  }
}

/// Converts LLVMValueRef to a corresponding VecLang expression, as well as a GEPMap,
/// which maps each LLVM gep expression to a symbol representing the array name
/// and a symbol representing the array offset, a var map, which maps a symbol to the
/// LLVMValueRef representing the variable, and a ValueVec, which reprsents
/// the values we generate extract instructions on.
pub fn to_expr(
  bb_vec: &[LLVMValueRef],
  operand_types: &[i32],
) -> (RecExpr<VecLang>, GEPMap, VarMap, ValueVec) {
  let (mut enode_vec, mut bops_vec, mut ops_to_replace, mut used_bop_ids) =
    (Vec::new(), Vec::new(), Vec::new(), Vec::new());
  let (mut gep_map, mut var_map, mut bop_map) = (BTreeMap::new(), BTreeMap::new(), BTreeMap::new());
  let mut ids = [Id::from(0); 2];
  for (i, bop) in bb_vec.iter().enumerate() {
    unsafe {
      if operand_types[i] == BINARY_OPERATOR {
        // to_expr on left and then right operands
        to_expr_operand(
          &LLVMGetOperand(*bop, 0),
          &mut bop_map,
          &mut ids,
          0,
          &mut used_bop_ids,
          &mut enode_vec,
          &mut gep_map,
          &mut var_map,
        );
        to_expr_operand(
          &LLVMGetOperand(*bop, 1),
          &mut bop_map,
          &mut ids,
          1,
          &mut used_bop_ids,
          &mut enode_vec,
          &mut gep_map,
          &mut var_map,
        );
        // lhs bop rhs
        enode_vec.push(choose_binop(bop, ids));
      } else if operand_types[i] == SQRT_OPERATOR {
        // currently fails to generate correct code or optimize.
        // to_expr_sqrt(bop, &mut var_map, &mut enode_vec);
      }
    }
    // add in the binary/unary operator to the bops_vec list
    let id = Id::from(enode_vec.len() - 1);
    bops_vec.push(id);
    ops_to_replace.push((*bop, id));
    bop_map.insert(*bop, id);
    // remove binops that are used as part of another binop
    for used_id in used_bop_ids.iter() {
      if bops_vec.contains(used_id) {
        let index = bops_vec
          .iter()
          .position(|&_id| _id == *used_id)
          .expect("Require used_id in vector");
        bops_vec.remove(index);
      }
    }
  }
  // decompose bops_vec into width number of binops
  pad_vector(&bops_vec, &mut enode_vec);

  // remove binary ops that were used, and thus not the ones we want to replace directly
  let mut final_ops_to_replace = Vec::new();
  for (bop, id) in ops_to_replace.iter() {
    if !used_bop_ids.contains(id) {
      final_ops_to_replace.push(*bop);
    }
  }

  return (
    RecExpr::from(enode_vec),
    gep_map,
    var_map,
    final_ops_to_replace,
  );
}

/// Translates VecLang binop expression node to the corresponding LLVMValueRef
unsafe fn translate_binop(
  enode: &VecLang,
  left: LLVMValueRef,
  right: LLVMValueRef,
  builder: LLVMBuilderRef,
  name: *const c_char,
) -> LLVMValueRef {
  match enode {
    VecLang::VecAdd(_) | VecLang::Add(_) => LLVMBuildFAdd(builder, left, right, name),
    VecLang::VecMul(_) | VecLang::Mul(_) => LLVMBuildFMul(builder, left, right, name),
    VecLang::VecMinus(_) | VecLang::Minus(_) => LLVMBuildFSub(builder, left, right, name),
    VecLang::VecDiv(_) | VecLang::Div(_) => LLVMBuildFDiv(builder, left, right, name),
    // use binary bitwise operators for or / and
    VecLang::Or(_) => LLVMBuildOr(builder, left, right, name),
    VecLang::And(_) => LLVMBuildAnd(builder, left, right, name),
    VecLang::Lt(_) => LLVMBuildFCmp(builder, LLVMRealPredicate::LLVMRealOLT, left, right, name),
    _ => panic!("Not a vector or scalar binop."),
  }
}

/// Translates VecLang unop expression node to the corresponding LLVMValueRef
unsafe fn translate_unop(
  enode: &VecLang,
  n: LLVMValueRef,
  builder: LLVMBuilderRef,
  module: LLVMModuleRef,
  name: *const c_char,
) -> LLVMValueRef {
  match enode {
    VecLang::Sgn(_) => {
      let one = LLVMConstReal(LLVMFloatType(), 1 as f64);
      let param_types = [LLVMFloatType(), LLVMFloatType()].as_mut_ptr();
      let fn_type = LLVMFunctionType(LLVMFloatType(), param_types, 2, 0 as i32);
      let func = LLVMAddFunction(module, b"llvm.copysign.f32\0".as_ptr() as *const _, fn_type);
      let args = [one, n].as_mut_ptr();
      LLVMBuildCall(builder, func, args, 2, name)
    }
    VecLang::Sqrt(_) => {
      let param_types = [LLVMFloatType()].as_mut_ptr();
      let fn_type = LLVMFunctionType(LLVMFloatType(), param_types, 1, 0 as i32);
      let func = LLVMAddFunction(module, b"llvm.sqrt.f32\0".as_ptr() as *const _, fn_type);
      let args = [n].as_mut_ptr();
      LLVMBuildCall(builder, func, args, 1, name)
    }
    VecLang::Neg(_) => LLVMBuildFNeg(builder, n, name),
    _ => panic!("Not a scalar unop."),
  }
}

/// translate_get converts a VecLang Get Node to the corresponding LLVM Ir array name and
/// LLVM IR offset, as symbols.
unsafe fn translate_get(get: &VecLang, enode_vec: &[VecLang]) -> (Symbol, Symbol) {
  match get {
    VecLang::Get([sym, i]) => match (&enode_vec[usize::from(*sym)], &enode_vec[usize::from(*i)]) {
      (VecLang::Symbol(name), VecLang::Symbol(offset)) => {
        return (*name, *offset);
      }
      _ => panic!("Match Error: Expects Pair of Symbol, Symbol."),
    },
    _ => panic!("Match Error in Translate Get: Expects Get Enode."),
  }
}

/// translate converts a VecLang expression to the corresponding LLVMValueRef.
unsafe fn translate(
  enode: &VecLang,
  vec: &[VecLang],
  gep_map: &GEPMap,
  var_map: &VarMap,
  builder: LLVMBuilderRef,
  module: LLVMModuleRef,
) -> LLVMValueRef {
  match enode {
    VecLang::Symbol(s) => *var_map.get(s).expect("Var map lookup error"),
    VecLang::Num(n) => LLVMConstReal(LLVMFloatType(), *n as f64),
    VecLang::Get(..) => {
      let (array_name, array_offsets) = translate_get(enode, vec);
      let gep_value = gep_map
        .get(&(array_name, array_offsets))
        .expect("Symbol map lookup error");
      LLVMBuildLoad(builder, *gep_value, b"\0".as_ptr() as *const _)
    }
    VecLang::LitVec(boxed_ids) | VecLang::Vec(boxed_ids) | VecLang::List(boxed_ids) => {
      let idvec = boxed_ids.to_vec();
      let idvec_len = idvec.len();
      let mut zeros = Vec::new();
      for _ in 0..idvec_len {
        zeros.push(LLVMConstReal(LLVMFloatType(), 0 as f64));
      }
      let zeros_ptr = zeros.as_mut_ptr();
      let mut vector = LLVMConstVector(zeros_ptr, idvec.len() as u32);
      for (idx, &eggid) in idvec.iter().enumerate() {
        let elt = &vec[usize::from(eggid)];
        let elt_val = translate(elt, vec, gep_map, var_map, builder, module);
        vector = LLVMBuildInsertElement(
          builder,
          vector,
          elt_val,
          LLVMConstInt(LLVMInt32Type(), idx as u64, 0),
          b"\0".as_ptr() as *const _,
        );
      }
      vector
    }
    VecLang::VecAdd([l, r])
    | VecLang::VecMinus([l, r])
    | VecLang::VecMul([l, r])
    | VecLang::VecDiv([l, r])
    | VecLang::Add([l, r])
    | VecLang::Minus([l, r])
    | VecLang::Mul([l, r])
    | VecLang::Div([l, r])
    | VecLang::Or([l, r])
    | VecLang::And([l, r])
    | VecLang::Lt([l, r]) => {
      let left = translate(
        &vec[usize::from(*l)],
        vec,
        gep_map,
        var_map,
        builder,
        module,
      );
      let right = translate(
        &vec[usize::from(*r)],
        vec,
        gep_map,
        var_map,
        builder,
        module,
      );
      translate_binop(enode, left, right, builder, b"\0".as_ptr() as *const _)
    }
    VecLang::Concat([v1, v2]) => {
      let trans_v1 = translate(
        &vec[usize::from(*v1)],
        vec,
        gep_map,
        var_map,
        builder,
        module,
      );
      let trans_v2 = translate(
        &vec[usize::from(*v2)],
        vec,
        gep_map,
        var_map,
        builder,
        module,
      );
      // manually concatenate 2 vectors by using a LLVM shuffle operation.
      let v1_type = LLVMTypeOf(trans_v1);
      let v1_size = LLVMGetVectorSize(v1_type);
      let v2_type = LLVMTypeOf(trans_v2);
      let v2_size = LLVMGetVectorSize(v2_type);
      let size = v1_size + v2_size;
      let mut indices = Vec::new();
      for i in 0..size {
        indices.push(LLVMConstInt(LLVMInt32Type(), i as u64, 0));
      }
      let mask = indices.as_mut_ptr();
      let mask_vector = LLVMConstVector(mask, size);
      LLVMBuildShuffleVector(
        builder,
        trans_v1,
        trans_v2,
        mask_vector,
        b"\0".as_ptr() as *const _,
      )
    }
    VecLang::VecMAC([acc, v1, v2]) => {
      let trans_acc = translate(
        &vec[usize::from(*acc)],
        vec,
        gep_map,
        var_map,
        builder,
        module,
      );
      let trans_v1 = translate(
        &vec[usize::from(*v1)],
        vec,
        gep_map,
        var_map,
        builder,
        module,
      );
      let trans_v2 = translate(
        &vec[usize::from(*v2)],
        vec,
        gep_map,
        var_map,
        builder,
        module,
      );
      let vec_type = LLVMTypeOf(trans_acc);

      let param_types = [vec_type, vec_type, vec_type].as_mut_ptr();
      let fn_type = LLVMFunctionType(vec_type, param_types, 3, 0 as i32);
      let func = LLVMAddFunction(module, b"llvm.fma.f32\0".as_ptr() as *const _, fn_type);
      let args = [trans_v1, trans_v2, trans_acc].as_mut_ptr();
      LLVMBuildCall(builder, func, args, 3, b"\0".as_ptr() as *const _)
    }
    // TODO: VecNeg, VecSqrt, VecSgn all have not been tested, need test cases.
    // TODO: LLVM actually supports many more vector intrinsics, including
    // vector sine/cosine instructions for floats.
    VecLang::VecNeg([v]) => {
      let neg_vector = translate(
        &vec[usize::from(*v)],
        vec,
        gep_map,
        var_map,
        builder,
        module,
      );
      LLVMBuildFNeg(builder, neg_vector, b"\0".as_ptr() as *const _)
    }
    VecLang::VecSqrt([v]) => {
      let sqrt_vec = translate(
        &vec[usize::from(*v)],
        vec,
        gep_map,
        var_map,
        builder,
        module,
      );
      let vec_type = LLVMTypeOf(sqrt_vec);
      let param_types = [vec_type].as_mut_ptr();
      let fn_type = LLVMFunctionType(vec_type, param_types, 1, 0 as i32);
      let func = LLVMAddFunction(module, b"llvm.sqrt.f32\0".as_ptr() as *const _, fn_type);
      let args = [sqrt_vec].as_mut_ptr();
      LLVMBuildCall(builder, func, args, 1, b"\0".as_ptr() as *const _)
    }
    // compliant with c++ LibMath copysign function, which differs with sgn at x = 0.
    VecLang::VecSgn([v]) => {
      let sgn_vec = translate(
        &vec[usize::from(*v)],
        vec,
        gep_map,
        var_map,
        builder,
        module,
      );
      let vec_type = LLVMTypeOf(sgn_vec);
      let vec_size = LLVMGetVectorSize(vec_type);
      let mut ones = Vec::new();
      for _ in 0..vec_size {
        ones.push(LLVMConstReal(LLVMFloatType(), 1 as f64));
      }
      let ones_ptr = ones.as_mut_ptr();
      let ones_vector = LLVMConstVector(ones_ptr, vec_size);
      let param_types = [vec_type, vec_type].as_mut_ptr();
      let fn_type = LLVMFunctionType(vec_type, param_types, 2, 0 as i32);
      let func = LLVMAddFunction(module, b"llvm.copysign.f32\0".as_ptr() as *const _, fn_type);
      let args = [ones_vector, sgn_vec].as_mut_ptr();
      LLVMBuildCall(builder, func, args, 2, b"\0".as_ptr() as *const _)
    }
    VecLang::Sgn([n]) | VecLang::Sqrt([n]) | VecLang::Neg([n]) => {
      let number = translate(
        &vec[usize::from(*n)],
        vec,
        gep_map,
        var_map,
        builder,
        module,
      );
      translate_unop(enode, number, builder, module, b"\0".as_ptr() as *const _)
    }
    VecLang::Ite(..) => panic!("Ite is not handled."),
  }
}

/// Convert a Veclang `expr` to LLVM IR code in place, using an LLVM builder.
unsafe fn to_llvm(
  module: LLVMModuleRef,
  expr: RecExpr<VecLang>,
  gep_map: &GEPMap,
  var_map: &VarMap,
  ops_to_replace: &ValueVec,
  builder: LLVMBuilderRef,
) -> () {
  let vec = expr.as_ref();
  let last = vec
    .last()
    .expect("No match for last element of vector of Egg Terms.");

  // create vectorized instructions.
  let vector = translate(last, vec, gep_map, var_map, builder, module);

  // for each binary operation that has been vectorized AND requires replacement
  // we extract the correct index from the vector and
  // determine the store to that binary op, copy it and move it after the extraction
  for (i, op) in ops_to_replace.iter().enumerate() {
    let index = LLVMConstInt(LLVMInt32Type(), i as u64, 0);
    let extracted_value =
      LLVMBuildExtractElement(builder, vector, index, b"\0".as_ptr() as *const _);
    // figure out where the next store is located, after the binary operation to replace.
    let mut store_instr = *op;
    // assumes there is a store next: could segfault or loop forever if not.
    // WARNING: In particular, could infinitely loop under -02/-03 optimizations.
    while !isa_store(store_instr) {
      store_instr = LLVMGetNextInstruction(store_instr);
    }
    let cloned_store = LLVMInstructionClone(store_instr);
    LLVMSetOperand(cloned_store, 0, extracted_value);
    LLVMInsertIntoBuilder(builder, cloned_store);
    // erase stores -> this was affecting a load and then a store to the same
    // location in matrix multiply
    LLVMInstructionEraseFromParent(store_instr);
  }
}

/// Main function to optimize: Takes in a basic block of instructions,
/// optimizes it, and then translates it to LLVM IR code, in place.
#[no_mangle]
pub fn optimize(
  module: LLVMModuleRef,
  context: LLVMContextRef,
  builder: LLVMBuilderRef,
  bb: *const LLVMValueRef,
  size: size_t,
) -> () {
  unsafe {
    // llvm to egg
    let llvm_instrs = from_raw_parts(bb, size);
    let (expr, gep_map, store_map, symbol_map) = llvm_to_egg(llvm_instrs);
    // let (expr, gep_map, var_map, ops_to_replace) = to_expr(
    //   from_raw_parts(bb, size),
    //   from_raw_parts(operand_types, size),
    // );

    // optimization pass
    eprintln!("{}", expr.pretty(10));
    let (_, best) = rules::run(&expr, 180, true, false);
    eprintln!("{}", best.pretty(10));

    // egg to llvm
    egg_to_llvm(
      best,
      &gep_map,
      &store_map,
      &symbol_map,
      module,
      context,
      builder,
    );
    // to_llvm(module, best, &GEPMap, &var_map, &ops_to_replace, builder);
  }
}

// ------------ NEW CONVERSION FROM LLVM IR TO EGG EXPRESSIONS -------

type store_map = BTreeMap<i32, LLVMValueRef>;
type gep_map = BTreeMap<VecLang, LLVMValueRef>;
type id_map = BTreeSet<Id>;
type symbol_map = BTreeMap<VecLang, LLVMValueRef>;

enum LLVMOpType {
  Argument,
  Constant,
  Store,
  Load,
  Gep,
  Unop,
  Bop,
  Call,
  FPTrunc,
}

unsafe fn is_pow2(n: u32) -> bool {
  let mut pow = 1;
  while pow < n {
    pow *= 2;
  }
  return pow == n;
}

unsafe fn get_pow2(n: u32) -> u32 {
  let mut pow = 1;
  while pow < n {
    pow *= 2;
  }
  return pow;
}

/// New Pad Vector should round the number of elements up to a power of 2, and then recursive
/// divide each into the lane width. Assumes lane width is also a power of 2 in size
unsafe fn balanced_pad_vector<'a>(
  binop_vec: &mut Vec<Id>,
  enode_vec: &'a mut Vec<VecLang>,
) -> &'a mut Vec<VecLang> {
  let width = config::vector_width();
  let length = binop_vec.len();
  let closest_pow2 = get_pow2(cmp::max(length, width) as u32);
  let diff = closest_pow2 - (length as u32);
  for _ in 0..diff {
    let zero = VecLang::Num(0);
    enode_vec.push(zero);
    let zero_idx = enode_vec.len() - 1;
    binop_vec.push(Id::from(zero_idx));
  }
  return build_concat(width, binop_vec, enode_vec);
}

unsafe fn build_concat<'a>(
  lane_width: usize,
  binop_vec: &mut Vec<Id>,
  enode_vec: &'a mut Vec<VecLang>,
) -> &'a mut Vec<VecLang> {
  if binop_vec.len() == lane_width {
    enode_vec.push(VecLang::Vec(binop_vec.clone().into_boxed_slice()));
    return enode_vec;
  }
  let num_binops = binop_vec.len();
  let halfway = num_binops / 2;
  let (mut left, mut right) = (Vec::new(), Vec::new());
  for (i, b) in binop_vec.iter().enumerate() {
    if i < halfway {
      left.push(*b);
    } else {
      right.push(*b);
    }
  }
  assert_eq!(left.len(), right.len());
  assert_eq!(left.len() + right.len(), num_binops);
  assert_eq!(left.len() % lane_width, 0);
  assert_eq!(right.len() % lane_width, 0);
  let enode_vec1 = build_concat(lane_width, &mut left, enode_vec);
  let idx1 = enode_vec1.len() - 1;
  let enode_vec2 = build_concat(lane_width, &mut right, enode_vec1);
  let idx2 = enode_vec2.len() - 1;
  enode_vec2.push(VecLang::Concat([Id::from(idx1), Id::from(idx2)]));
  return enode_vec2;
}

unsafe fn LLVMPrint(Inst: LLVMValueRef) -> () {
  LLVMDumpValue(Inst);
  println!();
}

unsafe fn llvm_recursive_print(inst: LLVMValueRef) -> () {
  if isa_argument(inst) {
    return LLVMDumpValue(inst);
  } else if isa_constant(inst) {
    return LLVMDumpValue(inst);
  }
  let num_ops = LLVMGetNumOperands(inst);
  for i in 0..num_ops {
    let operand = LLVMGetOperand(inst, i as u32);
    llvm_recursive_print(operand);
    print!(" ");
  }
  println!();
  LLVMDumpValue(inst);
  println!();
  return;
}

unsafe fn LLVMRecursiveAdd(Builder: LLVMBuilderRef, Inst: LLVMValueRef) -> LLVMValueRef {
  if isa_argument(Inst) {
    return Inst;
  } else if isa_constant(Inst) {
    return Inst;
  } else if isa_alloca(Inst) {
    let cloned_inst = LLVMInstructionClone(Inst);
    LLVMInsertIntoBuilder(Builder, cloned_inst);
    return cloned_inst;
  }
  let cloned_inst = LLVMInstructionClone(Inst);
  let num_ops = LLVMGetNumOperands(Inst);
  for i in 0..num_ops {
    let operand = LLVMGetOperand(Inst, i as u32);
    let new_inst = LLVMRecursiveAdd(Builder, operand);
    LLVMSetOperand(cloned_inst, i as u32, new_inst);
  }
  LLVMInsertIntoBuilder(Builder, cloned_inst);
  return cloned_inst;
}

unsafe fn match_llvm_op(expr: &LLVMValueRef) -> LLVMOpType {
  if isa_bop(*expr) {
    return LLVMOpType::Bop;
  } else if isa_unop(*expr) {
    return LLVMOpType::Unop;
  } else if isa_constant(*expr) {
    return LLVMOpType::Constant;
  } else if isa_gep(*expr) {
    return LLVMOpType::Gep;
  } else if isa_load(*expr) {
    return LLVMOpType::Load;
  } else if isa_store(*expr) {
    return LLVMOpType::Store;
  } else if isa_argument(*expr) {
    return LLVMOpType::Argument;
  } else if isa_call(*expr) {
    return LLVMOpType::Call;
  } else if isa_fptrunc(*expr) {
    return LLVMOpType::FPTrunc;
  } else {
    LLVMDumpValue(*expr);
    println!();
    panic!("ref_to_egg: Unmatched case for LLVMValueRef {:?}", *expr);
  }
}

unsafe fn choose_unop(unop: &LLVMValueRef, id: Id) -> VecLang {
  match LLVMGetInstructionOpcode(*unop) {
    LLVMFNeg => VecLang::Neg([id]),
    _ => panic!("Choose_Unop: Opcode Match Error"),
  }
}

unsafe fn arg_to_egg(
  expr: LLVMValueRef,
  mut enode_vec: Vec<VecLang>,
  next_idx: i32,
  gep_map: &mut GEPMap,
  store_map: &mut store_map,
  id_map: &mut id_map,
  symbol_map: &mut symbol_map,
) -> (Vec<VecLang>, i32) {
  let sym_name = gen_arg_name();
  let symbol = VecLang::Symbol(Symbol::from(sym_name));
  symbol_map.insert(symbol.clone(), expr);
  enode_vec.push(symbol);
  return (enode_vec, next_idx + 1);
}

unsafe fn bop_to_egg(
  expr: LLVMValueRef,
  mut enode_vec: Vec<VecLang>,
  next_idx: i32,
  gep_map: &mut GEPMap,
  store_map: &mut store_map,
  id_map: &mut id_map,
  symbol_map: &mut symbol_map,
) -> (Vec<VecLang>, i32) {
  let left = LLVMGetOperand(expr, 0);
  let right = LLVMGetOperand(expr, 1);
  let (v1, next_idx1) = ref_to_egg(
    left, enode_vec, next_idx, gep_map, store_map, id_map, symbol_map,
  );
  let (mut v2, next_idx2) =
    ref_to_egg(right, v1, next_idx1, gep_map, store_map, id_map, symbol_map);
  // let mut concat = [&v1[..], &v2[..]].concat(); // https://users.rust-lang.org/t/how-to-concatenate-two-vectors/8324/3
  let ids = [
    Id::from((next_idx1 - 1) as usize),
    Id::from((next_idx2 - 1) as usize),
  ];
  v2.push(choose_binop(&expr, ids));
  (v2, next_idx2 + 1)
}

unsafe fn unop_to_egg(
  expr: LLVMValueRef,
  mut enode_vec: Vec<VecLang>,
  next_idx: i32,
  gep_map: &mut GEPMap,
  store_map: &mut store_map,
  id_map: &mut id_map,
  symbol_map: &mut symbol_map,
) -> (Vec<VecLang>, i32) {
  let sub_expr = LLVMGetOperand(expr, 0);
  let (mut v, next_idx1) = ref_to_egg(
    sub_expr, enode_vec, next_idx, gep_map, store_map, id_map, symbol_map,
  );
  let id = Id::from((next_idx1 - 1) as usize);
  v.push(choose_unop(&expr, id));
  (v, next_idx1 + 1)
}

unsafe fn gep_to_egg(
  expr: LLVMValueRef,
  mut enode_vec: Vec<VecLang>,
  next_idx: i32,
  gep_map: &mut GEPMap,
  store_map: &mut store_map,
  id_map: &mut id_map,
  symbol_map: &mut symbol_map,
) -> (Vec<VecLang>, i32) {
  assert!(isa_argument(expr) || isa_gep(expr));
  // let mut enode_vec = Vec::new();
  let array_name = CStr::from_ptr(llvm_name(expr)).to_str().unwrap();
  enode_vec.push(VecLang::Symbol(Symbol::from(array_name)));

  let num_gep_operands = LLVMGetNumOperands(expr);
  let mut indices = Vec::new();
  for operand_idx in 1..num_gep_operands {
    let array_offset = llvm_index(expr, operand_idx);
    indices.push(array_offset);
  }
  let offsets_string: String = indices.into_iter().map(|i| i.to_string() + ",").collect();
  let offsets_symbol = Symbol::from(&offsets_string);
  enode_vec.push(VecLang::Symbol(offsets_symbol));

  let get_node = VecLang::Get([
    Id::from((next_idx) as usize),
    Id::from((next_idx + 1) as usize),
  ]);
  (*gep_map).insert(
    (Symbol::from(array_name), Symbol::from(&offsets_string)),
    expr,
  );
  enode_vec.push(get_node);

  return (enode_vec, next_idx + 3);
}

unsafe fn load_to_egg(
  expr: LLVMValueRef,
  mut enode_vec: Vec<VecLang>,
  next_idx: i32,
  gep_map: &mut GEPMap,
  store_map: &mut store_map,
  id_map: &mut id_map,
  symbol_map: &mut symbol_map,
) -> (Vec<VecLang>, i32) {
  let addr = LLVMGetOperand(expr, 0);
  if isa_argument(addr) {
    return load_arg_to_egg(
      addr, enode_vec, next_idx, gep_map, store_map, id_map, symbol_map,
    );
  } else if isa_gep(addr) {
    return gep_to_egg(
      addr, enode_vec, next_idx, gep_map, store_map, id_map, symbol_map,
    );
  } else {
    panic!("Load Expects its address to either be a function argument that is a pointer/array or a GEP instruction.")
  }
  // return ref_to_egg(addr, enode_vec, next_idx, gep_map, store_map, id_map, symbol_map);
}

unsafe fn store_to_egg(
  expr: LLVMValueRef,
  mut enode_vec: Vec<VecLang>,
  next_idx: i32,
  gep_map: &mut GEPMap,
  store_map: &mut store_map,
  id_map: &mut id_map,
  symbol_map: &mut symbol_map,
) -> (Vec<VecLang>, i32) {
  let data = LLVMGetOperand(expr, 0);
  let addr = LLVMGetOperand(expr, 1); // expected to be a gep operator or addr in LLVM
  let (vec, next_idx1) = ref_to_egg(
    data, enode_vec, next_idx, gep_map, store_map, id_map, symbol_map,
  );
  (*store_map).insert(next_idx1 - 1, addr);
  (*id_map).insert(Id::from((next_idx1 - 1) as usize));
  return (vec, next_idx1);
}

unsafe fn const_to_egg(
  expr: LLVMValueRef,
  mut enode_vec: Vec<VecLang>,
  next_idx: i32,
  gep_map: &mut GEPMap,
  store_map: &mut store_map,
  id_map: &mut id_map,
  symbol_map: &mut symbol_map,
) -> (Vec<VecLang>, i32) {
  let value = get_constant_float(expr);
  enode_vec.push(VecLang::Num(value as i32));
  (enode_vec, next_idx + 1)
}

unsafe fn load_arg_to_egg(
  expr: LLVMValueRef,
  mut enode_vec: Vec<VecLang>,
  next_idx: i32,
  gep_map: &mut GEPMap,
  store_map: &mut store_map,
  id_map: &mut id_map,
  symbol_map: &mut symbol_map,
) -> (Vec<VecLang>, i32) {
  assert!(isa_argument(expr) || isa_gep(expr));
  let array_name = CStr::from_ptr(llvm_name(expr)).to_str().unwrap();
  enode_vec.push(VecLang::Symbol(Symbol::from(array_name)));

  let num_gep_operands = LLVMGetNumOperands(expr);
  let mut indices = Vec::new();
  for operand_idx in 1..num_gep_operands {
    let array_offset = llvm_index(expr, operand_idx);
    indices.push(array_offset);
  }
  let offsets_string: String = indices.into_iter().map(|i| i.to_string() + ",").collect();
  let offsets_symbol = Symbol::from(&offsets_string);
  enode_vec.push(VecLang::Symbol(offsets_symbol));

  let get_node = VecLang::Get([
    Id::from((next_idx) as usize),
    Id::from((next_idx + 1) as usize),
  ]);
  (*gep_map).insert(
    (Symbol::from(array_name), Symbol::from(&offsets_string)),
    expr,
  );
  enode_vec.push(get_node);

  return (enode_vec, next_idx + 3);
}

unsafe fn load_call_to_egg(
  expr: LLVMValueRef,
  mut enode_vec: Vec<VecLang>,
  next_idx: i32,
  gep_map: &mut GEPMap,
  store_map: &mut store_map,
  id_map: &mut id_map,
  symbol_map: &mut symbol_map,
) -> (Vec<VecLang>, i32) {
  let call_sym_name = gen_call_name();
  let call_sym = VecLang::Symbol(Symbol::from(call_sym_name));
  symbol_map.insert(call_sym.clone(), expr);
  enode_vec.push(call_sym);
  return (enode_vec, next_idx + 1);
}

unsafe fn fpext_to_egg(
  expr: LLVMValueRef,
  enode_vec: Vec<VecLang>,
  next_idx: i32,
  gep_map: &mut GEPMap,
  store_map: &mut store_map,
  id_map: &mut id_map,
  symbol_map: &mut symbol_map,
) -> (Vec<VecLang>, i32) {
  let operand = LLVMGetOperand(expr, 0);
  return ref_to_egg(
    operand, enode_vec, next_idx, gep_map, store_map, id_map, symbol_map,
  );
}

unsafe fn sqrt_to_egg(
  expr: LLVMValueRef,
  enode_vec: Vec<VecLang>,
  next_idx: i32,
  gep_map: &mut GEPMap,
  store_map: &mut store_map,
  id_map: &mut id_map,
  symbol_map: &mut symbol_map,
) -> (Vec<VecLang>, i32) {
  let operand = LLVMGetOperand(expr, 0);
  let (mut new_enode_vec, next_idx1) = fpext_to_egg(
    operand, enode_vec, next_idx, gep_map, store_map, id_map, symbol_map,
  );
  let sqrt_node = VecLang::Sqrt([Id::from((next_idx1 - 1) as usize)]);
  new_enode_vec.push(sqrt_node);
  return (new_enode_vec, next_idx1 + 1);
}

unsafe fn fptrunc_to_egg(
  expr: LLVMValueRef,
  mut enode_vec: Vec<VecLang>,
  next_idx: i32,
  gep_map: &mut GEPMap,
  store_map: &mut store_map,
  id_map: &mut id_map,
  symbol_map: &mut symbol_map,
) -> (Vec<VecLang>, i32) {
  let operand = LLVMGetOperand(expr, 0);
  return sqrt_to_egg(
    operand, enode_vec, next_idx, gep_map, store_map, id_map, symbol_map,
  );
}

unsafe fn ref_to_egg(
  expr: LLVMValueRef,
  mut enode_vec: Vec<VecLang>,
  next_idx: i32,
  gep_map: &mut GEPMap,
  store_map: &mut store_map,
  id_map: &mut id_map,
  symbol_map: &mut symbol_map,
) -> (Vec<VecLang>, i32) {
  match match_llvm_op(&expr) {
    LLVMOpType::Bop => bop_to_egg(
      expr, enode_vec, next_idx, gep_map, store_map, id_map, symbol_map,
    ),
    LLVMOpType::Unop => unop_to_egg(
      expr, enode_vec, next_idx, gep_map, store_map, id_map, symbol_map,
    ),
    LLVMOpType::Constant => const_to_egg(
      expr, enode_vec, next_idx, gep_map, store_map, id_map, symbol_map,
    ),
    LLVMOpType::Gep => gep_to_egg(
      expr, enode_vec, next_idx, gep_map, store_map, id_map, symbol_map,
    ),
    LLVMOpType::Load => load_to_egg(
      expr, enode_vec, next_idx, gep_map, store_map, id_map, symbol_map,
    ),
    LLVMOpType::Store => store_to_egg(
      expr, enode_vec, next_idx, gep_map, store_map, id_map, symbol_map,
    ),
    LLVMOpType::Argument => arg_to_egg(
      expr, enode_vec, next_idx, gep_map, store_map, id_map, symbol_map,
    ),
    LLVMOpType::Call => load_call_to_egg(
      expr, enode_vec, next_idx, gep_map, store_map, id_map, symbol_map,
    ),
    LLVMOpType::FPTrunc => fptrunc_to_egg(
      expr, enode_vec, next_idx, gep_map, store_map, id_map, symbol_map,
    ),
  }
}

unsafe fn llvm_to_egg(
  bb_vec: &[LLVMValueRef],
) -> (RecExpr<VecLang>, GEPMap, store_map, symbol_map) {
  let mut enode_vec = Vec::new();
  let (mut gep_map, mut store_map, mut id_map, mut symbol_map) = (
    BTreeMap::new(),
    BTreeMap::new(),
    BTreeSet::new(),
    BTreeMap::new(),
  );
  let mut next_idx = 0;
  for bop in bb_vec.iter() {
    if isa_store(*bop) {
      let (new_enode_vec, next_idx1) = ref_to_egg(
        *bop,
        enode_vec,
        next_idx,
        &mut gep_map,
        &mut store_map,
        &mut id_map,
        &mut symbol_map,
      );
      next_idx = next_idx1;
      enode_vec = new_enode_vec;
    }
  }
  let mut final_vec = Vec::new();
  for id in id_map.iter() {
    final_vec.push(*id);
  }
  balanced_pad_vector(&mut final_vec, &mut enode_vec);

  let rec_expr = RecExpr::from(enode_vec);
  (rec_expr, gep_map, store_map, symbol_map)
}

unsafe fn translate_egg(
  enode: &VecLang,
  vec: &[VecLang],
  gep_map: &GEPMap,
  store_map: &store_map,
  symbol_map: &symbol_map,
  builder: LLVMBuilderRef,
  context: LLVMContextRef,
  module: LLVMModuleRef,
) -> LLVMValueRef {
  match enode {
    VecLang::Symbol(_) => *symbol_map
      .get(enode)
      .expect("Symbol Should Exist in Symbol Map."),
    VecLang::Num(n) => LLVMConstReal(LLVMFloatType(), *n as f64),
    // VecLang::Num(n) => build_constant_float(*n as f64, context),
    VecLang::Get(..) => {
      let (array_name, array_offsets) = translate_get(enode, vec);
      let gep_value = gep_map
        .get(&(array_name, array_offsets))
        .expect("Symbol map lookup error: Cannot Find GEP");
      if isa_gep(*gep_value) {
        let cloned_gep = LLVMInstructionClone(*gep_value);
        let new_gep = LLVMRecursiveAdd(builder, cloned_gep);
        LLVMBuildLoad(builder, new_gep, b"\0".as_ptr() as *const _)
      } else {
        LLVMBuildLoad(builder, *gep_value, b"\0".as_ptr() as *const _)
      }
    }
    VecLang::LitVec(boxed_ids) | VecLang::Vec(boxed_ids) | VecLang::List(boxed_ids) => {
      let idvec = boxed_ids.to_vec();
      let idvec_len = idvec.len();
      let mut zeros = Vec::new();
      for _ in 0..idvec_len {
        zeros.push(LLVMConstReal(LLVMFloatType(), 0 as f64));
      }
      let zeros_ptr = zeros.as_mut_ptr();
      let mut vector = LLVMConstVector(zeros_ptr, idvec.len() as u32);
      for (idx, &eggid) in idvec.iter().enumerate() {
        let elt = &vec[usize::from(eggid)];
        let elt_val = translate_egg(
          elt, vec, gep_map, store_map, symbol_map, builder, context, module,
        );
        vector = LLVMBuildInsertElement(
          builder,
          vector,
          elt_val,
          LLVMConstInt(LLVMInt32Type(), idx as u64, 0),
          b"\0".as_ptr() as *const _,
        );
      }
      vector
    }
    VecLang::VecAdd([l, r])
    | VecLang::VecMinus([l, r])
    | VecLang::VecMul([l, r])
    | VecLang::VecDiv([l, r])
    | VecLang::Add([l, r])
    | VecLang::Minus([l, r])
    | VecLang::Mul([l, r])
    | VecLang::Div([l, r])
    | VecLang::Or([l, r])
    | VecLang::And([l, r])
    | VecLang::Lt([l, r]) => {
      let left = translate_egg(
        &vec[usize::from(*l)],
        vec,
        gep_map,
        store_map,
        symbol_map,
        builder,
        context,
        module,
      );
      let right = translate_egg(
        &vec[usize::from(*r)],
        vec,
        gep_map,
        store_map,
        symbol_map,
        builder,
        context,
        module,
      );
      if isa_constant(left) && isa_constant(right) {
        let mut loses_info = 1;
        let nright = LLVMConstRealGetDouble(right, &mut loses_info);
        let new_right = build_constant_float(nright, context);
        let nleft = LLVMConstRealGetDouble(left, &mut loses_info);
        let new_left = build_constant_float(nleft, context);
        return translate_binop(
          enode,
          new_left,
          new_right,
          builder,
          b"\0".as_ptr() as *const _,
        );
      } else if isa_constant(right) {
        let mut loses_info = 1;
        let n = LLVMConstRealGetDouble(right, &mut loses_info);
        let new_right = build_constant_float(n, context);
        return translate_binop(enode, left, new_right, builder, b"\0".as_ptr() as *const _);
      } else if isa_constant(left) {
        let mut loses_info = 1;
        let n = LLVMConstRealGetDouble(left, &mut loses_info);
        let new_left = build_constant_float(n, context);
        return translate_binop(enode, new_left, right, builder, b"\0".as_ptr() as *const _);
      } else {
        return translate_binop(enode, left, right, builder, b"\0".as_ptr() as *const _);
      }
    }
    VecLang::Concat([v1, v2]) => {
      let trans_v1 = translate_egg(
        &vec[usize::from(*v1)],
        vec,
        gep_map,
        store_map,
        symbol_map,
        builder,
        context,
        module,
      );
      let mut trans_v2 = translate_egg(
        &vec[usize::from(*v2)],
        vec,
        gep_map,
        store_map,
        symbol_map,
        builder,
        context,
        module,
      );
      // it turns out all vectors need to be length power of 2
      // if the 2 vectors are not the same size, double the length of the smaller vector by padding with 0's in it
      // manually concatenate 2 vectors by using a LLVM shuffle operation.
      let v1_type = LLVMTypeOf(trans_v1);
      let v1_size = LLVMGetVectorSize(v1_type);
      let v2_type = LLVMTypeOf(trans_v2);
      let v2_size = LLVMGetVectorSize(v2_type);

      // HACKY FIX FOR NOW
      // assume both v1 and v2 are pow of 2 size
      // assume v2 size smaller or equal to v1 size
      // assume v2 is 1/2 size of v1
      if v1_size != v2_size {
        // replicate v2 size
        let mut zeros = Vec::new();
        for _ in 0..v2_size {
          zeros.push(LLVMConstReal(LLVMFloatType(), 0 as f64));
        }
        let zeros_ptr = zeros.as_mut_ptr();
        let zeros_vector = LLVMConstVector(zeros_ptr, v2_size);
        let size = 2 * v2_size;
        let mut indices = Vec::new();
        for i in 0..size {
          indices.push(LLVMConstInt(LLVMInt32Type(), i as u64, 0));
        }
        let mask = indices.as_mut_ptr();
        let mask_vector = LLVMConstVector(mask, size);
        trans_v2 = LLVMBuildShuffleVector(
          builder,
          trans_v2,
          zeros_vector,
          mask_vector,
          b"\0".as_ptr() as *const _,
        );
      }
      let size = v1_size + v2_size;
      let mut indices = Vec::new();
      for i in 0..size {
        indices.push(LLVMConstInt(LLVMInt32Type(), i as u64, 0));
      }
      let mask = indices.as_mut_ptr();
      let mask_vector = LLVMConstVector(mask, size);
      LLVMBuildShuffleVector(
        builder,
        trans_v1,
        trans_v2,
        mask_vector,
        b"\0".as_ptr() as *const _,
      )
    }
    VecLang::VecMAC([acc, v1, v2]) => {
      let trans_acc = translate_egg(
        &vec[usize::from(*acc)],
        vec,
        gep_map,
        store_map,
        symbol_map,
        builder,
        context,
        module,
      );
      let trans_v1 = translate_egg(
        &vec[usize::from(*v1)],
        vec,
        gep_map,
        store_map,
        symbol_map,
        builder,
        context,
        module,
      );
      let trans_v2 = translate_egg(
        &vec[usize::from(*v2)],
        vec,
        gep_map,
        store_map,
        symbol_map,
        builder,
        context,
        module,
      );
      let vec_type = LLVMTypeOf(trans_acc);
      let param_types = [vec_type, vec_type, vec_type].as_mut_ptr();
      let fn_type = LLVMFunctionType(vec_type, param_types, 3, 0 as i32);
      let func = LLVMAddFunction(module, b"llvm.fma.f32\0".as_ptr() as *const _, fn_type);
      let args = [trans_v1, trans_v2, trans_acc].as_mut_ptr();
      LLVMBuildCall(builder, func, args, 3, b"\0".as_ptr() as *const _)
    }
    // TODO: VecNeg, VecSqrt, VecSgn all have not been tested, need test cases.
    // TODO: LLVM actually supports many more vector intrinsics, including
    // vector sine/cosine instructions for floats.
    VecLang::VecNeg([v]) => {
      let neg_vector = translate_egg(
        &vec[usize::from(*v)],
        vec,
        gep_map,
        store_map,
        symbol_map,
        builder,
        context,
        module,
      );
      LLVMBuildFNeg(builder, neg_vector, b"\0".as_ptr() as *const _)
    }
    VecLang::VecSqrt([v]) => {
      let sqrt_vec = translate_egg(
        &vec[usize::from(*v)],
        vec,
        gep_map,
        store_map,
        symbol_map,
        builder,
        context,
        module,
      );
      let vec_type = LLVMTypeOf(sqrt_vec);
      let param_types = [vec_type].as_mut_ptr();
      let fn_type = LLVMFunctionType(vec_type, param_types, 1, 0 as i32);
      let func = LLVMAddFunction(module, b"llvm.sqrt.f32\0".as_ptr() as *const _, fn_type);
      let args = [sqrt_vec].as_mut_ptr();
      LLVMBuildCall(builder, func, args, 1, b"\0".as_ptr() as *const _)
    }
    // compliant with c++ LibMath copysign function, which differs with sgn at x = 0.
    VecLang::VecSgn([v]) => {
      let sgn_vec = translate_egg(
        &vec[usize::from(*v)],
        vec,
        gep_map,
        store_map,
        symbol_map,
        builder,
        context,
        module,
      );
      let vec_type = LLVMTypeOf(sgn_vec);
      let vec_size = LLVMGetVectorSize(vec_type);
      let mut ones = Vec::new();
      for _ in 0..vec_size {
        ones.push(LLVMConstReal(LLVMFloatType(), 1 as f64));
      }
      let ones_ptr = ones.as_mut_ptr();
      let ones_vector = LLVMConstVector(ones_ptr, vec_size);
      let param_types = [vec_type, vec_type].as_mut_ptr();
      let fn_type = LLVMFunctionType(vec_type, param_types, 2, 0 as i32);
      let func = LLVMAddFunction(module, b"llvm.copysign.f32\0".as_ptr() as *const _, fn_type);
      let args = [ones_vector, sgn_vec].as_mut_ptr();
      LLVMBuildCall(builder, func, args, 2, b"\0".as_ptr() as *const _)
    }
    VecLang::Sgn([n]) | VecLang::Sqrt([n]) | VecLang::Neg([n]) => {
      let number = translate_egg(
        &vec[usize::from(*n)],
        vec,
        gep_map,
        store_map,
        symbol_map,
        builder,
        context,
        module,
      );
      translate_unop(enode, number, builder, module, b"\0".as_ptr() as *const _)
    }
    VecLang::Ite(..) => panic!("Ite is not handled."),
  }
}

unsafe fn egg_to_llvm(
  expr: RecExpr<VecLang>,
  gep_map: &GEPMap,
  store_map: &store_map,
  symbol_map: &symbol_map,
  module: LLVMModuleRef,
  context: LLVMContextRef,
  builder: LLVMBuilderRef,
) -> () {
  // in fact this will look rather similar to translation from egg to llvm
  // the major differece is how we reconstruct loads and stores
  // whenever we encounter a get instruction, we retranslate as a gep and then a load
  // whenever we encounter an operand that is within the store map, we immediately build a store too.
  // This should maintain the translation

  // Note: You must include all instructions in the basic block, up to the final store
  // The builder mount location must be immediately at the beginning of the basic block to start writing instrucitons

  // Walk the RecExpr and translate it in place to LLVM
  let enode_vec = expr.as_ref();
  let last_enode = enode_vec
    .last()
    .expect("No match for last element of vector of Egg Terms.");
  let vector = translate_egg(
    last_enode, enode_vec, gep_map, store_map, symbol_map, builder, context, module,
  );

  // Add in the Stores
  for (i, (_, addr)) in store_map.iter().enumerate() {
    let index = LLVMConstInt(LLVMInt32Type(), i as u64, 0);
    let extracted_value =
      LLVMBuildExtractElement(builder, vector, index, b"\0".as_ptr() as *const _);
    if isa_argument(*addr) {
      LLVMBuildStore(builder, extracted_value, *addr);
    } else {
      let cloned_addr = LLVMInstructionClone(*addr);
      let new_addr = LLVMRecursiveAdd(builder, cloned_addr);
      LLVMBuildStore(builder, extracted_value, new_addr);
    }
  }
}
