use itertools::Itertools;
use std::collections::HashMap;
use std::io::{self, Read};

/// Transforms a named location in an array to a Get expressions.
/// For example, the name A$13 is transformed into (Get A 13).
fn to_value(v: lexpr::Value, erase: bool) -> lexpr::Value {
    if let lexpr::Value::String(s) = v {
        let mut split = s.split("$").collect::<Vec<_>>();
        let (pre, idx) = (split.remove(0), split.remove(1));
        if !erase {
            lexpr::Value::list(vec!["Get", pre, idx])
        } else {
            pre.into()
        }
    } else {
        panic!("Passed a non-string value to to_value");
    }
}

/// Performs transformations required to produce valid egg-dsl specs from
/// a given vec-dsl spec.
fn to_egg(expr: lexpr::Value, erase: bool, rewrites: &HashMap<&str, &str>) -> lexpr::Value {
    match expr {
        lexpr::Value::Number(_) => expr,
        lexpr::Value::String(_) => to_value(expr, erase),
        lexpr::Value::Cons(c) => {
            if let (lexpr::Value::String(head), lexpr::Value::Cons(tail)) = c.into_pair() {
                if &*head == "box" {
                    let (mut t, _) = tail.into_vec();
                    assert!(t.len() == 1, "Boxed value had more than one element");
                    return to_egg(t.remove(0), erase, rewrites);
                } else if &*head == "app" {
                    return to_egg(tail.into(), erase, rewrites);
                } else {
                    // Early return if this is a simple list
                    let mut children = tail
                        .into_vec()
                        .0
                        .into_iter()
                        .map(|v| to_egg(v, erase, rewrites))
                        .collect_vec();
                    if &*head == "list" && children.len() < 3 {
                        return lexpr::Value::cons(head, lexpr::Value::from(children));
                    }

                    // The operator name might need to change
                    let op = rewrites.get(&*head).unwrap_or(&&*head).clone();
                    // Rewrite all the children in the list.
                    children.reverse();
                    children
                        .into_iter()
                        .fold1(|x, y| lexpr::Value::cons(op, lexpr::Value::cons(x, y)))
                        .unwrap()
                }
            } else {
                panic!("Head of a list was not a string")
            }
        },
        _ => panic!("Unexpected lexpr value")
    }
}

fn main() -> io::Result<()> {
    let mut buffer = String::new();
    // Read the string provided on STDIN.
    io::stdin().read_to_string(&mut buffer)?;
    // Parse the given S-expr
    let v = lexpr::from_str(&buffer)?;
    println!("{}", v.to_string());
    Ok(())
}
