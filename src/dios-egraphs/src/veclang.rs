use egg::{*};

define_language! {
    pub enum VecLang {
        Num(i32),

        // Id is a key to identify EClasses within an EGraph, represents
        // children nodes
        "+" = Add(Box<[Id]>),
        "*" = Mul(Box<[Id]>),

        // Lists have a variable number of elements
        "List" = List(Box<[Id]>),

        // Vectors have 4 elements
        "Vec4" = Vec4([Id; 4]),

        // Used for partitioning and recombining lists
        "Concat" = Concat([Id; 2]),

        // Vector operations that take 2 vectors of inputs
        "VecAdd" = VecAdd([Id; 2]),
        "VecMul" = VecMul([Id; 2]),

        // MAC takes 3 lists: acc, v1, v2
        "VecMAC" = VecMAC([Id; 3]),

        // language items are parsed in order, and we want symbol to
        // be a fallback, so we put it last.
        // `Symbol` is an egg-provided interned string type
        Symbol(egg::Symbol),
    }
}


pub type EGraph = egg::EGraph<VecLang, VecLangAnalysis>;

#[derive(Default)]
pub struct VecLangAnalysis;

#[derive(Debug)]
pub struct Data {
}

impl Analysis<VecLang> for VecLangAnalysis {
    type Data = Data;
    fn merge(&self, _to: &mut Data, _from: Data) -> bool {
        false
    }

    fn make(_egraph: &EGraph, _enode: &VecLang) -> Data {
        Data { }
    }
}