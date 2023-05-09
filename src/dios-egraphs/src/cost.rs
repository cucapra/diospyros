use egg::*;

use crate::veclang::{EGraph, VecLang};

pub struct VecCostFn<'a> {
    pub egraph: &'a EGraph,
}

// &'a EGraph
impl CostFunction<VecLang> for VecCostFn<'_> {
    type Cost = f64;
    // you're passed in an enode whose children are costs instead of eclass ids
    fn cost<C>(&mut self, enode: &VecLang, mut costs: C) -> Self::Cost
    where
        C: FnMut(Id) -> Self::Cost,
    {
        const NO_OPTIMIZATION: f64 = 0.0;
        const VECTORIZED_MEMORY_ACCESS: f64 = 0.0001;
        const LITERAL: f64 = 0.001;
        const STRUCTURE: f64 = 0.1;
        const VEC_OP: f64 = 1.;
        const OP: f64 = 1.;
        const BIG: f64 = 100.0;
        let op_cost = match enode {
            // No Optimization case for testing purposes
            VecLang::NoOptVec(..) => NO_OPTIMIZATION,

            // Vectorized Memory Accesses are cheaper than individual memory loads and stores
            // Note: This assumes that masked-gathers or masked-scattters to vectors or memory
            // are implemented on the target, and are cheap, according to the LLVM cost model
            VecLang::AlignedConsecVecLoad(..) => VECTORIZED_MEMORY_ACCESS,
            VecLang::VecLoad(..) => VECTORIZED_MEMORY_ACCESS,
            VecLang::VecStore(..) => VECTORIZED_MEMORY_ACCESS,

            // You get literals for extremely cheap
            VecLang::Num(..) => LITERAL,
            VecLang::Reg(..) => LITERAL,
            VecLang::Arg(..) => LITERAL,
            VecLang::Symbol(..) => LITERAL,
            VecLang::Get(..) => LITERAL,
            VecLang::Set(..) => LITERAL,
            VecLang::Load(..) => LITERAL,
            VecLang::Store(..) => LITERAL,
            VecLang::Gep(..) => LITERAL,

            // And list structures for quite cheap
            VecLang::List(..) => STRUCTURE,
            VecLang::Concat(..) => STRUCTURE,

            // Vectors are cheap if they have literal values
            VecLang::Vec(vals) => {
                // For now, workaround to determine if children are num, symbol,
                // or get
                let non_literals = vals.iter().any(|&x| costs(x) > 3. * LITERAL);
                if non_literals {
                    BIG
                } else {
                    STRUCTURE
                }
            }
            VecLang::LitVec(..) => LITERAL,

            // But scalar and vector ops cost something
            VecLang::Add(vals) => OP * (vals.iter().count() as f64 - 1.),
            VecLang::Mul(vals) => OP * (vals.iter().count() as f64 - 1.),
            VecLang::Minus(vals) => OP * (vals.iter().count() as f64 - 1.),
            VecLang::Div(vals) => OP * (vals.iter().count() as f64 - 1.),

            VecLang::Sgn(..) => OP,
            VecLang::Neg(..) => OP,
            VecLang::Sqrt(..) => OP,

            VecLang::VecAdd(..) => VEC_OP,
            VecLang::VecMinus(..) => VEC_OP,
            VecLang::VecMul(..) => VEC_OP,
            VecLang::VecMAC(..) => VEC_OP,
            VecLang::VecDiv(..) => VEC_OP,
            VecLang::VecNeg(..) => VEC_OP,
            VecLang::VecSqrt(..) => VEC_OP,
            VecLang::VecSgn(..) => VEC_OP,
            _ => VEC_OP,
        };
        enode.fold(op_cost, |sum, id| sum + costs(id))
    }
}
