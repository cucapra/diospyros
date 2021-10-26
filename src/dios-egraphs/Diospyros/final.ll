; ModuleID = 'finish.ll'
source_filename = "llvm-tests/point-product.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.q_in = private unnamed_addr constant [4 x float] [float 0.000000e+00, float 1.000000e+00, float 2.000000e+00, float 3.000000e+00], align 16
@__const.main.p_in = private unnamed_addr constant [4 x float] [float 0.000000e+00, float 1.000000e+00, float 2.000000e+00, float 3.000000e+00], align 16
@.str = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1

; Function Attrs: alwaysinline nounwind ssp uwtable
define void @cross_product(float* %0, float* %1, float* %2) #0 {
  %4 = getelementptr inbounds float, float* %0, i64 1
  %5 = load float, float* %4, align 4
  %6 = insertelement <4 x float> zeroinitializer, float %5, i32 0
  %7 = getelementptr inbounds float, float* %0, i64 2
  %8 = load float, float* %7, align 4
  %9 = insertelement <4 x float> %6, float %8, i32 1
  %10 = getelementptr inbounds float, float* %0, i64 0
  %11 = load float, float* %10, align 4
  %12 = insertelement <4 x float> %9, float %11, i32 2
  %13 = insertelement <4 x float> %12, float 1.000000e+00, i32 3
  %14 = getelementptr inbounds float, float* %1, i64 2
  %15 = load float, float* %14, align 4
  %16 = insertelement <4 x float> zeroinitializer, float %15, i32 0
  %17 = getelementptr inbounds float, float* %1, i64 0
  %18 = load float, float* %17, align 4
  %19 = insertelement <4 x float> %16, float %18, i32 1
  %20 = getelementptr inbounds float, float* %1, i64 1
  %21 = load float, float* %20, align 4
  %22 = insertelement <4 x float> %19, float %21, i32 2
  %23 = insertelement <4 x float> %22, float 0.000000e+00, i32 3
  %24 = fmul <4 x float> %13, %23
  %25 = getelementptr inbounds float, float* %0, i64 2
  %26 = load float, float* %25, align 4
  %27 = insertelement <4 x float> zeroinitializer, float %26, i32 0
  %28 = getelementptr inbounds float, float* %0, i64 0
  %29 = load float, float* %28, align 4
  %30 = insertelement <4 x float> %27, float %29, i32 1
  %31 = getelementptr inbounds float, float* %0, i64 1
  %32 = load float, float* %31, align 4
  %33 = insertelement <4 x float> %30, float %32, i32 2
  %34 = insertelement <4 x float> %33, float 1.000000e+00, i32 3
  %35 = getelementptr inbounds float, float* %1, i64 1
  %36 = load float, float* %35, align 4
  %37 = insertelement <4 x float> zeroinitializer, float %36, i32 0
  %38 = getelementptr inbounds float, float* %1, i64 2
  %39 = load float, float* %38, align 4
  %40 = insertelement <4 x float> %37, float %39, i32 1
  %41 = getelementptr inbounds float, float* %1, i64 0
  %42 = load float, float* %41, align 4
  %43 = insertelement <4 x float> %40, float %42, i32 2
  %44 = insertelement <4 x float> %43, float 0.000000e+00, i32 3
  %45 = fmul <4 x float> %34, %44
  %46 = fsub <4 x float> %24, %45
  %47 = extractelement <4 x float> %46, i32 0
  %48 = getelementptr inbounds float, float* %2, i64 0
  store float %47, float* %48, align 4
  %49 = extractelement <4 x float> %46, i32 1
  %50 = getelementptr inbounds float, float* %2, i64 1
  store float %49, float* %50, align 4
  %51 = extractelement <4 x float> %46, i32 2
  %52 = getelementptr inbounds float, float* %2, i64 2
  store float %51, float* %52, align 4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define void @point_product(float* %0, float* %1, float* %2) #1 {
  %4 = getelementptr inbounds float, float* %0, i64 0
  %5 = load float, float* %4, align 4
  %6 = insertelement <4 x float> zeroinitializer, float %5, i32 0
  %7 = getelementptr inbounds float, float* %0, i64 1
  %8 = load float, float* %7, align 4
  %9 = insertelement <4 x float> %6, float %8, i32 1
  %10 = getelementptr inbounds float, float* %0, i64 2
  %11 = load float, float* %10, align 4
  %12 = insertelement <4 x float> %9, float %11, i32 2
  %13 = alloca [3 x float], align 4
  %14 = getelementptr inbounds [3 x float], [3 x float]* %13, i64 0, i64 0
  %15 = getelementptr inbounds float, float* %14, i64 1
  %16 = load float, float* %15, align 4
  %17 = getelementptr inbounds float, float* %1, i64 2
  %18 = load float, float* %17, align 4
  %19 = fmul float %16, %18
  %20 = alloca [3 x float], align 4
  %21 = getelementptr inbounds [3 x float], [3 x float]* %20, i64 0, i64 0
  %22 = getelementptr inbounds float, float* %21, i64 2
  %23 = load float, float* %22, align 4
  %24 = getelementptr inbounds float, float* %1, i64 1
  %25 = load float, float* %24, align 4
  %26 = fmul float %23, %25
  %27 = fsub float %19, %26
  %28 = insertelement <4 x float> %12, float %27, i32 3
  %29 = alloca [3 x float], align 4
  %30 = getelementptr inbounds [3 x float], [3 x float]* %29, i64 0, i64 0
  %31 = load float, float* %30, align 4
  %32 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %31, i32 2
  %33 = alloca [3 x float], align 4
  %34 = getelementptr inbounds [3 x float], [3 x float]* %33, i64 0, i64 1
  %35 = load float, float* %34, align 4
  %36 = insertelement <4 x float> %32, float %35, i32 3
  %37 = alloca [3 x float], align 4
  %38 = getelementptr inbounds [3 x float], [3 x float]* %37, i64 0, i64 0
  %39 = getelementptr inbounds float, float* %38, i64 2
  %40 = load float, float* %39, align 4
  %41 = load float, float* %1, align 4
  %42 = fmul float %40, %41
  %43 = alloca [3 x float], align 4
  %44 = getelementptr inbounds [3 x float], [3 x float]* %43, i64 0, i64 0
  %45 = load float, float* %44, align 4
  %46 = getelementptr inbounds float, float* %1, i64 2
  %47 = load float, float* %46, align 4
  %48 = fmul float %45, %47
  %49 = fsub float %42, %48
  %50 = insertelement <4 x float> zeroinitializer, float %49, i32 0
  %51 = alloca [3 x float], align 4
  %52 = getelementptr inbounds [3 x float], [3 x float]* %51, i64 0, i64 0
  %53 = load float, float* %52, align 4
  %54 = getelementptr inbounds float, float* %1, i64 1
  %55 = load float, float* %54, align 4
  %56 = fmul float %53, %55
  %57 = alloca [3 x float], align 4
  %58 = getelementptr inbounds [3 x float], [3 x float]* %57, i64 0, i64 0
  %59 = getelementptr inbounds float, float* %58, i64 1
  %60 = load float, float* %59, align 4
  %61 = load float, float* %1, align 4
  %62 = fmul float %60, %61
  %63 = fsub float %56, %62
  %64 = insertelement <4 x float> %50, float %63, i32 1
  %65 = insertelement <4 x float> %64, float 2.000000e+00, i32 2
  %66 = insertelement <4 x float> %65, float 2.000000e+00, i32 3
  %67 = fmul <4 x float> %36, %66
  %68 = shufflevector <4 x float> %28, <4 x float> %67, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %69 = alloca [3 x float], align 4
  %70 = getelementptr inbounds [3 x float], [3 x float]* %69, i64 0, i64 2
  %71 = load float, float* %70, align 4
  %72 = fmul float %71, 2.000000e+00
  %73 = insertelement <4 x float> zeroinitializer, float %72, i32 0
  %74 = alloca [3 x float], align 4
  %75 = getelementptr inbounds [3 x float], [3 x float]* %74, i64 0, i64 0
  %76 = getelementptr inbounds float, float* %75, i64 1
  %77 = load float, float* %76, align 4
  %78 = alloca [3 x float], align 4
  %79 = getelementptr inbounds [3 x float], [3 x float]* %78, i64 0, i64 0
  %80 = getelementptr inbounds float, float* %79, i64 2
  %81 = load float, float* %80, align 4
  %82 = fmul float %77, %81
  %83 = alloca [3 x float], align 4
  %84 = getelementptr inbounds [3 x float], [3 x float]* %83, i64 0, i64 0
  %85 = getelementptr inbounds float, float* %84, i64 2
  %86 = load float, float* %85, align 4
  %87 = alloca [3 x float], align 4
  %88 = getelementptr inbounds [3 x float], [3 x float]* %87, i64 0, i64 0
  %89 = getelementptr inbounds float, float* %88, i64 1
  %90 = load float, float* %89, align 4
  %91 = fmul float %86, %90
  %92 = fsub float %82, %91
  %93 = insertelement <4 x float> %73, float %92, i32 1
  %94 = alloca [3 x float], align 4
  %95 = getelementptr inbounds [3 x float], [3 x float]* %94, i64 0, i64 0
  %96 = getelementptr inbounds float, float* %95, i64 2
  %97 = load float, float* %96, align 4
  %98 = alloca [3 x float], align 4
  %99 = getelementptr inbounds [3 x float], [3 x float]* %98, i64 0, i64 0
  %100 = load float, float* %99, align 4
  %101 = fmul float %97, %100
  %102 = alloca [3 x float], align 4
  %103 = getelementptr inbounds [3 x float], [3 x float]* %102, i64 0, i64 0
  %104 = load float, float* %103, align 4
  %105 = alloca [3 x float], align 4
  %106 = getelementptr inbounds [3 x float], [3 x float]* %105, i64 0, i64 0
  %107 = getelementptr inbounds float, float* %106, i64 2
  %108 = load float, float* %107, align 4
  %109 = fmul float %104, %108
  %110 = fsub float %101, %109
  %111 = insertelement <4 x float> %93, float %110, i32 2
  %112 = alloca [3 x float], align 4
  %113 = getelementptr inbounds [3 x float], [3 x float]* %112, i64 0, i64 0
  %114 = load float, float* %113, align 4
  %115 = alloca [3 x float], align 4
  %116 = getelementptr inbounds [3 x float], [3 x float]* %115, i64 0, i64 0
  %117 = getelementptr inbounds float, float* %116, i64 1
  %118 = load float, float* %117, align 4
  %119 = fmul float %114, %118
  %120 = alloca [3 x float], align 4
  %121 = getelementptr inbounds [3 x float], [3 x float]* %120, i64 0, i64 0
  %122 = getelementptr inbounds float, float* %121, i64 1
  %123 = load float, float* %122, align 4
  %124 = alloca [3 x float], align 4
  %125 = getelementptr inbounds [3 x float], [3 x float]* %124, i64 0, i64 0
  %126 = load float, float* %125, align 4
  %127 = fmul float %123, %126
  %128 = fsub float %119, %127
  %129 = insertelement <4 x float> %111, float %128, i32 3
  %130 = load float, float* %1, align 4
  %131 = insertelement <4 x float> zeroinitializer, float %130, i32 0
  %132 = getelementptr inbounds float, float* %1, i64 1
  %133 = load float, float* %132, align 4
  %134 = insertelement <4 x float> %131, float %133, i32 1
  %135 = getelementptr inbounds float, float* %1, i64 2
  %136 = load float, float* %135, align 4
  %137 = insertelement <4 x float> %134, float %136, i32 2
  %138 = insertelement <4 x float> %137, float 0.000000e+00, i32 3
  %139 = getelementptr inbounds float, float* %0, i64 3
  %140 = load float, float* %139, align 4
  %141 = insertelement <4 x float> zeroinitializer, float %140, i32 0
  %142 = getelementptr inbounds float, float* %0, i64 3
  %143 = load float, float* %142, align 4
  %144 = insertelement <4 x float> %141, float %143, i32 1
  %145 = getelementptr inbounds float, float* %0, i64 3
  %146 = load float, float* %145, align 4
  %147 = insertelement <4 x float> %144, float %146, i32 2
  %148 = insertelement <4 x float> %147, float 1.000000e+00, i32 3
  %149 = alloca [3 x float], align 4
  %150 = getelementptr inbounds [3 x float], [3 x float]* %149, i64 0, i64 0
  %151 = load float, float* %150, align 4
  %152 = insertelement <4 x float> zeroinitializer, float %151, i32 0
  %153 = alloca [3 x float], align 4
  %154 = getelementptr inbounds [3 x float], [3 x float]* %153, i64 0, i64 1
  %155 = load float, float* %154, align 4
  %156 = insertelement <4 x float> %152, float %155, i32 1
  %157 = alloca [3 x float], align 4
  %158 = getelementptr inbounds [3 x float], [3 x float]* %157, i64 0, i64 2
  %159 = load float, float* %158, align 4
  %160 = insertelement <4 x float> %156, float %159, i32 2
  %161 = insertelement <4 x float> %160, float 0.000000e+00, i32 3
  %162 = call <4 x float> @llvm.fma.v4f32(<4 x float> %148, <4 x float> %161, <4 x float> %138)
  %163 = alloca [3 x float], align 4
  %164 = getelementptr inbounds [3 x float], [3 x float]* %163, i64 0, i64 0
  %165 = load float, float* %164, align 4
  %166 = insertelement <4 x float> zeroinitializer, float %165, i32 0
  %167 = alloca [3 x float], align 4
  %168 = getelementptr inbounds [3 x float], [3 x float]* %167, i64 0, i64 1
  %169 = load float, float* %168, align 4
  %170 = insertelement <4 x float> %166, float %169, i32 1
  %171 = alloca [3 x float], align 4
  %172 = getelementptr inbounds [3 x float], [3 x float]* %171, i64 0, i64 2
  %173 = load float, float* %172, align 4
  %174 = insertelement <4 x float> %170, float %173, i32 2
  %175 = insertelement <4 x float> %174, float 0.000000e+00, i32 3
  %176 = fadd <4 x float> %162, %175
  %177 = shufflevector <4 x float> %129, <4 x float> %176, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %178 = shufflevector <8 x float> %68, <8 x float> %177, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %179 = extractelement <16 x float> %178, i32 0
  %180 = alloca [3 x float], align 4
  %181 = getelementptr inbounds [3 x float], [3 x float]* %180, i64 0, i64 0
  store float %179, float* %181, align 4
  %182 = extractelement <16 x float> %178, i32 1
  %183 = alloca [3 x float], align 4
  %184 = getelementptr inbounds [3 x float], [3 x float]* %183, i64 0, i64 0
  %185 = getelementptr inbounds float, float* %184, i64 1
  store float %182, float* %185, align 4
  %186 = extractelement <16 x float> %178, i32 2
  %187 = alloca [3 x float], align 4
  %188 = getelementptr inbounds [3 x float], [3 x float]* %187, i64 0, i64 0
  %189 = getelementptr inbounds float, float* %188, i64 1
  %190 = getelementptr inbounds float, float* %189, i64 1
  store float %186, float* %190, align 4
  %191 = extractelement <16 x float> %178, i32 3
  %192 = alloca [3 x float], align 4
  %193 = getelementptr inbounds [3 x float], [3 x float]* %192, i64 0, i64 0
  store float %191, float* %193, align 4
  %194 = extractelement <16 x float> %178, i32 4
  %195 = alloca [3 x float], align 4
  %196 = getelementptr inbounds [3 x float], [3 x float]* %195, i64 0, i64 0
  %197 = getelementptr inbounds float, float* %196, i64 1
  store float %194, float* %197, align 4
  %198 = extractelement <16 x float> %178, i32 5
  %199 = alloca [3 x float], align 4
  %200 = getelementptr inbounds [3 x float], [3 x float]* %199, i64 0, i64 0
  %201 = getelementptr inbounds float, float* %200, i64 2
  store float %198, float* %201, align 4
  %202 = extractelement <16 x float> %178, i32 6
  %203 = alloca [3 x float], align 4
  %204 = getelementptr inbounds [3 x float], [3 x float]* %203, i64 0, i64 0
  store float %202, float* %204, align 4
  %205 = extractelement <16 x float> %178, i32 7
  %206 = alloca [3 x float], align 4
  %207 = getelementptr inbounds [3 x float], [3 x float]* %206, i64 0, i64 1
  store float %205, float* %207, align 4
  %208 = extractelement <16 x float> %178, i32 8
  %209 = alloca [3 x float], align 4
  %210 = getelementptr inbounds [3 x float], [3 x float]* %209, i64 0, i64 2
  store float %208, float* %210, align 4
  %211 = extractelement <16 x float> %178, i32 9
  %212 = alloca [3 x float], align 4
  %213 = getelementptr inbounds [3 x float], [3 x float]* %212, i64 0, i64 0
  store float %211, float* %213, align 4
  %214 = extractelement <16 x float> %178, i32 10
  %215 = alloca [3 x float], align 4
  %216 = getelementptr inbounds [3 x float], [3 x float]* %215, i64 0, i64 0
  %217 = getelementptr inbounds float, float* %216, i64 1
  store float %214, float* %217, align 4
  %218 = extractelement <16 x float> %178, i32 11
  %219 = alloca [3 x float], align 4
  %220 = getelementptr inbounds [3 x float], [3 x float]* %219, i64 0, i64 0
  %221 = getelementptr inbounds float, float* %220, i64 2
  store float %218, float* %221, align 4
  %222 = extractelement <16 x float> %178, i32 12
  store float %222, float* %2, align 4
  %223 = extractelement <16 x float> %178, i32 13
  %224 = getelementptr inbounds float, float* %2, i64 1
  store float %223, float* %224, align 4
  %225 = extractelement <16 x float> %178, i32 14
  %226 = getelementptr inbounds float, float* %2, i64 2
  store float %225, float* %226, align 4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #1 {
  %1 = alloca [4 x float], align 16
  %2 = alloca [4 x float], align 16
  %3 = alloca [4 x float], align 16
  %4 = bitcast [4 x float]* %1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %4, i8* align 16 bitcast ([4 x float]* @__const.main.q_in to i8*), i64 16, i1 false)
  %5 = bitcast [4 x float]* %2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %5, i8* align 16 bitcast ([4 x float]* @__const.main.p_in to i8*), i64 16, i1 false)
  %6 = bitcast [4 x float]* %3 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %6, i8 0, i64 16, i1 false)
  %7 = getelementptr inbounds [4 x float], [4 x float]* %1, i64 0, i64 0
  %8 = getelementptr inbounds [4 x float], [4 x float]* %2, i64 0, i64 0
  %9 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 0
  call void @point_product(float* %7, float* %8, float* %9)
  %10 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 0
  %11 = load float, float* %10, align 4
  %12 = fpext float %11 to double
  %13 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %12)
  %14 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 1
  %15 = load float, float* %14, align 4
  %16 = fpext float %15 to double
  %17 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %16)
  %18 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 2
  %19 = load float, float* %18, align 4
  %20 = fpext float %19 to double
  %21 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %20)
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #2

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #3

declare i32 @printf(i8*, ...) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.v4f32(<4 x float>, <4 x float>, <4 x float>) #5

attributes #0 = { alwaysinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { argmemonly nounwind willreturn }
attributes #3 = { argmemonly nounwind willreturn writeonly }
attributes #4 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { nounwind readnone speculatable willreturn }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
