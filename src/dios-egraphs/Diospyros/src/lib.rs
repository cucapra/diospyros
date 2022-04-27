extern crate llvm_sys as llvm;
use dioslib::{config, rules, veclang::VecLang};
use egg::*;
use libc::size_t;
use llvm::{core::*, prelude::*, LLVMOpcode::*, LLVMRealPredicate};
use std::{
  cmp,
  collections::{BTreeMap, BTreeSet},
  mem,
  os::raw::c_char,
  slice::from_raw_parts,
};

extern "C" {
  fn llvm_index(val: LLVMValueRef, index: i32) -> i32;
  fn llvm_name(val: LLVMValueRef) -> *const c_char;
  fn isa_unop(val: LLVMValueRef) -> bool;
  fn isa_bop(val: LLVMValueRef) -> bool;
  fn isa_constant(val: LLVMValueRef) -> bool;
  fn isa_constfp(val: LLVMValueRef) -> bool;
  fn isa_gep(val: LLVMValueRef) -> bool;
  fn isa_load(val: LLVMValueRef) -> bool;
  fn isa_store(val: LLVMValueRef) -> bool;
  fn isa_argument(val: LLVMValueRef) -> bool;
  fn isa_call(val: LLVMValueRef) -> bool;
  fn isa_fptrunc(val: LLVMValueRef) -> bool;
  fn isa_fpext(val: LLVMValueRef) -> bool;
  fn isa_alloca(val: LLVMValueRef) -> bool;
  fn isa_phi(val: LLVMValueRef) -> bool;
  fn _isa_sextint(val: LLVMValueRef) -> bool;
  fn isa_sitofp(val: LLVMValueRef) -> bool;
  fn isa_constaggregatezero(val: LLVMValueRef) -> bool;
  fn _isa_constaggregate(val: LLVMValueRef) -> bool;
  fn isa_integertype(val: LLVMValueRef) -> bool;
  fn _isa_intptr(val: LLVMValueRef) -> bool;
  fn isa_floatptr(val: LLVMValueRef) -> bool;
  fn _isa_floattype(val: LLVMValueRef) -> bool;
  fn isa_bitcast(val: LLVMValueRef) -> bool;
  fn isa_sqrt32(val: LLVMValueRef) -> bool;
  fn isa_sqrt64(val: LLVMValueRef) -> bool;
  fn get_constant_float(val: LLVMValueRef) -> f32;
  fn build_constant_float(n: f64, context: LLVMContextRef) -> LLVMValueRef;
}

// Note: We use BTreeMaps to enforce ordering in the map
// Without ordering, tests become flaky and start failing a lot more often
// We do not use HashMaps for this reason as ordering is not enforced.
// GEPMap : Maps the array name and array offset as symbols to the GEP
// LLVM Value Ref that LLVM Generated
type GEPMap = BTreeMap<(Symbol, Symbol), LLVMValueRef>;
type LLVMPairMap = BTreeMap<LLVMValueRef, LLVMValueRef>;

static mut ARG_IDX: u32 = 0;
static mut CALL_IDX: i32 = 0;
static mut NODE_IDX: u32 = 0;
static mut REG_IDX: u32 = 0;

unsafe fn gen_arg_idx() -> u32 {
  ARG_IDX += 1;
  return ARG_IDX;
}

unsafe fn gen_reg_idx() -> u32 {
  REG_IDX += 1;
  return REG_IDX;
}

unsafe fn gen_node_idx() -> u32 {
  NODE_IDX += 1;
  return NODE_IDX;
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

/// Main function to optimize: Takes in a basic block of instructions,
/// optimizes it, and then translates it to LLVM IR code, in place.

#[repr(C)]
pub struct IntLLVMPair {
  node_int: u32,
  arg: LLVMValueRef,
}

#[repr(C)]
pub struct LLVMPair {
  original_value: LLVMValueRef,
  new_value: LLVMValueRef,
}

#[repr(C)]
pub struct VectorPointerSize {
  llvm_pointer: *const LLVMPair,
  llvm_pointer_size: size_t,
}

#[no_mangle]
pub fn optimize(
  module: LLVMModuleRef,
  context: LLVMContextRef,
  builder: LLVMBuilderRef,
  bb: *const LLVMValueRef,
  size: size_t,
  past_instrs: *const LLVMPair,
  past_size: size_t,
  run_egg: bool,
  print_opt: bool,
) -> VectorPointerSize {
  unsafe {
    // llvm to egg
    let llvm_instrs = from_raw_parts(bb, size);
    let past_llvm_instrs = from_raw_parts(past_instrs, past_size);
    let mut llvm_arg_pairs = BTreeMap::new();
    for instr_pair in past_llvm_instrs {
      let original_value = instr_pair.original_value;
      let new_value = instr_pair.new_value;
      // assert!(isa_load(original_value) || isa_alloca(original_value));
      // assert!(isa_load(new_value) || isa_alloca(new_value));
      llvm_arg_pairs.insert(original_value, new_value);
    }
    let mut node_to_arg = Vec::new();
    let (expr, gep_map, store_map, symbol_map) =
      llvm_to_egg(llvm_instrs, &mut llvm_arg_pairs, &mut node_to_arg);

    // optimization pass
    if print_opt {
      eprintln!("{}", expr.pretty(10));
    }
    let mut best = expr.clone();
    if run_egg {
      let pair = rules::run(&expr, 180, true, !run_egg);
      best = pair.1;
    }
    if print_opt {
      eprintln!("{}", best.pretty(10));
    }

    // egg to llvm
    egg_to_llvm(
      best,
      &gep_map,
      &store_map,
      &symbol_map,
      &mut llvm_arg_pairs, // does this work properly?, IDK? Need to return mut value
      &node_to_arg,
      module,
      context,
      builder,
    );

    let mut final_llvm_arg_pairs = Vec::new();
    for (unchanged_val, new_val) in llvm_arg_pairs.iter() {
      let pair = LLVMPair {
        original_value: *unchanged_val,
        new_value: *new_val,
      };
      // assert!(isa_load(*unchanged_val) || isa_alloca(*unchanged_val));
      // assert!(isa_load(*new_val) || isa_alloca(*new_val));
      final_llvm_arg_pairs.push(pair);
    }

    // https://stackoverflow.com/questions/39224904/how-to-expose-a-rust-vect-to-ffi
    let mut llvm_arg_pairs_boxed_slice: Box<[LLVMPair]> = final_llvm_arg_pairs.into_boxed_slice();
    let llvm_arg_pairs_array: *mut LLVMPair = llvm_arg_pairs_boxed_slice.as_mut_ptr();
    let llvm_arg_pairs_array_len: usize = llvm_arg_pairs_boxed_slice.len();
    mem::forget(llvm_arg_pairs_boxed_slice);

    // TODO: FIX THIS
    return VectorPointerSize {
      llvm_pointer: llvm_arg_pairs_array,
      llvm_pointer_size: llvm_arg_pairs_array_len,
    };
  }
}

// ------------ NEW CONVERSION FROM LLVM IR TO EGG EXPRESSIONS -------

type StoreMap = BTreeMap<i32, LLVMValueRef>;
type IdMap = BTreeSet<Id>;
type SymbolMap = BTreeMap<VecLang, LLVMValueRef>;

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

unsafe fn llvm_recursive_add(
  builder: LLVMBuilderRef,
  inst: LLVMValueRef,
  context: LLVMContextRef,
  llvm_arg_pairs: &mut LLVMPairMap,
) -> LLVMValueRef {
  let cloned_inst = LLVMInstructionClone(inst);
  if isa_argument(inst) {
    return inst;
  }
  let mut matched = false;
  let mut ret_value = inst;
  for (original_val, new_val) in (&*llvm_arg_pairs).iter() {
    if cmp_val_ref_address(&**original_val, &*inst) {
      matched = true;
      ret_value = *new_val;
      break;
    }
  }
  if matched {
    return ret_value;
  }
  if isa_constant(inst) {
    return inst;
  } else if isa_phi(inst) {
    return inst;
  } else if isa_alloca(inst) {
    // We have this in the base case to stop reconstruction of allocas,
    // because allocas are like loads, and should not get reconstructioned
    // search the llvm_arg_pairs for allocas that were already created
    let mut matched = false;
    let mut ret_value = inst;
    for (original_val, new_val) in (&*llvm_arg_pairs).iter() {
      // let original_llvm = llvm_pair.original_value;
      // let new_llvm = llvm_pair.new_value;
      if cmp_val_ref_address(&**original_val, &*inst) {
        matched = true;
        ret_value = *new_val;
        break;
      }
    }
    if matched {
      return ret_value;
    } else {
      // assert!(isa_load(inst) || isa_alloca(inst));
      // assert!(isa_load(cloned_inst) || isa_alloca(cloned_inst));
      llvm_arg_pairs.insert(inst, cloned_inst);
      LLVMInsertIntoBuilder(builder, cloned_inst);
      return cloned_inst;
    }
  }
  let num_ops = LLVMGetNumOperands(inst);
  for i in 0..num_ops {
    let operand = LLVMGetOperand(inst, i as u32);
    let new_operand = llvm_recursive_add(builder, operand, context, llvm_arg_pairs);
    LLVMSetOperand(cloned_inst, i as u32, new_operand);
  }
  LLVMInsertIntoBuilder(builder, cloned_inst);

  let mut in_map = false;
  for (original_inst, _) in (&*llvm_arg_pairs).iter() {
    if cmp_val_ref_address(&**original_inst, &*inst) {
      in_map = true;
    }
  }
  if isa_load(inst) {
    if !in_map {
      // assert!(isa_load(inst) || isa_alloca(inst));
      // assert!(isa_load(cloned_inst) || isa_alloca(cloned_inst));
      llvm_arg_pairs.insert(inst, cloned_inst);
    }
  }
  return cloned_inst;
}

unsafe fn isa_fadd(llvm_instr: LLVMValueRef) -> bool {
  match LLVMGetInstructionOpcode(llvm_instr) {
    LLVMFadd => true,
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
  if isa_fadd(*llvm_instr) {
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
  } else if isa_argument(*llvm_instr) {
    return LLVMOpType::Argument;
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

// ---- Construction Zone -------

/// LLVM2EggState Contains Egg to LLVM Translation Metadata
struct LLVM2EggState<'a, 'b, 'c, 'd, 'e> {
  llvm2reg: &'a BTreeMap<LLVMValueRef, VecLang>,
  llvm2arg: &'b BTreeMap<LLVMValueRef, VecLang>,
  instructions_in_chunk: &'c BTreeSet<LLVMValueRef>,
  restricted_instructions: &'d BTreeSet<LLVMValueRef>,
  start_instructions: Vec<LLVMValueRef>,
  start_ids: &'e BTreeSet<Id>,
}

/// Translates LLVM Arg to an Egg Argument Node
unsafe fn arg_to_egg(
  llvm_instr: LLVMValueRef,
  mut egg_nodes: Vec<VecLang>,
  next_node_idx: u32,
  mut translation_metadata: LLVM2EggState,
) -> (Vec<VecLang>, u32) {
  assert!(isa_argument(llvm_instr));
  let argument_idx = gen_arg_idx();
  let argument_node = VecLang::Arg(argument_idx);
  egg_nodes.push(argument_node);
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
  mut egg_nodes: Vec<VecLang>,
  next_node_idx: u32,
  mut translation_metadata: LLVM2EggState,
) -> (Vec<VecLang>, u32) {
  assert!(isa_supported_binop(llvm_instr));
  let left = LLVMGetOperand(llvm_instr, 0);
  let right = LLVMGetOperand(llvm_instr, 1);
  let (left_egg_nodes, left_next_idx) =
    ref_to_egg(left, egg_nodes, next_node_idx, translation_metadata);
  let (mut right_egg_nodes, right_next_idx) =
    ref_to_egg(right, left_egg_nodes, left_next_idx, translation_metadata);
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
  mut egg_nodes: Vec<VecLang>,
  next_node_idx: u32,
  mut translation_metadata: LLVM2EggState,
) -> (Vec<VecLang>, u32) {
  assert!(isa_supported_unop(llvm_instr));
  let neg_expr = LLVMGetOperand(llvm_instr, 0);
  let (mut new_egg_nodes, new_next_idx) =
    ref_to_egg(neg_expr, egg_nodes, next_node_idx, translation_metadata);
  let id = Id::from((new_next_idx - 1) as usize);
  new_egg_nodes.push(choose_unop(&llvm_instr, id));
  (new_egg_nodes, new_next_idx + 1)
}

/// Translates Const Instruction to an Egg Number Node
unsafe fn const_to_egg(
  llvm_instr: LLVMValueRef,
  mut egg_nodes: Vec<VecLang>,
  next_node_idx: u32,
  mut translation_metadata: LLVM2EggState,
) -> (Vec<VecLang>, u32) {
  assert!(isa_constant(llvm_instr));
  let value = get_constant_float(llvm_instr);
  egg_nodes.push(VecLang::Num(value as i32));
  (egg_nodes, next_node_idx + 1)
}

/// Translates Sqrt 32 Instruction to an Egg Square Root Node
unsafe fn sqrt32_to_egg(
  llvm_instr: LLVMValueRef,
  mut egg_nodes: Vec<VecLang>,
  next_node_idx: u32,
  mut translation_metadata: LLVM2EggState,
) -> (Vec<VecLang>, u32) {
  assert!(isa_sqrt32(llvm_instr));
  let operand = LLVMGetOperand(llvm_instr, 0);
  let (mut new_enode_vec, new_next_node_idx) =
    ref_to_egg(llvm_instr, egg_nodes, next_node_idx, translation_metadata);
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
  mut translation_metadata: LLVM2EggState,
) -> (Vec<VecLang>, u32) {
  let register_idx = gen_reg_idx();
  let register_node = VecLang::Reg(register_idx);
  egg_nodes.push(register_node);
  translation_metadata
    .llvm2reg
    .insert(llvm_instr, register_node);
  (egg_nodes, next_node_idx + 1)
}

/// Recursively Translate LLVM Instruction to Egg Nodes.
///
/// TODO: Take care of chunk boundaries: translation should never overreach a chunk
/// TODO: May need to keep track of llvm instructions across chunks
unsafe fn ref_to_egg(
  llvm_instr: LLVMValueRef,
  mut egg_nodes: Vec<VecLang>,
  next_node_idx: u32,
  mut translation_metadata: LLVM2EggState,
) -> (Vec<VecLang>, u32) {
  // If, on a different pass, the instruction was translated already, then
  // just used the egg node representing the translation
  if translation_metadata.llvm2reg.contains_key(&llvm_instr) {
    let translated_egg_node = translation_metadata
      .llvm2reg
      .get(&llvm_instr)
      .expect("Key must exist");
    egg_nodes.push(*translated_egg_node);
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
  if !translation_metadata
    .instructions_in_chunk
    .contains(&llvm_instr)
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

unsafe fn start_translating_ref_to_egg(
  llvm_instr: LLVMValueRef,
  mut egg_nodes: Vec<VecLang>,
  next_node_idx: u32,
  mut translation_metadata: LLVM2EggState,
) -> (Vec<VecLang>, u32) {
  translation_metadata.start_instructions.push(llvm_instr);
  translation_metadata
    .start_ids
    .insert(Id::from(next_node_idx as usize));
  return ref_to_egg(llvm_instr, egg_nodes, next_node_idx, translation_metadata);
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

unsafe fn llvm_to_egg(
  llvm_instrs_in_chunk: &[LLVMValueRef],
  restricted_instrs: &[LLVMValueRef],
  // TODO: feed this in as an argument llvm_instr2egg_node: BTreeMap<LLVMValueRef, VecLang>,
) -> RecExpr<VecLang> {
  let mut egg_nodes: Vec<VecLang> = Vec::new();

  // Map from (translated / opaque) llvm instructions to register egg graph nodes
  let llvm_instr2reg_node: BTreeMap<LLVMValueRef, VecLang> = BTreeMap::new();
  // Map from (translated) llvm instructions to argument egg graph nodes
  let llvm_instr2arg_node: BTreeMap<LLVMValueRef, VecLang> = BTreeMap::new();

  // Ordered Vector of Starting LLVM instructions where translation began
  let start_instructions: Vec<LLVMValueRef> = Vec::new();

  // Ordered Set of Instructions in Chunk
  let instructions_in_chunk: BTreeSet<LLVMValueRef> = BTreeSet::new();
  for llvm_instr in llvm_instrs_in_chunk.iter() {
    instructions_in_chunk.insert(*llvm_instr);
  }

  // Ordered Set of Ids
  let start_ids: BTreeSet<Id> = BTreeSet::new();

  // Ordered Set of Instructions NOT TO BE Translated, except as registers
  let restricted_instrs: BTreeSet<LLVMValueRef> = BTreeSet::new();
  for llvm_instr in llvm_instrs_in_chunk.iter() {
    restricted_instrs.insert(*llvm_instr);
  }

  // State Variable To Hold Maps During Translation
  let mut translation_metadata = LLVM2EggState {
    llvm2reg: &llvm_instr2reg_node,
    llvm2arg: &llvm_instr2arg_node,
    instructions_in_chunk: &instructions_in_chunk,
    restricted_instructions: &restricted_instrs,
    start_instructions: start_instructions,
    start_ids: &start_ids,
  };

  // Index of next node to translate
  let mut next_node_idx: u32 = 0;

  // for each store, iterate backwards from that store and translate to egg
  for llvm_instr in llvm_instrs_in_chunk.iter() {
    if can_start_translation_instr(*llvm_instr) {
      let (new_egg_nodes, new_next_node_idx) =
        start_translating_ref_to_egg(*llvm_instr, egg_nodes, next_node_idx, translation_metadata);
      egg_nodes = new_egg_nodes;
      next_node_idx = new_next_node_idx;
    }
  }

  // Generate a padded vector
  let mut outer_vec_ids = Vec::new();
  for id in translation_metadata.start_ids.iter() {
    outer_vec_ids.push(*id);
  }
  balanced_pad_vector(&mut outer_vec_ids, &mut egg_nodes);

  let rec_expr = RecExpr::from(egg_nodes);

  return rec_expr;
}

// ---- Construction Zone -------

unsafe fn translate_egg(
  enode: &VecLang,
  vec: &[VecLang],
  gep_map: &GEPMap,
  store_map: &StoreMap,
  symbol_map: &SymbolMap,
  llvm_arg_pairs: &mut LLVMPairMap,
  node_to_arg_pair: &Vec<IntLLVMPair>,
  builder: LLVMBuilderRef,
  context: LLVMContextRef,
  module: LLVMModuleRef,
) -> LLVMValueRef {
  let instr = match enode {
    // VecLang::RegInfo(_) => panic!("RegInfo Currently Not Handled"),
    VecLang::Reg(_) => panic!("Reg Currently Not Handled"),
    VecLang::Symbol(symbol) => match symbol_map.get(enode) {
      Some(llvm_instr) => llvm_recursive_add(builder, *llvm_instr, context, llvm_arg_pairs),
      None => {
        let mut matched = false;
        let mut ret_value = LLVMBuildAdd(
          builder,
          LLVMConstReal(LLVMFloatTypeInContext(context), 0 as f64),
          LLVMConstReal(LLVMFloatTypeInContext(context), 0 as f64),
          b"nop\0".as_ptr() as *const _,
        );
        for node_arg_pair in node_to_arg_pair {
          let llvm_node = node_arg_pair.arg;
          let node_index = node_arg_pair.node_int;
          let string_node_index = node_index.to_string();
          if string_node_index.parse::<Symbol>().unwrap() == *symbol {
            for (original_val, new_val) in (&mut *llvm_arg_pairs).iter() {
              if cmp_val_ref_address(&**original_val, &*llvm_node) {
                matched = true;
                ret_value = *new_val;
                break;
              }
            }
          }
          if matched {
            break;
          }
        }
        if matched {
          ret_value
        } else {
          panic!("No Match in Node Arg Pair List.")
        }
      }
    },
    VecLang::Num(n) => LLVMConstReal(LLVMFloatTypeInContext(context), *n as f64),
    VecLang::Get(..) => {
      let (array_name, array_offsets) = translate_get(enode, vec);
      let gep_value = gep_map
        .get(&(array_name, array_offsets))
        .expect("Symbol map lookup error: Cannot Find GEP");
      let load_value = if isa_load(*gep_value) {
        let mut matched = false;
        let mut matched_expr = *gep_value;
        for (original_val, new_val) in (&*llvm_arg_pairs).iter() {
          if cmp_val_ref_address(&**original_val, &**gep_value) {
            matched = true;
            matched_expr = *new_val;
            break;
          }
        }
        if matched {
          matched_expr
        } else {
          let addr = LLVMGetOperand(*gep_value, 0);
          let new_gep = llvm_recursive_add(builder, addr, context, llvm_arg_pairs);
          let new_load = LLVMBuildLoad(builder, new_gep, b"\0".as_ptr() as *const _);
          llvm_arg_pairs.insert(*gep_value, new_load);
          new_load
        }
      } else if isa_gep(*gep_value) {
        let new_gep = llvm_recursive_add(builder, *gep_value, context, llvm_arg_pairs);
        LLVMBuildLoad(builder, new_gep, b"\0".as_ptr() as *const _)
      } else if isa_bitcast(*gep_value) {
        // TODO: DO NOT REGERATE CALLS. THESE SHOULD BE CACHED!!. e.g. a CALLOC
        let mut new_bitcast = llvm_recursive_add(builder, *gep_value, context, llvm_arg_pairs);
        if !isa_floatptr(new_bitcast) {
          let addr_space = LLVMGetPointerAddressSpace(LLVMTypeOf(new_bitcast));
          let new_ptr_type = LLVMPointerType(LLVMFloatTypeInContext(context), addr_space);
          new_bitcast = LLVMBuildBitCast(
            builder,
            new_bitcast,
            new_ptr_type,
            b"\0".as_ptr() as *const _,
          );
        }
        LLVMBuildLoad(builder, new_bitcast, b"\0".as_ptr() as *const _)
      } else if isa_sitofp(*gep_value) {
        let new_sitofp = llvm_recursive_add(builder, *gep_value, context, llvm_arg_pairs);
        new_sitofp
      } else if isa_argument(*gep_value) {
        let new_load_value = LLVMBuildLoad(builder, *gep_value, b"\0".as_ptr() as *const _);
        new_load_value
      } else {
        // includes isa_alloca case
        let mut matched = false;
        let mut matched_expr = *gep_value;
        for (original_val, new_val) in (&*llvm_arg_pairs).iter() {
          if cmp_val_ref_address(&**original_val, &**gep_value) {
            matched = true;
            matched_expr = *new_val;
            break;
          }
        }
        if matched {
          matched_expr
        } else {
          let new_load_value = LLVMBuildLoad(builder, *gep_value, b"\0".as_ptr() as *const _);
          // assert!(isa_load(*gep_value) || isa_alloca(*gep_value));
          // assert!(isa_load(new_load_value) || isa_alloca(new_load_value));
          llvm_arg_pairs.insert(*gep_value, new_load_value);
          new_load_value
        }
      };
      // let mut matched = false;
      // for (original_val, _) in (&*llvm_arg_pairs).iter() {
      //   if cmp_val_ref_address(&**original_val, &**gep_value) {
      //     matched = true;
      //     break;
      //   }
      // }
      // if !matched {
      //   llvm_arg_pairs.insert(*gep_value, load_value);
      // }
      load_value
    }
    VecLang::LitVec(boxed_ids) | VecLang::Vec(boxed_ids) | VecLang::List(boxed_ids) => {
      let idvec = boxed_ids.to_vec();
      let idvec_len = idvec.len();
      let mut zeros = Vec::new();
      for _ in 0..idvec_len {
        zeros.push(LLVMConstReal(LLVMFloatTypeInContext(context), 0 as f64));
      }
      let zeros_ptr = zeros.as_mut_ptr();
      let mut vector = LLVMConstVector(zeros_ptr, idvec.len() as u32);
      for (idx, &eggid) in idvec.iter().enumerate() {
        let elt = &vec[usize::from(eggid)];
        let mut elt_val = translate_egg(
          elt,
          vec,
          gep_map,
          store_map,
          symbol_map,
          llvm_arg_pairs,
          node_to_arg_pair,
          builder,
          context,
          module,
        );
        // check if the elt is an int
        if isa_integertype(elt_val) {
          elt_val = LLVMBuildBitCast(
            builder,
            elt_val,
            LLVMFloatTypeInContext(context),
            b"\0".as_ptr() as *const _,
          );
        }
        vector = LLVMBuildInsertElement(
          builder,
          vector,
          elt_val,
          LLVMConstInt(LLVMIntTypeInContext(context, 32), idx as u64, 0),
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
        llvm_arg_pairs,
        node_to_arg_pair,
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
        llvm_arg_pairs,
        node_to_arg_pair,
        builder,
        context,
        module,
      );
      let left = if LLVMTypeOf(left) == LLVMIntTypeInContext(context, 32) {
        LLVMBuildBitCast(
          builder,
          left,
          LLVMFloatTypeInContext(context),
          b"\0".as_ptr() as *const _,
        )
      } else {
        left
      };
      let right = if LLVMTypeOf(right) == LLVMIntTypeInContext(context, 32) {
        LLVMBuildBitCast(
          builder,
          right,
          LLVMFloatTypeInContext(context),
          b"\0".as_ptr() as *const _,
        )
      } else {
        right
      };
      if isa_constfp(left)
        && !isa_constaggregatezero(left)
        && isa_constfp(right)
        && !isa_constaggregatezero(right)
      {
        let mut loses_info = 1;
        let nright = LLVMConstRealGetDouble(right, &mut loses_info);
        let new_right = build_constant_float(nright, context);
        let nleft = LLVMConstRealGetDouble(left, &mut loses_info);
        let new_left = build_constant_float(nleft, context);
        translate_binop(
          enode,
          new_left,
          new_right,
          builder,
          b"\0".as_ptr() as *const _,
        )
      } else if isa_constfp(right) && !isa_constaggregatezero(right) {
        let mut loses_info = 1;
        let n = LLVMConstRealGetDouble(right, &mut loses_info);
        let new_right = build_constant_float(n, context);
        translate_binop(enode, left, new_right, builder, b"\0".as_ptr() as *const _)
      } else if isa_constfp(left) && !isa_constaggregatezero(left) {
        let mut loses_info = 1;
        let n = LLVMConstRealGetDouble(left, &mut loses_info);
        let new_left = build_constant_float(n, context);
        translate_binop(enode, new_left, right, builder, b"\0".as_ptr() as *const _)
      } else {
        translate_binop(enode, left, right, builder, b"\0".as_ptr() as *const _)
      }
    }
    VecLang::Concat([v1, v2]) => {
      let trans_v1 = translate_egg(
        &vec[usize::from(*v1)],
        vec,
        gep_map,
        store_map,
        symbol_map,
        llvm_arg_pairs,
        node_to_arg_pair,
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
        llvm_arg_pairs,
        node_to_arg_pair,
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
          zeros.push(LLVMConstReal(LLVMFloatTypeInContext(context), 0 as f64));
        }
        let zeros_ptr = zeros.as_mut_ptr();
        let zeros_vector = LLVMConstVector(zeros_ptr, v2_size);
        let size = 2 * v2_size;
        let mut indices = Vec::new();
        for i in 0..size {
          indices.push(LLVMConstInt(LLVMIntTypeInContext(context, 32), i as u64, 0));
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
        indices.push(LLVMConstInt(LLVMIntTypeInContext(context, 32), i as u64, 0));
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
        llvm_arg_pairs,
        node_to_arg_pair,
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
        llvm_arg_pairs,
        node_to_arg_pair,
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
        llvm_arg_pairs,
        node_to_arg_pair,
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
        llvm_arg_pairs,
        node_to_arg_pair,
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
        llvm_arg_pairs,
        node_to_arg_pair,
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
        llvm_arg_pairs,
        node_to_arg_pair,
        builder,
        context,
        module,
      );
      let vec_type = LLVMTypeOf(sgn_vec);
      let vec_size = LLVMGetVectorSize(vec_type);
      let mut ones = Vec::new();
      for _ in 0..vec_size {
        ones.push(LLVMConstReal(LLVMFloatTypeInContext(context), 1 as f64));
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
      let mut number = translate_egg(
        &vec[usize::from(*n)],
        vec,
        gep_map,
        store_map,
        symbol_map,
        llvm_arg_pairs,
        node_to_arg_pair,
        builder,
        context,
        module,
      );
      if isa_integertype(number) {
        number = LLVMBuildBitCast(
          builder,
          number,
          LLVMFloatTypeInContext(context),
          b"\0".as_ptr() as *const _,
        );
      }
      translate_unop(
        enode,
        number,
        builder,
        context,
        module,
        b"\0".as_ptr() as *const _,
      )
    }
    VecLang::Ite(..) => panic!("Ite is not handled."),
  };
  return instr;
}

unsafe fn gen_type_cast(
  val: LLVMValueRef,
  typ1: LLVMTypeRef,
  typ2: LLVMTypeRef,
  context: LLVMContextRef,
  builder: LLVMBuilderRef,
) -> LLVMValueRef {
  if typ1 == LLVMInt32TypeInContext(context) && typ2 == LLVMInt64TypeInContext(context) {
    return LLVMBuildZExt(builder, val, typ2, b"\0".as_ptr() as *const _);
  } else if typ1 == LLVMInt16TypeInContext(context) && typ2 == LLVMInt64TypeInContext(context) {
    return LLVMBuildZExt(builder, val, typ2, b"\0".as_ptr() as *const _);
  } else if typ1 == LLVMInt16TypeInContext(context) && typ2 == LLVMInt32TypeInContext(context) {
    return LLVMBuildZExt(builder, val, typ2, b"\0".as_ptr() as *const _);
  }
  LLVMDumpType(typ1);
  println!();
  LLVMDumpType(typ2);
  println!();
  panic!("Cannot convert between {:?} {:?}\n.", typ1, typ2);
}

unsafe fn egg_to_llvm(
  expr: RecExpr<VecLang>,
  gep_map: &GEPMap,
  store_map: &StoreMap,
  symbol_map: &SymbolMap,
  llvm_arg_pairs: &mut LLVMPairMap,
  node_to_arg_pair: &Vec<IntLLVMPair>,
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
    last_enode,
    enode_vec,
    gep_map,
    store_map,
    symbol_map,
    llvm_arg_pairs,
    node_to_arg_pair,
    builder,
    context,
    module,
  );

  // Add in the Stores
  for (i, (_, addr)) in store_map.iter().enumerate() {
    let index = LLVMConstInt(LLVMIntTypeInContext(context, 32), i as u64, 0);
    let mut extracted_value =
      LLVMBuildExtractElement(builder, vector, index, b"\0".as_ptr() as *const _);
    // check if the extracted type is an float and the address is a int ptr
    let mut_addr = if !isa_floatptr(*addr) {
      let addr_space = LLVMGetPointerAddressSpace(LLVMTypeOf(*addr));
      let new_ptr_type = LLVMPointerType(LLVMFloatTypeInContext(context), addr_space);
      LLVMBuildBitCast(builder, *addr, new_ptr_type, b"\0".as_ptr() as *const _)
    } else {
      *addr
    };
    if isa_argument(mut_addr) {
      if LLVMTypeOf(extracted_value) != LLVMGetElementType(LLVMTypeOf(mut_addr)) {
        extracted_value = gen_type_cast(
          extracted_value,
          LLVMTypeOf(extracted_value),
          LLVMGetElementType(LLVMTypeOf(mut_addr)),
          context,
          builder,
        );
      }
      LLVMBuildStore(builder, extracted_value, mut_addr);
    } else {
      let new_addr = llvm_recursive_add(builder, mut_addr, context, llvm_arg_pairs);
      if LLVMTypeOf(extracted_value) != LLVMGetElementType(LLVMTypeOf(mut_addr)) {
        extracted_value = gen_type_cast(
          extracted_value,
          LLVMTypeOf(extracted_value),
          LLVMGetElementType(LLVMTypeOf(mut_addr)),
          context,
          builder,
        );
      }
      LLVMBuildStore(builder, extracted_value, new_addr);
    }
  }
}
