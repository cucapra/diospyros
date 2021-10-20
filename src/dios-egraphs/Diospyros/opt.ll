; ModuleID = 'clang.ll'
source_filename = "llvm-tests/q-prod.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.a_q = private unnamed_addr constant [4 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00], align 16
@__const.main.a_t = private unnamed_addr constant [4 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00], align 16
@__const.main.b_t = private unnamed_addr constant [4 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00], align 16
@.str = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1

; Function Attrs: alwaysinline nounwind ssp uwtable
define void @naive_cross_product(float* %0, float* %1, float* %2) #0 {
  %4 = getelementptr inbounds float, float* %0, i64 1
  %5 = load float, float* %4, align 4
  %6 = getelementptr inbounds float, float* %1, i64 2
  %7 = load float, float* %6, align 4
  %8 = fmul float %5, %7
  %9 = getelementptr inbounds float, float* %0, i64 2
  %10 = load float, float* %9, align 4
  %11 = getelementptr inbounds float, float* %1, i64 1
  %12 = load float, float* %11, align 4
  %13 = fmul float %10, %12
  %14 = fsub float %8, %13
  %15 = getelementptr inbounds float, float* %2, i64 0
  store float %14, float* %15, align 4
  %16 = getelementptr inbounds float, float* %0, i64 2
  %17 = load float, float* %16, align 4
  %18 = getelementptr inbounds float, float* %1, i64 0
  %19 = load float, float* %18, align 4
  %20 = fmul float %17, %19
  %21 = getelementptr inbounds float, float* %0, i64 0
  %22 = load float, float* %21, align 4
  %23 = getelementptr inbounds float, float* %1, i64 2
  %24 = load float, float* %23, align 4
  %25 = fmul float %22, %24
  %26 = fsub float %20, %25
  %27 = getelementptr inbounds float, float* %2, i64 1
  store float %26, float* %27, align 4
  %28 = getelementptr inbounds float, float* %0, i64 0
  %29 = load float, float* %28, align 4
  %30 = getelementptr inbounds float, float* %1, i64 1
  %31 = load float, float* %30, align 4
  %32 = fmul float %29, %31
  %33 = getelementptr inbounds float, float* %0, i64 1
  %34 = load float, float* %33, align 4
  %35 = getelementptr inbounds float, float* %1, i64 0
  %36 = load float, float* %35, align 4
  %37 = fmul float %34, %36
  %38 = fsub float %32, %37
  %39 = getelementptr inbounds float, float* %2, i64 2
  store float %38, float* %39, align 4
  ret void
}

; Function Attrs: alwaysinline nounwind ssp uwtable
define void @naive_point_product(float* %0, float* %1, float* %2) #0 {
  %4 = alloca [3 x float], align 4
  %5 = alloca [3 x float], align 4
  %6 = alloca [3 x float], align 4
  %7 = getelementptr inbounds [3 x float], [3 x float]* %4, i64 0, i64 0
  %8 = getelementptr inbounds float, float* %0, i64 0
  %9 = load float, float* %8, align 4
  store float %9, float* %7, align 4
  %10 = getelementptr inbounds float, float* %7, i64 1
  %11 = getelementptr inbounds float, float* %0, i64 1
  %12 = load float, float* %11, align 4
  store float %12, float* %10, align 4
  %13 = getelementptr inbounds float, float* %10, i64 1
  %14 = getelementptr inbounds float, float* %0, i64 2
  %15 = load float, float* %14, align 4
  store float %15, float* %13, align 4
  %16 = getelementptr inbounds [3 x float], [3 x float]* %4, i64 0, i64 0
  %17 = getelementptr inbounds [3 x float], [3 x float]* %5, i64 0, i64 0
  %18 = getelementptr inbounds float, float* %16, i64 1
  %19 = load float, float* %18, align 4
  %20 = getelementptr inbounds float, float* %1, i64 2
  %21 = load float, float* %20, align 4
  %22 = fmul float %19, %21
  %23 = getelementptr inbounds float, float* %16, i64 2
  %24 = load float, float* %23, align 4
  %25 = getelementptr inbounds float, float* %1, i64 1
  %26 = load float, float* %25, align 4
  %27 = fmul float %24, %26
  %28 = fsub float %22, %27
  store float %28, float* %17, align 4
  %29 = getelementptr inbounds float, float* %16, i64 2
  %30 = load float, float* %29, align 4
  %31 = load float, float* %1, align 4
  %32 = fmul float %30, %31
  %33 = load float, float* %16, align 4
  %34 = getelementptr inbounds float, float* %1, i64 2
  %35 = load float, float* %34, align 4
  %36 = fmul float %33, %35
  %37 = fsub float %32, %36
  %38 = getelementptr inbounds float, float* %17, i64 1
  store float %37, float* %38, align 4
  %39 = load float, float* %16, align 4
  %40 = getelementptr inbounds float, float* %1, i64 1
  %41 = load float, float* %40, align 4
  %42 = fmul float %39, %41
  %43 = getelementptr inbounds float, float* %16, i64 1
  %44 = load float, float* %43, align 4
  %45 = load float, float* %1, align 4
  %46 = fmul float %44, %45
  %47 = fsub float %42, %46
  %48 = getelementptr inbounds float, float* %17, i64 2
  store float %47, float* %48, align 4
  %49 = getelementptr inbounds [3 x float], [3 x float]* %5, i64 0, i64 0
  %50 = load float, float* %49, align 4
  %51 = fmul float %50, 2.000000e+00
  %52 = getelementptr inbounds [3 x float], [3 x float]* %5, i64 0, i64 0
  store float %51, float* %52, align 4
  %53 = getelementptr inbounds [3 x float], [3 x float]* %5, i64 0, i64 1
  %54 = load float, float* %53, align 4
  %55 = fmul float %54, 2.000000e+00
  %56 = getelementptr inbounds [3 x float], [3 x float]* %5, i64 0, i64 1
  store float %55, float* %56, align 4
  %57 = getelementptr inbounds [3 x float], [3 x float]* %5, i64 0, i64 2
  %58 = load float, float* %57, align 4
  %59 = fmul float %58, 2.000000e+00
  %60 = getelementptr inbounds [3 x float], [3 x float]* %5, i64 0, i64 2
  store float %59, float* %60, align 4
  %61 = getelementptr inbounds [3 x float], [3 x float]* %4, i64 0, i64 0
  %62 = getelementptr inbounds [3 x float], [3 x float]* %5, i64 0, i64 0
  %63 = getelementptr inbounds [3 x float], [3 x float]* %6, i64 0, i64 0
  %64 = getelementptr inbounds float, float* %61, i64 1
  %65 = load float, float* %64, align 4
  %66 = getelementptr inbounds float, float* %62, i64 2
  %67 = load float, float* %66, align 4
  %68 = fmul float %65, %67
  %69 = getelementptr inbounds float, float* %61, i64 2
  %70 = load float, float* %69, align 4
  %71 = getelementptr inbounds float, float* %62, i64 1
  %72 = load float, float* %71, align 4
  %73 = fmul float %70, %72
  %74 = fsub float %68, %73
  store float %74, float* %63, align 4
  %75 = getelementptr inbounds float, float* %61, i64 2
  %76 = load float, float* %75, align 4
  %77 = load float, float* %62, align 4
  %78 = fmul float %76, %77
  %79 = load float, float* %61, align 4
  %80 = getelementptr inbounds float, float* %62, i64 2
  %81 = load float, float* %80, align 4
  %82 = fmul float %79, %81
  %83 = fsub float %78, %82
  %84 = getelementptr inbounds float, float* %63, i64 1
  store float %83, float* %84, align 4
  %85 = load float, float* %61, align 4
  %86 = getelementptr inbounds float, float* %62, i64 1
  %87 = load float, float* %86, align 4
  %88 = fmul float %85, %87
  %89 = getelementptr inbounds float, float* %61, i64 1
  %90 = load float, float* %89, align 4
  %91 = load float, float* %62, align 4
  %92 = fmul float %90, %91
  %93 = fsub float %88, %92
  %94 = getelementptr inbounds float, float* %63, i64 2
  store float %93, float* %94, align 4
  %95 = getelementptr inbounds float, float* %0, i64 3
  %96 = load float, float* %1, align 4
  %97 = load float, float* %95, align 4
  %98 = getelementptr inbounds [3 x float], [3 x float]* %5, i64 0, i64 0
  %99 = load float, float* %98, align 4
  %100 = fmul float %97, %99
  %101 = fadd float %96, %100
  %102 = getelementptr inbounds [3 x float], [3 x float]* %6, i64 0, i64 0
  %103 = load float, float* %102, align 4
  %104 = fadd float %101, %103
  store float %104, float* %2, align 4
  %105 = getelementptr inbounds float, float* %1, i64 1
  %106 = load float, float* %105, align 4
  %107 = load float, float* %95, align 4
  %108 = getelementptr inbounds [3 x float], [3 x float]* %5, i64 0, i64 1
  %109 = load float, float* %108, align 4
  %110 = fmul float %107, %109
  %111 = fadd float %106, %110
  %112 = getelementptr inbounds [3 x float], [3 x float]* %6, i64 0, i64 1
  %113 = load float, float* %112, align 4
  %114 = fadd float %111, %113
  %115 = getelementptr inbounds float, float* %2, i64 1
  store float %114, float* %115, align 4
  %116 = getelementptr inbounds float, float* %1, i64 2
  %117 = load float, float* %116, align 4
  %118 = load float, float* %95, align 4
  %119 = getelementptr inbounds [3 x float], [3 x float]* %5, i64 0, i64 2
  %120 = load float, float* %119, align 4
  %121 = fmul float %118, %120
  %122 = fadd float %117, %121
  %123 = getelementptr inbounds [3 x float], [3 x float]* %6, i64 0, i64 2
  %124 = load float, float* %123, align 4
  %125 = fadd float %122, %124
  %126 = getelementptr inbounds float, float* %2, i64 2
  store float %125, float* %126, align 4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define void @naive_quaternion_product(float* %0, float* %1, float* %2, float* %3, float* %4, float* %5) #1 {
  %7 = alloca [3 x float], align 4
  %8 = alloca [3 x float], align 4
  %9 = alloca [3 x float], align 4
  %10 = getelementptr inbounds float, float* %0, i64 3
  %11 = load float, float* %10, align 4
  %12 = getelementptr inbounds float, float* %2, i64 3
  %13 = load float, float* %12, align 4
  %14 = fmul float %11, %13
  %15 = getelementptr inbounds float, float* %0, i64 0
  %16 = load float, float* %15, align 4
  %17 = getelementptr inbounds float, float* %2, i64 0
  %18 = load float, float* %17, align 4
  %19 = fmul float %16, %18
  %20 = fsub float %14, %19
  %21 = getelementptr inbounds float, float* %0, i64 1
  %22 = load float, float* %21, align 4
  %23 = getelementptr inbounds float, float* %2, i64 1
  %24 = load float, float* %23, align 4
  %25 = fmul float %22, %24
  %26 = fsub float %20, %25
  %27 = getelementptr inbounds float, float* %0, i64 2
  %28 = load float, float* %27, align 4
  %29 = getelementptr inbounds float, float* %2, i64 2
  %30 = load float, float* %29, align 4
  %31 = fmul float %28, %30
  %32 = fsub float %26, %31
  %33 = getelementptr inbounds float, float* %4, i64 3
  store float %32, float* %33, align 4
  %34 = getelementptr inbounds float, float* %0, i64 3
  %35 = load float, float* %34, align 4
  %36 = getelementptr inbounds float, float* %2, i64 0
  %37 = load float, float* %36, align 4
  %38 = fmul float %35, %37
  %39 = getelementptr inbounds float, float* %0, i64 0
  %40 = load float, float* %39, align 4
  %41 = getelementptr inbounds float, float* %2, i64 3
  %42 = load float, float* %41, align 4
  %43 = fmul float %40, %42
  %44 = fadd float %38, %43
  %45 = getelementptr inbounds float, float* %0, i64 1
  %46 = load float, float* %45, align 4
  %47 = getelementptr inbounds float, float* %2, i64 2
  %48 = load float, float* %47, align 4
  %49 = fmul float %46, %48
  %50 = fadd float %44, %49
  %51 = getelementptr inbounds float, float* %0, i64 2
  %52 = load float, float* %51, align 4
  %53 = getelementptr inbounds float, float* %2, i64 1
  %54 = load float, float* %53, align 4
  %55 = fmul float %52, %54
  %56 = fsub float %50, %55
  %57 = getelementptr inbounds float, float* %4, i64 0
  store float %56, float* %57, align 4
  %58 = getelementptr inbounds float, float* %0, i64 3
  %59 = load float, float* %58, align 4
  %60 = getelementptr inbounds float, float* %2, i64 1
  %61 = load float, float* %60, align 4
  %62 = fmul float %59, %61
  %63 = getelementptr inbounds float, float* %0, i64 1
  %64 = load float, float* %63, align 4
  %65 = getelementptr inbounds float, float* %2, i64 3
  %66 = load float, float* %65, align 4
  %67 = fmul float %64, %66
  %68 = fadd float %62, %67
  %69 = getelementptr inbounds float, float* %0, i64 2
  %70 = load float, float* %69, align 4
  %71 = getelementptr inbounds float, float* %2, i64 0
  %72 = load float, float* %71, align 4
  %73 = fmul float %70, %72
  %74 = fadd float %68, %73
  %75 = getelementptr inbounds float, float* %0, i64 0
  %76 = load float, float* %75, align 4
  %77 = getelementptr inbounds float, float* %2, i64 2
  %78 = load float, float* %77, align 4
  %79 = fmul float %76, %78
  %80 = fsub float %74, %79
  %81 = getelementptr inbounds float, float* %4, i64 1
  store float %80, float* %81, align 4
  %82 = getelementptr inbounds float, float* %0, i64 3
  %83 = load float, float* %82, align 4
  %84 = getelementptr inbounds float, float* %2, i64 2
  %85 = load float, float* %84, align 4
  %86 = fmul float %83, %85
  %87 = getelementptr inbounds float, float* %0, i64 2
  %88 = load float, float* %87, align 4
  %89 = getelementptr inbounds float, float* %2, i64 3
  %90 = load float, float* %89, align 4
  %91 = fmul float %88, %90
  %92 = fadd float %86, %91
  %93 = getelementptr inbounds float, float* %0, i64 0
  %94 = load float, float* %93, align 4
  %95 = getelementptr inbounds float, float* %2, i64 1
  %96 = load float, float* %95, align 4
  %97 = fmul float %94, %96
  %98 = fadd float %92, %97
  %99 = getelementptr inbounds float, float* %0, i64 1
  %100 = load float, float* %99, align 4
  %101 = getelementptr inbounds float, float* %2, i64 0
  %102 = load float, float* %101, align 4
  %103 = fmul float %100, %102
  %104 = fsub float %98, %103
  %105 = getelementptr inbounds float, float* %4, i64 2
  store float %104, float* %105, align 4
  %106 = getelementptr inbounds [3 x float], [3 x float]* %7, i64 0, i64 0
  %107 = load float, float* %0, align 4
  store float %107, float* %106, align 4
  %108 = getelementptr inbounds float, float* %106, i64 1
  %109 = getelementptr inbounds float, float* %0, i64 1
  %110 = load float, float* %109, align 4
  store float %110, float* %108, align 4
  %111 = getelementptr inbounds float, float* %108, i64 1
  %112 = getelementptr inbounds float, float* %0, i64 2
  %113 = load float, float* %112, align 4
  store float %113, float* %111, align 4
  %114 = getelementptr inbounds [3 x float], [3 x float]* %7, i64 0, i64 0
  %115 = getelementptr inbounds [3 x float], [3 x float]* %8, i64 0, i64 0
  %116 = getelementptr inbounds float, float* %114, i64 1
  %117 = load float, float* %116, align 4
  %118 = getelementptr inbounds float, float* %3, i64 2
  %119 = load float, float* %118, align 4
  %120 = fmul float %117, %119
  %121 = getelementptr inbounds float, float* %114, i64 2
  %122 = load float, float* %121, align 4
  %123 = getelementptr inbounds float, float* %3, i64 1
  %124 = load float, float* %123, align 4
  %125 = fmul float %122, %124
  %126 = fsub float %120, %125
  store float %126, float* %115, align 4
  %127 = getelementptr inbounds float, float* %114, i64 2
  %128 = load float, float* %127, align 4
  %129 = load float, float* %3, align 4
  %130 = fmul float %128, %129
  %131 = load float, float* %114, align 4
  %132 = getelementptr inbounds float, float* %3, i64 2
  %133 = load float, float* %132, align 4
  %134 = fmul float %131, %133
  %135 = fsub float %130, %134
  %136 = getelementptr inbounds float, float* %115, i64 1
  store float %135, float* %136, align 4
  %137 = load float, float* %114, align 4
  %138 = getelementptr inbounds float, float* %3, i64 1
  %139 = load float, float* %138, align 4
  %140 = fmul float %137, %139
  %141 = getelementptr inbounds float, float* %114, i64 1
  %142 = load float, float* %141, align 4
  %143 = load float, float* %3, align 4
  %144 = fmul float %142, %143
  %145 = fsub float %140, %144
  %146 = getelementptr inbounds float, float* %115, i64 2
  store float %145, float* %146, align 4
  %147 = getelementptr inbounds [3 x float], [3 x float]* %8, i64 0, i64 0
  %148 = load float, float* %147, align 4
  %149 = fmul float %148, 2.000000e+00
  %150 = getelementptr inbounds [3 x float], [3 x float]* %8, i64 0, i64 0
  store float %149, float* %150, align 4
  %151 = getelementptr inbounds [3 x float], [3 x float]* %8, i64 0, i64 1
  %152 = load float, float* %151, align 4
  %153 = fmul float %152, 2.000000e+00
  %154 = getelementptr inbounds [3 x float], [3 x float]* %8, i64 0, i64 1
  store float %153, float* %154, align 4
  %155 = getelementptr inbounds [3 x float], [3 x float]* %8, i64 0, i64 2
  %156 = load float, float* %155, align 4
  %157 = fmul float %156, 2.000000e+00
  %158 = getelementptr inbounds [3 x float], [3 x float]* %8, i64 0, i64 2
  store float %157, float* %158, align 4
  %159 = getelementptr inbounds [3 x float], [3 x float]* %7, i64 0, i64 0
  %160 = getelementptr inbounds [3 x float], [3 x float]* %8, i64 0, i64 0
  %161 = getelementptr inbounds [3 x float], [3 x float]* %9, i64 0, i64 0
  %162 = getelementptr inbounds float, float* %159, i64 1
  %163 = load float, float* %162, align 4
  %164 = getelementptr inbounds float, float* %160, i64 2
  %165 = load float, float* %164, align 4
  %166 = fmul float %163, %165
  %167 = getelementptr inbounds float, float* %159, i64 2
  %168 = load float, float* %167, align 4
  %169 = getelementptr inbounds float, float* %160, i64 1
  %170 = load float, float* %169, align 4
  %171 = fmul float %168, %170
  %172 = fsub float %166, %171
  store float %172, float* %161, align 4
  %173 = getelementptr inbounds float, float* %159, i64 2
  %174 = load float, float* %173, align 4
  %175 = load float, float* %160, align 4
  %176 = fmul float %174, %175
  %177 = load float, float* %159, align 4
  %178 = getelementptr inbounds float, float* %160, i64 2
  %179 = load float, float* %178, align 4
  %180 = fmul float %177, %179
  %181 = fsub float %176, %180
  %182 = getelementptr inbounds float, float* %161, i64 1
  store float %181, float* %182, align 4
  %183 = load float, float* %159, align 4
  %184 = getelementptr inbounds float, float* %160, i64 1
  %185 = load float, float* %184, align 4
  %186 = fmul float %183, %185
  %187 = getelementptr inbounds float, float* %159, i64 1
  %188 = load float, float* %187, align 4
  %189 = load float, float* %160, align 4
  %190 = fmul float %188, %189
  %191 = fsub float %186, %190
  %192 = getelementptr inbounds float, float* %161, i64 2
  store float %191, float* %192, align 4
  %193 = getelementptr inbounds float, float* %0, i64 3
  %194 = load float, float* %3, align 4
  %195 = load float, float* %193, align 4
  %196 = getelementptr inbounds [3 x float], [3 x float]* %8, i64 0, i64 0
  %197 = load float, float* %196, align 4
  %198 = fmul float %195, %197
  %199 = fadd float %194, %198
  %200 = getelementptr inbounds [3 x float], [3 x float]* %9, i64 0, i64 0
  %201 = load float, float* %200, align 4
  %202 = fadd float %199, %201
  store float %202, float* %5, align 4
  %203 = getelementptr inbounds float, float* %3, i64 1
  %204 = load float, float* %203, align 4
  %205 = load float, float* %193, align 4
  %206 = getelementptr inbounds [3 x float], [3 x float]* %8, i64 0, i64 1
  %207 = load float, float* %206, align 4
  %208 = fmul float %205, %207
  %209 = fadd float %204, %208
  %210 = getelementptr inbounds [3 x float], [3 x float]* %9, i64 0, i64 1
  %211 = load float, float* %210, align 4
  %212 = fadd float %209, %211
  %213 = getelementptr inbounds float, float* %5, i64 1
  store float %212, float* %213, align 4
  %214 = getelementptr inbounds float, float* %3, i64 2
  %215 = load float, float* %214, align 4
  %216 = load float, float* %193, align 4
  %217 = getelementptr inbounds [3 x float], [3 x float]* %8, i64 0, i64 2
  %218 = load float, float* %217, align 4
  %219 = fmul float %216, %218
  %220 = fadd float %215, %219
  %221 = getelementptr inbounds [3 x float], [3 x float]* %9, i64 0, i64 2
  %222 = load float, float* %221, align 4
  %223 = fadd float %220, %222
  %224 = getelementptr inbounds float, float* %5, i64 2
  store float %223, float* %224, align 4
  %225 = load float, float* %1, align 4
  %226 = load float, float* %5, align 4
  %227 = fadd float %226, %225
  store float %227, float* %5, align 4
  %228 = getelementptr inbounds float, float* %1, i64 1
  %229 = load float, float* %228, align 4
  %230 = getelementptr inbounds float, float* %5, i64 1
  %231 = load float, float* %230, align 4
  %232 = fadd float %231, %229
  store float %232, float* %230, align 4
  %233 = getelementptr inbounds float, float* %1, i64 2
  %234 = load float, float* %233, align 4
  %235 = getelementptr inbounds float, float* %5, i64 2
  %236 = load float, float* %235, align 4
  %237 = fadd float %236, %234
  store float %237, float* %235, align 4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #1 {
  %1 = alloca [4 x float], align 16
  %2 = alloca [4 x float], align 16
  %3 = alloca [4 x float], align 16
  %4 = alloca [4 x float], align 16
  %5 = alloca [4 x float], align 16
  %6 = alloca [4 x float], align 16
  %7 = bitcast [4 x float]* %1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %7, i8* align 16 bitcast ([4 x float]* @__const.main.a_q to i8*), i64 16, i1 false)
  %8 = bitcast [4 x float]* %2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %8, i8* align 16 bitcast ([4 x float]* @__const.main.a_t to i8*), i64 16, i1 false)
  %9 = bitcast [4 x float]* %3 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %9, i8 0, i64 16, i1 false)
  %10 = bitcast [4 x float]* %4 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %10, i8* align 16 bitcast ([4 x float]* @__const.main.b_t to i8*), i64 16, i1 false)
  %11 = bitcast [4 x float]* %5 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %11, i8 0, i64 16, i1 false)
  %12 = bitcast [4 x float]* %6 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %12, i8 0, i64 16, i1 false)
  %13 = getelementptr inbounds [4 x float], [4 x float]* %1, i64 0, i64 0
  %14 = getelementptr inbounds [4 x float], [4 x float]* %2, i64 0, i64 0
  %15 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 0
  %16 = getelementptr inbounds [4 x float], [4 x float]* %4, i64 0, i64 0
  %17 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 0
  %18 = getelementptr inbounds [4 x float], [4 x float]* %6, i64 0, i64 0
  call void @naive_quaternion_product(float* %13, float* %14, float* %15, float* %16, float* %17, float* %18)
  %19 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 0
  %20 = load float, float* %19, align 4
  %21 = fpext float %20 to double
  %22 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %21)
  %23 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 1
  %24 = load float, float* %23, align 4
  %25 = fpext float %24 to double
  %26 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %25)
  %27 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 2
  %28 = load float, float* %27, align 4
  %29 = fpext float %28 to double
  %30 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %29)
  %31 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 3
  %32 = load float, float* %31, align 4
  %33 = fpext float %32 to double
  %34 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %33)
  %35 = getelementptr inbounds [4 x float], [4 x float]* %6, i64 0, i64 0
  %36 = load float, float* %35, align 4
  %37 = fpext float %36 to double
  %38 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %37)
  %39 = getelementptr inbounds [4 x float], [4 x float]* %6, i64 0, i64 1
  %40 = load float, float* %39, align 4
  %41 = fpext float %40 to double
  %42 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %41)
  %43 = getelementptr inbounds [4 x float], [4 x float]* %6, i64 0, i64 2
  %44 = load float, float* %43, align 4
  %45 = fpext float %44 to double
  %46 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %45)
  %47 = getelementptr inbounds [4 x float], [4 x float]* %6, i64 0, i64 3
  %48 = load float, float* %47, align 4
  %49 = fpext float %48 to double
  %50 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %49)
  ret i32 0
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
