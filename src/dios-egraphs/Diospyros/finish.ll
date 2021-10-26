; ModuleID = 'opt.ll'
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
  %40 = getelementptr inbounds float, float* %0, i64 1
  %41 = load float, float* %40, align 4
  %42 = insertelement <4 x float> zeroinitializer, float %41, i32 0
  %43 = getelementptr inbounds float, float* %0, i64 2
  %44 = load float, float* %43, align 4
  %45 = insertelement <4 x float> %42, float %44, i32 1
  %46 = getelementptr inbounds float, float* %0, i64 0
  %47 = load float, float* %46, align 4
  %48 = insertelement <4 x float> %45, float %47, i32 2
  %49 = insertelement <4 x float> %48, float 1.000000e+00, i32 3
  %50 = getelementptr inbounds float, float* %1, i64 2
  %51 = load float, float* %50, align 4
  %52 = insertelement <4 x float> zeroinitializer, float %51, i32 0
  %53 = getelementptr inbounds float, float* %1, i64 0
  %54 = load float, float* %53, align 4
  %55 = insertelement <4 x float> %52, float %54, i32 1
  %56 = getelementptr inbounds float, float* %1, i64 1
  %57 = load float, float* %56, align 4
  %58 = insertelement <4 x float> %55, float %57, i32 2
  %59 = insertelement <4 x float> %58, float 0.000000e+00, i32 3
  %60 = fmul <4 x float> %49, %59
  %61 = getelementptr inbounds float, float* %0, i64 2
  %62 = load float, float* %61, align 4
  %63 = insertelement <4 x float> zeroinitializer, float %62, i32 0
  %64 = getelementptr inbounds float, float* %0, i64 0
  %65 = load float, float* %64, align 4
  %66 = insertelement <4 x float> %63, float %65, i32 1
  %67 = getelementptr inbounds float, float* %0, i64 1
  %68 = load float, float* %67, align 4
  %69 = insertelement <4 x float> %66, float %68, i32 2
  %70 = insertelement <4 x float> %69, float 1.000000e+00, i32 3
  %71 = getelementptr inbounds float, float* %1, i64 1
  %72 = load float, float* %71, align 4
  %73 = insertelement <4 x float> zeroinitializer, float %72, i32 0
  %74 = getelementptr inbounds float, float* %1, i64 2
  %75 = load float, float* %74, align 4
  %76 = insertelement <4 x float> %73, float %75, i32 1
  %77 = getelementptr inbounds float, float* %1, i64 0
  %78 = load float, float* %77, align 4
  %79 = insertelement <4 x float> %76, float %78, i32 2
  %80 = insertelement <4 x float> %79, float 0.000000e+00, i32 3
  %81 = fmul <4 x float> %70, %80
  %82 = fsub <4 x float> %60, %81
  %83 = extractelement <4 x float> %82, i32 0
  %84 = getelementptr inbounds float, float* %2, i64 0
  store float %83, float* %84, align 4
  %85 = extractelement <4 x float> %82, i32 1
  %86 = getelementptr inbounds float, float* %2, i64 1
  store float %85, float* %86, align 4
  %87 = extractelement <4 x float> %82, i32 2
  %88 = getelementptr inbounds float, float* %2, i64 2
  store float %87, float* %88, align 4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define void @point_product(float* %0, float* %1, float* %2) #1 {
  %4 = alloca [3 x float], align 4
  %5 = alloca [3 x float], align 4
  %6 = alloca [3 x float], align 4
  %7 = getelementptr inbounds [3 x float], [3 x float]* %4, i64 0, i64 0
  %8 = getelementptr inbounds float, float* %0, i64 0
  %9 = load float, float* %8, align 4
  %10 = getelementptr inbounds float, float* %7, i64 1
  %11 = getelementptr inbounds float, float* %0, i64 1
  %12 = load float, float* %11, align 4
  %13 = getelementptr inbounds float, float* %10, i64 1
  %14 = getelementptr inbounds float, float* %0, i64 2
  %15 = load float, float* %14, align 4
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
  %49 = getelementptr inbounds [3 x float], [3 x float]* %5, i64 0, i64 0
  %50 = load float, float* %49, align 4
  %51 = fmul float %50, 2.000000e+00
  %52 = getelementptr inbounds [3 x float], [3 x float]* %5, i64 0, i64 0
  %53 = getelementptr inbounds [3 x float], [3 x float]* %5, i64 0, i64 1
  %54 = load float, float* %53, align 4
  %55 = fmul float %54, 2.000000e+00
  %56 = getelementptr inbounds [3 x float], [3 x float]* %5, i64 0, i64 1
  %57 = getelementptr inbounds [3 x float], [3 x float]* %5, i64 0, i64 2
  %58 = load float, float* %57, align 4
  %59 = fmul float %58, 2.000000e+00
  %60 = getelementptr inbounds [3 x float], [3 x float]* %5, i64 0, i64 2
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
  %127 = getelementptr inbounds float, float* %0, i64 0
  %128 = load float, float* %127, align 4
  %129 = insertelement <4 x float> zeroinitializer, float %128, i32 0
  %130 = getelementptr inbounds float, float* %0, i64 1
  %131 = load float, float* %130, align 4
  %132 = insertelement <4 x float> %129, float %131, i32 1
  %133 = getelementptr inbounds float, float* %0, i64 2
  %134 = load float, float* %133, align 4
  %135 = insertelement <4 x float> %132, float %134, i32 2
  %136 = alloca [3 x float], align 4
  %137 = getelementptr inbounds [3 x float], [3 x float]* %136, i64 0, i64 0
  %138 = getelementptr inbounds float, float* %137, i64 1
  %139 = load float, float* %138, align 4
  %140 = getelementptr inbounds float, float* %1, i64 2
  %141 = load float, float* %140, align 4
  %142 = fmul float %139, %141
  %143 = alloca [3 x float], align 4
  %144 = getelementptr inbounds [3 x float], [3 x float]* %143, i64 0, i64 0
  %145 = getelementptr inbounds float, float* %144, i64 2
  %146 = load float, float* %145, align 4
  %147 = getelementptr inbounds float, float* %1, i64 1
  %148 = load float, float* %147, align 4
  %149 = fmul float %146, %148
  %150 = fsub float %142, %149
  %151 = insertelement <4 x float> %135, float %150, i32 3
  %152 = alloca [3 x float], align 4
  %153 = getelementptr inbounds [3 x float], [3 x float]* %152, i64 0, i64 0
  %154 = load float, float* %153, align 4
  %155 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %154, i32 2
  %156 = alloca [3 x float], align 4
  %157 = getelementptr inbounds [3 x float], [3 x float]* %156, i64 0, i64 1
  %158 = load float, float* %157, align 4
  %159 = insertelement <4 x float> %155, float %158, i32 3
  %160 = alloca [3 x float], align 4
  %161 = getelementptr inbounds [3 x float], [3 x float]* %160, i64 0, i64 0
  %162 = getelementptr inbounds float, float* %161, i64 2
  %163 = load float, float* %162, align 4
  %164 = load float, float* %1, align 4
  %165 = fmul float %163, %164
  %166 = alloca [3 x float], align 4
  %167 = getelementptr inbounds [3 x float], [3 x float]* %166, i64 0, i64 0
  %168 = load float, float* %167, align 4
  %169 = getelementptr inbounds float, float* %1, i64 2
  %170 = load float, float* %169, align 4
  %171 = fmul float %168, %170
  %172 = fsub float %165, %171
  %173 = insertelement <4 x float> zeroinitializer, float %172, i32 0
  %174 = alloca [3 x float], align 4
  %175 = getelementptr inbounds [3 x float], [3 x float]* %174, i64 0, i64 0
  %176 = load float, float* %175, align 4
  %177 = getelementptr inbounds float, float* %1, i64 1
  %178 = load float, float* %177, align 4
  %179 = fmul float %176, %178
  %180 = alloca [3 x float], align 4
  %181 = getelementptr inbounds [3 x float], [3 x float]* %180, i64 0, i64 0
  %182 = getelementptr inbounds float, float* %181, i64 1
  %183 = load float, float* %182, align 4
  %184 = load float, float* %1, align 4
  %185 = fmul float %183, %184
  %186 = fsub float %179, %185
  %187 = insertelement <4 x float> %173, float %186, i32 1
  %188 = insertelement <4 x float> %187, float 2.000000e+00, i32 2
  %189 = insertelement <4 x float> %188, float 2.000000e+00, i32 3
  %190 = fmul <4 x float> %159, %189
  %191 = shufflevector <4 x float> %151, <4 x float> %190, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %192 = alloca [3 x float], align 4
  %193 = getelementptr inbounds [3 x float], [3 x float]* %192, i64 0, i64 2
  %194 = load float, float* %193, align 4
  %195 = fmul float %194, 2.000000e+00
  %196 = insertelement <4 x float> zeroinitializer, float %195, i32 0
  %197 = alloca [3 x float], align 4
  %198 = getelementptr inbounds [3 x float], [3 x float]* %197, i64 0, i64 0
  %199 = getelementptr inbounds float, float* %198, i64 1
  %200 = load float, float* %199, align 4
  %201 = alloca [3 x float], align 4
  %202 = getelementptr inbounds [3 x float], [3 x float]* %201, i64 0, i64 0
  %203 = getelementptr inbounds float, float* %202, i64 2
  %204 = load float, float* %203, align 4
  %205 = fmul float %200, %204
  %206 = alloca [3 x float], align 4
  %207 = getelementptr inbounds [3 x float], [3 x float]* %206, i64 0, i64 0
  %208 = getelementptr inbounds float, float* %207, i64 2
  %209 = load float, float* %208, align 4
  %210 = alloca [3 x float], align 4
  %211 = getelementptr inbounds [3 x float], [3 x float]* %210, i64 0, i64 0
  %212 = getelementptr inbounds float, float* %211, i64 1
  %213 = load float, float* %212, align 4
  %214 = fmul float %209, %213
  %215 = fsub float %205, %214
  %216 = insertelement <4 x float> %196, float %215, i32 1
  %217 = alloca [3 x float], align 4
  %218 = getelementptr inbounds [3 x float], [3 x float]* %217, i64 0, i64 0
  %219 = getelementptr inbounds float, float* %218, i64 2
  %220 = load float, float* %219, align 4
  %221 = alloca [3 x float], align 4
  %222 = getelementptr inbounds [3 x float], [3 x float]* %221, i64 0, i64 0
  %223 = load float, float* %222, align 4
  %224 = fmul float %220, %223
  %225 = alloca [3 x float], align 4
  %226 = getelementptr inbounds [3 x float], [3 x float]* %225, i64 0, i64 0
  %227 = load float, float* %226, align 4
  %228 = alloca [3 x float], align 4
  %229 = getelementptr inbounds [3 x float], [3 x float]* %228, i64 0, i64 0
  %230 = getelementptr inbounds float, float* %229, i64 2
  %231 = load float, float* %230, align 4
  %232 = fmul float %227, %231
  %233 = fsub float %224, %232
  %234 = insertelement <4 x float> %216, float %233, i32 2
  %235 = alloca [3 x float], align 4
  %236 = getelementptr inbounds [3 x float], [3 x float]* %235, i64 0, i64 0
  %237 = load float, float* %236, align 4
  %238 = alloca [3 x float], align 4
  %239 = getelementptr inbounds [3 x float], [3 x float]* %238, i64 0, i64 0
  %240 = getelementptr inbounds float, float* %239, i64 1
  %241 = load float, float* %240, align 4
  %242 = fmul float %237, %241
  %243 = alloca [3 x float], align 4
  %244 = getelementptr inbounds [3 x float], [3 x float]* %243, i64 0, i64 0
  %245 = getelementptr inbounds float, float* %244, i64 1
  %246 = load float, float* %245, align 4
  %247 = alloca [3 x float], align 4
  %248 = getelementptr inbounds [3 x float], [3 x float]* %247, i64 0, i64 0
  %249 = load float, float* %248, align 4
  %250 = fmul float %246, %249
  %251 = fsub float %242, %250
  %252 = insertelement <4 x float> %234, float %251, i32 3
  %253 = load float, float* %1, align 4
  %254 = insertelement <4 x float> zeroinitializer, float %253, i32 0
  %255 = getelementptr inbounds float, float* %1, i64 1
  %256 = load float, float* %255, align 4
  %257 = insertelement <4 x float> %254, float %256, i32 1
  %258 = getelementptr inbounds float, float* %1, i64 2
  %259 = load float, float* %258, align 4
  %260 = insertelement <4 x float> %257, float %259, i32 2
  %261 = insertelement <4 x float> %260, float 0.000000e+00, i32 3
  %262 = getelementptr inbounds float, float* %0, i64 3
  %263 = load float, float* %262, align 4
  %264 = insertelement <4 x float> zeroinitializer, float %263, i32 0
  %265 = getelementptr inbounds float, float* %0, i64 3
  %266 = load float, float* %265, align 4
  %267 = insertelement <4 x float> %264, float %266, i32 1
  %268 = getelementptr inbounds float, float* %0, i64 3
  %269 = load float, float* %268, align 4
  %270 = insertelement <4 x float> %267, float %269, i32 2
  %271 = insertelement <4 x float> %270, float 1.000000e+00, i32 3
  %272 = alloca [3 x float], align 4
  %273 = getelementptr inbounds [3 x float], [3 x float]* %272, i64 0, i64 0
  %274 = load float, float* %273, align 4
  %275 = insertelement <4 x float> zeroinitializer, float %274, i32 0
  %276 = alloca [3 x float], align 4
  %277 = getelementptr inbounds [3 x float], [3 x float]* %276, i64 0, i64 1
  %278 = load float, float* %277, align 4
  %279 = insertelement <4 x float> %275, float %278, i32 1
  %280 = alloca [3 x float], align 4
  %281 = getelementptr inbounds [3 x float], [3 x float]* %280, i64 0, i64 2
  %282 = load float, float* %281, align 4
  %283 = insertelement <4 x float> %279, float %282, i32 2
  %284 = insertelement <4 x float> %283, float 0.000000e+00, i32 3
  %285 = call <4 x float> @llvm.fma.f32(<4 x float> %271, <4 x float> %284, <4 x float> %261)
  %286 = alloca [3 x float], align 4
  %287 = getelementptr inbounds [3 x float], [3 x float]* %286, i64 0, i64 0
  %288 = load float, float* %287, align 4
  %289 = insertelement <4 x float> zeroinitializer, float %288, i32 0
  %290 = alloca [3 x float], align 4
  %291 = getelementptr inbounds [3 x float], [3 x float]* %290, i64 0, i64 1
  %292 = load float, float* %291, align 4
  %293 = insertelement <4 x float> %289, float %292, i32 1
  %294 = alloca [3 x float], align 4
  %295 = getelementptr inbounds [3 x float], [3 x float]* %294, i64 0, i64 2
  %296 = load float, float* %295, align 4
  %297 = insertelement <4 x float> %293, float %296, i32 2
  %298 = insertelement <4 x float> %297, float 0.000000e+00, i32 3
  %299 = fadd <4 x float> %285, %298
  %300 = shufflevector <4 x float> %252, <4 x float> %299, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %301 = shufflevector <8 x float> %191, <8 x float> %300, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %302 = extractelement <16 x float> %301, i32 0
  %303 = alloca [3 x float], align 4
  %304 = getelementptr inbounds [3 x float], [3 x float]* %303, i64 0, i64 0
  store float %302, float* %304, align 4
  %305 = extractelement <16 x float> %301, i32 1
  %306 = alloca [3 x float], align 4
  %307 = getelementptr inbounds [3 x float], [3 x float]* %306, i64 0, i64 0
  %308 = getelementptr inbounds float, float* %307, i64 1
  store float %305, float* %308, align 4
  %309 = extractelement <16 x float> %301, i32 2
  %310 = alloca [3 x float], align 4
  %311 = getelementptr inbounds [3 x float], [3 x float]* %310, i64 0, i64 0
  %312 = getelementptr inbounds float, float* %311, i64 1
  %313 = getelementptr inbounds float, float* %312, i64 1
  store float %309, float* %313, align 4
  %314 = extractelement <16 x float> %301, i32 3
  %315 = alloca [3 x float], align 4
  %316 = getelementptr inbounds [3 x float], [3 x float]* %315, i64 0, i64 0
  store float %314, float* %316, align 4
  %317 = extractelement <16 x float> %301, i32 4
  %318 = alloca [3 x float], align 4
  %319 = getelementptr inbounds [3 x float], [3 x float]* %318, i64 0, i64 0
  %320 = getelementptr inbounds float, float* %319, i64 1
  store float %317, float* %320, align 4
  %321 = extractelement <16 x float> %301, i32 5
  %322 = alloca [3 x float], align 4
  %323 = getelementptr inbounds [3 x float], [3 x float]* %322, i64 0, i64 0
  %324 = getelementptr inbounds float, float* %323, i64 2
  store float %321, float* %324, align 4
  %325 = extractelement <16 x float> %301, i32 6
  %326 = alloca [3 x float], align 4
  %327 = getelementptr inbounds [3 x float], [3 x float]* %326, i64 0, i64 0
  store float %325, float* %327, align 4
  %328 = extractelement <16 x float> %301, i32 7
  %329 = alloca [3 x float], align 4
  %330 = getelementptr inbounds [3 x float], [3 x float]* %329, i64 0, i64 1
  store float %328, float* %330, align 4
  %331 = extractelement <16 x float> %301, i32 8
  %332 = alloca [3 x float], align 4
  %333 = getelementptr inbounds [3 x float], [3 x float]* %332, i64 0, i64 2
  store float %331, float* %333, align 4
  %334 = extractelement <16 x float> %301, i32 9
  %335 = alloca [3 x float], align 4
  %336 = getelementptr inbounds [3 x float], [3 x float]* %335, i64 0, i64 0
  store float %334, float* %336, align 4
  %337 = extractelement <16 x float> %301, i32 10
  %338 = alloca [3 x float], align 4
  %339 = getelementptr inbounds [3 x float], [3 x float]* %338, i64 0, i64 0
  %340 = getelementptr inbounds float, float* %339, i64 1
  store float %337, float* %340, align 4
  %341 = extractelement <16 x float> %301, i32 11
  %342 = alloca [3 x float], align 4
  %343 = getelementptr inbounds [3 x float], [3 x float]* %342, i64 0, i64 0
  %344 = getelementptr inbounds float, float* %343, i64 2
  store float %341, float* %344, align 4
  %345 = extractelement <16 x float> %301, i32 12
  store float %345, float* %2, align 4
  %346 = extractelement <16 x float> %301, i32 13
  %347 = getelementptr inbounds float, float* %2, i64 1
  store float %346, float* %347, align 4
  %348 = extractelement <16 x float> %301, i32 14
  %349 = getelementptr inbounds float, float* %2, i64 2
  store float %348, float* %349, align 4
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
declare <4 x float> @llvm.fma.f32(<4 x float>, <4 x float>, <4 x float>) #5

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
