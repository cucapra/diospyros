; ModuleID = 'clang.ll'
source_filename = "llvm-tests/load_reuse.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.mat_in = private unnamed_addr constant [2 x [2 x float]] [[2 x float] [float 1.000000e+00, float 2.000000e+00], [2 x float] [float 3.000000e+00, float 4.000000e+00]], align 16
@__const.main.f_in = private unnamed_addr constant [2 x [2 x float]] [[2 x float] [float 1.000000e+00, float 1.000000e+00], [2 x float] [float 1.000000e+00, float 1.000000e+00]], align 16
@.str = private unnamed_addr constant [12 x i8] c"output: %f\0A\00", align 1

; Function Attrs: noinline nounwind ssp uwtable
define void @load_use_twice([2 x float]* %0, [2 x float]* %1, [3 x float]* %2, [3 x float]* %3) #0 {
.preheader7:
  %4 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 0, i64 0
  %5 = getelementptr inbounds [3 x float], [3 x float]* %3, i64 0, i64 0
  %6 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 0, i64 0
  %7 = load float, float* %6, align 4
  %8 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 0, i64 0
  %9 = load float, float* %8, align 4
  %10 = fmul float %7, %9
  %11 = fmul float %10, 3.000000e+00
  %12 = fadd float %11, -4.000000e+00
  %13 = load float, float* %4, align 4
  %14 = fadd float %13, %12
  store float %14, float* %4, align 4
  %15 = fmul float %10, 2.000000e+00
  %16 = fadd float %15, 1.000000e+00
  %17 = load float, float* %5, align 4
  %18 = fadd float %17, %16
  store float %18, float* %5, align 4
  %19 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 0, i64 1
  %20 = getelementptr inbounds [3 x float], [3 x float]* %3, i64 0, i64 1
  %21 = load float, float* %6, align 4
  %22 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 0, i64 1
  %23 = load float, float* %22, align 4
  %24 = fmul float %21, %23
  %25 = fmul float %24, 3.000000e+00
  %26 = fadd float %25, -4.000000e+00
  %27 = load float, float* %19, align 4
  %28 = fadd float %27, %26
  store float %28, float* %19, align 4
  %29 = fmul float %24, 2.000000e+00
  %30 = fadd float %29, 1.000000e+00
  %31 = load float, float* %20, align 4
  %32 = fadd float %31, %30
  store float %32, float* %20, align 4
  %33 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 0, i64 1
  %34 = load float, float* %33, align 4
  %35 = load float, float* %8, align 4
  %36 = fmul float %34, %35
  %37 = fmul float %36, 3.000000e+00
  %38 = fadd float %37, -4.000000e+00
  %39 = load float, float* %19, align 4
  %40 = fadd float %39, %38
  store float %40, float* %19, align 4
  %41 = fmul float %36, 2.000000e+00
  %42 = fadd float %41, 1.000000e+00
  %43 = load float, float* %20, align 4
  %44 = fadd float %43, %42
  store float %44, float* %20, align 4
  %45 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 0, i64 2
  %46 = getelementptr inbounds [3 x float], [3 x float]* %3, i64 0, i64 2
  %47 = load float, float* %33, align 4
  %48 = load float, float* %22, align 4
  %49 = fmul float %47, %48
  %50 = fmul float %49, 3.000000e+00
  %51 = fadd float %50, -4.000000e+00
  %52 = load float, float* %45, align 4
  %53 = fadd float %52, %51
  store float %53, float* %45, align 4
  %54 = fmul float %49, 2.000000e+00
  %55 = fadd float %54, 1.000000e+00
  %56 = load float, float* %46, align 4
  %57 = fadd float %56, %55
  store float %57, float* %46, align 4
  %58 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 1, i64 0
  %59 = getelementptr inbounds [3 x float], [3 x float]* %3, i64 1, i64 0
  %60 = load float, float* %6, align 4
  %61 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 1, i64 0
  %62 = load float, float* %61, align 4
  %63 = fmul float %60, %62
  %64 = fmul float %63, 3.000000e+00
  %65 = fadd float %64, -4.000000e+00
  %66 = load float, float* %58, align 4
  %67 = fadd float %66, %65
  store float %67, float* %58, align 4
  %68 = fmul float %63, 2.000000e+00
  %69 = fadd float %68, 1.000000e+00
  %70 = load float, float* %59, align 4
  %71 = fadd float %70, %69
  store float %71, float* %59, align 4
  %72 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 1, i64 0
  %73 = load float, float* %72, align 4
  %74 = load float, float* %8, align 4
  %75 = fmul float %73, %74
  %76 = fmul float %75, 3.000000e+00
  %77 = fadd float %76, -4.000000e+00
  %78 = load float, float* %58, align 4
  %79 = fadd float %78, %77
  store float %79, float* %58, align 4
  %80 = fmul float %75, 2.000000e+00
  %81 = fadd float %80, 1.000000e+00
  %82 = load float, float* %59, align 4
  %83 = fadd float %82, %81
  store float %83, float* %59, align 4
  %84 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 1, i64 1
  %85 = getelementptr inbounds [3 x float], [3 x float]* %3, i64 1, i64 1
  %86 = load float, float* %6, align 4
  %87 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 1, i64 1
  %88 = load float, float* %87, align 4
  %89 = fmul float %86, %88
  %90 = fmul float %89, 3.000000e+00
  %91 = fadd float %90, -4.000000e+00
  %92 = load float, float* %84, align 4
  %93 = fadd float %92, %91
  store float %93, float* %84, align 4
  %94 = fmul float %89, 2.000000e+00
  %95 = fadd float %94, 1.000000e+00
  %96 = load float, float* %85, align 4
  %97 = fadd float %96, %95
  store float %97, float* %85, align 4
  %98 = load float, float* %33, align 4
  %99 = load float, float* %61, align 4
  %100 = fmul float %98, %99
  %101 = fmul float %100, 3.000000e+00
  %102 = fadd float %101, -4.000000e+00
  %103 = load float, float* %84, align 4
  %104 = fadd float %103, %102
  store float %104, float* %84, align 4
  %105 = fmul float %100, 2.000000e+00
  %106 = fadd float %105, 1.000000e+00
  %107 = load float, float* %85, align 4
  %108 = fadd float %107, %106
  store float %108, float* %85, align 4
  %109 = load float, float* %72, align 4
  %110 = load float, float* %22, align 4
  %111 = fmul float %109, %110
  %112 = fmul float %111, 3.000000e+00
  %113 = fadd float %112, -4.000000e+00
  %114 = load float, float* %84, align 4
  %115 = fadd float %114, %113
  store float %115, float* %84, align 4
  %116 = fmul float %111, 2.000000e+00
  %117 = fadd float %116, 1.000000e+00
  %118 = load float, float* %85, align 4
  %119 = fadd float %118, %117
  store float %119, float* %85, align 4
  %120 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 1, i64 1
  %121 = load float, float* %120, align 4
  %122 = load float, float* %8, align 4
  %123 = fmul float %121, %122
  %124 = fmul float %123, 3.000000e+00
  %125 = fadd float %124, -4.000000e+00
  %126 = load float, float* %84, align 4
  %127 = fadd float %126, %125
  store float %127, float* %84, align 4
  %128 = fmul float %123, 2.000000e+00
  %129 = fadd float %128, 1.000000e+00
  %130 = load float, float* %85, align 4
  %131 = fadd float %130, %129
  store float %131, float* %85, align 4
  %132 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 1, i64 2
  %133 = getelementptr inbounds [3 x float], [3 x float]* %3, i64 1, i64 2
  %134 = load float, float* %33, align 4
  %135 = load float, float* %87, align 4
  %136 = fmul float %134, %135
  %137 = fmul float %136, 3.000000e+00
  %138 = fadd float %137, -4.000000e+00
  %139 = load float, float* %132, align 4
  %140 = fadd float %139, %138
  store float %140, float* %132, align 4
  %141 = fmul float %136, 2.000000e+00
  %142 = fadd float %141, 1.000000e+00
  %143 = load float, float* %133, align 4
  %144 = fadd float %143, %142
  store float %144, float* %133, align 4
  %145 = load float, float* %120, align 4
  %146 = load float, float* %22, align 4
  %147 = fmul float %145, %146
  %148 = fmul float %147, 3.000000e+00
  %149 = fadd float %148, -4.000000e+00
  %150 = load float, float* %132, align 4
  %151 = fadd float %150, %149
  store float %151, float* %132, align 4
  %152 = fmul float %147, 2.000000e+00
  %153 = fadd float %152, 1.000000e+00
  %154 = load float, float* %133, align 4
  %155 = fadd float %154, %153
  store float %155, float* %133, align 4
  %156 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 2, i64 0
  %157 = getelementptr inbounds [3 x float], [3 x float]* %3, i64 2, i64 0
  %158 = load float, float* %72, align 4
  %159 = load float, float* %61, align 4
  %160 = fmul float %158, %159
  %161 = fmul float %160, 3.000000e+00
  %162 = fadd float %161, -4.000000e+00
  %163 = load float, float* %156, align 4
  %164 = fadd float %163, %162
  store float %164, float* %156, align 4
  %165 = fmul float %160, 2.000000e+00
  %166 = fadd float %165, 1.000000e+00
  %167 = load float, float* %157, align 4
  %168 = fadd float %167, %166
  store float %168, float* %157, align 4
  %169 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 2, i64 1
  %170 = getelementptr inbounds [3 x float], [3 x float]* %3, i64 2, i64 1
  %171 = load float, float* %72, align 4
  %172 = load float, float* %87, align 4
  %173 = fmul float %171, %172
  %174 = fmul float %173, 3.000000e+00
  %175 = fadd float %174, -4.000000e+00
  %176 = load float, float* %169, align 4
  %177 = fadd float %176, %175
  store float %177, float* %169, align 4
  %178 = fmul float %173, 2.000000e+00
  %179 = fadd float %178, 1.000000e+00
  %180 = load float, float* %170, align 4
  %181 = fadd float %180, %179
  store float %181, float* %170, align 4
  %182 = load float, float* %120, align 4
  %183 = load float, float* %61, align 4
  %184 = fmul float %182, %183
  %185 = fmul float %184, 3.000000e+00
  %186 = fadd float %185, -4.000000e+00
  %187 = load float, float* %169, align 4
  %188 = fadd float %187, %186
  store float %188, float* %169, align 4
  %189 = fmul float %184, 2.000000e+00
  %190 = fadd float %189, 1.000000e+00
  %191 = load float, float* %170, align 4
  %192 = fadd float %191, %190
  store float %192, float* %170, align 4
  %193 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 2, i64 2
  %194 = getelementptr inbounds [3 x float], [3 x float]* %3, i64 2, i64 2
  %195 = load float, float* %120, align 4
  %196 = load float, float* %87, align 4
  %197 = fmul float %195, %196
  %198 = fmul float %197, 3.000000e+00
  %199 = fadd float %198, -4.000000e+00
  %200 = load float, float* %193, align 4
  %201 = fadd float %200, %199
  store float %201, float* %193, align 4
  %202 = fmul float %197, 2.000000e+00
  %203 = fadd float %202, 1.000000e+00
  %204 = load float, float* %194, align 4
  %205 = fadd float %204, %203
  store float %205, float* %194, align 4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #0 {
.preheader:
  %0 = alloca [2 x [2 x float]], align 16
  %1 = alloca [2 x [2 x float]], align 16
  %2 = alloca [3 x [3 x float]], align 16
  %3 = alloca [3 x [3 x float]], align 16
  %4 = bitcast [2 x [2 x float]]* %0 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 16 dereferenceable(16) %4, i8* nonnull align 16 dereferenceable(16) bitcast ([2 x [2 x float]]* @__const.main.mat_in to i8*), i64 16, i1 false)
  %5 = bitcast [2 x [2 x float]]* %1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 16 dereferenceable(16) %5, i8* nonnull align 16 dereferenceable(16) bitcast ([2 x [2 x float]]* @__const.main.f_in to i8*), i64 16, i1 false)
  %6 = bitcast [3 x [3 x float]]* %2 to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 dereferenceable(36) %6, i8 0, i64 36, i1 false)
  %7 = bitcast [3 x [3 x float]]* %3 to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 dereferenceable(36) %7, i8 0, i64 36, i1 false)
  %8 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %0, i64 0, i64 0
  %9 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %1, i64 0, i64 0
  %10 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 0
  %11 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %3, i64 0, i64 0
  call void @load_use_twice([2 x float]* nonnull %8, [2 x float]* nonnull %9, [3 x float]* nonnull %10, [3 x float]* nonnull %11)
  %12 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 0, i64 0
  %13 = load float, float* %12, align 16
  %14 = fpext float %13 to double
  %15 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %14) #4
  %16 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %3, i64 0, i64 0, i64 0
  %17 = load float, float* %16, align 16
  %18 = fpext float %17 to double
  %19 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %18) #4
  %20 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 0, i64 1
  %21 = load float, float* %20, align 4
  %22 = fpext float %21 to double
  %23 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %22) #4
  %24 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %3, i64 0, i64 0, i64 1
  %25 = load float, float* %24, align 4
  %26 = fpext float %25 to double
  %27 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %26) #4
  %28 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 0, i64 2
  %29 = load float, float* %28, align 8
  %30 = fpext float %29 to double
  %31 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %30) #4
  %32 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %3, i64 0, i64 0, i64 2
  %33 = load float, float* %32, align 8
  %34 = fpext float %33 to double
  %35 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %34) #4
  %36 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 1, i64 0
  %37 = load float, float* %36, align 4
  %38 = fpext float %37 to double
  %39 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %38) #4
  %40 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %3, i64 0, i64 1, i64 0
  %41 = load float, float* %40, align 4
  %42 = fpext float %41 to double
  %43 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %42) #4
  %44 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 1, i64 1
  %45 = load float, float* %44, align 4
  %46 = fpext float %45 to double
  %47 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %46) #4
  %48 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %3, i64 0, i64 1, i64 1
  %49 = load float, float* %48, align 4
  %50 = fpext float %49 to double
  %51 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %50) #4
  %52 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 1, i64 2
  %53 = load float, float* %52, align 4
  %54 = fpext float %53 to double
  %55 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %54) #4
  %56 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %3, i64 0, i64 1, i64 2
  %57 = load float, float* %56, align 4
  %58 = fpext float %57 to double
  %59 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %58) #4
  %60 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 2, i64 0
  %61 = load float, float* %60, align 8
  %62 = fpext float %61 to double
  %63 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %62) #4
  %64 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %3, i64 0, i64 2, i64 0
  %65 = load float, float* %64, align 8
  %66 = fpext float %65 to double
  %67 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %66) #4
  %68 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 2, i64 1
  %69 = load float, float* %68, align 4
  %70 = fpext float %69 to double
  %71 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %70) #4
  %72 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %3, i64 0, i64 2, i64 1
  %73 = load float, float* %72, align 4
  %74 = fpext float %73 to double
  %75 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %74) #4
  %76 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 2, i64 2
  %77 = load float, float* %76, align 8
  %78 = fpext float %77 to double
  %79 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %78) #4
  %80 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %3, i64 0, i64 2, i64 2
  %81 = load float, float* %80, align 8
  %82 = fpext float %81 to double
  %83 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %82) #4
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #1

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #2

declare i32 @printf(i8*, ...) #3

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { argmemonly nounwind willreturn writeonly }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
