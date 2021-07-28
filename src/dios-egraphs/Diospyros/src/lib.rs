extern crate llvm_sys as llvm;

use dioslib::{config, rules, veclang::VecLang};
use egg::*;
use libc::size_t;
use llvm::{core::*, prelude::*, LLVMOpcode::*};
use std::{collections::HashMap, ffi::CStr, os::raw::c_char, slice::from_raw_parts};

extern "C" {
  fn llvm_index(val: LLVMValueRef) -> i32;
  fn llvm_name(val: LLVMValueRef) -> *const c_char;
}

#[no_mangle]
unsafe fn choose_binop(bop: &LLVMValueRef, ids: [Id; 2]) -> VecLang {
  match LLVMGetInstructionOpcode(*bop) {
    LLVMAdd => VecLang::Add(ids),
    LLVMMul => VecLang::Mul(ids),
    LLVMSub => VecLang::Minus(ids),
    LLVMUDiv => VecLang::Div(ids),
    _ => panic!("Match Error"),
  }
}

type GEPMap = HashMap<(Symbol, i32), LLVMValueRef>;
type ValueVec = Vec<LLVMValueRef>;

#[no_mangle]
pub fn to_expr(bb_vec: &[LLVMValueRef]) -> (RecExpr<VecLang>, GEPMap, ValueVec) {
  let mut gep_map = HashMap::new();
  let (mut vec, mut adds, mut ops_to_replace) = (Vec::new(), Vec::new(), Vec::new());
  let (mut var, mut num);
  let mut ids = [Id::from(0); 2];
  for bop in bb_vec.iter() {
    ops_to_replace.push(*bop);
    unsafe {
      let lhs = LLVMGetOperand(LLVMGetOperand(*bop, 0), 0);
      let rhs = LLVMGetOperand(LLVMGetOperand(*bop, 1), 0);

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
  return (RecExpr::from(vec), gep_map, ops_to_replace);
}

#[no_mangle]
unsafe fn translate_binop(
  enode: &VecLang,
  left: LLVMValueRef,
  right: LLVMValueRef,
  builder: LLVMBuilderRef,
  name: *const c_char,
) -> LLVMValueRef {
  match enode {
    VecLang::VecAdd(_) => 
      LLVMBuildAdd(builder, left, right, name),
    VecLang::VecMul(_) => 
      LLVMBuildMul(builder, left, right, name),
    VecLang::VecMinus(_) => 
      LLVMBuildSub(builder, left, right, name),
    VecLang::VecDiv(_) =>
      LLVMBuildSDiv(builder, left, right, name),
    _ => panic!("not a binop")
  }
}

#[no_mangle]
unsafe fn translate(
  enode: &VecLang,
  vec: &[VecLang],
  gep_map: &GEPMap,
  builder: LLVMBuilderRef,
) -> LLVMValueRef {
  match enode {
    VecLang::Symbol(_) => panic!("Symbols are never supposed to be evaluated"),
    VecLang::Num(n) => {
      LLVMConstInt(LLVMInt32Type(), *n as u64, 0)
    }
    VecLang::Get([sym, i]) => {
      let array_name = match &vec[usize::from(*sym)] {
        VecLang::Symbol(s) => *s,
        _ => panic!("Match error in get enode: Expected Symbol."),
      };
      let offset_num = match &vec[usize::from(*i)] {
        VecLang::Num(n) => *n,
        _ => panic!("Match error in get enode: Expected Num."),
      };
      let gep_value = gep_map.get(&(array_name, offset_num)).expect("Symbol map lookup error");
      LLVMBuildLoad(builder, *gep_value, b"\0".as_ptr() as *const _)
    }
    VecLang::LitVec(boxed_ids) | VecLang::Vec(boxed_ids) => {
      let idvec = boxed_ids.to_vec();
      let array = [LLVMConstInt(LLVMInt32Type(), 0 as u64, 0); config::vector_width()].as_mut_ptr();
      let mut vector = LLVMConstVector(array, idvec.len() as u32);
      for (idx, &eggid) in idvec.iter().enumerate() {
        let elt = &vec[usize::from(eggid)];
        let elt_val = translate(elt, vec, gep_map, builder);
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
    VecLang::VecAdd(ids) | VecLang::VecMinus(ids) | VecLang::VecMul(ids) | VecLang::VecDiv(ids) => {
      let left = translate(&vec[usize::from(ids[0])], vec, gep_map, builder);
      let right = translate(&vec[usize::from(ids[1])], vec, gep_map, builder);
      translate_binop(enode, left, right, builder, b"\0".as_ptr() as *const _)
    },
    _ => panic!("Unimplemented"),
  }
}


#[no_mangle]
pub unsafe fn to_llvm(
  expr: RecExpr<VecLang>,
  gep_map: &GEPMap,
  ops_to_replace: &ValueVec,
  builder: LLVMBuilderRef,
) -> () {
  let vec = expr.as_ref();
  let last = vec.last().expect("No match for last element of vector of Egg Terms.");

  let vector = translate(last, vec, gep_map, builder);

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
  builder: LLVMBuilderRef,
  bb: *const LLVMValueRef,
  size: size_t,
) -> () {
  unsafe {
    // llvm to egg
    let (expr, gep_map, ops_to_replace) = to_expr(from_raw_parts(bb, size));

    // optimization pass
    eprintln!("{:?}", expr);
    let (_, best) = rules::run(&expr, 180, false, false);
    eprintln!("{:?}", best.as_ref());

    // egg to llvm
    to_llvm(best, &gep_map, &ops_to_replace, builder);
  }
}
