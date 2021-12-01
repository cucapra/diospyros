; ModuleID = 'clang.ll'
source_filename = "llvm-tests/qr-decomp-fixed-size.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.A = private unnamed_addr constant [16 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00, float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00, float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00, float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00], align 16
@.str = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1

; Function Attrs: alwaysinline nounwind ssp uwtable
define float @sgn(float %0) #0 {
  %2 = fcmp ogt float %0, 0.000000e+00
  %3 = zext i1 %2 to i32
  %4 = fcmp olt float %0, 0.000000e+00
  %.neg = sext i1 %4 to i32
  %5 = add nsw i32 %.neg, %3
  %6 = sitofp i32 %5 to float
  ret float %6
}

; Function Attrs: alwaysinline nounwind ssp uwtable
define float @naive_norm(float* %0, i32 %1) #0 {
  %3 = icmp sgt i32 %1, 0
  %smax = select i1 %3, i32 %1, i32 0
  %wide.trip.count = zext i32 %smax to i64
  br i1 %3, label %.lr.ph, label %._crit_edge

.lr.ph:                                           ; preds = %2
  %xtraiter = and i64 %wide.trip.count, 1
  %4 = icmp eq i32 %smax, 1
  br i1 %4, label %._crit_edge.unr-lcssa, label %.lr.ph.new

.lr.ph.new:                                       ; preds = %.lr.ph
  %unroll_iter = and i64 %wide.trip.count, 2147483646
  br label %5

5:                                                ; preds = %5, %.lr.ph.new
  %.013 = phi float [ 0.000000e+00, %.lr.ph.new ], [ %17, %5 ]
  %indvars.iv2 = phi i64 [ 0, %.lr.ph.new ], [ %indvars.iv.next.1, %5 ]
  %niter = phi i64 [ %unroll_iter, %.lr.ph.new ], [ %niter.nsub.1, %5 ]
  %6 = getelementptr inbounds float, float* %0, i64 %indvars.iv2
  %7 = load float, float* %6, align 4
  %8 = fpext float %7 to double
  %square = fmul double %8, %8
  %9 = fpext float %.013 to double
  %10 = fadd double %square, %9
  %11 = fptrunc double %10 to float
  %indvars.iv.next = or i64 %indvars.iv2, 1
  %12 = getelementptr inbounds float, float* %0, i64 %indvars.iv.next
  %13 = load float, float* %12, align 4
  %14 = fpext float %13 to double
  %square4 = fmul double %14, %14
  %15 = fpext float %11 to double
  %16 = fadd double %square4, %15
  %17 = fptrunc double %16 to float
  %indvars.iv.next.1 = add nuw nsw i64 %indvars.iv2, 2
  %niter.nsub.1 = add i64 %niter, -2
  %niter.ncmp.1.not = icmp eq i64 %niter.nsub.1, 0
  br i1 %niter.ncmp.1.not, label %._crit_edge.unr-lcssa, label %5

._crit_edge.unr-lcssa:                            ; preds = %5, %.lr.ph
  %split.ph = phi float [ undef, %.lr.ph ], [ %17, %5 ]
  %.013.unr = phi float [ 0.000000e+00, %.lr.ph ], [ %17, %5 ]
  %indvars.iv2.unr = phi i64 [ 0, %.lr.ph ], [ %indvars.iv.next.1, %5 ]
  %lcmp.mod.not = icmp eq i64 %xtraiter, 0
  br i1 %lcmp.mod.not, label %._crit_edge, label %.epil.preheader

.epil.preheader:                                  ; preds = %._crit_edge.unr-lcssa
  %18 = getelementptr inbounds float, float* %0, i64 %indvars.iv2.unr
  %19 = load float, float* %18, align 4
  %20 = fpext float %19 to double
  %square5 = fmul double %20, %20
  %21 = fpext float %.013.unr to double
  %22 = fadd double %square5, %21
  %23 = fptrunc double %22 to float
  br label %._crit_edge

._crit_edge:                                      ; preds = %._crit_edge.unr-lcssa, %.epil.preheader, %2
  %.01.lcssa = phi float [ 0.000000e+00, %2 ], [ %split.ph, %._crit_edge.unr-lcssa ], [ %23, %.epil.preheader ]
  %24 = call float @llvm.sqrt.f32(float %.01.lcssa)
  ret float %24
}

; Function Attrs: nounwind readnone speculatable willreturn
declare double @llvm.pow.f64(double, double) #1

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32(float) #1

; Function Attrs: alwaysinline nounwind ssp uwtable
define void @naive_fixed_transpose(float* %0) #0 {
.lr.ph:
  %1 = getelementptr inbounds float, float* %0, i64 1
  %2 = bitcast float* %1 to i32*
  %3 = load i32, i32* %2, align 4
  %4 = getelementptr inbounds float, float* %0, i64 4
  %5 = bitcast float* %4 to i32*
  %6 = load i32, i32* %5, align 4
  store i32 %6, i32* %2, align 4
  store i32 %3, i32* %5, align 4
  br label %7

7:                                                ; preds = %7, %.lr.ph
  %indvars.iv25 = phi i64 [ 2, %.lr.ph ], [ %indvars.iv.next3.1, %7 ]
  %8 = getelementptr inbounds float, float* %0, i64 %indvars.iv25
  %9 = bitcast float* %8 to i32*
  %10 = load i32, i32* %9, align 4
  %11 = shl nuw nsw i64 %indvars.iv25, 2
  %12 = getelementptr inbounds float, float* %0, i64 %11
  %13 = bitcast float* %12 to i32*
  %14 = load i32, i32* %13, align 4
  store i32 %14, i32* %9, align 4
  store i32 %10, i32* %13, align 4
  %indvars.iv.next3 = or i64 %indvars.iv25, 1
  %15 = getelementptr inbounds float, float* %0, i64 %indvars.iv.next3
  %16 = bitcast float* %15 to i32*
  %17 = load i32, i32* %16, align 4
  %18 = shl nuw nsw i64 %indvars.iv.next3, 2
  %19 = getelementptr inbounds float, float* %0, i64 %18
  %20 = bitcast float* %19 to i32*
  %21 = load i32, i32* %20, align 4
  store i32 %21, i32* %16, align 4
  store i32 %17, i32* %20, align 4
  %indvars.iv.next3.1 = add nuw nsw i64 %indvars.iv25, 2
  %exitcond.1.not = icmp eq i64 %indvars.iv.next3.1, 4
  br i1 %exitcond.1.not, label %.lr.ph.new.1, label %7

.lr.ph.new.1:                                     ; preds = %.lr.ph.new.1, %7
  %indvars.iv25.1 = phi i64 [ %indvars.iv.next3.1.1, %.lr.ph.new.1 ], [ 2, %7 ]
  %22 = add nuw nsw i64 %indvars.iv25.1, 4
  %23 = getelementptr inbounds float, float* %0, i64 %22
  %24 = bitcast float* %23 to i32*
  %25 = load i32, i32* %24, align 4
  %26 = shl nuw nsw i64 %indvars.iv25.1, 2
  %27 = or i64 %26, 1
  %28 = getelementptr inbounds float, float* %0, i64 %27
  %29 = bitcast float* %28 to i32*
  %30 = load i32, i32* %29, align 4
  store i32 %30, i32* %24, align 4
  store i32 %25, i32* %29, align 4
  %indvars.iv.next3.113 = or i64 %indvars.iv25.1, 1
  %31 = add nuw nsw i64 %indvars.iv25.1, 5
  %32 = getelementptr inbounds float, float* %0, i64 %31
  %33 = bitcast float* %32 to i32*
  %34 = load i32, i32* %33, align 4
  %35 = shl nuw nsw i64 %indvars.iv.next3.113, 2
  %36 = or i64 %35, 1
  %37 = getelementptr inbounds float, float* %0, i64 %36
  %38 = bitcast float* %37 to i32*
  %39 = load i32, i32* %38, align 4
  store i32 %39, i32* %33, align 4
  store i32 %34, i32* %38, align 4
  %indvars.iv.next3.1.1 = add nuw nsw i64 %indvars.iv25.1, 2
  %exitcond.1.1.not = icmp eq i64 %indvars.iv.next3.1.1, 4
  br i1 %exitcond.1.1.not, label %.prol.preheader.2, label %.lr.ph.new.1

.prol.preheader.2:                                ; preds = %.lr.ph.new.1
  %40 = getelementptr inbounds float, float* %0, i64 11
  %41 = bitcast float* %40 to i32*
  %42 = load i32, i32* %41, align 4
  %43 = getelementptr inbounds float, float* %0, i64 14
  %44 = bitcast float* %43 to i32*
  %45 = load i32, i32* %44, align 4
  store i32 %45, i32* %41, align 4
  store i32 %42, i32* %44, align 4
  ret void
}

; Function Attrs: alwaysinline nounwind ssp uwtable
define void @naive_fixed_matrix_multiply(float* %0, float* %1, float* %2) #0 {
.preheader:
  store float 0.000000e+00, float* %2, align 4
  %3 = load float, float* %0, align 4
  %4 = load float, float* %1, align 4
  %5 = fmul float %3, %4
  %6 = fadd float %5, 0.000000e+00
  store float %6, float* %2, align 4
  %7 = getelementptr inbounds float, float* %0, i64 1
  %8 = load float, float* %7, align 4
  %9 = getelementptr inbounds float, float* %1, i64 4
  %10 = load float, float* %9, align 4
  %11 = fmul float %8, %10
  %12 = fadd float %6, %11
  store float %12, float* %2, align 4
  %13 = getelementptr inbounds float, float* %0, i64 2
  %14 = load float, float* %13, align 4
  %15 = getelementptr inbounds float, float* %1, i64 8
  %16 = load float, float* %15, align 4
  %17 = fmul float %14, %16
  %18 = fadd float %12, %17
  store float %18, float* %2, align 4
  %19 = getelementptr inbounds float, float* %0, i64 3
  %20 = load float, float* %19, align 4
  %21 = getelementptr inbounds float, float* %1, i64 12
  %22 = load float, float* %21, align 4
  %23 = fmul float %20, %22
  %24 = fadd float %18, %23
  store float %24, float* %2, align 4
  %25 = getelementptr inbounds float, float* %2, i64 1
  store float 0.000000e+00, float* %25, align 4
  %26 = load float, float* %0, align 4
  %27 = getelementptr inbounds float, float* %1, i64 1
  %28 = load float, float* %27, align 4
  %29 = fmul float %26, %28
  %30 = fadd float %29, 0.000000e+00
  store float %30, float* %25, align 4
  %31 = load float, float* %7, align 4
  %32 = getelementptr inbounds float, float* %1, i64 5
  %33 = load float, float* %32, align 4
  %34 = fmul float %31, %33
  %35 = fadd float %30, %34
  store float %35, float* %25, align 4
  %36 = load float, float* %13, align 4
  %37 = getelementptr inbounds float, float* %1, i64 9
  %38 = load float, float* %37, align 4
  %39 = fmul float %36, %38
  %40 = fadd float %35, %39
  store float %40, float* %25, align 4
  %41 = load float, float* %19, align 4
  %42 = getelementptr inbounds float, float* %1, i64 13
  %43 = load float, float* %42, align 4
  %44 = fmul float %41, %43
  %45 = fadd float %40, %44
  store float %45, float* %25, align 4
  %46 = getelementptr inbounds float, float* %2, i64 2
  store float 0.000000e+00, float* %46, align 4
  %47 = load float, float* %0, align 4
  %48 = getelementptr inbounds float, float* %1, i64 2
  %49 = load float, float* %48, align 4
  %50 = fmul float %47, %49
  %51 = fadd float %50, 0.000000e+00
  store float %51, float* %46, align 4
  %52 = load float, float* %7, align 4
  %53 = getelementptr inbounds float, float* %1, i64 6
  %54 = load float, float* %53, align 4
  %55 = fmul float %52, %54
  %56 = fadd float %51, %55
  store float %56, float* %46, align 4
  %57 = load float, float* %13, align 4
  %58 = getelementptr inbounds float, float* %1, i64 10
  %59 = load float, float* %58, align 4
  %60 = fmul float %57, %59
  %61 = fadd float %56, %60
  store float %61, float* %46, align 4
  %62 = load float, float* %19, align 4
  %63 = getelementptr inbounds float, float* %1, i64 14
  %64 = load float, float* %63, align 4
  %65 = fmul float %62, %64
  %66 = fadd float %61, %65
  store float %66, float* %46, align 4
  %67 = getelementptr inbounds float, float* %2, i64 3
  store float 0.000000e+00, float* %67, align 4
  %68 = load float, float* %0, align 4
  %69 = getelementptr inbounds float, float* %1, i64 3
  %70 = load float, float* %69, align 4
  %71 = fmul float %68, %70
  %72 = fadd float %71, 0.000000e+00
  store float %72, float* %67, align 4
  %73 = load float, float* %7, align 4
  %74 = getelementptr inbounds float, float* %1, i64 7
  %75 = load float, float* %74, align 4
  %76 = fmul float %73, %75
  %77 = fadd float %72, %76
  store float %77, float* %67, align 4
  %78 = load float, float* %13, align 4
  %79 = getelementptr inbounds float, float* %1, i64 11
  %80 = load float, float* %79, align 4
  %81 = fmul float %78, %80
  %82 = fadd float %77, %81
  store float %82, float* %67, align 4
  %83 = load float, float* %19, align 4
  %84 = getelementptr inbounds float, float* %1, i64 15
  %85 = load float, float* %84, align 4
  %86 = fmul float %83, %85
  %87 = fadd float %82, %86
  store float %87, float* %67, align 4
  %88 = getelementptr inbounds float, float* %0, i64 4
  %89 = getelementptr inbounds float, float* %2, i64 4
  store float 0.000000e+00, float* %89, align 4
  %90 = load float, float* %88, align 4
  %91 = load float, float* %1, align 4
  %92 = fmul float %90, %91
  %93 = fadd float %92, 0.000000e+00
  store float %93, float* %89, align 4
  %94 = getelementptr inbounds float, float* %0, i64 5
  %95 = load float, float* %94, align 4
  %96 = load float, float* %9, align 4
  %97 = fmul float %95, %96
  %98 = fadd float %93, %97
  store float %98, float* %89, align 4
  %99 = getelementptr inbounds float, float* %0, i64 6
  %100 = load float, float* %99, align 4
  %101 = load float, float* %15, align 4
  %102 = fmul float %100, %101
  %103 = fadd float %98, %102
  store float %103, float* %89, align 4
  %104 = getelementptr inbounds float, float* %0, i64 7
  %105 = load float, float* %104, align 4
  %106 = load float, float* %21, align 4
  %107 = fmul float %105, %106
  %108 = fadd float %103, %107
  store float %108, float* %89, align 4
  %109 = getelementptr inbounds float, float* %2, i64 5
  store float 0.000000e+00, float* %109, align 4
  %110 = load float, float* %88, align 4
  %111 = load float, float* %27, align 4
  %112 = fmul float %110, %111
  %113 = fadd float %112, 0.000000e+00
  store float %113, float* %109, align 4
  %114 = load float, float* %94, align 4
  %115 = load float, float* %32, align 4
  %116 = fmul float %114, %115
  %117 = fadd float %113, %116
  store float %117, float* %109, align 4
  %118 = load float, float* %99, align 4
  %119 = load float, float* %37, align 4
  %120 = fmul float %118, %119
  %121 = fadd float %117, %120
  store float %121, float* %109, align 4
  %122 = load float, float* %104, align 4
  %123 = load float, float* %42, align 4
  %124 = fmul float %122, %123
  %125 = fadd float %121, %124
  store float %125, float* %109, align 4
  %126 = getelementptr inbounds float, float* %2, i64 6
  store float 0.000000e+00, float* %126, align 4
  %127 = load float, float* %88, align 4
  %128 = load float, float* %48, align 4
  %129 = fmul float %127, %128
  %130 = fadd float %129, 0.000000e+00
  store float %130, float* %126, align 4
  %131 = load float, float* %94, align 4
  %132 = load float, float* %53, align 4
  %133 = fmul float %131, %132
  %134 = fadd float %130, %133
  store float %134, float* %126, align 4
  %135 = load float, float* %99, align 4
  %136 = load float, float* %58, align 4
  %137 = fmul float %135, %136
  %138 = fadd float %134, %137
  store float %138, float* %126, align 4
  %139 = load float, float* %104, align 4
  %140 = load float, float* %63, align 4
  %141 = fmul float %139, %140
  %142 = fadd float %138, %141
  store float %142, float* %126, align 4
  %143 = getelementptr inbounds float, float* %2, i64 7
  store float 0.000000e+00, float* %143, align 4
  %144 = load float, float* %88, align 4
  %145 = load float, float* %69, align 4
  %146 = fmul float %144, %145
  %147 = fadd float %146, 0.000000e+00
  store float %147, float* %143, align 4
  %148 = load float, float* %94, align 4
  %149 = load float, float* %74, align 4
  %150 = fmul float %148, %149
  %151 = fadd float %147, %150
  store float %151, float* %143, align 4
  %152 = load float, float* %99, align 4
  %153 = load float, float* %79, align 4
  %154 = fmul float %152, %153
  %155 = fadd float %151, %154
  store float %155, float* %143, align 4
  %156 = load float, float* %104, align 4
  %157 = load float, float* %84, align 4
  %158 = fmul float %156, %157
  %159 = fadd float %155, %158
  store float %159, float* %143, align 4
  %160 = getelementptr inbounds float, float* %0, i64 8
  %161 = getelementptr inbounds float, float* %2, i64 8
  store float 0.000000e+00, float* %161, align 4
  %162 = load float, float* %160, align 4
  %163 = load float, float* %1, align 4
  %164 = fmul float %162, %163
  %165 = fadd float %164, 0.000000e+00
  store float %165, float* %161, align 4
  %166 = getelementptr inbounds float, float* %0, i64 9
  %167 = load float, float* %166, align 4
  %168 = load float, float* %9, align 4
  %169 = fmul float %167, %168
  %170 = fadd float %165, %169
  store float %170, float* %161, align 4
  %171 = getelementptr inbounds float, float* %0, i64 10
  %172 = load float, float* %171, align 4
  %173 = load float, float* %15, align 4
  %174 = fmul float %172, %173
  %175 = fadd float %170, %174
  store float %175, float* %161, align 4
  %176 = getelementptr inbounds float, float* %0, i64 11
  %177 = load float, float* %176, align 4
  %178 = load float, float* %21, align 4
  %179 = fmul float %177, %178
  %180 = fadd float %175, %179
  store float %180, float* %161, align 4
  %181 = getelementptr inbounds float, float* %2, i64 9
  store float 0.000000e+00, float* %181, align 4
  %182 = load float, float* %160, align 4
  %183 = load float, float* %27, align 4
  %184 = fmul float %182, %183
  %185 = fadd float %184, 0.000000e+00
  store float %185, float* %181, align 4
  %186 = load float, float* %166, align 4
  %187 = load float, float* %32, align 4
  %188 = fmul float %186, %187
  %189 = fadd float %185, %188
  store float %189, float* %181, align 4
  %190 = load float, float* %171, align 4
  %191 = load float, float* %37, align 4
  %192 = fmul float %190, %191
  %193 = fadd float %189, %192
  store float %193, float* %181, align 4
  %194 = load float, float* %176, align 4
  %195 = load float, float* %42, align 4
  %196 = fmul float %194, %195
  %197 = fadd float %193, %196
  store float %197, float* %181, align 4
  %198 = getelementptr inbounds float, float* %2, i64 10
  store float 0.000000e+00, float* %198, align 4
  %199 = load float, float* %160, align 4
  %200 = load float, float* %48, align 4
  %201 = fmul float %199, %200
  %202 = fadd float %201, 0.000000e+00
  store float %202, float* %198, align 4
  %203 = load float, float* %166, align 4
  %204 = load float, float* %53, align 4
  %205 = fmul float %203, %204
  %206 = fadd float %202, %205
  store float %206, float* %198, align 4
  %207 = load float, float* %171, align 4
  %208 = load float, float* %58, align 4
  %209 = fmul float %207, %208
  %210 = fadd float %206, %209
  store float %210, float* %198, align 4
  %211 = load float, float* %176, align 4
  %212 = load float, float* %63, align 4
  %213 = fmul float %211, %212
  %214 = fadd float %210, %213
  store float %214, float* %198, align 4
  %215 = getelementptr inbounds float, float* %2, i64 11
  store float 0.000000e+00, float* %215, align 4
  %216 = load float, float* %160, align 4
  %217 = load float, float* %69, align 4
  %218 = fmul float %216, %217
  %219 = fadd float %218, 0.000000e+00
  store float %219, float* %215, align 4
  %220 = load float, float* %166, align 4
  %221 = load float, float* %74, align 4
  %222 = fmul float %220, %221
  %223 = fadd float %219, %222
  store float %223, float* %215, align 4
  %224 = load float, float* %171, align 4
  %225 = load float, float* %79, align 4
  %226 = fmul float %224, %225
  %227 = fadd float %223, %226
  store float %227, float* %215, align 4
  %228 = load float, float* %176, align 4
  %229 = load float, float* %84, align 4
  %230 = fmul float %228, %229
  %231 = fadd float %227, %230
  store float %231, float* %215, align 4
  %232 = getelementptr inbounds float, float* %0, i64 12
  %233 = getelementptr inbounds float, float* %2, i64 12
  store float 0.000000e+00, float* %233, align 4
  %234 = load float, float* %232, align 4
  %235 = load float, float* %1, align 4
  %236 = fmul float %234, %235
  %237 = fadd float %236, 0.000000e+00
  store float %237, float* %233, align 4
  %238 = getelementptr inbounds float, float* %0, i64 13
  %239 = load float, float* %238, align 4
  %240 = load float, float* %9, align 4
  %241 = fmul float %239, %240
  %242 = fadd float %237, %241
  store float %242, float* %233, align 4
  %243 = getelementptr inbounds float, float* %0, i64 14
  %244 = load float, float* %243, align 4
  %245 = load float, float* %15, align 4
  %246 = fmul float %244, %245
  %247 = fadd float %242, %246
  store float %247, float* %233, align 4
  %248 = getelementptr inbounds float, float* %0, i64 15
  %249 = load float, float* %248, align 4
  %250 = load float, float* %21, align 4
  %251 = fmul float %249, %250
  %252 = fadd float %247, %251
  store float %252, float* %233, align 4
  %253 = getelementptr inbounds float, float* %2, i64 13
  store float 0.000000e+00, float* %253, align 4
  %254 = load float, float* %232, align 4
  %255 = load float, float* %27, align 4
  %256 = fmul float %254, %255
  %257 = fadd float %256, 0.000000e+00
  store float %257, float* %253, align 4
  %258 = load float, float* %238, align 4
  %259 = load float, float* %32, align 4
  %260 = fmul float %258, %259
  %261 = fadd float %257, %260
  store float %261, float* %253, align 4
  %262 = load float, float* %243, align 4
  %263 = load float, float* %37, align 4
  %264 = fmul float %262, %263
  %265 = fadd float %261, %264
  store float %265, float* %253, align 4
  %266 = load float, float* %248, align 4
  %267 = load float, float* %42, align 4
  %268 = fmul float %266, %267
  %269 = fadd float %265, %268
  store float %269, float* %253, align 4
  %270 = getelementptr inbounds float, float* %2, i64 14
  store float 0.000000e+00, float* %270, align 4
  %271 = load float, float* %232, align 4
  %272 = load float, float* %48, align 4
  %273 = fmul float %271, %272
  %274 = fadd float %273, 0.000000e+00
  store float %274, float* %270, align 4
  %275 = load float, float* %238, align 4
  %276 = load float, float* %53, align 4
  %277 = fmul float %275, %276
  %278 = fadd float %274, %277
  store float %278, float* %270, align 4
  %279 = load float, float* %243, align 4
  %280 = load float, float* %58, align 4
  %281 = fmul float %279, %280
  %282 = fadd float %278, %281
  store float %282, float* %270, align 4
  %283 = load float, float* %248, align 4
  %284 = load float, float* %63, align 4
  %285 = fmul float %283, %284
  %286 = fadd float %282, %285
  store float %286, float* %270, align 4
  %287 = getelementptr inbounds float, float* %2, i64 15
  store float 0.000000e+00, float* %287, align 4
  %288 = load float, float* %232, align 4
  %289 = load float, float* %69, align 4
  %290 = fmul float %288, %289
  %291 = fadd float %290, 0.000000e+00
  store float %291, float* %287, align 4
  %292 = load float, float* %238, align 4
  %293 = load float, float* %74, align 4
  %294 = fmul float %292, %293
  %295 = fadd float %291, %294
  store float %295, float* %287, align 4
  %296 = load float, float* %243, align 4
  %297 = load float, float* %79, align 4
  %298 = fmul float %296, %297
  %299 = fadd float %295, %298
  store float %299, float* %287, align 4
  %300 = load float, float* %248, align 4
  %301 = load float, float* %84, align 4
  %302 = fmul float %300, %301
  %303 = fadd float %299, %302
  store float %303, float* %287, align 4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define void @naive_fixed_qr_decomp(float* %0, float* %1, float* %2) #2 {
.preheader33:
  %3 = bitcast float* %2 to i8*
  %4 = bitcast float* %0 to i8*
  %5 = call i64 @llvm.objectsize.i64.p0i8(i8* %3, i1 false, i1 true, i1 false)
  %6 = call i8* @__memcpy_chk(i8* %3, i8* %4, i64 64, i64 %5) #8
  %7 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #9
  %8 = bitcast i8* %7 to float*
  store float 1.000000e+00, float* %8, align 4
  %9 = getelementptr inbounds i8, i8* %7, i64 16
  %10 = getelementptr inbounds i8, i8* %7, i64 20
  %11 = bitcast i8* %10 to float*
  store float 1.000000e+00, float* %11, align 4
  %12 = getelementptr inbounds i8, i8* %7, i64 32
  %13 = getelementptr inbounds i8, i8* %7, i64 36
  %14 = getelementptr inbounds i8, i8* %7, i64 40
  %15 = bitcast i8* %14 to float*
  store float 1.000000e+00, float* %15, align 4
  %16 = getelementptr inbounds i8, i8* %7, i64 48
  %17 = getelementptr inbounds i8, i8* %7, i64 52
  %18 = getelementptr inbounds i8, i8* %7, i64 56
  %19 = getelementptr inbounds i8, i8* %7, i64 60
  %20 = bitcast i8* %19 to float*
  store float 1.000000e+00, float* %20, align 4
  %21 = bitcast float* %1 to i8*
  %22 = call i64 @llvm.objectsize.i64.p0i8(i8* %21, i1 false, i1 true, i1 false)
  %23 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #9
  %24 = bitcast i8* %23 to float*
  %25 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #9
  %26 = bitcast i8* %25 to float*
  %27 = bitcast float* %2 to i32*
  %28 = load i32, i32* %27, align 4
  %29 = bitcast i8* %23 to i32*
  store i32 %28, i32* %29, align 4
  %30 = bitcast i8* %7 to i32*
  %31 = load i32, i32* %30, align 4
  %32 = bitcast i8* %25 to i32*
  store i32 %31, i32* %32, align 4
  %33 = getelementptr inbounds float, float* %2, i64 4
  %34 = bitcast float* %33 to i32*
  %35 = load i32, i32* %34, align 4
  %36 = getelementptr inbounds i8, i8* %23, i64 4
  %37 = bitcast i8* %36 to i32*
  store i32 %35, i32* %37, align 4
  %38 = bitcast i8* %9 to i32*
  %39 = load i32, i32* %38, align 4
  %40 = getelementptr inbounds i8, i8* %25, i64 4
  %41 = bitcast i8* %40 to i32*
  store i32 %39, i32* %41, align 4
  %42 = getelementptr inbounds float, float* %2, i64 8
  %43 = bitcast float* %42 to i32*
  %44 = load i32, i32* %43, align 4
  %45 = getelementptr inbounds i8, i8* %23, i64 8
  %46 = bitcast i8* %45 to i32*
  store i32 %44, i32* %46, align 4
  %47 = bitcast i8* %12 to i32*
  %48 = load i32, i32* %47, align 4
  %49 = getelementptr inbounds i8, i8* %25, i64 8
  %50 = bitcast i8* %49 to i32*
  store i32 %48, i32* %50, align 4
  %51 = getelementptr inbounds float, float* %2, i64 12
  %52 = bitcast float* %51 to i32*
  %53 = load i32, i32* %52, align 4
  %54 = getelementptr inbounds i8, i8* %23, i64 12
  %55 = bitcast i8* %54 to i32*
  store i32 %53, i32* %55, align 4
  %56 = bitcast i8* %16 to i32*
  %57 = load i32, i32* %56, align 4
  %58 = getelementptr inbounds i8, i8* %25, i64 12
  %59 = bitcast i8* %58 to i32*
  store i32 %57, i32* %59, align 4
  %60 = load float, float* %24, align 4
  %61 = fcmp ogt float %60, 0.000000e+00
  %62 = zext i1 %61 to i32
  %63 = fcmp olt float %60, 0.000000e+00
  %.neg = sext i1 %63 to i32
  %64 = add nsw i32 %.neg, %62
  %65 = sitofp i32 %64 to float
  %66 = fpext float %60 to double
  %square = fmul double %66, %66
  %67 = fadd double %square, 0.000000e+00
  %68 = fptrunc double %67 to float
  %69 = bitcast i8* %36 to float*
  %70 = load float, float* %69, align 4
  %71 = fpext float %70 to double
  %square202 = fmul double %71, %71
  %72 = fpext float %68 to double
  %73 = fadd double %square202, %72
  %74 = fptrunc double %73 to float
  %75 = bitcast i8* %45 to float*
  %76 = load float, float* %75, align 4
  %77 = fpext float %76 to double
  %square203 = fmul double %77, %77
  %78 = fpext float %74 to double
  %79 = fadd double %square203, %78
  %80 = fptrunc double %79 to float
  %81 = bitcast i8* %54 to float*
  %82 = load float, float* %81, align 4
  %83 = fpext float %82 to double
  %square204 = fmul double %83, %83
  %84 = fpext float %80 to double
  %85 = fadd double %square204, %84
  %86 = fptrunc double %85 to float
  %87 = fneg float %65
  %88 = call float @llvm.sqrt.f32(float %86) #8
  %89 = fmul float %88, %87
  %90 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #9
  %91 = bitcast i8* %90 to float*
  %92 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #9
  %93 = load float, float* %24, align 4
  %94 = load float, float* %26, align 4
  %95 = fmul float %89, %94
  %96 = fadd float %93, %95
  store float %96, float* %91, align 4
  %97 = load float, float* %69, align 4
  %98 = bitcast i8* %40 to float*
  %99 = load float, float* %98, align 4
  %100 = fmul float %89, %99
  %101 = fadd float %97, %100
  %102 = getelementptr inbounds i8, i8* %90, i64 4
  %103 = bitcast i8* %102 to float*
  store float %101, float* %103, align 4
  %104 = load float, float* %75, align 4
  %105 = bitcast i8* %49 to float*
  %106 = load float, float* %105, align 4
  %107 = fmul float %89, %106
  %108 = fadd float %104, %107
  %109 = getelementptr inbounds i8, i8* %90, i64 8
  %110 = bitcast i8* %109 to float*
  store float %108, float* %110, align 4
  %111 = load float, float* %81, align 4
  %112 = bitcast i8* %58 to float*
  %113 = load float, float* %112, align 4
  %114 = fmul float %89, %113
  %115 = fadd float %111, %114
  %116 = getelementptr inbounds i8, i8* %90, i64 12
  %117 = bitcast i8* %116 to float*
  store float %115, float* %117, align 4
  %118 = fpext float %96 to double
  %square205 = fmul double %118, %118
  %119 = fadd double %square205, 0.000000e+00
  %120 = fptrunc double %119 to float
  %121 = fpext float %101 to double
  %square206 = fmul double %121, %121
  %122 = fpext float %120 to double
  %123 = fadd double %square206, %122
  %124 = fptrunc double %123 to float
  %125 = fpext float %108 to double
  %square207 = fmul double %125, %125
  %126 = fpext float %124 to double
  %127 = fadd double %square207, %126
  %128 = fptrunc double %127 to float
  %129 = fpext float %115 to double
  %square208 = fmul double %129, %129
  %130 = fpext float %128 to double
  %131 = fadd double %square208, %130
  %132 = fptrunc double %131 to float
  %133 = bitcast i8* %92 to float*
  %134 = call float @llvm.sqrt.f32(float %132) #8
  %135 = fdiv float %96, %134
  store float %135, float* %133, align 4
  %136 = load float, float* %103, align 4
  %137 = fdiv float %136, %134
  %138 = getelementptr inbounds i8, i8* %92, i64 4
  %139 = bitcast i8* %138 to float*
  store float %137, float* %139, align 4
  %140 = load float, float* %110, align 4
  %141 = fdiv float %140, %134
  %142 = getelementptr inbounds i8, i8* %92, i64 8
  %143 = bitcast i8* %142 to float*
  store float %141, float* %143, align 4
  %144 = load float, float* %117, align 4
  %145 = fdiv float %144, %134
  %146 = getelementptr inbounds i8, i8* %92, i64 12
  %147 = bitcast i8* %146 to float*
  store float %145, float* %147, align 4
  %148 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #9
  %149 = bitcast i8* %148 to float*
  %150 = load float, float* %133, align 4
  %151 = fmul float %150, 2.000000e+00
  %152 = fmul float %151, %150
  %153 = fsub float 1.000000e+00, %152
  store float %153, float* %149, align 4
  %154 = load float, float* %133, align 4
  %155 = fmul float %154, 2.000000e+00
  %156 = load float, float* %139, align 4
  %157 = fmul float %155, %156
  %158 = fsub float 0.000000e+00, %157
  %159 = getelementptr inbounds i8, i8* %148, i64 4
  %160 = bitcast i8* %159 to float*
  store float %158, float* %160, align 4
  %161 = load float, float* %133, align 4
  %162 = fmul float %161, 2.000000e+00
  %163 = load float, float* %143, align 4
  %164 = fmul float %162, %163
  %165 = fsub float 0.000000e+00, %164
  %166 = getelementptr inbounds i8, i8* %148, i64 8
  %167 = bitcast i8* %166 to float*
  store float %165, float* %167, align 4
  %168 = load float, float* %133, align 4
  %169 = fmul float %168, 2.000000e+00
  %170 = load float, float* %147, align 4
  %171 = fmul float %169, %170
  %172 = fsub float 0.000000e+00, %171
  %173 = getelementptr inbounds i8, i8* %148, i64 12
  %174 = bitcast i8* %173 to float*
  store float %172, float* %174, align 4
  %175 = load float, float* %139, align 4
  %176 = fmul float %175, 2.000000e+00
  %177 = load float, float* %133, align 4
  %178 = fmul float %176, %177
  %179 = fsub float 0.000000e+00, %178
  %180 = getelementptr inbounds i8, i8* %148, i64 16
  %181 = bitcast i8* %180 to float*
  store float %179, float* %181, align 4
  %182 = load float, float* %139, align 4
  %183 = fmul float %182, 2.000000e+00
  %184 = fmul float %183, %182
  %185 = fsub float 1.000000e+00, %184
  %186 = getelementptr inbounds i8, i8* %148, i64 20
  %187 = bitcast i8* %186 to float*
  store float %185, float* %187, align 4
  %188 = load float, float* %139, align 4
  %189 = fmul float %188, 2.000000e+00
  %190 = load float, float* %143, align 4
  %191 = fmul float %189, %190
  %192 = fsub float 0.000000e+00, %191
  %193 = getelementptr inbounds i8, i8* %148, i64 24
  %194 = bitcast i8* %193 to float*
  store float %192, float* %194, align 4
  %195 = load float, float* %139, align 4
  %196 = fmul float %195, 2.000000e+00
  %197 = load float, float* %147, align 4
  %198 = fmul float %196, %197
  %199 = fsub float 0.000000e+00, %198
  %200 = getelementptr inbounds i8, i8* %148, i64 28
  %201 = bitcast i8* %200 to float*
  store float %199, float* %201, align 4
  %202 = load float, float* %143, align 4
  %203 = fmul float %202, 2.000000e+00
  %204 = load float, float* %133, align 4
  %205 = fmul float %203, %204
  %206 = fsub float 0.000000e+00, %205
  %207 = getelementptr inbounds i8, i8* %148, i64 32
  %208 = bitcast i8* %207 to float*
  store float %206, float* %208, align 4
  %209 = load float, float* %143, align 4
  %210 = fmul float %209, 2.000000e+00
  %211 = load float, float* %139, align 4
  %212 = fmul float %210, %211
  %213 = fsub float 0.000000e+00, %212
  %214 = getelementptr inbounds i8, i8* %148, i64 36
  %215 = bitcast i8* %214 to float*
  store float %213, float* %215, align 4
  %216 = load float, float* %143, align 4
  %217 = fmul float %216, 2.000000e+00
  %218 = fmul float %217, %216
  %219 = fsub float 1.000000e+00, %218
  %220 = getelementptr inbounds i8, i8* %148, i64 40
  %221 = bitcast i8* %220 to float*
  store float %219, float* %221, align 4
  %222 = load float, float* %143, align 4
  %223 = fmul float %222, 2.000000e+00
  %224 = load float, float* %147, align 4
  %225 = fmul float %223, %224
  %226 = fsub float 0.000000e+00, %225
  %227 = getelementptr inbounds i8, i8* %148, i64 44
  %228 = bitcast i8* %227 to float*
  store float %226, float* %228, align 4
  %229 = load float, float* %147, align 4
  %230 = fmul float %229, 2.000000e+00
  %231 = load float, float* %133, align 4
  %232 = fmul float %230, %231
  %233 = fsub float 0.000000e+00, %232
  %234 = getelementptr inbounds i8, i8* %148, i64 48
  %235 = bitcast i8* %234 to float*
  store float %233, float* %235, align 4
  %236 = load float, float* %147, align 4
  %237 = fmul float %236, 2.000000e+00
  %238 = load float, float* %139, align 4
  %239 = fmul float %237, %238
  %240 = fsub float 0.000000e+00, %239
  %241 = getelementptr inbounds i8, i8* %148, i64 52
  %242 = bitcast i8* %241 to float*
  store float %240, float* %242, align 4
  %243 = load float, float* %147, align 4
  %244 = fmul float %243, 2.000000e+00
  %245 = load float, float* %143, align 4
  %246 = fmul float %244, %245
  %247 = fsub float 0.000000e+00, %246
  %248 = getelementptr inbounds i8, i8* %148, i64 56
  %249 = bitcast i8* %248 to float*
  store float %247, float* %249, align 4
  %250 = load float, float* %147, align 4
  %251 = fmul float %250, 2.000000e+00
  %252 = fmul float %251, %250
  %253 = fsub float 1.000000e+00, %252
  %254 = getelementptr inbounds i8, i8* %148, i64 60
  %255 = bitcast i8* %254 to float*
  store float %253, float* %255, align 4
  %256 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #9
  %257 = bitcast i8* %256 to float*
  %258 = bitcast i8* %148 to i32*
  %259 = load i32, i32* %258, align 4
  %260 = bitcast i8* %256 to i32*
  store i32 %259, i32* %260, align 4
  %261 = bitcast i8* %159 to i32*
  %262 = load i32, i32* %261, align 4
  %263 = getelementptr inbounds i8, i8* %256, i64 4
  %264 = bitcast i8* %263 to i32*
  store i32 %262, i32* %264, align 4
  %265 = bitcast i8* %166 to i32*
  %266 = load i32, i32* %265, align 4
  %267 = getelementptr inbounds i8, i8* %256, i64 8
  %268 = bitcast i8* %267 to i32*
  store i32 %266, i32* %268, align 4
  %269 = bitcast i8* %173 to i32*
  %270 = load i32, i32* %269, align 4
  %271 = getelementptr inbounds i8, i8* %256, i64 12
  %272 = bitcast i8* %271 to i32*
  store i32 %270, i32* %272, align 4
  %273 = bitcast i8* %180 to i32*
  %274 = load i32, i32* %273, align 4
  %275 = getelementptr inbounds i8, i8* %256, i64 16
  %276 = bitcast i8* %275 to i32*
  store i32 %274, i32* %276, align 4
  %277 = bitcast i8* %186 to i32*
  %278 = load i32, i32* %277, align 4
  %279 = getelementptr inbounds i8, i8* %256, i64 20
  %280 = bitcast i8* %279 to i32*
  store i32 %278, i32* %280, align 4
  %281 = bitcast i8* %193 to i32*
  %282 = load i32, i32* %281, align 4
  %283 = getelementptr inbounds i8, i8* %256, i64 24
  %284 = bitcast i8* %283 to i32*
  store i32 %282, i32* %284, align 4
  %285 = bitcast i8* %200 to i32*
  %286 = load i32, i32* %285, align 4
  %287 = getelementptr inbounds i8, i8* %256, i64 28
  %288 = bitcast i8* %287 to i32*
  store i32 %286, i32* %288, align 4
  %289 = bitcast i8* %207 to i32*
  %290 = load i32, i32* %289, align 4
  %291 = getelementptr inbounds i8, i8* %256, i64 32
  %292 = bitcast i8* %291 to i32*
  store i32 %290, i32* %292, align 4
  %293 = bitcast i8* %214 to i32*
  %294 = load i32, i32* %293, align 4
  %295 = getelementptr inbounds i8, i8* %256, i64 36
  %296 = bitcast i8* %295 to i32*
  store i32 %294, i32* %296, align 4
  %297 = bitcast i8* %220 to i32*
  %298 = load i32, i32* %297, align 4
  %299 = getelementptr inbounds i8, i8* %256, i64 40
  %300 = bitcast i8* %299 to i32*
  store i32 %298, i32* %300, align 4
  %301 = bitcast i8* %227 to i32*
  %302 = load i32, i32* %301, align 4
  %303 = getelementptr inbounds i8, i8* %256, i64 44
  %304 = bitcast i8* %303 to i32*
  store i32 %302, i32* %304, align 4
  %305 = bitcast i8* %234 to i32*
  %306 = load i32, i32* %305, align 4
  %307 = getelementptr inbounds i8, i8* %256, i64 48
  %308 = bitcast i8* %307 to i32*
  store i32 %306, i32* %308, align 4
  %309 = bitcast i8* %241 to i32*
  %310 = load i32, i32* %309, align 4
  %311 = getelementptr inbounds i8, i8* %256, i64 52
  %312 = bitcast i8* %311 to i32*
  store i32 %310, i32* %312, align 4
  %313 = bitcast i8* %248 to i32*
  %314 = load i32, i32* %313, align 4
  %315 = getelementptr inbounds i8, i8* %256, i64 56
  %316 = bitcast i8* %315 to i32*
  store i32 %314, i32* %316, align 4
  %317 = bitcast i8* %254 to i32*
  %318 = load i32, i32* %317, align 4
  %319 = getelementptr inbounds i8, i8* %256, i64 60
  %320 = bitcast i8* %319 to i32*
  store i32 %318, i32* %320, align 4
  %321 = call i8* @__memcpy_chk(i8* %21, i8* %256, i64 64, i64 %22) #8
  store float 0.000000e+00, float* %2, align 4
  %322 = load float, float* %257, align 4
  %323 = load float, float* %0, align 4
  %324 = fmul float %322, %323
  %325 = fadd float %324, 0.000000e+00
  store float %325, float* %2, align 4
  %326 = bitcast i8* %263 to float*
  %327 = load float, float* %326, align 4
  %328 = getelementptr inbounds float, float* %0, i64 4
  %329 = load float, float* %328, align 4
  %330 = fmul float %327, %329
  %331 = fadd float %325, %330
  store float %331, float* %2, align 4
  %332 = bitcast i8* %267 to float*
  %333 = load float, float* %332, align 4
  %334 = getelementptr inbounds float, float* %0, i64 8
  %335 = load float, float* %334, align 4
  %336 = fmul float %333, %335
  %337 = fadd float %331, %336
  store float %337, float* %2, align 4
  %338 = bitcast i8* %271 to float*
  %339 = load float, float* %338, align 4
  %340 = getelementptr inbounds float, float* %0, i64 12
  %341 = load float, float* %340, align 4
  %342 = fmul float %339, %341
  %343 = fadd float %337, %342
  store float %343, float* %2, align 4
  %344 = getelementptr inbounds float, float* %2, i64 1
  store float 0.000000e+00, float* %344, align 4
  %345 = load float, float* %257, align 4
  %346 = getelementptr inbounds float, float* %0, i64 1
  %347 = load float, float* %346, align 4
  %348 = fmul float %345, %347
  %349 = fadd float %348, 0.000000e+00
  store float %349, float* %344, align 4
  %350 = load float, float* %326, align 4
  %351 = getelementptr inbounds float, float* %0, i64 5
  %352 = load float, float* %351, align 4
  %353 = fmul float %350, %352
  %354 = fadd float %349, %353
  store float %354, float* %344, align 4
  %355 = load float, float* %332, align 4
  %356 = getelementptr inbounds float, float* %0, i64 9
  %357 = load float, float* %356, align 4
  %358 = fmul float %355, %357
  %359 = fadd float %354, %358
  store float %359, float* %344, align 4
  %360 = load float, float* %338, align 4
  %361 = getelementptr inbounds float, float* %0, i64 13
  %362 = load float, float* %361, align 4
  %363 = fmul float %360, %362
  %364 = fadd float %359, %363
  store float %364, float* %344, align 4
  %365 = getelementptr inbounds float, float* %2, i64 2
  store float 0.000000e+00, float* %365, align 4
  %366 = load float, float* %257, align 4
  %367 = getelementptr inbounds float, float* %0, i64 2
  %368 = load float, float* %367, align 4
  %369 = fmul float %366, %368
  %370 = fadd float %369, 0.000000e+00
  store float %370, float* %365, align 4
  %371 = load float, float* %326, align 4
  %372 = getelementptr inbounds float, float* %0, i64 6
  %373 = load float, float* %372, align 4
  %374 = fmul float %371, %373
  %375 = fadd float %370, %374
  store float %375, float* %365, align 4
  %376 = load float, float* %332, align 4
  %377 = getelementptr inbounds float, float* %0, i64 10
  %378 = load float, float* %377, align 4
  %379 = fmul float %376, %378
  %380 = fadd float %375, %379
  store float %380, float* %365, align 4
  %381 = load float, float* %338, align 4
  %382 = getelementptr inbounds float, float* %0, i64 14
  %383 = load float, float* %382, align 4
  %384 = fmul float %381, %383
  %385 = fadd float %380, %384
  store float %385, float* %365, align 4
  %386 = getelementptr inbounds float, float* %2, i64 3
  store float 0.000000e+00, float* %386, align 4
  %387 = load float, float* %257, align 4
  %388 = getelementptr inbounds float, float* %0, i64 3
  %389 = load float, float* %388, align 4
  %390 = fmul float %387, %389
  %391 = fadd float %390, 0.000000e+00
  store float %391, float* %386, align 4
  %392 = load float, float* %326, align 4
  %393 = getelementptr inbounds float, float* %0, i64 7
  %394 = load float, float* %393, align 4
  %395 = fmul float %392, %394
  %396 = fadd float %391, %395
  store float %396, float* %386, align 4
  %397 = load float, float* %332, align 4
  %398 = getelementptr inbounds float, float* %0, i64 11
  %399 = load float, float* %398, align 4
  %400 = fmul float %397, %399
  %401 = fadd float %396, %400
  store float %401, float* %386, align 4
  %402 = load float, float* %338, align 4
  %403 = getelementptr inbounds float, float* %0, i64 15
  %404 = load float, float* %403, align 4
  %405 = fmul float %402, %404
  %406 = fadd float %401, %405
  store float %406, float* %386, align 4
  %407 = bitcast i8* %275 to float*
  store float 0.000000e+00, float* %33, align 4
  %408 = load float, float* %407, align 4
  %409 = load float, float* %0, align 4
  %410 = fmul float %408, %409
  %411 = fadd float %410, 0.000000e+00
  store float %411, float* %33, align 4
  %412 = bitcast i8* %279 to float*
  %413 = load float, float* %412, align 4
  %414 = load float, float* %328, align 4
  %415 = fmul float %413, %414
  %416 = fadd float %411, %415
  store float %416, float* %33, align 4
  %417 = bitcast i8* %283 to float*
  %418 = load float, float* %417, align 4
  %419 = load float, float* %334, align 4
  %420 = fmul float %418, %419
  %421 = fadd float %416, %420
  store float %421, float* %33, align 4
  %422 = bitcast i8* %287 to float*
  %423 = load float, float* %422, align 4
  %424 = load float, float* %340, align 4
  %425 = fmul float %423, %424
  %426 = fadd float %421, %425
  store float %426, float* %33, align 4
  %427 = getelementptr inbounds float, float* %2, i64 5
  store float 0.000000e+00, float* %427, align 4
  %428 = load float, float* %407, align 4
  %429 = load float, float* %346, align 4
  %430 = fmul float %428, %429
  %431 = fadd float %430, 0.000000e+00
  store float %431, float* %427, align 4
  %432 = load float, float* %412, align 4
  %433 = load float, float* %351, align 4
  %434 = fmul float %432, %433
  %435 = fadd float %431, %434
  store float %435, float* %427, align 4
  %436 = load float, float* %417, align 4
  %437 = load float, float* %356, align 4
  %438 = fmul float %436, %437
  %439 = fadd float %435, %438
  store float %439, float* %427, align 4
  %440 = load float, float* %422, align 4
  %441 = load float, float* %361, align 4
  %442 = fmul float %440, %441
  %443 = fadd float %439, %442
  store float %443, float* %427, align 4
  %444 = getelementptr inbounds float, float* %2, i64 6
  store float 0.000000e+00, float* %444, align 4
  %445 = load float, float* %407, align 4
  %446 = load float, float* %367, align 4
  %447 = fmul float %445, %446
  %448 = fadd float %447, 0.000000e+00
  store float %448, float* %444, align 4
  %449 = load float, float* %412, align 4
  %450 = load float, float* %372, align 4
  %451 = fmul float %449, %450
  %452 = fadd float %448, %451
  store float %452, float* %444, align 4
  %453 = load float, float* %417, align 4
  %454 = load float, float* %377, align 4
  %455 = fmul float %453, %454
  %456 = fadd float %452, %455
  store float %456, float* %444, align 4
  %457 = load float, float* %422, align 4
  %458 = load float, float* %382, align 4
  %459 = fmul float %457, %458
  %460 = fadd float %456, %459
  store float %460, float* %444, align 4
  %461 = getelementptr inbounds float, float* %2, i64 7
  store float 0.000000e+00, float* %461, align 4
  %462 = load float, float* %407, align 4
  %463 = load float, float* %388, align 4
  %464 = fmul float %462, %463
  %465 = fadd float %464, 0.000000e+00
  store float %465, float* %461, align 4
  %466 = load float, float* %412, align 4
  %467 = load float, float* %393, align 4
  %468 = fmul float %466, %467
  %469 = fadd float %465, %468
  store float %469, float* %461, align 4
  %470 = load float, float* %417, align 4
  %471 = load float, float* %398, align 4
  %472 = fmul float %470, %471
  %473 = fadd float %469, %472
  store float %473, float* %461, align 4
  %474 = load float, float* %422, align 4
  %475 = load float, float* %403, align 4
  %476 = fmul float %474, %475
  %477 = fadd float %473, %476
  store float %477, float* %461, align 4
  %478 = bitcast i8* %291 to float*
  store float 0.000000e+00, float* %42, align 4
  %479 = load float, float* %478, align 4
  %480 = load float, float* %0, align 4
  %481 = fmul float %479, %480
  %482 = fadd float %481, 0.000000e+00
  store float %482, float* %42, align 4
  %483 = bitcast i8* %295 to float*
  %484 = load float, float* %483, align 4
  %485 = load float, float* %328, align 4
  %486 = fmul float %484, %485
  %487 = fadd float %482, %486
  store float %487, float* %42, align 4
  %488 = bitcast i8* %299 to float*
  %489 = load float, float* %488, align 4
  %490 = load float, float* %334, align 4
  %491 = fmul float %489, %490
  %492 = fadd float %487, %491
  store float %492, float* %42, align 4
  %493 = bitcast i8* %303 to float*
  %494 = load float, float* %493, align 4
  %495 = load float, float* %340, align 4
  %496 = fmul float %494, %495
  %497 = fadd float %492, %496
  store float %497, float* %42, align 4
  %498 = getelementptr inbounds float, float* %2, i64 9
  store float 0.000000e+00, float* %498, align 4
  %499 = load float, float* %478, align 4
  %500 = load float, float* %346, align 4
  %501 = fmul float %499, %500
  %502 = fadd float %501, 0.000000e+00
  store float %502, float* %498, align 4
  %503 = load float, float* %483, align 4
  %504 = load float, float* %351, align 4
  %505 = fmul float %503, %504
  %506 = fadd float %502, %505
  store float %506, float* %498, align 4
  %507 = load float, float* %488, align 4
  %508 = load float, float* %356, align 4
  %509 = fmul float %507, %508
  %510 = fadd float %506, %509
  store float %510, float* %498, align 4
  %511 = load float, float* %493, align 4
  %512 = load float, float* %361, align 4
  %513 = fmul float %511, %512
  %514 = fadd float %510, %513
  store float %514, float* %498, align 4
  %515 = getelementptr inbounds float, float* %2, i64 10
  store float 0.000000e+00, float* %515, align 4
  %516 = load float, float* %478, align 4
  %517 = load float, float* %367, align 4
  %518 = fmul float %516, %517
  %519 = fadd float %518, 0.000000e+00
  store float %519, float* %515, align 4
  %520 = load float, float* %483, align 4
  %521 = load float, float* %372, align 4
  %522 = fmul float %520, %521
  %523 = fadd float %519, %522
  store float %523, float* %515, align 4
  %524 = load float, float* %488, align 4
  %525 = load float, float* %377, align 4
  %526 = fmul float %524, %525
  %527 = fadd float %523, %526
  store float %527, float* %515, align 4
  %528 = load float, float* %493, align 4
  %529 = load float, float* %382, align 4
  %530 = fmul float %528, %529
  %531 = fadd float %527, %530
  store float %531, float* %515, align 4
  %532 = getelementptr inbounds float, float* %2, i64 11
  store float 0.000000e+00, float* %532, align 4
  %533 = load float, float* %478, align 4
  %534 = load float, float* %388, align 4
  %535 = fmul float %533, %534
  %536 = fadd float %535, 0.000000e+00
  store float %536, float* %532, align 4
  %537 = load float, float* %483, align 4
  %538 = load float, float* %393, align 4
  %539 = fmul float %537, %538
  %540 = fadd float %536, %539
  store float %540, float* %532, align 4
  %541 = load float, float* %488, align 4
  %542 = load float, float* %398, align 4
  %543 = fmul float %541, %542
  %544 = fadd float %540, %543
  store float %544, float* %532, align 4
  %545 = load float, float* %493, align 4
  %546 = load float, float* %403, align 4
  %547 = fmul float %545, %546
  %548 = fadd float %544, %547
  store float %548, float* %532, align 4
  %549 = bitcast i8* %307 to float*
  store float 0.000000e+00, float* %51, align 4
  %550 = load float, float* %549, align 4
  %551 = load float, float* %0, align 4
  %552 = fmul float %550, %551
  %553 = fadd float %552, 0.000000e+00
  store float %553, float* %51, align 4
  %554 = bitcast i8* %311 to float*
  %555 = load float, float* %554, align 4
  %556 = load float, float* %328, align 4
  %557 = fmul float %555, %556
  %558 = fadd float %553, %557
  store float %558, float* %51, align 4
  %559 = bitcast i8* %315 to float*
  %560 = load float, float* %559, align 4
  %561 = load float, float* %334, align 4
  %562 = fmul float %560, %561
  %563 = fadd float %558, %562
  store float %563, float* %51, align 4
  %564 = bitcast i8* %319 to float*
  %565 = load float, float* %564, align 4
  %566 = load float, float* %340, align 4
  %567 = fmul float %565, %566
  %568 = fadd float %563, %567
  store float %568, float* %51, align 4
  %569 = getelementptr inbounds float, float* %2, i64 13
  store float 0.000000e+00, float* %569, align 4
  %570 = load float, float* %549, align 4
  %571 = load float, float* %346, align 4
  %572 = fmul float %570, %571
  %573 = fadd float %572, 0.000000e+00
  store float %573, float* %569, align 4
  %574 = load float, float* %554, align 4
  %575 = load float, float* %351, align 4
  %576 = fmul float %574, %575
  %577 = fadd float %573, %576
  store float %577, float* %569, align 4
  %578 = load float, float* %559, align 4
  %579 = load float, float* %356, align 4
  %580 = fmul float %578, %579
  %581 = fadd float %577, %580
  store float %581, float* %569, align 4
  %582 = load float, float* %564, align 4
  %583 = load float, float* %361, align 4
  %584 = fmul float %582, %583
  %585 = fadd float %581, %584
  store float %585, float* %569, align 4
  %586 = getelementptr inbounds float, float* %2, i64 14
  store float 0.000000e+00, float* %586, align 4
  %587 = load float, float* %549, align 4
  %588 = load float, float* %367, align 4
  %589 = fmul float %587, %588
  %590 = fadd float %589, 0.000000e+00
  store float %590, float* %586, align 4
  %591 = load float, float* %554, align 4
  %592 = load float, float* %372, align 4
  %593 = fmul float %591, %592
  %594 = fadd float %590, %593
  store float %594, float* %586, align 4
  %595 = load float, float* %559, align 4
  %596 = load float, float* %377, align 4
  %597 = fmul float %595, %596
  %598 = fadd float %594, %597
  store float %598, float* %586, align 4
  %599 = load float, float* %564, align 4
  %600 = load float, float* %382, align 4
  %601 = fmul float %599, %600
  %602 = fadd float %598, %601
  store float %602, float* %586, align 4
  %603 = getelementptr inbounds float, float* %2, i64 15
  store float 0.000000e+00, float* %603, align 4
  %604 = load float, float* %549, align 4
  %605 = load float, float* %388, align 4
  %606 = fmul float %604, %605
  %607 = fadd float %606, 0.000000e+00
  store float %607, float* %603, align 4
  %608 = load float, float* %554, align 4
  %609 = load float, float* %393, align 4
  %610 = fmul float %608, %609
  %611 = fadd float %607, %610
  store float %611, float* %603, align 4
  %612 = load float, float* %559, align 4
  %613 = load float, float* %398, align 4
  %614 = fmul float %612, %613
  %615 = fadd float %611, %614
  store float %615, float* %603, align 4
  %616 = load float, float* %564, align 4
  %617 = load float, float* %403, align 4
  %618 = fmul float %616, %617
  %619 = fadd float %615, %618
  store float %619, float* %603, align 4
  call void @free(i8* %23)
  call void @free(i8* %25)
  call void @free(i8* %90)
  call void @free(i8* %92)
  call void @free(i8* %148)
  call void @free(i8* %256)
  %620 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #9
  %621 = bitcast i8* %620 to float*
  %622 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #9
  %623 = bitcast i8* %622 to float*
  %624 = bitcast float* %427 to i32*
  %625 = load i32, i32* %624, align 4
  %626 = bitcast i8* %620 to i32*
  store i32 %625, i32* %626, align 4
  %627 = bitcast i8* %10 to i32*
  %628 = load i32, i32* %627, align 4
  %629 = bitcast i8* %622 to i32*
  store i32 %628, i32* %629, align 4
  %630 = bitcast float* %498 to i32*
  %631 = load i32, i32* %630, align 4
  %632 = getelementptr inbounds i8, i8* %620, i64 4
  %633 = bitcast i8* %632 to i32*
  store i32 %631, i32* %633, align 4
  %634 = bitcast i8* %13 to i32*
  %635 = load i32, i32* %634, align 4
  %636 = getelementptr inbounds i8, i8* %622, i64 4
  %637 = bitcast i8* %636 to i32*
  store i32 %635, i32* %637, align 4
  %638 = bitcast float* %569 to i32*
  %639 = load i32, i32* %638, align 4
  %640 = getelementptr inbounds i8, i8* %620, i64 8
  %641 = bitcast i8* %640 to i32*
  store i32 %639, i32* %641, align 4
  %642 = bitcast i8* %17 to i32*
  %643 = load i32, i32* %642, align 4
  %644 = getelementptr inbounds i8, i8* %622, i64 8
  %645 = bitcast i8* %644 to i32*
  store i32 %643, i32* %645, align 4
  %646 = load float, float* %621, align 4
  %647 = fcmp ogt float %646, 0.000000e+00
  %648 = zext i1 %647 to i32
  %649 = fcmp olt float %646, 0.000000e+00
  %.neg209 = sext i1 %649 to i32
  %650 = add nsw i32 %.neg209, %648
  %651 = sitofp i32 %650 to float
  %652 = fpext float %646 to double
  %square210 = fmul double %652, %652
  %653 = fadd double %square210, 0.000000e+00
  %654 = fptrunc double %653 to float
  %655 = bitcast i8* %632 to float*
  %656 = load float, float* %655, align 4
  %657 = fpext float %656 to double
  %square211 = fmul double %657, %657
  %658 = fpext float %654 to double
  %659 = fadd double %square211, %658
  %660 = fptrunc double %659 to float
  %661 = bitcast i8* %640 to float*
  %662 = load float, float* %661, align 4
  %663 = fpext float %662 to double
  %square212 = fmul double %663, %663
  %664 = fpext float %660 to double
  %665 = fadd double %square212, %664
  %666 = fptrunc double %665 to float
  %667 = fneg float %651
  %668 = call float @llvm.sqrt.f32(float %666) #8
  %669 = fmul float %668, %667
  %670 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #9
  %671 = bitcast i8* %670 to float*
  %672 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #9
  %673 = load float, float* %621, align 4
  %674 = load float, float* %623, align 4
  %675 = fmul float %669, %674
  %676 = fadd float %673, %675
  store float %676, float* %671, align 4
  %677 = load float, float* %655, align 4
  %678 = bitcast i8* %636 to float*
  %679 = load float, float* %678, align 4
  %680 = fmul float %669, %679
  %681 = fadd float %677, %680
  %682 = getelementptr inbounds i8, i8* %670, i64 4
  %683 = bitcast i8* %682 to float*
  store float %681, float* %683, align 4
  %684 = load float, float* %661, align 4
  %685 = bitcast i8* %644 to float*
  %686 = load float, float* %685, align 4
  %687 = fmul float %669, %686
  %688 = fadd float %684, %687
  %689 = getelementptr inbounds i8, i8* %670, i64 8
  %690 = bitcast i8* %689 to float*
  store float %688, float* %690, align 4
  %691 = fpext float %676 to double
  %square213 = fmul double %691, %691
  %692 = fadd double %square213, 0.000000e+00
  %693 = fptrunc double %692 to float
  %694 = fpext float %681 to double
  %square214 = fmul double %694, %694
  %695 = fpext float %693 to double
  %696 = fadd double %square214, %695
  %697 = fptrunc double %696 to float
  %698 = fpext float %688 to double
  %square215 = fmul double %698, %698
  %699 = fpext float %697 to double
  %700 = fadd double %square215, %699
  %701 = fptrunc double %700 to float
  %702 = bitcast i8* %672 to float*
  %703 = call float @llvm.sqrt.f32(float %701) #8
  %704 = fdiv float %676, %703
  store float %704, float* %702, align 4
  %705 = load float, float* %683, align 4
  %706 = fdiv float %705, %703
  %707 = getelementptr inbounds i8, i8* %672, i64 4
  %708 = bitcast i8* %707 to float*
  store float %706, float* %708, align 4
  %709 = load float, float* %690, align 4
  %710 = fdiv float %709, %703
  %711 = getelementptr inbounds i8, i8* %672, i64 8
  %712 = bitcast i8* %711 to float*
  store float %710, float* %712, align 4
  %713 = call dereferenceable_or_null(36) i8* @calloc(i64 4, i64 9) #9
  %714 = bitcast i8* %713 to float*
  %715 = load float, float* %702, align 4
  %716 = fmul float %715, 2.000000e+00
  %717 = fmul float %716, %715
  %718 = fsub float 1.000000e+00, %717
  store float %718, float* %714, align 4
  %719 = load float, float* %702, align 4
  %720 = fmul float %719, 2.000000e+00
  %721 = load float, float* %708, align 4
  %722 = fmul float %720, %721
  %723 = fsub float 0.000000e+00, %722
  %724 = getelementptr inbounds i8, i8* %713, i64 4
  %725 = bitcast i8* %724 to float*
  store float %723, float* %725, align 4
  %726 = load float, float* %702, align 4
  %727 = fmul float %726, 2.000000e+00
  %728 = load float, float* %712, align 4
  %729 = fmul float %727, %728
  %730 = fsub float 0.000000e+00, %729
  %731 = getelementptr inbounds i8, i8* %713, i64 8
  %732 = bitcast i8* %731 to float*
  store float %730, float* %732, align 4
  %733 = load float, float* %708, align 4
  %734 = fmul float %733, 2.000000e+00
  %735 = load float, float* %702, align 4
  %736 = fmul float %734, %735
  %737 = fsub float 0.000000e+00, %736
  %738 = getelementptr inbounds i8, i8* %713, i64 12
  %739 = bitcast i8* %738 to float*
  store float %737, float* %739, align 4
  %740 = load float, float* %708, align 4
  %741 = fmul float %740, 2.000000e+00
  %742 = fmul float %741, %740
  %743 = fsub float 1.000000e+00, %742
  %744 = getelementptr inbounds i8, i8* %713, i64 16
  %745 = bitcast i8* %744 to float*
  store float %743, float* %745, align 4
  %746 = load float, float* %708, align 4
  %747 = fmul float %746, 2.000000e+00
  %748 = load float, float* %712, align 4
  %749 = fmul float %747, %748
  %750 = fsub float 0.000000e+00, %749
  %751 = getelementptr inbounds i8, i8* %713, i64 20
  %752 = bitcast i8* %751 to float*
  store float %750, float* %752, align 4
  %753 = load float, float* %712, align 4
  %754 = fmul float %753, 2.000000e+00
  %755 = load float, float* %702, align 4
  %756 = fmul float %754, %755
  %757 = fsub float 0.000000e+00, %756
  %758 = getelementptr inbounds i8, i8* %713, i64 24
  %759 = bitcast i8* %758 to float*
  store float %757, float* %759, align 4
  %760 = load float, float* %712, align 4
  %761 = fmul float %760, 2.000000e+00
  %762 = load float, float* %708, align 4
  %763 = fmul float %761, %762
  %764 = fsub float 0.000000e+00, %763
  %765 = getelementptr inbounds i8, i8* %713, i64 28
  %766 = bitcast i8* %765 to float*
  store float %764, float* %766, align 4
  %767 = load float, float* %712, align 4
  %768 = fmul float %767, 2.000000e+00
  %769 = fmul float %768, %767
  %770 = fsub float 1.000000e+00, %769
  %771 = getelementptr inbounds i8, i8* %713, i64 32
  %772 = bitcast i8* %771 to float*
  store float %770, float* %772, align 4
  %773 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #9
  %774 = bitcast i8* %773 to float*
  store float 1.000000e+00, float* %774, align 4
  %775 = getelementptr inbounds i8, i8* %773, i64 4
  %776 = bitcast i8* %775 to float*
  %777 = getelementptr inbounds i8, i8* %773, i64 8
  %778 = bitcast i8* %777 to float*
  %779 = getelementptr inbounds i8, i8* %773, i64 12
  %780 = bitcast i8* %779 to float*
  %781 = getelementptr inbounds i8, i8* %773, i64 16
  %782 = bitcast i8* %781 to float*
  %783 = bitcast i8* %713 to i32*
  %784 = load i32, i32* %783, align 4
  %785 = getelementptr inbounds i8, i8* %773, i64 20
  %786 = bitcast i8* %785 to i32*
  store i32 %784, i32* %786, align 4
  %787 = bitcast i8* %724 to i32*
  %788 = load i32, i32* %787, align 4
  %789 = getelementptr inbounds i8, i8* %773, i64 24
  %790 = bitcast i8* %789 to i32*
  store i32 %788, i32* %790, align 4
  %791 = bitcast i8* %731 to i32*
  %792 = load i32, i32* %791, align 4
  %793 = getelementptr inbounds i8, i8* %773, i64 28
  %794 = bitcast i8* %793 to i32*
  store i32 %792, i32* %794, align 4
  %795 = getelementptr inbounds i8, i8* %773, i64 32
  %796 = bitcast i8* %795 to float*
  %797 = bitcast i8* %738 to i32*
  %798 = load i32, i32* %797, align 4
  %799 = getelementptr inbounds i8, i8* %773, i64 36
  %800 = bitcast i8* %799 to i32*
  store i32 %798, i32* %800, align 4
  %801 = bitcast i8* %744 to i32*
  %802 = load i32, i32* %801, align 4
  %803 = getelementptr inbounds i8, i8* %773, i64 40
  %804 = bitcast i8* %803 to i32*
  store i32 %802, i32* %804, align 4
  %805 = bitcast i8* %751 to i32*
  %806 = load i32, i32* %805, align 4
  %807 = getelementptr inbounds i8, i8* %773, i64 44
  %808 = bitcast i8* %807 to i32*
  store i32 %806, i32* %808, align 4
  %809 = getelementptr inbounds i8, i8* %773, i64 48
  %810 = bitcast i8* %809 to float*
  %811 = bitcast i8* %758 to i32*
  %812 = load i32, i32* %811, align 4
  %813 = getelementptr inbounds i8, i8* %773, i64 52
  %814 = bitcast i8* %813 to i32*
  store i32 %812, i32* %814, align 4
  %815 = bitcast i8* %765 to i32*
  %816 = load i32, i32* %815, align 4
  %817 = getelementptr inbounds i8, i8* %773, i64 56
  %818 = bitcast i8* %817 to i32*
  store i32 %816, i32* %818, align 4
  %819 = bitcast i8* %771 to i32*
  %820 = load i32, i32* %819, align 4
  %821 = getelementptr inbounds i8, i8* %773, i64 60
  %822 = bitcast i8* %821 to i32*
  store i32 %820, i32* %822, align 4
  %823 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #9
  %824 = bitcast i8* %823 to float*
  %825 = load float, float* %774, align 4
  %826 = load float, float* %1, align 4
  %827 = fmul float %825, %826
  %828 = fadd float %827, 0.000000e+00
  store float %828, float* %824, align 4
  %829 = load float, float* %776, align 4
  %830 = getelementptr inbounds float, float* %1, i64 4
  %831 = load float, float* %830, align 4
  %832 = fmul float %829, %831
  %833 = fadd float %828, %832
  store float %833, float* %824, align 4
  %834 = load float, float* %778, align 4
  %835 = getelementptr inbounds float, float* %1, i64 8
  %836 = load float, float* %835, align 4
  %837 = fmul float %834, %836
  %838 = fadd float %833, %837
  store float %838, float* %824, align 4
  %839 = load float, float* %780, align 4
  %840 = getelementptr inbounds float, float* %1, i64 12
  %841 = load float, float* %840, align 4
  %842 = fmul float %839, %841
  %843 = fadd float %838, %842
  store float %843, float* %824, align 4
  %844 = getelementptr inbounds i8, i8* %823, i64 4
  %845 = bitcast i8* %844 to float*
  %846 = load float, float* %774, align 4
  %847 = getelementptr inbounds float, float* %1, i64 1
  %848 = load float, float* %847, align 4
  %849 = fmul float %846, %848
  %850 = fadd float 0.000000e+00, %849
  store float %850, float* %845, align 4
  %851 = load float, float* %776, align 4
  %852 = getelementptr inbounds float, float* %1, i64 5
  %853 = load float, float* %852, align 4
  %854 = fmul float %851, %853
  %855 = fadd float %850, %854
  store float %855, float* %845, align 4
  %856 = load float, float* %778, align 4
  %857 = getelementptr inbounds float, float* %1, i64 9
  %858 = load float, float* %857, align 4
  %859 = fmul float %856, %858
  %860 = fadd float %855, %859
  store float %860, float* %845, align 4
  %861 = load float, float* %780, align 4
  %862 = getelementptr inbounds float, float* %1, i64 13
  %863 = load float, float* %862, align 4
  %864 = fmul float %861, %863
  %865 = fadd float %860, %864
  store float %865, float* %845, align 4
  %866 = getelementptr inbounds i8, i8* %823, i64 8
  %867 = bitcast i8* %866 to float*
  %868 = load float, float* %774, align 4
  %869 = getelementptr inbounds float, float* %1, i64 2
  %870 = load float, float* %869, align 4
  %871 = fmul float %868, %870
  %872 = fadd float 0.000000e+00, %871
  store float %872, float* %867, align 4
  %873 = load float, float* %776, align 4
  %874 = getelementptr inbounds float, float* %1, i64 6
  %875 = load float, float* %874, align 4
  %876 = fmul float %873, %875
  %877 = fadd float %872, %876
  store float %877, float* %867, align 4
  %878 = load float, float* %778, align 4
  %879 = getelementptr inbounds float, float* %1, i64 10
  %880 = load float, float* %879, align 4
  %881 = fmul float %878, %880
  %882 = fadd float %877, %881
  store float %882, float* %867, align 4
  %883 = load float, float* %780, align 4
  %884 = getelementptr inbounds float, float* %1, i64 14
  %885 = load float, float* %884, align 4
  %886 = fmul float %883, %885
  %887 = fadd float %882, %886
  store float %887, float* %867, align 4
  %888 = getelementptr inbounds i8, i8* %823, i64 12
  %889 = bitcast i8* %888 to float*
  %890 = load float, float* %774, align 4
  %891 = getelementptr inbounds float, float* %1, i64 3
  %892 = load float, float* %891, align 4
  %893 = fmul float %890, %892
  %894 = fadd float 0.000000e+00, %893
  store float %894, float* %889, align 4
  %895 = load float, float* %776, align 4
  %896 = getelementptr inbounds float, float* %1, i64 7
  %897 = load float, float* %896, align 4
  %898 = fmul float %895, %897
  %899 = fadd float %894, %898
  store float %899, float* %889, align 4
  %900 = load float, float* %778, align 4
  %901 = getelementptr inbounds float, float* %1, i64 11
  %902 = load float, float* %901, align 4
  %903 = fmul float %900, %902
  %904 = fadd float %899, %903
  store float %904, float* %889, align 4
  %905 = load float, float* %780, align 4
  %906 = getelementptr inbounds float, float* %1, i64 15
  %907 = load float, float* %906, align 4
  %908 = fmul float %905, %907
  %909 = fadd float %904, %908
  store float %909, float* %889, align 4
  %910 = getelementptr inbounds i8, i8* %823, i64 16
  %911 = bitcast i8* %910 to float*
  %912 = load float, float* %782, align 4
  %913 = load float, float* %1, align 4
  %914 = fmul float %912, %913
  %915 = fadd float %914, 0.000000e+00
  store float %915, float* %911, align 4
  %916 = bitcast i8* %785 to float*
  %917 = load float, float* %916, align 4
  %918 = load float, float* %830, align 4
  %919 = fmul float %917, %918
  %920 = fadd float %915, %919
  store float %920, float* %911, align 4
  %921 = bitcast i8* %789 to float*
  %922 = load float, float* %921, align 4
  %923 = load float, float* %835, align 4
  %924 = fmul float %922, %923
  %925 = fadd float %920, %924
  store float %925, float* %911, align 4
  %926 = bitcast i8* %793 to float*
  %927 = load float, float* %926, align 4
  %928 = load float, float* %840, align 4
  %929 = fmul float %927, %928
  %930 = fadd float %925, %929
  store float %930, float* %911, align 4
  %931 = getelementptr inbounds i8, i8* %823, i64 20
  %932 = bitcast i8* %931 to float*
  %933 = load float, float* %782, align 4
  %934 = load float, float* %847, align 4
  %935 = fmul float %933, %934
  %936 = fadd float 0.000000e+00, %935
  store float %936, float* %932, align 4
  %937 = load float, float* %916, align 4
  %938 = load float, float* %852, align 4
  %939 = fmul float %937, %938
  %940 = fadd float %936, %939
  store float %940, float* %932, align 4
  %941 = load float, float* %921, align 4
  %942 = load float, float* %857, align 4
  %943 = fmul float %941, %942
  %944 = fadd float %940, %943
  store float %944, float* %932, align 4
  %945 = load float, float* %926, align 4
  %946 = load float, float* %862, align 4
  %947 = fmul float %945, %946
  %948 = fadd float %944, %947
  store float %948, float* %932, align 4
  %949 = getelementptr inbounds i8, i8* %823, i64 24
  %950 = bitcast i8* %949 to float*
  %951 = load float, float* %782, align 4
  %952 = load float, float* %869, align 4
  %953 = fmul float %951, %952
  %954 = fadd float 0.000000e+00, %953
  store float %954, float* %950, align 4
  %955 = load float, float* %916, align 4
  %956 = load float, float* %874, align 4
  %957 = fmul float %955, %956
  %958 = fadd float %954, %957
  store float %958, float* %950, align 4
  %959 = load float, float* %921, align 4
  %960 = load float, float* %879, align 4
  %961 = fmul float %959, %960
  %962 = fadd float %958, %961
  store float %962, float* %950, align 4
  %963 = load float, float* %926, align 4
  %964 = load float, float* %884, align 4
  %965 = fmul float %963, %964
  %966 = fadd float %962, %965
  store float %966, float* %950, align 4
  %967 = getelementptr inbounds i8, i8* %823, i64 28
  %968 = bitcast i8* %967 to float*
  %969 = load float, float* %782, align 4
  %970 = load float, float* %891, align 4
  %971 = fmul float %969, %970
  %972 = fadd float 0.000000e+00, %971
  store float %972, float* %968, align 4
  %973 = load float, float* %916, align 4
  %974 = load float, float* %896, align 4
  %975 = fmul float %973, %974
  %976 = fadd float %972, %975
  store float %976, float* %968, align 4
  %977 = load float, float* %921, align 4
  %978 = load float, float* %901, align 4
  %979 = fmul float %977, %978
  %980 = fadd float %976, %979
  store float %980, float* %968, align 4
  %981 = load float, float* %926, align 4
  %982 = load float, float* %906, align 4
  %983 = fmul float %981, %982
  %984 = fadd float %980, %983
  store float %984, float* %968, align 4
  %985 = getelementptr inbounds i8, i8* %823, i64 32
  %986 = bitcast i8* %985 to float*
  %987 = load float, float* %796, align 4
  %988 = load float, float* %1, align 4
  %989 = fmul float %987, %988
  %990 = fadd float %989, 0.000000e+00
  store float %990, float* %986, align 4
  %991 = bitcast i8* %799 to float*
  %992 = load float, float* %991, align 4
  %993 = load float, float* %830, align 4
  %994 = fmul float %992, %993
  %995 = fadd float %990, %994
  store float %995, float* %986, align 4
  %996 = bitcast i8* %803 to float*
  %997 = load float, float* %996, align 4
  %998 = load float, float* %835, align 4
  %999 = fmul float %997, %998
  %1000 = fadd float %995, %999
  store float %1000, float* %986, align 4
  %1001 = bitcast i8* %807 to float*
  %1002 = load float, float* %1001, align 4
  %1003 = load float, float* %840, align 4
  %1004 = fmul float %1002, %1003
  %1005 = fadd float %1000, %1004
  store float %1005, float* %986, align 4
  %1006 = getelementptr inbounds i8, i8* %823, i64 36
  %1007 = bitcast i8* %1006 to float*
  %1008 = load float, float* %796, align 4
  %1009 = load float, float* %847, align 4
  %1010 = fmul float %1008, %1009
  %1011 = fadd float 0.000000e+00, %1010
  store float %1011, float* %1007, align 4
  %1012 = load float, float* %991, align 4
  %1013 = load float, float* %852, align 4
  %1014 = fmul float %1012, %1013
  %1015 = fadd float %1011, %1014
  store float %1015, float* %1007, align 4
  %1016 = load float, float* %996, align 4
  %1017 = load float, float* %857, align 4
  %1018 = fmul float %1016, %1017
  %1019 = fadd float %1015, %1018
  store float %1019, float* %1007, align 4
  %1020 = load float, float* %1001, align 4
  %1021 = load float, float* %862, align 4
  %1022 = fmul float %1020, %1021
  %1023 = fadd float %1019, %1022
  store float %1023, float* %1007, align 4
  %1024 = getelementptr inbounds i8, i8* %823, i64 40
  %1025 = bitcast i8* %1024 to float*
  %1026 = load float, float* %796, align 4
  %1027 = load float, float* %869, align 4
  %1028 = fmul float %1026, %1027
  %1029 = fadd float 0.000000e+00, %1028
  store float %1029, float* %1025, align 4
  %1030 = load float, float* %991, align 4
  %1031 = load float, float* %874, align 4
  %1032 = fmul float %1030, %1031
  %1033 = fadd float %1029, %1032
  store float %1033, float* %1025, align 4
  %1034 = load float, float* %996, align 4
  %1035 = load float, float* %879, align 4
  %1036 = fmul float %1034, %1035
  %1037 = fadd float %1033, %1036
  store float %1037, float* %1025, align 4
  %1038 = load float, float* %1001, align 4
  %1039 = load float, float* %884, align 4
  %1040 = fmul float %1038, %1039
  %1041 = fadd float %1037, %1040
  store float %1041, float* %1025, align 4
  %1042 = getelementptr inbounds i8, i8* %823, i64 44
  %1043 = bitcast i8* %1042 to float*
  %1044 = load float, float* %796, align 4
  %1045 = load float, float* %891, align 4
  %1046 = fmul float %1044, %1045
  %1047 = fadd float 0.000000e+00, %1046
  store float %1047, float* %1043, align 4
  %1048 = load float, float* %991, align 4
  %1049 = load float, float* %896, align 4
  %1050 = fmul float %1048, %1049
  %1051 = fadd float %1047, %1050
  store float %1051, float* %1043, align 4
  %1052 = load float, float* %996, align 4
  %1053 = load float, float* %901, align 4
  %1054 = fmul float %1052, %1053
  %1055 = fadd float %1051, %1054
  store float %1055, float* %1043, align 4
  %1056 = load float, float* %1001, align 4
  %1057 = load float, float* %906, align 4
  %1058 = fmul float %1056, %1057
  %1059 = fadd float %1055, %1058
  store float %1059, float* %1043, align 4
  %1060 = getelementptr inbounds i8, i8* %823, i64 48
  %1061 = bitcast i8* %1060 to float*
  %1062 = load float, float* %810, align 4
  %1063 = load float, float* %1, align 4
  %1064 = fmul float %1062, %1063
  %1065 = fadd float %1064, 0.000000e+00
  store float %1065, float* %1061, align 4
  %1066 = bitcast i8* %813 to float*
  %1067 = load float, float* %1066, align 4
  %1068 = load float, float* %830, align 4
  %1069 = fmul float %1067, %1068
  %1070 = fadd float %1065, %1069
  store float %1070, float* %1061, align 4
  %1071 = bitcast i8* %817 to float*
  %1072 = load float, float* %1071, align 4
  %1073 = load float, float* %835, align 4
  %1074 = fmul float %1072, %1073
  %1075 = fadd float %1070, %1074
  store float %1075, float* %1061, align 4
  %1076 = bitcast i8* %821 to float*
  %1077 = load float, float* %1076, align 4
  %1078 = load float, float* %840, align 4
  %1079 = fmul float %1077, %1078
  %1080 = fadd float %1075, %1079
  store float %1080, float* %1061, align 4
  %1081 = getelementptr inbounds i8, i8* %823, i64 52
  %1082 = bitcast i8* %1081 to float*
  %1083 = load float, float* %810, align 4
  %1084 = load float, float* %847, align 4
  %1085 = fmul float %1083, %1084
  %1086 = fadd float 0.000000e+00, %1085
  store float %1086, float* %1082, align 4
  %1087 = load float, float* %1066, align 4
  %1088 = load float, float* %852, align 4
  %1089 = fmul float %1087, %1088
  %1090 = fadd float %1086, %1089
  store float %1090, float* %1082, align 4
  %1091 = load float, float* %1071, align 4
  %1092 = load float, float* %857, align 4
  %1093 = fmul float %1091, %1092
  %1094 = fadd float %1090, %1093
  store float %1094, float* %1082, align 4
  %1095 = load float, float* %1076, align 4
  %1096 = load float, float* %862, align 4
  %1097 = fmul float %1095, %1096
  %1098 = fadd float %1094, %1097
  store float %1098, float* %1082, align 4
  %1099 = getelementptr inbounds i8, i8* %823, i64 56
  %1100 = bitcast i8* %1099 to float*
  %1101 = load float, float* %810, align 4
  %1102 = load float, float* %869, align 4
  %1103 = fmul float %1101, %1102
  %1104 = fadd float 0.000000e+00, %1103
  store float %1104, float* %1100, align 4
  %1105 = load float, float* %1066, align 4
  %1106 = load float, float* %874, align 4
  %1107 = fmul float %1105, %1106
  %1108 = fadd float %1104, %1107
  store float %1108, float* %1100, align 4
  %1109 = load float, float* %1071, align 4
  %1110 = load float, float* %879, align 4
  %1111 = fmul float %1109, %1110
  %1112 = fadd float %1108, %1111
  store float %1112, float* %1100, align 4
  %1113 = load float, float* %1076, align 4
  %1114 = load float, float* %884, align 4
  %1115 = fmul float %1113, %1114
  %1116 = fadd float %1112, %1115
  store float %1116, float* %1100, align 4
  %1117 = getelementptr inbounds i8, i8* %823, i64 60
  %1118 = bitcast i8* %1117 to float*
  %1119 = load float, float* %810, align 4
  %1120 = load float, float* %891, align 4
  %1121 = fmul float %1119, %1120
  %1122 = fadd float 0.000000e+00, %1121
  store float %1122, float* %1118, align 4
  %1123 = load float, float* %1066, align 4
  %1124 = load float, float* %896, align 4
  %1125 = fmul float %1123, %1124
  %1126 = fadd float %1122, %1125
  store float %1126, float* %1118, align 4
  %1127 = load float, float* %1071, align 4
  %1128 = load float, float* %901, align 4
  %1129 = fmul float %1127, %1128
  %1130 = fadd float %1126, %1129
  store float %1130, float* %1118, align 4
  %1131 = load float, float* %1076, align 4
  %1132 = load float, float* %906, align 4
  %1133 = fmul float %1131, %1132
  %1134 = fadd float %1130, %1133
  store float %1134, float* %1118, align 4
  %1135 = call i8* @__memcpy_chk(i8* %21, i8* %823, i64 64, i64 %22) #8
  store float 0.000000e+00, float* %824, align 4
  %1136 = load float, float* %774, align 4
  %1137 = load float, float* %2, align 4
  %1138 = fmul float %1136, %1137
  %1139 = fadd float %1138, 0.000000e+00
  store float %1139, float* %824, align 4
  %1140 = load float, float* %776, align 4
  %1141 = load float, float* %33, align 4
  %1142 = fmul float %1140, %1141
  %1143 = fadd float %1139, %1142
  store float %1143, float* %824, align 4
  %1144 = load float, float* %778, align 4
  %1145 = load float, float* %42, align 4
  %1146 = fmul float %1144, %1145
  %1147 = fadd float %1143, %1146
  store float %1147, float* %824, align 4
  %1148 = load float, float* %780, align 4
  %1149 = load float, float* %51, align 4
  %1150 = fmul float %1148, %1149
  %1151 = fadd float %1147, %1150
  store float %1151, float* %824, align 4
  store float 0.000000e+00, float* %845, align 4
  %1152 = load float, float* %774, align 4
  %1153 = load float, float* %344, align 4
  %1154 = fmul float %1152, %1153
  %1155 = fadd float 0.000000e+00, %1154
  store float %1155, float* %845, align 4
  %1156 = load float, float* %776, align 4
  %1157 = load float, float* %427, align 4
  %1158 = fmul float %1156, %1157
  %1159 = fadd float %1155, %1158
  store float %1159, float* %845, align 4
  %1160 = load float, float* %778, align 4
  %1161 = load float, float* %498, align 4
  %1162 = fmul float %1160, %1161
  %1163 = fadd float %1159, %1162
  store float %1163, float* %845, align 4
  %1164 = load float, float* %780, align 4
  %1165 = load float, float* %569, align 4
  %1166 = fmul float %1164, %1165
  %1167 = fadd float %1163, %1166
  store float %1167, float* %845, align 4
  store float 0.000000e+00, float* %867, align 4
  %1168 = load float, float* %774, align 4
  %1169 = load float, float* %365, align 4
  %1170 = fmul float %1168, %1169
  %1171 = fadd float 0.000000e+00, %1170
  store float %1171, float* %867, align 4
  %1172 = load float, float* %776, align 4
  %1173 = load float, float* %444, align 4
  %1174 = fmul float %1172, %1173
  %1175 = fadd float %1171, %1174
  store float %1175, float* %867, align 4
  %1176 = load float, float* %778, align 4
  %1177 = load float, float* %515, align 4
  %1178 = fmul float %1176, %1177
  %1179 = fadd float %1175, %1178
  store float %1179, float* %867, align 4
  %1180 = load float, float* %780, align 4
  %1181 = load float, float* %586, align 4
  %1182 = fmul float %1180, %1181
  %1183 = fadd float %1179, %1182
  store float %1183, float* %867, align 4
  store float 0.000000e+00, float* %889, align 4
  %1184 = load float, float* %774, align 4
  %1185 = load float, float* %386, align 4
  %1186 = fmul float %1184, %1185
  %1187 = fadd float 0.000000e+00, %1186
  store float %1187, float* %889, align 4
  %1188 = load float, float* %776, align 4
  %1189 = load float, float* %461, align 4
  %1190 = fmul float %1188, %1189
  %1191 = fadd float %1187, %1190
  store float %1191, float* %889, align 4
  %1192 = load float, float* %778, align 4
  %1193 = load float, float* %532, align 4
  %1194 = fmul float %1192, %1193
  %1195 = fadd float %1191, %1194
  store float %1195, float* %889, align 4
  %1196 = load float, float* %780, align 4
  %1197 = load float, float* %603, align 4
  %1198 = fmul float %1196, %1197
  %1199 = fadd float %1195, %1198
  store float %1199, float* %889, align 4
  store float 0.000000e+00, float* %911, align 4
  %1200 = load float, float* %782, align 4
  %1201 = load float, float* %2, align 4
  %1202 = fmul float %1200, %1201
  %1203 = fadd float %1202, 0.000000e+00
  store float %1203, float* %911, align 4
  %1204 = load float, float* %916, align 4
  %1205 = load float, float* %33, align 4
  %1206 = fmul float %1204, %1205
  %1207 = fadd float %1203, %1206
  store float %1207, float* %911, align 4
  %1208 = load float, float* %921, align 4
  %1209 = load float, float* %42, align 4
  %1210 = fmul float %1208, %1209
  %1211 = fadd float %1207, %1210
  store float %1211, float* %911, align 4
  %1212 = load float, float* %926, align 4
  %1213 = load float, float* %51, align 4
  %1214 = fmul float %1212, %1213
  %1215 = fadd float %1211, %1214
  store float %1215, float* %911, align 4
  store float 0.000000e+00, float* %932, align 4
  %1216 = load float, float* %782, align 4
  %1217 = load float, float* %344, align 4
  %1218 = fmul float %1216, %1217
  %1219 = fadd float 0.000000e+00, %1218
  store float %1219, float* %932, align 4
  %1220 = load float, float* %916, align 4
  %1221 = load float, float* %427, align 4
  %1222 = fmul float %1220, %1221
  %1223 = fadd float %1219, %1222
  store float %1223, float* %932, align 4
  %1224 = load float, float* %921, align 4
  %1225 = load float, float* %498, align 4
  %1226 = fmul float %1224, %1225
  %1227 = fadd float %1223, %1226
  store float %1227, float* %932, align 4
  %1228 = load float, float* %926, align 4
  %1229 = load float, float* %569, align 4
  %1230 = fmul float %1228, %1229
  %1231 = fadd float %1227, %1230
  store float %1231, float* %932, align 4
  store float 0.000000e+00, float* %950, align 4
  %1232 = load float, float* %782, align 4
  %1233 = load float, float* %365, align 4
  %1234 = fmul float %1232, %1233
  %1235 = fadd float 0.000000e+00, %1234
  store float %1235, float* %950, align 4
  %1236 = load float, float* %916, align 4
  %1237 = load float, float* %444, align 4
  %1238 = fmul float %1236, %1237
  %1239 = fadd float %1235, %1238
  store float %1239, float* %950, align 4
  %1240 = load float, float* %921, align 4
  %1241 = load float, float* %515, align 4
  %1242 = fmul float %1240, %1241
  %1243 = fadd float %1239, %1242
  store float %1243, float* %950, align 4
  %1244 = load float, float* %926, align 4
  %1245 = load float, float* %586, align 4
  %1246 = fmul float %1244, %1245
  %1247 = fadd float %1243, %1246
  store float %1247, float* %950, align 4
  store float 0.000000e+00, float* %968, align 4
  %1248 = load float, float* %782, align 4
  %1249 = load float, float* %386, align 4
  %1250 = fmul float %1248, %1249
  %1251 = fadd float 0.000000e+00, %1250
  store float %1251, float* %968, align 4
  %1252 = load float, float* %916, align 4
  %1253 = load float, float* %461, align 4
  %1254 = fmul float %1252, %1253
  %1255 = fadd float %1251, %1254
  store float %1255, float* %968, align 4
  %1256 = load float, float* %921, align 4
  %1257 = load float, float* %532, align 4
  %1258 = fmul float %1256, %1257
  %1259 = fadd float %1255, %1258
  store float %1259, float* %968, align 4
  %1260 = load float, float* %926, align 4
  %1261 = load float, float* %603, align 4
  %1262 = fmul float %1260, %1261
  %1263 = fadd float %1259, %1262
  store float %1263, float* %968, align 4
  store float 0.000000e+00, float* %986, align 4
  %1264 = load float, float* %796, align 4
  %1265 = load float, float* %2, align 4
  %1266 = fmul float %1264, %1265
  %1267 = fadd float %1266, 0.000000e+00
  store float %1267, float* %986, align 4
  %1268 = load float, float* %991, align 4
  %1269 = load float, float* %33, align 4
  %1270 = fmul float %1268, %1269
  %1271 = fadd float %1267, %1270
  store float %1271, float* %986, align 4
  %1272 = load float, float* %996, align 4
  %1273 = load float, float* %42, align 4
  %1274 = fmul float %1272, %1273
  %1275 = fadd float %1271, %1274
  store float %1275, float* %986, align 4
  %1276 = load float, float* %1001, align 4
  %1277 = load float, float* %51, align 4
  %1278 = fmul float %1276, %1277
  %1279 = fadd float %1275, %1278
  store float %1279, float* %986, align 4
  store float 0.000000e+00, float* %1007, align 4
  %1280 = load float, float* %796, align 4
  %1281 = load float, float* %344, align 4
  %1282 = fmul float %1280, %1281
  %1283 = fadd float 0.000000e+00, %1282
  store float %1283, float* %1007, align 4
  %1284 = load float, float* %991, align 4
  %1285 = load float, float* %427, align 4
  %1286 = fmul float %1284, %1285
  %1287 = fadd float %1283, %1286
  store float %1287, float* %1007, align 4
  %1288 = load float, float* %996, align 4
  %1289 = load float, float* %498, align 4
  %1290 = fmul float %1288, %1289
  %1291 = fadd float %1287, %1290
  store float %1291, float* %1007, align 4
  %1292 = load float, float* %1001, align 4
  %1293 = load float, float* %569, align 4
  %1294 = fmul float %1292, %1293
  %1295 = fadd float %1291, %1294
  store float %1295, float* %1007, align 4
  store float 0.000000e+00, float* %1025, align 4
  %1296 = load float, float* %796, align 4
  %1297 = load float, float* %365, align 4
  %1298 = fmul float %1296, %1297
  %1299 = fadd float 0.000000e+00, %1298
  store float %1299, float* %1025, align 4
  %1300 = load float, float* %991, align 4
  %1301 = load float, float* %444, align 4
  %1302 = fmul float %1300, %1301
  %1303 = fadd float %1299, %1302
  store float %1303, float* %1025, align 4
  %1304 = load float, float* %996, align 4
  %1305 = load float, float* %515, align 4
  %1306 = fmul float %1304, %1305
  %1307 = fadd float %1303, %1306
  store float %1307, float* %1025, align 4
  %1308 = load float, float* %1001, align 4
  %1309 = load float, float* %586, align 4
  %1310 = fmul float %1308, %1309
  %1311 = fadd float %1307, %1310
  store float %1311, float* %1025, align 4
  store float 0.000000e+00, float* %1043, align 4
  %1312 = load float, float* %796, align 4
  %1313 = load float, float* %386, align 4
  %1314 = fmul float %1312, %1313
  %1315 = fadd float 0.000000e+00, %1314
  store float %1315, float* %1043, align 4
  %1316 = load float, float* %991, align 4
  %1317 = load float, float* %461, align 4
  %1318 = fmul float %1316, %1317
  %1319 = fadd float %1315, %1318
  store float %1319, float* %1043, align 4
  %1320 = load float, float* %996, align 4
  %1321 = load float, float* %532, align 4
  %1322 = fmul float %1320, %1321
  %1323 = fadd float %1319, %1322
  store float %1323, float* %1043, align 4
  %1324 = load float, float* %1001, align 4
  %1325 = load float, float* %603, align 4
  %1326 = fmul float %1324, %1325
  %1327 = fadd float %1323, %1326
  store float %1327, float* %1043, align 4
  store float 0.000000e+00, float* %1061, align 4
  %1328 = load float, float* %810, align 4
  %1329 = load float, float* %2, align 4
  %1330 = fmul float %1328, %1329
  %1331 = fadd float %1330, 0.000000e+00
  store float %1331, float* %1061, align 4
  %1332 = load float, float* %1066, align 4
  %1333 = load float, float* %33, align 4
  %1334 = fmul float %1332, %1333
  %1335 = fadd float %1331, %1334
  store float %1335, float* %1061, align 4
  %1336 = load float, float* %1071, align 4
  %1337 = load float, float* %42, align 4
  %1338 = fmul float %1336, %1337
  %1339 = fadd float %1335, %1338
  store float %1339, float* %1061, align 4
  %1340 = load float, float* %1076, align 4
  %1341 = load float, float* %51, align 4
  %1342 = fmul float %1340, %1341
  %1343 = fadd float %1339, %1342
  store float %1343, float* %1061, align 4
  store float 0.000000e+00, float* %1082, align 4
  %1344 = load float, float* %810, align 4
  %1345 = load float, float* %344, align 4
  %1346 = fmul float %1344, %1345
  %1347 = fadd float 0.000000e+00, %1346
  store float %1347, float* %1082, align 4
  %1348 = load float, float* %1066, align 4
  %1349 = load float, float* %427, align 4
  %1350 = fmul float %1348, %1349
  %1351 = fadd float %1347, %1350
  store float %1351, float* %1082, align 4
  %1352 = load float, float* %1071, align 4
  %1353 = load float, float* %498, align 4
  %1354 = fmul float %1352, %1353
  %1355 = fadd float %1351, %1354
  store float %1355, float* %1082, align 4
  %1356 = load float, float* %1076, align 4
  %1357 = load float, float* %569, align 4
  %1358 = fmul float %1356, %1357
  %1359 = fadd float %1355, %1358
  store float %1359, float* %1082, align 4
  store float 0.000000e+00, float* %1100, align 4
  %1360 = load float, float* %810, align 4
  %1361 = load float, float* %365, align 4
  %1362 = fmul float %1360, %1361
  %1363 = fadd float 0.000000e+00, %1362
  store float %1363, float* %1100, align 4
  %1364 = load float, float* %1066, align 4
  %1365 = load float, float* %444, align 4
  %1366 = fmul float %1364, %1365
  %1367 = fadd float %1363, %1366
  store float %1367, float* %1100, align 4
  %1368 = load float, float* %1071, align 4
  %1369 = load float, float* %515, align 4
  %1370 = fmul float %1368, %1369
  %1371 = fadd float %1367, %1370
  store float %1371, float* %1100, align 4
  %1372 = load float, float* %1076, align 4
  %1373 = load float, float* %586, align 4
  %1374 = fmul float %1372, %1373
  %1375 = fadd float %1371, %1374
  store float %1375, float* %1100, align 4
  store float 0.000000e+00, float* %1118, align 4
  %1376 = load float, float* %810, align 4
  %1377 = load float, float* %386, align 4
  %1378 = fmul float %1376, %1377
  %1379 = fadd float 0.000000e+00, %1378
  store float %1379, float* %1118, align 4
  %1380 = load float, float* %1066, align 4
  %1381 = load float, float* %461, align 4
  %1382 = fmul float %1380, %1381
  %1383 = fadd float %1379, %1382
  store float %1383, float* %1118, align 4
  %1384 = load float, float* %1071, align 4
  %1385 = load float, float* %532, align 4
  %1386 = fmul float %1384, %1385
  %1387 = fadd float %1383, %1386
  store float %1387, float* %1118, align 4
  %1388 = load float, float* %1076, align 4
  %1389 = load float, float* %603, align 4
  %1390 = fmul float %1388, %1389
  %1391 = fadd float %1387, %1390
  store float %1391, float* %1118, align 4
  %1392 = call i8* @__memcpy_chk(i8* %3, i8* %823, i64 64, i64 %5) #8
  call void @free(i8* %620)
  call void @free(i8* %622)
  call void @free(i8* %670)
  call void @free(i8* %672)
  call void @free(i8* %713)
  call void @free(i8* %773)
  %1393 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #9
  %1394 = bitcast i8* %1393 to float*
  %1395 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #9
  %1396 = bitcast i8* %1395 to float*
  %1397 = bitcast float* %515 to i32*
  %1398 = load i32, i32* %1397, align 4
  %1399 = bitcast i8* %1393 to i32*
  store i32 %1398, i32* %1399, align 4
  %1400 = bitcast i8* %14 to i32*
  %1401 = load i32, i32* %1400, align 4
  %1402 = bitcast i8* %1395 to i32*
  store i32 %1401, i32* %1402, align 4
  %1403 = bitcast float* %586 to i32*
  %1404 = load i32, i32* %1403, align 4
  %1405 = getelementptr inbounds i8, i8* %1393, i64 4
  %1406 = bitcast i8* %1405 to i32*
  store i32 %1404, i32* %1406, align 4
  %1407 = bitcast i8* %18 to i32*
  %1408 = load i32, i32* %1407, align 4
  %1409 = getelementptr inbounds i8, i8* %1395, i64 4
  %1410 = bitcast i8* %1409 to i32*
  store i32 %1408, i32* %1410, align 4
  %1411 = load float, float* %1394, align 4
  %1412 = fcmp ogt float %1411, 0.000000e+00
  %1413 = zext i1 %1412 to i32
  %1414 = fcmp olt float %1411, 0.000000e+00
  %.neg216 = sext i1 %1414 to i32
  %1415 = add nsw i32 %.neg216, %1413
  %1416 = sitofp i32 %1415 to float
  %1417 = fpext float %1411 to double
  %square217 = fmul double %1417, %1417
  %1418 = fadd double %square217, 0.000000e+00
  %1419 = fptrunc double %1418 to float
  %1420 = bitcast i8* %1405 to float*
  %1421 = load float, float* %1420, align 4
  %1422 = fpext float %1421 to double
  %square218 = fmul double %1422, %1422
  %1423 = fpext float %1419 to double
  %1424 = fadd double %square218, %1423
  %1425 = fptrunc double %1424 to float
  %1426 = fneg float %1416
  %1427 = call float @llvm.sqrt.f32(float %1425) #8
  %1428 = fmul float %1427, %1426
  %1429 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #9
  %1430 = bitcast i8* %1429 to float*
  %1431 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #9
  %1432 = load float, float* %1394, align 4
  %1433 = load float, float* %1396, align 4
  %1434 = fmul float %1428, %1433
  %1435 = fadd float %1432, %1434
  store float %1435, float* %1430, align 4
  %1436 = load float, float* %1420, align 4
  %1437 = bitcast i8* %1409 to float*
  %1438 = load float, float* %1437, align 4
  %1439 = fmul float %1428, %1438
  %1440 = fadd float %1436, %1439
  %1441 = getelementptr inbounds i8, i8* %1429, i64 4
  %1442 = bitcast i8* %1441 to float*
  store float %1440, float* %1442, align 4
  %1443 = fpext float %1435 to double
  %square219 = fmul double %1443, %1443
  %1444 = fadd double %square219, 0.000000e+00
  %1445 = fptrunc double %1444 to float
  %1446 = fpext float %1440 to double
  %square220 = fmul double %1446, %1446
  %1447 = fpext float %1445 to double
  %1448 = fadd double %square220, %1447
  %1449 = fptrunc double %1448 to float
  %1450 = bitcast i8* %1431 to float*
  %1451 = call float @llvm.sqrt.f32(float %1449) #8
  %1452 = fdiv float %1435, %1451
  store float %1452, float* %1450, align 4
  %1453 = load float, float* %1442, align 4
  %1454 = fdiv float %1453, %1451
  %1455 = getelementptr inbounds i8, i8* %1431, i64 4
  %1456 = bitcast i8* %1455 to float*
  store float %1454, float* %1456, align 4
  %1457 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #9
  %1458 = bitcast i8* %1457 to float*
  %1459 = load float, float* %1450, align 4
  %1460 = fmul float %1459, 2.000000e+00
  %1461 = fmul float %1460, %1459
  %1462 = fsub float 1.000000e+00, %1461
  store float %1462, float* %1458, align 4
  %1463 = load float, float* %1450, align 4
  %1464 = fmul float %1463, 2.000000e+00
  %1465 = load float, float* %1456, align 4
  %1466 = fmul float %1464, %1465
  %1467 = fsub float 0.000000e+00, %1466
  %1468 = getelementptr inbounds i8, i8* %1457, i64 4
  %1469 = bitcast i8* %1468 to float*
  store float %1467, float* %1469, align 4
  %1470 = load float, float* %1456, align 4
  %1471 = fmul float %1470, 2.000000e+00
  %1472 = load float, float* %1450, align 4
  %1473 = fmul float %1471, %1472
  %1474 = fsub float 0.000000e+00, %1473
  %1475 = getelementptr inbounds i8, i8* %1457, i64 8
  %1476 = bitcast i8* %1475 to float*
  store float %1474, float* %1476, align 4
  %1477 = load float, float* %1456, align 4
  %1478 = fmul float %1477, 2.000000e+00
  %1479 = fmul float %1478, %1477
  %1480 = fsub float 1.000000e+00, %1479
  %1481 = getelementptr inbounds i8, i8* %1457, i64 12
  %1482 = bitcast i8* %1481 to float*
  store float %1480, float* %1482, align 4
  %1483 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #9
  %1484 = bitcast i8* %1483 to float*
  store float 1.000000e+00, float* %1484, align 4
  %1485 = getelementptr inbounds i8, i8* %1483, i64 4
  %1486 = bitcast i8* %1485 to float*
  %1487 = getelementptr inbounds i8, i8* %1483, i64 8
  %1488 = bitcast i8* %1487 to float*
  %1489 = getelementptr inbounds i8, i8* %1483, i64 12
  %1490 = bitcast i8* %1489 to float*
  %1491 = getelementptr inbounds i8, i8* %1483, i64 16
  %1492 = bitcast i8* %1491 to float*
  %1493 = getelementptr inbounds i8, i8* %1483, i64 20
  %1494 = bitcast i8* %1493 to float*
  store float 1.000000e+00, float* %1494, align 4
  %1495 = getelementptr inbounds i8, i8* %1483, i64 24
  %1496 = bitcast i8* %1495 to float*
  %1497 = getelementptr inbounds i8, i8* %1483, i64 28
  %1498 = bitcast i8* %1497 to float*
  %1499 = getelementptr inbounds i8, i8* %1483, i64 32
  %1500 = bitcast i8* %1499 to float*
  %1501 = getelementptr inbounds i8, i8* %1483, i64 36
  %1502 = bitcast i8* %1501 to float*
  %1503 = bitcast i8* %1457 to i32*
  %1504 = load i32, i32* %1503, align 4
  %1505 = getelementptr inbounds i8, i8* %1483, i64 40
  %1506 = bitcast i8* %1505 to i32*
  store i32 %1504, i32* %1506, align 4
  %1507 = bitcast i8* %1468 to i32*
  %1508 = load i32, i32* %1507, align 4
  %1509 = getelementptr inbounds i8, i8* %1483, i64 44
  %1510 = bitcast i8* %1509 to i32*
  store i32 %1508, i32* %1510, align 4
  %1511 = getelementptr inbounds i8, i8* %1483, i64 48
  %1512 = bitcast i8* %1511 to float*
  %1513 = getelementptr inbounds i8, i8* %1483, i64 52
  %1514 = bitcast i8* %1513 to float*
  %1515 = bitcast i8* %1475 to i32*
  %1516 = load i32, i32* %1515, align 4
  %1517 = getelementptr inbounds i8, i8* %1483, i64 56
  %1518 = bitcast i8* %1517 to i32*
  store i32 %1516, i32* %1518, align 4
  %1519 = bitcast i8* %1481 to i32*
  %1520 = load i32, i32* %1519, align 4
  %1521 = getelementptr inbounds i8, i8* %1483, i64 60
  %1522 = bitcast i8* %1521 to i32*
  store i32 %1520, i32* %1522, align 4
  %1523 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #9
  %1524 = bitcast i8* %1523 to float*
  %1525 = load float, float* %1484, align 4
  %1526 = load float, float* %1, align 4
  %1527 = fmul float %1525, %1526
  %1528 = fadd float %1527, 0.000000e+00
  store float %1528, float* %1524, align 4
  %1529 = load float, float* %1486, align 4
  %1530 = load float, float* %830, align 4
  %1531 = fmul float %1529, %1530
  %1532 = fadd float %1528, %1531
  store float %1532, float* %1524, align 4
  %1533 = load float, float* %1488, align 4
  %1534 = load float, float* %835, align 4
  %1535 = fmul float %1533, %1534
  %1536 = fadd float %1532, %1535
  store float %1536, float* %1524, align 4
  %1537 = load float, float* %1490, align 4
  %1538 = load float, float* %840, align 4
  %1539 = fmul float %1537, %1538
  %1540 = fadd float %1536, %1539
  store float %1540, float* %1524, align 4
  %1541 = getelementptr inbounds i8, i8* %1523, i64 4
  %1542 = bitcast i8* %1541 to float*
  %1543 = load float, float* %1484, align 4
  %1544 = load float, float* %847, align 4
  %1545 = fmul float %1543, %1544
  %1546 = fadd float 0.000000e+00, %1545
  store float %1546, float* %1542, align 4
  %1547 = load float, float* %1486, align 4
  %1548 = load float, float* %852, align 4
  %1549 = fmul float %1547, %1548
  %1550 = fadd float %1546, %1549
  store float %1550, float* %1542, align 4
  %1551 = load float, float* %1488, align 4
  %1552 = load float, float* %857, align 4
  %1553 = fmul float %1551, %1552
  %1554 = fadd float %1550, %1553
  store float %1554, float* %1542, align 4
  %1555 = load float, float* %1490, align 4
  %1556 = load float, float* %862, align 4
  %1557 = fmul float %1555, %1556
  %1558 = fadd float %1554, %1557
  store float %1558, float* %1542, align 4
  %1559 = getelementptr inbounds i8, i8* %1523, i64 8
  %1560 = bitcast i8* %1559 to float*
  %1561 = load float, float* %1484, align 4
  %1562 = load float, float* %869, align 4
  %1563 = fmul float %1561, %1562
  %1564 = fadd float 0.000000e+00, %1563
  store float %1564, float* %1560, align 4
  %1565 = load float, float* %1486, align 4
  %1566 = load float, float* %874, align 4
  %1567 = fmul float %1565, %1566
  %1568 = fadd float %1564, %1567
  store float %1568, float* %1560, align 4
  %1569 = load float, float* %1488, align 4
  %1570 = load float, float* %879, align 4
  %1571 = fmul float %1569, %1570
  %1572 = fadd float %1568, %1571
  store float %1572, float* %1560, align 4
  %1573 = load float, float* %1490, align 4
  %1574 = load float, float* %884, align 4
  %1575 = fmul float %1573, %1574
  %1576 = fadd float %1572, %1575
  store float %1576, float* %1560, align 4
  %1577 = getelementptr inbounds i8, i8* %1523, i64 12
  %1578 = bitcast i8* %1577 to float*
  %1579 = load float, float* %1484, align 4
  %1580 = load float, float* %891, align 4
  %1581 = fmul float %1579, %1580
  %1582 = fadd float 0.000000e+00, %1581
  store float %1582, float* %1578, align 4
  %1583 = load float, float* %1486, align 4
  %1584 = load float, float* %896, align 4
  %1585 = fmul float %1583, %1584
  %1586 = fadd float %1582, %1585
  store float %1586, float* %1578, align 4
  %1587 = load float, float* %1488, align 4
  %1588 = load float, float* %901, align 4
  %1589 = fmul float %1587, %1588
  %1590 = fadd float %1586, %1589
  store float %1590, float* %1578, align 4
  %1591 = load float, float* %1490, align 4
  %1592 = load float, float* %906, align 4
  %1593 = fmul float %1591, %1592
  %1594 = fadd float %1590, %1593
  store float %1594, float* %1578, align 4
  %1595 = getelementptr inbounds i8, i8* %1523, i64 16
  %1596 = bitcast i8* %1595 to float*
  %1597 = load float, float* %1492, align 4
  %1598 = load float, float* %1, align 4
  %1599 = fmul float %1597, %1598
  %1600 = fadd float %1599, 0.000000e+00
  store float %1600, float* %1596, align 4
  %1601 = load float, float* %1494, align 4
  %1602 = load float, float* %830, align 4
  %1603 = fmul float %1601, %1602
  %1604 = fadd float %1600, %1603
  store float %1604, float* %1596, align 4
  %1605 = load float, float* %1496, align 4
  %1606 = load float, float* %835, align 4
  %1607 = fmul float %1605, %1606
  %1608 = fadd float %1604, %1607
  store float %1608, float* %1596, align 4
  %1609 = load float, float* %1498, align 4
  %1610 = load float, float* %840, align 4
  %1611 = fmul float %1609, %1610
  %1612 = fadd float %1608, %1611
  store float %1612, float* %1596, align 4
  %1613 = getelementptr inbounds i8, i8* %1523, i64 20
  %1614 = bitcast i8* %1613 to float*
  %1615 = load float, float* %1492, align 4
  %1616 = load float, float* %847, align 4
  %1617 = fmul float %1615, %1616
  %1618 = fadd float 0.000000e+00, %1617
  store float %1618, float* %1614, align 4
  %1619 = load float, float* %1494, align 4
  %1620 = load float, float* %852, align 4
  %1621 = fmul float %1619, %1620
  %1622 = fadd float %1618, %1621
  store float %1622, float* %1614, align 4
  %1623 = load float, float* %1496, align 4
  %1624 = load float, float* %857, align 4
  %1625 = fmul float %1623, %1624
  %1626 = fadd float %1622, %1625
  store float %1626, float* %1614, align 4
  %1627 = load float, float* %1498, align 4
  %1628 = load float, float* %862, align 4
  %1629 = fmul float %1627, %1628
  %1630 = fadd float %1626, %1629
  store float %1630, float* %1614, align 4
  %1631 = getelementptr inbounds i8, i8* %1523, i64 24
  %1632 = bitcast i8* %1631 to float*
  %1633 = load float, float* %1492, align 4
  %1634 = load float, float* %869, align 4
  %1635 = fmul float %1633, %1634
  %1636 = fadd float 0.000000e+00, %1635
  store float %1636, float* %1632, align 4
  %1637 = load float, float* %1494, align 4
  %1638 = load float, float* %874, align 4
  %1639 = fmul float %1637, %1638
  %1640 = fadd float %1636, %1639
  store float %1640, float* %1632, align 4
  %1641 = load float, float* %1496, align 4
  %1642 = load float, float* %879, align 4
  %1643 = fmul float %1641, %1642
  %1644 = fadd float %1640, %1643
  store float %1644, float* %1632, align 4
  %1645 = load float, float* %1498, align 4
  %1646 = load float, float* %884, align 4
  %1647 = fmul float %1645, %1646
  %1648 = fadd float %1644, %1647
  store float %1648, float* %1632, align 4
  %1649 = getelementptr inbounds i8, i8* %1523, i64 28
  %1650 = bitcast i8* %1649 to float*
  %1651 = load float, float* %1492, align 4
  %1652 = load float, float* %891, align 4
  %1653 = fmul float %1651, %1652
  %1654 = fadd float 0.000000e+00, %1653
  store float %1654, float* %1650, align 4
  %1655 = load float, float* %1494, align 4
  %1656 = load float, float* %896, align 4
  %1657 = fmul float %1655, %1656
  %1658 = fadd float %1654, %1657
  store float %1658, float* %1650, align 4
  %1659 = load float, float* %1496, align 4
  %1660 = load float, float* %901, align 4
  %1661 = fmul float %1659, %1660
  %1662 = fadd float %1658, %1661
  store float %1662, float* %1650, align 4
  %1663 = load float, float* %1498, align 4
  %1664 = load float, float* %906, align 4
  %1665 = fmul float %1663, %1664
  %1666 = fadd float %1662, %1665
  store float %1666, float* %1650, align 4
  %1667 = getelementptr inbounds i8, i8* %1523, i64 32
  %1668 = bitcast i8* %1667 to float*
  %1669 = load float, float* %1500, align 4
  %1670 = load float, float* %1, align 4
  %1671 = fmul float %1669, %1670
  %1672 = fadd float %1671, 0.000000e+00
  store float %1672, float* %1668, align 4
  %1673 = load float, float* %1502, align 4
  %1674 = load float, float* %830, align 4
  %1675 = fmul float %1673, %1674
  %1676 = fadd float %1672, %1675
  store float %1676, float* %1668, align 4
  %1677 = bitcast i8* %1505 to float*
  %1678 = load float, float* %1677, align 4
  %1679 = load float, float* %835, align 4
  %1680 = fmul float %1678, %1679
  %1681 = fadd float %1676, %1680
  store float %1681, float* %1668, align 4
  %1682 = bitcast i8* %1509 to float*
  %1683 = load float, float* %1682, align 4
  %1684 = load float, float* %840, align 4
  %1685 = fmul float %1683, %1684
  %1686 = fadd float %1681, %1685
  store float %1686, float* %1668, align 4
  %1687 = getelementptr inbounds i8, i8* %1523, i64 36
  %1688 = bitcast i8* %1687 to float*
  %1689 = load float, float* %1500, align 4
  %1690 = load float, float* %847, align 4
  %1691 = fmul float %1689, %1690
  %1692 = fadd float 0.000000e+00, %1691
  store float %1692, float* %1688, align 4
  %1693 = load float, float* %1502, align 4
  %1694 = load float, float* %852, align 4
  %1695 = fmul float %1693, %1694
  %1696 = fadd float %1692, %1695
  store float %1696, float* %1688, align 4
  %1697 = load float, float* %1677, align 4
  %1698 = load float, float* %857, align 4
  %1699 = fmul float %1697, %1698
  %1700 = fadd float %1696, %1699
  store float %1700, float* %1688, align 4
  %1701 = load float, float* %1682, align 4
  %1702 = load float, float* %862, align 4
  %1703 = fmul float %1701, %1702
  %1704 = fadd float %1700, %1703
  store float %1704, float* %1688, align 4
  %1705 = getelementptr inbounds i8, i8* %1523, i64 40
  %1706 = bitcast i8* %1705 to float*
  %1707 = load float, float* %1500, align 4
  %1708 = load float, float* %869, align 4
  %1709 = fmul float %1707, %1708
  %1710 = fadd float 0.000000e+00, %1709
  store float %1710, float* %1706, align 4
  %1711 = load float, float* %1502, align 4
  %1712 = load float, float* %874, align 4
  %1713 = fmul float %1711, %1712
  %1714 = fadd float %1710, %1713
  store float %1714, float* %1706, align 4
  %1715 = load float, float* %1677, align 4
  %1716 = load float, float* %879, align 4
  %1717 = fmul float %1715, %1716
  %1718 = fadd float %1714, %1717
  store float %1718, float* %1706, align 4
  %1719 = load float, float* %1682, align 4
  %1720 = load float, float* %884, align 4
  %1721 = fmul float %1719, %1720
  %1722 = fadd float %1718, %1721
  store float %1722, float* %1706, align 4
  %1723 = getelementptr inbounds i8, i8* %1523, i64 44
  %1724 = bitcast i8* %1723 to float*
  %1725 = load float, float* %1500, align 4
  %1726 = load float, float* %891, align 4
  %1727 = fmul float %1725, %1726
  %1728 = fadd float 0.000000e+00, %1727
  store float %1728, float* %1724, align 4
  %1729 = load float, float* %1502, align 4
  %1730 = load float, float* %896, align 4
  %1731 = fmul float %1729, %1730
  %1732 = fadd float %1728, %1731
  store float %1732, float* %1724, align 4
  %1733 = load float, float* %1677, align 4
  %1734 = load float, float* %901, align 4
  %1735 = fmul float %1733, %1734
  %1736 = fadd float %1732, %1735
  store float %1736, float* %1724, align 4
  %1737 = load float, float* %1682, align 4
  %1738 = load float, float* %906, align 4
  %1739 = fmul float %1737, %1738
  %1740 = fadd float %1736, %1739
  store float %1740, float* %1724, align 4
  %1741 = getelementptr inbounds i8, i8* %1523, i64 48
  %1742 = bitcast i8* %1741 to float*
  %1743 = load float, float* %1512, align 4
  %1744 = load float, float* %1, align 4
  %1745 = fmul float %1743, %1744
  %1746 = fadd float %1745, 0.000000e+00
  store float %1746, float* %1742, align 4
  %1747 = load float, float* %1514, align 4
  %1748 = load float, float* %830, align 4
  %1749 = fmul float %1747, %1748
  %1750 = fadd float %1746, %1749
  store float %1750, float* %1742, align 4
  %1751 = bitcast i8* %1517 to float*
  %1752 = load float, float* %1751, align 4
  %1753 = load float, float* %835, align 4
  %1754 = fmul float %1752, %1753
  %1755 = fadd float %1750, %1754
  store float %1755, float* %1742, align 4
  %1756 = bitcast i8* %1521 to float*
  %1757 = load float, float* %1756, align 4
  %1758 = load float, float* %840, align 4
  %1759 = fmul float %1757, %1758
  %1760 = fadd float %1755, %1759
  store float %1760, float* %1742, align 4
  %1761 = getelementptr inbounds i8, i8* %1523, i64 52
  %1762 = bitcast i8* %1761 to float*
  %1763 = load float, float* %1512, align 4
  %1764 = load float, float* %847, align 4
  %1765 = fmul float %1763, %1764
  %1766 = fadd float 0.000000e+00, %1765
  store float %1766, float* %1762, align 4
  %1767 = load float, float* %1514, align 4
  %1768 = load float, float* %852, align 4
  %1769 = fmul float %1767, %1768
  %1770 = fadd float %1766, %1769
  store float %1770, float* %1762, align 4
  %1771 = load float, float* %1751, align 4
  %1772 = load float, float* %857, align 4
  %1773 = fmul float %1771, %1772
  %1774 = fadd float %1770, %1773
  store float %1774, float* %1762, align 4
  %1775 = load float, float* %1756, align 4
  %1776 = load float, float* %862, align 4
  %1777 = fmul float %1775, %1776
  %1778 = fadd float %1774, %1777
  store float %1778, float* %1762, align 4
  %1779 = getelementptr inbounds i8, i8* %1523, i64 56
  %1780 = bitcast i8* %1779 to float*
  %1781 = load float, float* %1512, align 4
  %1782 = load float, float* %869, align 4
  %1783 = fmul float %1781, %1782
  %1784 = fadd float 0.000000e+00, %1783
  store float %1784, float* %1780, align 4
  %1785 = load float, float* %1514, align 4
  %1786 = load float, float* %874, align 4
  %1787 = fmul float %1785, %1786
  %1788 = fadd float %1784, %1787
  store float %1788, float* %1780, align 4
  %1789 = load float, float* %1751, align 4
  %1790 = load float, float* %879, align 4
  %1791 = fmul float %1789, %1790
  %1792 = fadd float %1788, %1791
  store float %1792, float* %1780, align 4
  %1793 = load float, float* %1756, align 4
  %1794 = load float, float* %884, align 4
  %1795 = fmul float %1793, %1794
  %1796 = fadd float %1792, %1795
  store float %1796, float* %1780, align 4
  %1797 = getelementptr inbounds i8, i8* %1523, i64 60
  %1798 = bitcast i8* %1797 to float*
  %1799 = load float, float* %1512, align 4
  %1800 = load float, float* %891, align 4
  %1801 = fmul float %1799, %1800
  %1802 = fadd float 0.000000e+00, %1801
  store float %1802, float* %1798, align 4
  %1803 = load float, float* %1514, align 4
  %1804 = load float, float* %896, align 4
  %1805 = fmul float %1803, %1804
  %1806 = fadd float %1802, %1805
  store float %1806, float* %1798, align 4
  %1807 = load float, float* %1751, align 4
  %1808 = load float, float* %901, align 4
  %1809 = fmul float %1807, %1808
  %1810 = fadd float %1806, %1809
  store float %1810, float* %1798, align 4
  %1811 = load float, float* %1756, align 4
  %1812 = load float, float* %906, align 4
  %1813 = fmul float %1811, %1812
  %1814 = fadd float %1810, %1813
  store float %1814, float* %1798, align 4
  %1815 = call i8* @__memcpy_chk(i8* nonnull %21, i8* %1523, i64 64, i64 %22) #8
  store float 0.000000e+00, float* %1524, align 4
  %1816 = load float, float* %1484, align 4
  %1817 = load float, float* %2, align 4
  %1818 = fmul float %1816, %1817
  %1819 = fadd float %1818, 0.000000e+00
  store float %1819, float* %1524, align 4
  %1820 = load float, float* %1486, align 4
  %1821 = load float, float* %33, align 4
  %1822 = fmul float %1820, %1821
  %1823 = fadd float %1819, %1822
  store float %1823, float* %1524, align 4
  %1824 = load float, float* %1488, align 4
  %1825 = load float, float* %42, align 4
  %1826 = fmul float %1824, %1825
  %1827 = fadd float %1823, %1826
  store float %1827, float* %1524, align 4
  %1828 = load float, float* %1490, align 4
  %1829 = load float, float* %51, align 4
  %1830 = fmul float %1828, %1829
  %1831 = fadd float %1827, %1830
  store float %1831, float* %1524, align 4
  store float 0.000000e+00, float* %1542, align 4
  %1832 = load float, float* %1484, align 4
  %1833 = load float, float* %344, align 4
  %1834 = fmul float %1832, %1833
  %1835 = fadd float 0.000000e+00, %1834
  store float %1835, float* %1542, align 4
  %1836 = load float, float* %1486, align 4
  %1837 = load float, float* %427, align 4
  %1838 = fmul float %1836, %1837
  %1839 = fadd float %1835, %1838
  store float %1839, float* %1542, align 4
  %1840 = load float, float* %1488, align 4
  %1841 = load float, float* %498, align 4
  %1842 = fmul float %1840, %1841
  %1843 = fadd float %1839, %1842
  store float %1843, float* %1542, align 4
  %1844 = load float, float* %1490, align 4
  %1845 = load float, float* %569, align 4
  %1846 = fmul float %1844, %1845
  %1847 = fadd float %1843, %1846
  store float %1847, float* %1542, align 4
  store float 0.000000e+00, float* %1560, align 4
  %1848 = load float, float* %1484, align 4
  %1849 = load float, float* %365, align 4
  %1850 = fmul float %1848, %1849
  %1851 = fadd float 0.000000e+00, %1850
  store float %1851, float* %1560, align 4
  %1852 = load float, float* %1486, align 4
  %1853 = load float, float* %444, align 4
  %1854 = fmul float %1852, %1853
  %1855 = fadd float %1851, %1854
  store float %1855, float* %1560, align 4
  %1856 = load float, float* %1488, align 4
  %1857 = load float, float* %515, align 4
  %1858 = fmul float %1856, %1857
  %1859 = fadd float %1855, %1858
  store float %1859, float* %1560, align 4
  %1860 = load float, float* %1490, align 4
  %1861 = load float, float* %586, align 4
  %1862 = fmul float %1860, %1861
  %1863 = fadd float %1859, %1862
  store float %1863, float* %1560, align 4
  store float 0.000000e+00, float* %1578, align 4
  %1864 = load float, float* %1484, align 4
  %1865 = load float, float* %386, align 4
  %1866 = fmul float %1864, %1865
  %1867 = fadd float 0.000000e+00, %1866
  store float %1867, float* %1578, align 4
  %1868 = load float, float* %1486, align 4
  %1869 = load float, float* %461, align 4
  %1870 = fmul float %1868, %1869
  %1871 = fadd float %1867, %1870
  store float %1871, float* %1578, align 4
  %1872 = load float, float* %1488, align 4
  %1873 = load float, float* %532, align 4
  %1874 = fmul float %1872, %1873
  %1875 = fadd float %1871, %1874
  store float %1875, float* %1578, align 4
  %1876 = load float, float* %1490, align 4
  %1877 = load float, float* %603, align 4
  %1878 = fmul float %1876, %1877
  %1879 = fadd float %1875, %1878
  store float %1879, float* %1578, align 4
  store float 0.000000e+00, float* %1596, align 4
  %1880 = load float, float* %1492, align 4
  %1881 = load float, float* %2, align 4
  %1882 = fmul float %1880, %1881
  %1883 = fadd float %1882, 0.000000e+00
  store float %1883, float* %1596, align 4
  %1884 = load float, float* %1494, align 4
  %1885 = load float, float* %33, align 4
  %1886 = fmul float %1884, %1885
  %1887 = fadd float %1883, %1886
  store float %1887, float* %1596, align 4
  %1888 = load float, float* %1496, align 4
  %1889 = load float, float* %42, align 4
  %1890 = fmul float %1888, %1889
  %1891 = fadd float %1887, %1890
  store float %1891, float* %1596, align 4
  %1892 = load float, float* %1498, align 4
  %1893 = load float, float* %51, align 4
  %1894 = fmul float %1892, %1893
  %1895 = fadd float %1891, %1894
  store float %1895, float* %1596, align 4
  store float 0.000000e+00, float* %1614, align 4
  %1896 = load float, float* %1492, align 4
  %1897 = load float, float* %344, align 4
  %1898 = fmul float %1896, %1897
  %1899 = fadd float 0.000000e+00, %1898
  store float %1899, float* %1614, align 4
  %1900 = load float, float* %1494, align 4
  %1901 = load float, float* %427, align 4
  %1902 = fmul float %1900, %1901
  %1903 = fadd float %1899, %1902
  store float %1903, float* %1614, align 4
  %1904 = load float, float* %1496, align 4
  %1905 = load float, float* %498, align 4
  %1906 = fmul float %1904, %1905
  %1907 = fadd float %1903, %1906
  store float %1907, float* %1614, align 4
  %1908 = load float, float* %1498, align 4
  %1909 = load float, float* %569, align 4
  %1910 = fmul float %1908, %1909
  %1911 = fadd float %1907, %1910
  store float %1911, float* %1614, align 4
  store float 0.000000e+00, float* %1632, align 4
  %1912 = load float, float* %1492, align 4
  %1913 = load float, float* %365, align 4
  %1914 = fmul float %1912, %1913
  %1915 = fadd float 0.000000e+00, %1914
  store float %1915, float* %1632, align 4
  %1916 = load float, float* %1494, align 4
  %1917 = load float, float* %444, align 4
  %1918 = fmul float %1916, %1917
  %1919 = fadd float %1915, %1918
  store float %1919, float* %1632, align 4
  %1920 = load float, float* %1496, align 4
  %1921 = load float, float* %515, align 4
  %1922 = fmul float %1920, %1921
  %1923 = fadd float %1919, %1922
  store float %1923, float* %1632, align 4
  %1924 = load float, float* %1498, align 4
  %1925 = load float, float* %586, align 4
  %1926 = fmul float %1924, %1925
  %1927 = fadd float %1923, %1926
  store float %1927, float* %1632, align 4
  store float 0.000000e+00, float* %1650, align 4
  %1928 = load float, float* %1492, align 4
  %1929 = load float, float* %386, align 4
  %1930 = fmul float %1928, %1929
  %1931 = fadd float 0.000000e+00, %1930
  store float %1931, float* %1650, align 4
  %1932 = load float, float* %1494, align 4
  %1933 = load float, float* %461, align 4
  %1934 = fmul float %1932, %1933
  %1935 = fadd float %1931, %1934
  store float %1935, float* %1650, align 4
  %1936 = load float, float* %1496, align 4
  %1937 = load float, float* %532, align 4
  %1938 = fmul float %1936, %1937
  %1939 = fadd float %1935, %1938
  store float %1939, float* %1650, align 4
  %1940 = load float, float* %1498, align 4
  %1941 = load float, float* %603, align 4
  %1942 = fmul float %1940, %1941
  %1943 = fadd float %1939, %1942
  store float %1943, float* %1650, align 4
  store float 0.000000e+00, float* %1668, align 4
  %1944 = load float, float* %1500, align 4
  %1945 = load float, float* %2, align 4
  %1946 = fmul float %1944, %1945
  %1947 = fadd float %1946, 0.000000e+00
  store float %1947, float* %1668, align 4
  %1948 = load float, float* %1502, align 4
  %1949 = load float, float* %33, align 4
  %1950 = fmul float %1948, %1949
  %1951 = fadd float %1947, %1950
  store float %1951, float* %1668, align 4
  %1952 = load float, float* %1677, align 4
  %1953 = load float, float* %42, align 4
  %1954 = fmul float %1952, %1953
  %1955 = fadd float %1951, %1954
  store float %1955, float* %1668, align 4
  %1956 = load float, float* %1682, align 4
  %1957 = load float, float* %51, align 4
  %1958 = fmul float %1956, %1957
  %1959 = fadd float %1955, %1958
  store float %1959, float* %1668, align 4
  store float 0.000000e+00, float* %1688, align 4
  %1960 = load float, float* %1500, align 4
  %1961 = load float, float* %344, align 4
  %1962 = fmul float %1960, %1961
  %1963 = fadd float 0.000000e+00, %1962
  store float %1963, float* %1688, align 4
  %1964 = load float, float* %1502, align 4
  %1965 = load float, float* %427, align 4
  %1966 = fmul float %1964, %1965
  %1967 = fadd float %1963, %1966
  store float %1967, float* %1688, align 4
  %1968 = load float, float* %1677, align 4
  %1969 = load float, float* %498, align 4
  %1970 = fmul float %1968, %1969
  %1971 = fadd float %1967, %1970
  store float %1971, float* %1688, align 4
  %1972 = load float, float* %1682, align 4
  %1973 = load float, float* %569, align 4
  %1974 = fmul float %1972, %1973
  %1975 = fadd float %1971, %1974
  store float %1975, float* %1688, align 4
  store float 0.000000e+00, float* %1706, align 4
  %1976 = load float, float* %1500, align 4
  %1977 = load float, float* %365, align 4
  %1978 = fmul float %1976, %1977
  %1979 = fadd float 0.000000e+00, %1978
  store float %1979, float* %1706, align 4
  %1980 = load float, float* %1502, align 4
  %1981 = load float, float* %444, align 4
  %1982 = fmul float %1980, %1981
  %1983 = fadd float %1979, %1982
  store float %1983, float* %1706, align 4
  %1984 = load float, float* %1677, align 4
  %1985 = load float, float* %515, align 4
  %1986 = fmul float %1984, %1985
  %1987 = fadd float %1983, %1986
  store float %1987, float* %1706, align 4
  %1988 = load float, float* %1682, align 4
  %1989 = load float, float* %586, align 4
  %1990 = fmul float %1988, %1989
  %1991 = fadd float %1987, %1990
  store float %1991, float* %1706, align 4
  store float 0.000000e+00, float* %1724, align 4
  %1992 = load float, float* %1500, align 4
  %1993 = load float, float* %386, align 4
  %1994 = fmul float %1992, %1993
  %1995 = fadd float 0.000000e+00, %1994
  store float %1995, float* %1724, align 4
  %1996 = load float, float* %1502, align 4
  %1997 = load float, float* %461, align 4
  %1998 = fmul float %1996, %1997
  %1999 = fadd float %1995, %1998
  store float %1999, float* %1724, align 4
  %2000 = load float, float* %1677, align 4
  %2001 = load float, float* %532, align 4
  %2002 = fmul float %2000, %2001
  %2003 = fadd float %1999, %2002
  store float %2003, float* %1724, align 4
  %2004 = load float, float* %1682, align 4
  %2005 = load float, float* %603, align 4
  %2006 = fmul float %2004, %2005
  %2007 = fadd float %2003, %2006
  store float %2007, float* %1724, align 4
  store float 0.000000e+00, float* %1742, align 4
  %2008 = load float, float* %1512, align 4
  %2009 = load float, float* %2, align 4
  %2010 = fmul float %2008, %2009
  %2011 = fadd float %2010, 0.000000e+00
  store float %2011, float* %1742, align 4
  %2012 = load float, float* %1514, align 4
  %2013 = load float, float* %33, align 4
  %2014 = fmul float %2012, %2013
  %2015 = fadd float %2011, %2014
  store float %2015, float* %1742, align 4
  %2016 = load float, float* %1751, align 4
  %2017 = load float, float* %42, align 4
  %2018 = fmul float %2016, %2017
  %2019 = fadd float %2015, %2018
  store float %2019, float* %1742, align 4
  %2020 = load float, float* %1756, align 4
  %2021 = load float, float* %51, align 4
  %2022 = fmul float %2020, %2021
  %2023 = fadd float %2019, %2022
  store float %2023, float* %1742, align 4
  store float 0.000000e+00, float* %1762, align 4
  %2024 = load float, float* %1512, align 4
  %2025 = load float, float* %344, align 4
  %2026 = fmul float %2024, %2025
  %2027 = fadd float 0.000000e+00, %2026
  store float %2027, float* %1762, align 4
  %2028 = load float, float* %1514, align 4
  %2029 = load float, float* %427, align 4
  %2030 = fmul float %2028, %2029
  %2031 = fadd float %2027, %2030
  store float %2031, float* %1762, align 4
  %2032 = load float, float* %1751, align 4
  %2033 = load float, float* %498, align 4
  %2034 = fmul float %2032, %2033
  %2035 = fadd float %2031, %2034
  store float %2035, float* %1762, align 4
  %2036 = load float, float* %1756, align 4
  %2037 = load float, float* %569, align 4
  %2038 = fmul float %2036, %2037
  %2039 = fadd float %2035, %2038
  store float %2039, float* %1762, align 4
  store float 0.000000e+00, float* %1780, align 4
  %2040 = load float, float* %1512, align 4
  %2041 = load float, float* %365, align 4
  %2042 = fmul float %2040, %2041
  %2043 = fadd float 0.000000e+00, %2042
  store float %2043, float* %1780, align 4
  %2044 = load float, float* %1514, align 4
  %2045 = load float, float* %444, align 4
  %2046 = fmul float %2044, %2045
  %2047 = fadd float %2043, %2046
  store float %2047, float* %1780, align 4
  %2048 = load float, float* %1751, align 4
  %2049 = load float, float* %515, align 4
  %2050 = fmul float %2048, %2049
  %2051 = fadd float %2047, %2050
  store float %2051, float* %1780, align 4
  %2052 = load float, float* %1756, align 4
  %2053 = load float, float* %586, align 4
  %2054 = fmul float %2052, %2053
  %2055 = fadd float %2051, %2054
  store float %2055, float* %1780, align 4
  store float 0.000000e+00, float* %1798, align 4
  %2056 = load float, float* %1512, align 4
  %2057 = load float, float* %386, align 4
  %2058 = fmul float %2056, %2057
  %2059 = fadd float 0.000000e+00, %2058
  store float %2059, float* %1798, align 4
  %2060 = load float, float* %1514, align 4
  %2061 = load float, float* %461, align 4
  %2062 = fmul float %2060, %2061
  %2063 = fadd float %2059, %2062
  store float %2063, float* %1798, align 4
  %2064 = load float, float* %1751, align 4
  %2065 = load float, float* %532, align 4
  %2066 = fmul float %2064, %2065
  %2067 = fadd float %2063, %2066
  store float %2067, float* %1798, align 4
  %2068 = load float, float* %1756, align 4
  %2069 = load float, float* %603, align 4
  %2070 = fmul float %2068, %2069
  %2071 = fadd float %2067, %2070
  store float %2071, float* %1798, align 4
  %2072 = call i8* @__memcpy_chk(i8* nonnull %3, i8* %1523, i64 64, i64 %5) #8
  call void @free(i8* %1393)
  call void @free(i8* %1395)
  call void @free(i8* %1429)
  call void @free(i8* %1431)
  call void @free(i8* %1457)
  call void @free(i8* %1483)
  %2073 = bitcast float* %847 to i32*
  %2074 = load i32, i32* %2073, align 4
  %2075 = bitcast float* %830 to i32*
  %2076 = load i32, i32* %2075, align 4
  store i32 %2076, i32* %2073, align 4
  store i32 %2074, i32* %2075, align 4
  br label %2077

2077:                                             ; preds = %2077, %.preheader33
  %indvars.iv3437 = phi i64 [ 2, %.preheader33 ], [ %indvars.iv.next35.1, %2077 ]
  %2078 = getelementptr inbounds float, float* %1, i64 %indvars.iv3437
  %2079 = bitcast float* %2078 to i32*
  %2080 = load i32, i32* %2079, align 4
  %2081 = shl nuw nsw i64 %indvars.iv3437, 2
  %2082 = getelementptr inbounds float, float* %1, i64 %2081
  %2083 = bitcast float* %2082 to i32*
  %2084 = load i32, i32* %2083, align 4
  store i32 %2084, i32* %2079, align 4
  store i32 %2080, i32* %2083, align 4
  %indvars.iv.next35 = or i64 %indvars.iv3437, 1
  %2085 = getelementptr inbounds float, float* %1, i64 %indvars.iv.next35
  %2086 = bitcast float* %2085 to i32*
  %2087 = load i32, i32* %2086, align 4
  %2088 = shl nuw nsw i64 %indvars.iv.next35, 2
  %2089 = getelementptr inbounds float, float* %1, i64 %2088
  %2090 = bitcast float* %2089 to i32*
  %2091 = load i32, i32* %2090, align 4
  store i32 %2091, i32* %2086, align 4
  store i32 %2087, i32* %2090, align 4
  %indvars.iv.next35.1 = add nuw nsw i64 %indvars.iv3437, 2
  %exitcond.1.not = icmp eq i64 %indvars.iv.next35.1, 4
  br i1 %exitcond.1.not, label %.lr.ph.new.1, label %2077

.lr.ph.new.1:                                     ; preds = %.lr.ph.new.1, %2077
  %indvars.iv3437.1 = phi i64 [ %indvars.iv.next35.1.1, %.lr.ph.new.1 ], [ 2, %2077 ]
  %2092 = add nuw nsw i64 %indvars.iv3437.1, 4
  %2093 = getelementptr inbounds float, float* %1, i64 %2092
  %2094 = bitcast float* %2093 to i32*
  %2095 = load i32, i32* %2094, align 4
  %2096 = shl nuw nsw i64 %indvars.iv3437.1, 2
  %2097 = or i64 %2096, 1
  %2098 = getelementptr inbounds float, float* %1, i64 %2097
  %2099 = bitcast float* %2098 to i32*
  %2100 = load i32, i32* %2099, align 4
  store i32 %2100, i32* %2094, align 4
  store i32 %2095, i32* %2099, align 4
  %indvars.iv.next35.1149 = or i64 %indvars.iv3437.1, 1
  %2101 = add nuw nsw i64 %indvars.iv3437.1, 5
  %2102 = getelementptr inbounds float, float* %1, i64 %2101
  %2103 = bitcast float* %2102 to i32*
  %2104 = load i32, i32* %2103, align 4
  %2105 = shl nuw nsw i64 %indvars.iv.next35.1149, 2
  %2106 = or i64 %2105, 1
  %2107 = getelementptr inbounds float, float* %1, i64 %2106
  %2108 = bitcast float* %2107 to i32*
  %2109 = load i32, i32* %2108, align 4
  store i32 %2109, i32* %2103, align 4
  store i32 %2104, i32* %2108, align 4
  %indvars.iv.next35.1.1 = add nuw nsw i64 %indvars.iv3437.1, 2
  %exitcond.1.1.not = icmp eq i64 %indvars.iv.next35.1.1, 4
  br i1 %exitcond.1.1.not, label %.prol.preheader.2, label %.lr.ph.new.1

.prol.preheader.2:                                ; preds = %.lr.ph.new.1
  %2110 = bitcast float* %901 to i32*
  %2111 = load i32, i32* %2110, align 4
  %2112 = bitcast float* %884 to i32*
  %2113 = load i32, i32* %2112, align 4
  store i32 %2113, i32* %2110, align 4
  store i32 %2111, i32* %2112, align 4
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
.preheader:
  %0 = alloca [16 x float], align 16
  %1 = alloca [16 x float], align 16
  %2 = alloca [16 x float], align 16
  %3 = bitcast [16 x float]* %0 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 16 dereferenceable(64) %3, i8* nonnull align 16 dereferenceable(64) bitcast ([16 x float]* @__const.main.A to i8*), i64 64, i1 false)
  %4 = bitcast [16 x float]* %1 to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 dereferenceable(64) %4, i8 0, i64 64, i1 false)
  %5 = bitcast [16 x float]* %2 to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 dereferenceable(64) %5, i8 0, i64 64, i1 false)
  %6 = getelementptr inbounds [16 x float], [16 x float]* %0, i64 0, i64 0
  %7 = getelementptr inbounds [16 x float], [16 x float]* %1, i64 0, i64 0
  %8 = getelementptr inbounds [16 x float], [16 x float]* %2, i64 0, i64 0
  call void @naive_fixed_qr_decomp(float* nonnull %6, float* nonnull %7, float* nonnull %8)
  %9 = load float, float* %6, align 16
  %10 = fpext float %9 to double
  %11 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %10) #8
  %12 = getelementptr inbounds [16 x float], [16 x float]* %0, i64 0, i64 1
  %13 = load float, float* %12, align 4
  %14 = fpext float %13 to double
  %15 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %14) #8
  %16 = getelementptr inbounds [16 x float], [16 x float]* %0, i64 0, i64 2
  %17 = load float, float* %16, align 8
  %18 = fpext float %17 to double
  %19 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %18) #8
  %20 = getelementptr inbounds [16 x float], [16 x float]* %0, i64 0, i64 3
  %21 = load float, float* %20, align 4
  %22 = fpext float %21 to double
  %23 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %22) #8
  %24 = getelementptr inbounds [16 x float], [16 x float]* %0, i64 0, i64 4
  %25 = load float, float* %24, align 16
  %26 = fpext float %25 to double
  %27 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %26) #8
  %28 = getelementptr inbounds [16 x float], [16 x float]* %0, i64 0, i64 5
  %29 = load float, float* %28, align 4
  %30 = fpext float %29 to double
  %31 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %30) #8
  %32 = getelementptr inbounds [16 x float], [16 x float]* %0, i64 0, i64 6
  %33 = load float, float* %32, align 8
  %34 = fpext float %33 to double
  %35 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %34) #8
  %36 = getelementptr inbounds [16 x float], [16 x float]* %0, i64 0, i64 7
  %37 = load float, float* %36, align 4
  %38 = fpext float %37 to double
  %39 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %38) #8
  %40 = getelementptr inbounds [16 x float], [16 x float]* %0, i64 0, i64 8
  %41 = load float, float* %40, align 16
  %42 = fpext float %41 to double
  %43 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %42) #8
  %44 = getelementptr inbounds [16 x float], [16 x float]* %0, i64 0, i64 9
  %45 = load float, float* %44, align 4
  %46 = fpext float %45 to double
  %47 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %46) #8
  %48 = getelementptr inbounds [16 x float], [16 x float]* %0, i64 0, i64 10
  %49 = load float, float* %48, align 8
  %50 = fpext float %49 to double
  %51 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %50) #8
  %52 = getelementptr inbounds [16 x float], [16 x float]* %0, i64 0, i64 11
  %53 = load float, float* %52, align 4
  %54 = fpext float %53 to double
  %55 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %54) #8
  %56 = getelementptr inbounds [16 x float], [16 x float]* %0, i64 0, i64 12
  %57 = load float, float* %56, align 16
  %58 = fpext float %57 to double
  %59 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %58) #8
  %60 = getelementptr inbounds [16 x float], [16 x float]* %0, i64 0, i64 13
  %61 = load float, float* %60, align 4
  %62 = fpext float %61 to double
  %63 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %62) #8
  %64 = getelementptr inbounds [16 x float], [16 x float]* %0, i64 0, i64 14
  %65 = load float, float* %64, align 8
  %66 = fpext float %65 to double
  %67 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %66) #8
  %68 = getelementptr inbounds [16 x float], [16 x float]* %0, i64 0, i64 15
  %69 = load float, float* %68, align 4
  %70 = fpext float %69 to double
  %71 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %70) #8
  ret i32 0
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
attributes #9 = { nounwind allocsize(0,1) }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
