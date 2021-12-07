; ModuleID = 'aa.ll'
source_filename = "llvm-tests/2d-2d-conv.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.mat_in = private unnamed_addr constant [2 x [2 x float]] [[2 x float] [float 1.000000e+00, float 2.000000e+00], [2 x float] [float 3.000000e+00, float 4.000000e+00]], align 16
@__const.main.f_in = private unnamed_addr constant [2 x [2 x float]] [[2 x float] [float 1.000000e+00, float 1.000000e+00], [2 x float] [float 1.000000e+00, float 1.000000e+00]], align 16
@.str = private unnamed_addr constant [12 x i8] c"output: %f\0A\00", align 1

; Function Attrs: noinline nounwind ssp uwtable
define void @convolution([2 x float]* %0, [2 x float]* %1, [3 x float]* %2) #0 {
.preheader7:
  %3 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 0, i64 0
  %4 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 0, i64 0
  %5 = load float, float* %4, align 4
  %6 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 0, i64 0
  %7 = load float, float* %6, align 4
  %8 = fmul float %5, %7
  %9 = load float, float* %3, align 4
  %10 = fadd float %9, %8
  %11 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 0, i64 1
  %12 = load float, float* %4, align 4
  %13 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 0, i64 1
  %14 = load float, float* %13, align 4
  %15 = fmul float %12, %14
  %16 = load float, float* %11, align 4
  %17 = fadd float %16, %15
  %18 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 0, i64 1
  %19 = load float, float* %18, align 4
  %20 = load float, float* %6, align 4
  %21 = fmul float %19, %20
  %22 = fadd float %17, %21
  %23 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 0, i64 2
  %24 = load float, float* %18, align 4
  %25 = load float, float* %13, align 4
  %26 = fmul float %24, %25
  %27 = load float, float* %23, align 4
  %28 = fadd float %27, %26
  %29 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 1, i64 0
  %30 = load float, float* %4, align 4
  %31 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 1, i64 0
  %32 = load float, float* %31, align 4
  %33 = fmul float %30, %32
  %34 = load float, float* %29, align 4
  %35 = fadd float %34, %33
  %36 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 1, i64 0
  %37 = load float, float* %36, align 4
  %38 = load float, float* %6, align 4
  %39 = fmul float %37, %38
  %40 = fadd float %35, %39
  %41 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 1, i64 1
  %42 = load float, float* %4, align 4
  %43 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 1, i64 1
  %44 = load float, float* %43, align 4
  %45 = fmul float %42, %44
  %46 = load float, float* %41, align 4
  %47 = fadd float %46, %45
  %48 = load float, float* %18, align 4
  %49 = load float, float* %31, align 4
  %50 = fmul float %48, %49
  %51 = fadd float %47, %50
  %52 = load float, float* %36, align 4
  %53 = load float, float* %13, align 4
  %54 = fmul float %52, %53
  %55 = fadd float %51, %54
  %56 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 1, i64 1
  %57 = load float, float* %56, align 4
  %58 = load float, float* %6, align 4
  %59 = fmul float %57, %58
  %60 = fadd float %55, %59
  %61 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 1, i64 2
  %62 = load float, float* %18, align 4
  %63 = load float, float* %43, align 4
  %64 = fmul float %62, %63
  %65 = load float, float* %61, align 4
  %66 = fadd float %65, %64
  %67 = load float, float* %56, align 4
  %68 = load float, float* %13, align 4
  %69 = fmul float %67, %68
  %70 = fadd float %66, %69
  %71 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 2, i64 0
  %72 = load float, float* %36, align 4
  %73 = load float, float* %31, align 4
  %74 = fmul float %72, %73
  %75 = load float, float* %71, align 4
  %76 = fadd float %75, %74
  %77 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 2, i64 1
  %78 = load float, float* %36, align 4
  %79 = load float, float* %43, align 4
  %80 = fmul float %78, %79
  %81 = load float, float* %77, align 4
  %82 = fadd float %81, %80
  %83 = load float, float* %56, align 4
  %84 = load float, float* %31, align 4
  %85 = fmul float %83, %84
  %86 = fadd float %82, %85
  %87 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 2, i64 2
  %88 = load float, float* %56, align 4
  %89 = load float, float* %43, align 4
  %90 = fmul float %88, %89
  %91 = load float, float* %87, align 4
  %92 = fadd float %91, %90
  %93 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 0, i64 0
  %94 = load float, float* %93, align 4
  %95 = insertelement <4 x float> zeroinitializer, float %94, i32 0
  %96 = insertelement <4 x float> %95, float 0.000000e+00, i32 1
  %97 = insertelement <4 x float> %96, float 0.000000e+00, i32 2
  %98 = insertelement <4 x float> %97, float 0.000000e+00, i32 3
  %99 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 0, i64 0
  %100 = load float, float* %99, align 4
  %101 = insertelement <4 x float> zeroinitializer, float %100, i32 0
  %102 = insertelement <4 x float> %101, float 0.000000e+00, i32 1
  %103 = insertelement <4 x float> %102, float 0.000000e+00, i32 2
  %104 = insertelement <4 x float> %103, float 0.000000e+00, i32 3
  %105 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 0, i64 0
  %106 = load float, float* %105, align 4
  %107 = insertelement <4 x float> zeroinitializer, float %106, i32 0
  %108 = insertelement <4 x float> %107, float 0.000000e+00, i32 1
  %109 = insertelement <4 x float> %108, float 0.000000e+00, i32 2
  %110 = insertelement <4 x float> %109, float 0.000000e+00, i32 3
  %111 = call <4 x float> @llvm.fma.f32(<4 x float> %104, <4 x float> %110, <4 x float> %98)
  %112 = extractelement <4 x float> %111, i32 0
  %113 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 0, i64 0
  store float %112, float* %113, align 4
  %114 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 0, i64 1
  %115 = load float, float* %114, align 4
  %116 = insertelement <4 x float> zeroinitializer, float %115, i32 0
  %117 = insertelement <4 x float> %116, float 0.000000e+00, i32 1
  %118 = insertelement <4 x float> %117, float 0.000000e+00, i32 2
  %119 = insertelement <4 x float> %118, float 0.000000e+00, i32 3
  %120 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 0, i64 0
  %121 = load float, float* %120, align 4
  %122 = insertelement <4 x float> zeroinitializer, float %121, i32 0
  %123 = insertelement <4 x float> %122, float 0.000000e+00, i32 1
  %124 = insertelement <4 x float> %123, float 0.000000e+00, i32 2
  %125 = insertelement <4 x float> %124, float 0.000000e+00, i32 3
  %126 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 0, i64 1
  %127 = load float, float* %126, align 4
  %128 = insertelement <4 x float> zeroinitializer, float %127, i32 0
  %129 = insertelement <4 x float> %128, float 0.000000e+00, i32 1
  %130 = insertelement <4 x float> %129, float 0.000000e+00, i32 2
  %131 = insertelement <4 x float> %130, float 0.000000e+00, i32 3
  %132 = call <4 x float> @llvm.fma.f32.1(<4 x float> %125, <4 x float> %131, <4 x float> %119)
  %133 = extractelement <4 x float> %132, i32 0
  %134 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 0, i64 1
  store float %133, float* %134, align 4
  %135 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 0, i64 1
  %136 = load float, float* %135, align 4
  %137 = insertelement <4 x float> zeroinitializer, float %136, i32 0
  %138 = insertelement <4 x float> %137, float 0.000000e+00, i32 1
  %139 = insertelement <4 x float> %138, float 0.000000e+00, i32 2
  %140 = insertelement <4 x float> %139, float 0.000000e+00, i32 3
  %141 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 0, i64 0
  %142 = load float, float* %141, align 4
  %143 = insertelement <4 x float> zeroinitializer, float %142, i32 0
  %144 = insertelement <4 x float> %143, float 1.000000e+00, i32 1
  %145 = insertelement <4 x float> %144, float 1.000000e+00, i32 2
  %146 = insertelement <4 x float> %145, float 1.000000e+00, i32 3
  %147 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 0, i64 1
  %148 = load float, float* %147, align 4
  %149 = insertelement <4 x float> zeroinitializer, float %148, i32 0
  %150 = insertelement <4 x float> %149, float 0.000000e+00, i32 1
  %151 = insertelement <4 x float> %150, float 0.000000e+00, i32 2
  %152 = insertelement <4 x float> %151, float 0.000000e+00, i32 3
  %153 = call <4 x float> @llvm.fma.f32.2(<4 x float> %146, <4 x float> %152, <4 x float> %140)
  %154 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 0, i64 1
  %155 = load float, float* %154, align 4
  %156 = insertelement <4 x float> zeroinitializer, float %155, i32 0
  %157 = insertelement <4 x float> %156, float 0.000000e+00, i32 1
  %158 = insertelement <4 x float> %157, float 0.000000e+00, i32 2
  %159 = insertelement <4 x float> %158, float 0.000000e+00, i32 3
  %160 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 0, i64 0
  %161 = load float, float* %160, align 4
  %162 = insertelement <4 x float> zeroinitializer, float %161, i32 0
  %163 = insertelement <4 x float> %162, float 0.000000e+00, i32 1
  %164 = insertelement <4 x float> %163, float 0.000000e+00, i32 2
  %165 = insertelement <4 x float> %164, float 0.000000e+00, i32 3
  %166 = call <4 x float> @llvm.fma.f32.3(<4 x float> %159, <4 x float> %165, <4 x float> %153)
  %167 = extractelement <4 x float> %166, i32 0
  %168 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 0, i64 1
  store float %167, float* %168, align 4
  %169 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 0, i64 2
  %170 = load float, float* %169, align 4
  %171 = insertelement <4 x float> zeroinitializer, float %170, i32 0
  %172 = insertelement <4 x float> %171, float 0.000000e+00, i32 1
  %173 = insertelement <4 x float> %172, float 0.000000e+00, i32 2
  %174 = insertelement <4 x float> %173, float 0.000000e+00, i32 3
  %175 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 0, i64 1
  %176 = load float, float* %175, align 4
  %177 = insertelement <4 x float> zeroinitializer, float %176, i32 0
  %178 = insertelement <4 x float> %177, float 0.000000e+00, i32 1
  %179 = insertelement <4 x float> %178, float 0.000000e+00, i32 2
  %180 = insertelement <4 x float> %179, float 0.000000e+00, i32 3
  %181 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 0, i64 1
  %182 = load float, float* %181, align 4
  %183 = insertelement <4 x float> zeroinitializer, float %182, i32 0
  %184 = insertelement <4 x float> %183, float 0.000000e+00, i32 1
  %185 = insertelement <4 x float> %184, float 0.000000e+00, i32 2
  %186 = insertelement <4 x float> %185, float 0.000000e+00, i32 3
  %187 = call <4 x float> @llvm.fma.f32.4(<4 x float> %180, <4 x float> %186, <4 x float> %174)
  %188 = extractelement <4 x float> %187, i32 0
  %189 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 0, i64 2
  store float %188, float* %189, align 4
  %190 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 1, i64 0
  %191 = load float, float* %190, align 4
  %192 = insertelement <4 x float> zeroinitializer, float %191, i32 0
  %193 = insertelement <4 x float> %192, float 0.000000e+00, i32 1
  %194 = insertelement <4 x float> %193, float 0.000000e+00, i32 2
  %195 = insertelement <4 x float> %194, float 0.000000e+00, i32 3
  %196 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 0, i64 0
  %197 = load float, float* %196, align 4
  %198 = insertelement <4 x float> zeroinitializer, float %197, i32 0
  %199 = insertelement <4 x float> %198, float 0.000000e+00, i32 1
  %200 = insertelement <4 x float> %199, float 0.000000e+00, i32 2
  %201 = insertelement <4 x float> %200, float 0.000000e+00, i32 3
  %202 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 1, i64 0
  %203 = load float, float* %202, align 4
  %204 = insertelement <4 x float> zeroinitializer, float %203, i32 0
  %205 = insertelement <4 x float> %204, float 0.000000e+00, i32 1
  %206 = insertelement <4 x float> %205, float 0.000000e+00, i32 2
  %207 = insertelement <4 x float> %206, float 0.000000e+00, i32 3
  %208 = call <4 x float> @llvm.fma.f32.5(<4 x float> %201, <4 x float> %207, <4 x float> %195)
  %209 = extractelement <4 x float> %208, i32 0
  %210 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 1, i64 0
  store float %209, float* %210, align 4
  %211 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 1, i64 0
  %212 = load float, float* %211, align 4
  %213 = insertelement <4 x float> zeroinitializer, float %212, i32 0
  %214 = insertelement <4 x float> %213, float 0.000000e+00, i32 1
  %215 = insertelement <4 x float> %214, float 0.000000e+00, i32 2
  %216 = insertelement <4 x float> %215, float 0.000000e+00, i32 3
  %217 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 0, i64 0
  %218 = load float, float* %217, align 4
  %219 = insertelement <4 x float> zeroinitializer, float %218, i32 0
  %220 = insertelement <4 x float> %219, float 1.000000e+00, i32 1
  %221 = insertelement <4 x float> %220, float 1.000000e+00, i32 2
  %222 = insertelement <4 x float> %221, float 1.000000e+00, i32 3
  %223 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 1, i64 0
  %224 = load float, float* %223, align 4
  %225 = insertelement <4 x float> zeroinitializer, float %224, i32 0
  %226 = insertelement <4 x float> %225, float 0.000000e+00, i32 1
  %227 = insertelement <4 x float> %226, float 0.000000e+00, i32 2
  %228 = insertelement <4 x float> %227, float 0.000000e+00, i32 3
  %229 = call <4 x float> @llvm.fma.f32.6(<4 x float> %222, <4 x float> %228, <4 x float> %216)
  %230 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 1, i64 0
  %231 = load float, float* %230, align 4
  %232 = insertelement <4 x float> zeroinitializer, float %231, i32 0
  %233 = insertelement <4 x float> %232, float 0.000000e+00, i32 1
  %234 = insertelement <4 x float> %233, float 0.000000e+00, i32 2
  %235 = insertelement <4 x float> %234, float 0.000000e+00, i32 3
  %236 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 0, i64 0
  %237 = load float, float* %236, align 4
  %238 = insertelement <4 x float> zeroinitializer, float %237, i32 0
  %239 = insertelement <4 x float> %238, float 0.000000e+00, i32 1
  %240 = insertelement <4 x float> %239, float 0.000000e+00, i32 2
  %241 = insertelement <4 x float> %240, float 0.000000e+00, i32 3
  %242 = call <4 x float> @llvm.fma.f32.7(<4 x float> %235, <4 x float> %241, <4 x float> %229)
  %243 = extractelement <4 x float> %242, i32 0
  %244 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 1, i64 0
  store float %243, float* %244, align 4
  %245 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 1, i64 1
  %246 = load float, float* %245, align 4
  %247 = insertelement <4 x float> zeroinitializer, float %246, i32 0
  %248 = insertelement <4 x float> %247, float 0.000000e+00, i32 1
  %249 = insertelement <4 x float> %248, float 0.000000e+00, i32 2
  %250 = insertelement <4 x float> %249, float 0.000000e+00, i32 3
  %251 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 0, i64 0
  %252 = load float, float* %251, align 4
  %253 = insertelement <4 x float> zeroinitializer, float %252, i32 0
  %254 = insertelement <4 x float> %253, float 0.000000e+00, i32 1
  %255 = insertelement <4 x float> %254, float 0.000000e+00, i32 2
  %256 = insertelement <4 x float> %255, float 0.000000e+00, i32 3
  %257 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 1, i64 1
  %258 = load float, float* %257, align 4
  %259 = insertelement <4 x float> zeroinitializer, float %258, i32 0
  %260 = insertelement <4 x float> %259, float 0.000000e+00, i32 1
  %261 = insertelement <4 x float> %260, float 0.000000e+00, i32 2
  %262 = insertelement <4 x float> %261, float 0.000000e+00, i32 3
  %263 = call <4 x float> @llvm.fma.f32.8(<4 x float> %256, <4 x float> %262, <4 x float> %250)
  %264 = extractelement <4 x float> %263, i32 0
  %265 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 1, i64 1
  store float %264, float* %265, align 4
  %266 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 1, i64 1
  %267 = load float, float* %266, align 4
  %268 = insertelement <4 x float> zeroinitializer, float %267, i32 0
  %269 = insertelement <4 x float> %268, float 0.000000e+00, i32 1
  %270 = insertelement <4 x float> %269, float 0.000000e+00, i32 2
  %271 = insertelement <4 x float> %270, float 0.000000e+00, i32 3
  %272 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 0, i64 0
  %273 = load float, float* %272, align 4
  %274 = insertelement <4 x float> zeroinitializer, float %273, i32 0
  %275 = insertelement <4 x float> %274, float 1.000000e+00, i32 1
  %276 = insertelement <4 x float> %275, float 1.000000e+00, i32 2
  %277 = insertelement <4 x float> %276, float 1.000000e+00, i32 3
  %278 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 1, i64 1
  %279 = load float, float* %278, align 4
  %280 = insertelement <4 x float> zeroinitializer, float %279, i32 0
  %281 = insertelement <4 x float> %280, float 0.000000e+00, i32 1
  %282 = insertelement <4 x float> %281, float 0.000000e+00, i32 2
  %283 = insertelement <4 x float> %282, float 0.000000e+00, i32 3
  %284 = call <4 x float> @llvm.fma.f32.9(<4 x float> %277, <4 x float> %283, <4 x float> %271)
  %285 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 0, i64 1
  %286 = load float, float* %285, align 4
  %287 = insertelement <4 x float> zeroinitializer, float %286, i32 0
  %288 = insertelement <4 x float> %287, float 0.000000e+00, i32 1
  %289 = insertelement <4 x float> %288, float 0.000000e+00, i32 2
  %290 = insertelement <4 x float> %289, float 0.000000e+00, i32 3
  %291 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 1, i64 0
  %292 = load float, float* %291, align 4
  %293 = insertelement <4 x float> zeroinitializer, float %292, i32 0
  %294 = insertelement <4 x float> %293, float 0.000000e+00, i32 1
  %295 = insertelement <4 x float> %294, float 0.000000e+00, i32 2
  %296 = insertelement <4 x float> %295, float 0.000000e+00, i32 3
  %297 = call <4 x float> @llvm.fma.f32.10(<4 x float> %290, <4 x float> %296, <4 x float> %284)
  %298 = extractelement <4 x float> %297, i32 0
  %299 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 1, i64 1
  store float %298, float* %299, align 4
  %300 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 1, i64 1
  %301 = load float, float* %300, align 4
  %302 = insertelement <4 x float> zeroinitializer, float %301, i32 0
  %303 = insertelement <4 x float> %302, float 0.000000e+00, i32 1
  %304 = insertelement <4 x float> %303, float 0.000000e+00, i32 2
  %305 = insertelement <4 x float> %304, float 0.000000e+00, i32 3
  %306 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 0, i64 0
  %307 = load float, float* %306, align 4
  %308 = insertelement <4 x float> zeroinitializer, float %307, i32 0
  %309 = insertelement <4 x float> %308, float 1.000000e+00, i32 1
  %310 = insertelement <4 x float> %309, float 1.000000e+00, i32 2
  %311 = insertelement <4 x float> %310, float 1.000000e+00, i32 3
  %312 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 1, i64 1
  %313 = load float, float* %312, align 4
  %314 = insertelement <4 x float> zeroinitializer, float %313, i32 0
  %315 = insertelement <4 x float> %314, float 0.000000e+00, i32 1
  %316 = insertelement <4 x float> %315, float 0.000000e+00, i32 2
  %317 = insertelement <4 x float> %316, float 0.000000e+00, i32 3
  %318 = call <4 x float> @llvm.fma.f32.11(<4 x float> %311, <4 x float> %317, <4 x float> %305)
  %319 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 0, i64 1
  %320 = load float, float* %319, align 4
  %321 = insertelement <4 x float> zeroinitializer, float %320, i32 0
  %322 = insertelement <4 x float> %321, float 1.000000e+00, i32 1
  %323 = insertelement <4 x float> %322, float 1.000000e+00, i32 2
  %324 = insertelement <4 x float> %323, float 1.000000e+00, i32 3
  %325 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 1, i64 0
  %326 = load float, float* %325, align 4
  %327 = insertelement <4 x float> zeroinitializer, float %326, i32 0
  %328 = insertelement <4 x float> %327, float 0.000000e+00, i32 1
  %329 = insertelement <4 x float> %328, float 0.000000e+00, i32 2
  %330 = insertelement <4 x float> %329, float 0.000000e+00, i32 3
  %331 = call <4 x float> @llvm.fma.f32.12(<4 x float> %324, <4 x float> %330, <4 x float> %318)
  %332 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 1, i64 0
  %333 = load float, float* %332, align 4
  %334 = insertelement <4 x float> zeroinitializer, float %333, i32 0
  %335 = insertelement <4 x float> %334, float 0.000000e+00, i32 1
  %336 = insertelement <4 x float> %335, float 0.000000e+00, i32 2
  %337 = insertelement <4 x float> %336, float 0.000000e+00, i32 3
  %338 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 0, i64 1
  %339 = load float, float* %338, align 4
  %340 = insertelement <4 x float> zeroinitializer, float %339, i32 0
  %341 = insertelement <4 x float> %340, float 0.000000e+00, i32 1
  %342 = insertelement <4 x float> %341, float 0.000000e+00, i32 2
  %343 = insertelement <4 x float> %342, float 0.000000e+00, i32 3
  %344 = call <4 x float> @llvm.fma.f32.13(<4 x float> %337, <4 x float> %343, <4 x float> %331)
  %345 = extractelement <4 x float> %344, i32 0
  %346 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 1, i64 1
  store float %345, float* %346, align 4
  %347 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 1, i64 1
  %348 = load float, float* %347, align 4
  %349 = insertelement <4 x float> zeroinitializer, float %348, i32 0
  %350 = insertelement <4 x float> %349, float 0.000000e+00, i32 1
  %351 = insertelement <4 x float> %350, float 0.000000e+00, i32 2
  %352 = insertelement <4 x float> %351, float 0.000000e+00, i32 3
  %353 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 0, i64 0
  %354 = load float, float* %353, align 4
  %355 = insertelement <4 x float> zeroinitializer, float %354, i32 0
  %356 = insertelement <4 x float> %355, float 1.000000e+00, i32 1
  %357 = insertelement <4 x float> %356, float 1.000000e+00, i32 2
  %358 = insertelement <4 x float> %357, float 1.000000e+00, i32 3
  %359 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 1, i64 1
  %360 = load float, float* %359, align 4
  %361 = insertelement <4 x float> zeroinitializer, float %360, i32 0
  %362 = insertelement <4 x float> %361, float 0.000000e+00, i32 1
  %363 = insertelement <4 x float> %362, float 0.000000e+00, i32 2
  %364 = insertelement <4 x float> %363, float 0.000000e+00, i32 3
  %365 = call <4 x float> @llvm.fma.f32.14(<4 x float> %358, <4 x float> %364, <4 x float> %352)
  %366 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 0, i64 1
  %367 = load float, float* %366, align 4
  %368 = insertelement <4 x float> zeroinitializer, float %367, i32 0
  %369 = insertelement <4 x float> %368, float 1.000000e+00, i32 1
  %370 = insertelement <4 x float> %369, float 1.000000e+00, i32 2
  %371 = insertelement <4 x float> %370, float 1.000000e+00, i32 3
  %372 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 1, i64 0
  %373 = load float, float* %372, align 4
  %374 = insertelement <4 x float> zeroinitializer, float %373, i32 0
  %375 = insertelement <4 x float> %374, float 0.000000e+00, i32 1
  %376 = insertelement <4 x float> %375, float 0.000000e+00, i32 2
  %377 = insertelement <4 x float> %376, float 0.000000e+00, i32 3
  %378 = call <4 x float> @llvm.fma.f32.15(<4 x float> %371, <4 x float> %377, <4 x float> %365)
  %379 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 1, i64 0
  %380 = load float, float* %379, align 4
  %381 = insertelement <4 x float> zeroinitializer, float %380, i32 0
  %382 = insertelement <4 x float> %381, float 1.000000e+00, i32 1
  %383 = insertelement <4 x float> %382, float 1.000000e+00, i32 2
  %384 = insertelement <4 x float> %383, float 1.000000e+00, i32 3
  %385 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 0, i64 1
  %386 = load float, float* %385, align 4
  %387 = insertelement <4 x float> zeroinitializer, float %386, i32 0
  %388 = insertelement <4 x float> %387, float 0.000000e+00, i32 1
  %389 = insertelement <4 x float> %388, float 0.000000e+00, i32 2
  %390 = insertelement <4 x float> %389, float 0.000000e+00, i32 3
  %391 = call <4 x float> @llvm.fma.f32.16(<4 x float> %384, <4 x float> %390, <4 x float> %378)
  %392 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 1, i64 1
  %393 = load float, float* %392, align 4
  %394 = insertelement <4 x float> zeroinitializer, float %393, i32 0
  %395 = insertelement <4 x float> %394, float 0.000000e+00, i32 1
  %396 = insertelement <4 x float> %395, float 0.000000e+00, i32 2
  %397 = insertelement <4 x float> %396, float 0.000000e+00, i32 3
  %398 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 0, i64 0
  %399 = load float, float* %398, align 4
  %400 = insertelement <4 x float> zeroinitializer, float %399, i32 0
  %401 = insertelement <4 x float> %400, float 0.000000e+00, i32 1
  %402 = insertelement <4 x float> %401, float 0.000000e+00, i32 2
  %403 = insertelement <4 x float> %402, float 0.000000e+00, i32 3
  %404 = call <4 x float> @llvm.fma.f32.17(<4 x float> %397, <4 x float> %403, <4 x float> %391)
  %405 = extractelement <4 x float> %404, i32 0
  %406 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 1, i64 1
  store float %405, float* %406, align 4
  %407 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 1, i64 2
  %408 = load float, float* %407, align 4
  %409 = insertelement <4 x float> zeroinitializer, float %408, i32 0
  %410 = insertelement <4 x float> %409, float 0.000000e+00, i32 1
  %411 = insertelement <4 x float> %410, float 0.000000e+00, i32 2
  %412 = insertelement <4 x float> %411, float 0.000000e+00, i32 3
  %413 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 0, i64 1
  %414 = load float, float* %413, align 4
  %415 = insertelement <4 x float> zeroinitializer, float %414, i32 0
  %416 = insertelement <4 x float> %415, float 0.000000e+00, i32 1
  %417 = insertelement <4 x float> %416, float 0.000000e+00, i32 2
  %418 = insertelement <4 x float> %417, float 0.000000e+00, i32 3
  %419 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 1, i64 1
  %420 = load float, float* %419, align 4
  %421 = insertelement <4 x float> zeroinitializer, float %420, i32 0
  %422 = insertelement <4 x float> %421, float 0.000000e+00, i32 1
  %423 = insertelement <4 x float> %422, float 0.000000e+00, i32 2
  %424 = insertelement <4 x float> %423, float 0.000000e+00, i32 3
  %425 = call <4 x float> @llvm.fma.f32.18(<4 x float> %418, <4 x float> %424, <4 x float> %412)
  %426 = extractelement <4 x float> %425, i32 0
  %427 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 1, i64 2
  store float %426, float* %427, align 4
  %428 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 1, i64 2
  %429 = load float, float* %428, align 4
  %430 = insertelement <4 x float> zeroinitializer, float %429, i32 0
  %431 = insertelement <4 x float> %430, float 0.000000e+00, i32 1
  %432 = insertelement <4 x float> %431, float 0.000000e+00, i32 2
  %433 = insertelement <4 x float> %432, float 0.000000e+00, i32 3
  %434 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 0, i64 1
  %435 = load float, float* %434, align 4
  %436 = insertelement <4 x float> zeroinitializer, float %435, i32 0
  %437 = insertelement <4 x float> %436, float 1.000000e+00, i32 1
  %438 = insertelement <4 x float> %437, float 1.000000e+00, i32 2
  %439 = insertelement <4 x float> %438, float 1.000000e+00, i32 3
  %440 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 1, i64 1
  %441 = load float, float* %440, align 4
  %442 = insertelement <4 x float> zeroinitializer, float %441, i32 0
  %443 = insertelement <4 x float> %442, float 0.000000e+00, i32 1
  %444 = insertelement <4 x float> %443, float 0.000000e+00, i32 2
  %445 = insertelement <4 x float> %444, float 0.000000e+00, i32 3
  %446 = call <4 x float> @llvm.fma.f32.19(<4 x float> %439, <4 x float> %445, <4 x float> %433)
  %447 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 1, i64 1
  %448 = load float, float* %447, align 4
  %449 = insertelement <4 x float> zeroinitializer, float %448, i32 0
  %450 = insertelement <4 x float> %449, float 0.000000e+00, i32 1
  %451 = insertelement <4 x float> %450, float 0.000000e+00, i32 2
  %452 = insertelement <4 x float> %451, float 0.000000e+00, i32 3
  %453 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 0, i64 1
  %454 = load float, float* %453, align 4
  %455 = insertelement <4 x float> zeroinitializer, float %454, i32 0
  %456 = insertelement <4 x float> %455, float 0.000000e+00, i32 1
  %457 = insertelement <4 x float> %456, float 0.000000e+00, i32 2
  %458 = insertelement <4 x float> %457, float 0.000000e+00, i32 3
  %459 = call <4 x float> @llvm.fma.f32.20(<4 x float> %452, <4 x float> %458, <4 x float> %446)
  %460 = extractelement <4 x float> %459, i32 0
  %461 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 1, i64 2
  store float %460, float* %461, align 4
  %462 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 2, i64 0
  %463 = load float, float* %462, align 4
  %464 = insertelement <4 x float> zeroinitializer, float %463, i32 0
  %465 = insertelement <4 x float> %464, float 0.000000e+00, i32 1
  %466 = insertelement <4 x float> %465, float 0.000000e+00, i32 2
  %467 = insertelement <4 x float> %466, float 0.000000e+00, i32 3
  %468 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 1, i64 0
  %469 = load float, float* %468, align 4
  %470 = insertelement <4 x float> zeroinitializer, float %469, i32 0
  %471 = insertelement <4 x float> %470, float 0.000000e+00, i32 1
  %472 = insertelement <4 x float> %471, float 0.000000e+00, i32 2
  %473 = insertelement <4 x float> %472, float 0.000000e+00, i32 3
  %474 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 1, i64 0
  %475 = load float, float* %474, align 4
  %476 = insertelement <4 x float> zeroinitializer, float %475, i32 0
  %477 = insertelement <4 x float> %476, float 0.000000e+00, i32 1
  %478 = insertelement <4 x float> %477, float 0.000000e+00, i32 2
  %479 = insertelement <4 x float> %478, float 0.000000e+00, i32 3
  %480 = call <4 x float> @llvm.fma.f32.21(<4 x float> %473, <4 x float> %479, <4 x float> %467)
  %481 = extractelement <4 x float> %480, i32 0
  %482 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 2, i64 0
  store float %481, float* %482, align 4
  %483 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 2, i64 1
  %484 = load float, float* %483, align 4
  %485 = insertelement <4 x float> zeroinitializer, float %484, i32 0
  %486 = insertelement <4 x float> %485, float 0.000000e+00, i32 1
  %487 = insertelement <4 x float> %486, float 0.000000e+00, i32 2
  %488 = insertelement <4 x float> %487, float 0.000000e+00, i32 3
  %489 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 1, i64 0
  %490 = load float, float* %489, align 4
  %491 = insertelement <4 x float> zeroinitializer, float %490, i32 0
  %492 = insertelement <4 x float> %491, float 0.000000e+00, i32 1
  %493 = insertelement <4 x float> %492, float 0.000000e+00, i32 2
  %494 = insertelement <4 x float> %493, float 0.000000e+00, i32 3
  %495 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 1, i64 1
  %496 = load float, float* %495, align 4
  %497 = insertelement <4 x float> zeroinitializer, float %496, i32 0
  %498 = insertelement <4 x float> %497, float 0.000000e+00, i32 1
  %499 = insertelement <4 x float> %498, float 0.000000e+00, i32 2
  %500 = insertelement <4 x float> %499, float 0.000000e+00, i32 3
  %501 = call <4 x float> @llvm.fma.f32.22(<4 x float> %494, <4 x float> %500, <4 x float> %488)
  %502 = extractelement <4 x float> %501, i32 0
  %503 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 2, i64 1
  store float %502, float* %503, align 4
  %504 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 2, i64 1
  %505 = load float, float* %504, align 4
  %506 = insertelement <4 x float> zeroinitializer, float %505, i32 0
  %507 = insertelement <4 x float> %506, float 0.000000e+00, i32 1
  %508 = insertelement <4 x float> %507, float 0.000000e+00, i32 2
  %509 = insertelement <4 x float> %508, float 0.000000e+00, i32 3
  %510 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 1, i64 0
  %511 = load float, float* %510, align 4
  %512 = insertelement <4 x float> zeroinitializer, float %511, i32 0
  %513 = insertelement <4 x float> %512, float 1.000000e+00, i32 1
  %514 = insertelement <4 x float> %513, float 1.000000e+00, i32 2
  %515 = insertelement <4 x float> %514, float 1.000000e+00, i32 3
  %516 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 1, i64 1
  %517 = load float, float* %516, align 4
  %518 = insertelement <4 x float> zeroinitializer, float %517, i32 0
  %519 = insertelement <4 x float> %518, float 0.000000e+00, i32 1
  %520 = insertelement <4 x float> %519, float 0.000000e+00, i32 2
  %521 = insertelement <4 x float> %520, float 0.000000e+00, i32 3
  %522 = call <4 x float> @llvm.fma.f32.23(<4 x float> %515, <4 x float> %521, <4 x float> %509)
  %523 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 1, i64 1
  %524 = load float, float* %523, align 4
  %525 = insertelement <4 x float> zeroinitializer, float %524, i32 0
  %526 = insertelement <4 x float> %525, float 0.000000e+00, i32 1
  %527 = insertelement <4 x float> %526, float 0.000000e+00, i32 2
  %528 = insertelement <4 x float> %527, float 0.000000e+00, i32 3
  %529 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 1, i64 0
  %530 = load float, float* %529, align 4
  %531 = insertelement <4 x float> zeroinitializer, float %530, i32 0
  %532 = insertelement <4 x float> %531, float 0.000000e+00, i32 1
  %533 = insertelement <4 x float> %532, float 0.000000e+00, i32 2
  %534 = insertelement <4 x float> %533, float 0.000000e+00, i32 3
  %535 = call <4 x float> @llvm.fma.f32.24(<4 x float> %528, <4 x float> %534, <4 x float> %522)
  %536 = extractelement <4 x float> %535, i32 0
  %537 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 2, i64 1
  store float %536, float* %537, align 4
  %538 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 2, i64 2
  %539 = load float, float* %538, align 4
  %540 = insertelement <4 x float> zeroinitializer, float %539, i32 0
  %541 = insertelement <4 x float> %540, float 0.000000e+00, i32 1
  %542 = insertelement <4 x float> %541, float 0.000000e+00, i32 2
  %543 = insertelement <4 x float> %542, float 0.000000e+00, i32 3
  %544 = getelementptr inbounds [2 x float], [2 x float]* %0, i64 1, i64 1
  %545 = load float, float* %544, align 4
  %546 = insertelement <4 x float> zeroinitializer, float %545, i32 0
  %547 = insertelement <4 x float> %546, float 0.000000e+00, i32 1
  %548 = insertelement <4 x float> %547, float 0.000000e+00, i32 2
  %549 = insertelement <4 x float> %548, float 0.000000e+00, i32 3
  %550 = getelementptr inbounds [2 x float], [2 x float]* %1, i64 1, i64 1
  %551 = load float, float* %550, align 4
  %552 = insertelement <4 x float> zeroinitializer, float %551, i32 0
  %553 = insertelement <4 x float> %552, float 0.000000e+00, i32 1
  %554 = insertelement <4 x float> %553, float 0.000000e+00, i32 2
  %555 = insertelement <4 x float> %554, float 0.000000e+00, i32 3
  %556 = call <4 x float> @llvm.fma.f32.25(<4 x float> %549, <4 x float> %555, <4 x float> %543)
  %557 = extractelement <4 x float> %556, i32 0
  %558 = getelementptr inbounds [3 x float], [3 x float]* %2, i64 2, i64 2
  store float %557, float* %558, align 4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #0 {
.preheader:
  %0 = alloca [2 x [2 x float]], align 16
  %1 = alloca [2 x [2 x float]], align 16
  %2 = alloca [3 x [3 x float]], align 16
  %3 = bitcast [2 x [2 x float]]* %0 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 16 dereferenceable(16) %3, i8* nonnull align 16 dereferenceable(16) bitcast ([2 x [2 x float]]* @__const.main.mat_in to i8*), i64 16, i1 false)
  %4 = bitcast [2 x [2 x float]]* %1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 16 dereferenceable(16) %4, i8* nonnull align 16 dereferenceable(16) bitcast ([2 x [2 x float]]* @__const.main.f_in to i8*), i64 16, i1 false)
  %5 = bitcast [3 x [3 x float]]* %2 to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 dereferenceable(36) %5, i8 0, i64 36, i1 false)
  %6 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %0, i64 0, i64 0
  %7 = getelementptr inbounds [2 x [2 x float]], [2 x [2 x float]]* %1, i64 0, i64 0
  %8 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 0
  call void @convolution([2 x float]* nonnull %6, [2 x float]* nonnull %7, [3 x float]* nonnull %8)
  %9 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 0, i64 0
  %10 = load float, float* %9, align 16
  %11 = fpext float %10 to double
  %12 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %11) #5
  %13 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 0, i64 1
  %14 = load float, float* %13, align 4
  %15 = fpext float %14 to double
  %16 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %15) #5
  %17 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 0, i64 2
  %18 = load float, float* %17, align 8
  %19 = fpext float %18 to double
  %20 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %19) #5
  %21 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 1, i64 0
  %22 = load float, float* %21, align 4
  %23 = fpext float %22 to double
  %24 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %23) #5
  %25 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 1, i64 1
  %26 = load float, float* %25, align 4
  %27 = fpext float %26 to double
  %28 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %27) #5
  %29 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 1, i64 2
  %30 = load float, float* %29, align 4
  %31 = fpext float %30 to double
  %32 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %31) #5
  %33 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 2, i64 0
  %34 = load float, float* %33, align 8
  %35 = fpext float %34 to double
  %36 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %35) #5
  %37 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 2, i64 1
  %38 = load float, float* %37, align 4
  %39 = fpext float %38 to double
  %40 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %39) #5
  %41 = getelementptr inbounds [3 x [3 x float]], [3 x [3 x float]]* %2, i64 0, i64 2, i64 2
  %42 = load float, float* %41, align 8
  %43 = fpext float %42 to double
  %44 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %43) #5
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #1

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #2

declare i32 @printf(i8*, ...) #3

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32(<4 x float>, <4 x float>, <4 x float>) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.1(<4 x float>, <4 x float>, <4 x float>) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.2(<4 x float>, <4 x float>, <4 x float>) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.3(<4 x float>, <4 x float>, <4 x float>) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.4(<4 x float>, <4 x float>, <4 x float>) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.5(<4 x float>, <4 x float>, <4 x float>) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.6(<4 x float>, <4 x float>, <4 x float>) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.7(<4 x float>, <4 x float>, <4 x float>) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.8(<4 x float>, <4 x float>, <4 x float>) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.9(<4 x float>, <4 x float>, <4 x float>) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.10(<4 x float>, <4 x float>, <4 x float>) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.11(<4 x float>, <4 x float>, <4 x float>) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.12(<4 x float>, <4 x float>, <4 x float>) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.13(<4 x float>, <4 x float>, <4 x float>) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.14(<4 x float>, <4 x float>, <4 x float>) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.15(<4 x float>, <4 x float>, <4 x float>) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.16(<4 x float>, <4 x float>, <4 x float>) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.17(<4 x float>, <4 x float>, <4 x float>) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.18(<4 x float>, <4 x float>, <4 x float>) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.19(<4 x float>, <4 x float>, <4 x float>) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.20(<4 x float>, <4 x float>, <4 x float>) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.21(<4 x float>, <4 x float>, <4 x float>) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.22(<4 x float>, <4 x float>, <4 x float>) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.23(<4 x float>, <4 x float>, <4 x float>) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.24(<4 x float>, <4 x float>, <4 x float>) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.25(<4 x float>, <4 x float>, <4 x float>) #4

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { argmemonly nounwind willreturn writeonly }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind readnone speculatable willreturn }
attributes #5 = { nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
