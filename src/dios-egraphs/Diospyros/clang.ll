; ModuleID = 'llvm-tests/q-prod.c'
source_filename = "llvm-tests/q-prod.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.a_q = private unnamed_addr constant [4 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00], align 16
@__const.main.a_t = private unnamed_addr constant [4 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00], align 16
@__const.main.b_t = private unnamed_addr constant [4 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00], align 16
@.str = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1

; Function Attrs: alwaysinline nounwind ssp uwtable
define void @naive_cross_product(float* %0, float* %1, float* %2) #0 {
  %4 = alloca float*, align 8
  %5 = alloca float*, align 8
  %6 = alloca float*, align 8
  store float* %0, float** %4, align 8
  store float* %1, float** %5, align 8
  store float* %2, float** %6, align 8
  %7 = load float*, float** %4, align 8
  %8 = getelementptr inbounds float, float* %7, i64 1
  %9 = load float, float* %8, align 4
  %10 = load float*, float** %5, align 8
  %11 = getelementptr inbounds float, float* %10, i64 2
  %12 = load float, float* %11, align 4
  %13 = fmul float %9, %12
  %14 = load float*, float** %4, align 8
  %15 = getelementptr inbounds float, float* %14, i64 2
  %16 = load float, float* %15, align 4
  %17 = load float*, float** %5, align 8
  %18 = getelementptr inbounds float, float* %17, i64 1
  %19 = load float, float* %18, align 4
  %20 = fmul float %16, %19
  %21 = fsub float %13, %20
  %22 = load float*, float** %6, align 8
  %23 = getelementptr inbounds float, float* %22, i64 0
  store float %21, float* %23, align 4
  %24 = load float*, float** %4, align 8
  %25 = getelementptr inbounds float, float* %24, i64 2
  %26 = load float, float* %25, align 4
  %27 = load float*, float** %5, align 8
  %28 = getelementptr inbounds float, float* %27, i64 0
  %29 = load float, float* %28, align 4
  %30 = fmul float %26, %29
  %31 = load float*, float** %4, align 8
  %32 = getelementptr inbounds float, float* %31, i64 0
  %33 = load float, float* %32, align 4
  %34 = load float*, float** %5, align 8
  %35 = getelementptr inbounds float, float* %34, i64 2
  %36 = load float, float* %35, align 4
  %37 = fmul float %33, %36
  %38 = fsub float %30, %37
  %39 = load float*, float** %6, align 8
  %40 = getelementptr inbounds float, float* %39, i64 1
  store float %38, float* %40, align 4
  %41 = load float*, float** %4, align 8
  %42 = getelementptr inbounds float, float* %41, i64 0
  %43 = load float, float* %42, align 4
  %44 = load float*, float** %5, align 8
  %45 = getelementptr inbounds float, float* %44, i64 1
  %46 = load float, float* %45, align 4
  %47 = fmul float %43, %46
  %48 = load float*, float** %4, align 8
  %49 = getelementptr inbounds float, float* %48, i64 1
  %50 = load float, float* %49, align 4
  %51 = load float*, float** %5, align 8
  %52 = getelementptr inbounds float, float* %51, i64 0
  %53 = load float, float* %52, align 4
  %54 = fmul float %50, %53
  %55 = fsub float %47, %54
  %56 = load float*, float** %6, align 8
  %57 = getelementptr inbounds float, float* %56, i64 2
  store float %55, float* %57, align 4
  ret void
}

; Function Attrs: alwaysinline nounwind ssp uwtable
define void @naive_point_product(float* %0, float* %1, float* %2) #0 {
  %4 = alloca float*, align 8
  %5 = alloca float*, align 8
  %6 = alloca float*, align 8
  %7 = alloca float*, align 8
  %8 = alloca float*, align 8
  %9 = alloca float*, align 8
  %10 = alloca float*, align 8
  %11 = alloca float*, align 8
  %12 = alloca float*, align 8
  %13 = alloca [3 x float], align 4
  %14 = alloca [3 x float], align 4
  %15 = alloca i32, align 4
  %16 = alloca [3 x float], align 4
  %17 = alloca i32, align 4
  store float* %0, float** %10, align 8
  store float* %1, float** %11, align 8
  store float* %2, float** %12, align 8
  %18 = getelementptr inbounds [3 x float], [3 x float]* %13, i64 0, i64 0
  %19 = load float*, float** %10, align 8
  %20 = getelementptr inbounds float, float* %19, i64 0
  %21 = load float, float* %20, align 4
  store float %21, float* %18, align 4
  %22 = getelementptr inbounds float, float* %18, i64 1
  %23 = load float*, float** %10, align 8
  %24 = getelementptr inbounds float, float* %23, i64 1
  %25 = load float, float* %24, align 4
  store float %25, float* %22, align 4
  %26 = getelementptr inbounds float, float* %22, i64 1
  %27 = load float*, float** %10, align 8
  %28 = getelementptr inbounds float, float* %27, i64 2
  %29 = load float, float* %28, align 4
  store float %29, float* %26, align 4
  %30 = getelementptr inbounds [3 x float], [3 x float]* %13, i64 0, i64 0
  %31 = load float*, float** %11, align 8
  %32 = getelementptr inbounds [3 x float], [3 x float]* %14, i64 0, i64 0
  store float* %30, float** %7, align 8
  store float* %31, float** %8, align 8
  store float* %32, float** %9, align 8
  %33 = load float*, float** %7, align 8
  %34 = getelementptr inbounds float, float* %33, i64 1
  %35 = load float, float* %34, align 4
  %36 = load float*, float** %8, align 8
  %37 = getelementptr inbounds float, float* %36, i64 2
  %38 = load float, float* %37, align 4
  %39 = fmul float %35, %38
  %40 = load float*, float** %7, align 8
  %41 = getelementptr inbounds float, float* %40, i64 2
  %42 = load float, float* %41, align 4
  %43 = load float*, float** %8, align 8
  %44 = getelementptr inbounds float, float* %43, i64 1
  %45 = load float, float* %44, align 4
  %46 = fmul float %42, %45
  %47 = fsub float %39, %46
  %48 = load float*, float** %9, align 8
  store float %47, float* %48, align 4
  %49 = load float*, float** %7, align 8
  %50 = getelementptr inbounds float, float* %49, i64 2
  %51 = load float, float* %50, align 4
  %52 = load float*, float** %8, align 8
  %53 = load float, float* %52, align 4
  %54 = fmul float %51, %53
  %55 = load float*, float** %7, align 8
  %56 = load float, float* %55, align 4
  %57 = load float*, float** %8, align 8
  %58 = getelementptr inbounds float, float* %57, i64 2
  %59 = load float, float* %58, align 4
  %60 = fmul float %56, %59
  %61 = fsub float %54, %60
  %62 = load float*, float** %9, align 8
  %63 = getelementptr inbounds float, float* %62, i64 1
  store float %61, float* %63, align 4
  %64 = load float*, float** %7, align 8
  %65 = load float, float* %64, align 4
  %66 = load float*, float** %8, align 8
  %67 = getelementptr inbounds float, float* %66, i64 1
  %68 = load float, float* %67, align 4
  %69 = fmul float %65, %68
  %70 = load float*, float** %7, align 8
  %71 = getelementptr inbounds float, float* %70, i64 1
  %72 = load float, float* %71, align 4
  %73 = load float*, float** %8, align 8
  %74 = load float, float* %73, align 4
  %75 = fmul float %72, %74
  %76 = fsub float %69, %75
  %77 = load float*, float** %9, align 8
  %78 = getelementptr inbounds float, float* %77, i64 2
  store float %76, float* %78, align 4
  store i32 0, i32* %15, align 4
  br label %79

79:                                               ; preds = %91, %3
  %80 = load i32, i32* %15, align 4
  %81 = icmp slt i32 %80, 3
  br i1 %81, label %82, label %94

82:                                               ; preds = %79
  %83 = load i32, i32* %15, align 4
  %84 = sext i32 %83 to i64
  %85 = getelementptr inbounds [3 x float], [3 x float]* %14, i64 0, i64 %84
  %86 = load float, float* %85, align 4
  %87 = fmul float %86, 2.000000e+00
  %88 = load i32, i32* %15, align 4
  %89 = sext i32 %88 to i64
  %90 = getelementptr inbounds [3 x float], [3 x float]* %14, i64 0, i64 %89
  store float %87, float* %90, align 4
  br label %91

91:                                               ; preds = %82
  %92 = load i32, i32* %15, align 4
  %93 = add nsw i32 %92, 1
  store i32 %93, i32* %15, align 4
  br label %79

94:                                               ; preds = %79
  %95 = getelementptr inbounds [3 x float], [3 x float]* %13, i64 0, i64 0
  %96 = getelementptr inbounds [3 x float], [3 x float]* %14, i64 0, i64 0
  %97 = getelementptr inbounds [3 x float], [3 x float]* %16, i64 0, i64 0
  store float* %95, float** %4, align 8
  store float* %96, float** %5, align 8
  store float* %97, float** %6, align 8
  %98 = load float*, float** %4, align 8
  %99 = getelementptr inbounds float, float* %98, i64 1
  %100 = load float, float* %99, align 4
  %101 = load float*, float** %5, align 8
  %102 = getelementptr inbounds float, float* %101, i64 2
  %103 = load float, float* %102, align 4
  %104 = fmul float %100, %103
  %105 = load float*, float** %4, align 8
  %106 = getelementptr inbounds float, float* %105, i64 2
  %107 = load float, float* %106, align 4
  %108 = load float*, float** %5, align 8
  %109 = getelementptr inbounds float, float* %108, i64 1
  %110 = load float, float* %109, align 4
  %111 = fmul float %107, %110
  %112 = fsub float %104, %111
  %113 = load float*, float** %6, align 8
  store float %112, float* %113, align 4
  %114 = load float*, float** %4, align 8
  %115 = getelementptr inbounds float, float* %114, i64 2
  %116 = load float, float* %115, align 4
  %117 = load float*, float** %5, align 8
  %118 = load float, float* %117, align 4
  %119 = fmul float %116, %118
  %120 = load float*, float** %4, align 8
  %121 = load float, float* %120, align 4
  %122 = load float*, float** %5, align 8
  %123 = getelementptr inbounds float, float* %122, i64 2
  %124 = load float, float* %123, align 4
  %125 = fmul float %121, %124
  %126 = fsub float %119, %125
  %127 = load float*, float** %6, align 8
  %128 = getelementptr inbounds float, float* %127, i64 1
  store float %126, float* %128, align 4
  %129 = load float*, float** %4, align 8
  %130 = load float, float* %129, align 4
  %131 = load float*, float** %5, align 8
  %132 = getelementptr inbounds float, float* %131, i64 1
  %133 = load float, float* %132, align 4
  %134 = fmul float %130, %133
  %135 = load float*, float** %4, align 8
  %136 = getelementptr inbounds float, float* %135, i64 1
  %137 = load float, float* %136, align 4
  %138 = load float*, float** %5, align 8
  %139 = load float, float* %138, align 4
  %140 = fmul float %137, %139
  %141 = fsub float %134, %140
  %142 = load float*, float** %6, align 8
  %143 = getelementptr inbounds float, float* %142, i64 2
  store float %141, float* %143, align 4
  store i32 0, i32* %17, align 4
  br label %144

144:                                              ; preds = %171, %94
  %145 = load i32, i32* %17, align 4
  %146 = icmp slt i32 %145, 3
  br i1 %146, label %147, label %174

147:                                              ; preds = %144
  %148 = load float*, float** %11, align 8
  %149 = load i32, i32* %17, align 4
  %150 = sext i32 %149 to i64
  %151 = getelementptr inbounds float, float* %148, i64 %150
  %152 = load float, float* %151, align 4
  %153 = load float*, float** %10, align 8
  %154 = getelementptr inbounds float, float* %153, i64 3
  %155 = load float, float* %154, align 4
  %156 = load i32, i32* %17, align 4
  %157 = sext i32 %156 to i64
  %158 = getelementptr inbounds [3 x float], [3 x float]* %14, i64 0, i64 %157
  %159 = load float, float* %158, align 4
  %160 = fmul float %155, %159
  %161 = fadd float %152, %160
  %162 = load i32, i32* %17, align 4
  %163 = sext i32 %162 to i64
  %164 = getelementptr inbounds [3 x float], [3 x float]* %16, i64 0, i64 %163
  %165 = load float, float* %164, align 4
  %166 = fadd float %161, %165
  %167 = load float*, float** %12, align 8
  %168 = load i32, i32* %17, align 4
  %169 = sext i32 %168 to i64
  %170 = getelementptr inbounds float, float* %167, i64 %169
  store float %166, float* %170, align 4
  br label %171

171:                                              ; preds = %147
  %172 = load i32, i32* %17, align 4
  %173 = add nsw i32 %172, 1
  store i32 %173, i32* %17, align 4
  br label %144

174:                                              ; preds = %144
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define void @naive_quaternion_product(float* %0, float* %1, float* %2, float* %3, float* %4, float* %5) #1 {
  %7 = alloca float*, align 8
  %8 = alloca float*, align 8
  %9 = alloca float*, align 8
  %10 = alloca float*, align 8
  %11 = alloca float*, align 8
  %12 = alloca float*, align 8
  %13 = alloca float*, align 8
  %14 = alloca float*, align 8
  %15 = alloca float*, align 8
  %16 = alloca [3 x float], align 4
  %17 = alloca [3 x float], align 4
  %18 = alloca i32, align 4
  %19 = alloca [3 x float], align 4
  %20 = alloca i32, align 4
  %21 = alloca float*, align 8
  %22 = alloca float*, align 8
  %23 = alloca float*, align 8
  %24 = alloca float*, align 8
  %25 = alloca float*, align 8
  %26 = alloca float*, align 8
  %27 = alloca i32, align 4
  store float* %0, float** %21, align 8
  store float* %1, float** %22, align 8
  store float* %2, float** %23, align 8
  store float* %3, float** %24, align 8
  store float* %4, float** %25, align 8
  store float* %5, float** %26, align 8
  %28 = load float*, float** %21, align 8
  %29 = getelementptr inbounds float, float* %28, i64 3
  %30 = load float, float* %29, align 4
  %31 = load float*, float** %23, align 8
  %32 = getelementptr inbounds float, float* %31, i64 3
  %33 = load float, float* %32, align 4
  %34 = fmul float %30, %33
  %35 = load float*, float** %21, align 8
  %36 = getelementptr inbounds float, float* %35, i64 0
  %37 = load float, float* %36, align 4
  %38 = load float*, float** %23, align 8
  %39 = getelementptr inbounds float, float* %38, i64 0
  %40 = load float, float* %39, align 4
  %41 = fmul float %37, %40
  %42 = fsub float %34, %41
  %43 = load float*, float** %21, align 8
  %44 = getelementptr inbounds float, float* %43, i64 1
  %45 = load float, float* %44, align 4
  %46 = load float*, float** %23, align 8
  %47 = getelementptr inbounds float, float* %46, i64 1
  %48 = load float, float* %47, align 4
  %49 = fmul float %45, %48
  %50 = fsub float %42, %49
  %51 = load float*, float** %21, align 8
  %52 = getelementptr inbounds float, float* %51, i64 2
  %53 = load float, float* %52, align 4
  %54 = load float*, float** %23, align 8
  %55 = getelementptr inbounds float, float* %54, i64 2
  %56 = load float, float* %55, align 4
  %57 = fmul float %53, %56
  %58 = fsub float %50, %57
  %59 = load float*, float** %25, align 8
  %60 = getelementptr inbounds float, float* %59, i64 3
  store float %58, float* %60, align 4
  %61 = load float*, float** %21, align 8
  %62 = getelementptr inbounds float, float* %61, i64 3
  %63 = load float, float* %62, align 4
  %64 = load float*, float** %23, align 8
  %65 = getelementptr inbounds float, float* %64, i64 0
  %66 = load float, float* %65, align 4
  %67 = fmul float %63, %66
  %68 = load float*, float** %21, align 8
  %69 = getelementptr inbounds float, float* %68, i64 0
  %70 = load float, float* %69, align 4
  %71 = load float*, float** %23, align 8
  %72 = getelementptr inbounds float, float* %71, i64 3
  %73 = load float, float* %72, align 4
  %74 = fmul float %70, %73
  %75 = fadd float %67, %74
  %76 = load float*, float** %21, align 8
  %77 = getelementptr inbounds float, float* %76, i64 1
  %78 = load float, float* %77, align 4
  %79 = load float*, float** %23, align 8
  %80 = getelementptr inbounds float, float* %79, i64 2
  %81 = load float, float* %80, align 4
  %82 = fmul float %78, %81
  %83 = fadd float %75, %82
  %84 = load float*, float** %21, align 8
  %85 = getelementptr inbounds float, float* %84, i64 2
  %86 = load float, float* %85, align 4
  %87 = load float*, float** %23, align 8
  %88 = getelementptr inbounds float, float* %87, i64 1
  %89 = load float, float* %88, align 4
  %90 = fmul float %86, %89
  %91 = fsub float %83, %90
  %92 = load float*, float** %25, align 8
  %93 = getelementptr inbounds float, float* %92, i64 0
  store float %91, float* %93, align 4
  %94 = load float*, float** %21, align 8
  %95 = getelementptr inbounds float, float* %94, i64 3
  %96 = load float, float* %95, align 4
  %97 = load float*, float** %23, align 8
  %98 = getelementptr inbounds float, float* %97, i64 1
  %99 = load float, float* %98, align 4
  %100 = fmul float %96, %99
  %101 = load float*, float** %21, align 8
  %102 = getelementptr inbounds float, float* %101, i64 1
  %103 = load float, float* %102, align 4
  %104 = load float*, float** %23, align 8
  %105 = getelementptr inbounds float, float* %104, i64 3
  %106 = load float, float* %105, align 4
  %107 = fmul float %103, %106
  %108 = fadd float %100, %107
  %109 = load float*, float** %21, align 8
  %110 = getelementptr inbounds float, float* %109, i64 2
  %111 = load float, float* %110, align 4
  %112 = load float*, float** %23, align 8
  %113 = getelementptr inbounds float, float* %112, i64 0
  %114 = load float, float* %113, align 4
  %115 = fmul float %111, %114
  %116 = fadd float %108, %115
  %117 = load float*, float** %21, align 8
  %118 = getelementptr inbounds float, float* %117, i64 0
  %119 = load float, float* %118, align 4
  %120 = load float*, float** %23, align 8
  %121 = getelementptr inbounds float, float* %120, i64 2
  %122 = load float, float* %121, align 4
  %123 = fmul float %119, %122
  %124 = fsub float %116, %123
  %125 = load float*, float** %25, align 8
  %126 = getelementptr inbounds float, float* %125, i64 1
  store float %124, float* %126, align 4
  %127 = load float*, float** %21, align 8
  %128 = getelementptr inbounds float, float* %127, i64 3
  %129 = load float, float* %128, align 4
  %130 = load float*, float** %23, align 8
  %131 = getelementptr inbounds float, float* %130, i64 2
  %132 = load float, float* %131, align 4
  %133 = fmul float %129, %132
  %134 = load float*, float** %21, align 8
  %135 = getelementptr inbounds float, float* %134, i64 2
  %136 = load float, float* %135, align 4
  %137 = load float*, float** %23, align 8
  %138 = getelementptr inbounds float, float* %137, i64 3
  %139 = load float, float* %138, align 4
  %140 = fmul float %136, %139
  %141 = fadd float %133, %140
  %142 = load float*, float** %21, align 8
  %143 = getelementptr inbounds float, float* %142, i64 0
  %144 = load float, float* %143, align 4
  %145 = load float*, float** %23, align 8
  %146 = getelementptr inbounds float, float* %145, i64 1
  %147 = load float, float* %146, align 4
  %148 = fmul float %144, %147
  %149 = fadd float %141, %148
  %150 = load float*, float** %21, align 8
  %151 = getelementptr inbounds float, float* %150, i64 1
  %152 = load float, float* %151, align 4
  %153 = load float*, float** %23, align 8
  %154 = getelementptr inbounds float, float* %153, i64 0
  %155 = load float, float* %154, align 4
  %156 = fmul float %152, %155
  %157 = fsub float %149, %156
  %158 = load float*, float** %25, align 8
  %159 = getelementptr inbounds float, float* %158, i64 2
  store float %157, float* %159, align 4
  %160 = load float*, float** %21, align 8
  %161 = load float*, float** %24, align 8
  %162 = load float*, float** %26, align 8
  store float* %160, float** %13, align 8
  store float* %161, float** %14, align 8
  store float* %162, float** %15, align 8
  %163 = getelementptr inbounds [3 x float], [3 x float]* %16, i64 0, i64 0
  %164 = load float*, float** %13, align 8
  %165 = load float, float* %164, align 4
  store float %165, float* %163, align 4
  %166 = getelementptr inbounds float, float* %163, i64 1
  %167 = load float*, float** %13, align 8
  %168 = getelementptr inbounds float, float* %167, i64 1
  %169 = load float, float* %168, align 4
  store float %169, float* %166, align 4
  %170 = getelementptr inbounds float, float* %166, i64 1
  %171 = load float*, float** %13, align 8
  %172 = getelementptr inbounds float, float* %171, i64 2
  %173 = load float, float* %172, align 4
  store float %173, float* %170, align 4
  %174 = getelementptr inbounds [3 x float], [3 x float]* %16, i64 0, i64 0
  %175 = load float*, float** %14, align 8
  %176 = getelementptr inbounds [3 x float], [3 x float]* %17, i64 0, i64 0
  store float* %174, float** %10, align 8
  store float* %175, float** %11, align 8
  store float* %176, float** %12, align 8
  %177 = load float*, float** %10, align 8
  %178 = getelementptr inbounds float, float* %177, i64 1
  %179 = load float, float* %178, align 4
  %180 = load float*, float** %11, align 8
  %181 = getelementptr inbounds float, float* %180, i64 2
  %182 = load float, float* %181, align 4
  %183 = fmul float %179, %182
  %184 = load float*, float** %10, align 8
  %185 = getelementptr inbounds float, float* %184, i64 2
  %186 = load float, float* %185, align 4
  %187 = load float*, float** %11, align 8
  %188 = getelementptr inbounds float, float* %187, i64 1
  %189 = load float, float* %188, align 4
  %190 = fmul float %186, %189
  %191 = fsub float %183, %190
  %192 = load float*, float** %12, align 8
  store float %191, float* %192, align 4
  %193 = load float*, float** %10, align 8
  %194 = getelementptr inbounds float, float* %193, i64 2
  %195 = load float, float* %194, align 4
  %196 = load float*, float** %11, align 8
  %197 = load float, float* %196, align 4
  %198 = fmul float %195, %197
  %199 = load float*, float** %10, align 8
  %200 = load float, float* %199, align 4
  %201 = load float*, float** %11, align 8
  %202 = getelementptr inbounds float, float* %201, i64 2
  %203 = load float, float* %202, align 4
  %204 = fmul float %200, %203
  %205 = fsub float %198, %204
  %206 = load float*, float** %12, align 8
  %207 = getelementptr inbounds float, float* %206, i64 1
  store float %205, float* %207, align 4
  %208 = load float*, float** %10, align 8
  %209 = load float, float* %208, align 4
  %210 = load float*, float** %11, align 8
  %211 = getelementptr inbounds float, float* %210, i64 1
  %212 = load float, float* %211, align 4
  %213 = fmul float %209, %212
  %214 = load float*, float** %10, align 8
  %215 = getelementptr inbounds float, float* %214, i64 1
  %216 = load float, float* %215, align 4
  %217 = load float*, float** %11, align 8
  %218 = load float, float* %217, align 4
  %219 = fmul float %216, %218
  %220 = fsub float %213, %219
  %221 = load float*, float** %12, align 8
  %222 = getelementptr inbounds float, float* %221, i64 2
  store float %220, float* %222, align 4
  store i32 0, i32* %18, align 4
  br label %223

223:                                              ; preds = %226, %6
  %224 = load i32, i32* %18, align 4
  %225 = icmp slt i32 %224, 3
  br i1 %225, label %226, label %237

226:                                              ; preds = %223
  %227 = load i32, i32* %18, align 4
  %228 = sext i32 %227 to i64
  %229 = getelementptr inbounds [3 x float], [3 x float]* %17, i64 0, i64 %228
  %230 = load float, float* %229, align 4
  %231 = fmul float %230, 2.000000e+00
  %232 = load i32, i32* %18, align 4
  %233 = sext i32 %232 to i64
  %234 = getelementptr inbounds [3 x float], [3 x float]* %17, i64 0, i64 %233
  store float %231, float* %234, align 4
  %235 = load i32, i32* %18, align 4
  %236 = add nsw i32 %235, 1
  store i32 %236, i32* %18, align 4
  br label %223

237:                                              ; preds = %223
  %238 = getelementptr inbounds [3 x float], [3 x float]* %16, i64 0, i64 0
  %239 = getelementptr inbounds [3 x float], [3 x float]* %17, i64 0, i64 0
  %240 = getelementptr inbounds [3 x float], [3 x float]* %19, i64 0, i64 0
  store float* %238, float** %7, align 8
  store float* %239, float** %8, align 8
  store float* %240, float** %9, align 8
  %241 = load float*, float** %7, align 8
  %242 = getelementptr inbounds float, float* %241, i64 1
  %243 = load float, float* %242, align 4
  %244 = load float*, float** %8, align 8
  %245 = getelementptr inbounds float, float* %244, i64 2
  %246 = load float, float* %245, align 4
  %247 = fmul float %243, %246
  %248 = load float*, float** %7, align 8
  %249 = getelementptr inbounds float, float* %248, i64 2
  %250 = load float, float* %249, align 4
  %251 = load float*, float** %8, align 8
  %252 = getelementptr inbounds float, float* %251, i64 1
  %253 = load float, float* %252, align 4
  %254 = fmul float %250, %253
  %255 = fsub float %247, %254
  %256 = load float*, float** %9, align 8
  store float %255, float* %256, align 4
  %257 = load float*, float** %7, align 8
  %258 = getelementptr inbounds float, float* %257, i64 2
  %259 = load float, float* %258, align 4
  %260 = load float*, float** %8, align 8
  %261 = load float, float* %260, align 4
  %262 = fmul float %259, %261
  %263 = load float*, float** %7, align 8
  %264 = load float, float* %263, align 4
  %265 = load float*, float** %8, align 8
  %266 = getelementptr inbounds float, float* %265, i64 2
  %267 = load float, float* %266, align 4
  %268 = fmul float %264, %267
  %269 = fsub float %262, %268
  %270 = load float*, float** %9, align 8
  %271 = getelementptr inbounds float, float* %270, i64 1
  store float %269, float* %271, align 4
  %272 = load float*, float** %7, align 8
  %273 = load float, float* %272, align 4
  %274 = load float*, float** %8, align 8
  %275 = getelementptr inbounds float, float* %274, i64 1
  %276 = load float, float* %275, align 4
  %277 = fmul float %273, %276
  %278 = load float*, float** %7, align 8
  %279 = getelementptr inbounds float, float* %278, i64 1
  %280 = load float, float* %279, align 4
  %281 = load float*, float** %8, align 8
  %282 = load float, float* %281, align 4
  %283 = fmul float %280, %282
  %284 = fsub float %277, %283
  %285 = load float*, float** %9, align 8
  %286 = getelementptr inbounds float, float* %285, i64 2
  store float %284, float* %286, align 4
  store i32 0, i32* %20, align 4
  br label %287

287:                                              ; preds = %290, %237
  %288 = load i32, i32* %20, align 4
  %289 = icmp slt i32 %288, 3
  br i1 %289, label %290, label %316

290:                                              ; preds = %287
  %291 = load float*, float** %14, align 8
  %292 = load i32, i32* %20, align 4
  %293 = sext i32 %292 to i64
  %294 = getelementptr inbounds float, float* %291, i64 %293
  %295 = load float, float* %294, align 4
  %296 = load float*, float** %13, align 8
  %297 = getelementptr inbounds float, float* %296, i64 3
  %298 = load float, float* %297, align 4
  %299 = load i32, i32* %20, align 4
  %300 = sext i32 %299 to i64
  %301 = getelementptr inbounds [3 x float], [3 x float]* %17, i64 0, i64 %300
  %302 = load float, float* %301, align 4
  %303 = fmul float %298, %302
  %304 = fadd float %295, %303
  %305 = load i32, i32* %20, align 4
  %306 = sext i32 %305 to i64
  %307 = getelementptr inbounds [3 x float], [3 x float]* %19, i64 0, i64 %306
  %308 = load float, float* %307, align 4
  %309 = fadd float %304, %308
  %310 = load float*, float** %15, align 8
  %311 = load i32, i32* %20, align 4
  %312 = sext i32 %311 to i64
  %313 = getelementptr inbounds float, float* %310, i64 %312
  store float %309, float* %313, align 4
  %314 = load i32, i32* %20, align 4
  %315 = add nsw i32 %314, 1
  store i32 %315, i32* %20, align 4
  br label %287

316:                                              ; preds = %287
  store i32 0, i32* %27, align 4
  br label %317

317:                                              ; preds = %332, %316
  %318 = load i32, i32* %27, align 4
  %319 = icmp slt i32 %318, 3
  br i1 %319, label %320, label %335

320:                                              ; preds = %317
  %321 = load float*, float** %22, align 8
  %322 = load i32, i32* %27, align 4
  %323 = sext i32 %322 to i64
  %324 = getelementptr inbounds float, float* %321, i64 %323
  %325 = load float, float* %324, align 4
  %326 = load float*, float** %26, align 8
  %327 = load i32, i32* %27, align 4
  %328 = sext i32 %327 to i64
  %329 = getelementptr inbounds float, float* %326, i64 %328
  %330 = load float, float* %329, align 4
  %331 = fadd float %330, %325
  store float %331, float* %329, align 4
  br label %332

332:                                              ; preds = %320
  %333 = load i32, i32* %27, align 4
  %334 = add nsw i32 %333, 1
  store i32 %334, i32* %27, align 4
  br label %317

335:                                              ; preds = %317
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #1 {
  %1 = alloca i32, align 4
  %2 = alloca [4 x float], align 16
  %3 = alloca [4 x float], align 16
  %4 = alloca [4 x float], align 16
  %5 = alloca [4 x float], align 16
  %6 = alloca [4 x float], align 16
  %7 = alloca [4 x float], align 16
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  %10 = bitcast [4 x float]* %2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %10, i8* align 16 bitcast ([4 x float]* @__const.main.a_q to i8*), i64 16, i1 false)
  %11 = bitcast [4 x float]* %3 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %11, i8* align 16 bitcast ([4 x float]* @__const.main.a_t to i8*), i64 16, i1 false)
  %12 = bitcast [4 x float]* %4 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %12, i8 0, i64 16, i1 false)
  %13 = bitcast [4 x float]* %5 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %13, i8* align 16 bitcast ([4 x float]* @__const.main.b_t to i8*), i64 16, i1 false)
  %14 = bitcast [4 x float]* %6 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %14, i8 0, i64 16, i1 false)
  %15 = bitcast [4 x float]* %7 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %15, i8 0, i64 16, i1 false)
  %16 = getelementptr inbounds [4 x float], [4 x float]* %2, i64 0, i64 0
  %17 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 0
  %18 = getelementptr inbounds [4 x float], [4 x float]* %4, i64 0, i64 0
  %19 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 0
  %20 = getelementptr inbounds [4 x float], [4 x float]* %6, i64 0, i64 0
  %21 = getelementptr inbounds [4 x float], [4 x float]* %7, i64 0, i64 0
  call void @naive_quaternion_product(float* %16, float* %17, float* %18, float* %19, float* %20, float* %21)
  store i32 0, i32* %8, align 4
  br label %22

22:                                               ; preds = %32, %0
  %23 = load i32, i32* %8, align 4
  %24 = icmp slt i32 %23, 4
  br i1 %24, label %25, label %35

25:                                               ; preds = %22
  %26 = load i32, i32* %8, align 4
  %27 = sext i32 %26 to i64
  %28 = getelementptr inbounds [4 x float], [4 x float]* %6, i64 0, i64 %27
  %29 = load float, float* %28, align 4
  %30 = fpext float %29 to double
  %31 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %30)
  br label %32

32:                                               ; preds = %25
  %33 = load i32, i32* %8, align 4
  %34 = add nsw i32 %33, 1
  store i32 %34, i32* %8, align 4
  br label %22

35:                                               ; preds = %22
  store i32 0, i32* %9, align 4
  br label %36

36:                                               ; preds = %46, %35
  %37 = load i32, i32* %9, align 4
  %38 = icmp slt i32 %37, 4
  br i1 %38, label %39, label %49

39:                                               ; preds = %36
  %40 = load i32, i32* %9, align 4
  %41 = sext i32 %40 to i64
  %42 = getelementptr inbounds [4 x float], [4 x float]* %7, i64 0, i64 %41
  %43 = load float, float* %42, align 4
  %44 = fpext float %43 to double
  %45 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %44)
  br label %46

46:                                               ; preds = %39
  %47 = load i32, i32* %9, align 4
  %48 = add nsw i32 %47, 1
  store i32 %48, i32* %9, align 4
  br label %36

49:                                               ; preds = %36
  %50 = load i32, i32* %1, align 4
  ret i32 %50
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #2

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #3

declare i32 @printf(i8*, ...) #4

attributes #0 = { alwaysinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { argmemonly nounwind willreturn }
attributes #3 = { argmemonly nounwind willreturn writeonly }
attributes #4 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
