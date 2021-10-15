; ModuleID = 'opt.ll'
source_filename = "llvm-tests/width9_new.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.a_in = private unnamed_addr constant [9 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00, float 5.000000e+00, float 6.000000e+00, float 7.000000e+00, float 8.000000e+00, float 9.000000e+00], align 16
@__const.main.b_in = private unnamed_addr constant [9 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00, float 5.000000e+00, float 6.000000e+00, float 7.000000e+00, float 8.000000e+00, float 9.000000e+00], align 16
@__func__.main = private unnamed_addr constant [5 x i8] c"main\00", align 1
@.str = private unnamed_addr constant [24 x i8] c"llvm-tests/width9_new.c\00", align 1
@.str.1 = private unnamed_addr constant [14 x i8] c"c_out[0] == 2\00", align 1
@.str.2 = private unnamed_addr constant [14 x i8] c"c_out[1] == 4\00", align 1
@.str.3 = private unnamed_addr constant [14 x i8] c"c_out[2] == 6\00", align 1
@.str.4 = private unnamed_addr constant [14 x i8] c"c_out[3] == 8\00", align 1
@.str.5 = private unnamed_addr constant [15 x i8] c"c_out[4] == 10\00", align 1
@.str.6 = private unnamed_addr constant [15 x i8] c"c_out[5] == 12\00", align 1
@.str.7 = private unnamed_addr constant [15 x i8] c"c_out[6] == 14\00", align 1
@.str.8 = private unnamed_addr constant [15 x i8] c"c_out[7] == 16\00", align 1
@.str.9 = private unnamed_addr constant [15 x i8] c"c_out[8] == 18\00", align 1
@.str.10 = private unnamed_addr constant [11 x i8] c"first: %f\0A\00", align 1
@.str.11 = private unnamed_addr constant [12 x i8] c"second: %f\0A\00", align 1
@.str.12 = private unnamed_addr constant [11 x i8] c"third: %f\0A\00", align 1
@.str.13 = private unnamed_addr constant [12 x i8] c"fourth: %f\0A\00", align 1
@.str.14 = private unnamed_addr constant [11 x i8] c"fifth: %f\0A\00", align 1
@.str.15 = private unnamed_addr constant [11 x i8] c"sixth: %f\0A\00", align 1
@.str.16 = private unnamed_addr constant [13 x i8] c"seventh: %f\0A\00", align 1
@.str.17 = private unnamed_addr constant [11 x i8] c"eight: %f\0A\00", align 1
@.str.18 = private unnamed_addr constant [11 x i8] c"ninth: %f\0A\00", align 1

; Function Attrs: noinline nounwind ssp uwtable
define void @sum(float* %0, float* %1, float* %2) #0 {
  %4 = getelementptr inbounds float, float* %0, i64 0
  %5 = load float, float* %4, align 4
  %6 = getelementptr inbounds float, float* %1, i64 0
  %7 = load float, float* %6, align 4
  %8 = fadd float %5, %7
  %9 = getelementptr inbounds float, float* %2, i64 0
  %10 = getelementptr inbounds float, float* %0, i64 1
  %11 = load float, float* %10, align 4
  %12 = getelementptr inbounds float, float* %1, i64 1
  %13 = load float, float* %12, align 4
  %14 = fadd float %11, %13
  %15 = getelementptr inbounds float, float* %2, i64 1
  %16 = getelementptr inbounds float, float* %0, i64 2
  %17 = load float, float* %16, align 4
  %18 = getelementptr inbounds float, float* %1, i64 2
  %19 = load float, float* %18, align 4
  %20 = fadd float %17, %19
  %21 = getelementptr inbounds float, float* %2, i64 2
  %22 = getelementptr inbounds float, float* %0, i64 3
  %23 = load float, float* %22, align 4
  %24 = getelementptr inbounds float, float* %1, i64 3
  %25 = load float, float* %24, align 4
  %26 = fadd float %23, %25
  %27 = getelementptr inbounds float, float* %2, i64 3
  %28 = getelementptr inbounds float, float* %0, i64 4
  %29 = load float, float* %28, align 4
  %30 = getelementptr inbounds float, float* %1, i64 4
  %31 = load float, float* %30, align 4
  %32 = fadd float %29, %31
  %33 = getelementptr inbounds float, float* %2, i64 4
  %34 = getelementptr inbounds float, float* %0, i64 5
  %35 = load float, float* %34, align 4
  %36 = getelementptr inbounds float, float* %1, i64 5
  %37 = load float, float* %36, align 4
  %38 = fadd float %35, %37
  %39 = getelementptr inbounds float, float* %2, i64 5
  %40 = getelementptr inbounds float, float* %0, i64 6
  %41 = load float, float* %40, align 4
  %42 = getelementptr inbounds float, float* %1, i64 6
  %43 = load float, float* %42, align 4
  %44 = fadd float %41, %43
  %45 = getelementptr inbounds float, float* %2, i64 6
  %46 = getelementptr inbounds float, float* %0, i64 7
  %47 = load float, float* %46, align 4
  %48 = getelementptr inbounds float, float* %1, i64 7
  %49 = load float, float* %48, align 4
  %50 = fadd float %47, %49
  %51 = getelementptr inbounds float, float* %2, i64 7
  %52 = getelementptr inbounds float, float* %0, i64 8
  %53 = load float, float* %52, align 4
  %54 = getelementptr inbounds float, float* %1, i64 8
  %55 = load float, float* %54, align 4
  %56 = fadd float %53, %55
  %57 = getelementptr inbounds float, float* %2, i64 8
  %58 = getelementptr inbounds float, float* %0, i64 0
  %59 = load float, float* %58, align 4
  %60 = insertelement <4 x float> zeroinitializer, float %59, i32 0
  %61 = getelementptr inbounds float, float* %0, i64 1
  %62 = load float, float* %61, align 4
  %63 = insertelement <4 x float> %60, float %62, i32 1
  %64 = getelementptr inbounds float, float* %0, i64 2
  %65 = load float, float* %64, align 4
  %66 = insertelement <4 x float> %63, float %65, i32 2
  %67 = getelementptr inbounds float, float* %0, i64 3
  %68 = load float, float* %67, align 4
  %69 = insertelement <4 x float> %66, float %68, i32 3
  %70 = getelementptr inbounds float, float* %1, i64 0
  %71 = load float, float* %70, align 4
  %72 = insertelement <4 x float> zeroinitializer, float %71, i32 0
  %73 = getelementptr inbounds float, float* %1, i64 1
  %74 = load float, float* %73, align 4
  %75 = insertelement <4 x float> %72, float %74, i32 1
  %76 = getelementptr inbounds float, float* %1, i64 2
  %77 = load float, float* %76, align 4
  %78 = insertelement <4 x float> %75, float %77, i32 2
  %79 = getelementptr inbounds float, float* %1, i64 3
  %80 = load float, float* %79, align 4
  %81 = insertelement <4 x float> %78, float %80, i32 3
  %82 = fadd <4 x float> %69, %81
  %83 = getelementptr inbounds float, float* %0, i64 4
  %84 = load float, float* %83, align 4
  %85 = insertelement <4 x float> zeroinitializer, float %84, i32 0
  %86 = getelementptr inbounds float, float* %0, i64 5
  %87 = load float, float* %86, align 4
  %88 = insertelement <4 x float> %85, float %87, i32 1
  %89 = getelementptr inbounds float, float* %0, i64 6
  %90 = load float, float* %89, align 4
  %91 = insertelement <4 x float> %88, float %90, i32 2
  %92 = getelementptr inbounds float, float* %0, i64 7
  %93 = load float, float* %92, align 4
  %94 = insertelement <4 x float> %91, float %93, i32 3
  %95 = getelementptr inbounds float, float* %1, i64 4
  %96 = load float, float* %95, align 4
  %97 = insertelement <4 x float> zeroinitializer, float %96, i32 0
  %98 = getelementptr inbounds float, float* %1, i64 5
  %99 = load float, float* %98, align 4
  %100 = insertelement <4 x float> %97, float %99, i32 1
  %101 = getelementptr inbounds float, float* %1, i64 6
  %102 = load float, float* %101, align 4
  %103 = insertelement <4 x float> %100, float %102, i32 2
  %104 = getelementptr inbounds float, float* %1, i64 7
  %105 = load float, float* %104, align 4
  %106 = insertelement <4 x float> %103, float %105, i32 3
  %107 = fadd <4 x float> %94, %106
  %108 = shufflevector <4 x float> %82, <4 x float> %107, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %109 = getelementptr inbounds float, float* %0, i64 8
  %110 = load float, float* %109, align 4
  %111 = insertelement <4 x float> zeroinitializer, float %110, i32 0
  %112 = insertelement <4 x float> %111, float 0.000000e+00, i32 1
  %113 = insertelement <4 x float> %112, float 0.000000e+00, i32 2
  %114 = insertelement <4 x float> %113, float 0.000000e+00, i32 3
  %115 = getelementptr inbounds float, float* %1, i64 8
  %116 = load float, float* %115, align 4
  %117 = insertelement <4 x float> zeroinitializer, float %116, i32 0
  %118 = insertelement <4 x float> %117, float 0.000000e+00, i32 1
  %119 = insertelement <4 x float> %118, float 0.000000e+00, i32 2
  %120 = insertelement <4 x float> %119, float 0.000000e+00, i32 3
  %121 = fadd <4 x float> %114, %120
  %122 = shufflevector <8 x float> %108, <4 x float> %121, <12 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11>
  %123 = extractelement <12 x float> %122, i32 0
  %124 = getelementptr inbounds float, float* %2, i64 0
  store float %123, float* %124, align 4
  %125 = extractelement <12 x float> %122, i32 1
  %126 = getelementptr inbounds float, float* %2, i64 1
  store float %125, float* %126, align 4
  %127 = extractelement <12 x float> %122, i32 2
  %128 = getelementptr inbounds float, float* %2, i64 2
  store float %127, float* %128, align 4
  %129 = extractelement <12 x float> %122, i32 3
  %130 = getelementptr inbounds float, float* %2, i64 3
  store float %129, float* %130, align 4
  %131 = extractelement <12 x float> %122, i32 4
  %132 = getelementptr inbounds float, float* %2, i64 4
  store float %131, float* %132, align 4
  %133 = extractelement <12 x float> %122, i32 5
  %134 = getelementptr inbounds float, float* %2, i64 5
  store float %133, float* %134, align 4
  %135 = extractelement <12 x float> %122, i32 6
  %136 = getelementptr inbounds float, float* %2, i64 6
  store float %135, float* %136, align 4
  %137 = extractelement <12 x float> %122, i32 7
  %138 = getelementptr inbounds float, float* %2, i64 7
  store float %137, float* %138, align 4
  %139 = extractelement <12 x float> %122, i32 8
  %140 = getelementptr inbounds float, float* %2, i64 8
  store float %139, float* %140, align 4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main(i32 %0, i8** %1) #0 {
  %3 = alloca [9 x float], align 16
  %4 = alloca [9 x float], align 16
  %5 = alloca [9 x float], align 16
  %6 = bitcast [9 x float]* %3 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %6, i8* align 16 bitcast ([9 x float]* @__const.main.a_in to i8*), i64 36, i1 false)
  %7 = bitcast [9 x float]* %4 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %7, i8* align 16 bitcast ([9 x float]* @__const.main.b_in to i8*), i64 36, i1 false)
  %8 = getelementptr inbounds [9 x float], [9 x float]* %3, i64 0, i64 0
  %9 = getelementptr inbounds [9 x float], [9 x float]* %4, i64 0, i64 0
  %10 = getelementptr inbounds [9 x float], [9 x float]* %5, i64 0, i64 0
  call void @sum(float* %8, float* %9, float* %10)
  %11 = getelementptr inbounds [9 x float], [9 x float]* %5, i64 0, i64 0
  %12 = load float, float* %11, align 16
  %13 = fcmp oeq float %12, 2.000000e+00
  %14 = xor i1 %13, true
  %15 = zext i1 %14 to i32
  %16 = sext i32 %15 to i64
  %17 = icmp ne i64 %16, 0
  br i1 %17, label %18, label %19

18:                                               ; preds = %2
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str, i64 0, i64 0), i32 22, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.1, i64 0, i64 0)) #4
  unreachable

19:                                               ; preds = %2
  %20 = getelementptr inbounds [9 x float], [9 x float]* %5, i64 0, i64 1
  %21 = load float, float* %20, align 4
  %22 = fcmp oeq float %21, 4.000000e+00
  %23 = xor i1 %22, true
  %24 = zext i1 %23 to i32
  %25 = sext i32 %24 to i64
  %26 = icmp ne i64 %25, 0
  br i1 %26, label %27, label %28

27:                                               ; preds = %19
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str, i64 0, i64 0), i32 23, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.2, i64 0, i64 0)) #4
  unreachable

28:                                               ; preds = %19
  %29 = getelementptr inbounds [9 x float], [9 x float]* %5, i64 0, i64 2
  %30 = load float, float* %29, align 8
  %31 = fcmp oeq float %30, 6.000000e+00
  %32 = xor i1 %31, true
  %33 = zext i1 %32 to i32
  %34 = sext i32 %33 to i64
  %35 = icmp ne i64 %34, 0
  br i1 %35, label %36, label %37

36:                                               ; preds = %28
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str, i64 0, i64 0), i32 24, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.3, i64 0, i64 0)) #4
  unreachable

37:                                               ; preds = %28
  %38 = getelementptr inbounds [9 x float], [9 x float]* %5, i64 0, i64 3
  %39 = load float, float* %38, align 4
  %40 = fcmp oeq float %39, 8.000000e+00
  %41 = xor i1 %40, true
  %42 = zext i1 %41 to i32
  %43 = sext i32 %42 to i64
  %44 = icmp ne i64 %43, 0
  br i1 %44, label %45, label %46

45:                                               ; preds = %37
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str, i64 0, i64 0), i32 25, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.4, i64 0, i64 0)) #4
  unreachable

46:                                               ; preds = %37
  %47 = getelementptr inbounds [9 x float], [9 x float]* %5, i64 0, i64 4
  %48 = load float, float* %47, align 16
  %49 = fcmp oeq float %48, 1.000000e+01
  %50 = xor i1 %49, true
  %51 = zext i1 %50 to i32
  %52 = sext i32 %51 to i64
  %53 = icmp ne i64 %52, 0
  br i1 %53, label %54, label %55

54:                                               ; preds = %46
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str, i64 0, i64 0), i32 26, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.5, i64 0, i64 0)) #4
  unreachable

55:                                               ; preds = %46
  %56 = getelementptr inbounds [9 x float], [9 x float]* %5, i64 0, i64 5
  %57 = load float, float* %56, align 4
  %58 = fcmp oeq float %57, 1.200000e+01
  %59 = xor i1 %58, true
  %60 = zext i1 %59 to i32
  %61 = sext i32 %60 to i64
  %62 = icmp ne i64 %61, 0
  br i1 %62, label %63, label %64

63:                                               ; preds = %55
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str, i64 0, i64 0), i32 27, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.6, i64 0, i64 0)) #4
  unreachable

64:                                               ; preds = %55
  %65 = getelementptr inbounds [9 x float], [9 x float]* %5, i64 0, i64 6
  %66 = load float, float* %65, align 8
  %67 = fcmp oeq float %66, 1.400000e+01
  %68 = xor i1 %67, true
  %69 = zext i1 %68 to i32
  %70 = sext i32 %69 to i64
  %71 = icmp ne i64 %70, 0
  br i1 %71, label %72, label %73

72:                                               ; preds = %64
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str, i64 0, i64 0), i32 28, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.7, i64 0, i64 0)) #4
  unreachable

73:                                               ; preds = %64
  %74 = getelementptr inbounds [9 x float], [9 x float]* %5, i64 0, i64 7
  %75 = load float, float* %74, align 4
  %76 = fcmp oeq float %75, 1.600000e+01
  %77 = xor i1 %76, true
  %78 = zext i1 %77 to i32
  %79 = sext i32 %78 to i64
  %80 = icmp ne i64 %79, 0
  br i1 %80, label %81, label %82

81:                                               ; preds = %73
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str, i64 0, i64 0), i32 29, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.8, i64 0, i64 0)) #4
  unreachable

82:                                               ; preds = %73
  %83 = getelementptr inbounds [9 x float], [9 x float]* %5, i64 0, i64 8
  %84 = load float, float* %83, align 16
  %85 = fcmp oeq float %84, 1.800000e+01
  %86 = xor i1 %85, true
  %87 = zext i1 %86 to i32
  %88 = sext i32 %87 to i64
  %89 = icmp ne i64 %88, 0
  br i1 %89, label %90, label %91

90:                                               ; preds = %82
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str, i64 0, i64 0), i32 30, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.9, i64 0, i64 0)) #4
  unreachable

91:                                               ; preds = %82
  %92 = getelementptr inbounds [9 x float], [9 x float]* %5, i64 0, i64 0
  %93 = load float, float* %92, align 16
  %94 = fpext float %93 to double
  %95 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.10, i64 0, i64 0), double %94)
  %96 = getelementptr inbounds [9 x float], [9 x float]* %5, i64 0, i64 1
  %97 = load float, float* %96, align 4
  %98 = fpext float %97 to double
  %99 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.11, i64 0, i64 0), double %98)
  %100 = getelementptr inbounds [9 x float], [9 x float]* %5, i64 0, i64 2
  %101 = load float, float* %100, align 8
  %102 = fpext float %101 to double
  %103 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.12, i64 0, i64 0), double %102)
  %104 = getelementptr inbounds [9 x float], [9 x float]* %5, i64 0, i64 3
  %105 = load float, float* %104, align 4
  %106 = fpext float %105 to double
  %107 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.13, i64 0, i64 0), double %106)
  %108 = getelementptr inbounds [9 x float], [9 x float]* %5, i64 0, i64 4
  %109 = load float, float* %108, align 16
  %110 = fpext float %109 to double
  %111 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.14, i64 0, i64 0), double %110)
  %112 = getelementptr inbounds [9 x float], [9 x float]* %5, i64 0, i64 5
  %113 = load float, float* %112, align 4
  %114 = fpext float %113 to double
  %115 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.15, i64 0, i64 0), double %114)
  %116 = getelementptr inbounds [9 x float], [9 x float]* %5, i64 0, i64 6
  %117 = load float, float* %116, align 8
  %118 = fpext float %117 to double
  %119 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.16, i64 0, i64 0), double %118)
  %120 = getelementptr inbounds [9 x float], [9 x float]* %5, i64 0, i64 7
  %121 = load float, float* %120, align 4
  %122 = fpext float %121 to double
  %123 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.17, i64 0, i64 0), double %122)
  %124 = getelementptr inbounds [9 x float], [9 x float]* %5, i64 0, i64 8
  %125 = load float, float* %124, align 16
  %126 = fpext float %125 to double
  %127 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.18, i64 0, i64 0), double %126)
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #1

; Function Attrs: noreturn
declare void @__assert_rtn(i8*, i8*, i32, i8*) #2

declare i32 @printf(i8*, ...) #3

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { noreturn "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="true" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { noreturn }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
