; ModuleID = 'llvm-tests/cube-new.c'
source_filename = "llvm-tests/cube-new.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.a_in = private unnamed_addr constant [8 x float] [float 9.000000e+00, float 8.000000e+00, float 7.000000e+00, float 6.000000e+00, float 5.000000e+00, float 4.000000e+00, float 3.000000e+00, float 2.000000e+00], align 16
@.str = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1
@__func__.main = private unnamed_addr constant [5 x i8] c"main\00", align 1
@.str.1 = private unnamed_addr constant [22 x i8] c"llvm-tests/cube-new.c\00", align 1
@.str.2 = private unnamed_addr constant [16 x i8] c"b_out[0] == 729\00", align 1
@.str.3 = private unnamed_addr constant [16 x i8] c"b_out[1] == 512\00", align 1
@.str.4 = private unnamed_addr constant [16 x i8] c"b_out[2] == 343\00", align 1
@.str.5 = private unnamed_addr constant [16 x i8] c"b_out[3] == 216\00", align 1
@.str.6 = private unnamed_addr constant [16 x i8] c"b_out[4] == 125\00", align 1
@.str.7 = private unnamed_addr constant [15 x i8] c"b_out[5] == 64\00", align 1
@.str.8 = private unnamed_addr constant [15 x i8] c"b_out[6] == 27\00", align 1
@.str.9 = private unnamed_addr constant [14 x i8] c"b_out[7] == 8\00", align 1

; Function Attrs: noinline nounwind ssp uwtable
define void @cube(float* %0, float* %1) #0 {
  %3 = alloca float*, align 8
  %4 = alloca float*, align 8
  %5 = alloca i32, align 4
  store float* %0, float** %3, align 8
  store float* %1, float** %4, align 8
  store i32 0, i32* %5, align 4
  br label %6

6:                                                ; preds = %20, %2
  %7 = load i32, i32* %5, align 4
  %8 = icmp slt i32 %7, 8
  br i1 %8, label %9, label %23

9:                                                ; preds = %6
  %10 = load float*, float** %3, align 8
  %11 = load i32, i32* %5, align 4
  %12 = sext i32 %11 to i64
  %13 = getelementptr inbounds float, float* %10, i64 %12
  %14 = load float, float* %13, align 4
  %15 = call float @llvm.pow.f32(float %14, float 3.000000e+00)
  %16 = load float*, float** %4, align 8
  %17 = load i32, i32* %5, align 4
  %18 = sext i32 %17 to i64
  %19 = getelementptr inbounds float, float* %16, i64 %18
  store float %15, float* %19, align 4
  br label %20

20:                                               ; preds = %9
  %21 = load i32, i32* %5, align 4
  %22 = add nsw i32 %21, 1
  store i32 %22, i32* %5, align 4
  br label %6

23:                                               ; preds = %6
  ret void
}

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.pow.f32(float, float) #1

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca [8 x float], align 16
  %3 = alloca [8 x float], align 16
  %4 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  %5 = bitcast [8 x float]* %2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %5, i8* align 16 bitcast ([8 x float]* @__const.main.a_in to i8*), i64 32, i1 false)
  %6 = bitcast [8 x float]* %3 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %6, i8 0, i64 32, i1 false)
  %7 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 0
  %8 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 0
  call void @cube(float* %7, float* %8)
  store i32 0, i32* %4, align 4
  br label %9

9:                                                ; preds = %19, %0
  %10 = load i32, i32* %4, align 4
  %11 = icmp slt i32 %10, 8
  br i1 %11, label %12, label %22

12:                                               ; preds = %9
  %13 = load i32, i32* %4, align 4
  %14 = sext i32 %13 to i64
  %15 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 %14
  %16 = load float, float* %15, align 4
  %17 = fpext float %16 to double
  %18 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %17)
  br label %19

19:                                               ; preds = %12
  %20 = load i32, i32* %4, align 4
  %21 = add nsw i32 %20, 1
  store i32 %21, i32* %4, align 4
  br label %9

22:                                               ; preds = %9
  %23 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 0
  %24 = load float, float* %23, align 16
  %25 = fcmp oeq float %24, 7.290000e+02
  %26 = xor i1 %25, true
  %27 = zext i1 %26 to i32
  %28 = sext i32 %27 to i64
  %29 = icmp ne i64 %28, 0
  br i1 %29, label %30, label %32

30:                                               ; preds = %22
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.1, i64 0, i64 0), i32 18, i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.2, i64 0, i64 0)) #6
  unreachable

31:                                               ; No predecessors!
  br label %33

32:                                               ; preds = %22
  br label %33

33:                                               ; preds = %32, %31
  %34 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 1
  %35 = load float, float* %34, align 4
  %36 = fcmp oeq float %35, 5.120000e+02
  %37 = xor i1 %36, true
  %38 = zext i1 %37 to i32
  %39 = sext i32 %38 to i64
  %40 = icmp ne i64 %39, 0
  br i1 %40, label %41, label %43

41:                                               ; preds = %33
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.1, i64 0, i64 0), i32 19, i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.3, i64 0, i64 0)) #6
  unreachable

42:                                               ; No predecessors!
  br label %44

43:                                               ; preds = %33
  br label %44

44:                                               ; preds = %43, %42
  %45 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 2
  %46 = load float, float* %45, align 8
  %47 = fcmp oeq float %46, 3.430000e+02
  %48 = xor i1 %47, true
  %49 = zext i1 %48 to i32
  %50 = sext i32 %49 to i64
  %51 = icmp ne i64 %50, 0
  br i1 %51, label %52, label %54

52:                                               ; preds = %44
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.1, i64 0, i64 0), i32 20, i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.4, i64 0, i64 0)) #6
  unreachable

53:                                               ; No predecessors!
  br label %55

54:                                               ; preds = %44
  br label %55

55:                                               ; preds = %54, %53
  %56 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 3
  %57 = load float, float* %56, align 4
  %58 = fcmp oeq float %57, 2.160000e+02
  %59 = xor i1 %58, true
  %60 = zext i1 %59 to i32
  %61 = sext i32 %60 to i64
  %62 = icmp ne i64 %61, 0
  br i1 %62, label %63, label %65

63:                                               ; preds = %55
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.1, i64 0, i64 0), i32 21, i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.5, i64 0, i64 0)) #6
  unreachable

64:                                               ; No predecessors!
  br label %66

65:                                               ; preds = %55
  br label %66

66:                                               ; preds = %65, %64
  %67 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 4
  %68 = load float, float* %67, align 16
  %69 = fcmp oeq float %68, 1.250000e+02
  %70 = xor i1 %69, true
  %71 = zext i1 %70 to i32
  %72 = sext i32 %71 to i64
  %73 = icmp ne i64 %72, 0
  br i1 %73, label %74, label %76

74:                                               ; preds = %66
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.1, i64 0, i64 0), i32 22, i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.6, i64 0, i64 0)) #6
  unreachable

75:                                               ; No predecessors!
  br label %77

76:                                               ; preds = %66
  br label %77

77:                                               ; preds = %76, %75
  %78 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 5
  %79 = load float, float* %78, align 4
  %80 = fcmp oeq float %79, 6.400000e+01
  %81 = xor i1 %80, true
  %82 = zext i1 %81 to i32
  %83 = sext i32 %82 to i64
  %84 = icmp ne i64 %83, 0
  br i1 %84, label %85, label %87

85:                                               ; preds = %77
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.1, i64 0, i64 0), i32 23, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.7, i64 0, i64 0)) #6
  unreachable

86:                                               ; No predecessors!
  br label %88

87:                                               ; preds = %77
  br label %88

88:                                               ; preds = %87, %86
  %89 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 6
  %90 = load float, float* %89, align 8
  %91 = fcmp oeq float %90, 2.700000e+01
  %92 = xor i1 %91, true
  %93 = zext i1 %92 to i32
  %94 = sext i32 %93 to i64
  %95 = icmp ne i64 %94, 0
  br i1 %95, label %96, label %98

96:                                               ; preds = %88
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.1, i64 0, i64 0), i32 24, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.8, i64 0, i64 0)) #6
  unreachable

97:                                               ; No predecessors!
  br label %99

98:                                               ; preds = %88
  br label %99

99:                                               ; preds = %98, %97
  %100 = getelementptr inbounds [8 x float], [8 x float]* %3, i64 0, i64 7
  %101 = load float, float* %100, align 4
  %102 = fcmp oeq float %101, 8.000000e+00
  %103 = xor i1 %102, true
  %104 = zext i1 %103 to i32
  %105 = sext i32 %104 to i64
  %106 = icmp ne i64 %105, 0
  br i1 %106, label %107, label %109

107:                                              ; preds = %99
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.1, i64 0, i64 0), i32 25, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.9, i64 0, i64 0)) #6
  unreachable

108:                                              ; No predecessors!
  br label %110

109:                                              ; preds = %99
  br label %110

110:                                              ; preds = %109, %108
  %111 = load i32, i32* %1, align 4
  ret i32 %111
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #2

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #3

declare i32 @printf(i8*, ...) #4

; Function Attrs: noreturn
declare void @__assert_rtn(i8*, i8*, i32, i8*) #5

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable willreturn }
attributes #2 = { argmemonly nounwind willreturn }
attributes #3 = { argmemonly nounwind willreturn writeonly }
attributes #4 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { noreturn "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="true" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { noreturn }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
