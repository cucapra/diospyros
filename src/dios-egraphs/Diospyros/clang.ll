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

100:                                              ; preds = %589, %99
  %101 = load i32, i32* %41, align 4
  %102 = icmp slt i32 %101, 3
  br i1 %102, label %103, label %592

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
  %184 = fpext float %183 to double
  %185 = call double @llvm.sqrt.f64(double %184) #8
  %186 = fptrunc double %185 to float
  %187 = fmul float %161, %186
  store float %187, float* %47, align 4
  %188 = load i32, i32* %42, align 4
  %189 = sext i32 %188 to i64
  %190 = call i8* @calloc(i64 4, i64 %189) #9
  %191 = bitcast i8* %190 to float*
  store float* %191, float** %48, align 8
  %192 = load i32, i32* %42, align 4
  %193 = sext i32 %192 to i64
  %194 = call i8* @calloc(i64 4, i64 %193) #9
  %195 = bitcast i8* %194 to float*
  store float* %195, float** %49, align 8
  store i32 0, i32* %50, align 4
  br label %196

196:                                              ; preds = %218, %182
  %197 = load i32, i32* %50, align 4
  %198 = load i32, i32* %42, align 4
  %199 = icmp slt i32 %197, %198
  br i1 %199, label %200, label %221

200:                                              ; preds = %196
  %201 = load float*, float** %43, align 8
  %202 = load i32, i32* %50, align 4
  %203 = sext i32 %202 to i64
  %204 = getelementptr inbounds float, float* %201, i64 %203
  %205 = load float, float* %204, align 4
  %206 = load float, float* %47, align 4
  %207 = load float*, float** %44, align 8
  %208 = load i32, i32* %50, align 4
  %209 = sext i32 %208 to i64
  %210 = getelementptr inbounds float, float* %207, i64 %209
  %211 = load float, float* %210, align 4
  %212 = fmul float %206, %211
  %213 = fadd float %205, %212
  %214 = load float*, float** %48, align 8
  %215 = load i32, i32* %50, align 4
  %216 = sext i32 %215 to i64
  %217 = getelementptr inbounds float, float* %214, i64 %216
  store float %213, float* %217, align 4
  br label %218

218:                                              ; preds = %200
  %219 = load i32, i32* %50, align 4
  %220 = add nsw i32 %219, 1
  store i32 %220, i32* %50, align 4
  br label %196

221:                                              ; preds = %196
  %222 = load float*, float** %48, align 8
  %223 = load i32, i32* %42, align 4
  store float* %222, float** %8, align 8
  store i32 %223, i32* %9, align 4
  store float 0.000000e+00, float* %10, align 4
  store i32 0, i32* %11, align 4
  br label %224

224:                                              ; preds = %228, %221
  %225 = load i32, i32* %11, align 4
  %226 = load i32, i32* %9, align 4
  %227 = icmp slt i32 %225, %226
  br i1 %227, label %228, label %242

228:                                              ; preds = %224
  %229 = load float*, float** %8, align 8
  %230 = load i32, i32* %11, align 4
  %231 = sext i32 %230 to i64
  %232 = getelementptr inbounds float, float* %229, i64 %231
  %233 = load float, float* %232, align 4
  %234 = fpext float %233 to double
  %235 = call double @llvm.pow.f64(double %234, double 2.000000e+00) #8
  %236 = load float, float* %10, align 4
  %237 = fpext float %236 to double
  %238 = fadd double %237, %235
  %239 = fptrunc double %238 to float
  store float %239, float* %10, align 4
  %240 = load i32, i32* %11, align 4
  %241 = add nsw i32 %240, 1
  store i32 %241, i32* %11, align 4
  br label %224

242:                                              ; preds = %224
  %243 = load float, float* %10, align 4
  %244 = fpext float %243 to double
  %245 = call double @llvm.sqrt.f64(double %244) #8
  %246 = fptrunc double %245 to float
  store float %246, float* %51, align 4
  store i32 0, i32* %52, align 4
  br label %247

247:                                              ; preds = %263, %242
  %248 = load i32, i32* %52, align 4
  %249 = load i32, i32* %42, align 4
  %250 = icmp slt i32 %248, %249
  br i1 %250, label %251, label %266

251:                                              ; preds = %247
  %252 = load float*, float** %48, align 8
  %253 = load i32, i32* %52, align 4
  %254 = sext i32 %253 to i64
  %255 = getelementptr inbounds float, float* %252, i64 %254
  %256 = load float, float* %255, align 4
  %257 = load float, float* %51, align 4
  %258 = fdiv float %256, %257
  %259 = load float*, float** %49, align 8
  %260 = load i32, i32* %52, align 4
  %261 = sext i32 %260 to i64
  %262 = getelementptr inbounds float, float* %259, i64 %261
  store float %258, float* %262, align 4
  br label %263

263:                                              ; preds = %251
  %264 = load i32, i32* %52, align 4
  %265 = add nsw i32 %264, 1
  store i32 %265, i32* %52, align 4
  br label %247

266:                                              ; preds = %247
  %267 = load i32, i32* %42, align 4
  %268 = load i32, i32* %42, align 4
  %269 = mul nsw i32 %267, %268
  %270 = sext i32 %269 to i64
  %271 = call i8* @calloc(i64 4, i64 %270) #9
  %272 = bitcast i8* %271 to float*
  store float* %272, float** %53, align 8
  store i32 0, i32* %54, align 4
  br label %273

273:                                              ; preds = %316, %266
  %274 = load i32, i32* %54, align 4
  %275 = load i32, i32* %42, align 4
  %276 = icmp slt i32 %274, %275
  br i1 %276, label %277, label %319

277:                                              ; preds = %273
  store i32 0, i32* %55, align 4
  br label %278

278:                                              ; preds = %312, %277
  %279 = load i32, i32* %55, align 4
  %280 = load i32, i32* %42, align 4
  %281 = icmp slt i32 %279, %280
  br i1 %281, label %282, label %315

282:                                              ; preds = %278
  %283 = load i32, i32* %54, align 4
  %284 = load i32, i32* %55, align 4
  %285 = icmp eq i32 %283, %284
  %286 = zext i1 %285 to i64
  %287 = select i1 %285, double 1.000000e+00, double 0.000000e+00
  %288 = load float*, float** %49, align 8
  %289 = load i32, i32* %54, align 4
  %290 = sext i32 %289 to i64
  %291 = getelementptr inbounds float, float* %288, i64 %290
  %292 = load float, float* %291, align 4
  %293 = fmul float 2.000000e+00, %292
  %294 = load float*, float** %49, align 8
  %295 = load i32, i32* %55, align 4
  %296 = sext i32 %295 to i64
  %297 = getelementptr inbounds float, float* %294, i64 %296
  %298 = load float, float* %297, align 4
  %299 = fmul float %293, %298
  %300 = fpext float %299 to double
  %301 = fsub double %287, %300
  %302 = fptrunc double %301 to float
  store float %302, float* %56, align 4
  %303 = load float, float* %56, align 4
  %304 = load float*, float** %53, align 8
  %305 = load i32, i32* %54, align 4
  %306 = load i32, i32* %42, align 4
  %307 = mul nsw i32 %305, %306
  %308 = load i32, i32* %55, align 4
  %309 = add nsw i32 %307, %308
  %310 = sext i32 %309 to i64
  %311 = getelementptr inbounds float, float* %304, i64 %310
  store float %303, float* %311, align 4
  br label %312

312:                                              ; preds = %282
  %313 = load i32, i32* %55, align 4
  %314 = add nsw i32 %313, 1
  store i32 %314, i32* %55, align 4
  br label %278

315:                                              ; preds = %278
  br label %316

316:                                              ; preds = %315
  %317 = load i32, i32* %54, align 4
  %318 = add nsw i32 %317, 1
  store i32 %318, i32* %54, align 4
  br label %273

319:                                              ; preds = %273
  %320 = call i8* @calloc(i64 4, i64 16) #9
  %321 = bitcast i8* %320 to float*
  store float* %321, float** %57, align 8
  store i32 0, i32* %58, align 4
  br label %322

322:                                              ; preds = %371, %319
  %323 = load i32, i32* %58, align 4
  %324 = icmp slt i32 %323, 4
  br i1 %324, label %325, label %374

325:                                              ; preds = %322
  store i32 0, i32* %59, align 4
  br label %326

326:                                              ; preds = %367, %325
  %327 = load i32, i32* %59, align 4
  %328 = icmp slt i32 %327, 4
  br i1 %328, label %329, label %370

329:                                              ; preds = %326
  %330 = load i32, i32* %58, align 4
  %331 = load i32, i32* %41, align 4
  %332 = icmp slt i32 %330, %331
  br i1 %332, label %337, label %333

333:                                              ; preds = %329
  %334 = load i32, i32* %59, align 4
  %335 = load i32, i32* %41, align 4
  %336 = icmp slt i32 %334, %335
  br i1 %336, label %337, label %344

337:                                              ; preds = %333, %329
  %338 = load i32, i32* %58, align 4
  %339 = load i32, i32* %59, align 4
  %340 = icmp eq i32 %338, %339
  %341 = zext i1 %340 to i64
  %342 = select i1 %340, double 1.000000e+00, double 0.000000e+00
  %343 = fptrunc double %342 to float
  store float %343, float* %60, align 4
  br label %358

344:                                              ; preds = %333
  %345 = load float*, float** %53, align 8
  %346 = load i32, i32* %58, align 4
  %347 = load i32, i32* %41, align 4
  %348 = sub nsw i32 %346, %347
  %349 = load i32, i32* %42, align 4
  %350 = mul nsw i32 %348, %349
  %351 = load i32, i32* %59, align 4
  %352 = load i32, i32* %41, align 4
  %353 = sub nsw i32 %351, %352
  %354 = add nsw i32 %350, %353
  %355 = sext i32 %354 to i64
  %356 = getelementptr inbounds float, float* %345, i64 %355
  %357 = load float, float* %356, align 4
  store float %357, float* %60, align 4
  br label %358

358:                                              ; preds = %344, %337
  %359 = load float, float* %60, align 4
  %360 = load float*, float** %57, align 8
  %361 = load i32, i32* %58, align 4
  %362 = mul nsw i32 %361, 4
  %363 = load i32, i32* %59, align 4
  %364 = add nsw i32 %362, %363
  %365 = sext i32 %364 to i64
  %366 = getelementptr inbounds float, float* %360, i64 %365
  store float %359, float* %366, align 4
  br label %367

367:                                              ; preds = %358
  %368 = load i32, i32* %59, align 4
  %369 = add nsw i32 %368, 1
  store i32 %369, i32* %59, align 4
  br label %326

370:                                              ; preds = %326
  br label %371

371:                                              ; preds = %370
  %372 = load i32, i32* %58, align 4
  %373 = add nsw i32 %372, 1
  store i32 %373, i32* %58, align 4
  br label %322

374:                                              ; preds = %322
  %375 = load i32, i32* %41, align 4
  %376 = icmp eq i32 %375, 0
  br i1 %376, label %377, label %443

377:                                              ; preds = %374
  %378 = load float*, float** %36, align 8
  %379 = bitcast float* %378 to i8*
  %380 = load float*, float** %57, align 8
  %381 = bitcast float* %380 to i8*
  %382 = load float*, float** %36, align 8
  %383 = bitcast float* %382 to i8*
  %384 = call i64 @llvm.objectsize.i64.p0i8(i8* %383, i1 false, i1 true, i1 false)
  %385 = call i8* @__memcpy_chk(i8* %379, i8* %381, i64 64, i64 %384) #8
  %386 = load float*, float** %57, align 8
  %387 = load float*, float** %35, align 8
  %388 = load float*, float** %37, align 8
  store float* %386, float** %12, align 8
  store float* %387, float** %13, align 8
  store float* %388, float** %14, align 8
  store i32 0, i32* %15, align 4
  br label %389

389:                                              ; preds = %439, %377
  %390 = load i32, i32* %15, align 4
  %391 = icmp slt i32 %390, 4
  br i1 %391, label %392, label %442

392:                                              ; preds = %389
  store i32 0, i32* %16, align 4
  br label %393

393:                                              ; preds = %436, %392
  %394 = load i32, i32* %16, align 4
  %395 = icmp slt i32 %394, 4
  br i1 %395, label %396, label %439

396:                                              ; preds = %393
  %397 = load float*, float** %14, align 8
  %398 = load i32, i32* %15, align 4
  %399 = mul nsw i32 4, %398
  %400 = load i32, i32* %16, align 4
  %401 = add nsw i32 %399, %400
  %402 = sext i32 %401 to i64
  %403 = getelementptr inbounds float, float* %397, i64 %402
  store float 0.000000e+00, float* %403, align 4
  store i32 0, i32* %17, align 4
  br label %404

404:                                              ; preds = %407, %396
  %405 = load i32, i32* %17, align 4
  %406 = icmp slt i32 %405, 4
  br i1 %406, label %407, label %436

407:                                              ; preds = %404
  %408 = load float*, float** %12, align 8
  %409 = load i32, i32* %15, align 4
  %410 = mul nsw i32 4, %409
  %411 = load i32, i32* %17, align 4
  %412 = add nsw i32 %410, %411
  %413 = sext i32 %412 to i64
  %414 = getelementptr inbounds float, float* %408, i64 %413
  %415 = load float, float* %414, align 4
  %416 = load float*, float** %13, align 8
  %417 = load i32, i32* %17, align 4
  %418 = mul nsw i32 4, %417
  %419 = load i32, i32* %16, align 4
  %420 = add nsw i32 %418, %419
  %421 = sext i32 %420 to i64
  %422 = getelementptr inbounds float, float* %416, i64 %421
  %423 = load float, float* %422, align 4
  %424 = fmul float %415, %423
  %425 = load float*, float** %14, align 8
  %426 = load i32, i32* %15, align 4
  %427 = mul nsw i32 4, %426
  %428 = load i32, i32* %16, align 4
  %429 = add nsw i32 %427, %428
  %430 = sext i32 %429 to i64
  %431 = getelementptr inbounds float, float* %425, i64 %430
  %432 = load float, float* %431, align 4
  %433 = fadd float %432, %424
  store float %433, float* %431, align 4
  %434 = load i32, i32* %17, align 4
  %435 = add nsw i32 %434, 1
  store i32 %435, i32* %17, align 4
  br label %404

436:                                              ; preds = %404
  %437 = load i32, i32* %16, align 4
  %438 = add nsw i32 %437, 1
  store i32 %438, i32* %16, align 4
  br label %393

439:                                              ; preds = %393
  %440 = load i32, i32* %15, align 4
  %441 = add nsw i32 %440, 1
  store i32 %441, i32* %15, align 4
  br label %389

442:                                              ; preds = %389
  br label %576

443:                                              ; preds = %374
  %444 = call i8* @calloc(i64 4, i64 16) #9
  %445 = bitcast i8* %444 to float*
  store float* %445, float** %61, align 8
  %446 = load float*, float** %57, align 8
  %447 = load float*, float** %36, align 8
  %448 = load float*, float** %61, align 8
  store float* %446, float** %18, align 8
  store float* %447, float** %19, align 8
  store float* %448, float** %20, align 8
  store i32 0, i32* %21, align 4
  br label %449

449:                                              ; preds = %499, %443
  %450 = load i32, i32* %21, align 4
  %451 = icmp slt i32 %450, 4
  br i1 %451, label %452, label %502

452:                                              ; preds = %449
  store i32 0, i32* %22, align 4
  br label %453

453:                                              ; preds = %496, %452
  %454 = load i32, i32* %22, align 4
  %455 = icmp slt i32 %454, 4
  br i1 %455, label %456, label %499

456:                                              ; preds = %453
  %457 = load float*, float** %20, align 8
  %458 = load i32, i32* %21, align 4
  %459 = mul nsw i32 4, %458
  %460 = load i32, i32* %22, align 4
  %461 = add nsw i32 %459, %460
  %462 = sext i32 %461 to i64
  %463 = getelementptr inbounds float, float* %457, i64 %462
  store float 0.000000e+00, float* %463, align 4
  store i32 0, i32* %23, align 4
  br label %464

464:                                              ; preds = %467, %456
  %465 = load i32, i32* %23, align 4
  %466 = icmp slt i32 %465, 4
  br i1 %466, label %467, label %496

467:                                              ; preds = %464
  %468 = load float*, float** %18, align 8
  %469 = load i32, i32* %21, align 4
  %470 = mul nsw i32 4, %469
  %471 = load i32, i32* %23, align 4
  %472 = add nsw i32 %470, %471
  %473 = sext i32 %472 to i64
  %474 = getelementptr inbounds float, float* %468, i64 %473
  %475 = load float, float* %474, align 4
  %476 = load float*, float** %19, align 8
  %477 = load i32, i32* %23, align 4
  %478 = mul nsw i32 4, %477
  %479 = load i32, i32* %22, align 4
  %480 = add nsw i32 %478, %479
  %481 = sext i32 %480 to i64
  %482 = getelementptr inbounds float, float* %476, i64 %481
  %483 = load float, float* %482, align 4
  %484 = fmul float %475, %483
  %485 = load float*, float** %20, align 8
  %486 = load i32, i32* %21, align 4
  %487 = mul nsw i32 4, %486
  %488 = load i32, i32* %22, align 4
  %489 = add nsw i32 %487, %488
  %490 = sext i32 %489 to i64
  %491 = getelementptr inbounds float, float* %485, i64 %490
  %492 = load float, float* %491, align 4
  %493 = fadd float %492, %484
  store float %493, float* %491, align 4
  %494 = load i32, i32* %23, align 4
  %495 = add nsw i32 %494, 1
  store i32 %495, i32* %23, align 4
  br label %464

496:                                              ; preds = %464
  %497 = load i32, i32* %22, align 4
  %498 = add nsw i32 %497, 1
  store i32 %498, i32* %22, align 4
  br label %453

499:                                              ; preds = %453
  %500 = load i32, i32* %21, align 4
  %501 = add nsw i32 %500, 1
  store i32 %501, i32* %21, align 4
  br label %449

502:                                              ; preds = %449
  %503 = load float*, float** %36, align 8
  %504 = bitcast float* %503 to i8*
  %505 = load float*, float** %61, align 8
  %506 = bitcast float* %505 to i8*
  %507 = load float*, float** %36, align 8
  %508 = bitcast float* %507 to i8*
  %509 = call i64 @llvm.objectsize.i64.p0i8(i8* %508, i1 false, i1 true, i1 false)
  %510 = call i8* @__memcpy_chk(i8* %504, i8* %506, i64 64, i64 %509) #8
  %511 = load float*, float** %57, align 8
  %512 = load float*, float** %37, align 8
  %513 = load float*, float** %61, align 8
  store float* %511, float** %24, align 8
  store float* %512, float** %25, align 8
  store float* %513, float** %26, align 8
  store i32 0, i32* %27, align 4
  br label %514

514:                                              ; preds = %564, %502
  %515 = load i32, i32* %27, align 4
  %516 = icmp slt i32 %515, 4
  br i1 %516, label %517, label %567

517:                                              ; preds = %514
  store i32 0, i32* %28, align 4
  br label %518

518:                                              ; preds = %561, %517
  %519 = load i32, i32* %28, align 4
  %520 = icmp slt i32 %519, 4
  br i1 %520, label %521, label %564

521:                                              ; preds = %518
  %522 = load float*, float** %26, align 8
  %523 = load i32, i32* %27, align 4
  %524 = mul nsw i32 4, %523
  %525 = load i32, i32* %28, align 4
  %526 = add nsw i32 %524, %525
  %527 = sext i32 %526 to i64
  %528 = getelementptr inbounds float, float* %522, i64 %527
  store float 0.000000e+00, float* %528, align 4
  store i32 0, i32* %29, align 4
  br label %529

529:                                              ; preds = %532, %521
  %530 = load i32, i32* %29, align 4
  %531 = icmp slt i32 %530, 4
  br i1 %531, label %532, label %561

532:                                              ; preds = %529
  %533 = load float*, float** %24, align 8
  %534 = load i32, i32* %27, align 4
  %535 = mul nsw i32 4, %534
  %536 = load i32, i32* %29, align 4
  %537 = add nsw i32 %535, %536
  %538 = sext i32 %537 to i64
  %539 = getelementptr inbounds float, float* %533, i64 %538
  %540 = load float, float* %539, align 4
  %541 = load float*, float** %25, align 8
  %542 = load i32, i32* %29, align 4
  %543 = mul nsw i32 4, %542
  %544 = load i32, i32* %28, align 4
  %545 = add nsw i32 %543, %544
  %546 = sext i32 %545 to i64
  %547 = getelementptr inbounds float, float* %541, i64 %546
  %548 = load float, float* %547, align 4
  %549 = fmul float %540, %548
  %550 = load float*, float** %26, align 8
  %551 = load i32, i32* %27, align 4
  %552 = mul nsw i32 4, %551
  %553 = load i32, i32* %28, align 4
  %554 = add nsw i32 %552, %553
  %555 = sext i32 %554 to i64
  %556 = getelementptr inbounds float, float* %550, i64 %555
  %557 = load float, float* %556, align 4
  %558 = fadd float %557, %549
  store float %558, float* %556, align 4
  %559 = load i32, i32* %29, align 4
  %560 = add nsw i32 %559, 1
  store i32 %560, i32* %29, align 4
  br label %529

561:                                              ; preds = %529
  %562 = load i32, i32* %28, align 4
  %563 = add nsw i32 %562, 1
  store i32 %563, i32* %28, align 4
  br label %518

564:                                              ; preds = %518
  %565 = load i32, i32* %27, align 4
  %566 = add nsw i32 %565, 1
  store i32 %566, i32* %27, align 4
  br label %514

567:                                              ; preds = %514
  %568 = load float*, float** %37, align 8
  %569 = bitcast float* %568 to i8*
  %570 = load float*, float** %61, align 8
  %571 = bitcast float* %570 to i8*
  %572 = load float*, float** %37, align 8
  %573 = bitcast float* %572 to i8*
  %574 = call i64 @llvm.objectsize.i64.p0i8(i8* %573, i1 false, i1 true, i1 false)
  %575 = call i8* @__memcpy_chk(i8* %569, i8* %571, i64 64, i64 %574) #8
  br label %576

576:                                              ; preds = %567, %442
  %577 = load float*, float** %43, align 8
  %578 = bitcast float* %577 to i8*
  call void @free(i8* %578)
  %579 = load float*, float** %44, align 8
  %580 = bitcast float* %579 to i8*
  call void @free(i8* %580)
  %581 = load float*, float** %48, align 8
  %582 = bitcast float* %581 to i8*
  call void @free(i8* %582)
  %583 = load float*, float** %49, align 8
  %584 = bitcast float* %583 to i8*
  call void @free(i8* %584)
  %585 = load float*, float** %53, align 8
  %586 = bitcast float* %585 to i8*
  call void @free(i8* %586)
  %587 = load float*, float** %57, align 8
  %588 = bitcast float* %587 to i8*
  call void @free(i8* %588)
  br label %589

589:                                              ; preds = %576
  %590 = load i32, i32* %41, align 4
  %591 = add nsw i32 %590, 1
  store i32 %591, i32* %41, align 4
  br label %100

592:                                              ; preds = %100
  %593 = load float*, float** %36, align 8
  store float* %593, float** %30, align 8
  store i32 0, i32* %31, align 4
  br label %594

594:                                              ; preds = %637, %592
  %595 = load i32, i32* %31, align 4
  %596 = icmp slt i32 %595, 4
  br i1 %596, label %597, label %640

597:                                              ; preds = %594
  %598 = load i32, i32* %31, align 4
  %599 = add nsw i32 %598, 1
  store i32 %599, i32* %32, align 4
  br label %600

600:                                              ; preds = %603, %597
  %601 = load i32, i32* %32, align 4
  %602 = icmp slt i32 %601, 4
  br i1 %602, label %603, label %637

603:                                              ; preds = %600
  %604 = load float*, float** %30, align 8
  %605 = load i32, i32* %31, align 4
  %606 = mul nsw i32 %605, 4
  %607 = load i32, i32* %32, align 4
  %608 = add nsw i32 %606, %607
  %609 = sext i32 %608 to i64
  %610 = getelementptr inbounds float, float* %604, i64 %609
  %611 = load float, float* %610, align 4
  store float %611, float* %33, align 4
  %612 = load float*, float** %30, align 8
  %613 = load i32, i32* %32, align 4
  %614 = mul nsw i32 %613, 4
  %615 = load i32, i32* %31, align 4
  %616 = add nsw i32 %614, %615
  %617 = sext i32 %616 to i64
  %618 = getelementptr inbounds float, float* %612, i64 %617
  %619 = load float, float* %618, align 4
  %620 = load float*, float** %30, align 8
  %621 = load i32, i32* %31, align 4
  %622 = mul nsw i32 %621, 4
  %623 = load i32, i32* %32, align 4
  %624 = add nsw i32 %622, %623
  %625 = sext i32 %624 to i64
  %626 = getelementptr inbounds float, float* %620, i64 %625
  store float %619, float* %626, align 4
  %627 = load float, float* %33, align 4
  %628 = load float*, float** %30, align 8
  %629 = load i32, i32* %32, align 4
  %630 = mul nsw i32 %629, 4
  %631 = load i32, i32* %31, align 4
  %632 = add nsw i32 %630, %631
  %633 = sext i32 %632 to i64
  %634 = getelementptr inbounds float, float* %628, i64 %633
  store float %627, float* %634, align 4
  %635 = load i32, i32* %32, align 4
  %636 = add nsw i32 %635, 1
  store i32 %636, i32* %32, align 4
  br label %600

637:                                              ; preds = %600
  %638 = load i32, i32* %31, align 4
  %639 = add nsw i32 %638, 1
  store i32 %639, i32* %31, align 4
  br label %594

640:                                              ; preds = %594
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
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #6

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #7

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
