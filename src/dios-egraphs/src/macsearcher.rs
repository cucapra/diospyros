use egg::{*};

#[derive(Debug, PartialEq, Clone)]
pub struct MacSearcher<L> {
    pub full_mac_pattern: Pattern<L>,
    pub vec4_pattern: Pattern<L>,
}

impl<L: Language> MacSearcher<L> {
}

// Either want:
// (+ ?a (* ?b ?c))
// (* ?b ?c)
// 0


// (Vec4 (+ ?a (* ?b ?c))
//       (+ ?d (* ?e ?f))
//       (+ ?g (* ?h ?i))
//       (+ ?j (* ?k ?l)))
pub fn build_mac_searcher<L: Language>() -> MacSearcher<L> {
    let full_mac_pattern : Pattern<L> = "(Vec4 (+ ?a (* ?b ?c))
                                               (+ ?d (* ?e ?f))
                                               (+ ?g (* ?h ?i))
                                               (+ ?j (* ?k ?l)))"
        .parse::<Pattern<L>>()
        .unwrap();

    let vec4_pattern : Pattern<L> = "(Vec4 ?x ?y ?z ?w)"
        .parse::<Pattern<L>>()
        .unwrap();

    MacSearcher {
        full_mac_pattern,
        vec4_pattern,
    }
}

impl<L: Language, A: Analysis<L>> Searcher<L, A> for MacSearcher<L> {
    fn search_eclass(&self, egraph: &EGraph<L, A>, eclass: Id) -> Option<SearchMatches> {
        let vec4_matches = self.vec4_pattern.search_eclass(egraph, eclass);
        let vec4_mac_compatible = match vec4_matches {
            None => None,
            Some(matches) => {
                // Now we know the eclass is a Vec4. The question is: does it
                // match a pattern compatible with a MAC?
                // Either want:
                // (+ ?a (* ?b ?c))
                // (* ?b ?c)
                // 0
                let mut new_substs : Vec<Subst> = Vec::new();

                // For each set of substitutions
                for substs in matches.substs.iter() {
                    let new_sub = Subst::with_capacity(12);
                    let mut all_matches_found = false;
                    // For each variable x, y, x, w in (Vec4 ?x ?y ?z ?w)
                    for vec4_var in self.vec4_pattern.vars().iter() {
                        // Check if that variable matches add/mul
                        let add_mul_pattern : Pattern<L> = "(+ ?a (* ?b ?c))"
                            .parse::<Pattern<L>>()
                            .unwrap();
                        if let Some(child_eclass) = substs.get(*vec4_var) {
                            // println!("{:?}", *child_eclass);
                            if let Some(add_mul_match) = add_mul_pattern.search_eclass(egraph, *child_eclass) {
                                println!("{:?}", add_mul_match);
                                // TODO: add all matches found to new_sub, with
                                // renaming
                                continue;
                            }
                        }
                        all_matches_found = false;
                        break;
                    }
                    if all_matches_found {
                        new_substs.push(new_sub);
                    }
                };
                Some(matches)
            }
        };
        self.full_mac_pattern.search_eclass(egraph, eclass)
    }

    fn vars(&self) -> Vec<Var> {
        self.full_mac_pattern.vars()
    }
}