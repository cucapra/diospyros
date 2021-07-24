#![allow(unused_variables)]
extern crate llvm_sys as llvm;
use llvm::{core::*, prelude::*, LLVMOpcode::*};
use libc::size_t;
use egg::*;
use veclang::VecLang;
use std::{ffi::CStr, os::raw::c_char};

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

#[no_mangle]
pub fn to_expr(bb_vec: &[LLVMValueRef]) -> RecExpr<VecLang> {
  let (mut vec, mut adds) = (Vec::new(), Vec::new());
  let (mut var, mut num);
  let mut ids = [Id::from(0); 2];
  for bop in bb_vec.iter() {
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

      // rhs
      let name2 = CStr::from_ptr(llvm_name(rhs)).to_str().unwrap();
      vec.push(VecLang::Symbol(Symbol::from(name2)));
      var = vec.len() - 1;

      let ind2 = llvm_index(rhs);
      vec.push(VecLang::Num(ind2));
      num = vec.len() - 1;

      vec.push(VecLang::Get([Id::from(var), Id::from(num)]));
      ids[1] = Id::from(vec.len() - 1);

      // lhs + rhs
      vec.push(choose_binop(bop, ids));
      adds.push(Id::from(vec.len() - 1));
    }
  }
  vec.push(VecLang::Vec(adds.into_boxed_slice()));
  return RecExpr::from(vec);
}

#[no_mangle]
pub fn to_llvm(expr : RecExpr<VecLang>, inst : LLVMValueRef) -> LLVMValueRef {
  let exprs = RecExpr::as_ref(&expr);
  let last = expr.as_ref().last().unwrap();
  let _llvm_inst = eval_expr(last, exprs, inst);
  return inst;
}

#[no_mangle]
pub fn eval_expr(expr : &VecLang, exprs : &[VecLang], inst : LLVMValueRef) -> LLVMValueRef {
  match expr {
    VecLang::VecAdd([l, r]) => {
      ()
    },
    VecLang::LitVec(v) | VecLang::Vec(v) => (),
    VecLang::Symbol(s) => (),
    VecLang::Num(i) => (),
    _ => ()
  }
  return inst;
}

#[no_mangle]
pub fn optimize(bb: *const LLVMValueRef, size: size_t) -> () {
  unsafe {
    // llvm to egg
    let expr = to_expr(std::slice::from_raw_parts(bb, size));

    // optimization pass
    println!("{:?}", expr);
    let (_, best) = rules::run(&expr, 180, false, false);
    println!("{:?}", best);

    // TODO: egg to llvm
    let _lexpr = to_llvm(best, *bb);
  }
}
