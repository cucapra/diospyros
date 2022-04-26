extern crate llvm_sys as llvm;
use dioslib::{config, rules, veclang::VecLang};
use egg::*;
use libc::size_t;
use llvm::{core::*, prelude::*, LLVMOpcode::*, LLVMRealPredicate};
use std::{
    cmp,
    collections::{BTreeMap, BTreeSet},
    ffi::CStr,
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

static mut ARG_IDX: i32 = 0;
static mut CALL_IDX: i32 = 0;
static mut NODE_IDX: u32 = 0;

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

/// translate_get converts a VecLang Get Node to the corresponding LLVM Ir array name and
/// LLVM IR offset, as symbols.
unsafe fn translate_get(get: &VecLang, enode_vec: &[VecLang]) -> (Symbol, Symbol) {
    match get {
        VecLang::Get([sym, i]) => {
            match (&enode_vec[usize::from(*sym)], &enode_vec[usize::from(*i)]) {
                (VecLang::Symbol(name), VecLang::Symbol(offset)) => {
                    return (*name, *offset);
                }
                _ => panic!("Match Error: Expects Pair of Symbol, Symbol."),
            }
        }
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
        let mut llvm_arg_pairs_boxed_slice: Box<[LLVMPair]> =
            final_llvm_arg_pairs.into_boxed_slice();
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
    Store,
    Load,
    Gep,
    Unop,
    Bop,
    Call,
    FPTrunc,
    SIToFP,
    Bitcast,
    Sqrt32,
    Sqrt64,
    FPExt,
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

unsafe fn match_llvm_op(expr: &LLVMValueRef) -> LLVMOpType {
    if isa_bop(*expr) {
        return LLVMOpType::Bop;
    } else if isa_unop(*expr) {
        return LLVMOpType::Unop;
    } else if isa_constant(*expr) {
        return LLVMOpType::Constant;
    } else if isa_gep(*expr) {
        return LLVMOpType::Gep;
    } else if isa_load(*expr) {
        return LLVMOpType::Load;
    } else if isa_store(*expr) {
        return LLVMOpType::Store;
    } else if isa_argument(*expr) {
        return LLVMOpType::Argument;
    } else if isa_call(*expr) {
        return LLVMOpType::Call;
    } else if isa_fptrunc(*expr) {
        return LLVMOpType::FPTrunc;
    } else if isa_sitofp(*expr) {
        return LLVMOpType::SIToFP;
    } else if isa_bitcast(*expr) {
        return LLVMOpType::Bitcast;
    } else if isa_sqrt32(*expr) {
        return LLVMOpType::Sqrt32;
    } else if isa_sqrt64(*expr) {
        return LLVMOpType::Sqrt64;
    } else if isa_fpext(*expr) {
        return LLVMOpType::FPExt;
    } else {
        LLVMDumpValue(*expr);
        println!();
        panic!("ref_to_egg: Unmatched case for LLVMValueRef {:?}", *expr);
    }
}

unsafe fn choose_unop(unop: &LLVMValueRef, id: Id) -> VecLang {
    match LLVMGetInstructionOpcode(*unop) {
        LLVMFNeg => VecLang::Neg([id]),
        _ => panic!("Choose_Unop: Opcode Match Error"),
    }
}

unsafe fn arg_to_egg(
    expr: LLVMValueRef,
    mut enode_vec: Vec<VecLang>,
    next_idx: i32,
    _gep_map: &mut GEPMap,
    _store_map: &mut StoreMap,
    _id_map: &mut IdMap,
    symbol_map: &mut SymbolMap,
    _llvm_arg_pairs: &LLVMPairMap,
    _node_to_arg: &mut Vec<IntLLVMPair>,
) -> (Vec<VecLang>, i32) {
    let sym_name = gen_arg_name();
    let symbol = VecLang::Symbol(Symbol::from(sym_name));
    symbol_map.insert(symbol.clone(), expr);
    enode_vec.push(symbol);
    return (enode_vec, next_idx + 1);
}

unsafe fn bop_to_egg(
    expr: LLVMValueRef,
    enode_vec: Vec<VecLang>,
    next_idx: i32,
    gep_map: &mut GEPMap,
    store_map: &mut StoreMap,
    id_map: &mut IdMap,
    symbol_map: &mut SymbolMap,
    llvm_arg_pairs: &LLVMPairMap,
    node_to_arg: &mut Vec<IntLLVMPair>,
) -> (Vec<VecLang>, i32) {
    let left = LLVMGetOperand(expr, 0);
    let right = LLVMGetOperand(expr, 1);
    let (v1, next_idx1) = ref_to_egg(
        left,
        enode_vec,
        next_idx,
        gep_map,
        store_map,
        id_map,
        symbol_map,
        llvm_arg_pairs,
        node_to_arg,
    );
    let (mut v2, next_idx2) = ref_to_egg(
        right,
        v1,
        next_idx1,
        gep_map,
        store_map,
        id_map,
        symbol_map,
        llvm_arg_pairs,
        node_to_arg,
    );
    let ids = [
        Id::from((next_idx1 - 1) as usize),
        Id::from((next_idx2 - 1) as usize),
    ];
    v2.push(choose_binop(&expr, ids));
    (v2, next_idx2 + 1)
}

unsafe fn unop_to_egg(
    expr: LLVMValueRef,
    enode_vec: Vec<VecLang>,
    next_idx: i32,
    gep_map: &mut GEPMap,
    store_map: &mut StoreMap,
    id_map: &mut IdMap,
    symbol_map: &mut SymbolMap,
    llvm_arg_pairs: &LLVMPairMap,
    node_to_arg: &mut Vec<IntLLVMPair>,
) -> (Vec<VecLang>, i32) {
    let sub_expr = LLVMGetOperand(expr, 0);
    let (mut v, next_idx1) = ref_to_egg(
        sub_expr,
        enode_vec,
        next_idx,
        gep_map,
        store_map,
        id_map,
        symbol_map,
        llvm_arg_pairs,
        node_to_arg,
    );
    let id = Id::from((next_idx1 - 1) as usize);
    v.push(choose_unop(&expr, id));
    (v, next_idx1 + 1)
}

unsafe fn gep_to_egg(
    expr: LLVMValueRef,
    mut enode_vec: Vec<VecLang>,
    next_idx: i32,
    gep_map: &mut GEPMap,
    _store_map: &mut StoreMap,
    _id_map: &mut IdMap,
    _symbol_map: &mut SymbolMap,
    _llvm_arg_pairs: &LLVMPairMap,
    _node_to_arg: &mut Vec<IntLLVMPair>,
) -> (Vec<VecLang>, i32) {
    // // assert!(isa_argument(expr) || isa_gep(expr) || isa_load(expr));
    // let mut enode_vec = Vec::new();
    let array_name = CStr::from_ptr(llvm_name(expr)).to_str().unwrap();
    enode_vec.push(VecLang::Symbol(Symbol::from(array_name)));

    let num_gep_operands = LLVMGetNumOperands(expr);
    let mut indices = Vec::new();
    for operand_idx in 1..num_gep_operands {
        let array_offset = llvm_index(expr, operand_idx);
        indices.push(array_offset);
    }
    let offsets_string: String = indices.into_iter().map(|i| i.to_string() + ",").collect();
    let offsets_symbol = Symbol::from(&offsets_string);
    enode_vec.push(VecLang::Symbol(offsets_symbol));

    let get_node = VecLang::Get([
        Id::from((next_idx) as usize),
        Id::from((next_idx + 1) as usize),
    ]);
    (*gep_map).insert(
        (Symbol::from(array_name), Symbol::from(&offsets_string)),
        expr,
    );
    enode_vec.push(get_node);

    return (enode_vec, next_idx + 3);
}

unsafe fn _address_to_egg(
    expr: LLVMValueRef,
    mut enode_vec: Vec<VecLang>,
    next_idx: i32,
    gep_map: &mut GEPMap,
    _store_map: &mut StoreMap,
    _id_map: &mut IdMap,
    _symbol_map: &mut SymbolMap,
    _llvm_arg_pairs: &LLVMPairMap,
    _node_to_arg: &mut Vec<IntLLVMPair>,
) -> (Vec<VecLang>, i32) {
    let array_name = CStr::from_ptr(llvm_name(expr)).to_str().unwrap();
    enode_vec.push(VecLang::Symbol(Symbol::from(array_name)));

    let num_gep_operands = LLVMGetNumOperands(expr);
    let mut indices = Vec::new();
    for operand_idx in 1..num_gep_operands {
        let array_offset = llvm_index(expr, operand_idx);
        indices.push(array_offset);
    }
    let offsets_string: String = indices.into_iter().map(|i| i.to_string() + ",").collect();
    let offsets_symbol = Symbol::from(&offsets_string);
    enode_vec.push(VecLang::Symbol(offsets_symbol));

    let get_node = VecLang::Get([
        Id::from((next_idx) as usize),
        Id::from((next_idx + 1) as usize),
    ]);
    (*gep_map).insert(
        (Symbol::from(array_name), Symbol::from(&offsets_string)),
        expr,
    );
    enode_vec.push(get_node);

    return (enode_vec, next_idx + 3);
}

unsafe fn sitofp_to_egg(
    expr: LLVMValueRef,
    mut enode_vec: Vec<VecLang>,
    next_idx: i32,
    gep_map: &mut GEPMap,
    _store_map: &mut StoreMap,
    _id_map: &mut IdMap,
    _symbol_map: &mut SymbolMap,
    _llvm_arg_pairs: &LLVMPairMap,
    _node_to_arg: &mut Vec<IntLLVMPair>,
) -> (Vec<VecLang>, i32) {
    let array_name = CStr::from_ptr(llvm_name(expr)).to_str().unwrap();
    enode_vec.push(VecLang::Symbol(Symbol::from(array_name)));

    let num_gep_operands = LLVMGetNumOperands(expr);
    let mut indices = Vec::new();
    for operand_idx in 1..num_gep_operands {
        let array_offset = llvm_index(expr, operand_idx);
        indices.push(array_offset);
    }
    let offsets_string: String = indices.into_iter().map(|i| i.to_string() + ",").collect();
    let offsets_symbol = Symbol::from(&offsets_string);
    enode_vec.push(VecLang::Symbol(offsets_symbol));

    let get_node = VecLang::Get([
        Id::from((next_idx) as usize),
        Id::from((next_idx + 1) as usize),
    ]);
    (*gep_map).insert(
        (Symbol::from(array_name), Symbol::from(&offsets_string)),
        expr,
    );
    enode_vec.push(get_node);

    return (enode_vec, next_idx + 3);
}

unsafe fn load_to_egg(
    expr: LLVMValueRef,
    enode_vec: Vec<VecLang>,
    next_idx: i32,
    gep_map: &mut GEPMap,
    store_map: &mut StoreMap,
    id_map: &mut IdMap,
    symbol_map: &mut SymbolMap,
    llvm_arg_pairs: &LLVMPairMap,
    node_to_arg: &mut Vec<IntLLVMPair>,
) -> (Vec<VecLang>, i32) {
    return gep_to_egg(
        expr, // we pass the entire instruction and not just the address
        enode_vec,
        next_idx,
        gep_map,
        store_map,
        id_map,
        symbol_map,
        llvm_arg_pairs,
        node_to_arg,
    );
}

unsafe fn store_to_egg(
    expr: LLVMValueRef,
    enode_vec: Vec<VecLang>,
    next_idx: i32,
    gep_map: &mut GEPMap,
    store_map: &mut StoreMap,
    id_map: &mut IdMap,
    symbol_map: &mut SymbolMap,
    llvm_arg_pairs: &LLVMPairMap,
    node_to_arg: &mut Vec<IntLLVMPair>,
) -> (Vec<VecLang>, i32) {
    let data = LLVMGetOperand(expr, 0);
    let addr = LLVMGetOperand(expr, 1); // expected to be a gep operator or addr in LLVM
    let (vec, next_idx1) = ref_to_egg(
        data,
        enode_vec,
        next_idx,
        gep_map,
        store_map,
        id_map,
        symbol_map,
        llvm_arg_pairs,
        node_to_arg,
    );
    (*store_map).insert(next_idx1 - 1, addr);
    (*id_map).insert(Id::from((next_idx1 - 1) as usize));
    return (vec, next_idx1);
}

unsafe fn const_to_egg(
    expr: LLVMValueRef,
    mut enode_vec: Vec<VecLang>,
    next_idx: i32,
    _gep_map: &mut GEPMap,
    _store_map: &mut StoreMap,
    _id_map: &mut IdMap,
    _symbol_map: &mut SymbolMap,
    _llvm_arg_pairs: &LLVMPairMap,
    _node_to_arg: &mut Vec<IntLLVMPair>,
) -> (Vec<VecLang>, i32) {
    let value = get_constant_float(expr);
    enode_vec.push(VecLang::Num(value as i32));
    (enode_vec, next_idx + 1)
}

unsafe fn _load_arg_to_egg(
    expr: LLVMValueRef,
    mut enode_vec: Vec<VecLang>,
    next_idx: i32,
    gep_map: &mut GEPMap,
    _store_map: &mut StoreMap,
    _id_map: &mut IdMap,
    _symbol_map: &mut SymbolMap,
    _llvm_arg_pairs: &LLVMPairMap,
    _node_to_arg: &mut Vec<IntLLVMPair>,
) -> (Vec<VecLang>, i32) {
    // assert!(isa_argument(expr) || isa_gep(expr));
    let array_name = CStr::from_ptr(llvm_name(expr)).to_str().unwrap();
    enode_vec.push(VecLang::Symbol(Symbol::from(array_name)));

    let num_gep_operands = LLVMGetNumOperands(expr);
    let mut indices = Vec::new();
    for operand_idx in 1..num_gep_operands {
        let array_offset = llvm_index(expr, operand_idx);
        indices.push(array_offset);
    }
    let offsets_string: String = indices.into_iter().map(|i| i.to_string() + ",").collect();
    let offsets_symbol = Symbol::from(&offsets_string);
    enode_vec.push(VecLang::Symbol(offsets_symbol));

    let get_node = VecLang::Get([
        Id::from((next_idx) as usize),
        Id::from((next_idx + 1) as usize),
    ]);
    (*gep_map).insert(
        (Symbol::from(array_name), Symbol::from(&offsets_string)),
        expr,
    );
    enode_vec.push(get_node);

    return (enode_vec, next_idx + 3);
}

unsafe fn load_call_to_egg(
    expr: LLVMValueRef,
    mut enode_vec: Vec<VecLang>,
    next_idx: i32,
    gep_map: &mut GEPMap,
    store_map: &mut StoreMap,
    id_map: &mut IdMap,
    symbol_map: &mut SymbolMap,
    llvm_arg_pairs: &LLVMPairMap,
    node_to_arg: &mut Vec<IntLLVMPair>,
) -> (Vec<VecLang>, i32) {
    if isa_sqrt32(expr) {
        return sqrt32_to_egg(
            expr,
            enode_vec,
            next_idx,
            gep_map,
            store_map,
            id_map,
            symbol_map,
            llvm_arg_pairs,
            node_to_arg,
        );
    }
    let call_sym_name = gen_call_name();
    let call_sym = VecLang::Symbol(Symbol::from(call_sym_name));
    symbol_map.insert(call_sym.clone(), expr);
    enode_vec.push(call_sym);
    return (enode_vec, next_idx + 1);
}

unsafe fn fpext_to_egg(
    expr: LLVMValueRef,
    enode_vec: Vec<VecLang>,
    next_idx: i32,
    gep_map: &mut GEPMap,
    store_map: &mut StoreMap,
    id_map: &mut IdMap,
    symbol_map: &mut SymbolMap,
    llvm_arg_pairs: &LLVMPairMap,
    node_to_arg: &mut Vec<IntLLVMPair>,
) -> (Vec<VecLang>, i32) {
    // assert!(isa_fpext(expr));
    let operand = LLVMGetOperand(expr, 0);
    return ref_to_egg(
        operand,
        enode_vec,
        next_idx,
        gep_map,
        store_map,
        id_map,
        symbol_map,
        llvm_arg_pairs,
        node_to_arg,
    );
}

unsafe fn sqrt32_to_egg(
    expr: LLVMValueRef,
    enode_vec: Vec<VecLang>,
    next_idx: i32,
    gep_map: &mut GEPMap,
    store_map: &mut StoreMap,
    id_map: &mut IdMap,
    symbol_map: &mut SymbolMap,
    llvm_arg_pairs: &LLVMPairMap,
    node_to_arg: &mut Vec<IntLLVMPair>,
) -> (Vec<VecLang>, i32) {
    // assert!(isa_sqrt32(expr));
    let operand = LLVMGetOperand(expr, 0);
    let (mut new_enode_vec, next_idx1) = ref_to_egg(
        operand,
        enode_vec,
        next_idx,
        gep_map,
        store_map,
        id_map,
        symbol_map,
        llvm_arg_pairs,
        node_to_arg,
    );
    let sqrt_node = VecLang::Sqrt([Id::from((next_idx1 - 1) as usize)]);
    new_enode_vec.push(sqrt_node);
    return (new_enode_vec, next_idx1 + 1);
}

unsafe fn sqrt64_to_egg(
    _expr: LLVMValueRef,
    _enode_vec: Vec<VecLang>,
    _next_idx: i32,
    _gep_map: &mut GEPMap,
    _store_map: &mut StoreMap,
    _id_map: &mut IdMap,
    _symbol_map: &mut SymbolMap,
    _llvm_arg_pairs: &LLVMPairMap,
    _node_to_arg: &mut Vec<IntLLVMPair>,
) -> (Vec<VecLang>, i32) {
    // assert!(isa_sqrt64(expr));
    panic!("Currently, we do not handle calls to sqrt.f64 without fpext and fptrunc before and after!. This is the only 'context sensitive' instance in the dispatch matching. ")
}

unsafe fn fptrunc_to_egg(
    expr: LLVMValueRef,
    enode_vec: Vec<VecLang>,
    next_idx: i32,
    gep_map: &mut GEPMap,
    store_map: &mut StoreMap,
    id_map: &mut IdMap,
    symbol_map: &mut SymbolMap,
    llvm_arg_pairs: &LLVMPairMap,
    node_to_arg: &mut Vec<IntLLVMPair>,
) -> (Vec<VecLang>, i32) {
    // assert!(isa_fptrunc(expr));
    let operand = LLVMGetOperand(expr, 0);
    if isa_sqrt64(operand) {
        return sqrt64_to_egg(
            operand,
            enode_vec,
            next_idx,
            gep_map,
            store_map,
            id_map,
            symbol_map,
            llvm_arg_pairs,
            node_to_arg,
        );
    }
    return ref_to_egg(
        operand,
        enode_vec,
        next_idx,
        gep_map,
        store_map,
        id_map,
        symbol_map,
        llvm_arg_pairs,
        node_to_arg,
    );
}

unsafe fn bitcast_to_egg(
    expr: LLVMValueRef,
    enode_vec: Vec<VecLang>,
    next_idx: i32,
    gep_map: &mut GEPMap,
    store_map: &mut StoreMap,
    id_map: &mut IdMap,
    symbol_map: &mut SymbolMap,
    llvm_arg_pairs: &LLVMPairMap,
    node_to_arg: &mut Vec<IntLLVMPair>,
) -> (Vec<VecLang>, i32) {
    // assert!(isa_bitcast(expr));
    let operand = LLVMGetOperand(expr, 0);
    let result = ref_to_egg(
        operand,
        enode_vec,
        next_idx,
        gep_map,
        store_map,
        id_map,
        symbol_map,
        llvm_arg_pairs,
        node_to_arg,
    );
    return result;
}

unsafe fn ref_to_egg(
    expr: LLVMValueRef,
    mut enode_vec: Vec<VecLang>,
    next_idx: i32,
    gep_map: &mut GEPMap,
    store_map: &mut StoreMap,
    id_map: &mut IdMap,
    symbol_map: &mut SymbolMap,
    llvm_arg_pairs: &LLVMPairMap,
    node_to_arg: &mut Vec<IntLLVMPair>,
) -> (Vec<VecLang>, i32) {
    for (original_val, _) in llvm_arg_pairs.iter() {
        if cmp_val_ref_address(&**original_val, &*expr) {
            // Here we create a new numbered variable node
            let var_idx = gen_node_idx();
            let var_idx_str = var_idx.to_string();
            let special_var_node = VecLang::Symbol(Symbol::from(var_idx_str));
            enode_vec.push(special_var_node);
            let node_to_arg_pair = IntLLVMPair {
                arg: expr,
                node_int: var_idx,
            };
            node_to_arg.push(node_to_arg_pair);
            return (enode_vec, next_idx + 1);
        }
    }
    let (vec, next_idx) = match match_llvm_op(&expr) {
        LLVMOpType::Bop => bop_to_egg(
            expr,
            enode_vec,
            next_idx,
            gep_map,
            store_map,
            id_map,
            symbol_map,
            llvm_arg_pairs,
            node_to_arg,
        ),
        LLVMOpType::Unop => unop_to_egg(
            expr,
            enode_vec,
            next_idx,
            gep_map,
            store_map,
            id_map,
            symbol_map,
            llvm_arg_pairs,
            node_to_arg,
        ),
        LLVMOpType::Constant => const_to_egg(
            expr,
            enode_vec,
            next_idx,
            gep_map,
            store_map,
            id_map,
            symbol_map,
            llvm_arg_pairs,
            node_to_arg,
        ),
        LLVMOpType::Gep => gep_to_egg(
            expr,
            enode_vec,
            next_idx,
            gep_map,
            store_map,
            id_map,
            symbol_map,
            llvm_arg_pairs,
            node_to_arg,
        ),
        LLVMOpType::Load => load_to_egg(
            expr,
            enode_vec,
            next_idx,
            gep_map,
            store_map,
            id_map,
            symbol_map,
            llvm_arg_pairs,
            node_to_arg,
        ),
        LLVMOpType::Store => store_to_egg(
            expr,
            enode_vec,
            next_idx,
            gep_map,
            store_map,
            id_map,
            symbol_map,
            llvm_arg_pairs,
            node_to_arg,
        ),
        LLVMOpType::Argument => arg_to_egg(
            expr,
            enode_vec,
            next_idx,
            gep_map,
            store_map,
            id_map,
            symbol_map,
            llvm_arg_pairs,
            node_to_arg,
        ),
        LLVMOpType::Call => load_call_to_egg(
            expr,
            enode_vec,
            next_idx,
            gep_map,
            store_map,
            id_map,
            symbol_map,
            llvm_arg_pairs,
            node_to_arg,
        ),
        LLVMOpType::FPTrunc => fptrunc_to_egg(
            expr,
            enode_vec,
            next_idx,
            gep_map,
            store_map,
            id_map,
            symbol_map,
            llvm_arg_pairs,
            node_to_arg,
        ),
        LLVMOpType::FPExt => fpext_to_egg(
            expr,
            enode_vec,
            next_idx,
            gep_map,
            store_map,
            id_map,
            symbol_map,
            llvm_arg_pairs,
            node_to_arg,
        ),
        LLVMOpType::SIToFP => sitofp_to_egg(
            expr,
            enode_vec,
            next_idx,
            gep_map,
            store_map,
            id_map,
            symbol_map,
            llvm_arg_pairs,
            node_to_arg,
        ),
        LLVMOpType::Bitcast => bitcast_to_egg(
            expr,
            enode_vec,
            next_idx,
            gep_map,
            store_map,
            id_map,
            symbol_map,
            llvm_arg_pairs,
            node_to_arg,
        ),
        LLVMOpType::Sqrt32 => sqrt32_to_egg(
            expr,
            enode_vec,
            next_idx,
            gep_map,
            store_map,
            id_map,
            symbol_map,
            llvm_arg_pairs,
            node_to_arg,
        ),
        LLVMOpType::Sqrt64 => sqrt64_to_egg(
            expr,
            enode_vec,
            next_idx,
            gep_map,
            store_map,
            id_map,
            symbol_map,
            llvm_arg_pairs,
            node_to_arg,
        ),
    };
    return (vec, next_idx);
}

struct LLVM2EggState {
    llvm2egg: &BTreeMap<LLVMValueRef, VecLang>,
}

unsafe fn ref_to_egg(
    llvm_instr: LLVMValueRef,
    next_node_idx: i64,
    mut egg_nodes: Vec<VecLang>,
    mut translation_metadata: LLVM2EggState,
) -> Vec<VecLang> {
    if (translation_metadata.llvm2egg.contains_key(llvm_instr)) {
        let translated_egg_node = translation_metadata
            .llvm2egg
            .get(llvm_instr)
            .expect("Key must exist");
        egg_nodes.push(translated_egg_node);
        return (egg_nodes, next_node_idx + 1);
    }
    panic!("Unimplemented");
}

unsafe fn llvm_to_egg(llvm_instrs_in_chunk: &[LLVMValueRef]) -> RecExpr<VecLang> {
    let mut egg_nodes: Vec<VecLang> = Vec::new();

    // Map from (translated) llvm instructions to egg graph nodes
    let mut llvm_instr2egg_node: BTreeMap<LLVMValueRef, VecLang> = BTreeMap::new();

    // State Variable To Hold Maps During Translation
    let mut llvm2egg_state = LLVM2EggState {
        llvm2egg: llvm_instr2egg_node,
    };

    // Index of next node to translate
    let mut next_node_idx: i64 = 0;

    // for each store, iterate backwards from that store and translate to egg
    for llvm_instr in llvm_instrs_in_chunk.iter() {
        if isa_store(*llvm_instr) {
            ref_to_egg()
        }
    }

    panic!("Unimplemented");
}

unsafe fn llvm_to_egg<'a>(
    bb_vec: &[LLVMValueRef],
    llvm_arg_pairs: &mut LLVMPairMap,
    node_to_arg: &mut Vec<IntLLVMPair>,
) -> (RecExpr<VecLang>, GEPMap, StoreMap, SymbolMap) {
    let mut enode_vec = Vec::new();
    let (mut gep_map, mut store_map, mut id_map, mut symbol_map) = (
        BTreeMap::new(),
        BTreeMap::new(),
        BTreeSet::new(),
        BTreeMap::new(),
    );
    let mut next_idx = 0;
    for bop in bb_vec.iter() {
        if isa_store(*bop) {
            let (new_enode_vec, next_idx1) = ref_to_egg(
                *bop,
                enode_vec,
                next_idx,
                &mut gep_map,
                &mut store_map,
                &mut id_map,
                &mut symbol_map,
                llvm_arg_pairs,
                node_to_arg,
            );
            next_idx = next_idx1;
            enode_vec = new_enode_vec;
        }
    }
    let mut final_vec = Vec::new();
    for id in id_map.iter() {
        final_vec.push(*id);
    }
    balanced_pad_vector(&mut final_vec, &mut enode_vec);

    let rec_expr = RecExpr::from(enode_vec);
    (rec_expr, gep_map, store_map, symbol_map)
}
