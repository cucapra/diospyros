; ModuleID = 'clang.ll'
source_filename = "llvm-tests/continue-w.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.a_in = private unnamed_addr constant [8 x float] [float 9.000000e+00, float 8.000000e+00, float 7.000000e+00, float 6.000000e+00, float 5.000000e+00, float 4.000000e+00, float 3.000000e+00, float 2.000000e+00], align 16
@.str = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1

; Function Attrs: noinline nounwind ssp uwtable
define void @continue_w_test(float* %0, float %1, float* %2) #0 {
  br label %4

4:                                                ; preds = %3, %.backedge
  %.01 = phi i32 [ 0, %3 ], [ %.0.be, %.backedge ]
  %5 = icmp slt i32 %.01, 4
  br i1 %5, label %6, label %9

6:                                                ; preds = %4
  %7 = add nsw i32 %.01, 1
  br label %.backedge

.backedge:                                        ; preds = %6, %9
  %.0.be = phi i32 [ %7, %6 ], [ %16, %9 ]
  %8 = icmp slt i32 %.0.be, 8
  br i1 %8, label %4, label %17

9:                                                ; preds = %4
  %10 = sext i32 %.01 to i64
  %11 = getelementptr inbounds float, float* %0, i64 %10
  %12 = load float, float* %11, align 4
  %13 = fmul float %12, %1
  %14 = sext i32 %.01 to i64
  %15 = getelementptr inbounds float, float* %2, i64 %14
  store float %13, float* %15, align 4
  %16 = add nsw i32 %.01, 1
  br label %.backedge

17:                                               ; preds = %.backedge
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #0 {
  %1 = alloca [8 x float], align 16
  %2 = alloca [8 x float], align 16
  %3 = bitcast [8 x float]* %1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %3, i8* align 16 bitcast ([8 x float]* @__const.main.a_in to i8*), i64 32, i1 false)
  %4 = bitcast [8 x float]* %2 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %4, i8 0, i64 32, i1 false)
  %5 = getelementptr inbounds [8 x float], [8 x float]* %1, i64 0, i64 0
  %6 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 0
  call void @continue_w_test(float* %5, float 1.000000e+01, float* %6)
  %7 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 0
  %8 = load float, float* %7, align 4
  %9 = fpext float %8 to double
  %10 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %9)
  %11 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 1
  %12 = load float, float* %11, align 4
  %13 = fpext float %12 to double
  %14 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %13)
  %15 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 2
  %16 = load float, float* %15, align 4
  %17 = fpext float %16 to double
  %18 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %17)
  %19 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 3
  %20 = load float, float* %19, align 4
  %21 = fpext float %20 to double
  %22 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %21)
  %23 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 4
  %24 = load float, float* %23, align 4
  %25 = fpext float %24 to double
  %26 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %25)
  %27 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 5
  %28 = load float, float* %27, align 4
  %29 = fpext float %28 to double
  %30 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %29)
  %31 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 6
  %32 = load float, float* %31, align 4
  %33 = fpext float %32 to double
  %34 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %33)
  %35 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 7
  %36 = load float, float* %35, align 4
  %37 = fpext float %36 to double
  %38 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %37)
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

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
