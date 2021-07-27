#![allow(unused_variables)]
extern crate llvm_sys as llvm;
use dioslib::{config, rules, veclang::VecLang};
use egg::*;
use libc::size_t;
use llvm::{core::*, prelude::*, LLVMOpcode::*};
use std::{collections::HashMap, ffi::CStr, os::raw::c_char};

extern "C" {
  fn llvm_index(val: LLVMValueRef) -> i32;
  fn llvm_name(val: LLVMValueRef) -> *const c_char;
}

#[no_mangle]
unsafe fn choose_binop(bop: &LLVMValueRef, ids: [egg::Id; 2]) -> VecLang {
  match LLVMGetInstructionOpcode(*bop) {
    LLVMAdd => VecLang::Add(ids),
    LLVMMul => VecLang::Mul(ids),
    LLVMSub => VecLang::Minus(ids),
    LLVMUDiv => VecLang::Div(ids),
    _ => panic!("Match Error"),
  }
}

type GEPMap = HashMap<(egg::Symbol, i32), *mut llvm::LLVMValue>;
type DelInstrs = Vec<LLVMValueRef>;
type OpsReplace = Vec<LLVMValueRef>;

#[no_mangle]
pub fn to_expr(bb_vec: &[LLVMValueRef]) -> (RecExpr<VecLang>, GEPMap, DelInstrs, OpsReplace) {
  let mut gep_map = HashMap::new();
  let mut delete_instrs = Vec::new();
  let mut ops_to_replace = Vec::new();
  let (mut vec, mut adds) = (Vec::new(), Vec::new());
  let (mut var, mut num);
  let mut ids = [Id::from(0); 2];
  for bop in bb_vec.iter() {
    ops_to_replace.push(*bop);
    unsafe {
      let lhs = LLVMGetOperand(LLVMGetOperand(*bop, 0), 0);
      let rhs = LLVMGetOperand(LLVMGetOperand(*bop, 1), 0);
      delete_instrs.push(lhs);
      delete_instrs.push(rhs);
      delete_instrs.push(*bop);

      // lhs
      let name1 = CStr::from_ptr(llvm_name(lhs)).to_str().unwrap();
      vec.push(VecLang::Symbol(Symbol::from(name1)));
      var = vec.len() - 1;

      let ind1 = llvm_index(lhs);
      vec.push(VecLang::Num(ind1));
      num = vec.len() - 1;
      vec.push(VecLang::Get([Id::from(var), Id::from(num)]));
      ids[0] = Id::from(vec.len() - 1);

      let symbol1 = Symbol::from(name1);
      gep_map.insert((symbol1, ind1), lhs);

      // rhs
      let name2 = CStr::from_ptr(llvm_name(rhs)).to_str().unwrap();
      vec.push(VecLang::Symbol(Symbol::from(name2)));
      var = vec.len() - 1;

      let ind2 = llvm_index(rhs);
      vec.push(VecLang::Num(ind2));
      num = vec.len() - 1;

      vec.push(VecLang::Get([Id::from(var), Id::from(num)]));
      ids[1] = Id::from(vec.len() - 1);

      let symbol2 = Symbol::from(name2);
      gep_map.insert((symbol2, ind2), rhs);

      // lhs + rhs
      vec.push(choose_binop(bop, ids));
      adds.push(Id::from(vec.len() - 1));
    }
  }
  vec.push(VecLang::Vec(adds.into_boxed_slice()));
  return (RecExpr::from(vec), gep_map, delete_instrs, ops_to_replace);
}

type LLVMBinopBuilder = unsafe extern "C" fn(
  LLVMBuilderRef,
  LLVMValueRef,
  LLVMValueRef,
  *const ::libc::c_char,
) -> LLVMValueRef;

#[no_mangle]
unsafe fn translate_binop(
  ids: &[egg::Id; 2],
  vec: &[VecLang],
  gep_map: &GEPMap,
  builder: *mut llvm::LLVMBuilder,
  bb: *mut llvm::LLVMBasicBlock,
  context: *mut llvm::LLVMContext,
  name: *const ::libc::c_char,
  constructor: LLVMBinopBuilder,
) -> LLVMValueRef {
  let left = usize::from(ids[0]);
  let left_enode = &vec[left];
  let left_vref = translate(left_enode, vec, gep_map, builder, bb, context);
  let right = usize::from(ids[1]);
  let right_enode = &vec[right];
  let right_vref = translate(right_enode, vec, gep_map, builder, bb, context);
  let val = constructor(builder, left_vref, right_vref, name);
  val
}

#[no_mangle]
unsafe fn translate(
  enode: &VecLang,
  vec: &[VecLang],
  gep_map: &GEPMap,
  builder: *mut llvm::LLVMBuilder,
  bb: *mut llvm::LLVMBasicBlock,
  context: *mut llvm::LLVMContext,
) -> LLVMValueRef {
  match enode {
    VecLang::Symbol(s) => panic!("Symbols are never supposed to be evaluated"),
    VecLang::Num(n) => {
      let i64t = LLVMInt32TypeInContext(context);
      LLVMConstInt(i64t, *n as u64, 0)
    }
    VecLang::Get(ids) => {
      let name = usize::from(ids[0]);
      let name_enode = &vec[name];
      let array_name = match name_enode {
        VecLang::Symbol(s) => *s,
        _ => panic!("Match error in get enode: Expected Symbol."),
      };
      let offset = usize::from(ids[1]);
      let offset_enode = &vec[offset];
      let offset_num = match offset_enode {
        VecLang::Num(n) => *n,
        _ => panic!("Match error in get enode: Expected Num."),
      };
      let key = &(array_name, offset_num);
      let gep_value = match gep_map.get(key) {
        None => panic!("{:?} not found in symbol map", key),
        Some(val) => *val,
      };
      // let gep_value = translate(name_enode, vec, gep_map, builder, bb, context);
      LLVMBuildLoad(builder, gep_value, b"load\0".as_ptr() as *const _)
    }
    VecLang::LitVec(boxed_ids) | VecLang::Vec(boxed_ids) => {
      let idvec = boxed_ids.to_vec();
      let length = idvec.len();
      let i64t = LLVMInt32TypeInContext(context);
      let mut array: [LLVMValueRef; config::vector_width()] =
        [LLVMConstInt(i64t, 0 as u64, 0); config::vector_width()];
      let array_ptr = array.as_mut_ptr();
      let mut vector = LLVMConstVector(array_ptr, length as u32);
      for idx in 0..length {
        let eggid = idvec[idx];
        let eggindex = usize::from(eggid);
        let elt = &vec[eggindex];
        let elt_val = translate(elt, vec, gep_map, builder, bb, context);
        vector = LLVMBuildInsertElement(
          builder,
          vector,
          elt_val,
          LLVMConstInt(i64t, idx as u64, 0),
          b"vec insert\0".as_ptr() as *const _,
        );
      }
      vector
    }
    VecLang::Add(ids) | VecLang::VecAdd(ids) => translate_binop(
      ids,
      vec,
      gep_map,
      builder,
      bb,
      context,
      b"add\0".as_ptr() as *const _,
      LLVMBuildAdd,
    ),
    VecLang::VecMul(ids) => translate_binop(
      ids,
      vec,
      gep_map,
      builder,
      bb,
      context,
      b"mul\0".as_ptr() as *const _,
      LLVMBuildMul,
    ),
    VecLang::VecMinus(ids) => translate_binop(
      ids,
      vec,
      gep_map,
      builder,
      bb,
      context,
      b"sub\0".as_ptr() as *const _,
      LLVMBuildSub,
    ),
    _ => panic!("Unimplemented"),
  }
}

#[no_mangle]
unsafe fn delete_insts(instr_vec: &DelInstrs) -> () {
  for instr in instr_vec.iter() {
    LLVMInstructionEraseFromParent(*instr);
  }
}

#[no_mangle]
pub unsafe fn to_llvm(
  expr: RecExpr<VecLang>,
  gep_map: &GEPMap,
  del_instrs: &DelInstrs,
  ops_to_replace: &OpsReplace,
  basic_block: LLVMBasicBlockRef,
  insert_instr: LLVMValueRef,
  context: LLVMContextRef,
) -> LLVMBasicBlockRef {
  let vec = expr.as_ref();
  let last = match vec.last() {
    None => panic!("No match for last element of vector of Egg Terms."),
    Some(term) => term,
  };

  let builder = LLVMCreateBuilderInContext(context);
  let one_before = LLVMGetPreviousInstruction(insert_instr);
  let two_before = LLVMGetPreviousInstruction(one_before);
  let three_before = LLVMGetPreviousInstruction(two_before);
  LLVMPositionBuilderBefore(builder, two_before);
  let vector = translate(last, vec, gep_map, builder, basic_block, context);

  for i in 0..ops_to_replace.len() {
    let i64t = LLVMInt32TypeInContext(context);
    let index = LLVMConstInt(i64t, i as u64, 0);
    let extracted_value =
      LLVMBuildExtractElement(builder, vector, index, b"extract\0".as_ptr() as *const _);
    let op = ops_to_replace[i];
    let gep_instr = LLVMGetNextInstruction(op);
    let store_instr = LLVMGetNextInstruction(gep_instr);
    let cloned_store = LLVMInstructionClone(store_instr);
    LLVMSetOperand(cloned_store, 0, extracted_value);
    LLVMDumpValue(cloned_store);
    println!();
    LLVMInsertIntoBuilder(builder, cloned_store);
  }

  // delete_insts(del_instrs);

  return basic_block;
}

#[no_mangle]
pub fn optimize(
  context: LLVMContextRef,
  basic_block: LLVMBasicBlockRef,
  insert_inst: LLVMValueRef,
  bb: *const LLVMValueRef,
  size: size_t,
) -> LLVMBasicBlockRef {
  unsafe {
    // llvm to egg
    let (expr, gep_map, del_instrs, ops_to_replace) = to_expr(std::slice::from_raw_parts(bb, size));

    // optimization pass
    println!("{:?}", expr);
    let (_, best) = rules::run(&expr, 180, false, false);
    println!("{:?}", best.as_ref());

    // TODO: egg to llvm
    let result = to_llvm(
      best,
      &gep_map,
      &del_instrs,
      &ops_to_replace,
      basic_block,
      insert_inst,
      context,
    );
    return result;
  }
}
