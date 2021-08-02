extern crate llvm_sys as llvm;
use dioslib::{rules, veclang::VecLang};
use egg::*;
use libc::size_t;
use llvm::{core::*, prelude::*, LLVMOpcode::*, LLVMRealPredicate};
use std::{collections::HashMap, ffi::CStr, os::raw::c_char, slice::from_raw_parts};

extern "C" {
  fn llvm_index(val: LLVMValueRef, index: i32) -> i32;
  fn llvm_name(val: LLVMValueRef) -> *const c_char;
  fn isa_constant(val: LLVMValueRef) -> bool;
  fn get_constant_float(val: LLVMValueRef) -> f32;
}

type GEPMap = HashMap<(Symbol, Symbol), LLVMValueRef>;
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

unsafe fn to_expr_gep(
  operand: &LLVMValueRef,
  bop_map: &mut HashMap<LLVMValueRef, Id>,
  ids: &mut [egg::Id; 2],
  id_index: usize,
  used_bop_ids: &mut Vec<Id>,
  enode_vec: &mut Vec<VecLang>,
  gep_map: &mut GEPMap,
) -> () {
  let gep_operand = LLVMGetOperand(*operand, 0);
  if bop_map.contains_key(&operand) {
    let used_id = *bop_map.get(&operand).expect("Expected key in map");
    ids[id_index] = used_id;
    used_bop_ids.push(used_id);
  } else {
    let array_var_name = CStr::from_ptr(llvm_name(gep_operand)).to_str().unwrap();
    enode_vec.push(VecLang::Symbol(Symbol::from(array_var_name)));
    let array_var_idx = enode_vec.len() - 1;
    // --- get offsets for multidimensional arrays ----
    let num_gep_operands = LLVMGetNumOperands(gep_operand);
    let mut indices = Vec::new();
    for operand_idx in 2..num_gep_operands {
      let array_offset = llvm_index(gep_operand, operand_idx);
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
    gep_map.insert((array_name_symbol, offsets_symbol), gep_operand);
  }
}

pub fn to_expr(bb_vec: &[LLVMValueRef]) -> (RecExpr<VecLang>, GEPMap, ValueVec) {
  let (mut enode_vec, mut bops_vec, mut ops_to_replace, mut used_bop_ids) =
    (Vec::new(), Vec::new(), Vec::new(), Vec::new());
  let (mut gep_map, mut bop_map) = (HashMap::new(), HashMap::new());
  let mut ids = [Id::from(0); 2];
  for bop in bb_vec.iter() {
    unsafe {
      let left_operand = LLVMGetOperand(*bop, 0);
      let right_operand = LLVMGetOperand(*bop, 1);
      if isa_constant(left_operand) {
        to_expr_constant(&left_operand, &mut enode_vec, &mut ids, 0);
      } else {
        to_expr_gep(
          &left_operand,
          &mut bop_map,
          &mut ids,
          0,
          &mut used_bop_ids,
          &mut enode_vec,
          &mut gep_map,
        );
      }
      if isa_constant(right_operand) {
        to_expr_constant(&right_operand, &mut enode_vec, &mut ids, 1);
      } else {
        to_expr_gep(
          &right_operand,
          &mut bop_map,
          &mut ids,
          1,
          &mut used_bop_ids,
          &mut enode_vec,
          &mut gep_map,
        );
      }

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
  enode_vec.push(VecLang::Vec(bops_vec.into_boxed_slice()));

  // remove binary ops that were used, and thus not the ones we want to replace directly
  let mut final_ops_to_replace = Vec::new();
  for (bop, id) in ops_to_replace.iter() {
    if !used_bop_ids.contains(id) {
      final_ops_to_replace.push(*bop);
    }
  }

  return (RecExpr::from(enode_vec), gep_map, final_ops_to_replace);
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
  builder: LLVMBuilderRef,
  module: LLVMModuleRef,
) -> LLVMValueRef {
  match enode {
    VecLang::Symbol(_) => panic!("Symbols are never supposed to be evaluated"),
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
        let elt_val = translate(elt, vec, gep_map, builder, module);
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
      let left = translate(&vec[usize::from(*l)], vec, gep_map, builder, module);
      let right = translate(&vec[usize::from(*r)], vec, gep_map, builder, module);
      translate_binop(enode, left, right, builder, b"\0".as_ptr() as *const _)
    }
    VecLang::Concat([v1, v2]) => {
      let trans_v1 = translate(&vec[usize::from(*v1)], vec, gep_map, builder, module);
      let trans_v2 = translate(&vec[usize::from(*v2)], vec, gep_map, builder, module);
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
      let trans_acc = translate(&vec[usize::from(*acc)], vec, gep_map, builder, module);
      let trans_v1 = translate(&vec[usize::from(*v1)], vec, gep_map, builder, module);
      let trans_v2 = translate(&vec[usize::from(*v2)], vec, gep_map, builder, module);
      let vec_type = LLVMTypeOf(trans_acc);

      let param_types = [vec_type, vec_type, vec_type].as_mut_ptr();
      let fn_type = LLVMFunctionType(vec_type, param_types, 3, 0 as i32);
      let func = LLVMAddFunction(module, b"llvm.fma.f32\0".as_ptr() as *const _, fn_type);
      let args = [trans_v1, trans_v2, trans_acc].as_mut_ptr();
      LLVMBuildCall(builder, func, args, 3, b"\0".as_ptr() as *const _)
    }
    // TODO: Consider changing to floating point operations to allow for Unary fneg llvm instruction
    VecLang::VecNeg([v]) => {
      let neg_vector = translate(&vec[usize::from(*v)], vec, gep_map, builder, module);
      LLVMBuildFNeg(builder, neg_vector, b"\0".as_ptr() as *const _)
    }
    VecLang::VecSqrt([v]) => {
      let sqrt_vec = translate(&vec[usize::from(*v)], vec, gep_map, builder, module);
      let vec_type = LLVMTypeOf(sqrt_vec);
      let param_types = [vec_type].as_mut_ptr();
      let fn_type = LLVMFunctionType(vec_type, param_types, 1, 0 as i32);
      let func = LLVMAddFunction(module, b"llvm.sqrt.f32\0".as_ptr() as *const _, fn_type);
      let args = [sqrt_vec].as_mut_ptr();
      LLVMBuildCall(builder, func, args, 1, b"\0".as_ptr() as *const _)
    }
    // compliant with c++ LibMath copysign function, which differs with sgn at x = 0.
    VecLang::VecSgn([v]) => {
      let sgn_vec = translate(&vec[usize::from(*v)], vec, gep_map, builder, module);
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
      let number = translate(&vec[usize::from(*n)], vec, gep_map, builder, module);
      translate_unop(enode, number, builder, module, b"\0".as_ptr() as *const _)
    }
    VecLang::Ite(..) => panic!("Ite is not handled."),
  }
}

unsafe fn to_llvm(
  module: LLVMModuleRef,
  expr: RecExpr<VecLang>,
  gep_map: &GEPMap,
  ops_to_replace: &ValueVec,
  builder: LLVMBuilderRef,
) -> () {
  let vec = expr.as_ref();
  let last = vec
    .last()
    .expect("No match for last element of vector of Egg Terms.");

  let vector = translate(last, vec, gep_map, builder, module);

  for (i, op) in ops_to_replace.iter().enumerate() {
    let index = LLVMConstInt(LLVMInt32Type(), i as u64, 0);
    let extracted_value =
      LLVMBuildExtractElement(builder, vector, index, b"\0".as_ptr() as *const _);
    let store_instr = LLVMGetNextInstruction(LLVMGetNextInstruction(*op));
    let cloned_store = LLVMInstructionClone(store_instr);
    LLVMSetOperand(cloned_store, 0, extracted_value);
    LLVMInsertIntoBuilder(builder, cloned_store);
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
    let (expr, gep_map, ops_to_replace) = to_expr(from_raw_parts(bb, size));

    // optimization pass
    eprintln!("{:?}", expr);
    let (_, best) = rules::run(&expr, 180, true, false);
    eprintln!("{:?}", best.as_ref());

    // egg to llvm
    to_llvm(module, best, &gep_map, &ops_to_replace, builder);
  }
}
