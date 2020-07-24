use egg::{*};

#[derive(Debug, PartialEq, Clone)]
pub struct MacSearcher<L> {
    pub full_mac_pattern: Pattern<L>,
}

impl<L: Language> MacSearcher<L> {
}

// Either want:
// (+ ?a (* ?b ?c))
// (* ?b ?c)
// 0
pub fn build_mac_searcher<L: Language>() -> MacSearcher<L> {
    let full_mac_pattern : Pattern<L> = "(Vec4 (+ ?a (* ?b ?c))
                                               (+ ?d (* ?e ?f))
                                               (+ ?g (* ?h ?i))
                                               (+ ?j (* ?k ?l)))"
        .parse::<Pattern<L>>()
        .unwrap();

    MacSearcher {
        full_mac_pattern,
    }
}

impl<L: Language, A: Analysis<L>> Searcher<L, A> for MacSearcher<L> {
    fn search_eclass(&self, egraph: &EGraph<L, A>, eclass: Id) -> Option<SearchMatches> {
        let full_mac_matches = self.full_mac_pattern.search_eclass(egraph, eclass);
        full_mac_matches
    }

    fn vars(&self) -> Vec<Var> {
        self.full_mac_pattern.vars()
    }
}