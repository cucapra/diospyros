; ModuleID = 'aa.ll'
source_filename = "llvm-tests/2d-conv.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.mat_in = private unnamed_addr constant [4 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00], align 16
@__const.main.f_in = private unnamed_addr constant [4 x float] [float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00], align 16
@__const.main.expected = private unnamed_addr constant [9 x float] [float 1.000000e+00, float 3.000000e+00, float 2.000000e+00, float 4.000000e+00, float 1.000000e+01, float 6.000000e+00, float 3.000000e+00, float 7.000000e+00, float 4.000000e+00], align 16
@.str = private unnamed_addr constant [12 x i8] c"output: %f\0A\00", align 1
@__func__.main = private unnamed_addr constant [5 x i8] c"main\00", align 1
@.str.1 = private unnamed_addr constant [21 x i8] c"llvm-tests/2d-conv.c\00", align 1
@.str.2 = private unnamed_addr constant [26 x i8] c"mat_out[i] == expected[i]\00", align 1

; Function Attrs: noinline nounwind ssp uwtable
define void @convolution(float* %0, float* %1, float* %2) #0 {
.preheader7:
  %3 = load float, float* %0, align 4
  %4 = load float, float* %2, align 4
  %5 = load float, float* %1, align 4
  %6 = load float, float* %0, align 4
  %7 = fmul float %6, %5
  %8 = fadd float %4, %7
  %9 = getelementptr inbounds float, float* %2, i64 1
  %10 = getelementptr inbounds float, float* %1, i64 1
  %11 = load float, float* %10, align 4
  %12 = fmul float %3, %11
  %13 = load float, float* %9, align 4
  %14 = fadd float %13, %12
  %15 = getelementptr inbounds float, float* %0, i64 1
  %16 = load float, float* %15, align 4
  %17 = load float, float* %1, align 4
  %18 = fmul float %16, %17
  %19 = fadd float %14, %18
  %20 = getelementptr inbounds float, float* %2, i64 2
  %21 = load float, float* %15, align 4
  %22 = load float, float* %0, align 4
  %23 = load float, float* %10, align 4
  %24 = fmul float %21, %23
  %25 = load float, float* %20, align 4
  %26 = fadd float %25, %24
  %27 = getelementptr inbounds float, float* %2, i64 3
  %28 = getelementptr inbounds float, float* %1, i64 2
  %29 = load float, float* %28, align 4
  %30 = fmul float %22, %29
  %31 = load float, float* %27, align 4
  %32 = fadd float %31, %30
  %33 = getelementptr inbounds float, float* %0, i64 2
  %34 = load float, float* %33, align 4
  %35 = load float, float* %1, align 4
  %36 = load float, float* %0, align 4
  %37 = fmul float %34, %35
  %38 = fadd float %32, %37
  %39 = getelementptr inbounds float, float* %2, i64 4
  %40 = getelementptr inbounds float, float* %1, i64 3
  %41 = load float, float* %40, align 4
  %42 = fmul float %36, %41
  %43 = load float, float* %39, align 4
  %44 = fadd float %43, %42
  %45 = load float, float* %15, align 4
  %46 = load float, float* %28, align 4
  %47 = fmul float %45, %46
  %48 = fadd float %44, %47
  %49 = load float, float* %33, align 4
  %50 = load float, float* %10, align 4
  %51 = fmul float %49, %50
  %52 = fadd float %48, %51
  %53 = getelementptr inbounds float, float* %0, i64 3
  %54 = load float, float* %53, align 4
  %55 = load float, float* %1, align 4
  %56 = fmul float %54, %55
  %57 = fadd float %52, %56
  %58 = getelementptr inbounds float, float* %2, i64 5
  %59 = load float, float* %15, align 4
  %60 = load float, float* %40, align 4
  %61 = fmul float %59, %60
  %62 = load float, float* %58, align 4
  %63 = fadd float %62, %61
  %64 = load float, float* %53, align 4
  %65 = load float, float* %10, align 4
  %66 = fmul float %64, %65
  %67 = fadd float %63, %66
  %68 = getelementptr inbounds float, float* %2, i64 6
  %69 = load float, float* %33, align 4
  %70 = load float, float* %28, align 4
  %71 = fmul float %69, %70
  %72 = load float, float* %68, align 4
  %73 = fadd float %72, %71
  %74 = getelementptr inbounds float, float* %2, i64 7
  %75 = load float, float* %33, align 4
  %76 = load float, float* %40, align 4
  %77 = fmul float %75, %76
  %78 = load float, float* %74, align 4
  %79 = fadd float %78, %77
  %80 = load float, float* %53, align 4
  %81 = load float, float* %28, align 4
  %82 = fmul float %80, %81
  %83 = fadd float %79, %82
  %84 = getelementptr inbounds float, float* %2, i64 8
  %85 = load float, float* %53, align 4
  %86 = load float, float* %40, align 4
  %87 = fmul float %85, %86
  %88 = load float, float* %84, align 4
  %89 = fadd float %88, %87
  %90 = load float, float* %2, align 4
  %91 = insertelement <4 x float> zeroinitializer, float %90, i32 0
  %92 = insertelement <4 x float> %91, float 0.000000e+00, i32 1
  %93 = insertelement <4 x float> %92, float 0.000000e+00, i32 2
  %94 = insertelement <4 x float> %93, float 0.000000e+00, i32 3
  %95 = load float, float* %0, align 4
  %96 = insertelement <4 x float> zeroinitializer, float %95, i32 0
  %97 = insertelement <4 x float> %96, float 0.000000e+00, i32 1
  %98 = insertelement <4 x float> %97, float 0.000000e+00, i32 2
  %99 = insertelement <4 x float> %98, float 0.000000e+00, i32 3
  %100 = load float, float* %1, align 4
  %101 = insertelement <4 x float> zeroinitializer, float %100, i32 0
  %102 = insertelement <4 x float> %101, float 0.000000e+00, i32 1
  %103 = insertelement <4 x float> %102, float 0.000000e+00, i32 2
  %104 = insertelement <4 x float> %103, float 0.000000e+00, i32 3
  %105 = call <4 x float> @llvm.fma.f32(<4 x float> %99, <4 x float> %104, <4 x float> %94)
  %106 = extractelement <4 x float> %105, i32 0
  store float %106, float* %2, align 4
  %107 = getelementptr inbounds float, float* %2, i64 1
  %108 = load float, float* %107, align 4
  %109 = insertelement <4 x float> zeroinitializer, float %108, i32 0
  %110 = insertelement <4 x float> %109, float 0.000000e+00, i32 1
  %111 = insertelement <4 x float> %110, float 0.000000e+00, i32 2
  %112 = insertelement <4 x float> %111, float 0.000000e+00, i32 3
  %113 = load float, float* %0, align 4
  %114 = insertelement <4 x float> zeroinitializer, float %113, i32 0
  %115 = insertelement <4 x float> %114, float 0.000000e+00, i32 1
  %116 = insertelement <4 x float> %115, float 0.000000e+00, i32 2
  %117 = insertelement <4 x float> %116, float 0.000000e+00, i32 3
  %118 = getelementptr inbounds float, float* %1, i64 1
  %119 = load float, float* %118, align 4
  %120 = insertelement <4 x float> zeroinitializer, float %119, i32 0
  %121 = insertelement <4 x float> %120, float 0.000000e+00, i32 1
  %122 = insertelement <4 x float> %121, float 0.000000e+00, i32 2
  %123 = insertelement <4 x float> %122, float 0.000000e+00, i32 3
  %124 = call <4 x float> @llvm.fma.f32.1(<4 x float> %117, <4 x float> %123, <4 x float> %112)
  %125 = extractelement <4 x float> %124, i32 0
  %126 = getelementptr inbounds float, float* %2, i64 1
  store float %125, float* %126, align 4
  %127 = insertelement <4 x float> zeroinitializer, float %108, i32 0
  %128 = insertelement <4 x float> %127, float 0.000000e+00, i32 1
  %129 = insertelement <4 x float> %128, float 0.000000e+00, i32 2
  %130 = insertelement <4 x float> %129, float 0.000000e+00, i32 3
  %131 = load float, float* %0, align 4
  %132 = insertelement <4 x float> zeroinitializer, float %131, i32 0
  %133 = insertelement <4 x float> %132, float 1.000000e+00, i32 1
  %134 = insertelement <4 x float> %133, float 1.000000e+00, i32 2
  %135 = insertelement <4 x float> %134, float 1.000000e+00, i32 3
  %136 = insertelement <4 x float> zeroinitializer, float %119, i32 0
  %137 = insertelement <4 x float> %136, float 0.000000e+00, i32 1
  %138 = insertelement <4 x float> %137, float 0.000000e+00, i32 2
  %139 = insertelement <4 x float> %138, float 0.000000e+00, i32 3
  %140 = call <4 x float> @llvm.fma.f32.2(<4 x float> %135, <4 x float> %139, <4 x float> %130)
  %141 = getelementptr inbounds float, float* %0, i64 1
  %142 = load float, float* %141, align 4
  %143 = insertelement <4 x float> zeroinitializer, float %142, i32 0
  %144 = insertelement <4 x float> %143, float 0.000000e+00, i32 1
  %145 = insertelement <4 x float> %144, float 0.000000e+00, i32 2
  %146 = insertelement <4 x float> %145, float 0.000000e+00, i32 3
  %147 = load float, float* %1, align 4
  %148 = insertelement <4 x float> zeroinitializer, float %147, i32 0
  %149 = insertelement <4 x float> %148, float 0.000000e+00, i32 1
  %150 = insertelement <4 x float> %149, float 0.000000e+00, i32 2
  %151 = insertelement <4 x float> %150, float 0.000000e+00, i32 3
  %152 = call <4 x float> @llvm.fma.f32.3(<4 x float> %146, <4 x float> %151, <4 x float> %140)
  %153 = extractelement <4 x float> %152, i32 0
  %154 = getelementptr inbounds float, float* %2, i64 1
  store float %153, float* %154, align 4
  %155 = getelementptr inbounds float, float* %2, i64 2
  %156 = load float, float* %155, align 4
  %157 = insertelement <4 x float> zeroinitializer, float %156, i32 0
  %158 = insertelement <4 x float> %157, float 0.000000e+00, i32 1
  %159 = insertelement <4 x float> %158, float 0.000000e+00, i32 2
  %160 = insertelement <4 x float> %159, float 0.000000e+00, i32 3
  %161 = getelementptr inbounds float, float* %0, i64 1
  %162 = load float, float* %161, align 4
  %163 = insertelement <4 x float> zeroinitializer, float %162, i32 0
  %164 = insertelement <4 x float> %163, float 0.000000e+00, i32 1
  %165 = insertelement <4 x float> %164, float 0.000000e+00, i32 2
  %166 = insertelement <4 x float> %165, float 0.000000e+00, i32 3
  %167 = getelementptr inbounds float, float* %1, i64 1
  %168 = load float, float* %167, align 4
  %169 = insertelement <4 x float> zeroinitializer, float %168, i32 0
  %170 = insertelement <4 x float> %169, float 0.000000e+00, i32 1
  %171 = insertelement <4 x float> %170, float 0.000000e+00, i32 2
  %172 = insertelement <4 x float> %171, float 0.000000e+00, i32 3
  %173 = call <4 x float> @llvm.fma.f32.4(<4 x float> %166, <4 x float> %172, <4 x float> %160)
  %174 = extractelement <4 x float> %173, i32 0
  %175 = getelementptr inbounds float, float* %2, i64 2
  store float %174, float* %175, align 4
  %176 = getelementptr inbounds float, float* %2, i64 3
  %177 = load float, float* %176, align 4
  %178 = insertelement <4 x float> zeroinitializer, float %177, i32 1
  %179 = insertelement <4 x float> %178, float 0.000000e+00, i32 2
  %180 = insertelement <4 x float> %179, float 0.000000e+00, i32 3
  %181 = load float, float* %0, align 4
  %182 = insertelement <4 x float> <float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %181, i32 1
  %183 = insertelement <4 x float> %182, float 1.000000e+00, i32 2
  %184 = insertelement <4 x float> %183, float 1.000000e+00, i32 3
  %185 = getelementptr inbounds float, float* %2, i64 3
  %186 = load float, float* %185, align 4
  %187 = insertelement <4 x float> zeroinitializer, float %186, i32 0
  %188 = getelementptr inbounds float, float* %1, i64 2
  %189 = load float, float* %188, align 4
  %190 = insertelement <4 x float> %187, float %189, i32 1
  %191 = insertelement <4 x float> %190, float 0.000000e+00, i32 2
  %192 = insertelement <4 x float> %191, float 0.000000e+00, i32 3
  %193 = call <4 x float> @llvm.fma.f32.5(<4 x float> %184, <4 x float> %192, <4 x float> %180)
  %194 = load float, float* %0, align 4
  %195 = insertelement <4 x float> zeroinitializer, float %194, i32 0
  %196 = getelementptr inbounds float, float* %0, i64 2
  %197 = load float, float* %196, align 4
  %198 = insertelement <4 x float> %195, float %197, i32 1
  %199 = insertelement <4 x float> %198, float 0.000000e+00, i32 2
  %200 = insertelement <4 x float> %199, float 0.000000e+00, i32 3
  %201 = getelementptr inbounds float, float* %1, i64 2
  %202 = load float, float* %201, align 4
  %203 = insertelement <4 x float> zeroinitializer, float %202, i32 0
  %204 = load float, float* %1, align 4
  %205 = insertelement <4 x float> %203, float %204, i32 1
  %206 = insertelement <4 x float> %205, float 0.000000e+00, i32 2
  %207 = insertelement <4 x float> %206, float 0.000000e+00, i32 3
  %208 = call <4 x float> @llvm.fma.f32.6(<4 x float> %200, <4 x float> %207, <4 x float> %193)
  %209 = extractelement <4 x float> %208, i32 0
  %210 = getelementptr inbounds float, float* %2, i64 3
  store float %209, float* %210, align 4
  %211 = extractelement <4 x float> %208, i32 1
  %212 = getelementptr inbounds float, float* %2, i64 3
  store float %211, float* %212, align 4
  %213 = getelementptr inbounds float, float* %2, i64 4
  %214 = load float, float* %213, align 4
  %215 = insertelement <4 x float> zeroinitializer, float %214, i32 0
  %216 = insertelement <4 x float> %215, float 0.000000e+00, i32 1
  %217 = insertelement <4 x float> %216, float 0.000000e+00, i32 2
  %218 = insertelement <4 x float> %217, float 0.000000e+00, i32 3
  %219 = load float, float* %0, align 4
  %220 = insertelement <4 x float> zeroinitializer, float %219, i32 0
  %221 = insertelement <4 x float> %220, float 0.000000e+00, i32 1
  %222 = insertelement <4 x float> %221, float 0.000000e+00, i32 2
  %223 = insertelement <4 x float> %222, float 0.000000e+00, i32 3
  %224 = getelementptr inbounds float, float* %1, i64 3
  %225 = load float, float* %224, align 4
  %226 = insertelement <4 x float> zeroinitializer, float %225, i32 0
  %227 = insertelement <4 x float> %226, float 0.000000e+00, i32 1
  %228 = insertelement <4 x float> %227, float 0.000000e+00, i32 2
  %229 = insertelement <4 x float> %228, float 0.000000e+00, i32 3
  %230 = call <4 x float> @llvm.fma.f32.7(<4 x float> %223, <4 x float> %229, <4 x float> %218)
  %231 = extractelement <4 x float> %230, i32 0
  %232 = getelementptr inbounds float, float* %2, i64 4
  store float %231, float* %232, align 4
  %233 = insertelement <4 x float> zeroinitializer, float %214, i32 0
  %234 = insertelement <4 x float> %233, float 0.000000e+00, i32 1
  %235 = insertelement <4 x float> %234, float 0.000000e+00, i32 2
  %236 = insertelement <4 x float> %235, float 0.000000e+00, i32 3
  %237 = load float, float* %0, align 4
  %238 = insertelement <4 x float> zeroinitializer, float %237, i32 0
  %239 = insertelement <4 x float> %238, float 1.000000e+00, i32 1
  %240 = insertelement <4 x float> %239, float 1.000000e+00, i32 2
  %241 = insertelement <4 x float> %240, float 1.000000e+00, i32 3
  %242 = insertelement <4 x float> zeroinitializer, float %225, i32 0
  %243 = insertelement <4 x float> %242, float 0.000000e+00, i32 1
  %244 = insertelement <4 x float> %243, float 0.000000e+00, i32 2
  %245 = insertelement <4 x float> %244, float 0.000000e+00, i32 3
  %246 = call <4 x float> @llvm.fma.f32.8(<4 x float> %241, <4 x float> %245, <4 x float> %236)
  %247 = getelementptr inbounds float, float* %0, i64 1
  %248 = load float, float* %247, align 4
  %249 = insertelement <4 x float> zeroinitializer, float %248, i32 0
  %250 = insertelement <4 x float> %249, float 0.000000e+00, i32 1
  %251 = insertelement <4 x float> %250, float 0.000000e+00, i32 2
  %252 = insertelement <4 x float> %251, float 0.000000e+00, i32 3
  %253 = getelementptr inbounds float, float* %1, i64 2
  %254 = load float, float* %253, align 4
  %255 = insertelement <4 x float> zeroinitializer, float %254, i32 0
  %256 = insertelement <4 x float> %255, float 0.000000e+00, i32 1
  %257 = insertelement <4 x float> %256, float 0.000000e+00, i32 2
  %258 = insertelement <4 x float> %257, float 0.000000e+00, i32 3
  %259 = call <4 x float> @llvm.fma.f32.9(<4 x float> %252, <4 x float> %258, <4 x float> %246)
  %260 = extractelement <4 x float> %259, i32 0
  %261 = getelementptr inbounds float, float* %2, i64 4
  store float %260, float* %261, align 4
  %262 = insertelement <4 x float> zeroinitializer, float %214, i32 0
  %263 = insertelement <4 x float> %262, float 0.000000e+00, i32 1
  %264 = insertelement <4 x float> %263, float 0.000000e+00, i32 2
  %265 = insertelement <4 x float> %264, float 0.000000e+00, i32 3
  %266 = load float, float* %0, align 4
  %267 = insertelement <4 x float> zeroinitializer, float %266, i32 0
  %268 = insertelement <4 x float> %267, float 1.000000e+00, i32 1
  %269 = insertelement <4 x float> %268, float 1.000000e+00, i32 2
  %270 = insertelement <4 x float> %269, float 1.000000e+00, i32 3
  %271 = insertelement <4 x float> zeroinitializer, float %225, i32 0
  %272 = insertelement <4 x float> %271, float 0.000000e+00, i32 1
  %273 = insertelement <4 x float> %272, float 0.000000e+00, i32 2
  %274 = insertelement <4 x float> %273, float 0.000000e+00, i32 3
  %275 = call <4 x float> @llvm.fma.f32.10(<4 x float> %270, <4 x float> %274, <4 x float> %265)
  %276 = insertelement <4 x float> zeroinitializer, float %248, i32 0
  %277 = insertelement <4 x float> %276, float 1.000000e+00, i32 1
  %278 = insertelement <4 x float> %277, float 1.000000e+00, i32 2
  %279 = insertelement <4 x float> %278, float 1.000000e+00, i32 3
  %280 = insertelement <4 x float> zeroinitializer, float %254, i32 0
  %281 = insertelement <4 x float> %280, float 0.000000e+00, i32 1
  %282 = insertelement <4 x float> %281, float 0.000000e+00, i32 2
  %283 = insertelement <4 x float> %282, float 0.000000e+00, i32 3
  %284 = call <4 x float> @llvm.fma.f32.11(<4 x float> %279, <4 x float> %283, <4 x float> %275)
  %285 = getelementptr inbounds float, float* %0, i64 2
  %286 = load float, float* %285, align 4
  %287 = insertelement <4 x float> zeroinitializer, float %286, i32 0
  %288 = insertelement <4 x float> %287, float 0.000000e+00, i32 1
  %289 = insertelement <4 x float> %288, float 0.000000e+00, i32 2
  %290 = insertelement <4 x float> %289, float 0.000000e+00, i32 3
  %291 = getelementptr inbounds float, float* %1, i64 1
  %292 = load float, float* %291, align 4
  %293 = insertelement <4 x float> zeroinitializer, float %292, i32 0
  %294 = insertelement <4 x float> %293, float 0.000000e+00, i32 1
  %295 = insertelement <4 x float> %294, float 0.000000e+00, i32 2
  %296 = insertelement <4 x float> %295, float 0.000000e+00, i32 3
  %297 = call <4 x float> @llvm.fma.f32.12(<4 x float> %290, <4 x float> %296, <4 x float> %284)
  %298 = extractelement <4 x float> %297, i32 0
  %299 = getelementptr inbounds float, float* %2, i64 4
  store float %298, float* %299, align 4
  %300 = insertelement <4 x float> zeroinitializer, float %214, i32 0
  %301 = insertelement <4 x float> %300, float 0.000000e+00, i32 1
  %302 = insertelement <4 x float> %301, float 0.000000e+00, i32 2
  %303 = insertelement <4 x float> %302, float 0.000000e+00, i32 3
  %304 = load float, float* %0, align 4
  %305 = insertelement <4 x float> zeroinitializer, float %304, i32 0
  %306 = insertelement <4 x float> %305, float 1.000000e+00, i32 1
  %307 = insertelement <4 x float> %306, float 1.000000e+00, i32 2
  %308 = insertelement <4 x float> %307, float 1.000000e+00, i32 3
  %309 = insertelement <4 x float> zeroinitializer, float %225, i32 0
  %310 = insertelement <4 x float> %309, float 0.000000e+00, i32 1
  %311 = insertelement <4 x float> %310, float 0.000000e+00, i32 2
  %312 = insertelement <4 x float> %311, float 0.000000e+00, i32 3
  %313 = call <4 x float> @llvm.fma.f32.13(<4 x float> %308, <4 x float> %312, <4 x float> %303)
  %314 = insertelement <4 x float> zeroinitializer, float %248, i32 0
  %315 = insertelement <4 x float> %314, float 1.000000e+00, i32 1
  %316 = insertelement <4 x float> %315, float 1.000000e+00, i32 2
  %317 = insertelement <4 x float> %316, float 1.000000e+00, i32 3
  %318 = insertelement <4 x float> zeroinitializer, float %254, i32 0
  %319 = insertelement <4 x float> %318, float 0.000000e+00, i32 1
  %320 = insertelement <4 x float> %319, float 0.000000e+00, i32 2
  %321 = insertelement <4 x float> %320, float 0.000000e+00, i32 3
  %322 = call <4 x float> @llvm.fma.f32.14(<4 x float> %317, <4 x float> %321, <4 x float> %313)
  %323 = insertelement <4 x float> zeroinitializer, float %286, i32 0
  %324 = insertelement <4 x float> %323, float 1.000000e+00, i32 1
  %325 = insertelement <4 x float> %324, float 1.000000e+00, i32 2
  %326 = insertelement <4 x float> %325, float 1.000000e+00, i32 3
  %327 = insertelement <4 x float> zeroinitializer, float %292, i32 0
  %328 = insertelement <4 x float> %327, float 0.000000e+00, i32 1
  %329 = insertelement <4 x float> %328, float 0.000000e+00, i32 2
  %330 = insertelement <4 x float> %329, float 0.000000e+00, i32 3
  %331 = call <4 x float> @llvm.fma.f32.15(<4 x float> %326, <4 x float> %330, <4 x float> %322)
  %332 = getelementptr inbounds float, float* %0, i64 3
  %333 = load float, float* %332, align 4
  %334 = insertelement <4 x float> zeroinitializer, float %333, i32 0
  %335 = insertelement <4 x float> %334, float 0.000000e+00, i32 1
  %336 = insertelement <4 x float> %335, float 0.000000e+00, i32 2
  %337 = insertelement <4 x float> %336, float 0.000000e+00, i32 3
  %338 = load float, float* %1, align 4
  %339 = insertelement <4 x float> zeroinitializer, float %338, i32 0
  %340 = insertelement <4 x float> %339, float 0.000000e+00, i32 1
  %341 = insertelement <4 x float> %340, float 0.000000e+00, i32 2
  %342 = insertelement <4 x float> %341, float 0.000000e+00, i32 3
  %343 = call <4 x float> @llvm.fma.f32.16(<4 x float> %337, <4 x float> %342, <4 x float> %331)
  %344 = extractelement <4 x float> %343, i32 0
  %345 = getelementptr inbounds float, float* %2, i64 4
  store float %344, float* %345, align 4
  %346 = getelementptr inbounds float, float* %2, i64 5
  %347 = load float, float* %346, align 4
  %348 = insertelement <4 x float> zeroinitializer, float %347, i32 0
  %349 = insertelement <4 x float> %348, float 0.000000e+00, i32 1
  %350 = insertelement <4 x float> %349, float 0.000000e+00, i32 2
  %351 = insertelement <4 x float> %350, float 0.000000e+00, i32 3
  %352 = getelementptr inbounds float, float* %0, i64 1
  %353 = load float, float* %352, align 4
  %354 = insertelement <4 x float> zeroinitializer, float %353, i32 0
  %355 = insertelement <4 x float> %354, float 0.000000e+00, i32 1
  %356 = insertelement <4 x float> %355, float 0.000000e+00, i32 2
  %357 = insertelement <4 x float> %356, float 0.000000e+00, i32 3
  %358 = getelementptr inbounds float, float* %1, i64 3
  %359 = load float, float* %358, align 4
  %360 = insertelement <4 x float> zeroinitializer, float %359, i32 0
  %361 = insertelement <4 x float> %360, float 0.000000e+00, i32 1
  %362 = insertelement <4 x float> %361, float 0.000000e+00, i32 2
  %363 = insertelement <4 x float> %362, float 0.000000e+00, i32 3
  %364 = call <4 x float> @llvm.fma.f32.17(<4 x float> %357, <4 x float> %363, <4 x float> %351)
  %365 = extractelement <4 x float> %364, i32 0
  %366 = getelementptr inbounds float, float* %2, i64 5
  store float %365, float* %366, align 4
  %367 = insertelement <4 x float> zeroinitializer, float %347, i32 0
  %368 = insertelement <4 x float> %367, float 0.000000e+00, i32 1
  %369 = insertelement <4 x float> %368, float 0.000000e+00, i32 2
  %370 = insertelement <4 x float> %369, float 0.000000e+00, i32 3
  %371 = insertelement <4 x float> zeroinitializer, float %353, i32 0
  %372 = insertelement <4 x float> %371, float 1.000000e+00, i32 1
  %373 = insertelement <4 x float> %372, float 1.000000e+00, i32 2
  %374 = insertelement <4 x float> %373, float 1.000000e+00, i32 3
  %375 = insertelement <4 x float> zeroinitializer, float %359, i32 0
  %376 = insertelement <4 x float> %375, float 0.000000e+00, i32 1
  %377 = insertelement <4 x float> %376, float 0.000000e+00, i32 2
  %378 = insertelement <4 x float> %377, float 0.000000e+00, i32 3
  %379 = call <4 x float> @llvm.fma.f32.18(<4 x float> %374, <4 x float> %378, <4 x float> %370)
  %380 = getelementptr inbounds float, float* %0, i64 3
  %381 = load float, float* %380, align 4
  %382 = insertelement <4 x float> zeroinitializer, float %381, i32 0
  %383 = insertelement <4 x float> %382, float 0.000000e+00, i32 1
  %384 = insertelement <4 x float> %383, float 0.000000e+00, i32 2
  %385 = insertelement <4 x float> %384, float 0.000000e+00, i32 3
  %386 = getelementptr inbounds float, float* %1, i64 1
  %387 = load float, float* %386, align 4
  %388 = insertelement <4 x float> zeroinitializer, float %387, i32 0
  %389 = insertelement <4 x float> %388, float 0.000000e+00, i32 1
  %390 = insertelement <4 x float> %389, float 0.000000e+00, i32 2
  %391 = insertelement <4 x float> %390, float 0.000000e+00, i32 3
  %392 = call <4 x float> @llvm.fma.f32.19(<4 x float> %385, <4 x float> %391, <4 x float> %379)
  %393 = extractelement <4 x float> %392, i32 0
  %394 = getelementptr inbounds float, float* %2, i64 5
  store float %393, float* %394, align 4
  %395 = getelementptr inbounds float, float* %2, i64 6
  %396 = load float, float* %395, align 4
  %397 = insertelement <4 x float> zeroinitializer, float %396, i32 0
  %398 = insertelement <4 x float> %397, float 0.000000e+00, i32 1
  %399 = insertelement <4 x float> %398, float 0.000000e+00, i32 2
  %400 = insertelement <4 x float> %399, float 0.000000e+00, i32 3
  %401 = getelementptr inbounds float, float* %0, i64 2
  %402 = load float, float* %401, align 4
  %403 = insertelement <4 x float> zeroinitializer, float %402, i32 0
  %404 = insertelement <4 x float> %403, float 0.000000e+00, i32 1
  %405 = insertelement <4 x float> %404, float 0.000000e+00, i32 2
  %406 = insertelement <4 x float> %405, float 0.000000e+00, i32 3
  %407 = getelementptr inbounds float, float* %1, i64 2
  %408 = load float, float* %407, align 4
  %409 = insertelement <4 x float> zeroinitializer, float %408, i32 0
  %410 = insertelement <4 x float> %409, float 0.000000e+00, i32 1
  %411 = insertelement <4 x float> %410, float 0.000000e+00, i32 2
  %412 = insertelement <4 x float> %411, float 0.000000e+00, i32 3
  %413 = call <4 x float> @llvm.fma.f32.20(<4 x float> %406, <4 x float> %412, <4 x float> %400)
  %414 = extractelement <4 x float> %413, i32 0
  %415 = getelementptr inbounds float, float* %2, i64 6
  store float %414, float* %415, align 4
  %416 = getelementptr inbounds float, float* %2, i64 7
  %417 = load float, float* %416, align 4
  %418 = insertelement <4 x float> zeroinitializer, float %417, i32 0
  %419 = insertelement <4 x float> %418, float 0.000000e+00, i32 1
  %420 = insertelement <4 x float> %419, float 0.000000e+00, i32 2
  %421 = insertelement <4 x float> %420, float 0.000000e+00, i32 3
  %422 = getelementptr inbounds float, float* %0, i64 2
  %423 = load float, float* %422, align 4
  %424 = insertelement <4 x float> zeroinitializer, float %423, i32 0
  %425 = insertelement <4 x float> %424, float 0.000000e+00, i32 1
  %426 = insertelement <4 x float> %425, float 0.000000e+00, i32 2
  %427 = insertelement <4 x float> %426, float 0.000000e+00, i32 3
  %428 = getelementptr inbounds float, float* %1, i64 3
  %429 = load float, float* %428, align 4
  %430 = insertelement <4 x float> zeroinitializer, float %429, i32 0
  %431 = insertelement <4 x float> %430, float 0.000000e+00, i32 1
  %432 = insertelement <4 x float> %431, float 0.000000e+00, i32 2
  %433 = insertelement <4 x float> %432, float 0.000000e+00, i32 3
  %434 = call <4 x float> @llvm.fma.f32.21(<4 x float> %427, <4 x float> %433, <4 x float> %421)
  %435 = extractelement <4 x float> %434, i32 0
  %436 = getelementptr inbounds float, float* %2, i64 7
  store float %435, float* %436, align 4
  %437 = insertelement <4 x float> zeroinitializer, float %417, i32 0
  %438 = insertelement <4 x float> %437, float 0.000000e+00, i32 1
  %439 = insertelement <4 x float> %438, float 0.000000e+00, i32 2
  %440 = insertelement <4 x float> %439, float 0.000000e+00, i32 3
  %441 = insertelement <4 x float> zeroinitializer, float %423, i32 0
  %442 = insertelement <4 x float> %441, float 1.000000e+00, i32 1
  %443 = insertelement <4 x float> %442, float 1.000000e+00, i32 2
  %444 = insertelement <4 x float> %443, float 1.000000e+00, i32 3
  %445 = insertelement <4 x float> zeroinitializer, float %429, i32 0
  %446 = insertelement <4 x float> %445, float 0.000000e+00, i32 1
  %447 = insertelement <4 x float> %446, float 0.000000e+00, i32 2
  %448 = insertelement <4 x float> %447, float 0.000000e+00, i32 3
  %449 = call <4 x float> @llvm.fma.f32.22(<4 x float> %444, <4 x float> %448, <4 x float> %440)
  %450 = getelementptr inbounds float, float* %0, i64 3
  %451 = load float, float* %450, align 4
  %452 = insertelement <4 x float> zeroinitializer, float %451, i32 0
  %453 = insertelement <4 x float> %452, float 0.000000e+00, i32 1
  %454 = insertelement <4 x float> %453, float 0.000000e+00, i32 2
  %455 = insertelement <4 x float> %454, float 0.000000e+00, i32 3
  %456 = getelementptr inbounds float, float* %1, i64 2
  %457 = load float, float* %456, align 4
  %458 = insertelement <4 x float> zeroinitializer, float %457, i32 0
  %459 = insertelement <4 x float> %458, float 0.000000e+00, i32 1
  %460 = insertelement <4 x float> %459, float 0.000000e+00, i32 2
  %461 = insertelement <4 x float> %460, float 0.000000e+00, i32 3
  %462 = call <4 x float> @llvm.fma.f32.23(<4 x float> %455, <4 x float> %461, <4 x float> %449)
  %463 = extractelement <4 x float> %462, i32 0
  %464 = getelementptr inbounds float, float* %2, i64 7
  store float %463, float* %464, align 4
  %465 = getelementptr inbounds float, float* %2, i64 8
  %466 = load float, float* %465, align 4
  %467 = insertelement <4 x float> zeroinitializer, float %466, i32 0
  %468 = insertelement <4 x float> %467, float 0.000000e+00, i32 1
  %469 = insertelement <4 x float> %468, float 0.000000e+00, i32 2
  %470 = insertelement <4 x float> %469, float 0.000000e+00, i32 3
  %471 = getelementptr inbounds float, float* %0, i64 3
  %472 = load float, float* %471, align 4
  %473 = insertelement <4 x float> zeroinitializer, float %472, i32 0
  %474 = insertelement <4 x float> %473, float 0.000000e+00, i32 1
  %475 = insertelement <4 x float> %474, float 0.000000e+00, i32 2
  %476 = insertelement <4 x float> %475, float 0.000000e+00, i32 3
  %477 = getelementptr inbounds float, float* %1, i64 3
  %478 = load float, float* %477, align 4
  %479 = insertelement <4 x float> zeroinitializer, float %478, i32 0
  %480 = insertelement <4 x float> %479, float 0.000000e+00, i32 1
  %481 = insertelement <4 x float> %480, float 0.000000e+00, i32 2
  %482 = insertelement <4 x float> %481, float 0.000000e+00, i32 3
  %483 = call <4 x float> @llvm.fma.f32.24(<4 x float> %476, <4 x float> %482, <4 x float> %470)
  %484 = extractelement <4 x float> %483, i32 0
  %485 = getelementptr inbounds float, float* %2, i64 8
  store float %484, float* %485, align 4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #0 {
  %1 = alloca [4 x float], align 16
  %2 = alloca [4 x float], align 16
  %3 = alloca [9 x float], align 16
  %4 = bitcast [4 x float]* %1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 16 dereferenceable(16) %4, i8* nonnull align 16 dereferenceable(16) bitcast ([4 x float]* @__const.main.mat_in to i8*), i64 16, i1 false)
  %5 = bitcast [4 x float]* %2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 16 dereferenceable(16) %5, i8* nonnull align 16 dereferenceable(16) bitcast ([4 x float]* @__const.main.f_in to i8*), i64 16, i1 false)
  %6 = bitcast [9 x float]* %3 to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 dereferenceable(36) %6, i8 0, i64 36, i1 false)
  %7 = getelementptr inbounds [4 x float], [4 x float]* %1, i64 0, i64 0
  %8 = getelementptr inbounds [4 x float], [4 x float]* %2, i64 0, i64 0
  %9 = getelementptr inbounds [9 x float], [9 x float]* %3, i64 0, i64 0
  call void @convolution(float* nonnull %7, float* nonnull %8, float* nonnull %9)
  %10 = load float, float* %9, align 16
  %11 = fpext float %10 to double
  %12 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %11) #6
  %13 = load float, float* %9, align 16
  %14 = fcmp une float %13, 1.000000e+00
  br i1 %14, label %22, label %15

15:                                               ; preds = %0
  %16 = getelementptr inbounds [9 x float], [9 x float]* %3, i64 0, i64 1
  %17 = load float, float* %16, align 4
  %18 = fpext float %17 to double
  %19 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %18) #6
  %20 = load float, float* %16, align 4
  %21 = fcmp une float %20, 3.000000e+00
  br i1 %21, label %22, label %23

22:                                               ; preds = %65, %58, %51, %44, %37, %30, %23, %15, %0
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([21 x i8], [21 x i8]* @.str.1, i64 0, i64 0), i32 46, i8* getelementptr inbounds ([26 x i8], [26 x i8]* @.str.2, i64 0, i64 0)) #7
  unreachable

23:                                               ; preds = %15
  %24 = getelementptr inbounds [9 x float], [9 x float]* %3, i64 0, i64 2
  %25 = load float, float* %24, align 8
  %26 = fpext float %25 to double
  %27 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %26) #6
  %28 = load float, float* %24, align 8
  %29 = fcmp une float %28, 2.000000e+00
  br i1 %29, label %22, label %30

30:                                               ; preds = %23
  %31 = getelementptr inbounds [9 x float], [9 x float]* %3, i64 0, i64 3
  %32 = load float, float* %31, align 4
  %33 = fpext float %32 to double
  %34 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %33) #6
  %35 = load float, float* %31, align 4
  %36 = fcmp une float %35, 4.000000e+00
  br i1 %36, label %22, label %37

37:                                               ; preds = %30
  %38 = getelementptr inbounds [9 x float], [9 x float]* %3, i64 0, i64 4
  %39 = load float, float* %38, align 16
  %40 = fpext float %39 to double
  %41 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %40) #6
  %42 = load float, float* %38, align 16
  %43 = fcmp une float %42, 1.000000e+01
  br i1 %43, label %22, label %44

44:                                               ; preds = %37
  %45 = getelementptr inbounds [9 x float], [9 x float]* %3, i64 0, i64 5
  %46 = load float, float* %45, align 4
  %47 = fpext float %46 to double
  %48 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %47) #6
  %49 = load float, float* %45, align 4
  %50 = fcmp une float %49, 6.000000e+00
  br i1 %50, label %22, label %51

51:                                               ; preds = %44
  %52 = getelementptr inbounds [9 x float], [9 x float]* %3, i64 0, i64 6
  %53 = load float, float* %52, align 8
  %54 = fpext float %53 to double
  %55 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %54) #6
  %56 = load float, float* %52, align 8
  %57 = fcmp une float %56, 3.000000e+00
  br i1 %57, label %22, label %58

58:                                               ; preds = %51
  %59 = getelementptr inbounds [9 x float], [9 x float]* %3, i64 0, i64 7
  %60 = load float, float* %59, align 4
  %61 = fpext float %60 to double
  %62 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %61) #6
  %63 = load float, float* %59, align 4
  %64 = fcmp une float %63, 7.000000e+00
  br i1 %64, label %22, label %65

65:                                               ; preds = %58
  %66 = getelementptr inbounds [9 x float], [9 x float]* %3, i64 0, i64 8
  %67 = load float, float* %66, align 16
  %68 = fpext float %67 to double
  %69 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %68) #6
  %70 = load float, float* %66, align 16
  %71 = fcmp une float %70, 4.000000e+00
  br i1 %71, label %22, label %72

72:                                               ; preds = %65
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #1

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #2

declare i32 @printf(i8*, ...) #3

; Function Attrs: noreturn
declare void @__assert_rtn(i8*, i8*, i32, i8*) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32(<4 x float>, <4 x float>, <4 x float>) #5

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.1(<4 x float>, <4 x float>, <4 x float>) #5

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.2(<4 x float>, <4 x float>, <4 x float>) #5

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.3(<4 x float>, <4 x float>, <4 x float>) #5

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.4(<4 x float>, <4 x float>, <4 x float>) #5

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.5(<4 x float>, <4 x float>, <4 x float>) #5

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.6(<4 x float>, <4 x float>, <4 x float>) #5

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.7(<4 x float>, <4 x float>, <4 x float>) #5

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.8(<4 x float>, <4 x float>, <4 x float>) #5

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.9(<4 x float>, <4 x float>, <4 x float>) #5

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.10(<4 x float>, <4 x float>, <4 x float>) #5

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.11(<4 x float>, <4 x float>, <4 x float>) #5

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.12(<4 x float>, <4 x float>, <4 x float>) #5

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.13(<4 x float>, <4 x float>, <4 x float>) #5

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.14(<4 x float>, <4 x float>, <4 x float>) #5

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.15(<4 x float>, <4 x float>, <4 x float>) #5

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.16(<4 x float>, <4 x float>, <4 x float>) #5

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.17(<4 x float>, <4 x float>, <4 x float>) #5

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.18(<4 x float>, <4 x float>, <4 x float>) #5

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.19(<4 x float>, <4 x float>, <4 x float>) #5

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.20(<4 x float>, <4 x float>, <4 x float>) #5

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.21(<4 x float>, <4 x float>, <4 x float>) #5

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.22(<4 x float>, <4 x float>, <4 x float>) #5

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.23(<4 x float>, <4 x float>, <4 x float>) #5

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.24(<4 x float>, <4 x float>, <4 x float>) #5

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { argmemonly nounwind willreturn writeonly }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { noreturn "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="true" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { nounwind readnone speculatable willreturn }
attributes #6 = { nounwind }
attributes #7 = { noreturn nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
