#![allow(unused_variables)]

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

use egg::*;
use libc::size_t;
use llvm::{core::*, prelude::*, LLVMOpcode::*};
use std::{ffi::CStr, os::raw::c_char};
use veclang::VecLang;

use std::collections::HashMap;

extern "C" {
  fn llvm_index(val: LLVMValueRef) -> i32;
  fn llvm_name(val: LLVMValueRef) -> *const c_char;
  fn llvm_operand(val: LLVMValueRef) -> LLVMValueRef;
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
pub fn to_expr(
  bb_vec: &[LLVMValueRef],
) -> (
  RecExpr<VecLang>,
  std::collections::HashMap<egg::Symbol, *mut llvm::LLVMValue>,
) {
  let mut symbol_operand_map = HashMap::new();
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

      let operand1 = llvm_operand(lhs);
      let symbol1 = Symbol::from(name1);
      symbol_operand_map.insert(symbol1, operand1);

      // rhs
      let name2 = CStr::from_ptr(llvm_name(rhs)).to_str().unwrap();
      vec.push(VecLang::Symbol(Symbol::from(name2)));
      var = vec.len() - 1;

      let ind2 = llvm_index(rhs);
      vec.push(VecLang::Num(ind2));
      num = vec.len() - 1;

      vec.push(VecLang::Get([Id::from(var), Id::from(num)]));
      ids[1] = Id::from(vec.len() - 1);

      let operand2 = llvm_operand(rhs);
      let symbol2 = Symbol::from(name2);
      symbol_operand_map.insert(symbol2, operand2);

      // lhs + rhs
      vec.push(choose_binop(bop, ids));
      adds.push(Id::from(vec.len() - 1));
    }
  }
  vec.push(VecLang::Vec(adds.into_boxed_slice()));
  return (RecExpr::from(vec), symbol_operand_map);
}

#[no_mangle]
unsafe fn translate_binop(
  ids: &[egg::Id; 2],
  vec: &[VecLang],
  symbol_map: &HashMap<egg::Symbol, LLVMValueRef>,
  builder: *mut llvm::LLVMBuilder,
  bb: *mut llvm::LLVMBasicBlock,
  context: *mut llvm::LLVMContext,
  name: *const ::libc::c_char,
  constructor: unsafe extern "C" fn(
    LLVMBuilderRef,
    LLVMValueRef,
    LLVMValueRef,
    *const ::libc::c_char,
  ) -> LLVMValueRef,
) -> LLVMValueRef {
  let left = usize::from(ids[0]);
  let left_enode = &vec[left];
  let left_vref = translate(left_enode, vec, symbol_map, builder, bb, context);
  let right = usize::from(ids[1]);
  let right_enode = &vec[right];
  let right_vref = translate(right_enode, vec, symbol_map, builder, bb, context);
  let val = constructor(builder, left_vref, right_vref, name);
  // LLVMAppendExistingBasicBlock(val, bb);
  // LLVMBuildRet(builder, val);
  LLVMDumpValue(val);
  println!("\n");
  val
}

#[no_mangle]
unsafe fn translate(
  enode: &VecLang,
  vec: &[VecLang],
  symbol_map: &HashMap<egg::Symbol, LLVMValueRef>,
  builder: *mut llvm::LLVMBuilder,
  bb: *mut llvm::LLVMBasicBlock,
  context: *mut llvm::LLVMContext,
) -> LLVMValueRef {
  match enode {
    VecLang::Symbol(s) => match symbol_map.get(s) {
      None => panic!("{} not found in symbol map", s),
      Some(val) => *val,
    },
    VecLang::Num(n) => {
      let i64t = LLVMInt64TypeInContext(context);
      let i = LLVMConstInt(i64t, *n as u64, 0);
      LLVMDumpValue(i);
      println!("\n");
      i
    }
    VecLang::Get(ids) => {
      let name = usize::from(ids[0]);
      let name_enode = &vec[name];
      let name_vref = translate(name_enode, vec, symbol_map, builder, bb, context);
      let index = usize::from(ids[1]);
      let index_enode = &vec[index];
      let mut index_vref = translate(index_enode, vec, symbol_map, builder, bb, context);
      let mut_index_vref = &mut index_vref;
      let gep_val = LLVMBuildGEP(
        builder,
        name_vref,
        mut_index_vref,
        1,
        b"geps\0".as_ptr() as *const _,
      );
      LLVMDumpValue(gep_val);
      println!("\n");
      // LLVMAppendExistingBasicBlock(gep_val, bb);
      gep_val
    }
    VecLang::LitVec(boxed_ids) | VecLang::Vec(boxed_ids) => {
      let idvec = boxed_ids.to_vec();
      let length = idvec.len();
      let i64t = LLVMInt64TypeInContext(context);
      // let zero = &mut LLVMConstInt(i64t, 0 as u64, 0);
      let mut array: [LLVMValueRef; config::vector_width()] =
        [LLVMConstInt(i64t, 0 as u64, 0); config::vector_width()];
      let array_ptr = array.as_mut_ptr();
      let mut vector = LLVMConstVector(array_ptr, length as u32);
      for idx in 0..length {
        let eggid = idvec[idx];
        let eggindex = usize::from(eggid);
        let elt = &vec[eggindex];
        let elt_val = translate(elt, vec, symbol_map, builder, bb, context);
        LLVMDumpValue(elt_val);
        println!("\n");
        vector = LLVMBuildInsertElement(
          builder,
          vector,
          elt_val,
          LLVMConstInt(i64t, idx as u64, 0),
          b"vec insert\0".as_ptr() as *const _,
        );
      }
      LLVMDumpValue(vector);
      println!("\n");
      vector
    }
    VecLang::Add(ids) | VecLang::VecAdd(ids) => translate_binop(
      ids,
      vec,
      symbol_map,
      builder,
      bb,
      context,
      b"add\0".as_ptr() as *const _,
      LLVMBuildAdd,
    ),
    VecLang::VecMul(ids) => translate_binop(
      ids,
      vec,
      symbol_map,
      builder,
      bb,
      context,
      b"mul\0".as_ptr() as *const _,
      LLVMBuildMul,
    ),
    VecLang::VecMinus(ids) => translate_binop(
      ids,
      vec,
      symbol_map,
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
pub unsafe fn to_llvm(
  expr: RecExpr<VecLang>,
  symbol_map: &HashMap<egg::Symbol, LLVMValueRef>,
  basic_block: LLVMBasicBlockRef,
  insert_inst: LLVMValueRef,
  context: LLVMContextRef,
) -> LLVMBasicBlockRef {
  let vec = expr.as_ref();
  let last = match vec.last() {
    None => panic!("No match for last element of vector of Egg Terms."),
    Some(term) => term,
  };

  // let context = LLVMContextCreate();
  // let mut module = LLVMModuleCreateWithNameInContext(b"sum\0".as_ptr() as *const _, context);
  // let builder = LLVMCreateBuilderInContext(context);

  // get a type for sum function
  // let i64t = LLVMInt64TypeInContext(context);
  // let mut argts = [i64t, i64t, i64t];
  // let function_type = LLVMFunctionType(i64t, argts.as_mut_ptr(), argts.len() as u32, 0);

  // add it to our module
  // let function = LLVMAddFunction(module, b"sum\0".as_ptr() as *const _, function_type);

  // Create a basic block in the function and set our builder to generate
  // code in it.
  // let bb = LLVMAppendBasicBlockInContext(context, function, b"entry\0".as_ptr() as *const _);

  let builder = LLVMCreateBuilderInContext(context);
  LLVMPositionBuilderBefore(builder, insert_inst);
  let _ = translate(last, vec, symbol_map, builder, basic_block, context);
  // LLVMDumpModule(module);
  // println!("\n");

  let arr = [1, 2, 3];
  let idvec = arr.to_vec();
  let length = idvec.len();
  let i64t = LLVMInt64TypeInContext(context);
  // let zero = &mut LLVMConstInt(i64t, 0 as u64, 0);
  let mut array: [LLVMValueRef; config::vector_width()] =
    [LLVMConstInt(i64t, 0 as u64, 0); config::vector_width()];
  let array_ptr = array.as_mut_ptr();
  let mut vector = LLVMConstVector(array_ptr, length as u32);
  for i in 0..length {
    let val = LLVMConstInt(i64t, i as u64, 0);
    let idx = LLVMConstInt(i64t, i as u64, 0);
    vector = LLVMBuildInsertElement(builder, vector, val, idx, b"insert\0".as_ptr() as *const _);
  }
  let add = LLVMBuildAdd(
    builder,
    vector,
    vector,
    b"vector add\0".as_ptr() as *const _,
  );
  let result = LLVMBuildExtractElement(
    builder,
    vector,
    LLVMConstInt(i64t, 0 as u64, 0),
    b"extract\0".as_ptr() as *const _,
  );
  LLVMBuildRet(builder, add);

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
    let (expr, symbol_operand_map) = to_expr(std::slice::from_raw_parts(bb, size));

    // optimization pass
    println!("{:?}", expr);
    let (_, best) = rules::run(&expr, 180, false, false);
    println!("{:?}", best.as_ref());

    // TODO: egg to llvm
    let result = to_llvm(best, &symbol_operand_map, basic_block, insert_inst, context);
    return result;
  }
}
