use egg::{*};

use crate::{
    veclang::{EGraph, VecLang},
};

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
        const OP: f64 = 1.;
        const BIG: f64 = 100.0;
        let op_cost = match enode {
            // You get literals for extremely cheap
            VecLang::Num(..) => LITERAL,
            VecLang::Symbol(..) => LITERAL,
            VecLang::Get(..) => LITERAL,

            // And list structures for quite cheap
            VecLang::List(..) => STRUCTURE,
            VecLang::Concat(..) => STRUCTURE,

            // Vectors are cheap if they have literal values
            VecLang::Vec4(vals) => {
                // For now, workaround to determine if children are num, symbol,
                // or get
                let non_literals = vals.iter().any(|&x| costs(x) > 3.*LITERAL);
                if non_literals {BIG} else {STRUCTURE}
            },
            VecLang::LitVec4(..) => LITERAL,

            // But scalar and vector ops cost something
            VecLang::Add(vals) =>  BIG * (vals.iter().count() as f64 - 1.),
            VecLang::Mul(vals) => BIG * (vals.iter().count() as f64 - 1.),

            VecLang::VecAdd(..) => OP,
            VecLang::VecMul(..) => OP,
            VecLang::VecMAC(..) => OP,
            _ => OP,
        };
        enode.fold(op_cost, |sum, id| sum + costs(id))
    }
}