; ModuleID = 'diospyros.ll'
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
  %3 = load float, float* %2, align 4
  %4 = insertelement <4 x float> zeroinitializer, float %3, i32 0
  %5 = insertelement <4 x float> %4, float 0.000000e+00, i32 1
  %6 = insertelement <4 x float> %5, float 0.000000e+00, i32 2
  %7 = insertelement <4 x float> %6, float 0.000000e+00, i32 3
  %8 = load float, float* %0, align 4
  %9 = insertelement <4 x float> zeroinitializer, float %8, i32 0
  %10 = insertelement <4 x float> %9, float 0.000000e+00, i32 1
  %11 = insertelement <4 x float> %10, float 0.000000e+00, i32 2
  %12 = insertelement <4 x float> %11, float 0.000000e+00, i32 3
  %13 = load float, float* %1, align 4
  %14 = insertelement <4 x float> zeroinitializer, float %13, i32 0
  %15 = insertelement <4 x float> %14, float 0.000000e+00, i32 1
  %16 = insertelement <4 x float> %15, float 0.000000e+00, i32 2
  %17 = insertelement <4 x float> %16, float 0.000000e+00, i32 3
  %18 = call <4 x float> @llvm.fma.v4f32(<4 x float> %12, <4 x float> %17, <4 x float> %7)
  %19 = extractelement <4 x float> %18, i32 0
  store float %19, float* %2, align 4
  %20 = getelementptr inbounds float, float* %2, i64 1
  %21 = load float, float* %20, align 4
  %22 = insertelement <4 x float> zeroinitializer, float %21, i32 0
  %23 = insertelement <4 x float> %22, float 0.000000e+00, i32 1
  %24 = insertelement <4 x float> %23, float 0.000000e+00, i32 2
  %25 = insertelement <4 x float> %24, float 0.000000e+00, i32 3
  %26 = load float, float* %0, align 4
  %27 = insertelement <4 x float> zeroinitializer, float %26, i32 0
  %28 = insertelement <4 x float> %27, float 0.000000e+00, i32 1
  %29 = insertelement <4 x float> %28, float 0.000000e+00, i32 2
  %30 = insertelement <4 x float> %29, float 0.000000e+00, i32 3
  %31 = getelementptr inbounds float, float* %1, i64 1
  %32 = load float, float* %31, align 4
  %33 = insertelement <4 x float> zeroinitializer, float %32, i32 0
  %34 = insertelement <4 x float> %33, float 0.000000e+00, i32 1
  %35 = insertelement <4 x float> %34, float 0.000000e+00, i32 2
  %36 = insertelement <4 x float> %35, float 0.000000e+00, i32 3
  %37 = call <4 x float> @llvm.fma.v4f32(<4 x float> %30, <4 x float> %36, <4 x float> %25)
  %38 = extractelement <4 x float> %37, i32 0
  %39 = getelementptr inbounds float, float* %2, i64 1
  store float %38, float* %39, align 4
  %40 = insertelement <4 x float> zeroinitializer, float %21, i32 0
  %41 = insertelement <4 x float> %40, float 0.000000e+00, i32 1
  %42 = insertelement <4 x float> %41, float 0.000000e+00, i32 2
  %43 = insertelement <4 x float> %42, float 0.000000e+00, i32 3
  %44 = load float, float* %0, align 4
  %45 = insertelement <4 x float> zeroinitializer, float %44, i32 0
  %46 = insertelement <4 x float> %45, float 1.000000e+00, i32 1
  %47 = insertelement <4 x float> %46, float 1.000000e+00, i32 2
  %48 = insertelement <4 x float> %47, float 1.000000e+00, i32 3
  %49 = insertelement <4 x float> zeroinitializer, float %32, i32 0
  %50 = insertelement <4 x float> %49, float 0.000000e+00, i32 1
  %51 = insertelement <4 x float> %50, float 0.000000e+00, i32 2
  %52 = insertelement <4 x float> %51, float 0.000000e+00, i32 3
  %53 = call <4 x float> @llvm.fma.v4f32(<4 x float> %48, <4 x float> %52, <4 x float> %43)
  %54 = getelementptr inbounds float, float* %0, i64 1
  %55 = load float, float* %54, align 4
  %56 = insertelement <4 x float> zeroinitializer, float %55, i32 0
  %57 = insertelement <4 x float> %56, float 0.000000e+00, i32 1
  %58 = insertelement <4 x float> %57, float 0.000000e+00, i32 2
  %59 = insertelement <4 x float> %58, float 0.000000e+00, i32 3
  %60 = load float, float* %1, align 4
  %61 = insertelement <4 x float> zeroinitializer, float %60, i32 0
  %62 = insertelement <4 x float> %61, float 0.000000e+00, i32 1
  %63 = insertelement <4 x float> %62, float 0.000000e+00, i32 2
  %64 = insertelement <4 x float> %63, float 0.000000e+00, i32 3
  %65 = call <4 x float> @llvm.fma.v4f32(<4 x float> %59, <4 x float> %64, <4 x float> %53)
  %66 = extractelement <4 x float> %65, i32 0
  %67 = getelementptr inbounds float, float* %2, i64 1
  store float %66, float* %67, align 4
  %68 = getelementptr inbounds float, float* %2, i64 2
  %69 = load float, float* %68, align 4
  %70 = insertelement <4 x float> zeroinitializer, float %69, i32 0
  %71 = insertelement <4 x float> %70, float 0.000000e+00, i32 1
  %72 = insertelement <4 x float> %71, float 0.000000e+00, i32 2
  %73 = insertelement <4 x float> %72, float 0.000000e+00, i32 3
  %74 = getelementptr inbounds float, float* %0, i64 1
  %75 = load float, float* %74, align 4
  %76 = insertelement <4 x float> zeroinitializer, float %75, i32 0
  %77 = insertelement <4 x float> %76, float 0.000000e+00, i32 1
  %78 = insertelement <4 x float> %77, float 0.000000e+00, i32 2
  %79 = insertelement <4 x float> %78, float 0.000000e+00, i32 3
  %80 = getelementptr inbounds float, float* %1, i64 1
  %81 = load float, float* %80, align 4
  %82 = insertelement <4 x float> zeroinitializer, float %81, i32 0
  %83 = insertelement <4 x float> %82, float 0.000000e+00, i32 1
  %84 = insertelement <4 x float> %83, float 0.000000e+00, i32 2
  %85 = insertelement <4 x float> %84, float 0.000000e+00, i32 3
  %86 = call <4 x float> @llvm.fma.v4f32(<4 x float> %79, <4 x float> %85, <4 x float> %73)
  %87 = extractelement <4 x float> %86, i32 0
  %88 = getelementptr inbounds float, float* %2, i64 2
  store float %87, float* %88, align 4
  %89 = getelementptr inbounds float, float* %2, i64 3
  %90 = load float, float* %89, align 4
  %91 = insertelement <4 x float> zeroinitializer, float %90, i32 1
  %92 = insertelement <4 x float> %91, float 0.000000e+00, i32 2
  %93 = insertelement <4 x float> %92, float 0.000000e+00, i32 3
  %94 = load float, float* %0, align 4
  %95 = insertelement <4 x float> <float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %94, i32 1
  %96 = insertelement <4 x float> %95, float 1.000000e+00, i32 2
  %97 = insertelement <4 x float> %96, float 1.000000e+00, i32 3
  %98 = getelementptr inbounds float, float* %2, i64 3
  %99 = load float, float* %98, align 4
  %100 = insertelement <4 x float> zeroinitializer, float %99, i32 0
  %101 = getelementptr inbounds float, float* %1, i64 2
  %102 = load float, float* %101, align 4
  %103 = insertelement <4 x float> %100, float %102, i32 1
  %104 = insertelement <4 x float> %103, float 0.000000e+00, i32 2
  %105 = insertelement <4 x float> %104, float 0.000000e+00, i32 3
  %106 = call <4 x float> @llvm.fma.v4f32(<4 x float> %97, <4 x float> %105, <4 x float> %93)
  %107 = load float, float* %0, align 4
  %108 = insertelement <4 x float> zeroinitializer, float %107, i32 0
  %109 = getelementptr inbounds float, float* %0, i64 2
  %110 = load float, float* %109, align 4
  %111 = insertelement <4 x float> %108, float %110, i32 1
  %112 = insertelement <4 x float> %111, float 0.000000e+00, i32 2
  %113 = insertelement <4 x float> %112, float 0.000000e+00, i32 3
  %114 = getelementptr inbounds float, float* %1, i64 2
  %115 = load float, float* %114, align 4
  %116 = insertelement <4 x float> zeroinitializer, float %115, i32 0
  %117 = load float, float* %1, align 4
  %118 = insertelement <4 x float> %116, float %117, i32 1
  %119 = insertelement <4 x float> %118, float 0.000000e+00, i32 2
  %120 = insertelement <4 x float> %119, float 0.000000e+00, i32 3
  %121 = call <4 x float> @llvm.fma.v4f32(<4 x float> %113, <4 x float> %120, <4 x float> %106)
  %122 = extractelement <4 x float> %121, i32 1
  %123 = getelementptr inbounds float, float* %2, i64 3
  store float %122, float* %123, align 4
  %124 = getelementptr inbounds float, float* %2, i64 4
  %125 = load float, float* %124, align 4
  %126 = insertelement <4 x float> zeroinitializer, float %125, i32 0
  %127 = insertelement <4 x float> %126, float 0.000000e+00, i32 1
  %128 = insertelement <4 x float> %127, float 0.000000e+00, i32 2
  %129 = insertelement <4 x float> %128, float 0.000000e+00, i32 3
  %130 = load float, float* %0, align 4
  %131 = insertelement <4 x float> zeroinitializer, float %130, i32 0
  %132 = insertelement <4 x float> %131, float 0.000000e+00, i32 1
  %133 = insertelement <4 x float> %132, float 0.000000e+00, i32 2
  %134 = insertelement <4 x float> %133, float 0.000000e+00, i32 3
  %135 = getelementptr inbounds float, float* %1, i64 3
  %136 = load float, float* %135, align 4
  %137 = insertelement <4 x float> zeroinitializer, float %136, i32 0
  %138 = insertelement <4 x float> %137, float 0.000000e+00, i32 1
  %139 = insertelement <4 x float> %138, float 0.000000e+00, i32 2
  %140 = insertelement <4 x float> %139, float 0.000000e+00, i32 3
  %141 = call <4 x float> @llvm.fma.v4f32(<4 x float> %134, <4 x float> %140, <4 x float> %129)
  %142 = extractelement <4 x float> %141, i32 0
  %143 = getelementptr inbounds float, float* %2, i64 4
  store float %142, float* %143, align 4
  %144 = insertelement <4 x float> zeroinitializer, float %125, i32 0
  %145 = insertelement <4 x float> %144, float 0.000000e+00, i32 1
  %146 = insertelement <4 x float> %145, float 0.000000e+00, i32 2
  %147 = insertelement <4 x float> %146, float 0.000000e+00, i32 3
  %148 = load float, float* %0, align 4
  %149 = insertelement <4 x float> zeroinitializer, float %148, i32 0
  %150 = insertelement <4 x float> %149, float 1.000000e+00, i32 1
  %151 = insertelement <4 x float> %150, float 1.000000e+00, i32 2
  %152 = insertelement <4 x float> %151, float 1.000000e+00, i32 3
  %153 = insertelement <4 x float> zeroinitializer, float %136, i32 0
  %154 = insertelement <4 x float> %153, float 0.000000e+00, i32 1
  %155 = insertelement <4 x float> %154, float 0.000000e+00, i32 2
  %156 = insertelement <4 x float> %155, float 0.000000e+00, i32 3
  %157 = call <4 x float> @llvm.fma.v4f32(<4 x float> %152, <4 x float> %156, <4 x float> %147)
  %158 = getelementptr inbounds float, float* %0, i64 1
  %159 = load float, float* %158, align 4
  %160 = insertelement <4 x float> zeroinitializer, float %159, i32 0
  %161 = insertelement <4 x float> %160, float 0.000000e+00, i32 1
  %162 = insertelement <4 x float> %161, float 0.000000e+00, i32 2
  %163 = insertelement <4 x float> %162, float 0.000000e+00, i32 3
  %164 = getelementptr inbounds float, float* %1, i64 2
  %165 = load float, float* %164, align 4
  %166 = insertelement <4 x float> zeroinitializer, float %165, i32 0
  %167 = insertelement <4 x float> %166, float 0.000000e+00, i32 1
  %168 = insertelement <4 x float> %167, float 0.000000e+00, i32 2
  %169 = insertelement <4 x float> %168, float 0.000000e+00, i32 3
  %170 = call <4 x float> @llvm.fma.v4f32(<4 x float> %163, <4 x float> %169, <4 x float> %157)
  %171 = extractelement <4 x float> %170, i32 0
  %172 = getelementptr inbounds float, float* %2, i64 4
  store float %171, float* %172, align 4
  %173 = insertelement <4 x float> zeroinitializer, float %125, i32 0
  %174 = insertelement <4 x float> %173, float 0.000000e+00, i32 1
  %175 = insertelement <4 x float> %174, float 0.000000e+00, i32 2
  %176 = insertelement <4 x float> %175, float 0.000000e+00, i32 3
  %177 = load float, float* %0, align 4
  %178 = insertelement <4 x float> zeroinitializer, float %177, i32 0
  %179 = insertelement <4 x float> %178, float 1.000000e+00, i32 1
  %180 = insertelement <4 x float> %179, float 1.000000e+00, i32 2
  %181 = insertelement <4 x float> %180, float 1.000000e+00, i32 3
  %182 = insertelement <4 x float> zeroinitializer, float %136, i32 0
  %183 = insertelement <4 x float> %182, float 0.000000e+00, i32 1
  %184 = insertelement <4 x float> %183, float 0.000000e+00, i32 2
  %185 = insertelement <4 x float> %184, float 0.000000e+00, i32 3
  %186 = call <4 x float> @llvm.fma.v4f32(<4 x float> %181, <4 x float> %185, <4 x float> %176)
  %187 = insertelement <4 x float> zeroinitializer, float %159, i32 0
  %188 = insertelement <4 x float> %187, float 1.000000e+00, i32 1
  %189 = insertelement <4 x float> %188, float 1.000000e+00, i32 2
  %190 = insertelement <4 x float> %189, float 1.000000e+00, i32 3
  %191 = insertelement <4 x float> zeroinitializer, float %165, i32 0
  %192 = insertelement <4 x float> %191, float 0.000000e+00, i32 1
  %193 = insertelement <4 x float> %192, float 0.000000e+00, i32 2
  %194 = insertelement <4 x float> %193, float 0.000000e+00, i32 3
  %195 = call <4 x float> @llvm.fma.v4f32(<4 x float> %190, <4 x float> %194, <4 x float> %186)
  %196 = getelementptr inbounds float, float* %0, i64 2
  %197 = load float, float* %196, align 4
  %198 = insertelement <4 x float> zeroinitializer, float %197, i32 0
  %199 = insertelement <4 x float> %198, float 0.000000e+00, i32 1
  %200 = insertelement <4 x float> %199, float 0.000000e+00, i32 2
  %201 = insertelement <4 x float> %200, float 0.000000e+00, i32 3
  %202 = getelementptr inbounds float, float* %1, i64 1
  %203 = load float, float* %202, align 4
  %204 = insertelement <4 x float> zeroinitializer, float %203, i32 0
  %205 = insertelement <4 x float> %204, float 0.000000e+00, i32 1
  %206 = insertelement <4 x float> %205, float 0.000000e+00, i32 2
  %207 = insertelement <4 x float> %206, float 0.000000e+00, i32 3
  %208 = call <4 x float> @llvm.fma.v4f32(<4 x float> %201, <4 x float> %207, <4 x float> %195)
  %209 = extractelement <4 x float> %208, i32 0
  %210 = getelementptr inbounds float, float* %2, i64 4
  store float %209, float* %210, align 4
  %211 = insertelement <4 x float> zeroinitializer, float %125, i32 0
  %212 = insertelement <4 x float> %211, float 0.000000e+00, i32 1
  %213 = insertelement <4 x float> %212, float 0.000000e+00, i32 2
  %214 = insertelement <4 x float> %213, float 0.000000e+00, i32 3
  %215 = load float, float* %0, align 4
  %216 = insertelement <4 x float> zeroinitializer, float %215, i32 0
  %217 = insertelement <4 x float> %216, float 1.000000e+00, i32 1
  %218 = insertelement <4 x float> %217, float 1.000000e+00, i32 2
  %219 = insertelement <4 x float> %218, float 1.000000e+00, i32 3
  %220 = insertelement <4 x float> zeroinitializer, float %136, i32 0
  %221 = insertelement <4 x float> %220, float 0.000000e+00, i32 1
  %222 = insertelement <4 x float> %221, float 0.000000e+00, i32 2
  %223 = insertelement <4 x float> %222, float 0.000000e+00, i32 3
  %224 = call <4 x float> @llvm.fma.v4f32(<4 x float> %219, <4 x float> %223, <4 x float> %214)
  %225 = insertelement <4 x float> zeroinitializer, float %159, i32 0
  %226 = insertelement <4 x float> %225, float 1.000000e+00, i32 1
  %227 = insertelement <4 x float> %226, float 1.000000e+00, i32 2
  %228 = insertelement <4 x float> %227, float 1.000000e+00, i32 3
  %229 = insertelement <4 x float> zeroinitializer, float %165, i32 0
  %230 = insertelement <4 x float> %229, float 0.000000e+00, i32 1
  %231 = insertelement <4 x float> %230, float 0.000000e+00, i32 2
  %232 = insertelement <4 x float> %231, float 0.000000e+00, i32 3
  %233 = call <4 x float> @llvm.fma.v4f32(<4 x float> %228, <4 x float> %232, <4 x float> %224)
  %234 = insertelement <4 x float> zeroinitializer, float %197, i32 0
  %235 = insertelement <4 x float> %234, float 1.000000e+00, i32 1
  %236 = insertelement <4 x float> %235, float 1.000000e+00, i32 2
  %237 = insertelement <4 x float> %236, float 1.000000e+00, i32 3
  %238 = insertelement <4 x float> zeroinitializer, float %203, i32 0
  %239 = insertelement <4 x float> %238, float 0.000000e+00, i32 1
  %240 = insertelement <4 x float> %239, float 0.000000e+00, i32 2
  %241 = insertelement <4 x float> %240, float 0.000000e+00, i32 3
  %242 = call <4 x float> @llvm.fma.v4f32(<4 x float> %237, <4 x float> %241, <4 x float> %233)
  %243 = getelementptr inbounds float, float* %0, i64 3
  %244 = load float, float* %243, align 4
  %245 = insertelement <4 x float> zeroinitializer, float %244, i32 0
  %246 = insertelement <4 x float> %245, float 0.000000e+00, i32 1
  %247 = insertelement <4 x float> %246, float 0.000000e+00, i32 2
  %248 = insertelement <4 x float> %247, float 0.000000e+00, i32 3
  %249 = load float, float* %1, align 4
  %250 = insertelement <4 x float> zeroinitializer, float %249, i32 0
  %251 = insertelement <4 x float> %250, float 0.000000e+00, i32 1
  %252 = insertelement <4 x float> %251, float 0.000000e+00, i32 2
  %253 = insertelement <4 x float> %252, float 0.000000e+00, i32 3
  %254 = call <4 x float> @llvm.fma.v4f32(<4 x float> %248, <4 x float> %253, <4 x float> %242)
  %255 = extractelement <4 x float> %254, i32 0
  %256 = getelementptr inbounds float, float* %2, i64 4
  store float %255, float* %256, align 4
  %257 = getelementptr inbounds float, float* %2, i64 5
  %258 = load float, float* %257, align 4
  %259 = insertelement <4 x float> zeroinitializer, float %258, i32 0
  %260 = insertelement <4 x float> %259, float 0.000000e+00, i32 1
  %261 = insertelement <4 x float> %260, float 0.000000e+00, i32 2
  %262 = insertelement <4 x float> %261, float 0.000000e+00, i32 3
  %263 = getelementptr inbounds float, float* %0, i64 1
  %264 = load float, float* %263, align 4
  %265 = insertelement <4 x float> zeroinitializer, float %264, i32 0
  %266 = insertelement <4 x float> %265, float 0.000000e+00, i32 1
  %267 = insertelement <4 x float> %266, float 0.000000e+00, i32 2
  %268 = insertelement <4 x float> %267, float 0.000000e+00, i32 3
  %269 = getelementptr inbounds float, float* %1, i64 3
  %270 = load float, float* %269, align 4
  %271 = insertelement <4 x float> zeroinitializer, float %270, i32 0
  %272 = insertelement <4 x float> %271, float 0.000000e+00, i32 1
  %273 = insertelement <4 x float> %272, float 0.000000e+00, i32 2
  %274 = insertelement <4 x float> %273, float 0.000000e+00, i32 3
  %275 = call <4 x float> @llvm.fma.v4f32(<4 x float> %268, <4 x float> %274, <4 x float> %262)
  %276 = extractelement <4 x float> %275, i32 0
  %277 = getelementptr inbounds float, float* %2, i64 5
  store float %276, float* %277, align 4
  %278 = insertelement <4 x float> zeroinitializer, float %258, i32 0
  %279 = insertelement <4 x float> %278, float 0.000000e+00, i32 1
  %280 = insertelement <4 x float> %279, float 0.000000e+00, i32 2
  %281 = insertelement <4 x float> %280, float 0.000000e+00, i32 3
  %282 = insertelement <4 x float> zeroinitializer, float %264, i32 0
  %283 = insertelement <4 x float> %282, float 1.000000e+00, i32 1
  %284 = insertelement <4 x float> %283, float 1.000000e+00, i32 2
  %285 = insertelement <4 x float> %284, float 1.000000e+00, i32 3
  %286 = insertelement <4 x float> zeroinitializer, float %270, i32 0
  %287 = insertelement <4 x float> %286, float 0.000000e+00, i32 1
  %288 = insertelement <4 x float> %287, float 0.000000e+00, i32 2
  %289 = insertelement <4 x float> %288, float 0.000000e+00, i32 3
  %290 = call <4 x float> @llvm.fma.v4f32(<4 x float> %285, <4 x float> %289, <4 x float> %281)
  %291 = getelementptr inbounds float, float* %0, i64 3
  %292 = load float, float* %291, align 4
  %293 = insertelement <4 x float> zeroinitializer, float %292, i32 0
  %294 = insertelement <4 x float> %293, float 0.000000e+00, i32 1
  %295 = insertelement <4 x float> %294, float 0.000000e+00, i32 2
  %296 = insertelement <4 x float> %295, float 0.000000e+00, i32 3
  %297 = getelementptr inbounds float, float* %1, i64 1
  %298 = load float, float* %297, align 4
  %299 = insertelement <4 x float> zeroinitializer, float %298, i32 0
  %300 = insertelement <4 x float> %299, float 0.000000e+00, i32 1
  %301 = insertelement <4 x float> %300, float 0.000000e+00, i32 2
  %302 = insertelement <4 x float> %301, float 0.000000e+00, i32 3
  %303 = call <4 x float> @llvm.fma.v4f32(<4 x float> %296, <4 x float> %302, <4 x float> %290)
  %304 = extractelement <4 x float> %303, i32 0
  %305 = getelementptr inbounds float, float* %2, i64 5
  store float %304, float* %305, align 4
  %306 = getelementptr inbounds float, float* %2, i64 6
  %307 = load float, float* %306, align 4
  %308 = insertelement <4 x float> zeroinitializer, float %307, i32 0
  %309 = insertelement <4 x float> %308, float 0.000000e+00, i32 1
  %310 = insertelement <4 x float> %309, float 0.000000e+00, i32 2
  %311 = insertelement <4 x float> %310, float 0.000000e+00, i32 3
  %312 = getelementptr inbounds float, float* %0, i64 2
  %313 = load float, float* %312, align 4
  %314 = insertelement <4 x float> zeroinitializer, float %313, i32 0
  %315 = insertelement <4 x float> %314, float 0.000000e+00, i32 1
  %316 = insertelement <4 x float> %315, float 0.000000e+00, i32 2
  %317 = insertelement <4 x float> %316, float 0.000000e+00, i32 3
  %318 = getelementptr inbounds float, float* %1, i64 2
  %319 = load float, float* %318, align 4
  %320 = insertelement <4 x float> zeroinitializer, float %319, i32 0
  %321 = insertelement <4 x float> %320, float 0.000000e+00, i32 1
  %322 = insertelement <4 x float> %321, float 0.000000e+00, i32 2
  %323 = insertelement <4 x float> %322, float 0.000000e+00, i32 3
  %324 = call <4 x float> @llvm.fma.v4f32(<4 x float> %317, <4 x float> %323, <4 x float> %311)
  %325 = extractelement <4 x float> %324, i32 0
  %326 = getelementptr inbounds float, float* %2, i64 6
  store float %325, float* %326, align 4
  %327 = getelementptr inbounds float, float* %2, i64 7
  %328 = load float, float* %327, align 4
  %329 = insertelement <4 x float> zeroinitializer, float %328, i32 0
  %330 = insertelement <4 x float> %329, float 0.000000e+00, i32 1
  %331 = insertelement <4 x float> %330, float 0.000000e+00, i32 2
  %332 = insertelement <4 x float> %331, float 0.000000e+00, i32 3
  %333 = getelementptr inbounds float, float* %0, i64 2
  %334 = load float, float* %333, align 4
  %335 = insertelement <4 x float> zeroinitializer, float %334, i32 0
  %336 = insertelement <4 x float> %335, float 0.000000e+00, i32 1
  %337 = insertelement <4 x float> %336, float 0.000000e+00, i32 2
  %338 = insertelement <4 x float> %337, float 0.000000e+00, i32 3
  %339 = getelementptr inbounds float, float* %1, i64 3
  %340 = load float, float* %339, align 4
  %341 = insertelement <4 x float> zeroinitializer, float %340, i32 0
  %342 = insertelement <4 x float> %341, float 0.000000e+00, i32 1
  %343 = insertelement <4 x float> %342, float 0.000000e+00, i32 2
  %344 = insertelement <4 x float> %343, float 0.000000e+00, i32 3
  %345 = call <4 x float> @llvm.fma.v4f32(<4 x float> %338, <4 x float> %344, <4 x float> %332)
  %346 = extractelement <4 x float> %345, i32 0
  %347 = getelementptr inbounds float, float* %2, i64 7
  store float %346, float* %347, align 4
  %348 = insertelement <4 x float> zeroinitializer, float %328, i32 0
  %349 = insertelement <4 x float> %348, float 0.000000e+00, i32 1
  %350 = insertelement <4 x float> %349, float 0.000000e+00, i32 2
  %351 = insertelement <4 x float> %350, float 0.000000e+00, i32 3
  %352 = insertelement <4 x float> zeroinitializer, float %334, i32 0
  %353 = insertelement <4 x float> %352, float 1.000000e+00, i32 1
  %354 = insertelement <4 x float> %353, float 1.000000e+00, i32 2
  %355 = insertelement <4 x float> %354, float 1.000000e+00, i32 3
  %356 = insertelement <4 x float> zeroinitializer, float %340, i32 0
  %357 = insertelement <4 x float> %356, float 0.000000e+00, i32 1
  %358 = insertelement <4 x float> %357, float 0.000000e+00, i32 2
  %359 = insertelement <4 x float> %358, float 0.000000e+00, i32 3
  %360 = call <4 x float> @llvm.fma.v4f32(<4 x float> %355, <4 x float> %359, <4 x float> %351)
  %361 = getelementptr inbounds float, float* %0, i64 3
  %362 = load float, float* %361, align 4
  %363 = insertelement <4 x float> zeroinitializer, float %362, i32 0
  %364 = insertelement <4 x float> %363, float 0.000000e+00, i32 1
  %365 = insertelement <4 x float> %364, float 0.000000e+00, i32 2
  %366 = insertelement <4 x float> %365, float 0.000000e+00, i32 3
  %367 = getelementptr inbounds float, float* %1, i64 2
  %368 = load float, float* %367, align 4
  %369 = insertelement <4 x float> zeroinitializer, float %368, i32 0
  %370 = insertelement <4 x float> %369, float 0.000000e+00, i32 1
  %371 = insertelement <4 x float> %370, float 0.000000e+00, i32 2
  %372 = insertelement <4 x float> %371, float 0.000000e+00, i32 3
  %373 = call <4 x float> @llvm.fma.v4f32(<4 x float> %366, <4 x float> %372, <4 x float> %360)
  %374 = extractelement <4 x float> %373, i32 0
  %375 = getelementptr inbounds float, float* %2, i64 7
  store float %374, float* %375, align 4
  %376 = getelementptr inbounds float, float* %2, i64 8
  %377 = load float, float* %376, align 4
  %378 = insertelement <4 x float> zeroinitializer, float %377, i32 0
  %379 = insertelement <4 x float> %378, float 0.000000e+00, i32 1
  %380 = insertelement <4 x float> %379, float 0.000000e+00, i32 2
  %381 = insertelement <4 x float> %380, float 0.000000e+00, i32 3
  %382 = getelementptr inbounds float, float* %0, i64 3
  %383 = load float, float* %382, align 4
  %384 = insertelement <4 x float> zeroinitializer, float %383, i32 0
  %385 = insertelement <4 x float> %384, float 0.000000e+00, i32 1
  %386 = insertelement <4 x float> %385, float 0.000000e+00, i32 2
  %387 = insertelement <4 x float> %386, float 0.000000e+00, i32 3
  %388 = getelementptr inbounds float, float* %1, i64 3
  %389 = load float, float* %388, align 4
  %390 = insertelement <4 x float> zeroinitializer, float %389, i32 0
  %391 = insertelement <4 x float> %390, float 0.000000e+00, i32 1
  %392 = insertelement <4 x float> %391, float 0.000000e+00, i32 2
  %393 = insertelement <4 x float> %392, float 0.000000e+00, i32 3
  %394 = call <4 x float> @llvm.fma.v4f32(<4 x float> %387, <4 x float> %393, <4 x float> %381)
  %395 = extractelement <4 x float> %394, i32 0
  %396 = getelementptr inbounds float, float* %2, i64 8
  store float %395, float* %396, align 4
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
declare <4 x float> @llvm.fma.v4f32(<4 x float>, <4 x float>, <4 x float>) #5

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
