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
    fn isa_load(val: LLVMValueRef) -> bool;
    fn isa_store(val: LLVMValueRef) -> bool;
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
    fn generate_opaque_pointer(element_type: LLVMTypeRef) -> LLVMTypeRef;
}

static mut ARG_IDX: u32 = 0;
static mut REG_IDX: u32 = 0;
static mut GET_IDX: u32 = 0;

unsafe fn gen_arg_idx() -> u32 {
    ARG_IDX += 1;
    return ARG_IDX;
}

unsafe fn gen_reg_idx() -> u32 {
    REG_IDX += 1;
    return REG_IDX;
}

unsafe fn gen_get_idx() -> u32 {
    GET_IDX += 1;
    return GET_IDX;
}

// Map from Func Name to LLVM FUnc
// Have to use Vec because BTReeMap is unstable at constant in Rust 1.58. New versions
// of Rust break LLVM 11.0 so I cannot upgrade.
static mut FUNC_NAME2LLVM_FUNC: Vec<(&str, LLVMValueRef)> = Vec::new();

static FMA_NAME: &str = "llvm.fma.v4f32";
static SCATTER: &str = "llvm.masked.scatter.v4f32.v4p0f32";
static GATHER: &str = "llvm.masked.gather.v4f32.v4p0f32";

unsafe fn get_func_llvm_value(name: &str) -> Option<LLVMValueRef> {
    for (func_name, value) in FUNC_NAME2LLVM_FUNC.clone() {
        if func_name == name {
            return Some(value);
        }
    }
    return None;
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
            let fn_type =
                LLVMFunctionType(LLVMFloatTypeInContext(context), param_types, 2, 0 as i32);
            let func =
                LLVMAddFunction(module, b"llvm.copysign.f32\0".as_ptr() as *const _, fn_type);
            let args = [one, n].as_mut_ptr();
            LLVMBuildCall(builder, func, args, 2, name)
        }
        VecLang::Sqrt(_) => {
            let param_types = [LLVMFloatTypeInContext(context)].as_mut_ptr();
            let fn_type =
                LLVMFunctionType(LLVMFloatTypeInContext(context), param_types, 1, 0 as i32);
            let func = LLVMAddFunction(module, b"llvm.sqrt.f32\0".as_ptr() as *const _, fn_type);
            let args = [n].as_mut_ptr();
            LLVMBuildCall(builder, func, args, 1, name)
        }
        VecLang::Neg(_) => LLVMBuildFNeg(builder, n, name),
        _ => panic!("Not a scalar unop."),
    }
}

/// Calculate cost for any Egg expression.
/// Uses a custom model that I developed, to see if an optimization should go through
/// or not.
pub fn calculate_cost() -> u32 {
    return 0;
}

/// Struct representing load info, same as on C++ side
#[repr(C)]
pub struct load_info_t {
    pub load: LLVMValueRef,
    pub base_id: i32,
    pub offset: i32,
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
    load_info: *const load_info_t,
    load_info_size: size_t,
    run_egg: bool,
    print_opt: bool,
) -> bool {
    unsafe {
        // preprocessing of instructions
        let chunk_llvm_instrs = from_raw_parts(chunk_instrs, chunk_size);
        let restricted_llvm_instrs = from_raw_parts(restricted_instrs, restricted_size);
        let load_info = from_raw_parts(load_info, load_info_size);

        // llvm to egg
        let (egg_expr, llvm2egg_metadata) =
            llvm_to_egg_main(chunk_llvm_instrs, restricted_llvm_instrs, run_egg);

        // Bail if no egg Nodes to optimize
        if egg_expr.as_ref().is_empty() {
            eprintln!("No Egg Nodes in Optimization Vector");
            return false;
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

        return true;
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
    Load,
    Store,
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
    } else if isa_load(*llvm_instr) {
        return LLVMOpType::Load;
    } else if isa_store(*llvm_instr) {
        return LLVMOpType::Store;
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
    get2gep: BTreeMap<u32, LLVMValueRef>,
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

/// Translates a Load to an Egg Get Node
///
/// The translation of a load is a Get Node, which can then possibly be vectorized
/// Adds the gep address of the load to the translation metadata so that it can
/// be referenced when translating from Egg to LLVM
///
/// Fails if the llvm instruction under translation is not a load
unsafe fn load_to_egg(
    llvm_instr: LLVMValueRef,
    mut egg_nodes: Vec<VecLang>,
    next_node_idx: u32,
    translation_metadata: &mut LLVM2EggState,
) -> (Vec<VecLang>, u32) {
    assert!(isa_load(llvm_instr));
    let gep_id = gen_get_idx();
    let gep_node = VecLang::Gep(gep_id);
    egg_nodes.push(gep_node.clone());
    let llvm_gep_instr = LLVMGetOperand(llvm_instr, 0);
    // assert!(isa_gep(llvm_gep_instr) || isa_argument(llvm_gep_instr));
    translation_metadata.get2gep.insert(gep_id, llvm_gep_instr);

    let load_node = VecLang::Load([Id::from(next_node_idx as usize)]);
    egg_nodes.push(load_node.clone());
    assert!(!translation_metadata.llvm2reg.contains_key(&llvm_instr));
    translation_metadata.llvm2reg.insert(llvm_instr, load_node);
    (egg_nodes, next_node_idx + 2)
}

unsafe fn store_to_egg(
    llvm_instr: LLVMValueRef,
    egg_nodes: Vec<VecLang>,
    next_node_idx: u32,
    translation_metadata: &mut LLVM2EggState,
) -> (Vec<VecLang>, u32) {
    assert!(isa_store(llvm_instr));
    let llvm_val_instr = LLVMGetOperand(llvm_instr, 0);
    let llvm_gep_instr = LLVMGetOperand(llvm_instr, 1);
    let (mut new_egg_nodes, new_next_idx) = llvm_to_egg(
        llvm_val_instr,
        egg_nodes,
        next_node_idx,
        translation_metadata,
    );

    let gep_id = gen_get_idx();
    let gep_node = VecLang::Gep(gep_id);
    new_egg_nodes.push(gep_node.clone());
    translation_metadata.get2gep.insert(gep_id, llvm_gep_instr);

    let store_node = VecLang::Store([
        Id::from((new_next_idx - 1) as usize), // reference to the recursive translation
        Id::from(new_next_idx as usize),       // reference to a GEP node
    ]);
    new_egg_nodes.push(store_node.clone());
    assert!(!translation_metadata.llvm2reg.contains_key(&llvm_instr));
    translation_metadata.llvm2reg.insert(llvm_instr, store_node);

    (new_egg_nodes, new_next_idx + 2) // Add 2 because we built a gep, then also a store node
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
    if !translation_metadata
        .prior_translated_instructions
        .contains(&llvm_instr)
    {
        translation_metadata
            .prior_translated_instructions
            .insert(llvm_instr);
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
        LLVMOpType::Argument => {
            arg_to_egg(llvm_instr, egg_nodes, next_node_idx, translation_metadata)
        }
        LLVMOpType::Sqrt32 => {
            sqrt32_to_egg(llvm_instr, egg_nodes, next_node_idx, translation_metadata)
        }
        LLVMOpType::Load => load_to_egg(llvm_instr, egg_nodes, next_node_idx, translation_metadata),
        LLVMOpType::Store => {
            store_to_egg(llvm_instr, egg_nodes, next_node_idx, translation_metadata)
        }
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
        LLVMOpType::Store => true,
        LLVMOpType::FAdd
        | LLVMOpType::FMul
        | LLVMOpType::FDiv
        | LLVMOpType::FSub
        | LLVMOpType::FNeg
        | LLVMOpType::Constant
        | LLVMOpType::Sqrt32
        | LLVMOpType::Load
        | LLVMOpType::Argument
        | LLVMOpType::UnhandledLLVMOpCode => false,
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

    // Map from (translated) Egg get ID to an original LLVM get node
    let getid2gep: BTreeMap<u32, LLVMValueRef> = BTreeMap::new();

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

    let prior_translated_instructions: BTreeSet<LLVMValueRef> = BTreeSet::new();

    // State Variable To Hold Maps During Translation
    let mut translation_metadata = LLVM2EggState {
        llvm2reg: llvm_instr2reg_node,
        llvm2arg: llvm_instr2arg_node,
        get2gep: getid2gep,
        instructions_in_chunk: instructions_in_chunk,
        restricted_instructions: restricted_instrs_set,
        prior_translated_instructions: prior_translated_instructions,
        start_instructions: start_instructions,
        start_ids: start_ids,
    };

    // Index of next node to translate
    let mut next_node_idx: u32 = 0;

    // for each final instruction, iterate backwards from that final instruction and translate to egg
    for llvm_instr in llvm_instrs_in_chunk.iter() {
        // only start translation back if it is a "translatable instruction" and it was not translated already
        if can_start_translation_instr(*llvm_instr) // TODO: Need to DFS back from this instruction and make sure invariants for translation hold, e.g. no bitcasts somewhere down the translation tree.
            && !translation_metadata
                .prior_translated_instructions
                .contains(&llvm_instr)
        {
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

/// Translates a Gep node to an ID that the node holds. This ID is matche dto
/// a gep instruction in the get2gep map
///
/// Used in conjunction with Load to LLVM and VecLoad to LLVM
unsafe fn gep_to_llvm(egg_node: &VecLang, _md: &mut Egg2LLVMState) -> u32 {
    match *egg_node {
        VecLang::Gep(gep_id) => gep_id,
        _ => panic!("Non Gep nodes cannot be translated in gep_to_llvm."),
    }
}

/// Translates a Load Egg Node back to an LLVM Load INstruction
///
/// Assumes that every load is implicitly from a Float * / Single Level Float Pointer
unsafe fn load_to_llvm(gep_id: &Id, md: &mut Egg2LLVMState) -> LLVMValueRef {
    let original_gep_id = gep_to_llvm(&md.egg_nodes_vector[usize::from(*gep_id)], md);
    let get2gep = &md.llvm2egg_metadata.get2gep;
    for (gep_id, gep_instr) in get2gep.iter() {
        if original_gep_id == *gep_id {
            // assert!(isa_gep(*gep_instr) || isa_argument(*gep_instr));
            let new_load_instr = LLVMBuildLoad(md.builder, *gep_instr, b"\0".as_ptr() as *const _);
            return new_load_instr;
        }
    }
    panic!("Load2LLVM: Expected a successful lookup in get2gep, but cannot find Gep ID.");
}

unsafe fn store_to_llvm(val_id: &Id, gep_id: &Id, md: &mut Egg2LLVMState) -> LLVMValueRef {
    let original_gep_id = gep_to_llvm(&md.egg_nodes_vector[usize::from(*gep_id)], md);
    let llvm_val_instr = egg_to_llvm(&md.egg_nodes_vector[usize::from(*val_id)], md);
    let get2gep = &md.llvm2egg_metadata.get2gep;
    for (gep_id, gep_instr) in get2gep.iter() {
        if original_gep_id == *gep_id {
            // assert!(isa_gep(*gep_instr) || isa_argument(*gep_instr));
            let new_store_instr = LLVMBuildStore(md.builder, llvm_val_instr, *gep_instr);
            return new_store_instr;
        }
    }
    panic!("Store2LLVM: Expected a successful lookup in get2gep, but cannot find Gep ID.");
}

unsafe fn loadvec_to_llvm(
    gep1_id: &Id,
    gep2_id: &Id,
    gep3_id: &Id,
    gep4_id: &Id,
    md: &mut Egg2LLVMState,
) -> LLVMValueRef {
    // Set Opaque Pointer ness
    let gep1_id_val = gep_to_llvm(&md.egg_nodes_vector[usize::from(*gep1_id)], md);
    let gep2_id_val = gep_to_llvm(&md.egg_nodes_vector[usize::from(*gep2_id)], md);
    let gep3_id_val = gep_to_llvm(&md.egg_nodes_vector[usize::from(*gep3_id)], md);
    let gep4_id_val = gep_to_llvm(&md.egg_nodes_vector[usize::from(*gep4_id)], md);

    let gep1_llvm_instr = md
        .llvm2egg_metadata
        .get2gep
        .get(&gep1_id_val)
        .expect("Value of gep1 id should exist in get2gep");
    let gep2_llvm_instr = md
        .llvm2egg_metadata
        .get2gep
        .get(&gep2_id_val)
        .expect("Value of gep2 id should exist in get2gep");
    let gep3_llvm_instr = md
        .llvm2egg_metadata
        .get2gep
        .get(&gep3_id_val)
        .expect("Value of gep3 id should exist in get2gep");
    let gep4_llvm_instr = md
        .llvm2egg_metadata
        .get2gep
        .get(&gep4_id_val)
        .expect("Value of gep4 id should exist in get2gep");

    // New code to handle a vector load
    // let address_space = LLVMGetPointerAddressSpace(LLVMTypeOf(*gep1_llvm_instr));
    // let bitcase_scalar_to_vector_type = LLVMBuildBitCast(
    //     md.builder,
    //     *gep1_llvm_instr,
    //     LLVMPointerType(
    //         LLVMVectorType(LLVMFloatTypeInContext(md.context), 4),
    //         address_space,
    //     ),
    //     b"scalar-to-vector-type-bit-cast\0".as_ptr() as *const _,
    // );
    // let load = LLVMBuildLoad(
    //     md.builder,
    //     bitcase_scalar_to_vector_type,
    //     b"vector-load\0".as_ptr() as *const _,
    // );
    // return load;

    let vector_width = 4;
    let floatptr_type = LLVMTypeOf(*gep1_llvm_instr);
    let vec4ptr_type = LLVMVectorType(floatptr_type, vector_width);
    let vec4f_type = LLVMVectorType(LLVMFloatTypeInContext(md.context), vector_width);
    let vec4b_type = LLVMVectorType(LLVMInt1TypeInContext(md.context), vector_width);
    let int_type = LLVMIntTypeInContext(md.context, 32);

    // Parameter Types are:: vector of pointers, offset int, mask vector booleans and pass through vector
    // Pasthru is poison according to LLVM
    let param_types = [vec4ptr_type, int_type, vec4b_type, vec4f_type].as_mut_ptr();
    // Output type is a 4 length vector
    let fn_type = LLVMFunctionType(vec4f_type, param_types, 4, 0 as i32);
    // Build the Vector Load Intrinsic
    let func_name = &GATHER;
    let llvm_masked_gather_func = get_func_llvm_value(&func_name);

    let func = match llvm_masked_gather_func {
        Some(value) => value,
        None => {
            let new_func = LLVMAddFunction(
                md.module,
                b"llvm.masked.gather.v4f32.v4p0f32\0".as_ptr() as *const _,
                fn_type,
            );
            FUNC_NAME2LLVM_FUNC.push((&func_name, new_func));
            new_func
        }
    };

    // Build Arguments

    let mut zeros = Vec::new();
    for _ in 0..4 {
        zeros.push(LLVMConstReal(LLVMFloatTypeInContext(md.context), 0 as f64));
    }
    let zeros_ptr = zeros.as_mut_ptr();
    let zero_vector = LLVMConstVector(zeros_ptr, 4);

    let pointer_to_int_value = LLVMBuildPtrToInt(
        md.builder,
        LLVMConstInt(LLVMIntTypeInContext(md.context, 32), 0 as u64, 0),
        LLVMIntTypeInContext(md.context, 32),
        b"pointer-to-int\0".as_ptr() as *const _,
    );
    let pointer_to_float_value = LLVMBuildBitCast(
        md.builder,
        pointer_to_int_value,
        generate_opaque_pointer(LLVMFloatTypeInContext(md.context)),
        b"pointer-to-float-bit-cast\0".as_ptr() as *const _,
    );
    let mut pointer_to_floats = Vec::new();
    for _ in 0..4 {
        pointer_to_floats.push(pointer_to_float_value);
    }
    let pointer_to_floats_ptr = pointer_to_floats.as_mut_ptr();
    let mut pointer_vector = LLVMConstVector(pointer_to_floats_ptr, 4);

    let llvm_ptrs = vec![
        *gep1_llvm_instr,
        *gep2_llvm_instr,
        *gep3_llvm_instr,
        *gep4_llvm_instr,
    ];
    for idx in 0..4 {
        // Grow the Vector
        pointer_vector = LLVMBuildInsertElement(
            md.builder,
            pointer_vector,
            *llvm_ptrs.get(idx).expect("Index must be in vector"),
            LLVMConstInt(LLVMIntTypeInContext(md.context, 32), idx as u64, 0),
            b"\0".as_ptr() as *const _,
        );
    }

    let offset = LLVMConstInt(LLVMIntTypeInContext(md.context, 32), 0 as u64, 0);

    let mut mask_values = vec![
        LLVMConstInt(LLVMIntTypeInContext(md.context, 1), 1 as u64, 0),
        LLVMConstInt(LLVMIntTypeInContext(md.context, 1), 1 as u64, 0),
        LLVMConstInt(LLVMIntTypeInContext(md.context, 1), 1 as u64, 0),
        LLVMConstInt(LLVMIntTypeInContext(md.context, 1), 1 as u64, 0),
    ];
    let ptr_to_mask_values = mask_values.as_mut_ptr();
    let mask_vector = LLVMConstVector(ptr_to_mask_values, 4);

    let args = [pointer_vector, offset, mask_vector, zero_vector].as_mut_ptr();
    LLVMBuildCall(md.builder, func, args, 4, b"\0".as_ptr() as *const _)
}

unsafe fn storevec_to_llvm(
    val_vec_id: &Id,
    gep1_id: &Id,
    gep2_id: &Id,
    gep3_id: &Id,
    gep4_id: &Id,
    md: &mut Egg2LLVMState,
) -> LLVMValueRef {
    // Recursively translate val_vec_id to an LLVM Vector Instr
    let llvm_val_vec = egg_to_llvm(&md.egg_nodes_vector[usize::from(*val_vec_id)], md);

    // Set Opaque Pointer ness
    let gep1_id_val = gep_to_llvm(&md.egg_nodes_vector[usize::from(*gep1_id)], md);
    let gep2_id_val = gep_to_llvm(&md.egg_nodes_vector[usize::from(*gep2_id)], md);
    let gep3_id_val = gep_to_llvm(&md.egg_nodes_vector[usize::from(*gep3_id)], md);
    let gep4_id_val = gep_to_llvm(&md.egg_nodes_vector[usize::from(*gep4_id)], md);

    let gep1_llvm_instr = md
        .llvm2egg_metadata
        .get2gep
        .get(&gep1_id_val)
        .expect("Value of gep1 id should exist in get2gep");
    let gep2_llvm_instr = md
        .llvm2egg_metadata
        .get2gep
        .get(&gep2_id_val)
        .expect("Value of gep2 id should exist in get2gep");
    let gep3_llvm_instr = md
        .llvm2egg_metadata
        .get2gep
        .get(&gep3_id_val)
        .expect("Value of gep3 id should exist in get2gep");
    let gep4_llvm_instr = md
        .llvm2egg_metadata
        .get2gep
        .get(&gep4_id_val)
        .expect("Value of gep4 id should exist in get2gep");

    // New code to handle a vector store
    // Currently, this is the only type of store that can be generated because stores are not split.
    let address_space = LLVMGetPointerAddressSpace(LLVMTypeOf(*gep1_llvm_instr));
    let bitcase_scalar_to_vector_type = LLVMBuildBitCast(
        md.builder,
        *gep1_llvm_instr,
        LLVMPointerType(
            LLVMVectorType(LLVMFloatTypeInContext(md.context), 4),
            address_space,
        ),
        b"scalar-to-vector-type-bit-cast\0".as_ptr() as *const _,
    );
    let store = LLVMBuildStore(md.builder, llvm_val_vec, bitcase_scalar_to_vector_type);
    return store;

    let vector_width = 4;
    let floatptr_type = LLVMTypeOf(*gep1_llvm_instr);
    let vec4ptr_type = LLVMVectorType(floatptr_type, vector_width);
    let vec4f_type = LLVMVectorType(LLVMFloatTypeInContext(md.context), vector_width);
    let vec4b_type = LLVMVectorType(LLVMInt1TypeInContext(md.context), vector_width);
    let int_type = LLVMIntTypeInContext(md.context, 32);
    let void_type = LLVMVoidTypeInContext(md.context);

    // Parameter Types are: vector of values, vector of pointers, offset int, mask vector booleans
    let param_types = [vec4f_type, vec4ptr_type, int_type, vec4b_type].as_mut_ptr();
    // Output type is a void_type
    let fn_type = LLVMFunctionType(void_type, param_types, 4, 0 as i32);
    // Build the Vector Load Intrinsic
    let func_name = &SCATTER;
    let llvm_masked_scatter_func = get_func_llvm_value(&func_name);

    let func = match llvm_masked_scatter_func {
        Some(value) => value,
        None => {
            let new_func = LLVMAddFunction(
                md.module,
                b"llvm.masked.scatter.v4f32.v4p0f32\0".as_ptr() as *const _,
                fn_type,
            );
            FUNC_NAME2LLVM_FUNC.push((&func_name, new_func));
            new_func
        }
    };

    // Build Arguments

    let pointer_to_int_value = LLVMBuildPtrToInt(
        md.builder,
        LLVMConstInt(LLVMIntTypeInContext(md.context, 32), 0 as u64, 0),
        LLVMIntTypeInContext(md.context, 32),
        b"pointer-to-int\0".as_ptr() as *const _,
    );
    let pointer_to_float_value = LLVMBuildBitCast(
        md.builder,
        pointer_to_int_value,
        floatptr_type,
        b"pointer-to-float-bit-cast\0".as_ptr() as *const _,
    );
    let mut pointer_to_floats = Vec::new();
    for _ in 0..4 {
        pointer_to_floats.push(pointer_to_float_value);
    }
    let pointer_to_floats_ptr = pointer_to_floats.as_mut_ptr();
    let mut pointer_vector = LLVMConstVector(pointer_to_floats_ptr, 4);

    let llvm_ptrs = vec![
        *gep1_llvm_instr,
        *gep2_llvm_instr,
        *gep3_llvm_instr,
        *gep4_llvm_instr,
    ];
    for idx in 0..4 {
        // Grow the Vector
        pointer_vector = LLVMBuildInsertElement(
            md.builder,
            pointer_vector,
            *llvm_ptrs.get(idx).expect("Index must be in vector"),
            LLVMConstInt(LLVMIntTypeInContext(md.context, 32), idx as u64, 0),
            b"\0".as_ptr() as *const _,
        );
    }

    let offset = LLVMConstInt(LLVMIntTypeInContext(md.context, 32), 0 as u64, 0);

    let mut mask_values = vec![
        LLVMConstInt(LLVMIntTypeInContext(md.context, 1), 1 as u64, 0),
        LLVMConstInt(LLVMIntTypeInContext(md.context, 1), 1 as u64, 0),
        LLVMConstInt(LLVMIntTypeInContext(md.context, 1), 1 as u64, 0),
        LLVMConstInt(LLVMIntTypeInContext(md.context, 1), 1 as u64, 0),
    ];
    let ptr_to_mask_values = mask_values.as_mut_ptr();
    let mask_vector = LLVMConstVector(ptr_to_mask_values, 4);

    let args = [llvm_val_vec, pointer_vector, offset, mask_vector].as_mut_ptr();
    LLVMBuildCall(md.builder, func, args, 4, b"\0".as_ptr() as *const _)
}

unsafe fn arg_to_llvm(egg_node: &VecLang, md: &mut Egg2LLVMState) -> LLVMValueRef {
    // TODO: Make More Efficient with BTREEMAP?
    let llvm2arg = &md.llvm2egg_metadata.llvm2arg;
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

unsafe fn reg_to_llvm(
    egg_node: &VecLang,
    translation_metadata: &mut Egg2LLVMState,
) -> LLVMValueRef {
    // TODO: Make More Efficient with BTREEMAP?
    let llvm2reg = &translation_metadata.llvm2egg_metadata.llvm2reg;
    for (llvm_instr, reg_node) in llvm2reg.iter() {
        // We can do a struct comparison rather than point comparison as arg node contents are indexed by a unique u32.
        if reg_node == egg_node {
            assert!(!isa_argument(*llvm_instr));
            // do not clone an instruction translated earlier in the same chunk
            if translation_metadata
                .prior_translated_nodes
                .contains(&*llvm_instr)
            {
                return *llvm_instr;
            }
            // do not clone an instruction translated in a prior basic block / prior chunk
            if !translation_metadata
                .llvm2egg_metadata
                .instructions_in_chunk
                .contains(&*llvm_instr)
            {
                return *llvm_instr;
            }
            let new_instr = LLVMInstructionClone(*llvm_instr);
            LLVMInsertIntoBuilder(translation_metadata.builder, new_instr);
            translation_metadata
                .prior_translated_nodes
                .insert(new_instr);
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

unsafe fn nooptvector_to_llvm(boxed_ids: &Box<[Id]>, md: &mut Egg2LLVMState) -> LLVMValueRef {
    // Convert the Boxed Ids to a Vector, and generate a vector of zeros
    // Invariant: idvec must not be empty
    let idvec = boxed_ids.to_vec();
    let mut elt_val = LLVMConstInt(LLVMIntTypeInContext(md.context, 32), 0 as u64, 0);
    for eggid in idvec {
        let elt = &md.egg_nodes_vector[usize::from(eggid)];
        elt_val = egg_to_llvm(elt, md);
    }
    elt_val
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

// TODO: fix up concat errors due to having vecstores.
unsafe fn concat_to_llvm(
    left_vector: &Id,
    right_vector: &Id,
    md: &mut Egg2LLVMState,
) -> LLVMValueRef {
    {
        let trans_v1 = egg_to_llvm(&md.egg_nodes_vector[usize::from(*left_vector)], md);
        let mut trans_v2 = egg_to_llvm(&md.egg_nodes_vector[usize::from(*right_vector)], md);
        return trans_v2;

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
    // let vector_width = config::vector_width();
    // let fma_intrinsic_name = format!("llvm.fma.v{}f32\0", vector_width).as_bytes();

    let func_name = &FMA_NAME;
    let llvm_fma_func = get_func_llvm_value(&func_name);

    let func = match llvm_fma_func {
        Some(value) => value,
        None => {
            let new_func =
                LLVMAddFunction(md.module, b"llvm.fma.v4f32\0".as_ptr() as *const _, fn_type);
            FUNC_NAME2LLVM_FUNC.push((&func_name, new_func));
            new_func
        }
    };
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
        LLVMInstructionEraseFromParent(*old_instr);
    }
}

/// Egg To LLVM Dispatches translation of VecLanf Egg Nodes to LLVMValueRegs
///
/// Side Effect: Builds and Insert LLVM instructions
unsafe fn egg_to_llvm(
    egg_node: &VecLang,
    translation_metadata: &mut Egg2LLVMState,
) -> LLVMValueRef {
    match egg_node {
    VecLang::Symbol(..) => {
      panic!("Symbol was found. Egg to LLVM Translation does not handle symbol nodes.")
    }
    VecLang::Get(..) => {
      panic!("Get was found. Egg to LLVM Translation does not handle get nodes.")
    }
    VecLang::Gep(..) => {
        panic!("Gep was found. Egg to LLVM Translation does not handle gep nodes.")
    }
    VecLang::Load([gep_id]) => {
        load_to_llvm(gep_id, translation_metadata)
    }
    VecLang::Store([val_id, gep_id]) => {
        store_to_llvm(val_id, gep_id, translation_metadata)
    }
    VecLang::Set(..) => {
        panic!("Set was found. Egg to LLVM Translation does not handle set nodes.")
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
    VecLang::NoOptVec(boxed_ids) => nooptvector_to_llvm(boxed_ids, translation_metadata),
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
    VecLang::VecLoad([gep1_id, gep2_id, gep3_id, gep4_id]) => loadvec_to_llvm(gep1_id, gep2_id, gep3_id, gep4_id, translation_metadata),
    VecLang::VecStore([val_vec_id, gep1_id, gep2_id, gep3_id, gep4_id]) => storevec_to_llvm(val_vec_id, gep1_id, gep2_id, gep3_id, gep4_id, translation_metadata),
  }
}

// Function types for constructor anonymous functions
type VecLangSingleConstructor = fn([Id; 1]) -> VecLang;
type VecLangPairConstructor = fn([Id; 2]) -> VecLang;
type VecLangTripleConstructor = fn([Id; 3]) -> VecLang;
type VecLangQuadConstructor = fn([Id; 4]) -> VecLang;
type VecLangQuintConstructor = fn([Id; 5]) -> VecLang;
type VecLangBoxedConstructor = fn(bool, Box<[Id]>) -> VecLang;

/// Canonicalizes a Enode with a single inpit constructor
unsafe fn canonicalize_single(
    can_change_vector: bool,
    constructor: VecLangSingleConstructor,
    single_vector: &Id,
    old_egg_nodes: &[VecLang],
) -> Vec<VecLang> {
    let mut trans_v1 = canonicalize_egg(
        false,
        &old_egg_nodes[usize::from(*single_vector)],
        old_egg_nodes,
    );
    trans_v1.push(constructor([*single_vector]));
    trans_v1
}

/// Canonicalizes a Enode with a pair constructor
unsafe fn canonicalize_pair(
    is_concat: bool,
    can_change_vector: bool,
    constructor: VecLangPairConstructor,
    left_vector: &Id,
    right_vector: &Id,
    old_egg_nodes: &[VecLang],
) -> Vec<VecLang> {
    let trans_v1 = canonicalize_egg(
        if !is_concat { false } else { can_change_vector },
        &old_egg_nodes[usize::from(*left_vector)],
        old_egg_nodes,
    );
    let trans_v2 = canonicalize_egg(
        if !is_concat { false } else { can_change_vector },
        &old_egg_nodes[usize::from(*right_vector)],
        old_egg_nodes,
    );
    let mut whole_vector = [trans_v1, trans_v2].concat();
    whole_vector.push(constructor([*left_vector, *right_vector]));
    whole_vector
}

/// Canonicalizes a Enode with a triple input constructor
unsafe fn canonicalize_triple(
    can_change_vector: bool,
    constructor: VecLangTripleConstructor,
    first_vector: &Id,
    second_vector: &Id,
    third_vector: &Id,
    old_egg_nodes: &[VecLang],
) -> Vec<VecLang> {
    let trans_v1 = canonicalize_egg(
        false,
        &old_egg_nodes[usize::from(*first_vector)],
        old_egg_nodes,
    );
    let trans_v2 = canonicalize_egg(
        false,
        &old_egg_nodes[usize::from(*second_vector)],
        old_egg_nodes,
    );
    let trans_v3 = canonicalize_egg(
        false,
        &old_egg_nodes[usize::from(*third_vector)],
        old_egg_nodes,
    );
    let mut whole_vector = [trans_v1, trans_v2, trans_v3].concat();
    whole_vector.push(constructor([*first_vector, *second_vector, *third_vector]));
    whole_vector
}

/// Canonicalizes a Enode with a quadruple input constructor
unsafe fn canonicalize_quadruple(
    can_change_vector: bool,
    constructor: VecLangQuadConstructor,
    first_vector: &Id,
    second_vector: &Id,
    third_vector: &Id,
    fourth_vector: &Id,
    old_egg_nodes: &[VecLang],
) -> Vec<VecLang> {
    let trans_v1 = canonicalize_egg(
        false,
        &old_egg_nodes[usize::from(*first_vector)],
        old_egg_nodes,
    );
    let trans_v2 = canonicalize_egg(
        false,
        &old_egg_nodes[usize::from(*second_vector)],
        old_egg_nodes,
    );
    let trans_v3 = canonicalize_egg(
        false,
        &old_egg_nodes[usize::from(*third_vector)],
        old_egg_nodes,
    );
    let trans_v4 = canonicalize_egg(
        false,
        &old_egg_nodes[usize::from(*fourth_vector)],
        old_egg_nodes,
    );
    let mut whole_vector = [trans_v1, trans_v2, trans_v3, trans_v4].concat();
    whole_vector.push(constructor([
        *first_vector,
        *second_vector,
        *third_vector,
        *fourth_vector,
    ]));
    whole_vector
}

/// Canonicalizes a Enode with a quintuple input constructor
unsafe fn canonicalize_quintuple(
    can_change_vector: bool,
    constructor: VecLangQuintConstructor,
    first_vector: &Id,
    second_vector: &Id,
    third_vector: &Id,
    fourth_vector: &Id,
    fifth_vector: &Id,
    old_egg_nodes: &[VecLang],
) -> Vec<VecLang> {
    let trans_v1 = canonicalize_egg(
        false,
        &old_egg_nodes[usize::from(*first_vector)],
        old_egg_nodes,
    );
    let trans_v2 = canonicalize_egg(
        false,
        &old_egg_nodes[usize::from(*second_vector)],
        old_egg_nodes,
    );
    let trans_v3 = canonicalize_egg(
        false,
        &old_egg_nodes[usize::from(*third_vector)],
        old_egg_nodes,
    );
    let trans_v4 = canonicalize_egg(
        false,
        &old_egg_nodes[usize::from(*fourth_vector)],
        old_egg_nodes,
    );
    let trans_v5 = canonicalize_egg(
        false,
        &old_egg_nodes[usize::from(*fifth_vector)],
        old_egg_nodes,
    );
    let mut whole_vector = [trans_v1, trans_v2, trans_v3, trans_v4, trans_v5].concat();
    whole_vector.push(constructor([
        *first_vector,
        *second_vector,
        *third_vector,
        *fourth_vector,
        *fifth_vector,
    ]));
    whole_vector
}

unsafe fn canonicalize_vec_type(
    can_change_vector: bool,
    constructor: VecLangBoxedConstructor,
    boxed_ids: &Box<[Id]>,
    old_egg_nodes: &[VecLang],
) -> Vec<VecLang> {
    let mut whole_vector: Vec<VecLang> = Vec::new();
    let mut new_boxed_ids: Vec<Id> = Vec::new();
    for id in boxed_ids.iter() {
        new_boxed_ids.push(*id);
        let trans_vec = canonicalize_egg(false, &old_egg_nodes[usize::from(*id)], old_egg_nodes);
        for elt in trans_vec {
            whole_vector.push(elt);
        }
    }
    let boxed = new_boxed_ids.into_boxed_slice();
    whole_vector.push(constructor(can_change_vector, boxed));
    whole_vector
}

/// Modify the Egg expression so that the first instance of a Vector operation is replaced by a NoOpVector expression node
/// The reason is that in this version of Diospyros, stores and vecstores explictly mark where a store is to be done.
/// The outermost vectors encountered will not store anything. Replacing them with NoOps will allow translation to occur properly.
unsafe fn canonicalize_egg(
    can_change_vector: bool,
    curr_egg_node: &VecLang,
    old_egg_nodes: &[VecLang],
) -> Vec<VecLang> {
    match curr_egg_node {
    VecLang::NoOptVec(..) => panic!("No Opt Vector was found. Egg canonicalization does not handle No Opt Vector nodes at this location."),
    VecLang::Symbol(..) => {
      panic!("Symbol was found. Egg canonicalization does not handle symbol nodes.")
    }
    VecLang::Get(..) => {
      panic!("Get was found. Egg canonicalization does not handle get nodes.")
    }
    VecLang::Gep(g) => vec![VecLang::Gep(*g)],
    VecLang::Load([gep_id]) => canonicalize_single(can_change_vector,|single| -> VecLang {VecLang::Load(single)}, gep_id, old_egg_nodes ),
    VecLang::Store([val_id, gep_id]) => canonicalize_pair(false, can_change_vector, |pair| -> VecLang {VecLang::Store(pair)}, val_id, gep_id, old_egg_nodes),
    VecLang::Set(..) => {
        panic!("Set was found. Egg canonicalization does not handle set nodes.")
    }
    VecLang::Ite(..) => panic!("Ite was found. Egg canonicalization does not handle ite nodes."),
    VecLang::Or(..) => panic!("Or was found. Egg canonicalization does not handle or nodes."),
    VecLang::And(..) => panic!("And was found. Egg canonicalization does not handle and nodes."),
    VecLang::Lt(..) => panic!("Lt was found. Egg canonicalizationdoes not handle lt nodes."),
    VecLang::Sgn(..) => panic!("Sgn was found. Egg canonicalization does not handle sgn nodes. TODO: In the future, tis node will be handled alongside sqrt and neg scalar nodes."),
    VecLang::VecSgn(..) => panic!("VecSgn was found. Egg canonicalization does not handle vecsgn nodes. TODO: In the future, this node will be handled alongside VecSqrt and VecNeg vector nodes."),
    VecLang::Arg(a) => vec![VecLang::Arg(*a)],
    VecLang::Reg(r) =>  vec![VecLang::Reg(*r)],
    VecLang::Num(n) =>  vec![VecLang::Num(*n)],
    VecLang::List(_) => panic!("List was found. Egg canonicalization does not handle list nodes."),
    VecLang::LitVec(boxed_ids) => canonicalize_vec_type(can_change_vector, |change_vec_type, boxed| -> VecLang {if change_vec_type {VecLang::NoOptVec(boxed)} else {VecLang::LitVec(boxed)}}, boxed_ids, old_egg_nodes),
    VecLang::Vec(boxed_ids) => canonicalize_vec_type(can_change_vector, |change_vec_type, boxed| -> VecLang {if change_vec_type {VecLang::NoOptVec(boxed)} else {VecLang::Vec(boxed)}}, boxed_ids, old_egg_nodes),
    VecLang::VecAdd([l, r])=> canonicalize_pair(false, can_change_vector, |pair| -> VecLang {VecLang::VecAdd(pair)}, l, r, old_egg_nodes),
    VecLang::VecMinus([l, r])=> canonicalize_pair(false, can_change_vector, |pair| -> VecLang {VecLang::VecMinus(pair)},l, r, old_egg_nodes),
    VecLang::VecMul([l, r])=> canonicalize_pair(false, can_change_vector, |pair| -> VecLang {VecLang::VecMul(pair)}, l, r, old_egg_nodes),
    VecLang::VecDiv([l, r])=> canonicalize_pair(false, can_change_vector, |pair| -> VecLang {VecLang::VecDiv(pair)}, l, r, old_egg_nodes),
    VecLang::Add([l, r]) => canonicalize_pair(false, can_change_vector, |pair| -> VecLang {VecLang::Add(pair)}, l, r, old_egg_nodes),
    VecLang::Minus([l, r]) => canonicalize_pair(false, can_change_vector, |pair| -> VecLang {VecLang::Minus(pair)}, l, r, old_egg_nodes),
    VecLang::Mul([l, r]) => canonicalize_pair(false, can_change_vector, |pair| -> VecLang {VecLang::Mul(pair)}, l, r, old_egg_nodes),
    VecLang::Div([l, r]) => canonicalize_pair(false, can_change_vector, |pair| -> VecLang {VecLang::Div(pair)}, l, r, old_egg_nodes),
    VecLang::Concat([l, r]) => canonicalize_pair(true, can_change_vector, |pair| -> VecLang {VecLang::Concat(pair)},l, r, old_egg_nodes),
    VecLang::VecMAC([acc, v1, v2]) => canonicalize_triple(can_change_vector, |triple| -> VecLang {VecLang::VecMAC(triple)},acc, v1, v2, old_egg_nodes),


    // TODO: VecNeg, VecSqrt, VecSgn all have not been tested, need test cases.
    // TODO: LLVM actually supports many more vector intrinsics, including
    // vector sine/cosine instructions for floats.
    VecLang::VecNeg([v]) => canonicalize_single(can_change_vector,|single| -> VecLang {VecLang::VecNeg(single)}, v, old_egg_nodes ),
    VecLang::VecSqrt([v]) => canonicalize_single(can_change_vector,|single| -> VecLang {VecLang::VecSqrt(single)}, v, old_egg_nodes ),
    // VecSgn compliant with c++ LibMath copysign function, which differs with sgn at x = 0.
    VecLang::VecSgn([v]) => canonicalize_single(can_change_vector,|single| -> VecLang {VecLang::VecSgn(single)}, v, old_egg_nodes ),
    VecLang::Sgn([n]) => canonicalize_single(can_change_vector,|single| -> VecLang {VecLang::Sgn(single)}, n, old_egg_nodes ),
    VecLang::Sqrt([n]) => canonicalize_single(can_change_vector,|single| -> VecLang {VecLang::Sqrt(single)}, n, old_egg_nodes ),
    VecLang::Neg([n]) => canonicalize_single(can_change_vector,|single| -> VecLang {VecLang::Neg(single)}, n, old_egg_nodes ),
    VecLang::VecLoad([gep1_id, gep2_id, gep3_id, gep4_id]) => canonicalize_quadruple(can_change_vector,|quad| -> VecLang {VecLang::VecLoad(quad)}, gep1_id, gep2_id, gep3_id, gep4_id, old_egg_nodes ),
    VecLang::VecStore([val_vec_id, gep1_id, gep2_id, gep3_id, gep4_id]) => canonicalize_quintuple(can_change_vector,|quint| -> VecLang {VecLang::VecStore(quint)}, val_vec_id, gep1_id, gep2_id, gep3_id, gep4_id, old_egg_nodes ),
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

    // Regular translation from vectorization

    assert!(!is_nooptvec(last_egg_node));

    let canonicalized_egg_nodes = canonicalize_egg(true, last_egg_node, egg_nodes);
    let canonicalized_last_node = canonicalized_egg_nodes
        .last()
        .expect("No match for last element of vector of Canonicalized Egg Terms.");

    let mut translation_metadata = Egg2LLVMState {
        egg_nodes_vector: &canonicalized_egg_nodes,
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

    // let llvm_vector =
    egg_to_llvm(canonicalized_last_node, &mut translation_metadata);

    // remove starting stores
    let num_extractions = llvm2egg_metadata.start_instructions.len();
    for i in (0..num_extractions).rev() {
        let old_instr = llvm2egg_metadata
            .start_instructions
            .get(i)
            .expect("Index should be in vector.");
        LLVMInstructionEraseFromParent(*old_instr);
    }

    // BELOW HERE, we allow for vectorization output, and we stitch our work back into the current LLVM code

    // NOTE: We Assume Egg rewriter will maintain relative positions of elements in vector
    // REVIEW ASSUMPTION!
    // Extract the elements of the vector, to be assigned back to where they are to be used.
    // let num_extractions = llvm2egg_metadata.start_instructions.len();
    // for i in (0..num_extractions).rev() {
    //     let old_instr = llvm2egg_metadata
    //         .start_instructions
    //         .get(i)
    //         .expect("Index should be in vector.");
    //     // Build the extracted value
    //     let index = LLVMConstInt(LLVMIntTypeInContext(context, 32), i as u64, 0);
    //     let extracted_value =
    //         LLVMBuildExtractElement(builder, llvm_vector, index, b"\0".as_ptr() as *const _);
    //     // Replace all the uses of the old instruction with the new extracted value
    //     // Old instruction cannot have been removed.
    //     LLVMReplaceAllUsesWith(*old_instr, extracted_value);
    //     LLVMInstructionEraseFromParent(*old_instr);
    // }
}
