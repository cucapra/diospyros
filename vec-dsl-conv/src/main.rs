use itertools::Itertools;
use std::collections::HashMap;
use std::io::{self, Read};

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
        lexpr::Value::Symbol(s) => to_value(&*s, erase),
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
                    let op = lexpr::Value::symbol(rewrites.get(&*head).unwrap_or(&&*head).clone());
                    // Early return if this is a simple list
                    let mut children = tail
                        .into_vec()
                        .0
                        .into_iter()
                        .map(|v| to_egg(v, erase, rewrites))
                        .collect_vec();
                    if &*head == "list" || children.len() < 3 {
                        let mut list = vec![op];
                        list.append(&mut children);
                        return lexpr::Value::list(list);
                    }
                    // Rewrite all the children in the list.
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

fn preprocess_egg_to_vecs(expr: lexpr::Value, width: usize) -> lexpr::Value {
    if let lexpr::Value::Cons(c) = expr {
        let (mut list, _) = c.into_vec();
        // Remove the "list" from the start of the vec.
        list.remove(0);
        let mut concats = list
            .into_iter()
            .chunks(width)
            .into_iter()
            .map(|c| {
                let mut chunk = c.into_iter().collect_vec();
                if chunk.len() == width {
                    chunk.insert(0, lexpr::Value::symbol("Vec"));
                } else {
                    chunk.insert(0, lexpr::Value::symbol("list"));
                };
                lexpr::Value::list(chunk)
            })
            .collect_vec();
        let init = concats.remove(0);
        concats.into_iter().fold(init, |acc, x| {
            lexpr::Value::list(vec![lexpr::Value::symbol("Concat"), x, acc])
        })
    } else {
        panic!("Cannot pre-process non-list s-expression.")
    }
}

fn main() -> io::Result<()> {
    let mut buffer = String::new();
    // Read the string provided on STDIN.
    io::stdin().read_to_string(&mut buffer)?;
    // Parse the given S-expr
    let v = lexpr::from_str(&buffer)?;
    // Rewrite specifications
    let mut rewrites = HashMap::new();
    rewrites.insert("list", "List");
    let x = preprocess_egg_to_vecs(v, 2);
    println!("{}", to_egg(x, false, &rewrites));
    Ok(())
}
