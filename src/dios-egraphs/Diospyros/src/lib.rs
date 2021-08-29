extern crate llvm_sys as llvm;
use dioslib::{config, rules, veclang::VecLang};
use egg::*;
use libc::size_t;
use llvm::{core::*, prelude::*, LLVMOpcode::*, LLVMRealPredicate};
use std::{collections::HashMap, ffi::CStr, os::raw::c_char, slice::from_raw_parts};

extern "C" {
  fn llvm_index(val: LLVMValueRef, index: i32) -> i32;
  fn llvm_name(val: LLVMValueRef) -> *const c_char;
  fn isa_constant(val: LLVMValueRef) -> bool;
  fn isa_gep(val: LLVMValueRef) -> bool;
  fn isa_load(val: LLVMValueRef) -> bool;
  fn isa_store(val: LLVMValueRef) -> bool;
  fn get_constant_float(val: LLVMValueRef) -> f32;
  fn dfs_llvm_value_ref(val: LLVMValueRef, match_val: LLVMValueRef) -> bool;
}

type GEPMap = HashMap<(Symbol, Symbol), LLVMValueRef>;
type VarMap = HashMap<Symbol, LLVMValueRef>;
type ValueVec = Vec<LLVMValueRef>;

unsafe fn choose_binop(bop: &LLVMValueRef, ids: [Id; 2]) -> VecLang {
  match LLVMGetInstructionOpcode(*bop) {
    LLVMFAdd => VecLang::Add(ids),
    LLVMFMul => VecLang::Mul(ids),
    LLVMFSub => VecLang::Minus(ids),
    LLVMFDiv => VecLang::Div(ids),
    _ => panic!("Choose_Binop: Opcode Match Error"),
  }
}

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

unsafe fn to_expr_gep(
  gep_operand: &LLVMValueRef,
  ids: &mut [egg::Id; 2],
  id_index: usize,
  enode_vec: &mut Vec<VecLang>,
  gep_map: &mut GEPMap,
) -> () {
  // let gep_operand = LLVMGetOperand(*operand, 0);
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

unsafe fn mark_used_bops(
  operand: &LLVMValueRef,
  ids: &mut [egg::Id; 2],
  id_index: usize,
  bop_map: &mut HashMap<LLVMValueRef, Id>,
  used_bop_ids: &mut Vec<Id>,
) -> bool {
  let mut changed = false;
  for (&prev_used_bop, &mut prev_used_id) in bop_map {
    if dfs_llvm_value_ref(*operand, prev_used_bop) {
      ids[id_index] = prev_used_id;
      used_bop_ids.push(prev_used_id);

      changed |= true;
      println!("Operand");
      LLVMDumpValue(*operand);
      println!();
      println!("Value");
      LLVMDumpValue(prev_used_bop);
      println!();
      println!("Used");
    }
  }
  return changed;
}

unsafe fn to_expr_operand(
  operand: &LLVMValueRef,
  bop_map: &mut HashMap<LLVMValueRef, Id>,
  ids: &mut [egg::Id; 2],
  id_index: usize,
  used_bop_ids: &mut Vec<Id>,
  enode_vec: &mut Vec<VecLang>,
  gep_map: &mut GEPMap,
  var_map: &mut VarMap,
) -> () {
  // let removed_bops = mark_used_bops(operand, ids, id_index, bop_map, used_bop_ids);
  // if removed_bops {
  //   return ();
  // }
  if bop_map.contains_key(&operand) {
    let used_id = *bop_map.get(&operand).expect("Expected key in map");
    ids[id_index] = used_id;
    used_bop_ids.push(used_id);
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

pub fn to_expr(bb_vec: &[LLVMValueRef]) -> (RecExpr<VecLang>, GEPMap, VarMap, ValueVec) {
  let (mut enode_vec, mut bops_vec, mut ops_to_replace, mut used_bop_ids) =
    (Vec::new(), Vec::new(), Vec::new(), Vec::new());
  let (mut gep_map, mut var_map, mut bop_map) = (HashMap::new(), HashMap::new(), HashMap::new());
  let mut ids = [Id::from(0); 2];
  for bop in bb_vec.iter() {
    unsafe {
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
      let id = Id::from(enode_vec.len() - 1);
      bops_vec.push(id);

      ops_to_replace.push((*bop, id));

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

      bop_map.insert(*bop, id);
    }
  }
  // decompose bops_vec into width number of binops
  pad_vector(&bops_vec, &mut enode_vec);
  // enode_vec.push(VecLang::Vec(bops_vec.into_boxed_slice()));

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
      // let array = [LLVMConstReal(LLVMFloatType(), 0 as f64); config::vector_width()].as_mut_ptr();
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
    // TODO: Consider changing to floating point operations to allow for Unary fneg llvm instruction
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

  let vector = translate(last, vec, gep_map, var_map, builder, module);

  for (i, op) in ops_to_replace.iter().enumerate() {
    let index = LLVMConstInt(LLVMInt32Type(), i as u64, 0);
    let extracted_value =
      LLVMBuildExtractElement(builder, vector, index, b"\0".as_ptr() as *const _);
    // figure out where the next store is located
    let mut store_instr = *op;
    // assumes there is a store next: could swegafault or loop forever if not.
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

#[no_mangle]
pub fn optimize(
  module: LLVMModuleRef,
  builder: LLVMBuilderRef,
  bb: *const LLVMValueRef,
  size: size_t,
) -> () {
  unsafe {
    // llvm to egg
    let (expr, gep_map, var_map, ops_to_replace) = to_expr(from_raw_parts(bb, size));

    // optimization pass
    eprintln!("{:?}", expr);
    let (_, best) = rules::run(&expr, 180, true, false);
    eprintln!("{:?}", best.as_ref());

    // egg to llvm
    to_llvm(module, best, &gep_map, &var_map, &ops_to_replace, builder);
  }
}
