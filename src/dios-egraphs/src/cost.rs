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
        const LITERAL: f64 = 0.001;
        const STRUCTURE: f64 = 0.1;
        const VEC_OP: f64 = 1.;
        const OP: f64 = 1.;
        const BIG: f64 = 10.;
        let op_cost = match enode {
            // You get literals for extremely cheap
            VecLang::Num(..) => LITERAL,
            VecLang::Symbol(..) => LITERAL,
            VecLang::Get(..) => LITERAL,

            // And list structures for quite cheap
            VecLang::List(..) => BIG,
            VecLang::Concat(..) => STRUCTURE,

            // Vectors are just structures if they can't compile to shuffles
            VecLang::Vec(..) => STRUCTURE,

            // LitVecs are general, arbitrary-index shuffles
            VecLang::LitVec(..) => LITERAL * 2.,

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
        };
        enode.fold(op_cost, |sum, id| sum + costs(id))
    }
}
