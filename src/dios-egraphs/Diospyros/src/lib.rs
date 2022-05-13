#![allow(dead_code)]
extern crate llvm_sys as llvm;
use dioslib::{config, rules, veclang::VecLang};
use egg::*;
use libc::size_t;
use llvm::{core::*, prelude::*, LLVMOpcode::*, LLVMRealPredicate};
use std::{
  cmp,
  collections::{BTreeMap, BTreeSet},
  os::raw::c_char,
  slice::from_raw_parts,
};

extern "C" {
  fn _llvm_index(val: LLVMValueRef, index: i32) -> i32;
  fn _llvm_name(val: LLVMValueRef) -> *const c_char;
  fn _isa_unop(val: LLVMValueRef) -> bool;
  fn _isa_bop(val: LLVMValueRef) -> bool;
  fn isa_constant(val: LLVMValueRef) -> bool;
  fn isa_constfp(val: LLVMValueRef) -> bool;
  fn _isa_gep(val: LLVMValueRef) -> bool;
  fn _isa_load(val: LLVMValueRef) -> bool;
  fn _isa_store(val: LLVMValueRef) -> bool;
  fn isa_argument(val: LLVMValueRef) -> bool;
  fn _isa_call(val: LLVMValueRef) -> bool;
  fn _isa_fptrunc(val: LLVMValueRef) -> bool;
  fn _isa_fpext(val: LLVMValueRef) -> bool;
  fn _isa_alloca(val: LLVMValueRef) -> bool;
  fn _isa_phi(val: LLVMValueRef) -> bool;
  fn _isa_sextint(val: LLVMValueRef) -> bool;
  fn _isa_sitofp(val: LLVMValueRef) -> bool;
  fn isa_constaggregatezero(val: LLVMValueRef) -> bool;
  fn _isa_constaggregate(val: LLVMValueRef) -> bool;
  fn isa_integertype(val: LLVMValueRef) -> bool;
  fn _isa_intptr(val: LLVMValueRef) -> bool;
  fn _isa_floatptr(val: LLVMValueRef) -> bool;
  fn _isa_floattype(val: LLVMValueRef) -> bool;
  fn _isa_bitcast(val: LLVMValueRef) -> bool;
  fn isa_sqrt32(val: LLVMValueRef) -> bool;
  fn _isa_sqrt64(val: LLVMValueRef) -> bool;
  fn get_constant_float(val: LLVMValueRef) -> f32;
  fn build_constant_float(n: f64, context: LLVMContextRef) -> LLVMValueRef;
}

static mut ARG_IDX: u32 = 0;
static mut REG_IDX: u32 = 0;

unsafe fn gen_arg_idx() -> u32 {
  ARG_IDX += 1;
  return ARG_IDX;
}

unsafe fn gen_reg_idx() -> u32 {
  REG_IDX += 1;
  return REG_IDX;
}

// Reference Comparison: https://www.reddit.com/r/rust/comments/2r3wjk/is_there_way_to_compare_objects_by_address_in_rust/
// Compares whether addresses of LLVMValueRefs are the same.
// Not the contents of the Value Refs
fn cmp_val_ref_address(a1: &llvm::LLVMValue, a2: &llvm::LLVMValue) -> bool {
  a1 as *const _ == a2 as *const _
}

fn _cmp_typ(a1: &LLVMTypeRef, a2: &LLVMTypeRef) -> bool {
  a1 as *const _ == a2 as *const _
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
  context: LLVMContextRef,
  module: LLVMModuleRef,
  name: *const c_char,
) -> LLVMValueRef {
  match enode {
    VecLang::Sgn(_) => {
      let one = LLVMConstReal(LLVMFloatTypeInContext(context), 1 as f64);
      let param_types = [
        LLVMFloatTypeInContext(context),
        LLVMFloatTypeInContext(context),
      ]
      .as_mut_ptr();
      let fn_type = LLVMFunctionType(LLVMFloatTypeInContext(context), param_types, 2, 0 as i32);
      let func = LLVMAddFunction(module, b"llvm.copysign.f32\0".as_ptr() as *const _, fn_type);
      let args = [one, n].as_mut_ptr();
      LLVMBuildCall(builder, func, args, 2, name)
    }
    VecLang::Sqrt(_) => {
      let param_types = [LLVMFloatTypeInContext(context)].as_mut_ptr();
      let fn_type = LLVMFunctionType(LLVMFloatTypeInContext(context), param_types, 1, 0 as i32);
      let func = LLVMAddFunction(module, b"llvm.sqrt.f32\0".as_ptr() as *const _, fn_type);
      let args = [n].as_mut_ptr();
      LLVMBuildCall(builder, func, args, 1, name)
    }
    VecLang::Neg(_) => LLVMBuildFNeg(builder, n, name),
    _ => panic!("Not a scalar unop."),
  }
}

/// Main function to optimize: Takes in a basic block of instructions,
/// optimizes it, and then translates it to LLVM IR code, in place.

#[no_mangle]
pub fn optimize(
  module: LLVMModuleRef,
  context: LLVMContextRef,
  builder: LLVMBuilderRef,
  chunk_instrs: *const LLVMValueRef,
  chunk_size: size_t,
  restricted_instrs: *const LLVMValueRef,
  restricted_size: size_t,
  run_egg: bool,
  print_opt: bool,
) -> () {
  unsafe {
    // preprocessing of instructions
    let chunk_llvm_instrs = from_raw_parts(chunk_instrs, chunk_size);
    let restricted_llvm_instrs = from_raw_parts(restricted_instrs, restricted_size);

    // llvm to egg
    let (egg_expr, llvm2egg_metadata) =
      llvm_to_egg_main(chunk_llvm_instrs, restricted_llvm_instrs, run_egg);

    // Bail if no egg Nodes to optimize
    if egg_expr.as_ref().is_empty() {
      eprintln!("No Egg Nodes in Optimization Vector");
      return;
    }

    // optimization pass
    if print_opt {
      eprintln!("{}", egg_expr.pretty(10));
    }
    let mut best_egg_expr = egg_expr.clone();
    if run_egg {
      let pair = rules::run(&egg_expr, 180, true, !run_egg);
      best_egg_expr = pair.1;
    }
    if print_opt {
      eprintln!("{}", best_egg_expr.pretty(10));
    }

    // egg to llvm
    egg_to_llvm_main(
      best_egg_expr,
      &llvm2egg_metadata,
      module,
      context,
      builder,
      run_egg,
    );
  }
}

// ------------ NEW CONVERSION FROM LLVM IR TO EGG EXPRESSIONS -------

enum LLVMOpType {
  Argument,
  Constant,
  FNeg,
  FAdd,
  FSub,
  FMul,
  FDiv,
  Sqrt32,
  // TODO: SGN signum
  UnhandledLLVMOpCode,
}

unsafe fn get_pow2(n: u32) -> u32 {
  let mut pow = 1;
  while pow < n {
    pow *= 2;
  }
  return pow;
}

fn is_pow2(n: u32) -> bool {
  if n == 1 {
    return true;
  } else if n % 2 == 1 {
    return false;
  }
  return is_pow2(n / 2);
}

/// New Pad Vector should round the number of elements up to a power of 2, and then recursive
/// divide each into the lane width. Assumes lane width is also a power of 2 in size.
/// Raises assertion error if width is not a power of 2
/// If the vector has less than the width, we do not pad, and just append that vector to enodevect
unsafe fn balanced_pad_vector<'a>(
  binop_vec: &mut Vec<Id>,
  enode_vec: &'a mut Vec<VecLang>,
) -> &'a mut Vec<VecLang> {
  let width = config::vector_width();
  assert!(is_pow2(width as u32));
  let length = binop_vec.len();
  assert!(
    length > 0,
    "There must be 1 or more operators to vectorize."
  );
  // Check vector less than width, and then return
  if length < width {
    enode_vec.push(VecLang::Vec(binop_vec.clone().into_boxed_slice()));
    return enode_vec;
  }
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

/// Recursively concatenate vectors together
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

unsafe fn _llvm_print(inst: LLVMValueRef) -> () {
  LLVMDumpValue(inst);
  println!();
}

unsafe fn _llvm_recursive_print(inst: LLVMValueRef) -> () {
  if isa_argument(inst) {
    return LLVMDumpValue(inst);
  } else if isa_constant(inst) {
    return LLVMDumpValue(inst);
  }
  let num_ops = LLVMGetNumOperands(inst);
  for i in 0..num_ops {
    let operand = LLVMGetOperand(inst, i as u32);
    _llvm_recursive_print(operand);
    print!(" ");
  }
  println!();
  LLVMDumpValue(inst);
  println!();
  return;
}

unsafe fn isa_fadd(llvm_instr: LLVMValueRef) -> bool {
  match LLVMGetInstructionOpcode(llvm_instr) {
    LLVMFAdd => true,
    _ => false,
  }
}

unsafe fn isa_fsub(llvm_instr: LLVMValueRef) -> bool {
  match LLVMGetInstructionOpcode(llvm_instr) {
    LLVMFSub => true,
    _ => false,
  }
}

unsafe fn isa_fmul(llvm_instr: LLVMValueRef) -> bool {
  match LLVMGetInstructionOpcode(llvm_instr) {
    LLVMFMul => true,
    _ => false,
  }
}

unsafe fn isa_fdiv(llvm_instr: LLVMValueRef) -> bool {
  match LLVMGetInstructionOpcode(llvm_instr) {
    LLVMFDiv => true,
    _ => false,
  }
}

unsafe fn isa_fneg(llvm_instr: LLVMValueRef) -> bool {
  match LLVMGetInstructionOpcode(llvm_instr) {
    LLVMFNeg => true,
    _ => false,
  }
}

unsafe fn isa_supported_binop(llvm_instr: LLVMValueRef) -> bool {
  return isa_fadd(llvm_instr)
    || isa_fmul(llvm_instr)
    || isa_fdiv(llvm_instr)
    || isa_fsub(llvm_instr);
}

unsafe fn isa_supported_unop(llvm_instr: LLVMValueRef) -> bool {
  return isa_fneg(llvm_instr);
}

unsafe fn match_llvm_op(llvm_instr: &LLVMValueRef) -> LLVMOpType {
  if isa_argument(*llvm_instr) {
    return LLVMOpType::Argument;
  } else if isa_fadd(*llvm_instr) {
    return LLVMOpType::FAdd;
  } else if isa_fsub(*llvm_instr) {
    return LLVMOpType::FSub;
  } else if isa_fmul(*llvm_instr) {
    return LLVMOpType::FMul;
  } else if isa_fdiv(*llvm_instr) {
    return LLVMOpType::FDiv;
  } else if isa_fneg(*llvm_instr) {
    return LLVMOpType::FNeg;
  } else if isa_constant(*llvm_instr) {
    return LLVMOpType::Constant;
  } else if isa_sqrt32(*llvm_instr) {
    return LLVMOpType::Sqrt32;
  } else {
    return LLVMOpType::UnhandledLLVMOpCode;
  }
}

unsafe fn choose_unop(unop: &LLVMValueRef, id: Id) -> VecLang {
  match LLVMGetInstructionOpcode(*unop) {
    LLVMFNeg => VecLang::Neg([id]),
    _ => panic!("Choose_Unop: Opcode Match Error"),
  }
}

/// LLVM2EggState Contains Egg to LLVM Translation Metadata
#[derive(Debug, Clone)]
struct LLVM2EggState {
  llvm2reg: BTreeMap<LLVMValueRef, VecLang>,
  llvm2arg: BTreeMap<LLVMValueRef, VecLang>,
  instructions_in_chunk: BTreeSet<LLVMValueRef>,
  restricted_instructions: BTreeSet<LLVMValueRef>,
  prior_translated_instructions: BTreeSet<LLVMValueRef>,
  start_instructions: Vec<LLVMValueRef>,
  start_ids: Vec<Id>,
}

/// Translates LLVM Arg to an Egg Argument Node
unsafe fn arg_to_egg(
  llvm_instr: LLVMValueRef,
  mut egg_nodes: Vec<VecLang>,
  next_node_idx: u32,
  translation_metadata: &mut LLVM2EggState,
) -> (Vec<VecLang>, u32) {
  assert!(isa_argument(llvm_instr));
  let argument_idx = gen_arg_idx();
  let argument_node = VecLang::Arg(argument_idx);
  egg_nodes.push(argument_node.clone());
  assert!(!translation_metadata.llvm2arg.contains_key(&llvm_instr));
  translation_metadata
    .llvm2arg
    .insert(llvm_instr, argument_node);
  return (egg_nodes, next_node_idx + 1);
}

/// Translates Supported Binop Instruction to an Egg Bunary Operator Node
///
/// Supported Binary Operators are: FAdd, FSub, FMul, FDiv
unsafe fn bop_to_egg(
  llvm_instr: LLVMValueRef,
  egg_nodes: Vec<VecLang>,
  next_node_idx: u32,
  translation_metadata: &mut LLVM2EggState,
) -> (Vec<VecLang>, u32) {
  assert!(isa_supported_binop(llvm_instr));
  let left = LLVMGetOperand(llvm_instr, 0);
  let right = LLVMGetOperand(llvm_instr, 1);
  let (left_egg_nodes, left_next_idx) =
    llvm_to_egg(left, egg_nodes, next_node_idx, translation_metadata);
  let (mut right_egg_nodes, right_next_idx) =
    llvm_to_egg(right, left_egg_nodes, left_next_idx, translation_metadata);
  let ids = [
    Id::from((left_next_idx - 1) as usize),
    Id::from((right_next_idx - 1) as usize),
  ];
  right_egg_nodes.push(choose_binop(&llvm_instr, ids));
  (right_egg_nodes, right_next_idx + 1)
}

/// Translates Supported Unop Instruction to an Egg Unary Operator Node
///
/// Supported Unary Operators are: FNeg
unsafe fn unop_to_egg(
  llvm_instr: LLVMValueRef,
  egg_nodes: Vec<VecLang>,
  next_node_idx: u32,
  translation_metadata: &mut LLVM2EggState,
) -> (Vec<VecLang>, u32) {
  assert!(isa_supported_unop(llvm_instr));
  let neg_expr = LLVMGetOperand(llvm_instr, 0);
  let (mut new_egg_nodes, new_next_idx) =
    llvm_to_egg(neg_expr, egg_nodes, next_node_idx, translation_metadata);
  let id = Id::from((new_next_idx - 1) as usize);
  new_egg_nodes.push(choose_unop(&llvm_instr, id));
  (new_egg_nodes, new_next_idx + 1)
}

/// Translates Const Instruction to an Egg Number Node
unsafe fn const_to_egg(
  llvm_instr: LLVMValueRef,
  mut egg_nodes: Vec<VecLang>,
  next_node_idx: u32,
  _translation_metadata: &mut LLVM2EggState,
) -> (Vec<VecLang>, u32) {
  assert!(isa_constant(llvm_instr));
  let value = get_constant_float(llvm_instr);
  egg_nodes.push(VecLang::Num(value as i32));
  (egg_nodes, next_node_idx + 1)
}

/// Translates Sqrt 32 Instruction to an Egg Square Root Node
unsafe fn sqrt32_to_egg(
  llvm_instr: LLVMValueRef,
  egg_nodes: Vec<VecLang>,
  next_node_idx: u32,
  translation_metadata: &mut LLVM2EggState,
) -> (Vec<VecLang>, u32) {
  assert!(isa_sqrt32(llvm_instr));
  let sqrt_operand = LLVMGetOperand(llvm_instr, 0);
  let (mut new_enode_vec, new_next_node_idx) =
    llvm_to_egg(sqrt_operand, egg_nodes, next_node_idx, translation_metadata);
  let sqrt_node = VecLang::Sqrt([Id::from((new_next_node_idx - 1) as usize)]);
  new_enode_vec.push(sqrt_node);
  (new_enode_vec, new_next_node_idx + 1)
}

/// Translates an Unhandled OpCode to an Egg Register.
///
/// This represents a blackbox computation that we bail on translating
/// Assumes that the OpCode is actually a computation. If not, translation fails.
unsafe fn unhandled_opcode_to_egg(
  llvm_instr: LLVMValueRef,
  mut egg_nodes: Vec<VecLang>,
  next_node_idx: u32,
  translation_metadata: &mut LLVM2EggState,
) -> (Vec<VecLang>, u32) {
  let register_idx = gen_reg_idx();
  let register_node = VecLang::Reg(register_idx);
  egg_nodes.push(register_node.clone());
  assert!(!translation_metadata.llvm2reg.contains_key(&llvm_instr));
  translation_metadata
    .llvm2reg
    .insert(llvm_instr, register_node);
  (egg_nodes, next_node_idx + 1)
}

/// Recursively Translate LLVM Instruction to Egg Nodes.
///
/// TODO: Take care of chunk boundaries: translation should never overreach a chunk
/// TODO: May need to keep track of llvm instructions across chunks
unsafe fn llvm_to_egg(
  llvm_instr: LLVMValueRef,
  mut egg_nodes: Vec<VecLang>,
  next_node_idx: u32,
  translation_metadata: &mut LLVM2EggState,
) -> (Vec<VecLang>, u32) {
  // Mark instruction as translated, as it will be after it goes through the code below
  if !translation_metadata.prior_translated_instructions.contains(&llvm_instr) {
    translation_metadata.prior_translated_instructions.insert(llvm_instr);
  } 
  // If, on a different pass, the instruction was translated already, then
  // just used the egg node representing the translation
  if translation_metadata.llvm2reg.contains_key(&llvm_instr) {
    let translated_egg_node = translation_metadata
      .llvm2reg
      .get(&llvm_instr)
      .expect("Key must exist");
    egg_nodes.push(translated_egg_node.clone());
    return (egg_nodes, next_node_idx + 1);
  }
  // If the current llvm instruction is a "restricted" instruction, do not translate, but make it a register
  if translation_metadata
    .restricted_instructions
    .contains(&llvm_instr)
  {
    return unhandled_opcode_to_egg(llvm_instr, egg_nodes, next_node_idx, translation_metadata);
  }
  // If the current llvm instruction is not in the current chunk, we must return a register
  // The current llvm instruction must not be a arguments, because arguments will be outside every chunk
  if !translation_metadata
    .instructions_in_chunk
    .contains(&llvm_instr)
    && !isa_argument(llvm_instr)
  {
    return unhandled_opcode_to_egg(llvm_instr, egg_nodes, next_node_idx, translation_metadata);
  }
  // Recurse Backwards on the current instruction, translating its children,
  // based on the opcode of the parent.
  return match match_llvm_op(&llvm_instr) {
    LLVMOpType::FAdd | LLVMOpType::FSub | LLVMOpType::FMul | LLVMOpType::FDiv => {
      bop_to_egg(llvm_instr, egg_nodes, next_node_idx, translation_metadata)
    }
    LLVMOpType::FNeg => unop_to_egg(llvm_instr, egg_nodes, next_node_idx, translation_metadata),
    LLVMOpType::Constant => {
      const_to_egg(llvm_instr, egg_nodes, next_node_idx, translation_metadata)
    }
    LLVMOpType::Argument => arg_to_egg(llvm_instr, egg_nodes, next_node_idx, translation_metadata),
    LLVMOpType::Sqrt32 => sqrt32_to_egg(llvm_instr, egg_nodes, next_node_idx, translation_metadata),
    LLVMOpType::UnhandledLLVMOpCode => {
      unhandled_opcode_to_egg(llvm_instr, egg_nodes, next_node_idx, translation_metadata)
    }
  };
}

unsafe fn start_translating_llvm_to_egg(
  llvm_instr: LLVMValueRef,
  egg_nodes: Vec<VecLang>,
  next_node_idx: u32,
  translation_metadata: &mut LLVM2EggState,
) -> (Vec<VecLang>, u32) {
  translation_metadata.start_instructions.push(llvm_instr);
  let pair_result = llvm_to_egg(llvm_instr, egg_nodes, next_node_idx, translation_metadata);
  translation_metadata
    .start_ids
    .push(Id::from((pair_result.1 - 1) as usize));
  pair_result
}

unsafe fn can_start_translation_instr(llvm_instr: LLVMValueRef) -> bool {
  return match match_llvm_op(&llvm_instr) {
    LLVMOpType::FAdd
    | LLVMOpType::FMul
    | LLVMOpType::FDiv
    | LLVMOpType::FSub
    | LLVMOpType::FNeg
    | LLVMOpType::Constant
    | LLVMOpType::Sqrt32 => true,
    LLVMOpType::Argument | LLVMOpType::UnhandledLLVMOpCode => false,
  };
}

unsafe fn llvm_to_egg_main(
  llvm_instrs_in_chunk: &[LLVMValueRef],
  restricted_instrs: &[LLVMValueRef],
  vectorize: bool,
  // TODO: feed this in as an argument llvm_instr2egg_node: BTreeMap<LLVMValueRef, VecLang>,
) -> (RecExpr<VecLang>, LLVM2EggState) {
  let mut egg_nodes: Vec<VecLang> = Vec::new();

  // Map from (translated / opaque) llvm instructions to register egg graph nodes
  let llvm_instr2reg_node: BTreeMap<LLVMValueRef, VecLang> = BTreeMap::new();
  // Map from (translated) llvm instructions to argument egg graph nodes
  let llvm_instr2arg_node: BTreeMap<LLVMValueRef, VecLang> = BTreeMap::new();

  // Ordered Vector of Starting LLVM instructions where translation began
  let start_instructions: Vec<LLVMValueRef> = Vec::new();

  // Ordered Set of Instructions in Chunk
  let mut instructions_in_chunk: BTreeSet<LLVMValueRef> = BTreeSet::new();
  for llvm_instr in llvm_instrs_in_chunk.iter() {
    instructions_in_chunk.insert(*llvm_instr);
  }

  // Ordered Set of Ids
  let start_ids: Vec<Id> = Vec::new();

  // Ordered Set of Instructions NOT TO BE Translated, except as registers
  let mut restricted_instrs_set: BTreeSet<LLVMValueRef> = BTreeSet::new();
  for llvm_instr in restricted_instrs.iter() {
    restricted_instrs_set.insert(*llvm_instr);
  }

  // Invariant: every restricted instruction is in the chunk, using a pointer check
  for restr_instr in restricted_instrs.iter() {
    let mut found_match = false;
    for instr in instructions_in_chunk.iter() {
      if cmp_val_ref_address(&**restr_instr, &**instr) {
        found_match = true;
        break;
      }
    }
    if found_match {
      continue;
    }
  }
  // Invariant: chunk instructions are not empty in size
  assert!(!instructions_in_chunk.is_empty());

  let mut prior_translated_instructions: BTreeSet<LLVMValueRef> = BTreeSet::new();

  // State Variable To Hold Maps During Translation
  let mut translation_metadata = LLVM2EggState {
    llvm2reg: llvm_instr2reg_node,
    llvm2arg: llvm_instr2arg_node,
    instructions_in_chunk: instructions_in_chunk,
    restricted_instructions: restricted_instrs_set,
    prior_translated_instructions: prior_translated_instructions,
    start_instructions: start_instructions,
    start_ids: start_ids,
  };

  // Index of next node to translate
  let mut next_node_idx: u32 = 0;

  // for each final instruction, iterate backwards from that final instruction and translate to egg
  for llvm_instr in llvm_instrs_in_chunk.iter().rev() {
    // only start translation back if it is a "translatable instruction" and it was not translated already
    if can_start_translation_instr(*llvm_instr) && !translation_metadata.prior_translated_instructions.contains(&llvm_instr) {
      let (new_egg_nodes, new_next_node_idx) = start_translating_llvm_to_egg(
        *llvm_instr,
        egg_nodes,
        next_node_idx,
        &mut translation_metadata,
      );
      egg_nodes = new_egg_nodes;
      next_node_idx = new_next_node_idx;
    }
  }

  // For testing purposes: Handle no vectorization
  if !vectorize {
    let mut outer_vec_ids = Vec::new();
    for id in translation_metadata.start_ids.iter() {
      outer_vec_ids.push(*id);
    }
    egg_nodes.push(VecLang::NoOptVec(outer_vec_ids.clone().into_boxed_slice()));
    let rec_expr = RecExpr::from(egg_nodes);
    return (rec_expr, translation_metadata);
  }

  // Generate a padded vector
  let mut outer_vec_ids = Vec::new();
  for id in translation_metadata.start_ids.iter() {
    outer_vec_ids.push(*id);
  }
  balanced_pad_vector(&mut outer_vec_ids, &mut egg_nodes);

  let rec_expr = RecExpr::from(egg_nodes);

  return (rec_expr, translation_metadata);
}

/// Egg2LLVMState represent the state needed to translate from Egg to LLVM
struct Egg2LLVMState<'a> {
  llvm2egg_metadata: LLVM2EggState,
  egg_nodes_vector: &'a [VecLang],
  prior_translated_nodes: BTreeSet<LLVMValueRef>,
  builder: LLVMBuilderRef,
  context: LLVMContextRef,
  module: LLVMModuleRef,
}

unsafe fn arg_to_llvm(egg_node: &VecLang, translation_metadata: &mut Egg2LLVMState) -> LLVMValueRef {
  // TODO: Make More Efficient with BTREEMAP?
  let llvm2arg = &translation_metadata.llvm2egg_metadata.llvm2arg;
  for (llvm_instr, arg_node) in llvm2arg.iter() {
    // We can do a struct comparison rather than point comparison as arg node contents are indexed by a unique u32.
    if arg_node == egg_node {
      assert!(isa_argument(*llvm_instr));
      return *llvm_instr;
    }
  }
  panic!(
    "Expected a successful lookup in llvm2arg, but cannot find Argument Egg Node: {:?}.",
    egg_node
  );
}

unsafe fn reg_to_llvm(egg_node: &VecLang, translation_metadata: &mut Egg2LLVMState) -> LLVMValueRef {
  // TODO: Make More Efficient with BTREEMAP?
  let llvm2reg = &translation_metadata.llvm2egg_metadata.llvm2reg;
  for (llvm_instr, reg_node) in llvm2reg.iter() {
    // We can do a struct comparison rather than point comparison as arg node contents are indexed by a unique u32.
    if reg_node == egg_node {
      assert!(!isa_argument(*llvm_instr));
      // do not clone an instruction translated earlier in the same chunk
      if translation_metadata.prior_translated_nodes.contains(&*llvm_instr) {
        return *llvm_instr;
      }
      // do not clone an instruction translated in a prior basic block / prior chunk
      if !translation_metadata.llvm2egg_metadata.instructions_in_chunk.contains(&*llvm_instr) {
        return *llvm_instr;
      }
      let new_instr = LLVMInstructionClone(*llvm_instr);
      LLVMInsertIntoBuilder(translation_metadata.builder, new_instr);
      translation_metadata.prior_translated_nodes.insert(new_instr);
      return new_instr;
    }
  }
  panic!(
    "Expected a successful lookup in llvm2reg, but cannot find Register Egg Node: {:?}.",
    egg_node
  );
}

unsafe fn num_to_llvm(n: &i32, md: &mut Egg2LLVMState) -> LLVMValueRef {
  LLVMConstReal(LLVMFloatTypeInContext(md.context), *n as f64)
}

unsafe fn vec_to_llvm(boxed_ids: &Box<[Id]>, md: &mut Egg2LLVMState) -> LLVMValueRef {
  // Convert the Boxed Ids to a Vector, and generate a vector of zeros
  // Invariant: idvec must not be empty
  let idvec = boxed_ids.to_vec();
  let idvec_len = idvec.len();
  assert!(
    !idvec.is_empty(),
    "Id Vec Cannot be empty when converting Vector to an LLVM Vector"
  );
  let mut zeros = Vec::new();
  for _ in 0..idvec_len {
    zeros.push(LLVMConstReal(LLVMFloatTypeInContext(md.context), 0 as f64));
  }

  // Convert the Vector of Zeros to a Mut PTr to construct an LLVM Zero Vector
  // Invariant: zeros must not be empty
  assert!(
    !zeros.is_empty(),
    "Zeros Vector Cannot be empty when converting Vector to an LLVM Vector"
  );
  let zeros_ptr = zeros.as_mut_ptr();
  let mut vector = LLVMConstVector(zeros_ptr, idvec.len() as u32);
  for (idx, &eggid) in idvec.iter().enumerate() {
    let elt = &md.egg_nodes_vector[usize::from(eggid)];
    let mut elt_val = egg_to_llvm(elt, md);
    // TODO: Can We Eliminate this BitCast in the future??
    // With the new formulation, will we ever have an integer type?
    // Check if the elt is an int
    if isa_integertype(elt_val) {
      elt_val = LLVMBuildBitCast(
        md.builder,
        elt_val,
        LLVMFloatTypeInContext(md.context),
        b"\0".as_ptr() as *const _,
      );
    }

    // Construct the Vector
    vector = LLVMBuildInsertElement(
      md.builder,
      vector,
      elt_val,
      LLVMConstInt(LLVMIntTypeInContext(md.context, 32), idx as u64, 0),
      b"\0".as_ptr() as *const _,
    );
  }
  vector
}

// TODO: Segregate Vec and Scalar Binops?
unsafe fn binop_to_llvm(
  binop_node: &VecLang,
  left_id: &Id,
  right_id: &Id,
  md: &mut Egg2LLVMState,
) -> LLVMValueRef {
  let left = egg_to_llvm(&md.egg_nodes_vector[usize::from(*left_id)], md);
  let right = egg_to_llvm(&md.egg_nodes_vector[usize::from(*right_id)], md);

  // TODO: Can We Remove these Casts?
  let left = if LLVMTypeOf(left) == LLVMIntTypeInContext(md.context, 32) {
    LLVMBuildBitCast(
      md.builder,
      left,
      LLVMFloatTypeInContext(md.context),
      b"\0".as_ptr() as *const _,
    )
  } else {
    left
  };

  // TODO: Can We Remove these Casts?
  let right = if LLVMTypeOf(right) == LLVMIntTypeInContext(md.context, 32) {
    LLVMBuildBitCast(
      md.builder,
      right,
      LLVMFloatTypeInContext(md.context),
      b"\0".as_ptr() as *const _,
    )
  } else {
    right
  };

  // TODO: Can we eliminate these cases?
  if isa_constfp(left)
    && !isa_constaggregatezero(left)
    && isa_constfp(right)
    && !isa_constaggregatezero(right)
  {
    let mut loses_info = 1;
    let nright = LLVMConstRealGetDouble(right, &mut loses_info);
    let new_right = build_constant_float(nright, md.context);
    let nleft = LLVMConstRealGetDouble(left, &mut loses_info);
    let new_left = build_constant_float(nleft, md.context);
    translate_binop(
      binop_node,
      new_left,
      new_right,
      md.builder,
      b"\0".as_ptr() as *const _,
    )
  } else if isa_constfp(right) && !isa_constaggregatezero(right) {
    let mut loses_info = 1;
    let n = LLVMConstRealGetDouble(right, &mut loses_info);
    let new_right = build_constant_float(n, md.context);
    translate_binop(
      binop_node,
      left,
      new_right,
      md.builder,
      b"\0".as_ptr() as *const _,
    )
  } else if isa_constfp(left) && !isa_constaggregatezero(left) {
    let mut loses_info = 1;
    let n = LLVMConstRealGetDouble(left, &mut loses_info);
    let new_left = build_constant_float(n, md.context);
    translate_binop(
      binop_node,
      new_left,
      right,
      md.builder,
      b"\0".as_ptr() as *const _,
    )
  } else {
    translate_binop(
      binop_node,
      left,
      right,
      md.builder,
      b"\0".as_ptr() as *const _,
    )
  }
}

unsafe fn concat_to_llvm(left_vector: &Id, right_vector: &Id, md: &mut Egg2LLVMState) -> LLVMValueRef {
  {
    let trans_v1 = egg_to_llvm(&md.egg_nodes_vector[usize::from(*left_vector)], md);
    let mut trans_v2 = egg_to_llvm(&md.egg_nodes_vector[usize::from(*right_vector)], md);

    // In LLVM, it turns out all vectors need to be length power of 2
    // if the 2 vectors are not the same size, double the length of the smaller vector by padding with 0's in it
    // manually concatenate 2 vectors by using a LLVM shuffle operation.
    let v1_type = LLVMTypeOf(trans_v1);
    let v1_size = LLVMGetVectorSize(v1_type);
    let v2_type = LLVMTypeOf(trans_v2);
    let v2_size = LLVMGetVectorSize(v2_type);

    // TODO: HACKY FIX FOR NOW
    // assume both v1 and v2 are pow of 2 size
    // assume v2 size smaller or equal to v1 size
    // assume v2 is 1/2 size of v1
    if v1_size != v2_size {
      // replicate v2 size
      let mut zeros = Vec::new();
      for _ in 0..v2_size {
        zeros.push(LLVMConstReal(LLVMFloatTypeInContext(md.context), 0 as f64));
      }
      let zeros_ptr = zeros.as_mut_ptr();
      let zeros_vector = LLVMConstVector(zeros_ptr, v2_size);
      let size = 2 * v2_size;
      let mut indices = Vec::new();
      for i in 0..size {
        indices.push(LLVMConstInt(
          LLVMIntTypeInContext(md.context, 32),
          i as u64,
          0,
        ));
      }
      let mask = indices.as_mut_ptr();
      let mask_vector = LLVMConstVector(mask, size);
      trans_v2 = LLVMBuildShuffleVector(
        md.builder,
        trans_v2,
        zeros_vector,
        mask_vector,
        b"\0".as_ptr() as *const _,
      );
    }

    let size = v1_size + v2_size;
    let mut indices = Vec::new();
    for i in 0..size {
      indices.push(LLVMConstInt(
        LLVMIntTypeInContext(md.context, 32),
        i as u64,
        0,
      ));
    }

    let mask = indices.as_mut_ptr();
    let mask_vector = LLVMConstVector(mask, size);
    LLVMBuildShuffleVector(
      md.builder,
      trans_v1,
      trans_v2,
      mask_vector,
      b"\0".as_ptr() as *const _,
    )
  }
}

unsafe fn mac_to_llvm(
  accumulator_vector: &Id,
  left_prod_vector: &Id,
  right_prod_vector: &Id,
  md: &mut Egg2LLVMState,
) -> LLVMValueRef {
  let trans_acc = egg_to_llvm(&md.egg_nodes_vector[usize::from(*accumulator_vector)], md);
  let trans_v1 = egg_to_llvm(&md.egg_nodes_vector[usize::from(*left_prod_vector)], md);
  let trans_v2 = egg_to_llvm(&md.egg_nodes_vector[usize::from(*right_prod_vector)], md);
  let vec_type = LLVMTypeOf(trans_acc);
  let param_types = [vec_type, vec_type, vec_type].as_mut_ptr();
  let fn_type = LLVMFunctionType(vec_type, param_types, 3, 0 as i32);
  let func = LLVMAddFunction(md.module, b"llvm.fma.f32\0".as_ptr() as *const _, fn_type);
  let args = [trans_v1, trans_v2, trans_acc].as_mut_ptr();
  LLVMBuildCall(md.builder, func, args, 3, b"\0".as_ptr() as *const _)
}

unsafe fn scalar_unop_to_llvm(n: &Id, unop_node: &VecLang, md: &mut Egg2LLVMState) -> LLVMValueRef {
  let mut number = egg_to_llvm(&md.egg_nodes_vector[usize::from(*n)], md);
  if isa_integertype(number) {
    number = LLVMBuildBitCast(
      md.builder,
      number,
      LLVMFloatTypeInContext(md.context),
      b"\0".as_ptr() as *const _,
    );
  }
  translate_unop(
    unop_node,
    number,
    md.builder,
    md.context,
    md.module,
    b"\0".as_ptr() as *const _,
  )
}

unsafe fn vecneg_to_llvm(vec: &Id, md: &mut Egg2LLVMState) -> LLVMValueRef {
  let neg_vector = egg_to_llvm(&md.egg_nodes_vector[usize::from(*vec)], md);
  LLVMBuildFNeg(md.builder, neg_vector, b"\0".as_ptr() as *const _)
}

unsafe fn vecsqrt_to_llvm(vec: &Id, md: &mut Egg2LLVMState) -> LLVMValueRef {
  let sqrt_vec = egg_to_llvm(&md.egg_nodes_vector[usize::from(*vec)], md);
  let vec_type = LLVMTypeOf(sqrt_vec);
  let param_types = [vec_type].as_mut_ptr();
  let fn_type = LLVMFunctionType(vec_type, param_types, 1, 0 as i32);
  let func = LLVMAddFunction(md.module, b"llvm.sqrt.f32\0".as_ptr() as *const _, fn_type);
  let args = [sqrt_vec].as_mut_ptr();
  LLVMBuildCall(md.builder, func, args, 1, b"\0".as_ptr() as *const _)
}

unsafe fn vecsgn_to_llvm(vec: &Id, md: &mut Egg2LLVMState) -> LLVMValueRef {
  let sgn_vec = egg_to_llvm(&md.egg_nodes_vector[usize::from(*vec)], md);
  let vec_type = LLVMTypeOf(sgn_vec);
  let vec_size = LLVMGetVectorSize(vec_type);
  let mut ones = Vec::new();
  for _ in 0..vec_size {
    ones.push(LLVMConstReal(LLVMFloatTypeInContext(md.context), 1 as f64));
  }
  let ones_ptr = ones.as_mut_ptr();
  let ones_vector = LLVMConstVector(ones_ptr, vec_size);
  let param_types = [vec_type, vec_type].as_mut_ptr();
  let fn_type = LLVMFunctionType(vec_type, param_types, 2, 0 as i32);
  let func = LLVMAddFunction(
    md.module,
    b"llvm.copysign.f32\0".as_ptr() as *const _,
    fn_type,
  );
  let args = [ones_vector, sgn_vec].as_mut_ptr();
  LLVMBuildCall(md.builder, func, args, 2, b"\0".as_ptr() as *const _)
}

/**
 * Vector representing No Optimization: Egg will not have modified the vector at all.
 */
unsafe fn nooptvec_to_llvm(boxed_ids: &Box<[Id]>, md: &mut Egg2LLVMState) -> () {
  // Convert the Boxed Ids to a Vector, and generate a vector of zeros
  // Invariant: idvec must not be empty
  let idvec = boxed_ids.to_vec();
  assert!(
    !idvec.is_empty(),
    "Id Vec Cannot be empty when converting Vector to an LLVM Vector"
  );
  for (i, &eggid) in idvec.iter().enumerate() {
    let egg_node = &md.egg_nodes_vector[usize::from(eggid)];
    let new_instr = egg_to_llvm(egg_node, md);
    let old_instr = md
      .llvm2egg_metadata
      .start_instructions
      .get(i)
      .expect("Index Must Exist In Start Instructions");
    LLVMReplaceAllUsesWith(*old_instr, new_instr);
    LLVMInstructionRemoveFromParent(*old_instr);
  }
}

/// Egg To LLVM Dispatches translation of VecLanf Egg Nodes to LLVMValueRegs
///
/// Side Effect: Builds and Insert LLVM instructions
unsafe fn egg_to_llvm(egg_node: &VecLang, translation_metadata: &mut Egg2LLVMState) -> LLVMValueRef {
  match egg_node {
    VecLang::NoOptVec(..) => panic!("No Opt Vector was found. Egg to LLVM Translation does not handle No Opt Vector nodes at this location."),
    VecLang::Symbol(..) => {
      panic!("Symbol was found. Egg to LLVM Translation does not handle symbol nodes.")
    }
    VecLang::Get(..) => {
      panic!("Get was found. Egg to LLVM Translation does not handle get nodes.")
    }
    VecLang::Ite(..) => panic!("Ite was found. Egg to LLVM Translation does not handle ite nodes."),
    VecLang::Or(..) => panic!("Or was found. Egg to LLVM Translation does not handle or nodes."),
    VecLang::And(..) => panic!("And was found. Egg to LLVM Translation does not handle and nodes."),
    VecLang::Lt(..) => panic!("Lt was found. Egg to LLVM Translation does not handle lt nodes."),
    VecLang::Sgn(..) => panic!("Sgn was found. Egg to LLVM Translation does not handle sgn nodes. TODO: In the future, tis node will be handled alongside sqrt and neg scalar nodes."),
    VecLang::VecSgn(..) => panic!("VecSgn was found. Egg to LLVM Translation does not handle vecsgn nodes. TODO: In the future, this node will be handled alongside VecSqrt and VecNeg vector nodes."),
    VecLang::Arg(_) =>  arg_to_llvm(egg_node, translation_metadata),
    VecLang::Reg(_) =>  reg_to_llvm(egg_node, translation_metadata),
    VecLang::Num(n) =>  num_to_llvm(n, translation_metadata),
    VecLang::LitVec(boxed_ids) | VecLang::Vec(boxed_ids) | VecLang::List(boxed_ids) => {
       vec_to_llvm(&*boxed_ids, translation_metadata)
    }
    VecLang::VecAdd([l, r])
    | VecLang::VecMinus([l, r])
    | VecLang::VecMul([l, r])
    | VecLang::VecDiv([l, r])
    | VecLang::Add([l, r])
    | VecLang::Minus([l, r])
    | VecLang::Mul([l, r])
    | VecLang::Div([l, r]) =>  binop_to_llvm(egg_node, l, r, translation_metadata),
    VecLang::Concat([v1, v2]) =>  concat_to_llvm(v1, v2, translation_metadata),
    VecLang::VecMAC([acc, v1, v2]) =>  mac_to_llvm(acc, v1, v2, translation_metadata),


    // TODO: VecNeg, VecSqrt, VecSgn all have not been tested, need test cases.
    // TODO: LLVM actually supports many more vector intrinsics, including
    // vector sine/cosine instructions for floats.
    VecLang::VecNeg([v]) =>  vecneg_to_llvm(v, translation_metadata),
    VecLang::VecSqrt([v]) =>  vecsqrt_to_llvm(v, translation_metadata),
    // VecSgn compliant with c++ LibMath copysign function, which differs with sgn at x = 0.
    VecLang::VecSgn([v]) =>  vecsgn_to_llvm(v, translation_metadata),
    VecLang::Sgn([n]) | VecLang::Sqrt([n]) | VecLang::Neg([n]) =>  scalar_unop_to_llvm(n, egg_node, translation_metadata),
  }
}

unsafe fn is_nooptvec(egg_expr: &VecLang) -> bool {
  match egg_expr {
    VecLang::NoOptVec(..) => true,
    _ => false,
  }
}

unsafe fn get_noopt_eggnodes(egg_expr: &VecLang) -> &Box<[Id]> {
  match egg_expr {
    VecLang::NoOptVec(boxed_ids) => boxed_ids,
    _ => panic!("Not a NoOptVec!"),
  }
}

// TODO: Add non-vectorized version as well!
unsafe fn egg_to_llvm_main(
  expr: RecExpr<VecLang>,
  llvm2egg_metadata: &LLVM2EggState,
  module: LLVMModuleRef,
  context: LLVMContextRef,
  builder: LLVMBuilderRef,
  vectorize: bool,
) -> () {
  // Walk the RecExpr of Egg Nodes and translate it in place to LLVM
  let egg_nodes = expr.as_ref();
  let last_egg_node = egg_nodes
    .last()
    .expect("No match for last element of vector of Egg Terms.");

  // Nodes converted to llvm already, not to be retranslated
  let prior_translated_nodes: BTreeSet<LLVMValueRef> = BTreeSet::new();

  let mut translation_metadata = Egg2LLVMState {
    egg_nodes_vector: egg_nodes,
    llvm2egg_metadata: llvm2egg_metadata.clone(),
    prior_translated_nodes: prior_translated_nodes,
    builder: builder,
    context: context,
    module: module,
  };
  // If vectorize was not true, we are finished, because nooptvectorize_to_llvm will generate the required code.
  if !vectorize {
    assert!(is_nooptvec(last_egg_node));
    return nooptvec_to_llvm(get_noopt_eggnodes(last_egg_node), &mut translation_metadata);
  }

  // Regular translation from vectorization

  assert!(!is_nooptvec(last_egg_node));
  let llvm_vector = egg_to_llvm(last_egg_node, &mut translation_metadata);

  // BELOW HERE, we allow for vectorization output, and we stitch our work back into the current LLVM code

  // NOTE: We Assume Egg rewriter will maintain relative positions of elements in vector
  // Extract the elements of the vector, to be assigned back to where they are to be used.
  let num_extractions = llvm2egg_metadata.start_instructions.len();
  for i in (0..num_extractions).rev() {
    let old_instr = llvm2egg_metadata
      .start_instructions
      .get(i)
      .expect("Index should be in vector.");
    // Build the extracted value
    let index = LLVMConstInt(LLVMIntTypeInContext(context, 32), i as u64, 0);
    let extracted_value =
      LLVMBuildExtractElement(builder, llvm_vector, index, b"\0".as_ptr() as *const _);
    // Replace all the uses of the old instruction with the new extracted value
    // Old instruction cannot have been removed.
    LLVMReplaceAllUsesWith(*old_instr, extracted_value);
    LLVMInstructionRemoveFromParent(*old_instr);
  }
}
