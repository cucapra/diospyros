; ModuleID = 'opt.ll'
source_filename = "llvm-tests/sqrt.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.a_in = private unnamed_addr constant [8 x float] [float 9.000000e+00, float 8.000000e+00, float 7.000000e+00, float 6.000000e+00, float 5.000000e+00, float 4.000000e+00, float 3.000000e+00, float 2.000000e+00], align 16
@.str = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1

; Function Attrs: noinline nounwind ssp uwtable
define void @vsqrt(float* %0, float* %1, float* %2) #0 {
  %4 = load float, float* %0, align 4
  %5 = fpext float %4 to double
  %6 = call double @llvm.sqrt.f64(double %5)
  %7 = fptrunc double %6 to float
  %8 = load float, float* %0, align 4
  %9 = fpext float %8 to double
  %10 = call double @llvm.sqrt.f64(double %9)
  %11 = fptrunc double %10 to float
  %12 = getelementptr inbounds float, float* %0, i64 1
  %13 = load float, float* %12, align 4
  %14 = fpext float %13 to double
  %15 = call double @llvm.sqrt.f64(double %14)
  %16 = fptrunc double %15 to float
  %17 = getelementptr inbounds float, float* %1, i64 1
  %18 = getelementptr inbounds float, float* %0, i64 1
  %19 = load float, float* %18, align 4
  %20 = fpext float %19 to double
  %21 = call double @llvm.sqrt.f64(double %20)
  %22 = fptrunc double %21 to float
  %23 = getelementptr inbounds float, float* %2, i64 1
  %24 = getelementptr inbounds float, float* %0, i64 2
  %25 = load float, float* %24, align 4
  %26 = fpext float %25 to double
  %27 = call double @llvm.sqrt.f64(double %26)
  %28 = fptrunc double %27 to float
  %29 = getelementptr inbounds float, float* %1, i64 2
  %30 = getelementptr inbounds float, float* %0, i64 2
  %31 = load float, float* %30, align 4
  %32 = fpext float %31 to double
  %33 = call double @llvm.sqrt.f64(double %32)
  %34 = fptrunc double %33 to float
  %35 = getelementptr inbounds float, float* %2, i64 2
  %36 = getelementptr inbounds float, float* %0, i64 3
  %37 = load float, float* %36, align 4
  %38 = fpext float %37 to double
  %39 = call double @llvm.sqrt.f64(double %38)
  %40 = fptrunc double %39 to float
  %41 = getelementptr inbounds float, float* %1, i64 3
  %42 = getelementptr inbounds float, float* %0, i64 3
  %43 = load float, float* %42, align 4
  %44 = fpext float %43 to double
  %45 = call double @llvm.sqrt.f64(double %44)
  %46 = fptrunc double %45 to float
  %47 = getelementptr inbounds float, float* %2, i64 3
  %48 = getelementptr inbounds float, float* %0, i64 4
  %49 = load float, float* %48, align 4
  %50 = fpext float %49 to double
  %51 = call double @llvm.sqrt.f64(double %50)
  %52 = fptrunc double %51 to float
  %53 = getelementptr inbounds float, float* %1, i64 4
  %54 = getelementptr inbounds float, float* %0, i64 4
  %55 = load float, float* %54, align 4
  %56 = fpext float %55 to double
  %57 = call double @llvm.sqrt.f64(double %56)
  %58 = fptrunc double %57 to float
  %59 = getelementptr inbounds float, float* %2, i64 4
  %60 = getelementptr inbounds float, float* %0, i64 5
  %61 = load float, float* %60, align 4
  %62 = fpext float %61 to double
  %63 = call double @llvm.sqrt.f64(double %62)
  %64 = fptrunc double %63 to float
  %65 = getelementptr inbounds float, float* %1, i64 5
  %66 = getelementptr inbounds float, float* %0, i64 5
  %67 = load float, float* %66, align 4
  %68 = fpext float %67 to double
  %69 = call double @llvm.sqrt.f64(double %68)
  %70 = fptrunc double %69 to float
  %71 = getelementptr inbounds float, float* %2, i64 5
  %72 = getelementptr inbounds float, float* %0, i64 6
  %73 = load float, float* %72, align 4
  %74 = fpext float %73 to double
  %75 = call double @llvm.sqrt.f64(double %74)
  %76 = fptrunc double %75 to float
  %77 = getelementptr inbounds float, float* %1, i64 6
  %78 = getelementptr inbounds float, float* %0, i64 6
  %79 = load float, float* %78, align 4
  %80 = fpext float %79 to double
  %81 = call double @llvm.sqrt.f64(double %80)
  %82 = fptrunc double %81 to float
  %83 = getelementptr inbounds float, float* %2, i64 6
  %84 = getelementptr inbounds float, float* %0, i64 7
  %85 = load float, float* %84, align 4
  %86 = fpext float %85 to double
  %87 = call double @llvm.sqrt.f64(double %86)
  %88 = fptrunc double %87 to float
  %89 = getelementptr inbounds float, float* %1, i64 7
  %90 = getelementptr inbounds float, float* %0, i64 7
  %91 = load float, float* %90, align 4
  %92 = fpext float %91 to double
  %93 = call double @llvm.sqrt.f64(double %92)
  %94 = fptrunc double %93 to float
  %95 = getelementptr inbounds float, float* %2, i64 7
  %96 = load float, float* %0, align 4
  %97 = insertelement <4 x float> zeroinitializer, float %96, i32 0
  %98 = load float, float* %0, align 4
  %99 = insertelement <4 x float> %97, float %98, i32 1
  %100 = getelementptr inbounds float, float* %0, i64 1
  %101 = load float, float* %100, align 4
  %102 = insertelement <4 x float> %99, float %101, i32 2
  %103 = getelementptr inbounds float, float* %0, i64 1
  %104 = load float, float* %103, align 4
  %105 = insertelement <4 x float> %102, float %104, i32 3
  %106 = call <4 x float> @llvm.sqrt.f32(<4 x float> %105)
  %107 = getelementptr inbounds float, float* %0, i64 2
  %108 = load float, float* %107, align 4
  %109 = insertelement <4 x float> zeroinitializer, float %108, i32 0
  %110 = getelementptr inbounds float, float* %0, i64 2
  %111 = load float, float* %110, align 4
  %112 = insertelement <4 x float> %109, float %111, i32 1
  %113 = getelementptr inbounds float, float* %0, i64 3
  %114 = load float, float* %113, align 4
  %115 = insertelement <4 x float> %112, float %114, i32 2
  %116 = getelementptr inbounds float, float* %0, i64 3
  %117 = load float, float* %116, align 4
  %118 = insertelement <4 x float> %115, float %117, i32 3
  %119 = call <4 x float> @llvm.sqrt.f32.1(<4 x float> %118)
  %120 = shufflevector <4 x float> %106, <4 x float> %119, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %121 = getelementptr inbounds float, float* %0, i64 4
  %122 = load float, float* %121, align 4
  %123 = insertelement <4 x float> zeroinitializer, float %122, i32 0
  %124 = getelementptr inbounds float, float* %0, i64 4
  %125 = load float, float* %124, align 4
  %126 = insertelement <4 x float> %123, float %125, i32 1
  %127 = getelementptr inbounds float, float* %0, i64 5
  %128 = load float, float* %127, align 4
  %129 = insertelement <4 x float> %126, float %128, i32 2
  %130 = getelementptr inbounds float, float* %0, i64 5
  %131 = load float, float* %130, align 4
  %132 = insertelement <4 x float> %129, float %131, i32 3
  %133 = call <4 x float> @llvm.sqrt.f32.2(<4 x float> %132)
  %134 = getelementptr inbounds float, float* %0, i64 6
  %135 = load float, float* %134, align 4
  %136 = insertelement <4 x float> zeroinitializer, float %135, i32 0
  %137 = getelementptr inbounds float, float* %0, i64 6
  %138 = load float, float* %137, align 4
  %139 = insertelement <4 x float> %136, float %138, i32 1
  %140 = getelementptr inbounds float, float* %0, i64 7
  %141 = load float, float* %140, align 4
  %142 = insertelement <4 x float> %139, float %141, i32 2
  %143 = getelementptr inbounds float, float* %0, i64 7
  %144 = load float, float* %143, align 4
  %145 = insertelement <4 x float> %142, float %144, i32 3
  %146 = call <4 x float> @llvm.sqrt.f32.3(<4 x float> %145)
  %147 = shufflevector <4 x float> %133, <4 x float> %146, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %148 = shufflevector <8 x float> %120, <8 x float> %147, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %149 = extractelement <16 x float> %148, i32 0
  store float %149, float* %1, align 4
  %150 = extractelement <16 x float> %148, i32 1
  store float %150, float* %2, align 4
  %151 = extractelement <16 x float> %148, i32 2
  %152 = getelementptr inbounds float, float* %1, i64 1
  store float %151, float* %152, align 4
  %153 = extractelement <16 x float> %148, i32 3
  %154 = getelementptr inbounds float, float* %2, i64 1
  store float %153, float* %154, align 4
  %155 = extractelement <16 x float> %148, i32 4
  %156 = getelementptr inbounds float, float* %1, i64 2
  store float %155, float* %156, align 4
  %157 = extractelement <16 x float> %148, i32 5
  %158 = getelementptr inbounds float, float* %2, i64 2
  store float %157, float* %158, align 4
  %159 = extractelement <16 x float> %148, i32 6
  %160 = getelementptr inbounds float, float* %1, i64 3
  store float %159, float* %160, align 4
  %161 = extractelement <16 x float> %148, i32 7
  %162 = getelementptr inbounds float, float* %2, i64 3
  store float %161, float* %162, align 4
  %163 = extractelement <16 x float> %148, i32 8
  %164 = getelementptr inbounds float, float* %1, i64 4
  store float %163, float* %164, align 4
  %165 = extractelement <16 x float> %148, i32 9
  %166 = getelementptr inbounds float, float* %2, i64 4
  store float %165, float* %166, align 4
  %167 = extractelement <16 x float> %148, i32 10
  %168 = getelementptr inbounds float, float* %1, i64 5
  store float %167, float* %168, align 4
  %169 = extractelement <16 x float> %148, i32 11
  %170 = getelementptr inbounds float, float* %2, i64 5
  store float %169, float* %170, align 4
  %171 = extractelement <16 x float> %148, i32 12
  %172 = getelementptr inbounds float, float* %1, i64 6
  store float %171, float* %172, align 4
  %173 = extractelement <16 x float> %148, i32 13
  %174 = getelementptr inbounds float, float* %2, i64 6
  store float %173, float* %174, align 4
  %175 = extractelement <16 x float> %148, i32 14
  %176 = getelementptr inbounds float, float* %1, i64 7
  store float %175, float* %176, align 4
  %177 = extractelement <16 x float> %148, i32 15
  %178 = getelementptr inbounds float, float* %2, i64 7
  store float %177, float* %178, align 4
  ret void
}

; Function Attrs: nounwind readnone speculatable willreturn
declare double @llvm.sqrt.f64(double) #1

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #0 {
  %1 = alloca [8 x float], align 16
  %2 = alloca [8 x float], align 16
  %3 = alloca [8 x float], align 16
  %4 = bitcast [8 x float]* %1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %4, i8* align 16 bitcast ([8 x float]* @__const.main.a_in to i8*), i64 32, i1 false)
  %5 = bitcast [8 x float]* %2 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %5, i8 0, i64 32, i1 false)
  %6 = bitcast [8 x float]* %3 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %6, i8 0, i64 32, i1 false)
  %7 = getelementptr inbounds [8 x float], [8 x float]* %1, i64 0, i64 0
  %8 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 0
  %9 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 0
  call void @vsqrt(float* %7, float* %8, float* %9)
  %10 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 0
  %11 = load float, float* %10, align 4
  %12 = fpext float %11 to double
  %13 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %12)
  %14 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 0
  %15 = load float, float* %14, align 4
  %16 = fpext float %15 to double
  %17 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %16)
  %18 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 1
  %19 = load float, float* %18, align 4
  %20 = fpext float %19 to double
  %21 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %20)
  %22 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 1
  %23 = load float, float* %22, align 4
  %24 = fpext float %23 to double
  %25 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %24)
  %26 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 2
  %27 = load float, float* %26, align 4
  %28 = fpext float %27 to double
  %29 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %28)
  %30 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 2
  %31 = load float, float* %30, align 4
  %32 = fpext float %31 to double
  %33 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %32)
  %34 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 3
  %35 = load float, float* %34, align 4
  %36 = fpext float %35 to double
  %37 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %36)
  %38 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 3
  %39 = load float, float* %38, align 4
  %40 = fpext float %39 to double
  %41 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %40)
  %42 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 4
  %43 = load float, float* %42, align 4
  %44 = fpext float %43 to double
  %45 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %44)
  %46 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 4
  %47 = load float, float* %46, align 4
  %48 = fpext float %47 to double
  %49 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %48)
  %50 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 5
  %51 = load float, float* %50, align 4
  %52 = fpext float %51 to double
  %53 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %52)
  %54 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 5
  %55 = load float, float* %54, align 4
  %56 = fpext float %55 to double
  %57 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %56)
  %58 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 6
  %59 = load float, float* %58, align 4
  %60 = fpext float %59 to double
  %61 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %60)
  %62 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 6
  %63 = load float, float* %62, align 4
  %64 = fpext float %63 to double
  %65 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %64)
  %66 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 7
  %67 = load float, float* %66, align 4
  %68 = fpext float %67 to double
  %69 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %68)
  %70 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 7
  %71 = load float, float* %70, align 4
  %72 = fpext float %71 to double
  %73 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %72)
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #2

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #3

declare i32 @printf(i8*, ...) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.sqrt.f32(<4 x float>) #5

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.sqrt.f32.1(<4 x float>) #5

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.sqrt.f32.2(<4 x float>) #5

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.sqrt.f32.3(<4 x float>) #5

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable willreturn }
attributes #2 = { argmemonly nounwind willreturn }
attributes #3 = { argmemonly nounwind willreturn writeonly }
attributes #4 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { nounwind readnone speculatable willreturn }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
