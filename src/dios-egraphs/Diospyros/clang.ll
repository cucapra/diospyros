; ModuleID = 'llvm-tests/qr-decomp-fixed-size.c'
source_filename = "llvm-tests/qr-decomp-fixed-size.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.A = private unnamed_addr constant [16 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00, float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00, float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00, float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00], align 16
@.str = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1

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
  %28 = call float @llvm.sqrt.f32(float %27)
  ret float %28
}

; Function Attrs: nounwind readnone speculatable willreturn
declare double @llvm.pow.f64(double, double) #1

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32(float) #1

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
  %19 = alloca float*, align 8
  %20 = alloca float*, align 8
  %21 = alloca i32, align 4
  %22 = alloca i32, align 4
  %23 = alloca i32, align 4
  %24 = alloca float*, align 8
  %25 = alloca float*, align 8
  %26 = alloca float*, align 8
  %27 = alloca i32, align 4
  %28 = alloca i32, align 4
  %29 = alloca i32, align 4
  %30 = alloca float*, align 8
  %31 = alloca i32, align 4
  %32 = alloca i32, align 4
  %33 = alloca float, align 4
  %34 = alloca float, align 4
  %35 = alloca float*, align 8
  %36 = alloca float*, align 8
  %37 = alloca float*, align 8
  %38 = alloca float*, align 8
  %39 = alloca i32, align 4
  %40 = alloca i32, align 4
  %41 = alloca i32, align 4
  %42 = alloca i32, align 4
  %43 = alloca float*, align 8
  %44 = alloca float*, align 8
  %45 = alloca i32, align 4
  %46 = alloca i32, align 4
  %47 = alloca float, align 4
  %48 = alloca float*, align 8
  %49 = alloca float*, align 8
  %50 = alloca i32, align 4
  %51 = alloca float, align 4
  %52 = alloca i32, align 4
  %53 = alloca float*, align 8
  %54 = alloca i32, align 4
  %55 = alloca i32, align 4
  %56 = alloca float, align 4
  %57 = alloca float*, align 8
  %58 = alloca i32, align 4
  %59 = alloca i32, align 4
  %60 = alloca float, align 4
  %61 = alloca float*, align 8
  store float* %0, float** %35, align 8
  store float* %1, float** %36, align 8
  store float* %2, float** %37, align 8
  %62 = load float*, float** %37, align 8
  %63 = bitcast float* %62 to i8*
  %64 = load float*, float** %35, align 8
  %65 = bitcast float* %64 to i8*
  %66 = load float*, float** %37, align 8
  %67 = bitcast float* %66 to i8*
  %68 = call i64 @llvm.objectsize.i64.p0i8(i8* %67, i1 false, i1 true, i1 false)
  %69 = call i8* @__memcpy_chk(i8* %63, i8* %65, i64 64, i64 %68) #8
  %70 = call i8* @calloc(i64 4, i64 16) #9
  %71 = bitcast i8* %70 to float*
  store float* %71, float** %38, align 8
  store i32 0, i32* %39, align 4
  br label %72

72:                                               ; preds = %96, %3
  %73 = load i32, i32* %39, align 4
  %74 = icmp slt i32 %73, 4
  br i1 %74, label %75, label %99

75:                                               ; preds = %72
  store i32 0, i32* %40, align 4
  br label %76

76:                                               ; preds = %92, %75
  %77 = load i32, i32* %40, align 4
  %78 = icmp slt i32 %77, 4
  br i1 %78, label %79, label %95

79:                                               ; preds = %76
  %80 = load i32, i32* %39, align 4
  %81 = load i32, i32* %40, align 4
  %82 = icmp eq i32 %80, %81
  %83 = zext i1 %82 to i32
  %84 = sitofp i32 %83 to float
  %85 = load float*, float** %38, align 8
  %86 = load i32, i32* %39, align 4
  %87 = mul nsw i32 %86, 4
  %88 = load i32, i32* %40, align 4
  %89 = add nsw i32 %87, %88
  %90 = sext i32 %89 to i64
  %91 = getelementptr inbounds float, float* %85, i64 %90
  store float %84, float* %91, align 4
  br label %92

92:                                               ; preds = %79
  %93 = load i32, i32* %40, align 4
  %94 = add nsw i32 %93, 1
  store i32 %94, i32* %40, align 4
  br label %76

95:                                               ; preds = %76
  br label %96

96:                                               ; preds = %95
  %97 = load i32, i32* %39, align 4
  %98 = add nsw i32 %97, 1
  store i32 %98, i32* %39, align 4
  br label %72

99:                                               ; preds = %72
  store i32 0, i32* %41, align 4
  br label %100

100:                                              ; preds = %582, %99
  %101 = load i32, i32* %41, align 4
  %102 = icmp slt i32 %101, 3
  br i1 %102, label %103, label %585

103:                                              ; preds = %100
  %104 = load i32, i32* %41, align 4
  %105 = sub nsw i32 4, %104
  store i32 %105, i32* %42, align 4
  %106 = load i32, i32* %42, align 4
  %107 = sext i32 %106 to i64
  %108 = call i8* @calloc(i64 4, i64 %107) #9
  %109 = bitcast i8* %108 to float*
  store float* %109, float** %43, align 8
  %110 = load i32, i32* %42, align 4
  %111 = sext i32 %110 to i64
  %112 = call i8* @calloc(i64 4, i64 %111) #9
  %113 = bitcast i8* %112 to float*
  store float* %113, float** %44, align 8
  store i32 0, i32* %45, align 4
  br label %114

114:                                              ; preds = %146, %103
  %115 = load i32, i32* %45, align 4
  %116 = load i32, i32* %42, align 4
  %117 = icmp slt i32 %115, %116
  br i1 %117, label %118, label %149

118:                                              ; preds = %114
  %119 = load i32, i32* %41, align 4
  %120 = load i32, i32* %45, align 4
  %121 = add nsw i32 %119, %120
  store i32 %121, i32* %46, align 4
  %122 = load float*, float** %37, align 8
  %123 = load i32, i32* %46, align 4
  %124 = mul nsw i32 %123, 4
  %125 = load i32, i32* %41, align 4
  %126 = add nsw i32 %124, %125
  %127 = sext i32 %126 to i64
  %128 = getelementptr inbounds float, float* %122, i64 %127
  %129 = load float, float* %128, align 4
  %130 = load float*, float** %43, align 8
  %131 = load i32, i32* %45, align 4
  %132 = sext i32 %131 to i64
  %133 = getelementptr inbounds float, float* %130, i64 %132
  store float %129, float* %133, align 4
  %134 = load float*, float** %38, align 8
  %135 = load i32, i32* %46, align 4
  %136 = mul nsw i32 %135, 4
  %137 = load i32, i32* %41, align 4
  %138 = add nsw i32 %136, %137
  %139 = sext i32 %138 to i64
  %140 = getelementptr inbounds float, float* %134, i64 %139
  %141 = load float, float* %140, align 4
  %142 = load float*, float** %44, align 8
  %143 = load i32, i32* %45, align 4
  %144 = sext i32 %143 to i64
  %145 = getelementptr inbounds float, float* %142, i64 %144
  store float %141, float* %145, align 4
  br label %146

146:                                              ; preds = %118
  %147 = load i32, i32* %45, align 4
  %148 = add nsw i32 %147, 1
  store i32 %148, i32* %45, align 4
  br label %114

149:                                              ; preds = %114
  %150 = load float*, float** %43, align 8
  %151 = getelementptr inbounds float, float* %150, i64 0
  %152 = load float, float* %151, align 4
  store float %152, float* %34, align 4
  %153 = load float, float* %34, align 4
  %154 = fcmp ogt float %153, 0.000000e+00
  %155 = zext i1 %154 to i32
  %156 = load float, float* %34, align 4
  %157 = fcmp olt float %156, 0.000000e+00
  %158 = zext i1 %157 to i32
  %159 = sub nsw i32 %155, %158
  %160 = sitofp i32 %159 to float
  %161 = fneg float %160
  %162 = load float*, float** %43, align 8
  %163 = load i32, i32* %42, align 4
  store float* %162, float** %4, align 8
  store i32 %163, i32* %5, align 4
  store float 0.000000e+00, float* %6, align 4
  store i32 0, i32* %7, align 4
  br label %164

164:                                              ; preds = %168, %149
  %165 = load i32, i32* %7, align 4
  %166 = load i32, i32* %5, align 4
  %167 = icmp slt i32 %165, %166
  br i1 %167, label %168, label %182

168:                                              ; preds = %164
  %169 = load float*, float** %4, align 8
  %170 = load i32, i32* %7, align 4
  %171 = sext i32 %170 to i64
  %172 = getelementptr inbounds float, float* %169, i64 %171
  %173 = load float, float* %172, align 4
  %174 = fpext float %173 to double
  %175 = call double @llvm.pow.f64(double %174, double 2.000000e+00) #8
  %176 = load float, float* %6, align 4
  %177 = fpext float %176 to double
  %178 = fadd double %177, %175
  %179 = fptrunc double %178 to float
  store float %179, float* %6, align 4
  %180 = load i32, i32* %7, align 4
  %181 = add nsw i32 %180, 1
  store i32 %181, i32* %7, align 4
  br label %164

182:                                              ; preds = %164
  %183 = load float, float* %6, align 4
  %184 = call float @llvm.sqrt.f32(float %183) #8
  %185 = fmul float %161, %184
  store float %185, float* %47, align 4
  %186 = load i32, i32* %42, align 4
  %187 = sext i32 %186 to i64
  %188 = call i8* @calloc(i64 4, i64 %187) #9
  %189 = bitcast i8* %188 to float*
  store float* %189, float** %48, align 8
  %190 = load i32, i32* %42, align 4
  %191 = sext i32 %190 to i64
  %192 = call i8* @calloc(i64 4, i64 %191) #9
  %193 = bitcast i8* %192 to float*
  store float* %193, float** %49, align 8
  store i32 0, i32* %50, align 4
  br label %194

194:                                              ; preds = %216, %182
  %195 = load i32, i32* %50, align 4
  %196 = load i32, i32* %42, align 4
  %197 = icmp slt i32 %195, %196
  br i1 %197, label %198, label %219

198:                                              ; preds = %194
  %199 = load float*, float** %43, align 8
  %200 = load i32, i32* %50, align 4
  %201 = sext i32 %200 to i64
  %202 = getelementptr inbounds float, float* %199, i64 %201
  %203 = load float, float* %202, align 4
  %204 = load float, float* %47, align 4
  %205 = load float*, float** %44, align 8
  %206 = load i32, i32* %50, align 4
  %207 = sext i32 %206 to i64
  %208 = getelementptr inbounds float, float* %205, i64 %207
  %209 = load float, float* %208, align 4
  %210 = fmul float %204, %209
  %211 = fadd float %203, %210
  %212 = load float*, float** %48, align 8
  %213 = load i32, i32* %50, align 4
  %214 = sext i32 %213 to i64
  %215 = getelementptr inbounds float, float* %212, i64 %214
  store float %211, float* %215, align 4
  br label %216

216:                                              ; preds = %198
  %217 = load i32, i32* %50, align 4
  %218 = add nsw i32 %217, 1
  store i32 %218, i32* %50, align 4
  br label %194

219:                                              ; preds = %194
  %220 = load float*, float** %48, align 8
  %221 = load i32, i32* %42, align 4
  store float* %220, float** %8, align 8
  store i32 %221, i32* %9, align 4
  store float 0.000000e+00, float* %10, align 4
  store i32 0, i32* %11, align 4
  br label %222

222:                                              ; preds = %226, %219
  %223 = load i32, i32* %11, align 4
  %224 = load i32, i32* %9, align 4
  %225 = icmp slt i32 %223, %224
  br i1 %225, label %226, label %240

226:                                              ; preds = %222
  %227 = load float*, float** %8, align 8
  %228 = load i32, i32* %11, align 4
  %229 = sext i32 %228 to i64
  %230 = getelementptr inbounds float, float* %227, i64 %229
  %231 = load float, float* %230, align 4
  %232 = fpext float %231 to double
  %233 = call double @llvm.pow.f64(double %232, double 2.000000e+00) #8
  %234 = load float, float* %10, align 4
  %235 = fpext float %234 to double
  %236 = fadd double %235, %233
  %237 = fptrunc double %236 to float
  store float %237, float* %10, align 4
  %238 = load i32, i32* %11, align 4
  %239 = add nsw i32 %238, 1
  store i32 %239, i32* %11, align 4
  br label %222

240:                                              ; preds = %222
  %241 = load float, float* %10, align 4
  %242 = call float @llvm.sqrt.f32(float %241) #8
  store float %242, float* %51, align 4
  store i32 0, i32* %52, align 4
  br label %243

243:                                              ; preds = %259, %240
  %244 = load i32, i32* %52, align 4
  %245 = load i32, i32* %42, align 4
  %246 = icmp slt i32 %244, %245
  br i1 %246, label %247, label %262

247:                                              ; preds = %243
  %248 = load float*, float** %48, align 8
  %249 = load i32, i32* %52, align 4
  %250 = sext i32 %249 to i64
  %251 = getelementptr inbounds float, float* %248, i64 %250
  %252 = load float, float* %251, align 4
  %253 = load float, float* %51, align 4
  %254 = fdiv float %252, %253
  %255 = load float*, float** %49, align 8
  %256 = load i32, i32* %52, align 4
  %257 = sext i32 %256 to i64
  %258 = getelementptr inbounds float, float* %255, i64 %257
  store float %254, float* %258, align 4
  br label %259

259:                                              ; preds = %247
  %260 = load i32, i32* %52, align 4
  %261 = add nsw i32 %260, 1
  store i32 %261, i32* %52, align 4
  br label %243

262:                                              ; preds = %243
  %263 = load i32, i32* %42, align 4
  %264 = load i32, i32* %42, align 4
  %265 = mul nsw i32 %263, %264
  %266 = sext i32 %265 to i64
  %267 = call i8* @calloc(i64 4, i64 %266) #9
  %268 = bitcast i8* %267 to float*
  store float* %268, float** %53, align 8
  store i32 0, i32* %54, align 4
  br label %269

269:                                              ; preds = %310, %262
  %270 = load i32, i32* %54, align 4
  %271 = load i32, i32* %42, align 4
  %272 = icmp slt i32 %270, %271
  br i1 %272, label %273, label %313

273:                                              ; preds = %269
  store i32 0, i32* %55, align 4
  br label %274

274:                                              ; preds = %306, %273
  %275 = load i32, i32* %55, align 4
  %276 = load i32, i32* %42, align 4
  %277 = icmp slt i32 %275, %276
  br i1 %277, label %278, label %309

278:                                              ; preds = %274
  %279 = load i32, i32* %54, align 4
  %280 = load i32, i32* %55, align 4
  %281 = icmp eq i32 %279, %280
  %282 = zext i1 %281 to i64
  %283 = select i1 %281, float 1.000000e+00, float 0.000000e+00
  %284 = load float*, float** %49, align 8
  %285 = load i32, i32* %54, align 4
  %286 = sext i32 %285 to i64
  %287 = getelementptr inbounds float, float* %284, i64 %286
  %288 = load float, float* %287, align 4
  %289 = fmul float 2.000000e+00, %288
  %290 = load float*, float** %49, align 8
  %291 = load i32, i32* %55, align 4
  %292 = sext i32 %291 to i64
  %293 = getelementptr inbounds float, float* %290, i64 %292
  %294 = load float, float* %293, align 4
  %295 = fmul float %289, %294
  %296 = fsub float %283, %295
  store float %296, float* %56, align 4
  %297 = load float, float* %56, align 4
  %298 = load float*, float** %53, align 8
  %299 = load i32, i32* %54, align 4
  %300 = load i32, i32* %42, align 4
  %301 = mul nsw i32 %299, %300
  %302 = load i32, i32* %55, align 4
  %303 = add nsw i32 %301, %302
  %304 = sext i32 %303 to i64
  %305 = getelementptr inbounds float, float* %298, i64 %304
  store float %297, float* %305, align 4
  br label %306

306:                                              ; preds = %278
  %307 = load i32, i32* %55, align 4
  %308 = add nsw i32 %307, 1
  store i32 %308, i32* %55, align 4
  br label %274

309:                                              ; preds = %274
  br label %310

310:                                              ; preds = %309
  %311 = load i32, i32* %54, align 4
  %312 = add nsw i32 %311, 1
  store i32 %312, i32* %54, align 4
  br label %269

313:                                              ; preds = %269
  %314 = call i8* @calloc(i64 4, i64 16) #9
  %315 = bitcast i8* %314 to float*
  store float* %315, float** %57, align 8
  store i32 0, i32* %58, align 4
  br label %316

316:                                              ; preds = %364, %313
  %317 = load i32, i32* %58, align 4
  %318 = icmp slt i32 %317, 4
  br i1 %318, label %319, label %367

319:                                              ; preds = %316
  store i32 0, i32* %59, align 4
  br label %320

320:                                              ; preds = %360, %319
  %321 = load i32, i32* %59, align 4
  %322 = icmp slt i32 %321, 4
  br i1 %322, label %323, label %363

323:                                              ; preds = %320
  %324 = load i32, i32* %58, align 4
  %325 = load i32, i32* %41, align 4
  %326 = icmp slt i32 %324, %325
  br i1 %326, label %331, label %327

327:                                              ; preds = %323
  %328 = load i32, i32* %59, align 4
  %329 = load i32, i32* %41, align 4
  %330 = icmp slt i32 %328, %329
  br i1 %330, label %331, label %337

331:                                              ; preds = %327, %323
  %332 = load i32, i32* %58, align 4
  %333 = load i32, i32* %59, align 4
  %334 = icmp eq i32 %332, %333
  %335 = zext i1 %334 to i64
  %336 = select i1 %334, float 1.000000e+00, float 0.000000e+00
  store float %336, float* %60, align 4
  br label %351

337:                                              ; preds = %327
  %338 = load float*, float** %53, align 8
  %339 = load i32, i32* %58, align 4
  %340 = load i32, i32* %41, align 4
  %341 = sub nsw i32 %339, %340
  %342 = load i32, i32* %42, align 4
  %343 = mul nsw i32 %341, %342
  %344 = load i32, i32* %59, align 4
  %345 = load i32, i32* %41, align 4
  %346 = sub nsw i32 %344, %345
  %347 = add nsw i32 %343, %346
  %348 = sext i32 %347 to i64
  %349 = getelementptr inbounds float, float* %338, i64 %348
  %350 = load float, float* %349, align 4
  store float %350, float* %60, align 4
  br label %351

351:                                              ; preds = %337, %331
  %352 = load float, float* %60, align 4
  %353 = load float*, float** %57, align 8
  %354 = load i32, i32* %58, align 4
  %355 = mul nsw i32 %354, 4
  %356 = load i32, i32* %59, align 4
  %357 = add nsw i32 %355, %356
  %358 = sext i32 %357 to i64
  %359 = getelementptr inbounds float, float* %353, i64 %358
  store float %352, float* %359, align 4
  br label %360

360:                                              ; preds = %351
  %361 = load i32, i32* %59, align 4
  %362 = add nsw i32 %361, 1
  store i32 %362, i32* %59, align 4
  br label %320

363:                                              ; preds = %320
  br label %364

364:                                              ; preds = %363
  %365 = load i32, i32* %58, align 4
  %366 = add nsw i32 %365, 1
  store i32 %366, i32* %58, align 4
  br label %316

367:                                              ; preds = %316
  %368 = load i32, i32* %41, align 4
  %369 = icmp eq i32 %368, 0
  br i1 %369, label %370, label %436

370:                                              ; preds = %367
  %371 = load float*, float** %36, align 8
  %372 = bitcast float* %371 to i8*
  %373 = load float*, float** %57, align 8
  %374 = bitcast float* %373 to i8*
  %375 = load float*, float** %36, align 8
  %376 = bitcast float* %375 to i8*
  %377 = call i64 @llvm.objectsize.i64.p0i8(i8* %376, i1 false, i1 true, i1 false)
  %378 = call i8* @__memcpy_chk(i8* %372, i8* %374, i64 64, i64 %377) #8
  %379 = load float*, float** %57, align 8
  %380 = load float*, float** %35, align 8
  %381 = load float*, float** %37, align 8
  store float* %379, float** %12, align 8
  store float* %380, float** %13, align 8
  store float* %381, float** %14, align 8
  store i32 0, i32* %15, align 4
  br label %382

382:                                              ; preds = %432, %370
  %383 = load i32, i32* %15, align 4
  %384 = icmp slt i32 %383, 4
  br i1 %384, label %385, label %435

385:                                              ; preds = %382
  store i32 0, i32* %16, align 4
  br label %386

386:                                              ; preds = %429, %385
  %387 = load i32, i32* %16, align 4
  %388 = icmp slt i32 %387, 4
  br i1 %388, label %389, label %432

389:                                              ; preds = %386
  %390 = load float*, float** %14, align 8
  %391 = load i32, i32* %15, align 4
  %392 = mul nsw i32 4, %391
  %393 = load i32, i32* %16, align 4
  %394 = add nsw i32 %392, %393
  %395 = sext i32 %394 to i64
  %396 = getelementptr inbounds float, float* %390, i64 %395
  store float 0.000000e+00, float* %396, align 4
  store i32 0, i32* %17, align 4
  br label %397

397:                                              ; preds = %400, %389
  %398 = load i32, i32* %17, align 4
  %399 = icmp slt i32 %398, 4
  br i1 %399, label %400, label %429

400:                                              ; preds = %397
  %401 = load float*, float** %12, align 8
  %402 = load i32, i32* %15, align 4
  %403 = mul nsw i32 4, %402
  %404 = load i32, i32* %17, align 4
  %405 = add nsw i32 %403, %404
  %406 = sext i32 %405 to i64
  %407 = getelementptr inbounds float, float* %401, i64 %406
  %408 = load float, float* %407, align 4
  %409 = load float*, float** %13, align 8
  %410 = load i32, i32* %17, align 4
  %411 = mul nsw i32 4, %410
  %412 = load i32, i32* %16, align 4
  %413 = add nsw i32 %411, %412
  %414 = sext i32 %413 to i64
  %415 = getelementptr inbounds float, float* %409, i64 %414
  %416 = load float, float* %415, align 4
  %417 = fmul float %408, %416
  %418 = load float*, float** %14, align 8
  %419 = load i32, i32* %15, align 4
  %420 = mul nsw i32 4, %419
  %421 = load i32, i32* %16, align 4
  %422 = add nsw i32 %420, %421
  %423 = sext i32 %422 to i64
  %424 = getelementptr inbounds float, float* %418, i64 %423
  %425 = load float, float* %424, align 4
  %426 = fadd float %425, %417
  store float %426, float* %424, align 4
  %427 = load i32, i32* %17, align 4
  %428 = add nsw i32 %427, 1
  store i32 %428, i32* %17, align 4
  br label %397

429:                                              ; preds = %397
  %430 = load i32, i32* %16, align 4
  %431 = add nsw i32 %430, 1
  store i32 %431, i32* %16, align 4
  br label %386

432:                                              ; preds = %386
  %433 = load i32, i32* %15, align 4
  %434 = add nsw i32 %433, 1
  store i32 %434, i32* %15, align 4
  br label %382

435:                                              ; preds = %382
  br label %569

436:                                              ; preds = %367
  %437 = call i8* @calloc(i64 4, i64 16) #9
  %438 = bitcast i8* %437 to float*
  store float* %438, float** %61, align 8
  %439 = load float*, float** %57, align 8
  %440 = load float*, float** %36, align 8
  %441 = load float*, float** %61, align 8
  store float* %439, float** %18, align 8
  store float* %440, float** %19, align 8
  store float* %441, float** %20, align 8
  store i32 0, i32* %21, align 4
  br label %442

442:                                              ; preds = %492, %436
  %443 = load i32, i32* %21, align 4
  %444 = icmp slt i32 %443, 4
  br i1 %444, label %445, label %495

445:                                              ; preds = %442
  store i32 0, i32* %22, align 4
  br label %446

446:                                              ; preds = %489, %445
  %447 = load i32, i32* %22, align 4
  %448 = icmp slt i32 %447, 4
  br i1 %448, label %449, label %492

449:                                              ; preds = %446
  %450 = load float*, float** %20, align 8
  %451 = load i32, i32* %21, align 4
  %452 = mul nsw i32 4, %451
  %453 = load i32, i32* %22, align 4
  %454 = add nsw i32 %452, %453
  %455 = sext i32 %454 to i64
  %456 = getelementptr inbounds float, float* %450, i64 %455
  store float 0.000000e+00, float* %456, align 4
  store i32 0, i32* %23, align 4
  br label %457

457:                                              ; preds = %460, %449
  %458 = load i32, i32* %23, align 4
  %459 = icmp slt i32 %458, 4
  br i1 %459, label %460, label %489

460:                                              ; preds = %457
  %461 = load float*, float** %18, align 8
  %462 = load i32, i32* %21, align 4
  %463 = mul nsw i32 4, %462
  %464 = load i32, i32* %23, align 4
  %465 = add nsw i32 %463, %464
  %466 = sext i32 %465 to i64
  %467 = getelementptr inbounds float, float* %461, i64 %466
  %468 = load float, float* %467, align 4
  %469 = load float*, float** %19, align 8
  %470 = load i32, i32* %23, align 4
  %471 = mul nsw i32 4, %470
  %472 = load i32, i32* %22, align 4
  %473 = add nsw i32 %471, %472
  %474 = sext i32 %473 to i64
  %475 = getelementptr inbounds float, float* %469, i64 %474
  %476 = load float, float* %475, align 4
  %477 = fmul float %468, %476
  %478 = load float*, float** %20, align 8
  %479 = load i32, i32* %21, align 4
  %480 = mul nsw i32 4, %479
  %481 = load i32, i32* %22, align 4
  %482 = add nsw i32 %480, %481
  %483 = sext i32 %482 to i64
  %484 = getelementptr inbounds float, float* %478, i64 %483
  %485 = load float, float* %484, align 4
  %486 = fadd float %485, %477
  store float %486, float* %484, align 4
  %487 = load i32, i32* %23, align 4
  %488 = add nsw i32 %487, 1
  store i32 %488, i32* %23, align 4
  br label %457

489:                                              ; preds = %457
  %490 = load i32, i32* %22, align 4
  %491 = add nsw i32 %490, 1
  store i32 %491, i32* %22, align 4
  br label %446

492:                                              ; preds = %446
  %493 = load i32, i32* %21, align 4
  %494 = add nsw i32 %493, 1
  store i32 %494, i32* %21, align 4
  br label %442

495:                                              ; preds = %442
  %496 = load float*, float** %36, align 8
  %497 = bitcast float* %496 to i8*
  %498 = load float*, float** %61, align 8
  %499 = bitcast float* %498 to i8*
  %500 = load float*, float** %36, align 8
  %501 = bitcast float* %500 to i8*
  %502 = call i64 @llvm.objectsize.i64.p0i8(i8* %501, i1 false, i1 true, i1 false)
  %503 = call i8* @__memcpy_chk(i8* %497, i8* %499, i64 64, i64 %502) #8
  %504 = load float*, float** %57, align 8
  %505 = load float*, float** %37, align 8
  %506 = load float*, float** %61, align 8
  store float* %504, float** %24, align 8
  store float* %505, float** %25, align 8
  store float* %506, float** %26, align 8
  store i32 0, i32* %27, align 4
  br label %507

507:                                              ; preds = %557, %495
  %508 = load i32, i32* %27, align 4
  %509 = icmp slt i32 %508, 4
  br i1 %509, label %510, label %560

510:                                              ; preds = %507
  store i32 0, i32* %28, align 4
  br label %511

511:                                              ; preds = %554, %510
  %512 = load i32, i32* %28, align 4
  %513 = icmp slt i32 %512, 4
  br i1 %513, label %514, label %557

514:                                              ; preds = %511
  %515 = load float*, float** %26, align 8
  %516 = load i32, i32* %27, align 4
  %517 = mul nsw i32 4, %516
  %518 = load i32, i32* %28, align 4
  %519 = add nsw i32 %517, %518
  %520 = sext i32 %519 to i64
  %521 = getelementptr inbounds float, float* %515, i64 %520
  store float 0.000000e+00, float* %521, align 4
  store i32 0, i32* %29, align 4
  br label %522

522:                                              ; preds = %525, %514
  %523 = load i32, i32* %29, align 4
  %524 = icmp slt i32 %523, 4
  br i1 %524, label %525, label %554

525:                                              ; preds = %522
  %526 = load float*, float** %24, align 8
  %527 = load i32, i32* %27, align 4
  %528 = mul nsw i32 4, %527
  %529 = load i32, i32* %29, align 4
  %530 = add nsw i32 %528, %529
  %531 = sext i32 %530 to i64
  %532 = getelementptr inbounds float, float* %526, i64 %531
  %533 = load float, float* %532, align 4
  %534 = load float*, float** %25, align 8
  %535 = load i32, i32* %29, align 4
  %536 = mul nsw i32 4, %535
  %537 = load i32, i32* %28, align 4
  %538 = add nsw i32 %536, %537
  %539 = sext i32 %538 to i64
  %540 = getelementptr inbounds float, float* %534, i64 %539
  %541 = load float, float* %540, align 4
  %542 = fmul float %533, %541
  %543 = load float*, float** %26, align 8
  %544 = load i32, i32* %27, align 4
  %545 = mul nsw i32 4, %544
  %546 = load i32, i32* %28, align 4
  %547 = add nsw i32 %545, %546
  %548 = sext i32 %547 to i64
  %549 = getelementptr inbounds float, float* %543, i64 %548
  %550 = load float, float* %549, align 4
  %551 = fadd float %550, %542
  store float %551, float* %549, align 4
  %552 = load i32, i32* %29, align 4
  %553 = add nsw i32 %552, 1
  store i32 %553, i32* %29, align 4
  br label %522

554:                                              ; preds = %522
  %555 = load i32, i32* %28, align 4
  %556 = add nsw i32 %555, 1
  store i32 %556, i32* %28, align 4
  br label %511

557:                                              ; preds = %511
  %558 = load i32, i32* %27, align 4
  %559 = add nsw i32 %558, 1
  store i32 %559, i32* %27, align 4
  br label %507

560:                                              ; preds = %507
  %561 = load float*, float** %37, align 8
  %562 = bitcast float* %561 to i8*
  %563 = load float*, float** %61, align 8
  %564 = bitcast float* %563 to i8*
  %565 = load float*, float** %37, align 8
  %566 = bitcast float* %565 to i8*
  %567 = call i64 @llvm.objectsize.i64.p0i8(i8* %566, i1 false, i1 true, i1 false)
  %568 = call i8* @__memcpy_chk(i8* %562, i8* %564, i64 64, i64 %567) #8
  br label %569

569:                                              ; preds = %560, %435
  %570 = load float*, float** %43, align 8
  %571 = bitcast float* %570 to i8*
  call void @free(i8* %571)
  %572 = load float*, float** %44, align 8
  %573 = bitcast float* %572 to i8*
  call void @free(i8* %573)
  %574 = load float*, float** %48, align 8
  %575 = bitcast float* %574 to i8*
  call void @free(i8* %575)
  %576 = load float*, float** %49, align 8
  %577 = bitcast float* %576 to i8*
  call void @free(i8* %577)
  %578 = load float*, float** %53, align 8
  %579 = bitcast float* %578 to i8*
  call void @free(i8* %579)
  %580 = load float*, float** %57, align 8
  %581 = bitcast float* %580 to i8*
  call void @free(i8* %581)
  br label %582

582:                                              ; preds = %569
  %583 = load i32, i32* %41, align 4
  %584 = add nsw i32 %583, 1
  store i32 %584, i32* %41, align 4
  br label %100

585:                                              ; preds = %100
  %586 = load float*, float** %36, align 8
  store float* %586, float** %30, align 8
  store i32 0, i32* %31, align 4
  br label %587

587:                                              ; preds = %630, %585
  %588 = load i32, i32* %31, align 4
  %589 = icmp slt i32 %588, 4
  br i1 %589, label %590, label %633

590:                                              ; preds = %587
  %591 = load i32, i32* %31, align 4
  %592 = add nsw i32 %591, 1
  store i32 %592, i32* %32, align 4
  br label %593

593:                                              ; preds = %596, %590
  %594 = load i32, i32* %32, align 4
  %595 = icmp slt i32 %594, 4
  br i1 %595, label %596, label %630

596:                                              ; preds = %593
  %597 = load float*, float** %30, align 8
  %598 = load i32, i32* %31, align 4
  %599 = mul nsw i32 %598, 4
  %600 = load i32, i32* %32, align 4
  %601 = add nsw i32 %599, %600
  %602 = sext i32 %601 to i64
  %603 = getelementptr inbounds float, float* %597, i64 %602
  %604 = load float, float* %603, align 4
  store float %604, float* %33, align 4
  %605 = load float*, float** %30, align 8
  %606 = load i32, i32* %32, align 4
  %607 = mul nsw i32 %606, 4
  %608 = load i32, i32* %31, align 4
  %609 = add nsw i32 %607, %608
  %610 = sext i32 %609 to i64
  %611 = getelementptr inbounds float, float* %605, i64 %610
  %612 = load float, float* %611, align 4
  %613 = load float*, float** %30, align 8
  %614 = load i32, i32* %31, align 4
  %615 = mul nsw i32 %614, 4
  %616 = load i32, i32* %32, align 4
  %617 = add nsw i32 %615, %616
  %618 = sext i32 %617 to i64
  %619 = getelementptr inbounds float, float* %613, i64 %618
  store float %612, float* %619, align 4
  %620 = load float, float* %33, align 4
  %621 = load float*, float** %30, align 8
  %622 = load i32, i32* %32, align 4
  %623 = mul nsw i32 %622, 4
  %624 = load i32, i32* %31, align 4
  %625 = add nsw i32 %623, %624
  %626 = sext i32 %625 to i64
  %627 = getelementptr inbounds float, float* %621, i64 %626
  store float %620, float* %627, align 4
  %628 = load i32, i32* %32, align 4
  %629 = add nsw i32 %628, 1
  store i32 %629, i32* %32, align 4
  br label %593

630:                                              ; preds = %593
  %631 = load i32, i32* %31, align 4
  %632 = add nsw i32 %631, 1
  store i32 %632, i32* %31, align 4
  br label %587

633:                                              ; preds = %587
  ret void
}

; Function Attrs: nounwind
declare i8* @__memcpy_chk(i8*, i8*, i64, i64) #3

; Function Attrs: nounwind readnone speculatable willreturn
declare i64 @llvm.objectsize.i64.p0i8(i8*, i1 immarg, i1 immarg, i1 immarg) #1

; Function Attrs: allocsize(0,1)
declare i8* @calloc(i64, i64) #4

declare void @free(i8*) #5

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #2 {
  %1 = alloca i32, align 4
  %2 = alloca [16 x float], align 16
  %3 = alloca [16 x float], align 16
  %4 = alloca [16 x float], align 16
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  %7 = bitcast [16 x float]* %2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %7, i8* align 16 bitcast ([16 x float]* @__const.main.A to i8*), i64 64, i1 false)
  %8 = bitcast [16 x float]* %3 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %8, i8 0, i64 64, i1 false)
  %9 = bitcast [16 x float]* %4 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %9, i8 0, i64 64, i1 false)
  %10 = getelementptr inbounds [16 x float], [16 x float]* %2, i64 0, i64 0
  %11 = getelementptr inbounds [16 x float], [16 x float]* %3, i64 0, i64 0
  %12 = getelementptr inbounds [16 x float], [16 x float]* %4, i64 0, i64 0
  call void @naive_fixed_qr_decomp(float* %10, float* %11, float* %12)
  store i32 0, i32* %5, align 4
  br label %13

13:                                               ; preds = %34, %0
  %14 = load i32, i32* %5, align 4
  %15 = icmp slt i32 %14, 4
  br i1 %15, label %16, label %37

16:                                               ; preds = %13
  store i32 0, i32* %6, align 4
  br label %17

17:                                               ; preds = %30, %16
  %18 = load i32, i32* %6, align 4
  %19 = icmp slt i32 %18, 4
  br i1 %19, label %20, label %33

20:                                               ; preds = %17
  %21 = load i32, i32* %5, align 4
  %22 = mul nsw i32 %21, 4
  %23 = load i32, i32* %6, align 4
  %24 = add nsw i32 %22, %23
  %25 = sext i32 %24 to i64
  %26 = getelementptr inbounds [16 x float], [16 x float]* %2, i64 0, i64 %25
  %27 = load float, float* %26, align 4
  %28 = fpext float %27 to double
  %29 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %28)
  br label %30

30:                                               ; preds = %20
  %31 = load i32, i32* %6, align 4
  %32 = add nsw i32 %31, 1
  store i32 %32, i32* %6, align 4
  br label %17

33:                                               ; preds = %17
  br label %34

34:                                               ; preds = %33
  %35 = load i32, i32* %5, align 4
  %36 = add nsw i32 %35, 1
  store i32 %36, i32* %5, align 4
  br label %13

37:                                               ; preds = %13
  %38 = load i32, i32* %1, align 4
  ret i32 %38
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #6

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #7

declare i32 @printf(i8*, ...) #5

attributes #0 = { alwaysinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable willreturn }
attributes #2 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { allocsize(0,1) "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { argmemonly nounwind willreturn }
attributes #7 = { argmemonly nounwind willreturn writeonly }
attributes #8 = { nounwind }
attributes #9 = { allocsize(0,1) }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
