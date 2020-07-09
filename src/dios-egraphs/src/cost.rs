use egg::{*};

use crate::{
    veclang::{VecLang},
};

pub struct VecCostFn;
impl CostFunction<VecLang> for VecCostFn {
    type Cost = f64;
    // you're passed in an enode whose children are costs instead of eclass ids
    fn cost<C>(&mut self, enode: &VecLang, mut costs: C) -> Self::Cost
    where
        C: FnMut(Id) -> Self::Cost,
    {
        const BIG: f64 = 100.0;
        const LITERAL: f64 = 0.001;
        const STRUCTURE: f64 = 0.1;
        const OP: f64 = 1.;
        let op_cost = match enode {
            // You get literals for extremely cheap
            VecLang::Num(..) => LITERAL,
            VecLang::Symbol(..) => LITERAL,

            // And list structures for quite cheap
            VecLang::List(..) => STRUCTURE,
            VecLang::Concat(..) => STRUCTURE,

            // Vectors are cheap if they have literal values
            VecLang::Vec4(vals) => {
                let non_literals = vals.iter().any(|&x| costs(x) > LITERAL);
                if non_literals {BIG} else {STRUCTURE}
            },

            // But scalar and vector ops cost something
            VecLang::Add(..) => OP,
            VecLang::Mul(..) => OP,

            VecLang::VecAdd(..) => OP,
            VecLang::VecMul(..) => OP,
            VecLang::VecMAC(..) => OP,
        };
        enode.fold(op_cost, |sum, id| sum + costs(id))
    }
}