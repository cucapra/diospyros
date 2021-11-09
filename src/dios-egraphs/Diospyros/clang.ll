; ModuleID = 'llvm-tests/qr-decomp-fixed-size.c'
source_filename = "llvm-tests/qr-decomp-fixed-size.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.A = private unnamed_addr constant [16 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00, float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00, float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00, float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00], align 16

; Function Attrs: alwaysinline nounwind ssp uwtable
define float @sgn(float %0) #0 {
  %2 = alloca float, align 4
  store float %0, float* %2, align 4
  %3 = load float, float* %2, align 4
  %4 = fcmp ogt float %3, 0.000000e+00
  %5 = zext i1 %4 to i32
  %6 = load float, float* %2, align 4
  %7 = fcmp olt float %6, 0.000000e+00
  %8 = zext i1 %7 to i32
  %9 = sub nsw i32 %5, %8
  %10 = sitofp i32 %9 to float
  ret float %10
}

; Function Attrs: alwaysinline nounwind ssp uwtable
define float @naive_norm(float* %0, i32 %1) #0 {
  %3 = alloca float*, align 8
  %4 = alloca i32, align 4
  %5 = alloca float, align 4
  %6 = alloca i32, align 4
  store float* %0, float** %3, align 8
  store i32 %1, i32* %4, align 4
  store float 0.000000e+00, float* %5, align 4
  store i32 0, i32* %6, align 4
  br label %7

7:                                                ; preds = %23, %2
  %8 = load i32, i32* %6, align 4
  %9 = load i32, i32* %4, align 4
  %10 = icmp slt i32 %8, %9
  br i1 %10, label %11, label %26

11:                                               ; preds = %7
  %12 = load float*, float** %3, align 8
  %13 = load i32, i32* %6, align 4
  %14 = sext i32 %13 to i64
  %15 = getelementptr inbounds float, float* %12, i64 %14
  %16 = load float, float* %15, align 4
  %17 = fpext float %16 to double
  %18 = call double @llvm.pow.f64(double %17, double 2.000000e+00)
  %19 = load float, float* %5, align 4
  %20 = fpext float %19 to double
  %21 = fadd double %20, %18
  %22 = fptrunc double %21 to float
  store float %22, float* %5, align 4
  br label %23

23:                                               ; preds = %11
  %24 = load i32, i32* %6, align 4
  %25 = add nsw i32 %24, 1
  store i32 %25, i32* %6, align 4
  br label %7

26:                                               ; preds = %7
  %27 = load float, float* %5, align 4
  %28 = fpext float %27 to double
  %29 = call double @llvm.sqrt.f64(double %28)
  %30 = fptrunc double %29 to float
  ret float %30
}

; Function Attrs: nounwind readnone speculatable willreturn
declare double @llvm.pow.f64(double, double) #1

; Function Attrs: nounwind readnone speculatable willreturn
declare double @llvm.sqrt.f64(double) #1

; Function Attrs: alwaysinline nounwind ssp uwtable
define void @naive_fixed_transpose(float* %0) #0 {
  %2 = alloca float*, align 8
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca float, align 4
  store float* %0, float** %2, align 8
  store i32 0, i32* %3, align 4
  br label %6

6:                                                ; preds = %51, %1
  %7 = load i32, i32* %3, align 4
  %8 = icmp slt i32 %7, 4
  br i1 %8, label %9, label %54

9:                                                ; preds = %6
  %10 = load i32, i32* %3, align 4
  %11 = add nsw i32 %10, 1
  store i32 %11, i32* %4, align 4
  br label %12

12:                                               ; preds = %47, %9
  %13 = load i32, i32* %4, align 4
  %14 = icmp slt i32 %13, 4
  br i1 %14, label %15, label %50

15:                                               ; preds = %12
  %16 = load float*, float** %2, align 8
  %17 = load i32, i32* %3, align 4
  %18 = mul nsw i32 %17, 4
  %19 = load i32, i32* %4, align 4
  %20 = add nsw i32 %18, %19
  %21 = sext i32 %20 to i64
  %22 = getelementptr inbounds float, float* %16, i64 %21
  %23 = load float, float* %22, align 4
  store float %23, float* %5, align 4
  %24 = load float*, float** %2, align 8
  %25 = load i32, i32* %4, align 4
  %26 = mul nsw i32 %25, 4
  %27 = load i32, i32* %3, align 4
  %28 = add nsw i32 %26, %27
  %29 = sext i32 %28 to i64
  %30 = getelementptr inbounds float, float* %24, i64 %29
  %31 = load float, float* %30, align 4
  %32 = load float*, float** %2, align 8
  %33 = load i32, i32* %3, align 4
  %34 = mul nsw i32 %33, 4
  %35 = load i32, i32* %4, align 4
  %36 = add nsw i32 %34, %35
  %37 = sext i32 %36 to i64
  %38 = getelementptr inbounds float, float* %32, i64 %37
  store float %31, float* %38, align 4
  %39 = load float, float* %5, align 4
  %40 = load float*, float** %2, align 8
  %41 = load i32, i32* %4, align 4
  %42 = mul nsw i32 %41, 4
  %43 = load i32, i32* %3, align 4
  %44 = add nsw i32 %42, %43
  %45 = sext i32 %44 to i64
  %46 = getelementptr inbounds float, float* %40, i64 %45
  store float %39, float* %46, align 4
  br label %47

47:                                               ; preds = %15
  %48 = load i32, i32* %4, align 4
  %49 = add nsw i32 %48, 1
  store i32 %49, i32* %4, align 4
  br label %12

50:                                               ; preds = %12
  br label %51

51:                                               ; preds = %50
  %52 = load i32, i32* %3, align 4
  %53 = add nsw i32 %52, 1
  store i32 %53, i32* %3, align 4
  br label %6

54:                                               ; preds = %6
  ret void
}

; Function Attrs: alwaysinline nounwind ssp uwtable
define void @naive_fixed_matrix_multiply(float* %0, float* %1, float* %2) #0 {
  %4 = alloca float*, align 8
  %5 = alloca float*, align 8
  %6 = alloca float*, align 8
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  store float* %0, float** %4, align 8
  store float* %1, float** %5, align 8
  store float* %2, float** %6, align 8
  store i32 0, i32* %7, align 4
  br label %10

10:                                               ; preds = %63, %3
  %11 = load i32, i32* %7, align 4
  %12 = icmp slt i32 %11, 4
  br i1 %12, label %13, label %66

13:                                               ; preds = %10
  store i32 0, i32* %8, align 4
  br label %14

14:                                               ; preds = %59, %13
  %15 = load i32, i32* %8, align 4
  %16 = icmp slt i32 %15, 4
  br i1 %16, label %17, label %62

17:                                               ; preds = %14
  %18 = load float*, float** %6, align 8
  %19 = load i32, i32* %7, align 4
  %20 = mul nsw i32 4, %19
  %21 = load i32, i32* %8, align 4
  %22 = add nsw i32 %20, %21
  %23 = sext i32 %22 to i64
  %24 = getelementptr inbounds float, float* %18, i64 %23
  store float 0.000000e+00, float* %24, align 4
  store i32 0, i32* %9, align 4
  br label %25

25:                                               ; preds = %55, %17
  %26 = load i32, i32* %9, align 4
  %27 = icmp slt i32 %26, 4
  br i1 %27, label %28, label %58

28:                                               ; preds = %25
  %29 = load float*, float** %4, align 8
  %30 = load i32, i32* %7, align 4
  %31 = mul nsw i32 4, %30
  %32 = load i32, i32* %9, align 4
  %33 = add nsw i32 %31, %32
  %34 = sext i32 %33 to i64
  %35 = getelementptr inbounds float, float* %29, i64 %34
  %36 = load float, float* %35, align 4
  %37 = load float*, float** %5, align 8
  %38 = load i32, i32* %9, align 4
  %39 = mul nsw i32 4, %38
  %40 = load i32, i32* %8, align 4
  %41 = add nsw i32 %39, %40
  %42 = sext i32 %41 to i64
  %43 = getelementptr inbounds float, float* %37, i64 %42
  %44 = load float, float* %43, align 4
  %45 = fmul float %36, %44
  %46 = load float*, float** %6, align 8
  %47 = load i32, i32* %7, align 4
  %48 = mul nsw i32 4, %47
  %49 = load i32, i32* %8, align 4
  %50 = add nsw i32 %48, %49
  %51 = sext i32 %50 to i64
  %52 = getelementptr inbounds float, float* %46, i64 %51
  %53 = load float, float* %52, align 4
  %54 = fadd float %53, %45
  store float %54, float* %52, align 4
  br label %55

55:                                               ; preds = %28
  %56 = load i32, i32* %9, align 4
  %57 = add nsw i32 %56, 1
  store i32 %57, i32* %9, align 4
  br label %25

58:                                               ; preds = %25
  br label %59

59:                                               ; preds = %58
  %60 = load i32, i32* %8, align 4
  %61 = add nsw i32 %60, 1
  store i32 %61, i32* %8, align 4
  br label %14

62:                                               ; preds = %14
  br label %63

63:                                               ; preds = %62
  %64 = load i32, i32* %7, align 4
  %65 = add nsw i32 %64, 1
  store i32 %65, i32* %7, align 4
  br label %10

66:                                               ; preds = %10
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define void @naive_fixed_qr_decomp(float* %0, float* %1, float* %2) #2 {
  %4 = alloca float*, align 8
  %5 = alloca i32, align 4
  %6 = alloca float, align 4
  %7 = alloca i32, align 4
  %8 = alloca float*, align 8
  %9 = alloca i32, align 4
  %10 = alloca float, align 4
  %11 = alloca i32, align 4
  %12 = alloca float*, align 8
  %13 = alloca float*, align 8
  %14 = alloca float*, align 8
  %15 = alloca i32, align 4
  %16 = alloca i32, align 4
  %17 = alloca i32, align 4
  %18 = alloca float*, align 8
  %19 = alloca i32, align 4
  %20 = alloca i32, align 4
  %21 = alloca float, align 4
  %22 = alloca float, align 4
  %23 = alloca float*, align 8
  %24 = alloca float*, align 8
  %25 = alloca float*, align 8
  %26 = alloca float*, align 8
  %27 = alloca i32, align 4
  %28 = alloca i32, align 4
  %29 = alloca i32, align 4
  %30 = alloca i32, align 4
  %31 = alloca float*, align 8
  %32 = alloca float*, align 8
  %33 = alloca i32, align 4
  %34 = alloca i32, align 4
  %35 = alloca float, align 4
  %36 = alloca float*, align 8
  %37 = alloca float*, align 8
  %38 = alloca i32, align 4
  %39 = alloca float, align 4
  %40 = alloca i32, align 4
  %41 = alloca float*, align 8
  %42 = alloca i32, align 4
  %43 = alloca i32, align 4
  %44 = alloca float, align 4
  %45 = alloca float*, align 8
  %46 = alloca i32, align 4
  %47 = alloca i32, align 4
  %48 = alloca float, align 4
  store float* %0, float** %23, align 8
  store float* %1, float** %24, align 8
  store float* %2, float** %25, align 8
  %49 = load float*, float** %25, align 8
  %50 = bitcast float* %49 to i8*
  %51 = load float*, float** %23, align 8
  %52 = bitcast float* %51 to i8*
  %53 = load float*, float** %25, align 8
  %54 = bitcast float* %53 to i8*
  %55 = call i64 @llvm.objectsize.i64.p0i8(i8* %54, i1 false, i1 true, i1 false)
  %56 = call i8* @__memcpy_chk(i8* %50, i8* %52, i64 64, i64 %55) #7
  %57 = call i8* @calloc(i64 4, i64 16) #8
  %58 = bitcast i8* %57 to float*
  store float* %58, float** %26, align 8
  store i32 0, i32* %27, align 4
  br label %59

59:                                               ; preds = %83, %3
  %60 = load i32, i32* %27, align 4
  %61 = icmp slt i32 %60, 4
  br i1 %61, label %62, label %86

62:                                               ; preds = %59
  store i32 0, i32* %28, align 4
  br label %63

63:                                               ; preds = %79, %62
  %64 = load i32, i32* %28, align 4
  %65 = icmp slt i32 %64, 4
  br i1 %65, label %66, label %82

66:                                               ; preds = %63
  %67 = load i32, i32* %27, align 4
  %68 = load i32, i32* %28, align 4
  %69 = icmp eq i32 %67, %68
  %70 = zext i1 %69 to i32
  %71 = sitofp i32 %70 to float
  %72 = load float*, float** %26, align 8
  %73 = load i32, i32* %27, align 4
  %74 = mul nsw i32 %73, 4
  %75 = load i32, i32* %28, align 4
  %76 = add nsw i32 %74, %75
  %77 = sext i32 %76 to i64
  %78 = getelementptr inbounds float, float* %72, i64 %77
  store float %71, float* %78, align 4
  br label %79

79:                                               ; preds = %66
  %80 = load i32, i32* %28, align 4
  %81 = add nsw i32 %80, 1
  store i32 %81, i32* %28, align 4
  br label %63

82:                                               ; preds = %63
  br label %83

83:                                               ; preds = %82
  %84 = load i32, i32* %27, align 4
  %85 = add nsw i32 %84, 1
  store i32 %85, i32* %27, align 4
  br label %59

86:                                               ; preds = %59
  store i32 0, i32* %29, align 4
  br label %87

87:                                               ; preds = %419, %86
  %88 = load i32, i32* %29, align 4
  %89 = icmp slt i32 %88, 3
  br i1 %89, label %90, label %422

90:                                               ; preds = %87
  %91 = load i32, i32* %29, align 4
  %92 = sub nsw i32 4, %91
  store i32 %92, i32* %30, align 4
  %93 = load i32, i32* %30, align 4
  %94 = sext i32 %93 to i64
  %95 = call i8* @calloc(i64 4, i64 %94) #8
  %96 = bitcast i8* %95 to float*
  store float* %96, float** %31, align 8
  %97 = load i32, i32* %30, align 4
  %98 = sext i32 %97 to i64
  %99 = call i8* @calloc(i64 4, i64 %98) #8
  %100 = bitcast i8* %99 to float*
  store float* %100, float** %32, align 8
  store i32 0, i32* %33, align 4
  br label %101

101:                                              ; preds = %133, %90
  %102 = load i32, i32* %33, align 4
  %103 = load i32, i32* %30, align 4
  %104 = icmp slt i32 %102, %103
  br i1 %104, label %105, label %136

105:                                              ; preds = %101
  %106 = load i32, i32* %29, align 4
  %107 = load i32, i32* %33, align 4
  %108 = add nsw i32 %106, %107
  store i32 %108, i32* %34, align 4
  %109 = load float*, float** %25, align 8
  %110 = load i32, i32* %34, align 4
  %111 = mul nsw i32 %110, 4
  %112 = load i32, i32* %29, align 4
  %113 = add nsw i32 %111, %112
  %114 = sext i32 %113 to i64
  %115 = getelementptr inbounds float, float* %109, i64 %114
  %116 = load float, float* %115, align 4
  %117 = load float*, float** %31, align 8
  %118 = load i32, i32* %33, align 4
  %119 = sext i32 %118 to i64
  %120 = getelementptr inbounds float, float* %117, i64 %119
  store float %116, float* %120, align 4
  %121 = load float*, float** %26, align 8
  %122 = load i32, i32* %34, align 4
  %123 = mul nsw i32 %122, 4
  %124 = load i32, i32* %29, align 4
  %125 = add nsw i32 %123, %124
  %126 = sext i32 %125 to i64
  %127 = getelementptr inbounds float, float* %121, i64 %126
  %128 = load float, float* %127, align 4
  %129 = load float*, float** %32, align 8
  %130 = load i32, i32* %33, align 4
  %131 = sext i32 %130 to i64
  %132 = getelementptr inbounds float, float* %129, i64 %131
  store float %128, float* %132, align 4
  br label %133

133:                                              ; preds = %105
  %134 = load i32, i32* %33, align 4
  %135 = add nsw i32 %134, 1
  store i32 %135, i32* %33, align 4
  br label %101

136:                                              ; preds = %101
  %137 = load float*, float** %31, align 8
  %138 = getelementptr inbounds float, float* %137, i64 0
  %139 = load float, float* %138, align 4
  store float %139, float* %22, align 4
  %140 = load float, float* %22, align 4
  %141 = fcmp ogt float %140, 0.000000e+00
  %142 = zext i1 %141 to i32
  %143 = load float, float* %22, align 4
  %144 = fcmp olt float %143, 0.000000e+00
  %145 = zext i1 %144 to i32
  %146 = sub nsw i32 %142, %145
  %147 = sitofp i32 %146 to float
  %148 = fneg float %147
  %149 = load float*, float** %31, align 8
  %150 = load i32, i32* %30, align 4
  store float* %149, float** %4, align 8
  store i32 %150, i32* %5, align 4
  store float 0.000000e+00, float* %6, align 4
  store i32 0, i32* %7, align 4
  br label %151

151:                                              ; preds = %155, %136
  %152 = load i32, i32* %7, align 4
  %153 = load i32, i32* %5, align 4
  %154 = icmp slt i32 %152, %153
  br i1 %154, label %155, label %169

155:                                              ; preds = %151
  %156 = load float*, float** %4, align 8
  %157 = load i32, i32* %7, align 4
  %158 = sext i32 %157 to i64
  %159 = getelementptr inbounds float, float* %156, i64 %158
  %160 = load float, float* %159, align 4
  %161 = fpext float %160 to double
  %162 = call double @llvm.pow.f64(double %161, double 2.000000e+00) #7
  %163 = load float, float* %6, align 4
  %164 = fpext float %163 to double
  %165 = fadd double %164, %162
  %166 = fptrunc double %165 to float
  store float %166, float* %6, align 4
  %167 = load i32, i32* %7, align 4
  %168 = add nsw i32 %167, 1
  store i32 %168, i32* %7, align 4
  br label %151

169:                                              ; preds = %151
  %170 = load float, float* %6, align 4
  %171 = fpext float %170 to double
  %172 = call double @llvm.sqrt.f64(double %171) #7
  %173 = fptrunc double %172 to float
  %174 = fmul float %148, %173
  store float %174, float* %35, align 4
  %175 = load i32, i32* %30, align 4
  %176 = sext i32 %175 to i64
  %177 = call i8* @calloc(i64 4, i64 %176) #8
  %178 = bitcast i8* %177 to float*
  store float* %178, float** %36, align 8
  %179 = load i32, i32* %30, align 4
  %180 = sext i32 %179 to i64
  %181 = call i8* @calloc(i64 4, i64 %180) #8
  %182 = bitcast i8* %181 to float*
  store float* %182, float** %37, align 8
  store i32 0, i32* %38, align 4
  br label %183

183:                                              ; preds = %205, %169
  %184 = load i32, i32* %38, align 4
  %185 = load i32, i32* %30, align 4
  %186 = icmp slt i32 %184, %185
  br i1 %186, label %187, label %208

187:                                              ; preds = %183
  %188 = load float*, float** %31, align 8
  %189 = load i32, i32* %38, align 4
  %190 = sext i32 %189 to i64
  %191 = getelementptr inbounds float, float* %188, i64 %190
  %192 = load float, float* %191, align 4
  %193 = load float, float* %35, align 4
  %194 = load float*, float** %32, align 8
  %195 = load i32, i32* %38, align 4
  %196 = sext i32 %195 to i64
  %197 = getelementptr inbounds float, float* %194, i64 %196
  %198 = load float, float* %197, align 4
  %199 = fmul float %193, %198
  %200 = fadd float %192, %199
  %201 = load float*, float** %36, align 8
  %202 = load i32, i32* %38, align 4
  %203 = sext i32 %202 to i64
  %204 = getelementptr inbounds float, float* %201, i64 %203
  store float %200, float* %204, align 4
  br label %205

205:                                              ; preds = %187
  %206 = load i32, i32* %38, align 4
  %207 = add nsw i32 %206, 1
  store i32 %207, i32* %38, align 4
  br label %183

208:                                              ; preds = %183
  %209 = load float*, float** %36, align 8
  %210 = load i32, i32* %30, align 4
  store float* %209, float** %8, align 8
  store i32 %210, i32* %9, align 4
  store float 0.000000e+00, float* %10, align 4
  store i32 0, i32* %11, align 4
  br label %211

211:                                              ; preds = %215, %208
  %212 = load i32, i32* %11, align 4
  %213 = load i32, i32* %9, align 4
  %214 = icmp slt i32 %212, %213
  br i1 %214, label %215, label %229

215:                                              ; preds = %211
  %216 = load float*, float** %8, align 8
  %217 = load i32, i32* %11, align 4
  %218 = sext i32 %217 to i64
  %219 = getelementptr inbounds float, float* %216, i64 %218
  %220 = load float, float* %219, align 4
  %221 = fpext float %220 to double
  %222 = call double @llvm.pow.f64(double %221, double 2.000000e+00) #7
  %223 = load float, float* %10, align 4
  %224 = fpext float %223 to double
  %225 = fadd double %224, %222
  %226 = fptrunc double %225 to float
  store float %226, float* %10, align 4
  %227 = load i32, i32* %11, align 4
  %228 = add nsw i32 %227, 1
  store i32 %228, i32* %11, align 4
  br label %211

229:                                              ; preds = %211
  %230 = load float, float* %10, align 4
  %231 = fpext float %230 to double
  %232 = call double @llvm.sqrt.f64(double %231) #7
  %233 = fptrunc double %232 to float
  store float %233, float* %39, align 4
  store i32 0, i32* %40, align 4
  br label %234

234:                                              ; preds = %250, %229
  %235 = load i32, i32* %40, align 4
  %236 = load i32, i32* %30, align 4
  %237 = icmp slt i32 %235, %236
  br i1 %237, label %238, label %253

238:                                              ; preds = %234
  %239 = load float*, float** %36, align 8
  %240 = load i32, i32* %40, align 4
  %241 = sext i32 %240 to i64
  %242 = getelementptr inbounds float, float* %239, i64 %241
  %243 = load float, float* %242, align 4
  %244 = load float, float* %39, align 4
  %245 = fdiv float %243, %244
  %246 = load float*, float** %37, align 8
  %247 = load i32, i32* %40, align 4
  %248 = sext i32 %247 to i64
  %249 = getelementptr inbounds float, float* %246, i64 %248
  store float %245, float* %249, align 4
  br label %250

250:                                              ; preds = %238
  %251 = load i32, i32* %40, align 4
  %252 = add nsw i32 %251, 1
  store i32 %252, i32* %40, align 4
  br label %234

253:                                              ; preds = %234
  %254 = load i32, i32* %30, align 4
  %255 = load i32, i32* %30, align 4
  %256 = mul nsw i32 %254, %255
  %257 = sext i32 %256 to i64
  %258 = call i8* @calloc(i64 4, i64 %257) #8
  %259 = bitcast i8* %258 to float*
  store float* %259, float** %41, align 8
  store i32 0, i32* %42, align 4
  br label %260

260:                                              ; preds = %303, %253
  %261 = load i32, i32* %42, align 4
  %262 = load i32, i32* %30, align 4
  %263 = icmp slt i32 %261, %262
  br i1 %263, label %264, label %306

264:                                              ; preds = %260
  store i32 0, i32* %43, align 4
  br label %265

265:                                              ; preds = %299, %264
  %266 = load i32, i32* %43, align 4
  %267 = load i32, i32* %30, align 4
  %268 = icmp slt i32 %266, %267
  br i1 %268, label %269, label %302

269:                                              ; preds = %265
  %270 = load i32, i32* %42, align 4
  %271 = load i32, i32* %43, align 4
  %272 = icmp eq i32 %270, %271
  %273 = zext i1 %272 to i64
  %274 = select i1 %272, double 1.000000e+00, double 0.000000e+00
  %275 = load float*, float** %37, align 8
  %276 = load i32, i32* %42, align 4
  %277 = sext i32 %276 to i64
  %278 = getelementptr inbounds float, float* %275, i64 %277
  %279 = load float, float* %278, align 4
  %280 = fmul float 2.000000e+00, %279
  %281 = load float*, float** %37, align 8
  %282 = load i32, i32* %43, align 4
  %283 = sext i32 %282 to i64
  %284 = getelementptr inbounds float, float* %281, i64 %283
  %285 = load float, float* %284, align 4
  %286 = fmul float %280, %285
  %287 = fpext float %286 to double
  %288 = fsub double %274, %287
  %289 = fptrunc double %288 to float
  store float %289, float* %44, align 4
  %290 = load float, float* %44, align 4
  %291 = load float*, float** %41, align 8
  %292 = load i32, i32* %42, align 4
  %293 = load i32, i32* %30, align 4
  %294 = mul nsw i32 %292, %293
  %295 = load i32, i32* %43, align 4
  %296 = add nsw i32 %294, %295
  %297 = sext i32 %296 to i64
  %298 = getelementptr inbounds float, float* %291, i64 %297
  store float %290, float* %298, align 4
  br label %299

299:                                              ; preds = %269
  %300 = load i32, i32* %43, align 4
  %301 = add nsw i32 %300, 1
  store i32 %301, i32* %43, align 4
  br label %265

302:                                              ; preds = %265
  br label %303

303:                                              ; preds = %302
  %304 = load i32, i32* %42, align 4
  %305 = add nsw i32 %304, 1
  store i32 %305, i32* %42, align 4
  br label %260

306:                                              ; preds = %260
  %307 = call i8* @calloc(i64 4, i64 16) #8
  %308 = bitcast i8* %307 to float*
  store float* %308, float** %45, align 8
  store i32 0, i32* %46, align 4
  br label %309

309:                                              ; preds = %358, %306
  %310 = load i32, i32* %46, align 4
  %311 = icmp slt i32 %310, 4
  br i1 %311, label %312, label %361

312:                                              ; preds = %309
  store i32 0, i32* %47, align 4
  br label %313

313:                                              ; preds = %354, %312
  %314 = load i32, i32* %47, align 4
  %315 = icmp slt i32 %314, 4
  br i1 %315, label %316, label %357

316:                                              ; preds = %313
  %317 = load i32, i32* %46, align 4
  %318 = load i32, i32* %29, align 4
  %319 = icmp slt i32 %317, %318
  br i1 %319, label %324, label %320

320:                                              ; preds = %316
  %321 = load i32, i32* %47, align 4
  %322 = load i32, i32* %29, align 4
  %323 = icmp slt i32 %321, %322
  br i1 %323, label %324, label %331

324:                                              ; preds = %320, %316
  %325 = load i32, i32* %46, align 4
  %326 = load i32, i32* %47, align 4
  %327 = icmp eq i32 %325, %326
  %328 = zext i1 %327 to i64
  %329 = select i1 %327, double 1.000000e+00, double 0.000000e+00
  %330 = fptrunc double %329 to float
  store float %330, float* %48, align 4
  br label %345

331:                                              ; preds = %320
  %332 = load float*, float** %41, align 8
  %333 = load i32, i32* %46, align 4
  %334 = load i32, i32* %29, align 4
  %335 = sub nsw i32 %333, %334
  %336 = load i32, i32* %30, align 4
  %337 = mul nsw i32 %335, %336
  %338 = load i32, i32* %47, align 4
  %339 = load i32, i32* %29, align 4
  %340 = sub nsw i32 %338, %339
  %341 = add nsw i32 %337, %340
  %342 = sext i32 %341 to i64
  %343 = getelementptr inbounds float, float* %332, i64 %342
  %344 = load float, float* %343, align 4
  store float %344, float* %48, align 4
  br label %345

345:                                              ; preds = %331, %324
  %346 = load float, float* %48, align 4
  %347 = load float*, float** %45, align 8
  %348 = load i32, i32* %46, align 4
  %349 = mul nsw i32 %348, 4
  %350 = load i32, i32* %47, align 4
  %351 = add nsw i32 %349, %350
  %352 = sext i32 %351 to i64
  %353 = getelementptr inbounds float, float* %347, i64 %352
  store float %346, float* %353, align 4
  br label %354

354:                                              ; preds = %345
  %355 = load i32, i32* %47, align 4
  %356 = add nsw i32 %355, 1
  store i32 %356, i32* %47, align 4
  br label %313

357:                                              ; preds = %313
  br label %358

358:                                              ; preds = %357
  %359 = load i32, i32* %46, align 4
  %360 = add nsw i32 %359, 1
  store i32 %360, i32* %46, align 4
  br label %309

361:                                              ; preds = %309
  %362 = load float*, float** %45, align 8
  %363 = load float*, float** %23, align 8
  %364 = load float*, float** %25, align 8
  store float* %362, float** %12, align 8
  store float* %363, float** %13, align 8
  store float* %364, float** %14, align 8
  store i32 0, i32* %15, align 4
  br label %365

365:                                              ; preds = %415, %361
  %366 = load i32, i32* %15, align 4
  %367 = icmp slt i32 %366, 4
  br i1 %367, label %368, label %418

368:                                              ; preds = %365
  store i32 0, i32* %16, align 4
  br label %369

369:                                              ; preds = %412, %368
  %370 = load i32, i32* %16, align 4
  %371 = icmp slt i32 %370, 4
  br i1 %371, label %372, label %415

372:                                              ; preds = %369
  %373 = load float*, float** %14, align 8
  %374 = load i32, i32* %15, align 4
  %375 = mul nsw i32 4, %374
  %376 = load i32, i32* %16, align 4
  %377 = add nsw i32 %375, %376
  %378 = sext i32 %377 to i64
  %379 = getelementptr inbounds float, float* %373, i64 %378
  store float 0.000000e+00, float* %379, align 4
  store i32 0, i32* %17, align 4
  br label %380

380:                                              ; preds = %383, %372
  %381 = load i32, i32* %17, align 4
  %382 = icmp slt i32 %381, 4
  br i1 %382, label %383, label %412

383:                                              ; preds = %380
  %384 = load float*, float** %12, align 8
  %385 = load i32, i32* %15, align 4
  %386 = mul nsw i32 4, %385
  %387 = load i32, i32* %17, align 4
  %388 = add nsw i32 %386, %387
  %389 = sext i32 %388 to i64
  %390 = getelementptr inbounds float, float* %384, i64 %389
  %391 = load float, float* %390, align 4
  %392 = load float*, float** %13, align 8
  %393 = load i32, i32* %17, align 4
  %394 = mul nsw i32 4, %393
  %395 = load i32, i32* %16, align 4
  %396 = add nsw i32 %394, %395
  %397 = sext i32 %396 to i64
  %398 = getelementptr inbounds float, float* %392, i64 %397
  %399 = load float, float* %398, align 4
  %400 = fmul float %391, %399
  %401 = load float*, float** %14, align 8
  %402 = load i32, i32* %15, align 4
  %403 = mul nsw i32 4, %402
  %404 = load i32, i32* %16, align 4
  %405 = add nsw i32 %403, %404
  %406 = sext i32 %405 to i64
  %407 = getelementptr inbounds float, float* %401, i64 %406
  %408 = load float, float* %407, align 4
  %409 = fadd float %408, %400
  store float %409, float* %407, align 4
  %410 = load i32, i32* %17, align 4
  %411 = add nsw i32 %410, 1
  store i32 %411, i32* %17, align 4
  br label %380

412:                                              ; preds = %380
  %413 = load i32, i32* %16, align 4
  %414 = add nsw i32 %413, 1
  store i32 %414, i32* %16, align 4
  br label %369

415:                                              ; preds = %369
  %416 = load i32, i32* %15, align 4
  %417 = add nsw i32 %416, 1
  store i32 %417, i32* %15, align 4
  br label %365

418:                                              ; preds = %365
  br label %419

419:                                              ; preds = %418
  %420 = load i32, i32* %29, align 4
  %421 = add nsw i32 %420, 1
  store i32 %421, i32* %29, align 4
  br label %87

422:                                              ; preds = %87
  %423 = load float*, float** %24, align 8
  store float* %423, float** %18, align 8
  store i32 0, i32* %19, align 4
  br label %424

424:                                              ; preds = %467, %422
  %425 = load i32, i32* %19, align 4
  %426 = icmp slt i32 %425, 4
  br i1 %426, label %427, label %470

427:                                              ; preds = %424
  %428 = load i32, i32* %19, align 4
  %429 = add nsw i32 %428, 1
  store i32 %429, i32* %20, align 4
  br label %430

430:                                              ; preds = %433, %427
  %431 = load i32, i32* %20, align 4
  %432 = icmp slt i32 %431, 4
  br i1 %432, label %433, label %467

433:                                              ; preds = %430
  %434 = load float*, float** %18, align 8
  %435 = load i32, i32* %19, align 4
  %436 = mul nsw i32 %435, 4
  %437 = load i32, i32* %20, align 4
  %438 = add nsw i32 %436, %437
  %439 = sext i32 %438 to i64
  %440 = getelementptr inbounds float, float* %434, i64 %439
  %441 = load float, float* %440, align 4
  store float %441, float* %21, align 4
  %442 = load float*, float** %18, align 8
  %443 = load i32, i32* %20, align 4
  %444 = mul nsw i32 %443, 4
  %445 = load i32, i32* %19, align 4
  %446 = add nsw i32 %444, %445
  %447 = sext i32 %446 to i64
  %448 = getelementptr inbounds float, float* %442, i64 %447
  %449 = load float, float* %448, align 4
  %450 = load float*, float** %18, align 8
  %451 = load i32, i32* %19, align 4
  %452 = mul nsw i32 %451, 4
  %453 = load i32, i32* %20, align 4
  %454 = add nsw i32 %452, %453
  %455 = sext i32 %454 to i64
  %456 = getelementptr inbounds float, float* %450, i64 %455
  store float %449, float* %456, align 4
  %457 = load float, float* %21, align 4
  %458 = load float*, float** %18, align 8
  %459 = load i32, i32* %20, align 4
  %460 = mul nsw i32 %459, 4
  %461 = load i32, i32* %19, align 4
  %462 = add nsw i32 %460, %461
  %463 = sext i32 %462 to i64
  %464 = getelementptr inbounds float, float* %458, i64 %463
  store float %457, float* %464, align 4
  %465 = load i32, i32* %20, align 4
  %466 = add nsw i32 %465, 1
  store i32 %466, i32* %20, align 4
  br label %430

467:                                              ; preds = %430
  %468 = load i32, i32* %19, align 4
  %469 = add nsw i32 %468, 1
  store i32 %469, i32* %19, align 4
  br label %424

470:                                              ; preds = %424
  ret void
}

; Function Attrs: nounwind
declare i8* @__memcpy_chk(i8*, i8*, i64, i64) #3

; Function Attrs: nounwind readnone speculatable willreturn
declare i64 @llvm.objectsize.i64.p0i8(i8*, i1 immarg, i1 immarg, i1 immarg) #1

; Function Attrs: allocsize(0,1)
declare i8* @calloc(i64, i64) #4

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #2 {
  %1 = alloca [16 x float], align 16
  %2 = alloca [16 x float], align 16
  %3 = alloca [16 x float], align 16
  %4 = bitcast [16 x float]* %1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %4, i8* align 16 bitcast ([16 x float]* @__const.main.A to i8*), i64 64, i1 false)
  %5 = bitcast [16 x float]* %2 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %5, i8 0, i64 64, i1 false)
  %6 = bitcast [16 x float]* %3 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %6, i8 0, i64 64, i1 false)
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #5

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #6

attributes #0 = { alwaysinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable willreturn }
attributes #2 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { allocsize(0,1) "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { argmemonly nounwind willreturn }
attributes #6 = { argmemonly nounwind willreturn writeonly }
attributes #7 = { nounwind }
attributes #8 = { allocsize(0,1) }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
