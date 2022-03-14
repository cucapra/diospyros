; ModuleID = 'fail-tests/qr-decomp-local-arrays.c'
source_filename = "fail-tests/qr-decomp-local-arrays.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@.str = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1
@.str.1 = private unnamed_addr constant [14 x i8] c"Q Output: %f\0A\00", align 1
@.str.2 = private unnamed_addr constant [23 x i8] c"Expected Q Output: %f\0A\00", align 1
@.str.3 = private unnamed_addr constant [14 x i8] c"R Output: %f\0A\00", align 1
@.str.4 = private unnamed_addr constant [23 x i8] c"Expected R Output: %f\0A\00", align 1

; Function Attrs: alwaysinline nounwind ssp uwtable
define float @sgn(float %0) #0 {
  %2 = alloca float, align 4
  store float %0, float* %2, align 4
  %3 = load float, float* %2, align 4
  %4 = fcmp ogt float %3, 0.000000e+00
  %5 = zext i1 %4 to i32
  %6 = load float, float* %2, align 4
  %7 = fcmp olt float %6, 0.000000e+00
  %8 = zext i1 %7 to i32
  %9 = sub nsw i32 %5, %8
  %10 = sitofp i32 %9 to float
  ret float %10
}

; Function Attrs: noinline nounwind ssp uwtable
define float @no_opt_sgn(float %0) #1 {
  %2 = alloca float, align 4
  store float %0, float* %2, align 4
  %3 = load float, float* %2, align 4
  %4 = fcmp ogt float %3, 0.000000e+00
  %5 = zext i1 %4 to i32
  %6 = load float, float* %2, align 4
  %7 = fcmp olt float %6, 0.000000e+00
  %8 = zext i1 %7 to i32
  %9 = sub nsw i32 %5, %8
  %10 = sitofp i32 %9 to float
  ret float %10
}

; Function Attrs: alwaysinline nounwind ssp uwtable
define float @naive_norm(float* %0, i32 %1) #0 {
  %3 = alloca float*, align 8
  %4 = alloca i32, align 4
  %5 = alloca float, align 4
  %6 = alloca i32, align 4
  store float* %0, float** %3, align 8
  store i32 %1, i32* %4, align 4
  store float 0.000000e+00, float* %5, align 4
  store i32 0, i32* %6, align 4
  br label %7

7:                                                ; preds = %25, %2
  %8 = load i32, i32* %6, align 4
  %9 = load i32, i32* %4, align 4
  %10 = icmp slt i32 %8, %9
  br i1 %10, label %11, label %28

11:                                               ; preds = %7
  %12 = load float*, float** %3, align 8
  %13 = load i32, i32* %6, align 4
  %14 = sext i32 %13 to i64
  %15 = getelementptr inbounds float, float* %12, i64 %14
  %16 = load float, float* %15, align 4
  %17 = load float*, float** %3, align 8
  %18 = load i32, i32* %6, align 4
  %19 = sext i32 %18 to i64
  %20 = getelementptr inbounds float, float* %17, i64 %19
  %21 = load float, float* %20, align 4
  %22 = fmul float %16, %21
  %23 = load float, float* %5, align 4
  %24 = fadd float %23, %22
  store float %24, float* %5, align 4
  br label %25

25:                                               ; preds = %11
  %26 = load i32, i32* %6, align 4
  %27 = add nsw i32 %26, 1
  store i32 %27, i32* %6, align 4
  br label %7

28:                                               ; preds = %7
  %29 = load float, float* %5, align 4
  %30 = call float @llvm.sqrt.f32(float %29)
  ret float %30
}

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32(float) #2

; Function Attrs: noinline nounwind ssp uwtable
define float @no_opt_naive_norm(float* %0, i32 %1) #1 {
  %3 = alloca float*, align 8
  %4 = alloca i32, align 4
  %5 = alloca float, align 4
  %6 = alloca i32, align 4
  store float* %0, float** %3, align 8
  store i32 %1, i32* %4, align 4
  store float 0.000000e+00, float* %5, align 4
  store i32 0, i32* %6, align 4
  br label %7

7:                                                ; preds = %25, %2
  %8 = load i32, i32* %6, align 4
  %9 = load i32, i32* %4, align 4
  %10 = icmp slt i32 %8, %9
  br i1 %10, label %11, label %28

11:                                               ; preds = %7
  %12 = load float*, float** %3, align 8
  %13 = load i32, i32* %6, align 4
  %14 = sext i32 %13 to i64
  %15 = getelementptr inbounds float, float* %12, i64 %14
  %16 = load float, float* %15, align 4
  %17 = load float*, float** %3, align 8
  %18 = load i32, i32* %6, align 4
  %19 = sext i32 %18 to i64
  %20 = getelementptr inbounds float, float* %17, i64 %19
  %21 = load float, float* %20, align 4
  %22 = fmul float %16, %21
  %23 = load float, float* %5, align 4
  %24 = fadd float %23, %22
  store float %24, float* %5, align 4
  br label %25

25:                                               ; preds = %11
  %26 = load i32, i32* %6, align 4
  %27 = add nsw i32 %26, 1
  store i32 %27, i32* %6, align 4
  br label %7

28:                                               ; preds = %7
  %29 = load float, float* %5, align 4
  %30 = call float @llvm.sqrt.f32(float %29)
  ret float %30
}

; Function Attrs: alwaysinline nounwind ssp uwtable
define void @naive_fixed_transpose(float* %0) #0 {
  %2 = alloca float*, align 8
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca float, align 4
  store float* %0, float** %2, align 8
  store i32 0, i32* %3, align 4
  br label %6

6:                                                ; preds = %51, %1
  %7 = load i32, i32* %3, align 4
  %8 = icmp slt i32 %7, 2
  br i1 %8, label %9, label %54

9:                                                ; preds = %6
  %10 = load i32, i32* %3, align 4
  %11 = add nsw i32 %10, 1
  store i32 %11, i32* %4, align 4
  br label %12

12:                                               ; preds = %47, %9
  %13 = load i32, i32* %4, align 4
  %14 = icmp slt i32 %13, 2
  br i1 %14, label %15, label %50

15:                                               ; preds = %12
  %16 = load float*, float** %2, align 8
  %17 = load i32, i32* %3, align 4
  %18 = mul nsw i32 %17, 2
  %19 = load i32, i32* %4, align 4
  %20 = add nsw i32 %18, %19
  %21 = sext i32 %20 to i64
  %22 = getelementptr inbounds float, float* %16, i64 %21
  %23 = load float, float* %22, align 4
  store float %23, float* %5, align 4
  %24 = load float*, float** %2, align 8
  %25 = load i32, i32* %4, align 4
  %26 = mul nsw i32 %25, 2
  %27 = load i32, i32* %3, align 4
  %28 = add nsw i32 %26, %27
  %29 = sext i32 %28 to i64
  %30 = getelementptr inbounds float, float* %24, i64 %29
  %31 = load float, float* %30, align 4
  %32 = load float*, float** %2, align 8
  %33 = load i32, i32* %3, align 4
  %34 = mul nsw i32 %33, 2
  %35 = load i32, i32* %4, align 4
  %36 = add nsw i32 %34, %35
  %37 = sext i32 %36 to i64
  %38 = getelementptr inbounds float, float* %32, i64 %37
  store float %31, float* %38, align 4
  %39 = load float, float* %5, align 4
  %40 = load float*, float** %2, align 8
  %41 = load i32, i32* %4, align 4
  %42 = mul nsw i32 %41, 2
  %43 = load i32, i32* %3, align 4
  %44 = add nsw i32 %42, %43
  %45 = sext i32 %44 to i64
  %46 = getelementptr inbounds float, float* %40, i64 %45
  store float %39, float* %46, align 4
  br label %47

47:                                               ; preds = %15
  %48 = load i32, i32* %4, align 4
  %49 = add nsw i32 %48, 1
  store i32 %49, i32* %4, align 4
  br label %12

50:                                               ; preds = %12
  br label %51

51:                                               ; preds = %50
  %52 = load i32, i32* %3, align 4
  %53 = add nsw i32 %52, 1
  store i32 %53, i32* %3, align 4
  br label %6

54:                                               ; preds = %6
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define void @no_opt_naive_fixed_transpose(float* %0) #1 {
  %2 = alloca float*, align 8
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca float, align 4
  store float* %0, float** %2, align 8
  store i32 0, i32* %3, align 4
  br label %6

6:                                                ; preds = %51, %1
  %7 = load i32, i32* %3, align 4
  %8 = icmp slt i32 %7, 2
  br i1 %8, label %9, label %54

9:                                                ; preds = %6
  %10 = load i32, i32* %3, align 4
  %11 = add nsw i32 %10, 1
  store i32 %11, i32* %4, align 4
  br label %12

12:                                               ; preds = %47, %9
  %13 = load i32, i32* %4, align 4
  %14 = icmp slt i32 %13, 2
  br i1 %14, label %15, label %50

15:                                               ; preds = %12
  %16 = load float*, float** %2, align 8
  %17 = load i32, i32* %3, align 4
  %18 = mul nsw i32 %17, 2
  %19 = load i32, i32* %4, align 4
  %20 = add nsw i32 %18, %19
  %21 = sext i32 %20 to i64
  %22 = getelementptr inbounds float, float* %16, i64 %21
  %23 = load float, float* %22, align 4
  store float %23, float* %5, align 4
  %24 = load float*, float** %2, align 8
  %25 = load i32, i32* %4, align 4
  %26 = mul nsw i32 %25, 2
  %27 = load i32, i32* %3, align 4
  %28 = add nsw i32 %26, %27
  %29 = sext i32 %28 to i64
  %30 = getelementptr inbounds float, float* %24, i64 %29
  %31 = load float, float* %30, align 4
  %32 = load float*, float** %2, align 8
  %33 = load i32, i32* %3, align 4
  %34 = mul nsw i32 %33, 2
  %35 = load i32, i32* %4, align 4
  %36 = add nsw i32 %34, %35
  %37 = sext i32 %36 to i64
  %38 = getelementptr inbounds float, float* %32, i64 %37
  store float %31, float* %38, align 4
  %39 = load float, float* %5, align 4
  %40 = load float*, float** %2, align 8
  %41 = load i32, i32* %4, align 4
  %42 = mul nsw i32 %41, 2
  %43 = load i32, i32* %3, align 4
  %44 = add nsw i32 %42, %43
  %45 = sext i32 %44 to i64
  %46 = getelementptr inbounds float, float* %40, i64 %45
  store float %39, float* %46, align 4
  br label %47

47:                                               ; preds = %15
  %48 = load i32, i32* %4, align 4
  %49 = add nsw i32 %48, 1
  store i32 %49, i32* %4, align 4
  br label %12

50:                                               ; preds = %12
  br label %51

51:                                               ; preds = %50
  %52 = load i32, i32* %3, align 4
  %53 = add nsw i32 %52, 1
  store i32 %53, i32* %3, align 4
  br label %6

54:                                               ; preds = %6
  ret void
}

; Function Attrs: alwaysinline nounwind ssp uwtable
define void @naive_fixed_matrix_multiply(float* %0, float* %1, float* %2) #0 {
  %4 = alloca float*, align 8
  %5 = alloca float*, align 8
  %6 = alloca float*, align 8
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  store float* %0, float** %4, align 8
  store float* %1, float** %5, align 8
  store float* %2, float** %6, align 8
  store i32 0, i32* %7, align 4
  br label %10

10:                                               ; preds = %63, %3
  %11 = load i32, i32* %7, align 4
  %12 = icmp slt i32 %11, 2
  br i1 %12, label %13, label %66

13:                                               ; preds = %10
  store i32 0, i32* %8, align 4
  br label %14

14:                                               ; preds = %59, %13
  %15 = load i32, i32* %8, align 4
  %16 = icmp slt i32 %15, 2
  br i1 %16, label %17, label %62

17:                                               ; preds = %14
  %18 = load float*, float** %6, align 8
  %19 = load i32, i32* %7, align 4
  %20 = mul nsw i32 2, %19
  %21 = load i32, i32* %8, align 4
  %22 = add nsw i32 %20, %21
  %23 = sext i32 %22 to i64
  %24 = getelementptr inbounds float, float* %18, i64 %23
  store float 0.000000e+00, float* %24, align 4
  store i32 0, i32* %9, align 4
  br label %25

25:                                               ; preds = %55, %17
  %26 = load i32, i32* %9, align 4
  %27 = icmp slt i32 %26, 2
  br i1 %27, label %28, label %58

28:                                               ; preds = %25
  %29 = load float*, float** %4, align 8
  %30 = load i32, i32* %7, align 4
  %31 = mul nsw i32 2, %30
  %32 = load i32, i32* %9, align 4
  %33 = add nsw i32 %31, %32
  %34 = sext i32 %33 to i64
  %35 = getelementptr inbounds float, float* %29, i64 %34
  %36 = load float, float* %35, align 4
  %37 = load float*, float** %5, align 8
  %38 = load i32, i32* %9, align 4
  %39 = mul nsw i32 2, %38
  %40 = load i32, i32* %8, align 4
  %41 = add nsw i32 %39, %40
  %42 = sext i32 %41 to i64
  %43 = getelementptr inbounds float, float* %37, i64 %42
  %44 = load float, float* %43, align 4
  %45 = fmul float %36, %44
  %46 = load float*, float** %6, align 8
  %47 = load i32, i32* %7, align 4
  %48 = mul nsw i32 2, %47
  %49 = load i32, i32* %8, align 4
  %50 = add nsw i32 %48, %49
  %51 = sext i32 %50 to i64
  %52 = getelementptr inbounds float, float* %46, i64 %51
  %53 = load float, float* %52, align 4
  %54 = fadd float %53, %45
  store float %54, float* %52, align 4
  br label %55

55:                                               ; preds = %28
  %56 = load i32, i32* %9, align 4
  %57 = add nsw i32 %56, 1
  store i32 %57, i32* %9, align 4
  br label %25

58:                                               ; preds = %25
  br label %59

59:                                               ; preds = %58
  %60 = load i32, i32* %8, align 4
  %61 = add nsw i32 %60, 1
  store i32 %61, i32* %8, align 4
  br label %14

62:                                               ; preds = %14
  br label %63

63:                                               ; preds = %62
  %64 = load i32, i32* %7, align 4
  %65 = add nsw i32 %64, 1
  store i32 %65, i32* %7, align 4
  br label %10

66:                                               ; preds = %10
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define void @no_opt_naive_fixed_matrix_multiply(float* %0, float* %1, float* %2) #1 {
  %4 = alloca float*, align 8
  %5 = alloca float*, align 8
  %6 = alloca float*, align 8
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  store float* %0, float** %4, align 8
  store float* %1, float** %5, align 8
  store float* %2, float** %6, align 8
  store i32 0, i32* %7, align 4
  br label %10

10:                                               ; preds = %63, %3
  %11 = load i32, i32* %7, align 4
  %12 = icmp slt i32 %11, 2
  br i1 %12, label %13, label %66

13:                                               ; preds = %10
  store i32 0, i32* %8, align 4
  br label %14

14:                                               ; preds = %59, %13
  %15 = load i32, i32* %8, align 4
  %16 = icmp slt i32 %15, 2
  br i1 %16, label %17, label %62

17:                                               ; preds = %14
  %18 = load float*, float** %6, align 8
  %19 = load i32, i32* %7, align 4
  %20 = mul nsw i32 2, %19
  %21 = load i32, i32* %8, align 4
  %22 = add nsw i32 %20, %21
  %23 = sext i32 %22 to i64
  %24 = getelementptr inbounds float, float* %18, i64 %23
  store float 0.000000e+00, float* %24, align 4
  store i32 0, i32* %9, align 4
  br label %25

25:                                               ; preds = %55, %17
  %26 = load i32, i32* %9, align 4
  %27 = icmp slt i32 %26, 2
  br i1 %27, label %28, label %58

28:                                               ; preds = %25
  %29 = load float*, float** %4, align 8
  %30 = load i32, i32* %7, align 4
  %31 = mul nsw i32 2, %30
  %32 = load i32, i32* %9, align 4
  %33 = add nsw i32 %31, %32
  %34 = sext i32 %33 to i64
  %35 = getelementptr inbounds float, float* %29, i64 %34
  %36 = load float, float* %35, align 4
  %37 = load float*, float** %5, align 8
  %38 = load i32, i32* %9, align 4
  %39 = mul nsw i32 2, %38
  %40 = load i32, i32* %8, align 4
  %41 = add nsw i32 %39, %40
  %42 = sext i32 %41 to i64
  %43 = getelementptr inbounds float, float* %37, i64 %42
  %44 = load float, float* %43, align 4
  %45 = fmul float %36, %44
  %46 = load float*, float** %6, align 8
  %47 = load i32, i32* %7, align 4
  %48 = mul nsw i32 2, %47
  %49 = load i32, i32* %8, align 4
  %50 = add nsw i32 %48, %49
  %51 = sext i32 %50 to i64
  %52 = getelementptr inbounds float, float* %46, i64 %51
  %53 = load float, float* %52, align 4
  %54 = fadd float %53, %45
  store float %54, float* %52, align 4
  br label %55

55:                                               ; preds = %28
  %56 = load i32, i32* %9, align 4
  %57 = add nsw i32 %56, 1
  store i32 %57, i32* %9, align 4
  br label %25

58:                                               ; preds = %25
  br label %59

59:                                               ; preds = %58
  %60 = load i32, i32* %8, align 4
  %61 = add nsw i32 %60, 1
  store i32 %61, i32* %8, align 4
  br label %14

62:                                               ; preds = %14
  br label %63

63:                                               ; preds = %62
  %64 = load i32, i32* %7, align 4
  %65 = add nsw i32 %64, 1
  store i32 %65, i32* %7, align 4
  br label %10

66:                                               ; preds = %10
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define void @naive_fixed_qr_decomp(float* %0, float* %1, float* %2) #1 {
  %4 = alloca float*, align 8
  %5 = alloca i32, align 4
  %6 = alloca float, align 4
  %7 = alloca i32, align 4
  %8 = alloca float*, align 8
  %9 = alloca i32, align 4
  %10 = alloca float, align 4
  %11 = alloca i32, align 4
  %12 = alloca float*, align 8
  %13 = alloca float*, align 8
  %14 = alloca float*, align 8
  %15 = alloca i32, align 4
  %16 = alloca i32, align 4
  %17 = alloca i32, align 4
  %18 = alloca float*, align 8
  %19 = alloca float*, align 8
  %20 = alloca float*, align 8
  %21 = alloca i32, align 4
  %22 = alloca i32, align 4
  %23 = alloca i32, align 4
  %24 = alloca float*, align 8
  %25 = alloca float*, align 8
  %26 = alloca float*, align 8
  %27 = alloca i32, align 4
  %28 = alloca i32, align 4
  %29 = alloca i32, align 4
  %30 = alloca float*, align 8
  %31 = alloca i32, align 4
  %32 = alloca i32, align 4
  %33 = alloca float, align 4
  %34 = alloca float, align 4
  %35 = alloca float*, align 8
  %36 = alloca float*, align 8
  %37 = alloca float*, align 8
  %38 = alloca i32, align 4
  %39 = alloca [4 x float], align 16
  %40 = alloca i32, align 4
  %41 = alloca i32, align 4
  %42 = alloca i32, align 4
  %43 = alloca i32, align 4
  %44 = alloca [2 x float], align 4
  %45 = alloca [2 x float], align 4
  %46 = alloca i32, align 4
  %47 = alloca i32, align 4
  %48 = alloca i32, align 4
  %49 = alloca float, align 4
  %50 = alloca [2 x float], align 4
  %51 = alloca [2 x float], align 4
  %52 = alloca i32, align 4
  %53 = alloca i32, align 4
  %54 = alloca float, align 4
  %55 = alloca i32, align 4
  %56 = alloca [4 x float], align 16
  %57 = alloca i32, align 4
  %58 = alloca i32, align 4
  %59 = alloca i32, align 4
  %60 = alloca float, align 4
  %61 = alloca [4 x float], align 16
  %62 = alloca i32, align 4
  %63 = alloca i32, align 4
  %64 = alloca i32, align 4
  %65 = alloca float, align 4
  %66 = alloca i32, align 4
  %67 = alloca [4 x float], align 16
  %68 = alloca i32, align 4
  %69 = alloca i32, align 4
  %70 = alloca i32, align 4
  store float* %0, float** %35, align 8
  store float* %1, float** %36, align 8
  store float* %2, float** %37, align 8
  store i32 0, i32* %38, align 4
  br label %71

71:                                               ; preds = %84, %3
  %72 = load i32, i32* %38, align 4
  %73 = icmp slt i32 %72, 4
  br i1 %73, label %74, label %87

74:                                               ; preds = %71
  %75 = load float*, float** %35, align 8
  %76 = load i32, i32* %38, align 4
  %77 = sext i32 %76 to i64
  %78 = getelementptr inbounds float, float* %75, i64 %77
  %79 = load float, float* %78, align 4
  %80 = load float*, float** %37, align 8
  %81 = load i32, i32* %38, align 4
  %82 = sext i32 %81 to i64
  %83 = getelementptr inbounds float, float* %80, i64 %82
  store float %79, float* %83, align 4
  br label %84

84:                                               ; preds = %74
  %85 = load i32, i32* %38, align 4
  %86 = add nsw i32 %85, 1
  store i32 %86, i32* %38, align 4
  br label %71

87:                                               ; preds = %71
  %88 = bitcast [4 x float]* %39 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %88, i8 0, i64 16, i1 false)
  store i32 0, i32* %40, align 4
  br label %89

89:                                               ; preds = %112, %87
  %90 = load i32, i32* %40, align 4
  %91 = icmp slt i32 %90, 2
  br i1 %91, label %92, label %115

92:                                               ; preds = %89
  store i32 0, i32* %41, align 4
  br label %93

93:                                               ; preds = %108, %92
  %94 = load i32, i32* %41, align 4
  %95 = icmp slt i32 %94, 2
  br i1 %95, label %96, label %111

96:                                               ; preds = %93
  %97 = load i32, i32* %40, align 4
  %98 = load i32, i32* %41, align 4
  %99 = icmp eq i32 %97, %98
  %100 = zext i1 %99 to i32
  %101 = sitofp i32 %100 to float
  %102 = load i32, i32* %40, align 4
  %103 = mul nsw i32 %102, 2
  %104 = load i32, i32* %41, align 4
  %105 = add nsw i32 %103, %104
  %106 = sext i32 %105 to i64
  %107 = getelementptr inbounds [4 x float], [4 x float]* %39, i64 0, i64 %106
  store float %101, float* %107, align 4
  br label %108

108:                                              ; preds = %96
  %109 = load i32, i32* %41, align 4
  %110 = add nsw i32 %109, 1
  store i32 %110, i32* %41, align 4
  br label %93

111:                                              ; preds = %93
  br label %112

112:                                              ; preds = %111
  %113 = load i32, i32* %40, align 4
  %114 = add nsw i32 %113, 1
  store i32 %114, i32* %40, align 4
  br label %89

115:                                              ; preds = %89
  store i32 0, i32* %42, align 4
  br label %116

116:                                              ; preds = %643, %115
  %117 = load i32, i32* %42, align 4
  %118 = icmp slt i32 %117, 1
  br i1 %118, label %119, label %646

119:                                              ; preds = %116
  %120 = load i32, i32* %42, align 4
  %121 = sub nsw i32 2, %120
  store i32 %121, i32* %43, align 4
  %122 = bitcast [2 x float]* %44 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 4 %122, i8 0, i64 8, i1 false)
  %123 = bitcast [2 x float]* %45 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 4 %123, i8 0, i64 8, i1 false)
  store i32 0, i32* %46, align 4
  br label %124

124:                                              ; preds = %134, %119
  %125 = load i32, i32* %46, align 4
  %126 = icmp slt i32 %125, 2
  br i1 %126, label %127, label %137

127:                                              ; preds = %124
  %128 = load i32, i32* %46, align 4
  %129 = sext i32 %128 to i64
  %130 = getelementptr inbounds [2 x float], [2 x float]* %44, i64 0, i64 %129
  store float 0.000000e+00, float* %130, align 4
  %131 = load i32, i32* %46, align 4
  %132 = sext i32 %131 to i64
  %133 = getelementptr inbounds [2 x float], [2 x float]* %45, i64 0, i64 %132
  store float 0.000000e+00, float* %133, align 4
  br label %134

134:                                              ; preds = %127
  %135 = load i32, i32* %46, align 4
  %136 = add nsw i32 %135, 1
  store i32 %136, i32* %46, align 4
  br label %124

137:                                              ; preds = %124
  store i32 0, i32* %47, align 4
  br label %138

138:                                              ; preds = %167, %137
  %139 = load i32, i32* %47, align 4
  %140 = load i32, i32* %43, align 4
  %141 = icmp slt i32 %139, %140
  br i1 %141, label %142, label %170

142:                                              ; preds = %138
  %143 = load i32, i32* %42, align 4
  %144 = load i32, i32* %47, align 4
  %145 = add nsw i32 %143, %144
  store i32 %145, i32* %48, align 4
  %146 = load float*, float** %37, align 8
  %147 = load i32, i32* %48, align 4
  %148 = mul nsw i32 %147, 2
  %149 = load i32, i32* %42, align 4
  %150 = add nsw i32 %148, %149
  %151 = sext i32 %150 to i64
  %152 = getelementptr inbounds float, float* %146, i64 %151
  %153 = load float, float* %152, align 4
  %154 = load i32, i32* %47, align 4
  %155 = sext i32 %154 to i64
  %156 = getelementptr inbounds [2 x float], [2 x float]* %44, i64 0, i64 %155
  store float %153, float* %156, align 4
  %157 = load i32, i32* %48, align 4
  %158 = mul nsw i32 %157, 2
  %159 = load i32, i32* %42, align 4
  %160 = add nsw i32 %158, %159
  %161 = sext i32 %160 to i64
  %162 = getelementptr inbounds [4 x float], [4 x float]* %39, i64 0, i64 %161
  %163 = load float, float* %162, align 4
  %164 = load i32, i32* %47, align 4
  %165 = sext i32 %164 to i64
  %166 = getelementptr inbounds [2 x float], [2 x float]* %45, i64 0, i64 %165
  store float %163, float* %166, align 4
  br label %167

167:                                              ; preds = %142
  %168 = load i32, i32* %47, align 4
  %169 = add nsw i32 %168, 1
  store i32 %169, i32* %47, align 4
  br label %138

170:                                              ; preds = %138
  %171 = getelementptr inbounds [2 x float], [2 x float]* %44, i64 0, i64 0
  %172 = load float, float* %171, align 4
  store float %172, float* %34, align 4
  %173 = load float, float* %34, align 4
  %174 = fcmp ogt float %173, 0.000000e+00
  %175 = zext i1 %174 to i32
  %176 = load float, float* %34, align 4
  %177 = fcmp olt float %176, 0.000000e+00
  %178 = zext i1 %177 to i32
  %179 = sub nsw i32 %175, %178
  %180 = sitofp i32 %179 to float
  %181 = fneg float %180
  %182 = getelementptr inbounds [2 x float], [2 x float]* %44, i64 0, i64 0
  %183 = load i32, i32* %43, align 4
  store float* %182, float** %4, align 8
  store i32 %183, i32* %5, align 4
  store float 0.000000e+00, float* %6, align 4
  store i32 0, i32* %7, align 4
  br label %184

184:                                              ; preds = %188, %170
  %185 = load i32, i32* %7, align 4
  %186 = load i32, i32* %5, align 4
  %187 = icmp slt i32 %185, %186
  br i1 %187, label %188, label %204

188:                                              ; preds = %184
  %189 = load float*, float** %4, align 8
  %190 = load i32, i32* %7, align 4
  %191 = sext i32 %190 to i64
  %192 = getelementptr inbounds float, float* %189, i64 %191
  %193 = load float, float* %192, align 4
  %194 = load float*, float** %4, align 8
  %195 = load i32, i32* %7, align 4
  %196 = sext i32 %195 to i64
  %197 = getelementptr inbounds float, float* %194, i64 %196
  %198 = load float, float* %197, align 4
  %199 = fmul float %193, %198
  %200 = load float, float* %6, align 4
  %201 = fadd float %200, %199
  store float %201, float* %6, align 4
  %202 = load i32, i32* %7, align 4
  %203 = add nsw i32 %202, 1
  store i32 %203, i32* %7, align 4
  br label %184

204:                                              ; preds = %184
  %205 = load float, float* %6, align 4
  %206 = call float @llvm.sqrt.f32(float %205) #7
  %207 = fmul float %181, %206
  store float %207, float* %49, align 4
  %208 = bitcast [2 x float]* %50 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 4 %208, i8 0, i64 8, i1 false)
  %209 = bitcast [2 x float]* %51 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 4 %209, i8 0, i64 8, i1 false)
  store i32 0, i32* %52, align 4
  br label %210

210:                                              ; preds = %220, %204
  %211 = load i32, i32* %52, align 4
  %212 = icmp slt i32 %211, 2
  br i1 %212, label %213, label %223

213:                                              ; preds = %210
  %214 = load i32, i32* %52, align 4
  %215 = sext i32 %214 to i64
  %216 = getelementptr inbounds [2 x float], [2 x float]* %50, i64 0, i64 %215
  store float 0.000000e+00, float* %216, align 4
  %217 = load i32, i32* %52, align 4
  %218 = sext i32 %217 to i64
  %219 = getelementptr inbounds [2 x float], [2 x float]* %51, i64 0, i64 %218
  store float 0.000000e+00, float* %219, align 4
  br label %220

220:                                              ; preds = %213
  %221 = load i32, i32* %52, align 4
  %222 = add nsw i32 %221, 1
  store i32 %222, i32* %52, align 4
  br label %210

223:                                              ; preds = %210
  store i32 0, i32* %53, align 4
  br label %224

224:                                              ; preds = %243, %223
  %225 = load i32, i32* %53, align 4
  %226 = load i32, i32* %43, align 4
  %227 = icmp slt i32 %225, %226
  br i1 %227, label %228, label %246

228:                                              ; preds = %224
  %229 = load i32, i32* %53, align 4
  %230 = sext i32 %229 to i64
  %231 = getelementptr inbounds [2 x float], [2 x float]* %44, i64 0, i64 %230
  %232 = load float, float* %231, align 4
  %233 = load float, float* %49, align 4
  %234 = load i32, i32* %53, align 4
  %235 = sext i32 %234 to i64
  %236 = getelementptr inbounds [2 x float], [2 x float]* %45, i64 0, i64 %235
  %237 = load float, float* %236, align 4
  %238 = fmul float %233, %237
  %239 = fadd float %232, %238
  %240 = load i32, i32* %53, align 4
  %241 = sext i32 %240 to i64
  %242 = getelementptr inbounds [2 x float], [2 x float]* %50, i64 0, i64 %241
  store float %239, float* %242, align 4
  br label %243

243:                                              ; preds = %228
  %244 = load i32, i32* %53, align 4
  %245 = add nsw i32 %244, 1
  store i32 %245, i32* %53, align 4
  br label %224

246:                                              ; preds = %224
  %247 = getelementptr inbounds [2 x float], [2 x float]* %50, i64 0, i64 0
  %248 = load i32, i32* %43, align 4
  store float* %247, float** %8, align 8
  store i32 %248, i32* %9, align 4
  store float 0.000000e+00, float* %10, align 4
  store i32 0, i32* %11, align 4
  br label %249

249:                                              ; preds = %253, %246
  %250 = load i32, i32* %11, align 4
  %251 = load i32, i32* %9, align 4
  %252 = icmp slt i32 %250, %251
  br i1 %252, label %253, label %269

253:                                              ; preds = %249
  %254 = load float*, float** %8, align 8
  %255 = load i32, i32* %11, align 4
  %256 = sext i32 %255 to i64
  %257 = getelementptr inbounds float, float* %254, i64 %256
  %258 = load float, float* %257, align 4
  %259 = load float*, float** %8, align 8
  %260 = load i32, i32* %11, align 4
  %261 = sext i32 %260 to i64
  %262 = getelementptr inbounds float, float* %259, i64 %261
  %263 = load float, float* %262, align 4
  %264 = fmul float %258, %263
  %265 = load float, float* %10, align 4
  %266 = fadd float %265, %264
  store float %266, float* %10, align 4
  %267 = load i32, i32* %11, align 4
  %268 = add nsw i32 %267, 1
  store i32 %268, i32* %11, align 4
  br label %249

269:                                              ; preds = %249
  %270 = load float, float* %10, align 4
  %271 = call float @llvm.sqrt.f32(float %270) #7
  store float %271, float* %54, align 4
  store i32 0, i32* %55, align 4
  br label %272

272:                                              ; preds = %287, %269
  %273 = load i32, i32* %55, align 4
  %274 = load i32, i32* %43, align 4
  %275 = icmp slt i32 %273, %274
  br i1 %275, label %276, label %290

276:                                              ; preds = %272
  %277 = load i32, i32* %55, align 4
  %278 = sext i32 %277 to i64
  %279 = getelementptr inbounds [2 x float], [2 x float]* %50, i64 0, i64 %278
  %280 = load float, float* %279, align 4
  %281 = load float, float* %54, align 4
  %282 = fadd float %281, 0x3EE4F8B580000000
  %283 = fdiv float %280, %282
  %284 = load i32, i32* %55, align 4
  %285 = sext i32 %284 to i64
  %286 = getelementptr inbounds [2 x float], [2 x float]* %51, i64 0, i64 %285
  store float %283, float* %286, align 4
  br label %287

287:                                              ; preds = %276
  %288 = load i32, i32* %55, align 4
  %289 = add nsw i32 %288, 1
  store i32 %289, i32* %55, align 4
  br label %272

290:                                              ; preds = %272
  %291 = bitcast [4 x float]* %56 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %291, i8 0, i64 16, i1 false)
  store i32 0, i32* %57, align 4
  br label %292

292:                                              ; preds = %299, %290
  %293 = load i32, i32* %57, align 4
  %294 = icmp slt i32 %293, 4
  br i1 %294, label %295, label %302

295:                                              ; preds = %292
  %296 = load i32, i32* %57, align 4
  %297 = sext i32 %296 to i64
  %298 = getelementptr inbounds [4 x float], [4 x float]* %56, i64 0, i64 %297
  store float 0.000000e+00, float* %298, align 4
  br label %299

299:                                              ; preds = %295
  %300 = load i32, i32* %57, align 4
  %301 = add nsw i32 %300, 1
  store i32 %301, i32* %57, align 4
  br label %292

302:                                              ; preds = %292
  store i32 0, i32* %58, align 4
  br label %303

303:                                              ; preds = %341, %302
  %304 = load i32, i32* %58, align 4
  %305 = load i32, i32* %43, align 4
  %306 = icmp slt i32 %304, %305
  br i1 %306, label %307, label %344

307:                                              ; preds = %303
  store i32 0, i32* %59, align 4
  br label %308

308:                                              ; preds = %337, %307
  %309 = load i32, i32* %59, align 4
  %310 = load i32, i32* %43, align 4
  %311 = icmp slt i32 %309, %310
  br i1 %311, label %312, label %340

312:                                              ; preds = %308
  %313 = load i32, i32* %58, align 4
  %314 = load i32, i32* %59, align 4
  %315 = icmp eq i32 %313, %314
  %316 = zext i1 %315 to i64
  %317 = select i1 %315, float 1.000000e+00, float 0.000000e+00
  %318 = load i32, i32* %58, align 4
  %319 = sext i32 %318 to i64
  %320 = getelementptr inbounds [2 x float], [2 x float]* %51, i64 0, i64 %319
  %321 = load float, float* %320, align 4
  %322 = fmul float 2.000000e+00, %321
  %323 = load i32, i32* %59, align 4
  %324 = sext i32 %323 to i64
  %325 = getelementptr inbounds [2 x float], [2 x float]* %51, i64 0, i64 %324
  %326 = load float, float* %325, align 4
  %327 = fmul float %322, %326
  %328 = fsub float %317, %327
  store float %328, float* %60, align 4
  %329 = load float, float* %60, align 4
  %330 = load i32, i32* %58, align 4
  %331 = load i32, i32* %43, align 4
  %332 = mul nsw i32 %330, %331
  %333 = load i32, i32* %59, align 4
  %334 = add nsw i32 %332, %333
  %335 = sext i32 %334 to i64
  %336 = getelementptr inbounds [4 x float], [4 x float]* %56, i64 0, i64 %335
  store float %329, float* %336, align 4
  br label %337

337:                                              ; preds = %312
  %338 = load i32, i32* %59, align 4
  %339 = add nsw i32 %338, 1
  store i32 %339, i32* %59, align 4
  br label %308

340:                                              ; preds = %308
  br label %341

341:                                              ; preds = %340
  %342 = load i32, i32* %58, align 4
  %343 = add nsw i32 %342, 1
  store i32 %343, i32* %58, align 4
  br label %303

344:                                              ; preds = %303
  %345 = bitcast [4 x float]* %61 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %345, i8 0, i64 16, i1 false)
  store i32 0, i32* %62, align 4
  br label %346

346:                                              ; preds = %353, %344
  %347 = load i32, i32* %62, align 4
  %348 = icmp slt i32 %347, 4
  br i1 %348, label %349, label %356

349:                                              ; preds = %346
  %350 = load i32, i32* %62, align 4
  %351 = sext i32 %350 to i64
  %352 = getelementptr inbounds [4 x float], [4 x float]* %61, i64 0, i64 %351
  store float 0.000000e+00, float* %352, align 4
  br label %353

353:                                              ; preds = %349
  %354 = load i32, i32* %62, align 4
  %355 = add nsw i32 %354, 1
  store i32 %355, i32* %62, align 4
  br label %346

356:                                              ; preds = %346
  store i32 0, i32* %63, align 4
  br label %357

357:                                              ; preds = %403, %356
  %358 = load i32, i32* %63, align 4
  %359 = icmp slt i32 %358, 2
  br i1 %359, label %360, label %406

360:                                              ; preds = %357
  store i32 0, i32* %64, align 4
  br label %361

361:                                              ; preds = %399, %360
  %362 = load i32, i32* %64, align 4
  %363 = icmp slt i32 %362, 2
  br i1 %363, label %364, label %402

364:                                              ; preds = %361
  %365 = load i32, i32* %63, align 4
  %366 = load i32, i32* %42, align 4
  %367 = icmp slt i32 %365, %366
  br i1 %367, label %372, label %368

368:                                              ; preds = %364
  %369 = load i32, i32* %64, align 4
  %370 = load i32, i32* %42, align 4
  %371 = icmp slt i32 %369, %370
  br i1 %371, label %372, label %378

372:                                              ; preds = %368, %364
  %373 = load i32, i32* %63, align 4
  %374 = load i32, i32* %64, align 4
  %375 = icmp eq i32 %373, %374
  %376 = zext i1 %375 to i64
  %377 = select i1 %375, float 1.000000e+00, float 0.000000e+00
  store float %377, float* %65, align 4
  br label %391

378:                                              ; preds = %368
  %379 = load i32, i32* %63, align 4
  %380 = load i32, i32* %42, align 4
  %381 = sub nsw i32 %379, %380
  %382 = load i32, i32* %43, align 4
  %383 = mul nsw i32 %381, %382
  %384 = load i32, i32* %64, align 4
  %385 = load i32, i32* %42, align 4
  %386 = sub nsw i32 %384, %385
  %387 = add nsw i32 %383, %386
  %388 = sext i32 %387 to i64
  %389 = getelementptr inbounds [4 x float], [4 x float]* %56, i64 0, i64 %388
  %390 = load float, float* %389, align 4
  store float %390, float* %65, align 4
  br label %391

391:                                              ; preds = %378, %372
  %392 = load float, float* %65, align 4
  %393 = load i32, i32* %63, align 4
  %394 = mul nsw i32 %393, 2
  %395 = load i32, i32* %64, align 4
  %396 = add nsw i32 %394, %395
  %397 = sext i32 %396 to i64
  %398 = getelementptr inbounds [4 x float], [4 x float]* %61, i64 0, i64 %397
  store float %392, float* %398, align 4
  br label %399

399:                                              ; preds = %391
  %400 = load i32, i32* %64, align 4
  %401 = add nsw i32 %400, 1
  store i32 %401, i32* %64, align 4
  br label %361

402:                                              ; preds = %361
  br label %403

403:                                              ; preds = %402
  %404 = load i32, i32* %63, align 4
  %405 = add nsw i32 %404, 1
  store i32 %405, i32* %63, align 4
  br label %357

406:                                              ; preds = %357
  %407 = load i32, i32* %42, align 4
  %408 = icmp eq i32 %407, 0
  br i1 %408, label %409, label %483

409:                                              ; preds = %406
  store i32 0, i32* %66, align 4
  br label %410

410:                                              ; preds = %422, %409
  %411 = load i32, i32* %66, align 4
  %412 = icmp slt i32 %411, 4
  br i1 %412, label %413, label %425

413:                                              ; preds = %410
  %414 = load i32, i32* %66, align 4
  %415 = sext i32 %414 to i64
  %416 = getelementptr inbounds [4 x float], [4 x float]* %61, i64 0, i64 %415
  %417 = load float, float* %416, align 4
  %418 = load float*, float** %36, align 8
  %419 = load i32, i32* %66, align 4
  %420 = sext i32 %419 to i64
  %421 = getelementptr inbounds float, float* %418, i64 %420
  store float %417, float* %421, align 4
  br label %422

422:                                              ; preds = %413
  %423 = load i32, i32* %66, align 4
  %424 = add nsw i32 %423, 1
  store i32 %424, i32* %66, align 4
  br label %410

425:                                              ; preds = %410
  %426 = getelementptr inbounds [4 x float], [4 x float]* %61, i64 0, i64 0
  %427 = load float*, float** %35, align 8
  %428 = load float*, float** %37, align 8
  store float* %426, float** %12, align 8
  store float* %427, float** %13, align 8
  store float* %428, float** %14, align 8
  store i32 0, i32* %15, align 4
  br label %429

429:                                              ; preds = %479, %425
  %430 = load i32, i32* %15, align 4
  %431 = icmp slt i32 %430, 2
  br i1 %431, label %432, label %482

432:                                              ; preds = %429
  store i32 0, i32* %16, align 4
  br label %433

433:                                              ; preds = %476, %432
  %434 = load i32, i32* %16, align 4
  %435 = icmp slt i32 %434, 2
  br i1 %435, label %436, label %479

436:                                              ; preds = %433
  %437 = load float*, float** %14, align 8
  %438 = load i32, i32* %15, align 4
  %439 = mul nsw i32 2, %438
  %440 = load i32, i32* %16, align 4
  %441 = add nsw i32 %439, %440
  %442 = sext i32 %441 to i64
  %443 = getelementptr inbounds float, float* %437, i64 %442
  store float 0.000000e+00, float* %443, align 4
  store i32 0, i32* %17, align 4
  br label %444

444:                                              ; preds = %447, %436
  %445 = load i32, i32* %17, align 4
  %446 = icmp slt i32 %445, 2
  br i1 %446, label %447, label %476

447:                                              ; preds = %444
  %448 = load float*, float** %12, align 8
  %449 = load i32, i32* %15, align 4
  %450 = mul nsw i32 2, %449
  %451 = load i32, i32* %17, align 4
  %452 = add nsw i32 %450, %451
  %453 = sext i32 %452 to i64
  %454 = getelementptr inbounds float, float* %448, i64 %453
  %455 = load float, float* %454, align 4
  %456 = load float*, float** %13, align 8
  %457 = load i32, i32* %17, align 4
  %458 = mul nsw i32 2, %457
  %459 = load i32, i32* %16, align 4
  %460 = add nsw i32 %458, %459
  %461 = sext i32 %460 to i64
  %462 = getelementptr inbounds float, float* %456, i64 %461
  %463 = load float, float* %462, align 4
  %464 = fmul float %455, %463
  %465 = load float*, float** %14, align 8
  %466 = load i32, i32* %15, align 4
  %467 = mul nsw i32 2, %466
  %468 = load i32, i32* %16, align 4
  %469 = add nsw i32 %467, %468
  %470 = sext i32 %469 to i64
  %471 = getelementptr inbounds float, float* %465, i64 %470
  %472 = load float, float* %471, align 4
  %473 = fadd float %472, %464
  store float %473, float* %471, align 4
  %474 = load i32, i32* %17, align 4
  %475 = add nsw i32 %474, 1
  store i32 %475, i32* %17, align 4
  br label %444

476:                                              ; preds = %444
  %477 = load i32, i32* %16, align 4
  %478 = add nsw i32 %477, 1
  store i32 %478, i32* %16, align 4
  br label %433

479:                                              ; preds = %433
  %480 = load i32, i32* %15, align 4
  %481 = add nsw i32 %480, 1
  store i32 %481, i32* %15, align 4
  br label %429

482:                                              ; preds = %429
  br label %642

483:                                              ; preds = %406
  %484 = bitcast [4 x float]* %67 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %484, i8 0, i64 16, i1 false)
  store i32 0, i32* %68, align 4
  br label %485

485:                                              ; preds = %492, %483
  %486 = load i32, i32* %68, align 4
  %487 = icmp slt i32 %486, 4
  br i1 %487, label %488, label %495

488:                                              ; preds = %485
  %489 = load i32, i32* %68, align 4
  %490 = sext i32 %489 to i64
  %491 = getelementptr inbounds [4 x float], [4 x float]* %67, i64 0, i64 %490
  store float 0.000000e+00, float* %491, align 4
  br label %492

492:                                              ; preds = %488
  %493 = load i32, i32* %68, align 4
  %494 = add nsw i32 %493, 1
  store i32 %494, i32* %68, align 4
  br label %485

495:                                              ; preds = %485
  %496 = getelementptr inbounds [4 x float], [4 x float]* %61, i64 0, i64 0
  %497 = load float*, float** %36, align 8
  %498 = getelementptr inbounds [4 x float], [4 x float]* %67, i64 0, i64 0
  store float* %496, float** %18, align 8
  store float* %497, float** %19, align 8
  store float* %498, float** %20, align 8
  store i32 0, i32* %21, align 4
  br label %499

499:                                              ; preds = %549, %495
  %500 = load i32, i32* %21, align 4
  %501 = icmp slt i32 %500, 2
  br i1 %501, label %502, label %552

502:                                              ; preds = %499
  store i32 0, i32* %22, align 4
  br label %503

503:                                              ; preds = %546, %502
  %504 = load i32, i32* %22, align 4
  %505 = icmp slt i32 %504, 2
  br i1 %505, label %506, label %549

506:                                              ; preds = %503
  %507 = load float*, float** %20, align 8
  %508 = load i32, i32* %21, align 4
  %509 = mul nsw i32 2, %508
  %510 = load i32, i32* %22, align 4
  %511 = add nsw i32 %509, %510
  %512 = sext i32 %511 to i64
  %513 = getelementptr inbounds float, float* %507, i64 %512
  store float 0.000000e+00, float* %513, align 4
  store i32 0, i32* %23, align 4
  br label %514

514:                                              ; preds = %517, %506
  %515 = load i32, i32* %23, align 4
  %516 = icmp slt i32 %515, 2
  br i1 %516, label %517, label %546

517:                                              ; preds = %514
  %518 = load float*, float** %18, align 8
  %519 = load i32, i32* %21, align 4
  %520 = mul nsw i32 2, %519
  %521 = load i32, i32* %23, align 4
  %522 = add nsw i32 %520, %521
  %523 = sext i32 %522 to i64
  %524 = getelementptr inbounds float, float* %518, i64 %523
  %525 = load float, float* %524, align 4
  %526 = load float*, float** %19, align 8
  %527 = load i32, i32* %23, align 4
  %528 = mul nsw i32 2, %527
  %529 = load i32, i32* %22, align 4
  %530 = add nsw i32 %528, %529
  %531 = sext i32 %530 to i64
  %532 = getelementptr inbounds float, float* %526, i64 %531
  %533 = load float, float* %532, align 4
  %534 = fmul float %525, %533
  %535 = load float*, float** %20, align 8
  %536 = load i32, i32* %21, align 4
  %537 = mul nsw i32 2, %536
  %538 = load i32, i32* %22, align 4
  %539 = add nsw i32 %537, %538
  %540 = sext i32 %539 to i64
  %541 = getelementptr inbounds float, float* %535, i64 %540
  %542 = load float, float* %541, align 4
  %543 = fadd float %542, %534
  store float %543, float* %541, align 4
  %544 = load i32, i32* %23, align 4
  %545 = add nsw i32 %544, 1
  store i32 %545, i32* %23, align 4
  br label %514

546:                                              ; preds = %514
  %547 = load i32, i32* %22, align 4
  %548 = add nsw i32 %547, 1
  store i32 %548, i32* %22, align 4
  br label %503

549:                                              ; preds = %503
  %550 = load i32, i32* %21, align 4
  %551 = add nsw i32 %550, 1
  store i32 %551, i32* %21, align 4
  br label %499

552:                                              ; preds = %499
  store i32 0, i32* %69, align 4
  br label %553

553:                                              ; preds = %565, %552
  %554 = load i32, i32* %69, align 4
  %555 = icmp slt i32 %554, 4
  br i1 %555, label %556, label %568

556:                                              ; preds = %553
  %557 = load i32, i32* %69, align 4
  %558 = sext i32 %557 to i64
  %559 = getelementptr inbounds [4 x float], [4 x float]* %67, i64 0, i64 %558
  %560 = load float, float* %559, align 4
  %561 = load float*, float** %36, align 8
  %562 = load i32, i32* %69, align 4
  %563 = sext i32 %562 to i64
  %564 = getelementptr inbounds float, float* %561, i64 %563
  store float %560, float* %564, align 4
  br label %565

565:                                              ; preds = %556
  %566 = load i32, i32* %69, align 4
  %567 = add nsw i32 %566, 1
  store i32 %567, i32* %69, align 4
  br label %553

568:                                              ; preds = %553
  %569 = getelementptr inbounds [4 x float], [4 x float]* %61, i64 0, i64 0
  %570 = load float*, float** %37, align 8
  %571 = getelementptr inbounds [4 x float], [4 x float]* %67, i64 0, i64 0
  store float* %569, float** %24, align 8
  store float* %570, float** %25, align 8
  store float* %571, float** %26, align 8
  store i32 0, i32* %27, align 4
  br label %572

572:                                              ; preds = %622, %568
  %573 = load i32, i32* %27, align 4
  %574 = icmp slt i32 %573, 2
  br i1 %574, label %575, label %625

575:                                              ; preds = %572
  store i32 0, i32* %28, align 4
  br label %576

576:                                              ; preds = %619, %575
  %577 = load i32, i32* %28, align 4
  %578 = icmp slt i32 %577, 2
  br i1 %578, label %579, label %622

579:                                              ; preds = %576
  %580 = load float*, float** %26, align 8
  %581 = load i32, i32* %27, align 4
  %582 = mul nsw i32 2, %581
  %583 = load i32, i32* %28, align 4
  %584 = add nsw i32 %582, %583
  %585 = sext i32 %584 to i64
  %586 = getelementptr inbounds float, float* %580, i64 %585
  store float 0.000000e+00, float* %586, align 4
  store i32 0, i32* %29, align 4
  br label %587

587:                                              ; preds = %590, %579
  %588 = load i32, i32* %29, align 4
  %589 = icmp slt i32 %588, 2
  br i1 %589, label %590, label %619

590:                                              ; preds = %587
  %591 = load float*, float** %24, align 8
  %592 = load i32, i32* %27, align 4
  %593 = mul nsw i32 2, %592
  %594 = load i32, i32* %29, align 4
  %595 = add nsw i32 %593, %594
  %596 = sext i32 %595 to i64
  %597 = getelementptr inbounds float, float* %591, i64 %596
  %598 = load float, float* %597, align 4
  %599 = load float*, float** %25, align 8
  %600 = load i32, i32* %29, align 4
  %601 = mul nsw i32 2, %600
  %602 = load i32, i32* %28, align 4
  %603 = add nsw i32 %601, %602
  %604 = sext i32 %603 to i64
  %605 = getelementptr inbounds float, float* %599, i64 %604
  %606 = load float, float* %605, align 4
  %607 = fmul float %598, %606
  %608 = load float*, float** %26, align 8
  %609 = load i32, i32* %27, align 4
  %610 = mul nsw i32 2, %609
  %611 = load i32, i32* %28, align 4
  %612 = add nsw i32 %610, %611
  %613 = sext i32 %612 to i64
  %614 = getelementptr inbounds float, float* %608, i64 %613
  %615 = load float, float* %614, align 4
  %616 = fadd float %615, %607
  store float %616, float* %614, align 4
  %617 = load i32, i32* %29, align 4
  %618 = add nsw i32 %617, 1
  store i32 %618, i32* %29, align 4
  br label %587

619:                                              ; preds = %587
  %620 = load i32, i32* %28, align 4
  %621 = add nsw i32 %620, 1
  store i32 %621, i32* %28, align 4
  br label %576

622:                                              ; preds = %576
  %623 = load i32, i32* %27, align 4
  %624 = add nsw i32 %623, 1
  store i32 %624, i32* %27, align 4
  br label %572

625:                                              ; preds = %572
  store i32 0, i32* %70, align 4
  br label %626

626:                                              ; preds = %638, %625
  %627 = load i32, i32* %70, align 4
  %628 = icmp slt i32 %627, 4
  br i1 %628, label %629, label %641

629:                                              ; preds = %626
  %630 = load i32, i32* %70, align 4
  %631 = sext i32 %630 to i64
  %632 = getelementptr inbounds [4 x float], [4 x float]* %67, i64 0, i64 %631
  %633 = load float, float* %632, align 4
  %634 = load float*, float** %37, align 8
  %635 = load i32, i32* %70, align 4
  %636 = sext i32 %635 to i64
  %637 = getelementptr inbounds float, float* %634, i64 %636
  store float %633, float* %637, align 4
  br label %638

638:                                              ; preds = %629
  %639 = load i32, i32* %70, align 4
  %640 = add nsw i32 %639, 1
  store i32 %640, i32* %70, align 4
  br label %626

641:                                              ; preds = %626
  br label %642

642:                                              ; preds = %641, %482
  br label %643

643:                                              ; preds = %642
  %644 = load i32, i32* %42, align 4
  %645 = add nsw i32 %644, 1
  store i32 %645, i32* %42, align 4
  br label %116

646:                                              ; preds = %116
  %647 = load float*, float** %36, align 8
  store float* %647, float** %30, align 8
  store i32 0, i32* %31, align 4
  br label %648

648:                                              ; preds = %691, %646
  %649 = load i32, i32* %31, align 4
  %650 = icmp slt i32 %649, 2
  br i1 %650, label %651, label %694

651:                                              ; preds = %648
  %652 = load i32, i32* %31, align 4
  %653 = add nsw i32 %652, 1
  store i32 %653, i32* %32, align 4
  br label %654

654:                                              ; preds = %657, %651
  %655 = load i32, i32* %32, align 4
  %656 = icmp slt i32 %655, 2
  br i1 %656, label %657, label %691

657:                                              ; preds = %654
  %658 = load float*, float** %30, align 8
  %659 = load i32, i32* %31, align 4
  %660 = mul nsw i32 %659, 2
  %661 = load i32, i32* %32, align 4
  %662 = add nsw i32 %660, %661
  %663 = sext i32 %662 to i64
  %664 = getelementptr inbounds float, float* %658, i64 %663
  %665 = load float, float* %664, align 4
  store float %665, float* %33, align 4
  %666 = load float*, float** %30, align 8
  %667 = load i32, i32* %32, align 4
  %668 = mul nsw i32 %667, 2
  %669 = load i32, i32* %31, align 4
  %670 = add nsw i32 %668, %669
  %671 = sext i32 %670 to i64
  %672 = getelementptr inbounds float, float* %666, i64 %671
  %673 = load float, float* %672, align 4
  %674 = load float*, float** %30, align 8
  %675 = load i32, i32* %31, align 4
  %676 = mul nsw i32 %675, 2
  %677 = load i32, i32* %32, align 4
  %678 = add nsw i32 %676, %677
  %679 = sext i32 %678 to i64
  %680 = getelementptr inbounds float, float* %674, i64 %679
  store float %673, float* %680, align 4
  %681 = load float, float* %33, align 4
  %682 = load float*, float** %30, align 8
  %683 = load i32, i32* %32, align 4
  %684 = mul nsw i32 %683, 2
  %685 = load i32, i32* %31, align 4
  %686 = add nsw i32 %684, %685
  %687 = sext i32 %686 to i64
  %688 = getelementptr inbounds float, float* %682, i64 %687
  store float %681, float* %688, align 4
  %689 = load i32, i32* %32, align 4
  %690 = add nsw i32 %689, 1
  store i32 %690, i32* %32, align 4
  br label %654

691:                                              ; preds = %654
  %692 = load i32, i32* %31, align 4
  %693 = add nsw i32 %692, 1
  store i32 %693, i32* %31, align 4
  br label %648

694:                                              ; preds = %648
  ret void
}

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #3

; Function Attrs: noinline nounwind ssp uwtable
define void @no_opt_naive_fixed_qr_decomp(float* %0, float* %1, float* %2) #1 {
  %4 = alloca float*, align 8
  %5 = alloca float*, align 8
  %6 = alloca float*, align 8
  %7 = alloca float*, align 8
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  %10 = alloca i32, align 4
  %11 = alloca i32, align 4
  %12 = alloca float*, align 8
  %13 = alloca float*, align 8
  %14 = alloca i32, align 4
  %15 = alloca i32, align 4
  %16 = alloca float, align 4
  %17 = alloca float*, align 8
  %18 = alloca float*, align 8
  %19 = alloca i32, align 4
  %20 = alloca float, align 4
  %21 = alloca i32, align 4
  %22 = alloca float*, align 8
  %23 = alloca i32, align 4
  %24 = alloca i32, align 4
  %25 = alloca float, align 4
  %26 = alloca float*, align 8
  %27 = alloca i32, align 4
  %28 = alloca i32, align 4
  %29 = alloca float, align 4
  %30 = alloca float*, align 8
  store float* %0, float** %4, align 8
  store float* %1, float** %5, align 8
  store float* %2, float** %6, align 8
  %31 = load float*, float** %6, align 8
  %32 = bitcast float* %31 to i8*
  %33 = load float*, float** %4, align 8
  %34 = bitcast float* %33 to i8*
  %35 = load float*, float** %6, align 8
  %36 = bitcast float* %35 to i8*
  %37 = call i64 @llvm.objectsize.i64.p0i8(i8* %36, i1 false, i1 true, i1 false)
  %38 = call i8* @__memcpy_chk(i8* %32, i8* %34, i64 16, i64 %37) #7
  %39 = call i8* @calloc(i64 4, i64 4) #8
  %40 = bitcast i8* %39 to float*
  store float* %40, float** %7, align 8
  store i32 0, i32* %8, align 4
  br label %41

41:                                               ; preds = %65, %3
  %42 = load i32, i32* %8, align 4
  %43 = icmp slt i32 %42, 2
  br i1 %43, label %44, label %68

44:                                               ; preds = %41
  store i32 0, i32* %9, align 4
  br label %45

45:                                               ; preds = %61, %44
  %46 = load i32, i32* %9, align 4
  %47 = icmp slt i32 %46, 2
  br i1 %47, label %48, label %64

48:                                               ; preds = %45
  %49 = load i32, i32* %8, align 4
  %50 = load i32, i32* %9, align 4
  %51 = icmp eq i32 %49, %50
  %52 = zext i1 %51 to i32
  %53 = sitofp i32 %52 to float
  %54 = load float*, float** %7, align 8
  %55 = load i32, i32* %8, align 4
  %56 = mul nsw i32 %55, 2
  %57 = load i32, i32* %9, align 4
  %58 = add nsw i32 %56, %57
  %59 = sext i32 %58 to i64
  %60 = getelementptr inbounds float, float* %54, i64 %59
  store float %53, float* %60, align 4
  br label %61

61:                                               ; preds = %48
  %62 = load i32, i32* %9, align 4
  %63 = add nsw i32 %62, 1
  store i32 %63, i32* %9, align 4
  br label %45

64:                                               ; preds = %45
  br label %65

65:                                               ; preds = %64
  %66 = load i32, i32* %8, align 4
  %67 = add nsw i32 %66, 1
  store i32 %67, i32* %8, align 4
  br label %41

68:                                               ; preds = %41
  store i32 0, i32* %10, align 4
  br label %69

69:                                               ; preds = %343, %68
  %70 = load i32, i32* %10, align 4
  %71 = icmp slt i32 %70, 1
  br i1 %71, label %72, label %346

72:                                               ; preds = %69
  %73 = load i32, i32* %10, align 4
  %74 = sub nsw i32 2, %73
  store i32 %74, i32* %11, align 4
  %75 = load i32, i32* %11, align 4
  %76 = sext i32 %75 to i64
  %77 = call i8* @calloc(i64 4, i64 %76) #8
  %78 = bitcast i8* %77 to float*
  store float* %78, float** %12, align 8
  %79 = load i32, i32* %11, align 4
  %80 = sext i32 %79 to i64
  %81 = call i8* @calloc(i64 4, i64 %80) #8
  %82 = bitcast i8* %81 to float*
  store float* %82, float** %13, align 8
  store i32 0, i32* %14, align 4
  br label %83

83:                                               ; preds = %115, %72
  %84 = load i32, i32* %14, align 4
  %85 = load i32, i32* %11, align 4
  %86 = icmp slt i32 %84, %85
  br i1 %86, label %87, label %118

87:                                               ; preds = %83
  %88 = load i32, i32* %10, align 4
  %89 = load i32, i32* %14, align 4
  %90 = add nsw i32 %88, %89
  store i32 %90, i32* %15, align 4
  %91 = load float*, float** %6, align 8
  %92 = load i32, i32* %15, align 4
  %93 = mul nsw i32 %92, 2
  %94 = load i32, i32* %10, align 4
  %95 = add nsw i32 %93, %94
  %96 = sext i32 %95 to i64
  %97 = getelementptr inbounds float, float* %91, i64 %96
  %98 = load float, float* %97, align 4
  %99 = load float*, float** %12, align 8
  %100 = load i32, i32* %14, align 4
  %101 = sext i32 %100 to i64
  %102 = getelementptr inbounds float, float* %99, i64 %101
  store float %98, float* %102, align 4
  %103 = load float*, float** %7, align 8
  %104 = load i32, i32* %15, align 4
  %105 = mul nsw i32 %104, 2
  %106 = load i32, i32* %10, align 4
  %107 = add nsw i32 %105, %106
  %108 = sext i32 %107 to i64
  %109 = getelementptr inbounds float, float* %103, i64 %108
  %110 = load float, float* %109, align 4
  %111 = load float*, float** %13, align 8
  %112 = load i32, i32* %14, align 4
  %113 = sext i32 %112 to i64
  %114 = getelementptr inbounds float, float* %111, i64 %113
  store float %110, float* %114, align 4
  br label %115

115:                                              ; preds = %87
  %116 = load i32, i32* %14, align 4
  %117 = add nsw i32 %116, 1
  store i32 %117, i32* %14, align 4
  br label %83

118:                                              ; preds = %83
  %119 = load float*, float** %12, align 8
  %120 = getelementptr inbounds float, float* %119, i64 0
  %121 = load float, float* %120, align 4
  %122 = call float @no_opt_sgn(float %121)
  %123 = fneg float %122
  %124 = load float*, float** %12, align 8
  %125 = load i32, i32* %11, align 4
  %126 = call float @no_opt_naive_norm(float* %124, i32 %125)
  %127 = fmul float %123, %126
  store float %127, float* %16, align 4
  %128 = load i32, i32* %11, align 4
  %129 = sext i32 %128 to i64
  %130 = call i8* @calloc(i64 4, i64 %129) #8
  %131 = bitcast i8* %130 to float*
  store float* %131, float** %17, align 8
  %132 = load i32, i32* %11, align 4
  %133 = sext i32 %132 to i64
  %134 = call i8* @calloc(i64 4, i64 %133) #8
  %135 = bitcast i8* %134 to float*
  store float* %135, float** %18, align 8
  store i32 0, i32* %19, align 4
  br label %136

136:                                              ; preds = %158, %118
  %137 = load i32, i32* %19, align 4
  %138 = load i32, i32* %11, align 4
  %139 = icmp slt i32 %137, %138
  br i1 %139, label %140, label %161

140:                                              ; preds = %136
  %141 = load float*, float** %12, align 8
  %142 = load i32, i32* %19, align 4
  %143 = sext i32 %142 to i64
  %144 = getelementptr inbounds float, float* %141, i64 %143
  %145 = load float, float* %144, align 4
  %146 = load float, float* %16, align 4
  %147 = load float*, float** %13, align 8
  %148 = load i32, i32* %19, align 4
  %149 = sext i32 %148 to i64
  %150 = getelementptr inbounds float, float* %147, i64 %149
  %151 = load float, float* %150, align 4
  %152 = fmul float %146, %151
  %153 = fadd float %145, %152
  %154 = load float*, float** %17, align 8
  %155 = load i32, i32* %19, align 4
  %156 = sext i32 %155 to i64
  %157 = getelementptr inbounds float, float* %154, i64 %156
  store float %153, float* %157, align 4
  br label %158

158:                                              ; preds = %140
  %159 = load i32, i32* %19, align 4
  %160 = add nsw i32 %159, 1
  store i32 %160, i32* %19, align 4
  br label %136

161:                                              ; preds = %136
  %162 = load float*, float** %17, align 8
  %163 = load i32, i32* %11, align 4
  %164 = call float @no_opt_naive_norm(float* %162, i32 %163)
  store float %164, float* %20, align 4
  store i32 0, i32* %21, align 4
  br label %165

165:                                              ; preds = %182, %161
  %166 = load i32, i32* %21, align 4
  %167 = load i32, i32* %11, align 4
  %168 = icmp slt i32 %166, %167
  br i1 %168, label %169, label %185

169:                                              ; preds = %165
  %170 = load float*, float** %17, align 8
  %171 = load i32, i32* %21, align 4
  %172 = sext i32 %171 to i64
  %173 = getelementptr inbounds float, float* %170, i64 %172
  %174 = load float, float* %173, align 4
  %175 = load float, float* %20, align 4
  %176 = fadd float %175, 0x3EE4F8B580000000
  %177 = fdiv float %174, %176
  %178 = load float*, float** %18, align 8
  %179 = load i32, i32* %21, align 4
  %180 = sext i32 %179 to i64
  %181 = getelementptr inbounds float, float* %178, i64 %180
  store float %177, float* %181, align 4
  br label %182

182:                                              ; preds = %169
  %183 = load i32, i32* %21, align 4
  %184 = add nsw i32 %183, 1
  store i32 %184, i32* %21, align 4
  br label %165

185:                                              ; preds = %165
  %186 = load i32, i32* %11, align 4
  %187 = load i32, i32* %11, align 4
  %188 = mul nsw i32 %186, %187
  %189 = sext i32 %188 to i64
  %190 = call i8* @calloc(i64 4, i64 %189) #8
  %191 = bitcast i8* %190 to float*
  store float* %191, float** %22, align 8
  store i32 0, i32* %23, align 4
  br label %192

192:                                              ; preds = %233, %185
  %193 = load i32, i32* %23, align 4
  %194 = load i32, i32* %11, align 4
  %195 = icmp slt i32 %193, %194
  br i1 %195, label %196, label %236

196:                                              ; preds = %192
  store i32 0, i32* %24, align 4
  br label %197

197:                                              ; preds = %229, %196
  %198 = load i32, i32* %24, align 4
  %199 = load i32, i32* %11, align 4
  %200 = icmp slt i32 %198, %199
  br i1 %200, label %201, label %232

201:                                              ; preds = %197
  %202 = load i32, i32* %23, align 4
  %203 = load i32, i32* %24, align 4
  %204 = icmp eq i32 %202, %203
  %205 = zext i1 %204 to i64
  %206 = select i1 %204, float 1.000000e+00, float 0.000000e+00
  %207 = load float*, float** %18, align 8
  %208 = load i32, i32* %23, align 4
  %209 = sext i32 %208 to i64
  %210 = getelementptr inbounds float, float* %207, i64 %209
  %211 = load float, float* %210, align 4
  %212 = fmul float 2.000000e+00, %211
  %213 = load float*, float** %18, align 8
  %214 = load i32, i32* %24, align 4
  %215 = sext i32 %214 to i64
  %216 = getelementptr inbounds float, float* %213, i64 %215
  %217 = load float, float* %216, align 4
  %218 = fmul float %212, %217
  %219 = fsub float %206, %218
  store float %219, float* %25, align 4
  %220 = load float, float* %25, align 4
  %221 = load float*, float** %22, align 8
  %222 = load i32, i32* %23, align 4
  %223 = load i32, i32* %11, align 4
  %224 = mul nsw i32 %222, %223
  %225 = load i32, i32* %24, align 4
  %226 = add nsw i32 %224, %225
  %227 = sext i32 %226 to i64
  %228 = getelementptr inbounds float, float* %221, i64 %227
  store float %220, float* %228, align 4
  br label %229

229:                                              ; preds = %201
  %230 = load i32, i32* %24, align 4
  %231 = add nsw i32 %230, 1
  store i32 %231, i32* %24, align 4
  br label %197

232:                                              ; preds = %197
  br label %233

233:                                              ; preds = %232
  %234 = load i32, i32* %23, align 4
  %235 = add nsw i32 %234, 1
  store i32 %235, i32* %23, align 4
  br label %192

236:                                              ; preds = %192
  %237 = call i8* @calloc(i64 4, i64 4) #8
  %238 = bitcast i8* %237 to float*
  store float* %238, float** %26, align 8
  store i32 0, i32* %27, align 4
  br label %239

239:                                              ; preds = %287, %236
  %240 = load i32, i32* %27, align 4
  %241 = icmp slt i32 %240, 2
  br i1 %241, label %242, label %290

242:                                              ; preds = %239
  store i32 0, i32* %28, align 4
  br label %243

243:                                              ; preds = %283, %242
  %244 = load i32, i32* %28, align 4
  %245 = icmp slt i32 %244, 2
  br i1 %245, label %246, label %286

246:                                              ; preds = %243
  %247 = load i32, i32* %27, align 4
  %248 = load i32, i32* %10, align 4
  %249 = icmp slt i32 %247, %248
  br i1 %249, label %254, label %250

250:                                              ; preds = %246
  %251 = load i32, i32* %28, align 4
  %252 = load i32, i32* %10, align 4
  %253 = icmp slt i32 %251, %252
  br i1 %253, label %254, label %260

254:                                              ; preds = %250, %246
  %255 = load i32, i32* %27, align 4
  %256 = load i32, i32* %28, align 4
  %257 = icmp eq i32 %255, %256
  %258 = zext i1 %257 to i64
  %259 = select i1 %257, float 1.000000e+00, float 0.000000e+00
  store float %259, float* %29, align 4
  br label %274

260:                                              ; preds = %250
  %261 = load float*, float** %22, align 8
  %262 = load i32, i32* %27, align 4
  %263 = load i32, i32* %10, align 4
  %264 = sub nsw i32 %262, %263
  %265 = load i32, i32* %11, align 4
  %266 = mul nsw i32 %264, %265
  %267 = load i32, i32* %28, align 4
  %268 = load i32, i32* %10, align 4
  %269 = sub nsw i32 %267, %268
  %270 = add nsw i32 %266, %269
  %271 = sext i32 %270 to i64
  %272 = getelementptr inbounds float, float* %261, i64 %271
  %273 = load float, float* %272, align 4
  store float %273, float* %29, align 4
  br label %274

274:                                              ; preds = %260, %254
  %275 = load float, float* %29, align 4
  %276 = load float*, float** %26, align 8
  %277 = load i32, i32* %27, align 4
  %278 = mul nsw i32 %277, 2
  %279 = load i32, i32* %28, align 4
  %280 = add nsw i32 %278, %279
  %281 = sext i32 %280 to i64
  %282 = getelementptr inbounds float, float* %276, i64 %281
  store float %275, float* %282, align 4
  br label %283

283:                                              ; preds = %274
  %284 = load i32, i32* %28, align 4
  %285 = add nsw i32 %284, 1
  store i32 %285, i32* %28, align 4
  br label %243

286:                                              ; preds = %243
  br label %287

287:                                              ; preds = %286
  %288 = load i32, i32* %27, align 4
  %289 = add nsw i32 %288, 1
  store i32 %289, i32* %27, align 4
  br label %239

290:                                              ; preds = %239
  %291 = load i32, i32* %10, align 4
  %292 = icmp eq i32 %291, 0
  br i1 %292, label %293, label %305

293:                                              ; preds = %290
  %294 = load float*, float** %5, align 8
  %295 = bitcast float* %294 to i8*
  %296 = load float*, float** %26, align 8
  %297 = bitcast float* %296 to i8*
  %298 = load float*, float** %5, align 8
  %299 = bitcast float* %298 to i8*
  %300 = call i64 @llvm.objectsize.i64.p0i8(i8* %299, i1 false, i1 true, i1 false)
  %301 = call i8* @__memcpy_chk(i8* %295, i8* %297, i64 16, i64 %300) #7
  %302 = load float*, float** %26, align 8
  %303 = load float*, float** %4, align 8
  %304 = load float*, float** %6, align 8
  call void @no_opt_naive_fixed_matrix_multiply(float* %302, float* %303, float* %304)
  br label %330

305:                                              ; preds = %290
  %306 = call i8* @calloc(i64 4, i64 4) #8
  %307 = bitcast i8* %306 to float*
  store float* %307, float** %30, align 8
  %308 = load float*, float** %26, align 8
  %309 = load float*, float** %5, align 8
  %310 = load float*, float** %30, align 8
  call void @no_opt_naive_fixed_matrix_multiply(float* %308, float* %309, float* %310)
  %311 = load float*, float** %5, align 8
  %312 = bitcast float* %311 to i8*
  %313 = load float*, float** %30, align 8
  %314 = bitcast float* %313 to i8*
  %315 = load float*, float** %5, align 8
  %316 = bitcast float* %315 to i8*
  %317 = call i64 @llvm.objectsize.i64.p0i8(i8* %316, i1 false, i1 true, i1 false)
  %318 = call i8* @__memcpy_chk(i8* %312, i8* %314, i64 16, i64 %317) #7
  %319 = load float*, float** %26, align 8
  %320 = load float*, float** %6, align 8
  %321 = load float*, float** %30, align 8
  call void @no_opt_naive_fixed_matrix_multiply(float* %319, float* %320, float* %321)
  %322 = load float*, float** %6, align 8
  %323 = bitcast float* %322 to i8*
  %324 = load float*, float** %30, align 8
  %325 = bitcast float* %324 to i8*
  %326 = load float*, float** %6, align 8
  %327 = bitcast float* %326 to i8*
  %328 = call i64 @llvm.objectsize.i64.p0i8(i8* %327, i1 false, i1 true, i1 false)
  %329 = call i8* @__memcpy_chk(i8* %323, i8* %325, i64 16, i64 %328) #7
  br label %330

330:                                              ; preds = %305, %293
  %331 = load float*, float** %12, align 8
  %332 = bitcast float* %331 to i8*
  call void @free(i8* %332)
  %333 = load float*, float** %13, align 8
  %334 = bitcast float* %333 to i8*
  call void @free(i8* %334)
  %335 = load float*, float** %17, align 8
  %336 = bitcast float* %335 to i8*
  call void @free(i8* %336)
  %337 = load float*, float** %18, align 8
  %338 = bitcast float* %337 to i8*
  call void @free(i8* %338)
  %339 = load float*, float** %22, align 8
  %340 = bitcast float* %339 to i8*
  call void @free(i8* %340)
  %341 = load float*, float** %26, align 8
  %342 = bitcast float* %341 to i8*
  call void @free(i8* %342)
  br label %343

343:                                              ; preds = %330
  %344 = load i32, i32* %10, align 4
  %345 = add nsw i32 %344, 1
  store i32 %345, i32* %10, align 4
  br label %69

346:                                              ; preds = %69
  %347 = load float*, float** %5, align 8
  call void @no_opt_naive_fixed_transpose(float* %347)
  ret void
}

; Function Attrs: nounwind
declare i8* @__memcpy_chk(i8*, i8*, i64, i64) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare i64 @llvm.objectsize.i64.p0i8(i8*, i1 immarg, i1 immarg, i1 immarg) #2

; Function Attrs: allocsize(0,1)
declare i8* @calloc(i64, i64) #5

declare void @free(i8*) #6

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #1 {
  %1 = alloca i32, align 4
  %2 = alloca i64, align 8
  %3 = alloca [4 x float], align 16
  %4 = alloca i32, align 4
  %5 = alloca [4 x float], align 16
  %6 = alloca [4 x float], align 16
  %7 = alloca [4 x float], align 16
  %8 = alloca [4 x float], align 16
  %9 = alloca i32, align 4
  %10 = alloca i32, align 4
  %11 = alloca i32, align 4
  %12 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  %13 = call i64 @time(i64* null)
  store i64 %13, i64* %2, align 8
  %14 = call i64 @time(i64* %2)
  %15 = trunc i64 %14 to i32
  call void @srand(i32 %15)
  %16 = bitcast [4 x float]* %3 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %16, i8 0, i64 16, i1 false)
  store i32 0, i32* %4, align 4
  br label %17

17:                                               ; preds = %33, %0
  %18 = load i32, i32* %4, align 4
  %19 = icmp slt i32 %18, 4
  br i1 %19, label %20, label %36

20:                                               ; preds = %17
  %21 = call i32 @rand()
  %22 = sitofp i32 %21 to float
  %23 = fdiv float %22, 0x41747AE140000000
  %24 = load i32, i32* %4, align 4
  %25 = sext i32 %24 to i64
  %26 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 %25
  store float %23, float* %26, align 4
  %27 = load i32, i32* %4, align 4
  %28 = sext i32 %27 to i64
  %29 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 %28
  %30 = load float, float* %29, align 4
  %31 = fpext float %30 to double
  %32 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %31)
  br label %33

33:                                               ; preds = %20
  %34 = load i32, i32* %4, align 4
  %35 = add nsw i32 %34, 1
  store i32 %35, i32* %4, align 4
  br label %17

36:                                               ; preds = %17
  %37 = bitcast [4 x float]* %5 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %37, i8 0, i64 16, i1 false)
  %38 = bitcast [4 x float]* %6 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %38, i8 0, i64 16, i1 false)
  %39 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 0
  %40 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 0
  %41 = getelementptr inbounds [4 x float], [4 x float]* %6, i64 0, i64 0
  call void @naive_fixed_qr_decomp(float* %39, float* %40, float* %41)
  %42 = bitcast [4 x float]* %7 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %42, i8 0, i64 16, i1 false)
  %43 = bitcast [4 x float]* %8 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %43, i8 0, i64 16, i1 false)
  %44 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 0
  %45 = getelementptr inbounds [4 x float], [4 x float]* %7, i64 0, i64 0
  %46 = getelementptr inbounds [4 x float], [4 x float]* %8, i64 0, i64 0
  call void @no_opt_naive_fixed_qr_decomp(float* %44, float* %45, float* %46)
  store i32 0, i32* %9, align 4
  br label %47

47:                                               ; preds = %77, %36
  %48 = load i32, i32* %9, align 4
  %49 = icmp slt i32 %48, 2
  br i1 %49, label %50, label %80

50:                                               ; preds = %47
  store i32 0, i32* %10, align 4
  br label %51

51:                                               ; preds = %73, %50
  %52 = load i32, i32* %10, align 4
  %53 = icmp slt i32 %52, 2
  br i1 %53, label %54, label %76

54:                                               ; preds = %51
  %55 = load i32, i32* %9, align 4
  %56 = mul nsw i32 %55, 2
  %57 = load i32, i32* %10, align 4
  %58 = add nsw i32 %56, %57
  %59 = sext i32 %58 to i64
  %60 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 %59
  %61 = load float, float* %60, align 4
  %62 = fpext float %61 to double
  %63 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.1, i64 0, i64 0), double %62)
  %64 = load i32, i32* %9, align 4
  %65 = mul nsw i32 %64, 2
  %66 = load i32, i32* %10, align 4
  %67 = add nsw i32 %65, %66
  %68 = sext i32 %67 to i64
  %69 = getelementptr inbounds [4 x float], [4 x float]* %7, i64 0, i64 %68
  %70 = load float, float* %69, align 4
  %71 = fpext float %70 to double
  %72 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([23 x i8], [23 x i8]* @.str.2, i64 0, i64 0), double %71)
  br label %73

73:                                               ; preds = %54
  %74 = load i32, i32* %10, align 4
  %75 = add nsw i32 %74, 1
  store i32 %75, i32* %10, align 4
  br label %51

76:                                               ; preds = %51
  br label %77

77:                                               ; preds = %76
  %78 = load i32, i32* %9, align 4
  %79 = add nsw i32 %78, 1
  store i32 %79, i32* %9, align 4
  br label %47

80:                                               ; preds = %47
  store i32 0, i32* %11, align 4
  br label %81

81:                                               ; preds = %111, %80
  %82 = load i32, i32* %11, align 4
  %83 = icmp slt i32 %82, 2
  br i1 %83, label %84, label %114

84:                                               ; preds = %81
  store i32 0, i32* %12, align 4
  br label %85

85:                                               ; preds = %107, %84
  %86 = load i32, i32* %12, align 4
  %87 = icmp slt i32 %86, 2
  br i1 %87, label %88, label %110

88:                                               ; preds = %85
  %89 = load i32, i32* %11, align 4
  %90 = mul nsw i32 %89, 2
  %91 = load i32, i32* %12, align 4
  %92 = add nsw i32 %90, %91
  %93 = sext i32 %92 to i64
  %94 = getelementptr inbounds [4 x float], [4 x float]* %6, i64 0, i64 %93
  %95 = load float, float* %94, align 4
  %96 = fpext float %95 to double
  %97 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.3, i64 0, i64 0), double %96)
  %98 = load i32, i32* %11, align 4
  %99 = mul nsw i32 %98, 2
  %100 = load i32, i32* %12, align 4
  %101 = add nsw i32 %99, %100
  %102 = sext i32 %101 to i64
  %103 = getelementptr inbounds [4 x float], [4 x float]* %8, i64 0, i64 %102
  %104 = load float, float* %103, align 4
  %105 = fpext float %104 to double
  %106 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([23 x i8], [23 x i8]* @.str.4, i64 0, i64 0), double %105)
  br label %107

107:                                              ; preds = %88
  %108 = load i32, i32* %12, align 4
  %109 = add nsw i32 %108, 1
  store i32 %109, i32* %12, align 4
  br label %85

110:                                              ; preds = %85
  br label %111

111:                                              ; preds = %110
  %112 = load i32, i32* %11, align 4
  %113 = add nsw i32 %112, 1
  store i32 %113, i32* %11, align 4
  br label %81

114:                                              ; preds = %81
  %115 = load i32, i32* %1, align 4
  ret i32 %115
}

declare i64 @time(i64*) #6

declare void @srand(i32) #6

declare i32 @rand() #6

declare i32 @printf(i8*, ...) #6

attributes #0 = { alwaysinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind readnone speculatable willreturn }
attributes #3 = { argmemonly nounwind willreturn writeonly }
attributes #4 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { allocsize(0,1) "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { nounwind }
attributes #8 = { allocsize(0,1) }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
