use egg::*;

define_language! {
    pub enum VecLang {
        Num(i32),

        // Register points to other computation, denoted by a number
        Reg(u32),

        // Argument points to a argument, denoted by a number
        Arg(u32),

        // Id is a key to identify EClasses within an EGraph, represents
        // children nodes
        "+" = Add([Id; 2]),
        "*" = Mul([Id; 2]),
        "-" = Minus([Id; 2]),
        "/" = Div([Id; 2]),

        "or" = Or([Id; 2]),
        "&&" = And([Id; 2]),
        "ite" = Ite([Id; 3]),
        "<" = Lt([Id; 2]),

        "sgn" = Sgn([Id; 1]),
        "sqrt" = Sqrt([Id; 1]),
        "neg" = Neg([Id; 1]),

        // Lists have a variable number of elements
        "List" = List(Box<[Id]>),

        // Vectors have width elements
        "Vec" = Vec(Box<[Id]>),

        // Vectors have width elements, not to be optimized (for testing purposes)
        "NoOptVec" = NoOptVec(Box<[Id]>),

        // Vector with all literals
        "LitVec" = LitVec(Box<[Id]>),

        "Get" = Get([Id; 2]),

        // Used for partitioning and recombining lists
        "Concat" = Concat([Id; 2]),

        // Vector operations that take 2 vectors of inputs
        "VecAdd" = VecAdd([Id; 2]),
        "VecMinus" = VecMinus([Id; 2]),
        "VecMul" = VecMul([Id; 2]),
        "VecDiv" = VecDiv([Id; 2]),
        // "VecMulSgn" = VecMulSgn([Id; 2]),

        // Vector operations that take 1 vector of inputs
        "VecNeg" = VecNeg([Id; 1]),
        "VecSqrt" = VecSqrt([Id; 1]),
        "VecSgn" = VecSgn([Id; 1]),

        // MAC takes 3 lists: acc, v1, v2
        "VecMAC" = VecMAC([Id; 3]),

        // Info specific to register
        // RegInfo(egg::Symbol),

        // language items are parsed in order, and we want symbol to
        // be a fallback, so we put it last.
        // `Symbol` is an egg-provided interned string type
        Symbol(egg::Symbol),
    }
}

pub type EGraph = egg::EGraph<VecLang, ()>;
