use itertools::Itertools;
use std::collections::HashMap;
use std::io::{self};

/// Transforms a named location in an array to a Get expressions.
/// For example, the name A$13 is transformed into (Get A 13).
fn to_value(s: &str, erase: bool) -> lexpr::Value {
    let mut split = s.split("$").collect::<Vec<_>>();
    assert!(split.len() == 2, "Failed to split symbol: {}", s);
    let (pre, idx) = (split.remove(0), split.remove(0));
    if !erase {
        lexpr::Value::list(vec![
            lexpr::Value::symbol("Get"),
            lexpr::Value::symbol(pre),
            lexpr::Value::Number(idx.parse::<u64>().unwrap().into()),
        ])
    } else {
        lexpr::Value::Symbol(pre.into())
    }
}

/// Performs transformations required to produce valid egg-dsl specs from
/// a given vec-dsl spec.
fn to_egg(expr: lexpr::Value, erase: bool, rewrites: &HashMap<&str, &str>) -> lexpr::Value {
    match expr {
        lexpr::Value::Number(_) => expr,
        lexpr::Value::Symbol(s) => {
            if s.contains("$") {
                to_value(&*s, erase)
            } else {
                lexpr::Value::Symbol(s)
            }
        }
        lexpr::Value::Cons(c) => {
            if let (lexpr::Value::Symbol(head), lexpr::Value::Cons(tail)) = c.into_pair() {
                if &*head == "box" {
                    let (mut t, _) = tail.into_vec();
                    assert!(t.len() == 1, "Boxed value had more than one element");
                    return to_egg(t.remove(0), erase, rewrites);
                } else if &*head == "app" {
                    return to_egg(tail.into(), erase, rewrites);
                } else {
                    // The operator name might need to change
                    let mut op =
                        lexpr::Value::symbol(rewrites.get(&*head).unwrap_or(&&*head).clone());
                    let mut children = tail
                        .into_vec()
                        .0
                        .into_iter()
                        .map(|v| to_egg(v, erase, rewrites))
                        .collect_vec();

                    // Early return if this is a simple list, vec, or already
                    // a binary operation
                    if let lexpr::Value::Symbol(op_str) = op.clone() {
                        if &*op_str == "List"
                            || &*op_str == "Vec"
                            || children.len() < 3
                            || (&*head == "ite" &&  children.len() == 3) {
                            // Special case: (- a) -> (neg a)
                            if &*head == "-" && children.len() == 1 {
                                op = lexpr::Value::symbol("neg")
                            }
                            if &*head == "!" && children.len() == 1 {
                                op = lexpr::Value::symbol("neg")
                            }
                            let mut list = vec![op];
                            list.append(&mut children);
                            return lexpr::Value::list(list);
                        }
                    }

                    // Otherwise, turn variadic operations into binary ones
                    children.reverse();
                    let init = children.remove(0);
                    children
                        .into_iter()
                        .fold(init, |acc, x| lexpr::Value::list(vec![op.clone(), x, acc]))
                }
            } else {
                panic!("Head of a list was not a string")
            }
        }
        v => panic!("Unexpected lexpr value: {}", v),
    }
}

pub fn convert_string(input: &String) -> io::Result<String> {
    // Parse the given S-expr
    // Remove residual Racket syntax markers
    let input = input.replace("#&", "");
    let input = input.replace("'(", "(list ");
    let input = input.replace("||", "or");
    let input = input.replace("'", "");
    let v = lexpr::from_str(&input)?;
    // Rewrite specifications
    let mut rewrites = HashMap::new();
    rewrites.insert("list", "List");
    let egg = to_egg(v, false, &rewrites);
    lexpr::to_string(&egg)
}
