; ModuleID = 'llvm-tests/point-product.c'
source_filename = "llvm-tests/point-product.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.q_in = private unnamed_addr constant [4 x float] [float 0.000000e+00, float 1.000000e+00, float 2.000000e+00, float 3.000000e+00], align 16
@__const.main.p_in = private unnamed_addr constant [4 x float] [float 0.000000e+00, float 1.000000e+00, float 2.000000e+00, float 3.000000e+00], align 16
@.str = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1

; Function Attrs: alwaysinline nounwind ssp uwtable
define void @cross_product(float* %0, float* %1, float* %2) #0 {
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

; Function Attrs: noinline nounwind ssp uwtable
define void @point_product(float* %0, float* %1, float* %2) #1 {
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
define i32 @main() #1 {
  %1 = alloca i32, align 4
  %2 = alloca [4 x float], align 16
  %3 = alloca [4 x float], align 16
  %4 = alloca [4 x float], align 16
  %5 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  %6 = bitcast [4 x float]* %2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %6, i8* align 16 bitcast ([4 x float]* @__const.main.q_in to i8*), i64 16, i1 false)
  %7 = bitcast [4 x float]* %3 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %7, i8* align 16 bitcast ([4 x float]* @__const.main.p_in to i8*), i64 16, i1 false)
  %8 = bitcast [4 x float]* %4 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %8, i8 0, i64 16, i1 false)
  %9 = getelementptr inbounds [4 x float], [4 x float]* %2, i64 0, i64 0
  %10 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 0
  %11 = getelementptr inbounds [4 x float], [4 x float]* %4, i64 0, i64 0
  call void @point_product(float* %9, float* %10, float* %11)
  store i32 0, i32* %5, align 4
  br label %12

12:                                               ; preds = %22, %0
  %13 = load i32, i32* %5, align 4
  %14 = icmp slt i32 %13, 3
  br i1 %14, label %15, label %25

15:                                               ; preds = %12
  %16 = load i32, i32* %5, align 4
  %17 = sext i32 %16 to i64
  %18 = getelementptr inbounds [4 x float], [4 x float]* %4, i64 0, i64 %17
  %19 = load float, float* %18, align 4
  %20 = fpext float %19 to double
  %21 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %20)
  br label %22

22:                                               ; preds = %15
  %23 = load i32, i32* %5, align 4
  %24 = add nsw i32 %23, 1
  store i32 %24, i32* %5, align 4
  br label %12

25:                                               ; preds = %12
  %26 = load i32, i32* %1, align 4
  ret i32 %26
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
