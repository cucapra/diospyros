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
use llvm::LLVMOpcode::*;

// use crate::rules::*;
// use veclang::{VecLang};

use libc::size_t;
// use std::ffi::{OsString, OsStr};
use egg::*;
use std::ffi::CStr;
use std::os::raw::c_char;
use veclang::VecLang;
// use std::convert::TryInto;

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

unsafe fn translate(
  enode: &VecLang,
  vec: &[VecLang],
  builder: *mut llvm::LLVMBuilder,
  context: *mut llvm::LLVMContext,
) -> LLVMValueRef {
  match enode {
    VecLang::Symbol(s) => panic!("Unimplemented"),
    VecLang::Num(n) => {
      let i64t = LLVMInt64TypeInContext(context);
      LLVMConstInt(i64t, *n as u64, 0)
    }
    VecLang::Get(ids) => {
      let name = usize::from(ids[0]);
      let name_enode = &vec[name];
      let name_vref = translate(name_enode, vec, builder, context);
      let index = usize::from(ids[1]);
      let index_enode = &vec[index];
      let mut index_vref = translate(index_enode, vec, builder, context);
      let mut_index_vref = &mut index_vref;
      LLVMBuildGEP(
        builder,
        name_vref,
        mut_index_vref,
        1,
        b"geps\0".as_ptr() as *const _,
      )
    }
    VecLang::Add(ids) => panic!("Unimplemented"),
    _ => panic!("Unimplemented"),
  }
}

#[no_mangle]
pub unsafe fn to_llvm(expr: RecExpr<VecLang>) -> LLVMValueRef {
  let vec = expr.as_ref();
  let context = LLVMContextCreate();
  let module = LLVMModuleCreateWithNameInContext(b"sum\0".as_ptr() as *const _, context);
  let builder = LLVMCreateBuilderInContext(context);

  // get a type for sum function
  let i64t = LLVMInt64TypeInContext(context);
  let mut argts = [i64t, i64t, i64t];
  let function_type = LLVMFunctionType(i64t, argts.as_mut_ptr(), argts.len() as u32, 0);

  // add it to our module
  let function = LLVMAddFunction(module, b"sum\0".as_ptr() as *const _, function_type);

  // Create a basic block in the function and set our builder to generate
  // code in it.
  let bb = LLVMAppendBasicBlockInContext(context, function, b"entry\0".as_ptr() as *const _);
  return LLVMBasicBlockAsValue(bb);
}

#[no_mangle]
pub fn optimize(bb: *const LLVMValueRef, size: size_t) -> () {
  unsafe {
    // llvm to egg
    let expr = to_expr(std::slice::from_raw_parts(bb, size));

    // optimization pass
    println!("{:?}", expr);
    let (_, best) = rules::run(&expr, 180, false, false);
    println!("{:?}", best.as_ref());

    // TODO: egg to llvm
  }
}
