pub const fn vector_width() -> usize {
    #[cfg(feature="vec_width_2")]
    { 2 }
    #[cfg(feature="vec_width_8")]
    { 8 }
    // Default to a width of 4
    #[cfg(not(any(feature="vec_width_2", feature="vec_width_8")))]
    { 4 }
}