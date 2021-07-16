extern crate llvm_sys as llvm;
pub mod binopsearcher;
pub mod config;
pub mod cost;
pub mod macsearcher;
pub mod rewriteconcats;
pub mod rules;
pub mod searchutils;
pub mod stringconversion;
pub mod veclang;

use llvm::core::*;
use llvm::prelude::*;

// use crate::rules::*;
// use veclang::{VecLang};

use libc::size_t;
// use std::ffi::{OsString, OsStr};
use egg::*;
use veclang::VecLang;
use std::ffi::CStr;
use std::os::raw::c_char;
// use std::convert::TryInto;

extern "C" {
  fn llvm_index(val : LLVMValueRef) -> i32;
  fn llvm_name(val : LLVMValueRef) -> *const c_char;
}

#[no_mangle]
pub fn to_expr(bb_vec : &[LLVMValueRef]) -> RecExpr<VecLang> {
  let (mut vec, mut adds) = (Vec::new(), Vec::new());
  let (mut var, mut num);
  let mut ids = [Id::from(0); 2];
  for add in bb_vec.iter() {
    unsafe {
      let lhs = LLVMGetOperand(LLVMGetOperand(*add, 0), 0);
      let rhs = LLVMGetOperand(LLVMGetOperand(*add, 1), 0);
      
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
      vec.push(VecLang::Add(ids));
      adds.push(Id::from(vec.len() - 1));
    }
  }
  vec.push(VecLang::Vec(adds.into_boxed_slice()));
  return RecExpr::from(vec);
}

// #[no_mangle]
// pub fn to_llvm(expr : RecExpr<VecLang>) -> LLVMValueRef {
//   let vec = expr.as_ref();
// }

#[no_mangle]
pub fn optimize(bb : *const LLVMValueRef, size : size_t) -> () {
  unsafe {
    // llvm to egg
    let expr = to_expr(std::slice::from_raw_parts(bb, size));

    // optimization pass
    println!("{:?}", expr);
    let (_, best) = rules::run(&expr, 180, false, false);
    println!("{:?}", best);

    // TODO: egg to llvm
  }
}