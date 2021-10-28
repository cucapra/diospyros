; ModuleID = 'clang.ll'
source_filename = "llvm-tests/qr-decomp-fixed-size.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.A = private unnamed_addr constant [16 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00, float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00, float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00, float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00], align 16

; Function Attrs: alwaysinline nounwind ssp uwtable
define float @sgn(float %0) #0 {
  %2 = fcmp ogt float %0, 0.000000e+00
  %3 = zext i1 %2 to i32
  %4 = fcmp olt float %0, 0.000000e+00
  %5 = zext i1 %4 to i32
  %6 = sub nsw i32 %3, %5
  %7 = sitofp i32 %6 to float
  ret float %7
}

; Function Attrs: alwaysinline nounwind ssp uwtable
define float @naive_norm(float* %0, i32 %1) #0 {
  %3 = icmp sgt i32 %1, 0
  %smax = select i1 %3, i32 %1, i32 0
  %wide.trip.count = zext i32 %smax to i64
  br i1 %3, label %.lr.ph, label %._crit_edge

.lr.ph:                                           ; preds = %2
  %4 = add nsw i64 %wide.trip.count, -1
  %xtraiter = and i64 %wide.trip.count, 1
  %5 = icmp ult i64 %4, 1
  br i1 %5, label %._crit_edge.unr-lcssa, label %.lr.ph.new

.lr.ph.new:                                       ; preds = %.lr.ph
  %unroll_iter = sub i64 %wide.trip.count, %xtraiter
  br label %6

6:                                                ; preds = %6, %.lr.ph.new
  %.013 = phi float [ 0.000000e+00, %.lr.ph.new ], [ %20, %6 ]
  %indvars.iv2 = phi i64 [ 0, %.lr.ph.new ], [ %indvars.iv.next.1, %6 ]
  %niter = phi i64 [ %unroll_iter, %.lr.ph.new ], [ %niter.nsub.1, %6 ]
  %7 = getelementptr inbounds float, float* %0, i64 %indvars.iv2
  %8 = load float, float* %7, align 4
  %9 = fpext float %8 to double
  %10 = call double @llvm.pow.f64(double %9, double 2.000000e+00)
  %11 = fpext float %.013 to double
  %12 = fadd double %11, %10
  %13 = fptrunc double %12 to float
  %indvars.iv.next = add nuw nsw i64 %indvars.iv2, 1
  %niter.nsub = sub i64 %niter, 1
  %14 = getelementptr inbounds float, float* %0, i64 %indvars.iv.next
  %15 = load float, float* %14, align 4
  %16 = fpext float %15 to double
  %17 = call double @llvm.pow.f64(double %16, double 2.000000e+00)
  %18 = fpext float %13 to double
  %19 = fadd double %18, %17
  %20 = fptrunc double %19 to float
  %indvars.iv.next.1 = add nuw nsw i64 %indvars.iv.next, 1
  %niter.nsub.1 = sub i64 %niter.nsub, 1
  %niter.ncmp.1 = icmp ne i64 %niter.nsub.1, 0
  br i1 %niter.ncmp.1, label %6, label %._crit_edge.unr-lcssa

._crit_edge.unr-lcssa:                            ; preds = %6, %.lr.ph
  %split.ph = phi float [ undef, %.lr.ph ], [ %20, %6 ]
  %.013.unr = phi float [ 0.000000e+00, %.lr.ph ], [ %20, %6 ]
  %indvars.iv2.unr = phi i64 [ 0, %.lr.ph ], [ %indvars.iv.next.1, %6 ]
  %lcmp.mod = icmp ne i64 %xtraiter, 0
  br i1 %lcmp.mod, label %.epil.preheader, label %._crit_edge

.epil.preheader:                                  ; preds = %._crit_edge.unr-lcssa
  %.013.epil = phi float [ %.013.unr, %._crit_edge.unr-lcssa ]
  %indvars.iv2.epil = phi i64 [ %indvars.iv2.unr, %._crit_edge.unr-lcssa ]
  %21 = getelementptr inbounds float, float* %0, i64 %indvars.iv2.epil
  %22 = load float, float* %21, align 4
  %23 = fpext float %22 to double
  %24 = call double @llvm.pow.f64(double %23, double 2.000000e+00)
  %25 = fpext float %.013.epil to double
  %26 = fadd double %25, %24
  %27 = fptrunc double %26 to float
  %indvars.iv.next.epil = add nuw nsw i64 %indvars.iv2.epil, 1
  %exitcond.epil = icmp ne i64 %indvars.iv.next.epil, %wide.trip.count
  br label %._crit_edge

._crit_edge:                                      ; preds = %.epil.preheader, %._crit_edge.unr-lcssa, %2
  %.01.lcssa = phi float [ 0.000000e+00, %2 ], [ %split.ph, %._crit_edge.unr-lcssa ], [ %27, %.epil.preheader ]
  %28 = fpext float %.01.lcssa to double
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
.lr.ph:
  %1 = getelementptr inbounds float, float* %0, i64 1
  %2 = load float, float* %1, align 4
  %3 = getelementptr inbounds float, float* %0, i64 4
  %4 = load float, float* %3, align 4
  %5 = getelementptr inbounds float, float* %0, i64 1
  store float %4, float* %5, align 4
  %6 = getelementptr inbounds float, float* %0, i64 4
  store float %2, float* %6, align 4
  br label %7

7:                                                ; preds = %7, %.lr.ph
  %indvars.iv25 = phi i64 [ 2, %.lr.ph ], [ %indvars.iv.next3.1, %7 ]
  %8 = add nuw nsw i64 0, %indvars.iv25
  %9 = getelementptr inbounds float, float* %0, i64 %8
  %10 = load float, float* %9, align 4
  %11 = mul nuw nsw i64 %indvars.iv25, 4
  %12 = getelementptr inbounds float, float* %0, i64 %11
  %13 = load float, float* %12, align 4
  %14 = add nuw nsw i64 0, %indvars.iv25
  %15 = getelementptr inbounds float, float* %0, i64 %14
  store float %13, float* %15, align 4
  %16 = mul nuw nsw i64 %indvars.iv25, 4
  %17 = getelementptr inbounds float, float* %0, i64 %16
  store float %10, float* %17, align 4
  %indvars.iv.next3 = add nuw nsw i64 %indvars.iv25, 1
  %18 = add nuw nsw i64 0, %indvars.iv.next3
  %19 = getelementptr inbounds float, float* %0, i64 %18
  %20 = load float, float* %19, align 4
  %21 = mul nuw nsw i64 %indvars.iv.next3, 4
  %22 = getelementptr inbounds float, float* %0, i64 %21
  %23 = load float, float* %22, align 4
  %24 = add nuw nsw i64 0, %indvars.iv.next3
  %25 = getelementptr inbounds float, float* %0, i64 %24
  store float %23, float* %25, align 4
  %26 = mul nuw nsw i64 %indvars.iv.next3, 4
  %27 = getelementptr inbounds float, float* %0, i64 %26
  store float %20, float* %27, align 4
  %indvars.iv.next3.1 = add nuw nsw i64 %indvars.iv.next3, 1
  %exitcond.1 = icmp ne i64 %indvars.iv.next3.1, 4
  br i1 %exitcond.1, label %7, label %.lr.ph.new.1

.lr.ph.new.1:                                     ; preds = %7, %.lr.ph.new.1
  %indvars.iv25.1 = phi i64 [ %indvars.iv.next3.1.1, %.lr.ph.new.1 ], [ 2, %7 ]
  %28 = add nuw nsw i64 4, %indvars.iv25.1
  %29 = getelementptr inbounds float, float* %0, i64 %28
  %30 = load float, float* %29, align 4
  %31 = mul nuw nsw i64 %indvars.iv25.1, 4
  %32 = add nuw nsw i64 %31, 1
  %33 = getelementptr inbounds float, float* %0, i64 %32
  %34 = load float, float* %33, align 4
  %35 = add nuw nsw i64 4, %indvars.iv25.1
  %36 = getelementptr inbounds float, float* %0, i64 %35
  store float %34, float* %36, align 4
  %37 = mul nuw nsw i64 %indvars.iv25.1, 4
  %38 = add nuw nsw i64 %37, 1
  %39 = getelementptr inbounds float, float* %0, i64 %38
  store float %30, float* %39, align 4
  %indvars.iv.next3.113 = add nuw nsw i64 %indvars.iv25.1, 1
  %40 = add nuw nsw i64 4, %indvars.iv.next3.113
  %41 = getelementptr inbounds float, float* %0, i64 %40
  %42 = load float, float* %41, align 4
  %43 = mul nuw nsw i64 %indvars.iv.next3.113, 4
  %44 = add nuw nsw i64 %43, 1
  %45 = getelementptr inbounds float, float* %0, i64 %44
  %46 = load float, float* %45, align 4
  %47 = add nuw nsw i64 4, %indvars.iv.next3.113
  %48 = getelementptr inbounds float, float* %0, i64 %47
  store float %46, float* %48, align 4
  %49 = mul nuw nsw i64 %indvars.iv.next3.113, 4
  %50 = add nuw nsw i64 %49, 1
  %51 = getelementptr inbounds float, float* %0, i64 %50
  store float %42, float* %51, align 4
  %indvars.iv.next3.1.1 = add nuw nsw i64 %indvars.iv.next3.113, 1
  %exitcond.1.1 = icmp ne i64 %indvars.iv.next3.1.1, 4
  br i1 %exitcond.1.1, label %.lr.ph.new.1, label %.prol.preheader.2

.prol.preheader.2:                                ; preds = %.lr.ph.new.1
  %52 = getelementptr inbounds float, float* %0, i64 11
  %53 = load float, float* %52, align 4
  %54 = getelementptr inbounds float, float* %0, i64 14
  %55 = load float, float* %54, align 4
  %56 = getelementptr inbounds float, float* %0, i64 11
  store float %55, float* %56, align 4
  %57 = getelementptr inbounds float, float* %0, i64 14
  store float %53, float* %57, align 4
  ret void
}

; Function Attrs: alwaysinline nounwind ssp uwtable
define void @naive_fixed_matrix_multiply(float* %0, float* %1, float* %2) #0 {
.preheader:
  store float 0.000000e+00, float* %2, align 4
  %3 = load float, float* %0, align 4
  %4 = load float, float* %1, align 4
  %5 = fmul float %3, %4
  %6 = load float, float* %2, align 4
  %7 = fadd float %6, %5
  store float %7, float* %2, align 4
  %8 = getelementptr inbounds float, float* %0, i64 1
  %9 = load float, float* %8, align 4
  %10 = getelementptr inbounds float, float* %1, i64 4
  %11 = load float, float* %10, align 4
  %12 = fmul float %9, %11
  %13 = load float, float* %2, align 4
  %14 = fadd float %13, %12
  store float %14, float* %2, align 4
  %15 = getelementptr inbounds float, float* %0, i64 2
  %16 = load float, float* %15, align 4
  %17 = getelementptr inbounds float, float* %1, i64 8
  %18 = load float, float* %17, align 4
  %19 = fmul float %16, %18
  %20 = load float, float* %2, align 4
  %21 = fadd float %20, %19
  store float %21, float* %2, align 4
  %22 = getelementptr inbounds float, float* %0, i64 3
  %23 = load float, float* %22, align 4
  %24 = getelementptr inbounds float, float* %1, i64 12
  %25 = load float, float* %24, align 4
  %26 = fmul float %23, %25
  %27 = load float, float* %2, align 4
  %28 = fadd float %27, %26
  store float %28, float* %2, align 4
  %29 = getelementptr inbounds float, float* %2, i64 1
  store float 0.000000e+00, float* %29, align 4
  %30 = getelementptr inbounds float, float* %2, i64 1
  %31 = load float, float* %0, align 4
  %32 = getelementptr inbounds float, float* %1, i64 1
  %33 = load float, float* %32, align 4
  %34 = fmul float %31, %33
  %35 = load float, float* %30, align 4
  %36 = fadd float %35, %34
  store float %36, float* %30, align 4
  %37 = getelementptr inbounds float, float* %0, i64 1
  %38 = load float, float* %37, align 4
  %39 = getelementptr inbounds float, float* %1, i64 5
  %40 = load float, float* %39, align 4
  %41 = fmul float %38, %40
  %42 = load float, float* %30, align 4
  %43 = fadd float %42, %41
  store float %43, float* %30, align 4
  %44 = getelementptr inbounds float, float* %0, i64 2
  %45 = load float, float* %44, align 4
  %46 = getelementptr inbounds float, float* %1, i64 9
  %47 = load float, float* %46, align 4
  %48 = fmul float %45, %47
  %49 = load float, float* %30, align 4
  %50 = fadd float %49, %48
  store float %50, float* %30, align 4
  %51 = getelementptr inbounds float, float* %0, i64 3
  %52 = load float, float* %51, align 4
  %53 = getelementptr inbounds float, float* %1, i64 13
  %54 = load float, float* %53, align 4
  %55 = fmul float %52, %54
  %56 = load float, float* %30, align 4
  %57 = fadd float %56, %55
  store float %57, float* %30, align 4
  %58 = getelementptr inbounds float, float* %2, i64 2
  store float 0.000000e+00, float* %58, align 4
  %59 = getelementptr inbounds float, float* %2, i64 2
  %60 = load float, float* %0, align 4
  %61 = getelementptr inbounds float, float* %1, i64 2
  %62 = load float, float* %61, align 4
  %63 = fmul float %60, %62
  %64 = load float, float* %59, align 4
  %65 = fadd float %64, %63
  store float %65, float* %59, align 4
  %66 = getelementptr inbounds float, float* %0, i64 1
  %67 = load float, float* %66, align 4
  %68 = getelementptr inbounds float, float* %1, i64 6
  %69 = load float, float* %68, align 4
  %70 = fmul float %67, %69
  %71 = load float, float* %59, align 4
  %72 = fadd float %71, %70
  store float %72, float* %59, align 4
  %73 = getelementptr inbounds float, float* %0, i64 2
  %74 = load float, float* %73, align 4
  %75 = getelementptr inbounds float, float* %1, i64 10
  %76 = load float, float* %75, align 4
  %77 = fmul float %74, %76
  %78 = load float, float* %59, align 4
  %79 = fadd float %78, %77
  store float %79, float* %59, align 4
  %80 = getelementptr inbounds float, float* %0, i64 3
  %81 = load float, float* %80, align 4
  %82 = getelementptr inbounds float, float* %1, i64 14
  %83 = load float, float* %82, align 4
  %84 = fmul float %81, %83
  %85 = load float, float* %59, align 4
  %86 = fadd float %85, %84
  store float %86, float* %59, align 4
  %87 = getelementptr inbounds float, float* %2, i64 3
  store float 0.000000e+00, float* %87, align 4
  %88 = getelementptr inbounds float, float* %2, i64 3
  %89 = load float, float* %0, align 4
  %90 = getelementptr inbounds float, float* %1, i64 3
  %91 = load float, float* %90, align 4
  %92 = fmul float %89, %91
  %93 = load float, float* %88, align 4
  %94 = fadd float %93, %92
  store float %94, float* %88, align 4
  %95 = getelementptr inbounds float, float* %0, i64 1
  %96 = load float, float* %95, align 4
  %97 = getelementptr inbounds float, float* %1, i64 7
  %98 = load float, float* %97, align 4
  %99 = fmul float %96, %98
  %100 = load float, float* %88, align 4
  %101 = fadd float %100, %99
  store float %101, float* %88, align 4
  %102 = getelementptr inbounds float, float* %0, i64 2
  %103 = load float, float* %102, align 4
  %104 = getelementptr inbounds float, float* %1, i64 11
  %105 = load float, float* %104, align 4
  %106 = fmul float %103, %105
  %107 = load float, float* %88, align 4
  %108 = fadd float %107, %106
  store float %108, float* %88, align 4
  %109 = getelementptr inbounds float, float* %0, i64 3
  %110 = load float, float* %109, align 4
  %111 = getelementptr inbounds float, float* %1, i64 15
  %112 = load float, float* %111, align 4
  %113 = fmul float %110, %112
  %114 = load float, float* %88, align 4
  %115 = fadd float %114, %113
  store float %115, float* %88, align 4
  %116 = getelementptr inbounds float, float* %0, i64 4
  %117 = getelementptr inbounds float, float* %2, i64 4
  store float 0.000000e+00, float* %117, align 4
  %118 = getelementptr inbounds float, float* %2, i64 4
  %119 = load float, float* %116, align 4
  %120 = load float, float* %1, align 4
  %121 = fmul float %119, %120
  %122 = load float, float* %118, align 4
  %123 = fadd float %122, %121
  store float %123, float* %118, align 4
  %124 = getelementptr inbounds float, float* %0, i64 5
  %125 = load float, float* %124, align 4
  %126 = getelementptr inbounds float, float* %1, i64 4
  %127 = load float, float* %126, align 4
  %128 = fmul float %125, %127
  %129 = load float, float* %118, align 4
  %130 = fadd float %129, %128
  store float %130, float* %118, align 4
  %131 = getelementptr inbounds float, float* %0, i64 6
  %132 = load float, float* %131, align 4
  %133 = getelementptr inbounds float, float* %1, i64 8
  %134 = load float, float* %133, align 4
  %135 = fmul float %132, %134
  %136 = load float, float* %118, align 4
  %137 = fadd float %136, %135
  store float %137, float* %118, align 4
  %138 = getelementptr inbounds float, float* %0, i64 7
  %139 = load float, float* %138, align 4
  %140 = getelementptr inbounds float, float* %1, i64 12
  %141 = load float, float* %140, align 4
  %142 = fmul float %139, %141
  %143 = load float, float* %118, align 4
  %144 = fadd float %143, %142
  store float %144, float* %118, align 4
  %145 = getelementptr inbounds float, float* %2, i64 5
  store float 0.000000e+00, float* %145, align 4
  %146 = getelementptr inbounds float, float* %2, i64 5
  %147 = load float, float* %116, align 4
  %148 = getelementptr inbounds float, float* %1, i64 1
  %149 = load float, float* %148, align 4
  %150 = fmul float %147, %149
  %151 = load float, float* %146, align 4
  %152 = fadd float %151, %150
  store float %152, float* %146, align 4
  %153 = getelementptr inbounds float, float* %0, i64 5
  %154 = load float, float* %153, align 4
  %155 = getelementptr inbounds float, float* %1, i64 5
  %156 = load float, float* %155, align 4
  %157 = fmul float %154, %156
  %158 = load float, float* %146, align 4
  %159 = fadd float %158, %157
  store float %159, float* %146, align 4
  %160 = getelementptr inbounds float, float* %0, i64 6
  %161 = load float, float* %160, align 4
  %162 = getelementptr inbounds float, float* %1, i64 9
  %163 = load float, float* %162, align 4
  %164 = fmul float %161, %163
  %165 = load float, float* %146, align 4
  %166 = fadd float %165, %164
  store float %166, float* %146, align 4
  %167 = getelementptr inbounds float, float* %0, i64 7
  %168 = load float, float* %167, align 4
  %169 = getelementptr inbounds float, float* %1, i64 13
  %170 = load float, float* %169, align 4
  %171 = fmul float %168, %170
  %172 = load float, float* %146, align 4
  %173 = fadd float %172, %171
  store float %173, float* %146, align 4
  %174 = getelementptr inbounds float, float* %2, i64 6
  store float 0.000000e+00, float* %174, align 4
  %175 = getelementptr inbounds float, float* %2, i64 6
  %176 = load float, float* %116, align 4
  %177 = getelementptr inbounds float, float* %1, i64 2
  %178 = load float, float* %177, align 4
  %179 = fmul float %176, %178
  %180 = load float, float* %175, align 4
  %181 = fadd float %180, %179
  store float %181, float* %175, align 4
  %182 = getelementptr inbounds float, float* %0, i64 5
  %183 = load float, float* %182, align 4
  %184 = getelementptr inbounds float, float* %1, i64 6
  %185 = load float, float* %184, align 4
  %186 = fmul float %183, %185
  %187 = load float, float* %175, align 4
  %188 = fadd float %187, %186
  store float %188, float* %175, align 4
  %189 = getelementptr inbounds float, float* %0, i64 6
  %190 = load float, float* %189, align 4
  %191 = getelementptr inbounds float, float* %1, i64 10
  %192 = load float, float* %191, align 4
  %193 = fmul float %190, %192
  %194 = load float, float* %175, align 4
  %195 = fadd float %194, %193
  store float %195, float* %175, align 4
  %196 = getelementptr inbounds float, float* %0, i64 7
  %197 = load float, float* %196, align 4
  %198 = getelementptr inbounds float, float* %1, i64 14
  %199 = load float, float* %198, align 4
  %200 = fmul float %197, %199
  %201 = load float, float* %175, align 4
  %202 = fadd float %201, %200
  store float %202, float* %175, align 4
  %203 = getelementptr inbounds float, float* %2, i64 7
  store float 0.000000e+00, float* %203, align 4
  %204 = getelementptr inbounds float, float* %2, i64 7
  %205 = load float, float* %116, align 4
  %206 = getelementptr inbounds float, float* %1, i64 3
  %207 = load float, float* %206, align 4
  %208 = fmul float %205, %207
  %209 = load float, float* %204, align 4
  %210 = fadd float %209, %208
  store float %210, float* %204, align 4
  %211 = getelementptr inbounds float, float* %0, i64 5
  %212 = load float, float* %211, align 4
  %213 = getelementptr inbounds float, float* %1, i64 7
  %214 = load float, float* %213, align 4
  %215 = fmul float %212, %214
  %216 = load float, float* %204, align 4
  %217 = fadd float %216, %215
  store float %217, float* %204, align 4
  %218 = getelementptr inbounds float, float* %0, i64 6
  %219 = load float, float* %218, align 4
  %220 = getelementptr inbounds float, float* %1, i64 11
  %221 = load float, float* %220, align 4
  %222 = fmul float %219, %221
  %223 = load float, float* %204, align 4
  %224 = fadd float %223, %222
  store float %224, float* %204, align 4
  %225 = getelementptr inbounds float, float* %0, i64 7
  %226 = load float, float* %225, align 4
  %227 = getelementptr inbounds float, float* %1, i64 15
  %228 = load float, float* %227, align 4
  %229 = fmul float %226, %228
  %230 = load float, float* %204, align 4
  %231 = fadd float %230, %229
  store float %231, float* %204, align 4
  %232 = getelementptr inbounds float, float* %0, i64 8
  %233 = getelementptr inbounds float, float* %2, i64 8
  store float 0.000000e+00, float* %233, align 4
  %234 = getelementptr inbounds float, float* %2, i64 8
  %235 = load float, float* %232, align 4
  %236 = load float, float* %1, align 4
  %237 = fmul float %235, %236
  %238 = load float, float* %234, align 4
  %239 = fadd float %238, %237
  store float %239, float* %234, align 4
  %240 = getelementptr inbounds float, float* %0, i64 9
  %241 = load float, float* %240, align 4
  %242 = getelementptr inbounds float, float* %1, i64 4
  %243 = load float, float* %242, align 4
  %244 = fmul float %241, %243
  %245 = load float, float* %234, align 4
  %246 = fadd float %245, %244
  store float %246, float* %234, align 4
  %247 = getelementptr inbounds float, float* %0, i64 10
  %248 = load float, float* %247, align 4
  %249 = getelementptr inbounds float, float* %1, i64 8
  %250 = load float, float* %249, align 4
  %251 = fmul float %248, %250
  %252 = load float, float* %234, align 4
  %253 = fadd float %252, %251
  store float %253, float* %234, align 4
  %254 = getelementptr inbounds float, float* %0, i64 11
  %255 = load float, float* %254, align 4
  %256 = getelementptr inbounds float, float* %1, i64 12
  %257 = load float, float* %256, align 4
  %258 = fmul float %255, %257
  %259 = load float, float* %234, align 4
  %260 = fadd float %259, %258
  store float %260, float* %234, align 4
  %261 = getelementptr inbounds float, float* %2, i64 9
  store float 0.000000e+00, float* %261, align 4
  %262 = getelementptr inbounds float, float* %2, i64 9
  %263 = load float, float* %232, align 4
  %264 = getelementptr inbounds float, float* %1, i64 1
  %265 = load float, float* %264, align 4
  %266 = fmul float %263, %265
  %267 = load float, float* %262, align 4
  %268 = fadd float %267, %266
  store float %268, float* %262, align 4
  %269 = getelementptr inbounds float, float* %0, i64 9
  %270 = load float, float* %269, align 4
  %271 = getelementptr inbounds float, float* %1, i64 5
  %272 = load float, float* %271, align 4
  %273 = fmul float %270, %272
  %274 = load float, float* %262, align 4
  %275 = fadd float %274, %273
  store float %275, float* %262, align 4
  %276 = getelementptr inbounds float, float* %0, i64 10
  %277 = load float, float* %276, align 4
  %278 = getelementptr inbounds float, float* %1, i64 9
  %279 = load float, float* %278, align 4
  %280 = fmul float %277, %279
  %281 = load float, float* %262, align 4
  %282 = fadd float %281, %280
  store float %282, float* %262, align 4
  %283 = getelementptr inbounds float, float* %0, i64 11
  %284 = load float, float* %283, align 4
  %285 = getelementptr inbounds float, float* %1, i64 13
  %286 = load float, float* %285, align 4
  %287 = fmul float %284, %286
  %288 = load float, float* %262, align 4
  %289 = fadd float %288, %287
  store float %289, float* %262, align 4
  %290 = getelementptr inbounds float, float* %2, i64 10
  store float 0.000000e+00, float* %290, align 4
  %291 = getelementptr inbounds float, float* %2, i64 10
  %292 = load float, float* %232, align 4
  %293 = getelementptr inbounds float, float* %1, i64 2
  %294 = load float, float* %293, align 4
  %295 = fmul float %292, %294
  %296 = load float, float* %291, align 4
  %297 = fadd float %296, %295
  store float %297, float* %291, align 4
  %298 = getelementptr inbounds float, float* %0, i64 9
  %299 = load float, float* %298, align 4
  %300 = getelementptr inbounds float, float* %1, i64 6
  %301 = load float, float* %300, align 4
  %302 = fmul float %299, %301
  %303 = load float, float* %291, align 4
  %304 = fadd float %303, %302
  store float %304, float* %291, align 4
  %305 = getelementptr inbounds float, float* %0, i64 10
  %306 = load float, float* %305, align 4
  %307 = getelementptr inbounds float, float* %1, i64 10
  %308 = load float, float* %307, align 4
  %309 = fmul float %306, %308
  %310 = load float, float* %291, align 4
  %311 = fadd float %310, %309
  store float %311, float* %291, align 4
  %312 = getelementptr inbounds float, float* %0, i64 11
  %313 = load float, float* %312, align 4
  %314 = getelementptr inbounds float, float* %1, i64 14
  %315 = load float, float* %314, align 4
  %316 = fmul float %313, %315
  %317 = load float, float* %291, align 4
  %318 = fadd float %317, %316
  store float %318, float* %291, align 4
  %319 = getelementptr inbounds float, float* %2, i64 11
  store float 0.000000e+00, float* %319, align 4
  %320 = getelementptr inbounds float, float* %2, i64 11
  %321 = load float, float* %232, align 4
  %322 = getelementptr inbounds float, float* %1, i64 3
  %323 = load float, float* %322, align 4
  %324 = fmul float %321, %323
  %325 = load float, float* %320, align 4
  %326 = fadd float %325, %324
  store float %326, float* %320, align 4
  %327 = getelementptr inbounds float, float* %0, i64 9
  %328 = load float, float* %327, align 4
  %329 = getelementptr inbounds float, float* %1, i64 7
  %330 = load float, float* %329, align 4
  %331 = fmul float %328, %330
  %332 = load float, float* %320, align 4
  %333 = fadd float %332, %331
  store float %333, float* %320, align 4
  %334 = getelementptr inbounds float, float* %0, i64 10
  %335 = load float, float* %334, align 4
  %336 = getelementptr inbounds float, float* %1, i64 11
  %337 = load float, float* %336, align 4
  %338 = fmul float %335, %337
  %339 = load float, float* %320, align 4
  %340 = fadd float %339, %338
  store float %340, float* %320, align 4
  %341 = getelementptr inbounds float, float* %0, i64 11
  %342 = load float, float* %341, align 4
  %343 = getelementptr inbounds float, float* %1, i64 15
  %344 = load float, float* %343, align 4
  %345 = fmul float %342, %344
  %346 = load float, float* %320, align 4
  %347 = fadd float %346, %345
  store float %347, float* %320, align 4
  %348 = getelementptr inbounds float, float* %0, i64 12
  %349 = getelementptr inbounds float, float* %2, i64 12
  store float 0.000000e+00, float* %349, align 4
  %350 = getelementptr inbounds float, float* %2, i64 12
  %351 = load float, float* %348, align 4
  %352 = load float, float* %1, align 4
  %353 = fmul float %351, %352
  %354 = load float, float* %350, align 4
  %355 = fadd float %354, %353
  store float %355, float* %350, align 4
  %356 = getelementptr inbounds float, float* %0, i64 13
  %357 = load float, float* %356, align 4
  %358 = getelementptr inbounds float, float* %1, i64 4
  %359 = load float, float* %358, align 4
  %360 = fmul float %357, %359
  %361 = load float, float* %350, align 4
  %362 = fadd float %361, %360
  store float %362, float* %350, align 4
  %363 = getelementptr inbounds float, float* %0, i64 14
  %364 = load float, float* %363, align 4
  %365 = getelementptr inbounds float, float* %1, i64 8
  %366 = load float, float* %365, align 4
  %367 = fmul float %364, %366
  %368 = load float, float* %350, align 4
  %369 = fadd float %368, %367
  store float %369, float* %350, align 4
  %370 = getelementptr inbounds float, float* %0, i64 15
  %371 = load float, float* %370, align 4
  %372 = getelementptr inbounds float, float* %1, i64 12
  %373 = load float, float* %372, align 4
  %374 = fmul float %371, %373
  %375 = load float, float* %350, align 4
  %376 = fadd float %375, %374
  store float %376, float* %350, align 4
  %377 = getelementptr inbounds float, float* %2, i64 13
  store float 0.000000e+00, float* %377, align 4
  %378 = getelementptr inbounds float, float* %2, i64 13
  %379 = load float, float* %348, align 4
  %380 = getelementptr inbounds float, float* %1, i64 1
  %381 = load float, float* %380, align 4
  %382 = fmul float %379, %381
  %383 = load float, float* %378, align 4
  %384 = fadd float %383, %382
  store float %384, float* %378, align 4
  %385 = getelementptr inbounds float, float* %0, i64 13
  %386 = load float, float* %385, align 4
  %387 = getelementptr inbounds float, float* %1, i64 5
  %388 = load float, float* %387, align 4
  %389 = fmul float %386, %388
  %390 = load float, float* %378, align 4
  %391 = fadd float %390, %389
  store float %391, float* %378, align 4
  %392 = getelementptr inbounds float, float* %0, i64 14
  %393 = load float, float* %392, align 4
  %394 = getelementptr inbounds float, float* %1, i64 9
  %395 = load float, float* %394, align 4
  %396 = fmul float %393, %395
  %397 = load float, float* %378, align 4
  %398 = fadd float %397, %396
  store float %398, float* %378, align 4
  %399 = getelementptr inbounds float, float* %0, i64 15
  %400 = load float, float* %399, align 4
  %401 = getelementptr inbounds float, float* %1, i64 13
  %402 = load float, float* %401, align 4
  %403 = fmul float %400, %402
  %404 = load float, float* %378, align 4
  %405 = fadd float %404, %403
  store float %405, float* %378, align 4
  %406 = getelementptr inbounds float, float* %2, i64 14
  store float 0.000000e+00, float* %406, align 4
  %407 = getelementptr inbounds float, float* %2, i64 14
  %408 = load float, float* %348, align 4
  %409 = getelementptr inbounds float, float* %1, i64 2
  %410 = load float, float* %409, align 4
  %411 = fmul float %408, %410
  %412 = load float, float* %407, align 4
  %413 = fadd float %412, %411
  store float %413, float* %407, align 4
  %414 = getelementptr inbounds float, float* %0, i64 13
  %415 = load float, float* %414, align 4
  %416 = getelementptr inbounds float, float* %1, i64 6
  %417 = load float, float* %416, align 4
  %418 = fmul float %415, %417
  %419 = load float, float* %407, align 4
  %420 = fadd float %419, %418
  store float %420, float* %407, align 4
  %421 = getelementptr inbounds float, float* %0, i64 14
  %422 = load float, float* %421, align 4
  %423 = getelementptr inbounds float, float* %1, i64 10
  %424 = load float, float* %423, align 4
  %425 = fmul float %422, %424
  %426 = load float, float* %407, align 4
  %427 = fadd float %426, %425
  store float %427, float* %407, align 4
  %428 = getelementptr inbounds float, float* %0, i64 15
  %429 = load float, float* %428, align 4
  %430 = getelementptr inbounds float, float* %1, i64 14
  %431 = load float, float* %430, align 4
  %432 = fmul float %429, %431
  %433 = load float, float* %407, align 4
  %434 = fadd float %433, %432
  store float %434, float* %407, align 4
  %435 = getelementptr inbounds float, float* %2, i64 15
  store float 0.000000e+00, float* %435, align 4
  %436 = getelementptr inbounds float, float* %2, i64 15
  %437 = load float, float* %348, align 4
  %438 = getelementptr inbounds float, float* %1, i64 3
  %439 = load float, float* %438, align 4
  %440 = fmul float %437, %439
  %441 = load float, float* %436, align 4
  %442 = fadd float %441, %440
  store float %442, float* %436, align 4
  %443 = getelementptr inbounds float, float* %0, i64 13
  %444 = load float, float* %443, align 4
  %445 = getelementptr inbounds float, float* %1, i64 7
  %446 = load float, float* %445, align 4
  %447 = fmul float %444, %446
  %448 = load float, float* %436, align 4
  %449 = fadd float %448, %447
  store float %449, float* %436, align 4
  %450 = getelementptr inbounds float, float* %0, i64 14
  %451 = load float, float* %450, align 4
  %452 = getelementptr inbounds float, float* %1, i64 11
  %453 = load float, float* %452, align 4
  %454 = fmul float %451, %453
  %455 = load float, float* %436, align 4
  %456 = fadd float %455, %454
  store float %456, float* %436, align 4
  %457 = getelementptr inbounds float, float* %0, i64 15
  %458 = load float, float* %457, align 4
  %459 = getelementptr inbounds float, float* %1, i64 15
  %460 = load float, float* %459, align 4
  %461 = fmul float %458, %460
  %462 = load float, float* %436, align 4
  %463 = fadd float %462, %461
  store float %463, float* %436, align 4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define void @naive_fixed_qr_decomp(float* %0, float* %1, float* %2) #2 {
.preheader33:
  %3 = bitcast float* %2 to i8*
  %4 = bitcast float* %0 to i8*
  %5 = bitcast float* %2 to i8*
  %6 = call i64 @llvm.objectsize.i64.p0i8(i8* %5, i1 false, i1 true, i1 false)
  %7 = call i8* @__memcpy_chk(i8* %3, i8* %4, i64 64, i64 %6) #8
  %8 = call i8* @calloc(i64 4, i64 16) #9
  %9 = bitcast i8* %8 to float*
  store float 1.000000e+00, float* %9, align 4
  %10 = getelementptr inbounds float, float* %9, i64 1
  store float 0.000000e+00, float* %10, align 4
  %11 = getelementptr inbounds float, float* %9, i64 2
  store float 0.000000e+00, float* %11, align 4
  %12 = getelementptr inbounds float, float* %9, i64 3
  store float 0.000000e+00, float* %12, align 4
  %13 = getelementptr inbounds float, float* %9, i64 4
  store float 0.000000e+00, float* %13, align 4
  %14 = getelementptr inbounds float, float* %9, i64 5
  store float 1.000000e+00, float* %14, align 4
  %15 = getelementptr inbounds float, float* %9, i64 6
  store float 0.000000e+00, float* %15, align 4
  %16 = getelementptr inbounds float, float* %9, i64 7
  store float 0.000000e+00, float* %16, align 4
  %17 = getelementptr inbounds float, float* %9, i64 8
  store float 0.000000e+00, float* %17, align 4
  %18 = getelementptr inbounds float, float* %9, i64 9
  store float 0.000000e+00, float* %18, align 4
  %19 = getelementptr inbounds float, float* %9, i64 10
  store float 1.000000e+00, float* %19, align 4
  %20 = getelementptr inbounds float, float* %9, i64 11
  store float 0.000000e+00, float* %20, align 4
  %21 = getelementptr inbounds float, float* %9, i64 12
  store float 0.000000e+00, float* %21, align 4
  %22 = getelementptr inbounds float, float* %9, i64 13
  store float 0.000000e+00, float* %22, align 4
  %23 = getelementptr inbounds float, float* %9, i64 14
  store float 0.000000e+00, float* %23, align 4
  %24 = getelementptr inbounds float, float* %9, i64 15
  store float 1.000000e+00, float* %24, align 4
  %25 = bitcast float* %1 to i8*
  %26 = bitcast float* %1 to i8*
  %27 = call i64 @llvm.objectsize.i64.p0i8(i8* %26, i1 false, i1 true, i1 false)
  %28 = bitcast float* %2 to i8*
  %29 = bitcast float* %2 to i8*
  %30 = call i64 @llvm.objectsize.i64.p0i8(i8* %29, i1 false, i1 true, i1 false)
  %31 = bitcast float* %1 to i8*
  %32 = bitcast float* %1 to i8*
  %33 = call i64 @llvm.objectsize.i64.p0i8(i8* %32, i1 false, i1 true, i1 false)
  %34 = call i8* @calloc(i64 4, i64 4) #9
  %35 = bitcast i8* %34 to float*
  %36 = call i8* @calloc(i64 4, i64 4) #9
  %37 = bitcast i8* %36 to float*
  %38 = load float, float* %2, align 4
  store float %38, float* %35, align 4
  %39 = load float, float* %9, align 4
  store float %39, float* %37, align 4
  %40 = getelementptr inbounds float, float* %2, i64 4
  %41 = load float, float* %40, align 4
  %42 = getelementptr inbounds float, float* %35, i64 1
  store float %41, float* %42, align 4
  %43 = getelementptr inbounds float, float* %9, i64 4
  %44 = load float, float* %43, align 4
  %45 = getelementptr inbounds float, float* %37, i64 1
  store float %44, float* %45, align 4
  %46 = getelementptr inbounds float, float* %2, i64 8
  %47 = load float, float* %46, align 4
  %48 = getelementptr inbounds float, float* %35, i64 2
  store float %47, float* %48, align 4
  %49 = getelementptr inbounds float, float* %9, i64 8
  %50 = load float, float* %49, align 4
  %51 = getelementptr inbounds float, float* %37, i64 2
  store float %50, float* %51, align 4
  %52 = getelementptr inbounds float, float* %2, i64 12
  %53 = load float, float* %52, align 4
  %54 = getelementptr inbounds float, float* %35, i64 3
  store float %53, float* %54, align 4
  %55 = getelementptr inbounds float, float* %9, i64 12
  %56 = load float, float* %55, align 4
  %57 = getelementptr inbounds float, float* %37, i64 3
  store float %56, float* %57, align 4
  %58 = load float, float* %35, align 4
  %59 = fcmp ogt float %58, 0.000000e+00
  %60 = zext i1 %59 to i32
  %61 = fcmp olt float %58, 0.000000e+00
  %62 = zext i1 %61 to i32
  %63 = sub nsw i32 %60, %62
  %64 = sitofp i32 %63 to float
  %65 = load float, float* %35, align 4
  %66 = fpext float %65 to double
  %67 = call double @llvm.pow.f64(double %66, double 2.000000e+00) #8
  %68 = fadd double 0.000000e+00, %67
  %69 = fptrunc double %68 to float
  %70 = getelementptr inbounds float, float* %35, i64 1
  %71 = load float, float* %70, align 4
  %72 = fpext float %71 to double
  %73 = call double @llvm.pow.f64(double %72, double 2.000000e+00) #8
  %74 = fpext float %69 to double
  %75 = fadd double %74, %73
  %76 = fptrunc double %75 to float
  %77 = getelementptr inbounds float, float* %35, i64 2
  %78 = load float, float* %77, align 4
  %79 = fpext float %78 to double
  %80 = call double @llvm.pow.f64(double %79, double 2.000000e+00) #8
  %81 = fpext float %76 to double
  %82 = fadd double %81, %80
  %83 = fptrunc double %82 to float
  %84 = getelementptr inbounds float, float* %35, i64 3
  %85 = load float, float* %84, align 4
  %86 = fpext float %85 to double
  %87 = call double @llvm.pow.f64(double %86, double 2.000000e+00) #8
  %88 = fpext float %83 to double
  %89 = fadd double %88, %87
  %90 = fptrunc double %89 to float
  %91 = fneg float %64
  %92 = fpext float %90 to double
  %93 = call double @llvm.sqrt.f64(double %92) #8
  %94 = fptrunc double %93 to float
  %95 = fmul float %91, %94
  %96 = call i8* @calloc(i64 4, i64 4) #9
  %97 = bitcast i8* %96 to float*
  %98 = call i8* @calloc(i64 4, i64 4) #9
  %99 = load float, float* %35, align 4
  %100 = load float, float* %37, align 4
  %101 = fmul float %95, %100
  %102 = fadd float %99, %101
  store float %102, float* %97, align 4
  %103 = getelementptr inbounds float, float* %35, i64 1
  %104 = load float, float* %103, align 4
  %105 = getelementptr inbounds float, float* %37, i64 1
  %106 = load float, float* %105, align 4
  %107 = fmul float %95, %106
  %108 = fadd float %104, %107
  %109 = getelementptr inbounds float, float* %97, i64 1
  store float %108, float* %109, align 4
  %110 = getelementptr inbounds float, float* %35, i64 2
  %111 = load float, float* %110, align 4
  %112 = getelementptr inbounds float, float* %37, i64 2
  %113 = load float, float* %112, align 4
  %114 = fmul float %95, %113
  %115 = fadd float %111, %114
  %116 = getelementptr inbounds float, float* %97, i64 2
  store float %115, float* %116, align 4
  %117 = getelementptr inbounds float, float* %35, i64 3
  %118 = load float, float* %117, align 4
  %119 = getelementptr inbounds float, float* %37, i64 3
  %120 = load float, float* %119, align 4
  %121 = fmul float %95, %120
  %122 = fadd float %118, %121
  %123 = getelementptr inbounds float, float* %97, i64 3
  store float %122, float* %123, align 4
  %124 = load float, float* %97, align 4
  %125 = fpext float %124 to double
  %126 = call double @llvm.pow.f64(double %125, double 2.000000e+00) #8
  %127 = fadd double 0.000000e+00, %126
  %128 = fptrunc double %127 to float
  %129 = getelementptr inbounds float, float* %97, i64 1
  %130 = load float, float* %129, align 4
  %131 = fpext float %130 to double
  %132 = call double @llvm.pow.f64(double %131, double 2.000000e+00) #8
  %133 = fpext float %128 to double
  %134 = fadd double %133, %132
  %135 = fptrunc double %134 to float
  %136 = getelementptr inbounds float, float* %97, i64 2
  %137 = load float, float* %136, align 4
  %138 = fpext float %137 to double
  %139 = call double @llvm.pow.f64(double %138, double 2.000000e+00) #8
  %140 = fpext float %135 to double
  %141 = fadd double %140, %139
  %142 = fptrunc double %141 to float
  %143 = getelementptr inbounds float, float* %97, i64 3
  %144 = load float, float* %143, align 4
  %145 = fpext float %144 to double
  %146 = call double @llvm.pow.f64(double %145, double 2.000000e+00) #8
  %147 = fpext float %142 to double
  %148 = fadd double %147, %146
  %149 = fptrunc double %148 to float
  %150 = bitcast i8* %98 to float*
  %151 = fpext float %149 to double
  %152 = call double @llvm.sqrt.f64(double %151) #8
  %153 = fptrunc double %152 to float
  %154 = load float, float* %97, align 4
  %155 = fdiv float %154, %153
  store float %155, float* %150, align 4
  %156 = getelementptr inbounds float, float* %97, i64 1
  %157 = load float, float* %156, align 4
  %158 = fdiv float %157, %153
  %159 = getelementptr inbounds float, float* %150, i64 1
  store float %158, float* %159, align 4
  %160 = getelementptr inbounds float, float* %97, i64 2
  %161 = load float, float* %160, align 4
  %162 = fdiv float %161, %153
  %163 = getelementptr inbounds float, float* %150, i64 2
  store float %162, float* %163, align 4
  %164 = getelementptr inbounds float, float* %97, i64 3
  %165 = load float, float* %164, align 4
  %166 = fdiv float %165, %153
  %167 = getelementptr inbounds float, float* %150, i64 3
  store float %166, float* %167, align 4
  %168 = call i8* @calloc(i64 4, i64 16) #9
  %169 = bitcast i8* %168 to float*
  %170 = load float, float* %150, align 4
  %171 = fmul float 2.000000e+00, %170
  %172 = load float, float* %150, align 4
  %173 = fmul float %171, %172
  %174 = fpext float %173 to double
  %175 = fsub double 1.000000e+00, %174
  %176 = fptrunc double %175 to float
  store float %176, float* %169, align 4
  %177 = load float, float* %150, align 4
  %178 = fmul float 2.000000e+00, %177
  %179 = getelementptr inbounds float, float* %150, i64 1
  %180 = load float, float* %179, align 4
  %181 = fmul float %178, %180
  %182 = fpext float %181 to double
  %183 = fsub double 0.000000e+00, %182
  %184 = fptrunc double %183 to float
  %185 = getelementptr inbounds float, float* %169, i64 1
  store float %184, float* %185, align 4
  %186 = load float, float* %150, align 4
  %187 = fmul float 2.000000e+00, %186
  %188 = getelementptr inbounds float, float* %150, i64 2
  %189 = load float, float* %188, align 4
  %190 = fmul float %187, %189
  %191 = fpext float %190 to double
  %192 = fsub double 0.000000e+00, %191
  %193 = fptrunc double %192 to float
  %194 = getelementptr inbounds float, float* %169, i64 2
  store float %193, float* %194, align 4
  %195 = load float, float* %150, align 4
  %196 = fmul float 2.000000e+00, %195
  %197 = getelementptr inbounds float, float* %150, i64 3
  %198 = load float, float* %197, align 4
  %199 = fmul float %196, %198
  %200 = fpext float %199 to double
  %201 = fsub double 0.000000e+00, %200
  %202 = fptrunc double %201 to float
  %203 = getelementptr inbounds float, float* %169, i64 3
  store float %202, float* %203, align 4
  %204 = getelementptr inbounds float, float* %150, i64 1
  %205 = load float, float* %204, align 4
  %206 = fmul float 2.000000e+00, %205
  %207 = load float, float* %150, align 4
  %208 = fmul float %206, %207
  %209 = fpext float %208 to double
  %210 = fsub double 0.000000e+00, %209
  %211 = fptrunc double %210 to float
  %212 = getelementptr inbounds float, float* %169, i64 4
  store float %211, float* %212, align 4
  %213 = load float, float* %204, align 4
  %214 = fmul float 2.000000e+00, %213
  %215 = getelementptr inbounds float, float* %150, i64 1
  %216 = load float, float* %215, align 4
  %217 = fmul float %214, %216
  %218 = fpext float %217 to double
  %219 = fsub double 1.000000e+00, %218
  %220 = fptrunc double %219 to float
  %221 = getelementptr inbounds float, float* %169, i64 5
  store float %220, float* %221, align 4
  %222 = load float, float* %204, align 4
  %223 = fmul float 2.000000e+00, %222
  %224 = getelementptr inbounds float, float* %150, i64 2
  %225 = load float, float* %224, align 4
  %226 = fmul float %223, %225
  %227 = fpext float %226 to double
  %228 = fsub double 0.000000e+00, %227
  %229 = fptrunc double %228 to float
  %230 = getelementptr inbounds float, float* %169, i64 6
  store float %229, float* %230, align 4
  %231 = load float, float* %204, align 4
  %232 = fmul float 2.000000e+00, %231
  %233 = getelementptr inbounds float, float* %150, i64 3
  %234 = load float, float* %233, align 4
  %235 = fmul float %232, %234
  %236 = fpext float %235 to double
  %237 = fsub double 0.000000e+00, %236
  %238 = fptrunc double %237 to float
  %239 = getelementptr inbounds float, float* %169, i64 7
  store float %238, float* %239, align 4
  %240 = getelementptr inbounds float, float* %150, i64 2
  %241 = load float, float* %240, align 4
  %242 = fmul float 2.000000e+00, %241
  %243 = load float, float* %150, align 4
  %244 = fmul float %242, %243
  %245 = fpext float %244 to double
  %246 = fsub double 0.000000e+00, %245
  %247 = fptrunc double %246 to float
  %248 = getelementptr inbounds float, float* %169, i64 8
  store float %247, float* %248, align 4
  %249 = load float, float* %240, align 4
  %250 = fmul float 2.000000e+00, %249
  %251 = getelementptr inbounds float, float* %150, i64 1
  %252 = load float, float* %251, align 4
  %253 = fmul float %250, %252
  %254 = fpext float %253 to double
  %255 = fsub double 0.000000e+00, %254
  %256 = fptrunc double %255 to float
  %257 = getelementptr inbounds float, float* %169, i64 9
  store float %256, float* %257, align 4
  %258 = load float, float* %240, align 4
  %259 = fmul float 2.000000e+00, %258
  %260 = getelementptr inbounds float, float* %150, i64 2
  %261 = load float, float* %260, align 4
  %262 = fmul float %259, %261
  %263 = fpext float %262 to double
  %264 = fsub double 1.000000e+00, %263
  %265 = fptrunc double %264 to float
  %266 = getelementptr inbounds float, float* %169, i64 10
  store float %265, float* %266, align 4
  %267 = load float, float* %240, align 4
  %268 = fmul float 2.000000e+00, %267
  %269 = getelementptr inbounds float, float* %150, i64 3
  %270 = load float, float* %269, align 4
  %271 = fmul float %268, %270
  %272 = fpext float %271 to double
  %273 = fsub double 0.000000e+00, %272
  %274 = fptrunc double %273 to float
  %275 = getelementptr inbounds float, float* %169, i64 11
  store float %274, float* %275, align 4
  %276 = getelementptr inbounds float, float* %150, i64 3
  %277 = load float, float* %276, align 4
  %278 = fmul float 2.000000e+00, %277
  %279 = load float, float* %150, align 4
  %280 = fmul float %278, %279
  %281 = fpext float %280 to double
  %282 = fsub double 0.000000e+00, %281
  %283 = fptrunc double %282 to float
  %284 = getelementptr inbounds float, float* %169, i64 12
  store float %283, float* %284, align 4
  %285 = load float, float* %276, align 4
  %286 = fmul float 2.000000e+00, %285
  %287 = getelementptr inbounds float, float* %150, i64 1
  %288 = load float, float* %287, align 4
  %289 = fmul float %286, %288
  %290 = fpext float %289 to double
  %291 = fsub double 0.000000e+00, %290
  %292 = fptrunc double %291 to float
  %293 = getelementptr inbounds float, float* %169, i64 13
  store float %292, float* %293, align 4
  %294 = load float, float* %276, align 4
  %295 = fmul float 2.000000e+00, %294
  %296 = getelementptr inbounds float, float* %150, i64 2
  %297 = load float, float* %296, align 4
  %298 = fmul float %295, %297
  %299 = fpext float %298 to double
  %300 = fsub double 0.000000e+00, %299
  %301 = fptrunc double %300 to float
  %302 = getelementptr inbounds float, float* %169, i64 14
  store float %301, float* %302, align 4
  %303 = load float, float* %276, align 4
  %304 = fmul float 2.000000e+00, %303
  %305 = getelementptr inbounds float, float* %150, i64 3
  %306 = load float, float* %305, align 4
  %307 = fmul float %304, %306
  %308 = fpext float %307 to double
  %309 = fsub double 1.000000e+00, %308
  %310 = fptrunc double %309 to float
  %311 = getelementptr inbounds float, float* %169, i64 15
  store float %310, float* %311, align 4
  %312 = call i8* @calloc(i64 4, i64 16) #9
  %313 = bitcast i8* %312 to float*
  %314 = getelementptr inbounds float, float* %169, i64 0
  %315 = load float, float* %314, align 4
  store float %315, float* %313, align 4
  %316 = getelementptr inbounds float, float* %169, i64 1
  %317 = load float, float* %316, align 4
  %318 = getelementptr inbounds float, float* %313, i64 1
  store float %317, float* %318, align 4
  %319 = getelementptr inbounds float, float* %169, i64 2
  %320 = load float, float* %319, align 4
  %321 = getelementptr inbounds float, float* %313, i64 2
  store float %320, float* %321, align 4
  %322 = getelementptr inbounds float, float* %169, i64 3
  %323 = load float, float* %322, align 4
  %324 = getelementptr inbounds float, float* %313, i64 3
  store float %323, float* %324, align 4
  %325 = getelementptr inbounds float, float* %169, i64 4
  %326 = load float, float* %325, align 4
  %327 = getelementptr inbounds float, float* %313, i64 4
  store float %326, float* %327, align 4
  %328 = getelementptr inbounds float, float* %169, i64 5
  %329 = load float, float* %328, align 4
  %330 = getelementptr inbounds float, float* %313, i64 5
  store float %329, float* %330, align 4
  %331 = getelementptr inbounds float, float* %169, i64 6
  %332 = load float, float* %331, align 4
  %333 = getelementptr inbounds float, float* %313, i64 6
  store float %332, float* %333, align 4
  %334 = getelementptr inbounds float, float* %169, i64 7
  %335 = load float, float* %334, align 4
  %336 = getelementptr inbounds float, float* %313, i64 7
  store float %335, float* %336, align 4
  %337 = getelementptr inbounds float, float* %169, i64 8
  %338 = load float, float* %337, align 4
  %339 = getelementptr inbounds float, float* %313, i64 8
  store float %338, float* %339, align 4
  %340 = getelementptr inbounds float, float* %169, i64 9
  %341 = load float, float* %340, align 4
  %342 = getelementptr inbounds float, float* %313, i64 9
  store float %341, float* %342, align 4
  %343 = getelementptr inbounds float, float* %169, i64 10
  %344 = load float, float* %343, align 4
  %345 = getelementptr inbounds float, float* %313, i64 10
  store float %344, float* %345, align 4
  %346 = getelementptr inbounds float, float* %169, i64 11
  %347 = load float, float* %346, align 4
  %348 = getelementptr inbounds float, float* %313, i64 11
  store float %347, float* %348, align 4
  %349 = getelementptr inbounds float, float* %169, i64 12
  %350 = load float, float* %349, align 4
  %351 = getelementptr inbounds float, float* %313, i64 12
  store float %350, float* %351, align 4
  %352 = getelementptr inbounds float, float* %169, i64 13
  %353 = load float, float* %352, align 4
  %354 = getelementptr inbounds float, float* %313, i64 13
  store float %353, float* %354, align 4
  %355 = getelementptr inbounds float, float* %169, i64 14
  %356 = load float, float* %355, align 4
  %357 = getelementptr inbounds float, float* %313, i64 14
  store float %356, float* %357, align 4
  %358 = getelementptr inbounds float, float* %169, i64 15
  %359 = load float, float* %358, align 4
  %360 = getelementptr inbounds float, float* %313, i64 15
  store float %359, float* %360, align 4
  %361 = call i8* @__memcpy_chk(i8* %31, i8* %312, i64 64, i64 %33) #8
  store float 0.000000e+00, float* %2, align 4
  %362 = load float, float* %313, align 4
  %363 = load float, float* %0, align 4
  %364 = fmul float %362, %363
  %365 = load float, float* %2, align 4
  %366 = fadd float %365, %364
  store float %366, float* %2, align 4
  %367 = getelementptr inbounds float, float* %313, i64 1
  %368 = load float, float* %367, align 4
  %369 = getelementptr inbounds float, float* %0, i64 4
  %370 = load float, float* %369, align 4
  %371 = fmul float %368, %370
  %372 = load float, float* %2, align 4
  %373 = fadd float %372, %371
  store float %373, float* %2, align 4
  %374 = getelementptr inbounds float, float* %313, i64 2
  %375 = load float, float* %374, align 4
  %376 = getelementptr inbounds float, float* %0, i64 8
  %377 = load float, float* %376, align 4
  %378 = fmul float %375, %377
  %379 = load float, float* %2, align 4
  %380 = fadd float %379, %378
  store float %380, float* %2, align 4
  %381 = getelementptr inbounds float, float* %313, i64 3
  %382 = load float, float* %381, align 4
  %383 = getelementptr inbounds float, float* %0, i64 12
  %384 = load float, float* %383, align 4
  %385 = fmul float %382, %384
  %386 = load float, float* %2, align 4
  %387 = fadd float %386, %385
  store float %387, float* %2, align 4
  %388 = getelementptr inbounds float, float* %2, i64 1
  store float 0.000000e+00, float* %388, align 4
  %389 = getelementptr inbounds float, float* %2, i64 1
  %390 = load float, float* %313, align 4
  %391 = getelementptr inbounds float, float* %0, i64 1
  %392 = load float, float* %391, align 4
  %393 = fmul float %390, %392
  %394 = load float, float* %389, align 4
  %395 = fadd float %394, %393
  store float %395, float* %389, align 4
  %396 = getelementptr inbounds float, float* %313, i64 1
  %397 = load float, float* %396, align 4
  %398 = getelementptr inbounds float, float* %0, i64 5
  %399 = load float, float* %398, align 4
  %400 = fmul float %397, %399
  %401 = load float, float* %389, align 4
  %402 = fadd float %401, %400
  store float %402, float* %389, align 4
  %403 = getelementptr inbounds float, float* %313, i64 2
  %404 = load float, float* %403, align 4
  %405 = getelementptr inbounds float, float* %0, i64 9
  %406 = load float, float* %405, align 4
  %407 = fmul float %404, %406
  %408 = load float, float* %389, align 4
  %409 = fadd float %408, %407
  store float %409, float* %389, align 4
  %410 = getelementptr inbounds float, float* %313, i64 3
  %411 = load float, float* %410, align 4
  %412 = getelementptr inbounds float, float* %0, i64 13
  %413 = load float, float* %412, align 4
  %414 = fmul float %411, %413
  %415 = load float, float* %389, align 4
  %416 = fadd float %415, %414
  store float %416, float* %389, align 4
  %417 = getelementptr inbounds float, float* %2, i64 2
  store float 0.000000e+00, float* %417, align 4
  %418 = getelementptr inbounds float, float* %2, i64 2
  %419 = load float, float* %313, align 4
  %420 = getelementptr inbounds float, float* %0, i64 2
  %421 = load float, float* %420, align 4
  %422 = fmul float %419, %421
  %423 = load float, float* %418, align 4
  %424 = fadd float %423, %422
  store float %424, float* %418, align 4
  %425 = getelementptr inbounds float, float* %313, i64 1
  %426 = load float, float* %425, align 4
  %427 = getelementptr inbounds float, float* %0, i64 6
  %428 = load float, float* %427, align 4
  %429 = fmul float %426, %428
  %430 = load float, float* %418, align 4
  %431 = fadd float %430, %429
  store float %431, float* %418, align 4
  %432 = getelementptr inbounds float, float* %313, i64 2
  %433 = load float, float* %432, align 4
  %434 = getelementptr inbounds float, float* %0, i64 10
  %435 = load float, float* %434, align 4
  %436 = fmul float %433, %435
  %437 = load float, float* %418, align 4
  %438 = fadd float %437, %436
  store float %438, float* %418, align 4
  %439 = getelementptr inbounds float, float* %313, i64 3
  %440 = load float, float* %439, align 4
  %441 = getelementptr inbounds float, float* %0, i64 14
  %442 = load float, float* %441, align 4
  %443 = fmul float %440, %442
  %444 = load float, float* %418, align 4
  %445 = fadd float %444, %443
  store float %445, float* %418, align 4
  %446 = getelementptr inbounds float, float* %2, i64 3
  store float 0.000000e+00, float* %446, align 4
  %447 = getelementptr inbounds float, float* %2, i64 3
  %448 = load float, float* %313, align 4
  %449 = getelementptr inbounds float, float* %0, i64 3
  %450 = load float, float* %449, align 4
  %451 = fmul float %448, %450
  %452 = load float, float* %447, align 4
  %453 = fadd float %452, %451
  store float %453, float* %447, align 4
  %454 = getelementptr inbounds float, float* %313, i64 1
  %455 = load float, float* %454, align 4
  %456 = getelementptr inbounds float, float* %0, i64 7
  %457 = load float, float* %456, align 4
  %458 = fmul float %455, %457
  %459 = load float, float* %447, align 4
  %460 = fadd float %459, %458
  store float %460, float* %447, align 4
  %461 = getelementptr inbounds float, float* %313, i64 2
  %462 = load float, float* %461, align 4
  %463 = getelementptr inbounds float, float* %0, i64 11
  %464 = load float, float* %463, align 4
  %465 = fmul float %462, %464
  %466 = load float, float* %447, align 4
  %467 = fadd float %466, %465
  store float %467, float* %447, align 4
  %468 = getelementptr inbounds float, float* %313, i64 3
  %469 = load float, float* %468, align 4
  %470 = getelementptr inbounds float, float* %0, i64 15
  %471 = load float, float* %470, align 4
  %472 = fmul float %469, %471
  %473 = load float, float* %447, align 4
  %474 = fadd float %473, %472
  store float %474, float* %447, align 4
  %475 = getelementptr inbounds float, float* %313, i64 4
  %476 = getelementptr inbounds float, float* %2, i64 4
  store float 0.000000e+00, float* %476, align 4
  %477 = getelementptr inbounds float, float* %2, i64 4
  %478 = load float, float* %475, align 4
  %479 = load float, float* %0, align 4
  %480 = fmul float %478, %479
  %481 = load float, float* %477, align 4
  %482 = fadd float %481, %480
  store float %482, float* %477, align 4
  %483 = getelementptr inbounds float, float* %313, i64 5
  %484 = load float, float* %483, align 4
  %485 = getelementptr inbounds float, float* %0, i64 4
  %486 = load float, float* %485, align 4
  %487 = fmul float %484, %486
  %488 = load float, float* %477, align 4
  %489 = fadd float %488, %487
  store float %489, float* %477, align 4
  %490 = getelementptr inbounds float, float* %313, i64 6
  %491 = load float, float* %490, align 4
  %492 = getelementptr inbounds float, float* %0, i64 8
  %493 = load float, float* %492, align 4
  %494 = fmul float %491, %493
  %495 = load float, float* %477, align 4
  %496 = fadd float %495, %494
  store float %496, float* %477, align 4
  %497 = getelementptr inbounds float, float* %313, i64 7
  %498 = load float, float* %497, align 4
  %499 = getelementptr inbounds float, float* %0, i64 12
  %500 = load float, float* %499, align 4
  %501 = fmul float %498, %500
  %502 = load float, float* %477, align 4
  %503 = fadd float %502, %501
  store float %503, float* %477, align 4
  %504 = getelementptr inbounds float, float* %2, i64 5
  store float 0.000000e+00, float* %504, align 4
  %505 = getelementptr inbounds float, float* %2, i64 5
  %506 = load float, float* %475, align 4
  %507 = getelementptr inbounds float, float* %0, i64 1
  %508 = load float, float* %507, align 4
  %509 = fmul float %506, %508
  %510 = load float, float* %505, align 4
  %511 = fadd float %510, %509
  store float %511, float* %505, align 4
  %512 = getelementptr inbounds float, float* %313, i64 5
  %513 = load float, float* %512, align 4
  %514 = getelementptr inbounds float, float* %0, i64 5
  %515 = load float, float* %514, align 4
  %516 = fmul float %513, %515
  %517 = load float, float* %505, align 4
  %518 = fadd float %517, %516
  store float %518, float* %505, align 4
  %519 = getelementptr inbounds float, float* %313, i64 6
  %520 = load float, float* %519, align 4
  %521 = getelementptr inbounds float, float* %0, i64 9
  %522 = load float, float* %521, align 4
  %523 = fmul float %520, %522
  %524 = load float, float* %505, align 4
  %525 = fadd float %524, %523
  store float %525, float* %505, align 4
  %526 = getelementptr inbounds float, float* %313, i64 7
  %527 = load float, float* %526, align 4
  %528 = getelementptr inbounds float, float* %0, i64 13
  %529 = load float, float* %528, align 4
  %530 = fmul float %527, %529
  %531 = load float, float* %505, align 4
  %532 = fadd float %531, %530
  store float %532, float* %505, align 4
  %533 = getelementptr inbounds float, float* %2, i64 6
  store float 0.000000e+00, float* %533, align 4
  %534 = getelementptr inbounds float, float* %2, i64 6
  %535 = load float, float* %475, align 4
  %536 = getelementptr inbounds float, float* %0, i64 2
  %537 = load float, float* %536, align 4
  %538 = fmul float %535, %537
  %539 = load float, float* %534, align 4
  %540 = fadd float %539, %538
  store float %540, float* %534, align 4
  %541 = getelementptr inbounds float, float* %313, i64 5
  %542 = load float, float* %541, align 4
  %543 = getelementptr inbounds float, float* %0, i64 6
  %544 = load float, float* %543, align 4
  %545 = fmul float %542, %544
  %546 = load float, float* %534, align 4
  %547 = fadd float %546, %545
  store float %547, float* %534, align 4
  %548 = getelementptr inbounds float, float* %313, i64 6
  %549 = load float, float* %548, align 4
  %550 = getelementptr inbounds float, float* %0, i64 10
  %551 = load float, float* %550, align 4
  %552 = fmul float %549, %551
  %553 = load float, float* %534, align 4
  %554 = fadd float %553, %552
  store float %554, float* %534, align 4
  %555 = getelementptr inbounds float, float* %313, i64 7
  %556 = load float, float* %555, align 4
  %557 = getelementptr inbounds float, float* %0, i64 14
  %558 = load float, float* %557, align 4
  %559 = fmul float %556, %558
  %560 = load float, float* %534, align 4
  %561 = fadd float %560, %559
  store float %561, float* %534, align 4
  %562 = getelementptr inbounds float, float* %2, i64 7
  store float 0.000000e+00, float* %562, align 4
  %563 = getelementptr inbounds float, float* %2, i64 7
  %564 = load float, float* %475, align 4
  %565 = getelementptr inbounds float, float* %0, i64 3
  %566 = load float, float* %565, align 4
  %567 = fmul float %564, %566
  %568 = load float, float* %563, align 4
  %569 = fadd float %568, %567
  store float %569, float* %563, align 4
  %570 = getelementptr inbounds float, float* %313, i64 5
  %571 = load float, float* %570, align 4
  %572 = getelementptr inbounds float, float* %0, i64 7
  %573 = load float, float* %572, align 4
  %574 = fmul float %571, %573
  %575 = load float, float* %563, align 4
  %576 = fadd float %575, %574
  store float %576, float* %563, align 4
  %577 = getelementptr inbounds float, float* %313, i64 6
  %578 = load float, float* %577, align 4
  %579 = getelementptr inbounds float, float* %0, i64 11
  %580 = load float, float* %579, align 4
  %581 = fmul float %578, %580
  %582 = load float, float* %563, align 4
  %583 = fadd float %582, %581
  store float %583, float* %563, align 4
  %584 = getelementptr inbounds float, float* %313, i64 7
  %585 = load float, float* %584, align 4
  %586 = getelementptr inbounds float, float* %0, i64 15
  %587 = load float, float* %586, align 4
  %588 = fmul float %585, %587
  %589 = load float, float* %563, align 4
  %590 = fadd float %589, %588
  store float %590, float* %563, align 4
  %591 = getelementptr inbounds float, float* %313, i64 8
  %592 = getelementptr inbounds float, float* %2, i64 8
  store float 0.000000e+00, float* %592, align 4
  %593 = getelementptr inbounds float, float* %2, i64 8
  %594 = load float, float* %591, align 4
  %595 = load float, float* %0, align 4
  %596 = fmul float %594, %595
  %597 = load float, float* %593, align 4
  %598 = fadd float %597, %596
  store float %598, float* %593, align 4
  %599 = getelementptr inbounds float, float* %313, i64 9
  %600 = load float, float* %599, align 4
  %601 = getelementptr inbounds float, float* %0, i64 4
  %602 = load float, float* %601, align 4
  %603 = fmul float %600, %602
  %604 = load float, float* %593, align 4
  %605 = fadd float %604, %603
  store float %605, float* %593, align 4
  %606 = getelementptr inbounds float, float* %313, i64 10
  %607 = load float, float* %606, align 4
  %608 = getelementptr inbounds float, float* %0, i64 8
  %609 = load float, float* %608, align 4
  %610 = fmul float %607, %609
  %611 = load float, float* %593, align 4
  %612 = fadd float %611, %610
  store float %612, float* %593, align 4
  %613 = getelementptr inbounds float, float* %313, i64 11
  %614 = load float, float* %613, align 4
  %615 = getelementptr inbounds float, float* %0, i64 12
  %616 = load float, float* %615, align 4
  %617 = fmul float %614, %616
  %618 = load float, float* %593, align 4
  %619 = fadd float %618, %617
  store float %619, float* %593, align 4
  %620 = getelementptr inbounds float, float* %2, i64 9
  store float 0.000000e+00, float* %620, align 4
  %621 = getelementptr inbounds float, float* %2, i64 9
  %622 = load float, float* %591, align 4
  %623 = getelementptr inbounds float, float* %0, i64 1
  %624 = load float, float* %623, align 4
  %625 = fmul float %622, %624
  %626 = load float, float* %621, align 4
  %627 = fadd float %626, %625
  store float %627, float* %621, align 4
  %628 = getelementptr inbounds float, float* %313, i64 9
  %629 = load float, float* %628, align 4
  %630 = getelementptr inbounds float, float* %0, i64 5
  %631 = load float, float* %630, align 4
  %632 = fmul float %629, %631
  %633 = load float, float* %621, align 4
  %634 = fadd float %633, %632
  store float %634, float* %621, align 4
  %635 = getelementptr inbounds float, float* %313, i64 10
  %636 = load float, float* %635, align 4
  %637 = getelementptr inbounds float, float* %0, i64 9
  %638 = load float, float* %637, align 4
  %639 = fmul float %636, %638
  %640 = load float, float* %621, align 4
  %641 = fadd float %640, %639
  store float %641, float* %621, align 4
  %642 = getelementptr inbounds float, float* %313, i64 11
  %643 = load float, float* %642, align 4
  %644 = getelementptr inbounds float, float* %0, i64 13
  %645 = load float, float* %644, align 4
  %646 = fmul float %643, %645
  %647 = load float, float* %621, align 4
  %648 = fadd float %647, %646
  store float %648, float* %621, align 4
  %649 = getelementptr inbounds float, float* %2, i64 10
  store float 0.000000e+00, float* %649, align 4
  %650 = getelementptr inbounds float, float* %2, i64 10
  %651 = load float, float* %591, align 4
  %652 = getelementptr inbounds float, float* %0, i64 2
  %653 = load float, float* %652, align 4
  %654 = fmul float %651, %653
  %655 = load float, float* %650, align 4
  %656 = fadd float %655, %654
  store float %656, float* %650, align 4
  %657 = getelementptr inbounds float, float* %313, i64 9
  %658 = load float, float* %657, align 4
  %659 = getelementptr inbounds float, float* %0, i64 6
  %660 = load float, float* %659, align 4
  %661 = fmul float %658, %660
  %662 = load float, float* %650, align 4
  %663 = fadd float %662, %661
  store float %663, float* %650, align 4
  %664 = getelementptr inbounds float, float* %313, i64 10
  %665 = load float, float* %664, align 4
  %666 = getelementptr inbounds float, float* %0, i64 10
  %667 = load float, float* %666, align 4
  %668 = fmul float %665, %667
  %669 = load float, float* %650, align 4
  %670 = fadd float %669, %668
  store float %670, float* %650, align 4
  %671 = getelementptr inbounds float, float* %313, i64 11
  %672 = load float, float* %671, align 4
  %673 = getelementptr inbounds float, float* %0, i64 14
  %674 = load float, float* %673, align 4
  %675 = fmul float %672, %674
  %676 = load float, float* %650, align 4
  %677 = fadd float %676, %675
  store float %677, float* %650, align 4
  %678 = getelementptr inbounds float, float* %2, i64 11
  store float 0.000000e+00, float* %678, align 4
  %679 = getelementptr inbounds float, float* %2, i64 11
  %680 = load float, float* %591, align 4
  %681 = getelementptr inbounds float, float* %0, i64 3
  %682 = load float, float* %681, align 4
  %683 = fmul float %680, %682
  %684 = load float, float* %679, align 4
  %685 = fadd float %684, %683
  store float %685, float* %679, align 4
  %686 = getelementptr inbounds float, float* %313, i64 9
  %687 = load float, float* %686, align 4
  %688 = getelementptr inbounds float, float* %0, i64 7
  %689 = load float, float* %688, align 4
  %690 = fmul float %687, %689
  %691 = load float, float* %679, align 4
  %692 = fadd float %691, %690
  store float %692, float* %679, align 4
  %693 = getelementptr inbounds float, float* %313, i64 10
  %694 = load float, float* %693, align 4
  %695 = getelementptr inbounds float, float* %0, i64 11
  %696 = load float, float* %695, align 4
  %697 = fmul float %694, %696
  %698 = load float, float* %679, align 4
  %699 = fadd float %698, %697
  store float %699, float* %679, align 4
  %700 = getelementptr inbounds float, float* %313, i64 11
  %701 = load float, float* %700, align 4
  %702 = getelementptr inbounds float, float* %0, i64 15
  %703 = load float, float* %702, align 4
  %704 = fmul float %701, %703
  %705 = load float, float* %679, align 4
  %706 = fadd float %705, %704
  store float %706, float* %679, align 4
  %707 = getelementptr inbounds float, float* %313, i64 12
  %708 = getelementptr inbounds float, float* %2, i64 12
  store float 0.000000e+00, float* %708, align 4
  %709 = getelementptr inbounds float, float* %2, i64 12
  %710 = load float, float* %707, align 4
  %711 = load float, float* %0, align 4
  %712 = fmul float %710, %711
  %713 = load float, float* %709, align 4
  %714 = fadd float %713, %712
  store float %714, float* %709, align 4
  %715 = getelementptr inbounds float, float* %313, i64 13
  %716 = load float, float* %715, align 4
  %717 = getelementptr inbounds float, float* %0, i64 4
  %718 = load float, float* %717, align 4
  %719 = fmul float %716, %718
  %720 = load float, float* %709, align 4
  %721 = fadd float %720, %719
  store float %721, float* %709, align 4
  %722 = getelementptr inbounds float, float* %313, i64 14
  %723 = load float, float* %722, align 4
  %724 = getelementptr inbounds float, float* %0, i64 8
  %725 = load float, float* %724, align 4
  %726 = fmul float %723, %725
  %727 = load float, float* %709, align 4
  %728 = fadd float %727, %726
  store float %728, float* %709, align 4
  %729 = getelementptr inbounds float, float* %313, i64 15
  %730 = load float, float* %729, align 4
  %731 = getelementptr inbounds float, float* %0, i64 12
  %732 = load float, float* %731, align 4
  %733 = fmul float %730, %732
  %734 = load float, float* %709, align 4
  %735 = fadd float %734, %733
  store float %735, float* %709, align 4
  %736 = getelementptr inbounds float, float* %2, i64 13
  store float 0.000000e+00, float* %736, align 4
  %737 = getelementptr inbounds float, float* %2, i64 13
  %738 = load float, float* %707, align 4
  %739 = getelementptr inbounds float, float* %0, i64 1
  %740 = load float, float* %739, align 4
  %741 = fmul float %738, %740
  %742 = load float, float* %737, align 4
  %743 = fadd float %742, %741
  store float %743, float* %737, align 4
  %744 = getelementptr inbounds float, float* %313, i64 13
  %745 = load float, float* %744, align 4
  %746 = getelementptr inbounds float, float* %0, i64 5
  %747 = load float, float* %746, align 4
  %748 = fmul float %745, %747
  %749 = load float, float* %737, align 4
  %750 = fadd float %749, %748
  store float %750, float* %737, align 4
  %751 = getelementptr inbounds float, float* %313, i64 14
  %752 = load float, float* %751, align 4
  %753 = getelementptr inbounds float, float* %0, i64 9
  %754 = load float, float* %753, align 4
  %755 = fmul float %752, %754
  %756 = load float, float* %737, align 4
  %757 = fadd float %756, %755
  store float %757, float* %737, align 4
  %758 = getelementptr inbounds float, float* %313, i64 15
  %759 = load float, float* %758, align 4
  %760 = getelementptr inbounds float, float* %0, i64 13
  %761 = load float, float* %760, align 4
  %762 = fmul float %759, %761
  %763 = load float, float* %737, align 4
  %764 = fadd float %763, %762
  store float %764, float* %737, align 4
  %765 = getelementptr inbounds float, float* %2, i64 14
  store float 0.000000e+00, float* %765, align 4
  %766 = getelementptr inbounds float, float* %2, i64 14
  %767 = load float, float* %707, align 4
  %768 = getelementptr inbounds float, float* %0, i64 2
  %769 = load float, float* %768, align 4
  %770 = fmul float %767, %769
  %771 = load float, float* %766, align 4
  %772 = fadd float %771, %770
  store float %772, float* %766, align 4
  %773 = getelementptr inbounds float, float* %313, i64 13
  %774 = load float, float* %773, align 4
  %775 = getelementptr inbounds float, float* %0, i64 6
  %776 = load float, float* %775, align 4
  %777 = fmul float %774, %776
  %778 = load float, float* %766, align 4
  %779 = fadd float %778, %777
  store float %779, float* %766, align 4
  %780 = getelementptr inbounds float, float* %313, i64 14
  %781 = load float, float* %780, align 4
  %782 = getelementptr inbounds float, float* %0, i64 10
  %783 = load float, float* %782, align 4
  %784 = fmul float %781, %783
  %785 = load float, float* %766, align 4
  %786 = fadd float %785, %784
  store float %786, float* %766, align 4
  %787 = getelementptr inbounds float, float* %313, i64 15
  %788 = load float, float* %787, align 4
  %789 = getelementptr inbounds float, float* %0, i64 14
  %790 = load float, float* %789, align 4
  %791 = fmul float %788, %790
  %792 = load float, float* %766, align 4
  %793 = fadd float %792, %791
  store float %793, float* %766, align 4
  %794 = getelementptr inbounds float, float* %2, i64 15
  store float 0.000000e+00, float* %794, align 4
  %795 = getelementptr inbounds float, float* %2, i64 15
  %796 = load float, float* %707, align 4
  %797 = getelementptr inbounds float, float* %0, i64 3
  %798 = load float, float* %797, align 4
  %799 = fmul float %796, %798
  %800 = load float, float* %795, align 4
  %801 = fadd float %800, %799
  store float %801, float* %795, align 4
  %802 = getelementptr inbounds float, float* %313, i64 13
  %803 = load float, float* %802, align 4
  %804 = getelementptr inbounds float, float* %0, i64 7
  %805 = load float, float* %804, align 4
  %806 = fmul float %803, %805
  %807 = load float, float* %795, align 4
  %808 = fadd float %807, %806
  store float %808, float* %795, align 4
  %809 = getelementptr inbounds float, float* %313, i64 14
  %810 = load float, float* %809, align 4
  %811 = getelementptr inbounds float, float* %0, i64 11
  %812 = load float, float* %811, align 4
  %813 = fmul float %810, %812
  %814 = load float, float* %795, align 4
  %815 = fadd float %814, %813
  store float %815, float* %795, align 4
  %816 = getelementptr inbounds float, float* %313, i64 15
  %817 = load float, float* %816, align 4
  %818 = getelementptr inbounds float, float* %0, i64 15
  %819 = load float, float* %818, align 4
  %820 = fmul float %817, %819
  %821 = load float, float* %795, align 4
  %822 = fadd float %821, %820
  store float %822, float* %795, align 4
  call void @free(i8* %34)
  call void @free(i8* %36)
  call void @free(i8* %96)
  call void @free(i8* %98)
  call void @free(i8* %168)
  call void @free(i8* %312)
  %823 = call i8* @calloc(i64 4, i64 3) #9
  %824 = bitcast i8* %823 to float*
  %825 = call i8* @calloc(i64 4, i64 3) #9
  %826 = bitcast i8* %825 to float*
  %827 = getelementptr inbounds float, float* %2, i64 5
  %828 = load float, float* %827, align 4
  store float %828, float* %824, align 4
  %829 = getelementptr inbounds float, float* %9, i64 5
  %830 = load float, float* %829, align 4
  store float %830, float* %826, align 4
  %831 = getelementptr inbounds float, float* %2, i64 9
  %832 = load float, float* %831, align 4
  %833 = getelementptr inbounds float, float* %824, i64 1
  store float %832, float* %833, align 4
  %834 = getelementptr inbounds float, float* %9, i64 9
  %835 = load float, float* %834, align 4
  %836 = getelementptr inbounds float, float* %826, i64 1
  store float %835, float* %836, align 4
  %837 = getelementptr inbounds float, float* %2, i64 13
  %838 = load float, float* %837, align 4
  %839 = getelementptr inbounds float, float* %824, i64 2
  store float %838, float* %839, align 4
  %840 = getelementptr inbounds float, float* %9, i64 13
  %841 = load float, float* %840, align 4
  %842 = getelementptr inbounds float, float* %826, i64 2
  store float %841, float* %842, align 4
  %843 = load float, float* %824, align 4
  %844 = fcmp ogt float %843, 0.000000e+00
  %845 = zext i1 %844 to i32
  %846 = fcmp olt float %843, 0.000000e+00
  %847 = zext i1 %846 to i32
  %848 = sub nsw i32 %845, %847
  %849 = sitofp i32 %848 to float
  %850 = load float, float* %824, align 4
  %851 = fpext float %850 to double
  %852 = call double @llvm.pow.f64(double %851, double 2.000000e+00) #8
  %853 = fadd double 0.000000e+00, %852
  %854 = fptrunc double %853 to float
  %855 = getelementptr inbounds float, float* %824, i64 1
  %856 = load float, float* %855, align 4
  %857 = fpext float %856 to double
  %858 = call double @llvm.pow.f64(double %857, double 2.000000e+00) #8
  %859 = fpext float %854 to double
  %860 = fadd double %859, %858
  %861 = fptrunc double %860 to float
  %862 = getelementptr inbounds float, float* %824, i64 2
  %863 = load float, float* %862, align 4
  %864 = fpext float %863 to double
  %865 = call double @llvm.pow.f64(double %864, double 2.000000e+00) #8
  %866 = fpext float %861 to double
  %867 = fadd double %866, %865
  %868 = fptrunc double %867 to float
  %869 = fneg float %849
  %870 = fpext float %868 to double
  %871 = call double @llvm.sqrt.f64(double %870) #8
  %872 = fptrunc double %871 to float
  %873 = fmul float %869, %872
  %874 = call i8* @calloc(i64 4, i64 3) #9
  %875 = bitcast i8* %874 to float*
  %876 = call i8* @calloc(i64 4, i64 3) #9
  %877 = load float, float* %824, align 4
  %878 = load float, float* %826, align 4
  %879 = fmul float %873, %878
  %880 = fadd float %877, %879
  store float %880, float* %875, align 4
  %881 = getelementptr inbounds float, float* %824, i64 1
  %882 = load float, float* %881, align 4
  %883 = getelementptr inbounds float, float* %826, i64 1
  %884 = load float, float* %883, align 4
  %885 = fmul float %873, %884
  %886 = fadd float %882, %885
  %887 = getelementptr inbounds float, float* %875, i64 1
  store float %886, float* %887, align 4
  %888 = getelementptr inbounds float, float* %824, i64 2
  %889 = load float, float* %888, align 4
  %890 = getelementptr inbounds float, float* %826, i64 2
  %891 = load float, float* %890, align 4
  %892 = fmul float %873, %891
  %893 = fadd float %889, %892
  %894 = getelementptr inbounds float, float* %875, i64 2
  store float %893, float* %894, align 4
  %895 = load float, float* %875, align 4
  %896 = fpext float %895 to double
  %897 = call double @llvm.pow.f64(double %896, double 2.000000e+00) #8
  %898 = fadd double 0.000000e+00, %897
  %899 = fptrunc double %898 to float
  %900 = getelementptr inbounds float, float* %875, i64 1
  %901 = load float, float* %900, align 4
  %902 = fpext float %901 to double
  %903 = call double @llvm.pow.f64(double %902, double 2.000000e+00) #8
  %904 = fpext float %899 to double
  %905 = fadd double %904, %903
  %906 = fptrunc double %905 to float
  %907 = getelementptr inbounds float, float* %875, i64 2
  %908 = load float, float* %907, align 4
  %909 = fpext float %908 to double
  %910 = call double @llvm.pow.f64(double %909, double 2.000000e+00) #8
  %911 = fpext float %906 to double
  %912 = fadd double %911, %910
  %913 = fptrunc double %912 to float
  %914 = bitcast i8* %876 to float*
  %915 = fpext float %913 to double
  %916 = call double @llvm.sqrt.f64(double %915) #8
  %917 = fptrunc double %916 to float
  %918 = load float, float* %875, align 4
  %919 = fdiv float %918, %917
  store float %919, float* %914, align 4
  %920 = getelementptr inbounds float, float* %875, i64 1
  %921 = load float, float* %920, align 4
  %922 = fdiv float %921, %917
  %923 = getelementptr inbounds float, float* %914, i64 1
  store float %922, float* %923, align 4
  %924 = getelementptr inbounds float, float* %875, i64 2
  %925 = load float, float* %924, align 4
  %926 = fdiv float %925, %917
  %927 = getelementptr inbounds float, float* %914, i64 2
  store float %926, float* %927, align 4
  %928 = call i8* @calloc(i64 4, i64 9) #9
  %929 = bitcast i8* %928 to float*
  %930 = load float, float* %914, align 4
  %931 = fmul float 2.000000e+00, %930
  %932 = load float, float* %914, align 4
  %933 = fmul float %931, %932
  %934 = fpext float %933 to double
  %935 = fsub double 1.000000e+00, %934
  %936 = fptrunc double %935 to float
  store float %936, float* %929, align 4
  %937 = load float, float* %914, align 4
  %938 = fmul float 2.000000e+00, %937
  %939 = getelementptr inbounds float, float* %914, i64 1
  %940 = load float, float* %939, align 4
  %941 = fmul float %938, %940
  %942 = fpext float %941 to double
  %943 = fsub double 0.000000e+00, %942
  %944 = fptrunc double %943 to float
  %945 = getelementptr inbounds float, float* %929, i64 1
  store float %944, float* %945, align 4
  %946 = load float, float* %914, align 4
  %947 = fmul float 2.000000e+00, %946
  %948 = getelementptr inbounds float, float* %914, i64 2
  %949 = load float, float* %948, align 4
  %950 = fmul float %947, %949
  %951 = fpext float %950 to double
  %952 = fsub double 0.000000e+00, %951
  %953 = fptrunc double %952 to float
  %954 = getelementptr inbounds float, float* %929, i64 2
  store float %953, float* %954, align 4
  %955 = getelementptr inbounds float, float* %914, i64 1
  %956 = load float, float* %955, align 4
  %957 = fmul float 2.000000e+00, %956
  %958 = load float, float* %914, align 4
  %959 = fmul float %957, %958
  %960 = fpext float %959 to double
  %961 = fsub double 0.000000e+00, %960
  %962 = fptrunc double %961 to float
  %963 = getelementptr inbounds float, float* %929, i64 3
  store float %962, float* %963, align 4
  %964 = load float, float* %955, align 4
  %965 = fmul float 2.000000e+00, %964
  %966 = getelementptr inbounds float, float* %914, i64 1
  %967 = load float, float* %966, align 4
  %968 = fmul float %965, %967
  %969 = fpext float %968 to double
  %970 = fsub double 1.000000e+00, %969
  %971 = fptrunc double %970 to float
  %972 = getelementptr inbounds float, float* %929, i64 4
  store float %971, float* %972, align 4
  %973 = load float, float* %955, align 4
  %974 = fmul float 2.000000e+00, %973
  %975 = getelementptr inbounds float, float* %914, i64 2
  %976 = load float, float* %975, align 4
  %977 = fmul float %974, %976
  %978 = fpext float %977 to double
  %979 = fsub double 0.000000e+00, %978
  %980 = fptrunc double %979 to float
  %981 = getelementptr inbounds float, float* %929, i64 5
  store float %980, float* %981, align 4
  %982 = getelementptr inbounds float, float* %914, i64 2
  %983 = load float, float* %982, align 4
  %984 = fmul float 2.000000e+00, %983
  %985 = load float, float* %914, align 4
  %986 = fmul float %984, %985
  %987 = fpext float %986 to double
  %988 = fsub double 0.000000e+00, %987
  %989 = fptrunc double %988 to float
  %990 = getelementptr inbounds float, float* %929, i64 6
  store float %989, float* %990, align 4
  %991 = load float, float* %982, align 4
  %992 = fmul float 2.000000e+00, %991
  %993 = getelementptr inbounds float, float* %914, i64 1
  %994 = load float, float* %993, align 4
  %995 = fmul float %992, %994
  %996 = fpext float %995 to double
  %997 = fsub double 0.000000e+00, %996
  %998 = fptrunc double %997 to float
  %999 = getelementptr inbounds float, float* %929, i64 7
  store float %998, float* %999, align 4
  %1000 = load float, float* %982, align 4
  %1001 = fmul float 2.000000e+00, %1000
  %1002 = getelementptr inbounds float, float* %914, i64 2
  %1003 = load float, float* %1002, align 4
  %1004 = fmul float %1001, %1003
  %1005 = fpext float %1004 to double
  %1006 = fsub double 1.000000e+00, %1005
  %1007 = fptrunc double %1006 to float
  %1008 = getelementptr inbounds float, float* %929, i64 8
  store float %1007, float* %1008, align 4
  %1009 = call i8* @calloc(i64 4, i64 16) #9
  %1010 = bitcast i8* %1009 to float*
  store float 1.000000e+00, float* %1010, align 4
  %1011 = getelementptr inbounds float, float* %1010, i64 1
  store float 0.000000e+00, float* %1011, align 4
  %1012 = getelementptr inbounds float, float* %1010, i64 2
  store float 0.000000e+00, float* %1012, align 4
  %1013 = getelementptr inbounds float, float* %1010, i64 3
  store float 0.000000e+00, float* %1013, align 4
  %1014 = getelementptr inbounds float, float* %1010, i64 4
  store float 0.000000e+00, float* %1014, align 4
  %1015 = load float, float* %929, align 4
  %1016 = getelementptr inbounds float, float* %1010, i64 5
  store float %1015, float* %1016, align 4
  %1017 = getelementptr inbounds float, float* %929, i64 1
  %1018 = load float, float* %1017, align 4
  %1019 = getelementptr inbounds float, float* %1010, i64 6
  store float %1018, float* %1019, align 4
  %1020 = getelementptr inbounds float, float* %929, i64 2
  %1021 = load float, float* %1020, align 4
  %1022 = getelementptr inbounds float, float* %1010, i64 7
  store float %1021, float* %1022, align 4
  %1023 = getelementptr inbounds float, float* %1010, i64 8
  store float 0.000000e+00, float* %1023, align 4
  %1024 = getelementptr inbounds float, float* %929, i64 3
  %1025 = load float, float* %1024, align 4
  %1026 = getelementptr inbounds float, float* %1010, i64 9
  store float %1025, float* %1026, align 4
  %1027 = getelementptr inbounds float, float* %929, i64 4
  %1028 = load float, float* %1027, align 4
  %1029 = getelementptr inbounds float, float* %1010, i64 10
  store float %1028, float* %1029, align 4
  %1030 = getelementptr inbounds float, float* %929, i64 5
  %1031 = load float, float* %1030, align 4
  %1032 = getelementptr inbounds float, float* %1010, i64 11
  store float %1031, float* %1032, align 4
  %1033 = getelementptr inbounds float, float* %1010, i64 12
  store float 0.000000e+00, float* %1033, align 4
  %1034 = getelementptr inbounds float, float* %929, i64 6
  %1035 = load float, float* %1034, align 4
  %1036 = getelementptr inbounds float, float* %1010, i64 13
  store float %1035, float* %1036, align 4
  %1037 = getelementptr inbounds float, float* %929, i64 7
  %1038 = load float, float* %1037, align 4
  %1039 = getelementptr inbounds float, float* %1010, i64 14
  store float %1038, float* %1039, align 4
  %1040 = getelementptr inbounds float, float* %929, i64 8
  %1041 = load float, float* %1040, align 4
  %1042 = getelementptr inbounds float, float* %1010, i64 15
  store float %1041, float* %1042, align 4
  %1043 = call i8* @calloc(i64 4, i64 16) #9
  %1044 = bitcast i8* %1043 to float*
  store float 0.000000e+00, float* %1044, align 4
  %1045 = load float, float* %1010, align 4
  %1046 = load float, float* %1, align 4
  %1047 = fmul float %1045, %1046
  %1048 = load float, float* %1044, align 4
  %1049 = fadd float %1048, %1047
  store float %1049, float* %1044, align 4
  %1050 = getelementptr inbounds float, float* %1010, i64 1
  %1051 = load float, float* %1050, align 4
  %1052 = getelementptr inbounds float, float* %1, i64 4
  %1053 = load float, float* %1052, align 4
  %1054 = fmul float %1051, %1053
  %1055 = load float, float* %1044, align 4
  %1056 = fadd float %1055, %1054
  store float %1056, float* %1044, align 4
  %1057 = getelementptr inbounds float, float* %1010, i64 2
  %1058 = load float, float* %1057, align 4
  %1059 = getelementptr inbounds float, float* %1, i64 8
  %1060 = load float, float* %1059, align 4
  %1061 = fmul float %1058, %1060
  %1062 = load float, float* %1044, align 4
  %1063 = fadd float %1062, %1061
  store float %1063, float* %1044, align 4
  %1064 = getelementptr inbounds float, float* %1010, i64 3
  %1065 = load float, float* %1064, align 4
  %1066 = getelementptr inbounds float, float* %1, i64 12
  %1067 = load float, float* %1066, align 4
  %1068 = fmul float %1065, %1067
  %1069 = load float, float* %1044, align 4
  %1070 = fadd float %1069, %1068
  store float %1070, float* %1044, align 4
  %1071 = getelementptr inbounds float, float* %1044, i64 1
  store float 0.000000e+00, float* %1071, align 4
  %1072 = getelementptr inbounds float, float* %1044, i64 1
  %1073 = load float, float* %1010, align 4
  %1074 = getelementptr inbounds float, float* %1, i64 1
  %1075 = load float, float* %1074, align 4
  %1076 = fmul float %1073, %1075
  %1077 = load float, float* %1072, align 4
  %1078 = fadd float %1077, %1076
  store float %1078, float* %1072, align 4
  %1079 = getelementptr inbounds float, float* %1010, i64 1
  %1080 = load float, float* %1079, align 4
  %1081 = getelementptr inbounds float, float* %1, i64 5
  %1082 = load float, float* %1081, align 4
  %1083 = fmul float %1080, %1082
  %1084 = load float, float* %1072, align 4
  %1085 = fadd float %1084, %1083
  store float %1085, float* %1072, align 4
  %1086 = getelementptr inbounds float, float* %1010, i64 2
  %1087 = load float, float* %1086, align 4
  %1088 = getelementptr inbounds float, float* %1, i64 9
  %1089 = load float, float* %1088, align 4
  %1090 = fmul float %1087, %1089
  %1091 = load float, float* %1072, align 4
  %1092 = fadd float %1091, %1090
  store float %1092, float* %1072, align 4
  %1093 = getelementptr inbounds float, float* %1010, i64 3
  %1094 = load float, float* %1093, align 4
  %1095 = getelementptr inbounds float, float* %1, i64 13
  %1096 = load float, float* %1095, align 4
  %1097 = fmul float %1094, %1096
  %1098 = load float, float* %1072, align 4
  %1099 = fadd float %1098, %1097
  store float %1099, float* %1072, align 4
  %1100 = getelementptr inbounds float, float* %1044, i64 2
  store float 0.000000e+00, float* %1100, align 4
  %1101 = getelementptr inbounds float, float* %1044, i64 2
  %1102 = load float, float* %1010, align 4
  %1103 = getelementptr inbounds float, float* %1, i64 2
  %1104 = load float, float* %1103, align 4
  %1105 = fmul float %1102, %1104
  %1106 = load float, float* %1101, align 4
  %1107 = fadd float %1106, %1105
  store float %1107, float* %1101, align 4
  %1108 = getelementptr inbounds float, float* %1010, i64 1
  %1109 = load float, float* %1108, align 4
  %1110 = getelementptr inbounds float, float* %1, i64 6
  %1111 = load float, float* %1110, align 4
  %1112 = fmul float %1109, %1111
  %1113 = load float, float* %1101, align 4
  %1114 = fadd float %1113, %1112
  store float %1114, float* %1101, align 4
  %1115 = getelementptr inbounds float, float* %1010, i64 2
  %1116 = load float, float* %1115, align 4
  %1117 = getelementptr inbounds float, float* %1, i64 10
  %1118 = load float, float* %1117, align 4
  %1119 = fmul float %1116, %1118
  %1120 = load float, float* %1101, align 4
  %1121 = fadd float %1120, %1119
  store float %1121, float* %1101, align 4
  %1122 = getelementptr inbounds float, float* %1010, i64 3
  %1123 = load float, float* %1122, align 4
  %1124 = getelementptr inbounds float, float* %1, i64 14
  %1125 = load float, float* %1124, align 4
  %1126 = fmul float %1123, %1125
  %1127 = load float, float* %1101, align 4
  %1128 = fadd float %1127, %1126
  store float %1128, float* %1101, align 4
  %1129 = getelementptr inbounds float, float* %1044, i64 3
  store float 0.000000e+00, float* %1129, align 4
  %1130 = getelementptr inbounds float, float* %1044, i64 3
  %1131 = load float, float* %1010, align 4
  %1132 = getelementptr inbounds float, float* %1, i64 3
  %1133 = load float, float* %1132, align 4
  %1134 = fmul float %1131, %1133
  %1135 = load float, float* %1130, align 4
  %1136 = fadd float %1135, %1134
  store float %1136, float* %1130, align 4
  %1137 = getelementptr inbounds float, float* %1010, i64 1
  %1138 = load float, float* %1137, align 4
  %1139 = getelementptr inbounds float, float* %1, i64 7
  %1140 = load float, float* %1139, align 4
  %1141 = fmul float %1138, %1140
  %1142 = load float, float* %1130, align 4
  %1143 = fadd float %1142, %1141
  store float %1143, float* %1130, align 4
  %1144 = getelementptr inbounds float, float* %1010, i64 2
  %1145 = load float, float* %1144, align 4
  %1146 = getelementptr inbounds float, float* %1, i64 11
  %1147 = load float, float* %1146, align 4
  %1148 = fmul float %1145, %1147
  %1149 = load float, float* %1130, align 4
  %1150 = fadd float %1149, %1148
  store float %1150, float* %1130, align 4
  %1151 = getelementptr inbounds float, float* %1010, i64 3
  %1152 = load float, float* %1151, align 4
  %1153 = getelementptr inbounds float, float* %1, i64 15
  %1154 = load float, float* %1153, align 4
  %1155 = fmul float %1152, %1154
  %1156 = load float, float* %1130, align 4
  %1157 = fadd float %1156, %1155
  store float %1157, float* %1130, align 4
  %1158 = getelementptr inbounds float, float* %1010, i64 4
  %1159 = getelementptr inbounds float, float* %1044, i64 4
  store float 0.000000e+00, float* %1159, align 4
  %1160 = getelementptr inbounds float, float* %1044, i64 4
  %1161 = load float, float* %1158, align 4
  %1162 = load float, float* %1, align 4
  %1163 = fmul float %1161, %1162
  %1164 = load float, float* %1160, align 4
  %1165 = fadd float %1164, %1163
  store float %1165, float* %1160, align 4
  %1166 = getelementptr inbounds float, float* %1010, i64 5
  %1167 = load float, float* %1166, align 4
  %1168 = getelementptr inbounds float, float* %1, i64 4
  %1169 = load float, float* %1168, align 4
  %1170 = fmul float %1167, %1169
  %1171 = load float, float* %1160, align 4
  %1172 = fadd float %1171, %1170
  store float %1172, float* %1160, align 4
  %1173 = getelementptr inbounds float, float* %1010, i64 6
  %1174 = load float, float* %1173, align 4
  %1175 = getelementptr inbounds float, float* %1, i64 8
  %1176 = load float, float* %1175, align 4
  %1177 = fmul float %1174, %1176
  %1178 = load float, float* %1160, align 4
  %1179 = fadd float %1178, %1177
  store float %1179, float* %1160, align 4
  %1180 = getelementptr inbounds float, float* %1010, i64 7
  %1181 = load float, float* %1180, align 4
  %1182 = getelementptr inbounds float, float* %1, i64 12
  %1183 = load float, float* %1182, align 4
  %1184 = fmul float %1181, %1183
  %1185 = load float, float* %1160, align 4
  %1186 = fadd float %1185, %1184
  store float %1186, float* %1160, align 4
  %1187 = getelementptr inbounds float, float* %1044, i64 5
  store float 0.000000e+00, float* %1187, align 4
  %1188 = getelementptr inbounds float, float* %1044, i64 5
  %1189 = load float, float* %1158, align 4
  %1190 = getelementptr inbounds float, float* %1, i64 1
  %1191 = load float, float* %1190, align 4
  %1192 = fmul float %1189, %1191
  %1193 = load float, float* %1188, align 4
  %1194 = fadd float %1193, %1192
  store float %1194, float* %1188, align 4
  %1195 = getelementptr inbounds float, float* %1010, i64 5
  %1196 = load float, float* %1195, align 4
  %1197 = getelementptr inbounds float, float* %1, i64 5
  %1198 = load float, float* %1197, align 4
  %1199 = fmul float %1196, %1198
  %1200 = load float, float* %1188, align 4
  %1201 = fadd float %1200, %1199
  store float %1201, float* %1188, align 4
  %1202 = getelementptr inbounds float, float* %1010, i64 6
  %1203 = load float, float* %1202, align 4
  %1204 = getelementptr inbounds float, float* %1, i64 9
  %1205 = load float, float* %1204, align 4
  %1206 = fmul float %1203, %1205
  %1207 = load float, float* %1188, align 4
  %1208 = fadd float %1207, %1206
  store float %1208, float* %1188, align 4
  %1209 = getelementptr inbounds float, float* %1010, i64 7
  %1210 = load float, float* %1209, align 4
  %1211 = getelementptr inbounds float, float* %1, i64 13
  %1212 = load float, float* %1211, align 4
  %1213 = fmul float %1210, %1212
  %1214 = load float, float* %1188, align 4
  %1215 = fadd float %1214, %1213
  store float %1215, float* %1188, align 4
  %1216 = getelementptr inbounds float, float* %1044, i64 6
  store float 0.000000e+00, float* %1216, align 4
  %1217 = getelementptr inbounds float, float* %1044, i64 6
  %1218 = load float, float* %1158, align 4
  %1219 = getelementptr inbounds float, float* %1, i64 2
  %1220 = load float, float* %1219, align 4
  %1221 = fmul float %1218, %1220
  %1222 = load float, float* %1217, align 4
  %1223 = fadd float %1222, %1221
  store float %1223, float* %1217, align 4
  %1224 = getelementptr inbounds float, float* %1010, i64 5
  %1225 = load float, float* %1224, align 4
  %1226 = getelementptr inbounds float, float* %1, i64 6
  %1227 = load float, float* %1226, align 4
  %1228 = fmul float %1225, %1227
  %1229 = load float, float* %1217, align 4
  %1230 = fadd float %1229, %1228
  store float %1230, float* %1217, align 4
  %1231 = getelementptr inbounds float, float* %1010, i64 6
  %1232 = load float, float* %1231, align 4
  %1233 = getelementptr inbounds float, float* %1, i64 10
  %1234 = load float, float* %1233, align 4
  %1235 = fmul float %1232, %1234
  %1236 = load float, float* %1217, align 4
  %1237 = fadd float %1236, %1235
  store float %1237, float* %1217, align 4
  %1238 = getelementptr inbounds float, float* %1010, i64 7
  %1239 = load float, float* %1238, align 4
  %1240 = getelementptr inbounds float, float* %1, i64 14
  %1241 = load float, float* %1240, align 4
  %1242 = fmul float %1239, %1241
  %1243 = load float, float* %1217, align 4
  %1244 = fadd float %1243, %1242
  store float %1244, float* %1217, align 4
  %1245 = getelementptr inbounds float, float* %1044, i64 7
  store float 0.000000e+00, float* %1245, align 4
  %1246 = getelementptr inbounds float, float* %1044, i64 7
  %1247 = load float, float* %1158, align 4
  %1248 = getelementptr inbounds float, float* %1, i64 3
  %1249 = load float, float* %1248, align 4
  %1250 = fmul float %1247, %1249
  %1251 = load float, float* %1246, align 4
  %1252 = fadd float %1251, %1250
  store float %1252, float* %1246, align 4
  %1253 = getelementptr inbounds float, float* %1010, i64 5
  %1254 = load float, float* %1253, align 4
  %1255 = getelementptr inbounds float, float* %1, i64 7
  %1256 = load float, float* %1255, align 4
  %1257 = fmul float %1254, %1256
  %1258 = load float, float* %1246, align 4
  %1259 = fadd float %1258, %1257
  store float %1259, float* %1246, align 4
  %1260 = getelementptr inbounds float, float* %1010, i64 6
  %1261 = load float, float* %1260, align 4
  %1262 = getelementptr inbounds float, float* %1, i64 11
  %1263 = load float, float* %1262, align 4
  %1264 = fmul float %1261, %1263
  %1265 = load float, float* %1246, align 4
  %1266 = fadd float %1265, %1264
  store float %1266, float* %1246, align 4
  %1267 = getelementptr inbounds float, float* %1010, i64 7
  %1268 = load float, float* %1267, align 4
  %1269 = getelementptr inbounds float, float* %1, i64 15
  %1270 = load float, float* %1269, align 4
  %1271 = fmul float %1268, %1270
  %1272 = load float, float* %1246, align 4
  %1273 = fadd float %1272, %1271
  store float %1273, float* %1246, align 4
  %1274 = getelementptr inbounds float, float* %1010, i64 8
  %1275 = getelementptr inbounds float, float* %1044, i64 8
  store float 0.000000e+00, float* %1275, align 4
  %1276 = getelementptr inbounds float, float* %1044, i64 8
  %1277 = load float, float* %1274, align 4
  %1278 = load float, float* %1, align 4
  %1279 = fmul float %1277, %1278
  %1280 = load float, float* %1276, align 4
  %1281 = fadd float %1280, %1279
  store float %1281, float* %1276, align 4
  %1282 = getelementptr inbounds float, float* %1010, i64 9
  %1283 = load float, float* %1282, align 4
  %1284 = getelementptr inbounds float, float* %1, i64 4
  %1285 = load float, float* %1284, align 4
  %1286 = fmul float %1283, %1285
  %1287 = load float, float* %1276, align 4
  %1288 = fadd float %1287, %1286
  store float %1288, float* %1276, align 4
  %1289 = getelementptr inbounds float, float* %1010, i64 10
  %1290 = load float, float* %1289, align 4
  %1291 = getelementptr inbounds float, float* %1, i64 8
  %1292 = load float, float* %1291, align 4
  %1293 = fmul float %1290, %1292
  %1294 = load float, float* %1276, align 4
  %1295 = fadd float %1294, %1293
  store float %1295, float* %1276, align 4
  %1296 = getelementptr inbounds float, float* %1010, i64 11
  %1297 = load float, float* %1296, align 4
  %1298 = getelementptr inbounds float, float* %1, i64 12
  %1299 = load float, float* %1298, align 4
  %1300 = fmul float %1297, %1299
  %1301 = load float, float* %1276, align 4
  %1302 = fadd float %1301, %1300
  store float %1302, float* %1276, align 4
  %1303 = getelementptr inbounds float, float* %1044, i64 9
  store float 0.000000e+00, float* %1303, align 4
  %1304 = getelementptr inbounds float, float* %1044, i64 9
  %1305 = load float, float* %1274, align 4
  %1306 = getelementptr inbounds float, float* %1, i64 1
  %1307 = load float, float* %1306, align 4
  %1308 = fmul float %1305, %1307
  %1309 = load float, float* %1304, align 4
  %1310 = fadd float %1309, %1308
  store float %1310, float* %1304, align 4
  %1311 = getelementptr inbounds float, float* %1010, i64 9
  %1312 = load float, float* %1311, align 4
  %1313 = getelementptr inbounds float, float* %1, i64 5
  %1314 = load float, float* %1313, align 4
  %1315 = fmul float %1312, %1314
  %1316 = load float, float* %1304, align 4
  %1317 = fadd float %1316, %1315
  store float %1317, float* %1304, align 4
  %1318 = getelementptr inbounds float, float* %1010, i64 10
  %1319 = load float, float* %1318, align 4
  %1320 = getelementptr inbounds float, float* %1, i64 9
  %1321 = load float, float* %1320, align 4
  %1322 = fmul float %1319, %1321
  %1323 = load float, float* %1304, align 4
  %1324 = fadd float %1323, %1322
  store float %1324, float* %1304, align 4
  %1325 = getelementptr inbounds float, float* %1010, i64 11
  %1326 = load float, float* %1325, align 4
  %1327 = getelementptr inbounds float, float* %1, i64 13
  %1328 = load float, float* %1327, align 4
  %1329 = fmul float %1326, %1328
  %1330 = load float, float* %1304, align 4
  %1331 = fadd float %1330, %1329
  store float %1331, float* %1304, align 4
  %1332 = getelementptr inbounds float, float* %1044, i64 10
  store float 0.000000e+00, float* %1332, align 4
  %1333 = getelementptr inbounds float, float* %1044, i64 10
  %1334 = load float, float* %1274, align 4
  %1335 = getelementptr inbounds float, float* %1, i64 2
  %1336 = load float, float* %1335, align 4
  %1337 = fmul float %1334, %1336
  %1338 = load float, float* %1333, align 4
  %1339 = fadd float %1338, %1337
  store float %1339, float* %1333, align 4
  %1340 = getelementptr inbounds float, float* %1010, i64 9
  %1341 = load float, float* %1340, align 4
  %1342 = getelementptr inbounds float, float* %1, i64 6
  %1343 = load float, float* %1342, align 4
  %1344 = fmul float %1341, %1343
  %1345 = load float, float* %1333, align 4
  %1346 = fadd float %1345, %1344
  store float %1346, float* %1333, align 4
  %1347 = getelementptr inbounds float, float* %1010, i64 10
  %1348 = load float, float* %1347, align 4
  %1349 = getelementptr inbounds float, float* %1, i64 10
  %1350 = load float, float* %1349, align 4
  %1351 = fmul float %1348, %1350
  %1352 = load float, float* %1333, align 4
  %1353 = fadd float %1352, %1351
  store float %1353, float* %1333, align 4
  %1354 = getelementptr inbounds float, float* %1010, i64 11
  %1355 = load float, float* %1354, align 4
  %1356 = getelementptr inbounds float, float* %1, i64 14
  %1357 = load float, float* %1356, align 4
  %1358 = fmul float %1355, %1357
  %1359 = load float, float* %1333, align 4
  %1360 = fadd float %1359, %1358
  store float %1360, float* %1333, align 4
  %1361 = getelementptr inbounds float, float* %1044, i64 11
  store float 0.000000e+00, float* %1361, align 4
  %1362 = getelementptr inbounds float, float* %1044, i64 11
  %1363 = load float, float* %1274, align 4
  %1364 = getelementptr inbounds float, float* %1, i64 3
  %1365 = load float, float* %1364, align 4
  %1366 = fmul float %1363, %1365
  %1367 = load float, float* %1362, align 4
  %1368 = fadd float %1367, %1366
  store float %1368, float* %1362, align 4
  %1369 = getelementptr inbounds float, float* %1010, i64 9
  %1370 = load float, float* %1369, align 4
  %1371 = getelementptr inbounds float, float* %1, i64 7
  %1372 = load float, float* %1371, align 4
  %1373 = fmul float %1370, %1372
  %1374 = load float, float* %1362, align 4
  %1375 = fadd float %1374, %1373
  store float %1375, float* %1362, align 4
  %1376 = getelementptr inbounds float, float* %1010, i64 10
  %1377 = load float, float* %1376, align 4
  %1378 = getelementptr inbounds float, float* %1, i64 11
  %1379 = load float, float* %1378, align 4
  %1380 = fmul float %1377, %1379
  %1381 = load float, float* %1362, align 4
  %1382 = fadd float %1381, %1380
  store float %1382, float* %1362, align 4
  %1383 = getelementptr inbounds float, float* %1010, i64 11
  %1384 = load float, float* %1383, align 4
  %1385 = getelementptr inbounds float, float* %1, i64 15
  %1386 = load float, float* %1385, align 4
  %1387 = fmul float %1384, %1386
  %1388 = load float, float* %1362, align 4
  %1389 = fadd float %1388, %1387
  store float %1389, float* %1362, align 4
  %1390 = getelementptr inbounds float, float* %1010, i64 12
  %1391 = getelementptr inbounds float, float* %1044, i64 12
  store float 0.000000e+00, float* %1391, align 4
  %1392 = getelementptr inbounds float, float* %1044, i64 12
  %1393 = load float, float* %1390, align 4
  %1394 = load float, float* %1, align 4
  %1395 = fmul float %1393, %1394
  %1396 = load float, float* %1392, align 4
  %1397 = fadd float %1396, %1395
  store float %1397, float* %1392, align 4
  %1398 = getelementptr inbounds float, float* %1010, i64 13
  %1399 = load float, float* %1398, align 4
  %1400 = getelementptr inbounds float, float* %1, i64 4
  %1401 = load float, float* %1400, align 4
  %1402 = fmul float %1399, %1401
  %1403 = load float, float* %1392, align 4
  %1404 = fadd float %1403, %1402
  store float %1404, float* %1392, align 4
  %1405 = getelementptr inbounds float, float* %1010, i64 14
  %1406 = load float, float* %1405, align 4
  %1407 = getelementptr inbounds float, float* %1, i64 8
  %1408 = load float, float* %1407, align 4
  %1409 = fmul float %1406, %1408
  %1410 = load float, float* %1392, align 4
  %1411 = fadd float %1410, %1409
  store float %1411, float* %1392, align 4
  %1412 = getelementptr inbounds float, float* %1010, i64 15
  %1413 = load float, float* %1412, align 4
  %1414 = getelementptr inbounds float, float* %1, i64 12
  %1415 = load float, float* %1414, align 4
  %1416 = fmul float %1413, %1415
  %1417 = load float, float* %1392, align 4
  %1418 = fadd float %1417, %1416
  store float %1418, float* %1392, align 4
  %1419 = getelementptr inbounds float, float* %1044, i64 13
  store float 0.000000e+00, float* %1419, align 4
  %1420 = getelementptr inbounds float, float* %1044, i64 13
  %1421 = load float, float* %1390, align 4
  %1422 = getelementptr inbounds float, float* %1, i64 1
  %1423 = load float, float* %1422, align 4
  %1424 = fmul float %1421, %1423
  %1425 = load float, float* %1420, align 4
  %1426 = fadd float %1425, %1424
  store float %1426, float* %1420, align 4
  %1427 = getelementptr inbounds float, float* %1010, i64 13
  %1428 = load float, float* %1427, align 4
  %1429 = getelementptr inbounds float, float* %1, i64 5
  %1430 = load float, float* %1429, align 4
  %1431 = fmul float %1428, %1430
  %1432 = load float, float* %1420, align 4
  %1433 = fadd float %1432, %1431
  store float %1433, float* %1420, align 4
  %1434 = getelementptr inbounds float, float* %1010, i64 14
  %1435 = load float, float* %1434, align 4
  %1436 = getelementptr inbounds float, float* %1, i64 9
  %1437 = load float, float* %1436, align 4
  %1438 = fmul float %1435, %1437
  %1439 = load float, float* %1420, align 4
  %1440 = fadd float %1439, %1438
  store float %1440, float* %1420, align 4
  %1441 = getelementptr inbounds float, float* %1010, i64 15
  %1442 = load float, float* %1441, align 4
  %1443 = getelementptr inbounds float, float* %1, i64 13
  %1444 = load float, float* %1443, align 4
  %1445 = fmul float %1442, %1444
  %1446 = load float, float* %1420, align 4
  %1447 = fadd float %1446, %1445
  store float %1447, float* %1420, align 4
  %1448 = getelementptr inbounds float, float* %1044, i64 14
  store float 0.000000e+00, float* %1448, align 4
  %1449 = getelementptr inbounds float, float* %1044, i64 14
  %1450 = load float, float* %1390, align 4
  %1451 = getelementptr inbounds float, float* %1, i64 2
  %1452 = load float, float* %1451, align 4
  %1453 = fmul float %1450, %1452
  %1454 = load float, float* %1449, align 4
  %1455 = fadd float %1454, %1453
  store float %1455, float* %1449, align 4
  %1456 = getelementptr inbounds float, float* %1010, i64 13
  %1457 = load float, float* %1456, align 4
  %1458 = getelementptr inbounds float, float* %1, i64 6
  %1459 = load float, float* %1458, align 4
  %1460 = fmul float %1457, %1459
  %1461 = load float, float* %1449, align 4
  %1462 = fadd float %1461, %1460
  store float %1462, float* %1449, align 4
  %1463 = getelementptr inbounds float, float* %1010, i64 14
  %1464 = load float, float* %1463, align 4
  %1465 = getelementptr inbounds float, float* %1, i64 10
  %1466 = load float, float* %1465, align 4
  %1467 = fmul float %1464, %1466
  %1468 = load float, float* %1449, align 4
  %1469 = fadd float %1468, %1467
  store float %1469, float* %1449, align 4
  %1470 = getelementptr inbounds float, float* %1010, i64 15
  %1471 = load float, float* %1470, align 4
  %1472 = getelementptr inbounds float, float* %1, i64 14
  %1473 = load float, float* %1472, align 4
  %1474 = fmul float %1471, %1473
  %1475 = load float, float* %1449, align 4
  %1476 = fadd float %1475, %1474
  store float %1476, float* %1449, align 4
  %1477 = getelementptr inbounds float, float* %1044, i64 15
  store float 0.000000e+00, float* %1477, align 4
  %1478 = getelementptr inbounds float, float* %1044, i64 15
  %1479 = load float, float* %1390, align 4
  %1480 = getelementptr inbounds float, float* %1, i64 3
  %1481 = load float, float* %1480, align 4
  %1482 = fmul float %1479, %1481
  %1483 = load float, float* %1478, align 4
  %1484 = fadd float %1483, %1482
  store float %1484, float* %1478, align 4
  %1485 = getelementptr inbounds float, float* %1010, i64 13
  %1486 = load float, float* %1485, align 4
  %1487 = getelementptr inbounds float, float* %1, i64 7
  %1488 = load float, float* %1487, align 4
  %1489 = fmul float %1486, %1488
  %1490 = load float, float* %1478, align 4
  %1491 = fadd float %1490, %1489
  store float %1491, float* %1478, align 4
  %1492 = getelementptr inbounds float, float* %1010, i64 14
  %1493 = load float, float* %1492, align 4
  %1494 = getelementptr inbounds float, float* %1, i64 11
  %1495 = load float, float* %1494, align 4
  %1496 = fmul float %1493, %1495
  %1497 = load float, float* %1478, align 4
  %1498 = fadd float %1497, %1496
  store float %1498, float* %1478, align 4
  %1499 = getelementptr inbounds float, float* %1010, i64 15
  %1500 = load float, float* %1499, align 4
  %1501 = getelementptr inbounds float, float* %1, i64 15
  %1502 = load float, float* %1501, align 4
  %1503 = fmul float %1500, %1502
  %1504 = load float, float* %1478, align 4
  %1505 = fadd float %1504, %1503
  store float %1505, float* %1478, align 4
  %1506 = call i8* @__memcpy_chk(i8* %25, i8* %1043, i64 64, i64 %27) #8
  store float 0.000000e+00, float* %1044, align 4
  %1507 = load float, float* %1010, align 4
  %1508 = load float, float* %2, align 4
  %1509 = fmul float %1507, %1508
  %1510 = load float, float* %1044, align 4
  %1511 = fadd float %1510, %1509
  store float %1511, float* %1044, align 4
  %1512 = getelementptr inbounds float, float* %1010, i64 1
  %1513 = load float, float* %1512, align 4
  %1514 = getelementptr inbounds float, float* %2, i64 4
  %1515 = load float, float* %1514, align 4
  %1516 = fmul float %1513, %1515
  %1517 = load float, float* %1044, align 4
  %1518 = fadd float %1517, %1516
  store float %1518, float* %1044, align 4
  %1519 = getelementptr inbounds float, float* %1010, i64 2
  %1520 = load float, float* %1519, align 4
  %1521 = getelementptr inbounds float, float* %2, i64 8
  %1522 = load float, float* %1521, align 4
  %1523 = fmul float %1520, %1522
  %1524 = load float, float* %1044, align 4
  %1525 = fadd float %1524, %1523
  store float %1525, float* %1044, align 4
  %1526 = getelementptr inbounds float, float* %1010, i64 3
  %1527 = load float, float* %1526, align 4
  %1528 = getelementptr inbounds float, float* %2, i64 12
  %1529 = load float, float* %1528, align 4
  %1530 = fmul float %1527, %1529
  %1531 = load float, float* %1044, align 4
  %1532 = fadd float %1531, %1530
  store float %1532, float* %1044, align 4
  %1533 = getelementptr inbounds float, float* %1044, i64 1
  store float 0.000000e+00, float* %1533, align 4
  %1534 = getelementptr inbounds float, float* %1044, i64 1
  %1535 = load float, float* %1010, align 4
  %1536 = getelementptr inbounds float, float* %2, i64 1
  %1537 = load float, float* %1536, align 4
  %1538 = fmul float %1535, %1537
  %1539 = load float, float* %1534, align 4
  %1540 = fadd float %1539, %1538
  store float %1540, float* %1534, align 4
  %1541 = getelementptr inbounds float, float* %1010, i64 1
  %1542 = load float, float* %1541, align 4
  %1543 = getelementptr inbounds float, float* %2, i64 5
  %1544 = load float, float* %1543, align 4
  %1545 = fmul float %1542, %1544
  %1546 = load float, float* %1534, align 4
  %1547 = fadd float %1546, %1545
  store float %1547, float* %1534, align 4
  %1548 = getelementptr inbounds float, float* %1010, i64 2
  %1549 = load float, float* %1548, align 4
  %1550 = getelementptr inbounds float, float* %2, i64 9
  %1551 = load float, float* %1550, align 4
  %1552 = fmul float %1549, %1551
  %1553 = load float, float* %1534, align 4
  %1554 = fadd float %1553, %1552
  store float %1554, float* %1534, align 4
  %1555 = getelementptr inbounds float, float* %1010, i64 3
  %1556 = load float, float* %1555, align 4
  %1557 = getelementptr inbounds float, float* %2, i64 13
  %1558 = load float, float* %1557, align 4
  %1559 = fmul float %1556, %1558
  %1560 = load float, float* %1534, align 4
  %1561 = fadd float %1560, %1559
  store float %1561, float* %1534, align 4
  %1562 = getelementptr inbounds float, float* %1044, i64 2
  store float 0.000000e+00, float* %1562, align 4
  %1563 = getelementptr inbounds float, float* %1044, i64 2
  %1564 = load float, float* %1010, align 4
  %1565 = getelementptr inbounds float, float* %2, i64 2
  %1566 = load float, float* %1565, align 4
  %1567 = fmul float %1564, %1566
  %1568 = load float, float* %1563, align 4
  %1569 = fadd float %1568, %1567
  store float %1569, float* %1563, align 4
  %1570 = getelementptr inbounds float, float* %1010, i64 1
  %1571 = load float, float* %1570, align 4
  %1572 = getelementptr inbounds float, float* %2, i64 6
  %1573 = load float, float* %1572, align 4
  %1574 = fmul float %1571, %1573
  %1575 = load float, float* %1563, align 4
  %1576 = fadd float %1575, %1574
  store float %1576, float* %1563, align 4
  %1577 = getelementptr inbounds float, float* %1010, i64 2
  %1578 = load float, float* %1577, align 4
  %1579 = getelementptr inbounds float, float* %2, i64 10
  %1580 = load float, float* %1579, align 4
  %1581 = fmul float %1578, %1580
  %1582 = load float, float* %1563, align 4
  %1583 = fadd float %1582, %1581
  store float %1583, float* %1563, align 4
  %1584 = getelementptr inbounds float, float* %1010, i64 3
  %1585 = load float, float* %1584, align 4
  %1586 = getelementptr inbounds float, float* %2, i64 14
  %1587 = load float, float* %1586, align 4
  %1588 = fmul float %1585, %1587
  %1589 = load float, float* %1563, align 4
  %1590 = fadd float %1589, %1588
  store float %1590, float* %1563, align 4
  %1591 = getelementptr inbounds float, float* %1044, i64 3
  store float 0.000000e+00, float* %1591, align 4
  %1592 = getelementptr inbounds float, float* %1044, i64 3
  %1593 = load float, float* %1010, align 4
  %1594 = getelementptr inbounds float, float* %2, i64 3
  %1595 = load float, float* %1594, align 4
  %1596 = fmul float %1593, %1595
  %1597 = load float, float* %1592, align 4
  %1598 = fadd float %1597, %1596
  store float %1598, float* %1592, align 4
  %1599 = getelementptr inbounds float, float* %1010, i64 1
  %1600 = load float, float* %1599, align 4
  %1601 = getelementptr inbounds float, float* %2, i64 7
  %1602 = load float, float* %1601, align 4
  %1603 = fmul float %1600, %1602
  %1604 = load float, float* %1592, align 4
  %1605 = fadd float %1604, %1603
  store float %1605, float* %1592, align 4
  %1606 = getelementptr inbounds float, float* %1010, i64 2
  %1607 = load float, float* %1606, align 4
  %1608 = getelementptr inbounds float, float* %2, i64 11
  %1609 = load float, float* %1608, align 4
  %1610 = fmul float %1607, %1609
  %1611 = load float, float* %1592, align 4
  %1612 = fadd float %1611, %1610
  store float %1612, float* %1592, align 4
  %1613 = getelementptr inbounds float, float* %1010, i64 3
  %1614 = load float, float* %1613, align 4
  %1615 = getelementptr inbounds float, float* %2, i64 15
  %1616 = load float, float* %1615, align 4
  %1617 = fmul float %1614, %1616
  %1618 = load float, float* %1592, align 4
  %1619 = fadd float %1618, %1617
  store float %1619, float* %1592, align 4
  %1620 = getelementptr inbounds float, float* %1010, i64 4
  %1621 = getelementptr inbounds float, float* %1044, i64 4
  store float 0.000000e+00, float* %1621, align 4
  %1622 = getelementptr inbounds float, float* %1044, i64 4
  %1623 = load float, float* %1620, align 4
  %1624 = load float, float* %2, align 4
  %1625 = fmul float %1623, %1624
  %1626 = load float, float* %1622, align 4
  %1627 = fadd float %1626, %1625
  store float %1627, float* %1622, align 4
  %1628 = getelementptr inbounds float, float* %1010, i64 5
  %1629 = load float, float* %1628, align 4
  %1630 = getelementptr inbounds float, float* %2, i64 4
  %1631 = load float, float* %1630, align 4
  %1632 = fmul float %1629, %1631
  %1633 = load float, float* %1622, align 4
  %1634 = fadd float %1633, %1632
  store float %1634, float* %1622, align 4
  %1635 = getelementptr inbounds float, float* %1010, i64 6
  %1636 = load float, float* %1635, align 4
  %1637 = getelementptr inbounds float, float* %2, i64 8
  %1638 = load float, float* %1637, align 4
  %1639 = fmul float %1636, %1638
  %1640 = load float, float* %1622, align 4
  %1641 = fadd float %1640, %1639
  store float %1641, float* %1622, align 4
  %1642 = getelementptr inbounds float, float* %1010, i64 7
  %1643 = load float, float* %1642, align 4
  %1644 = getelementptr inbounds float, float* %2, i64 12
  %1645 = load float, float* %1644, align 4
  %1646 = fmul float %1643, %1645
  %1647 = load float, float* %1622, align 4
  %1648 = fadd float %1647, %1646
  store float %1648, float* %1622, align 4
  %1649 = getelementptr inbounds float, float* %1044, i64 5
  store float 0.000000e+00, float* %1649, align 4
  %1650 = getelementptr inbounds float, float* %1044, i64 5
  %1651 = load float, float* %1620, align 4
  %1652 = getelementptr inbounds float, float* %2, i64 1
  %1653 = load float, float* %1652, align 4
  %1654 = fmul float %1651, %1653
  %1655 = load float, float* %1650, align 4
  %1656 = fadd float %1655, %1654
  store float %1656, float* %1650, align 4
  %1657 = getelementptr inbounds float, float* %1010, i64 5
  %1658 = load float, float* %1657, align 4
  %1659 = getelementptr inbounds float, float* %2, i64 5
  %1660 = load float, float* %1659, align 4
  %1661 = fmul float %1658, %1660
  %1662 = load float, float* %1650, align 4
  %1663 = fadd float %1662, %1661
  store float %1663, float* %1650, align 4
  %1664 = getelementptr inbounds float, float* %1010, i64 6
  %1665 = load float, float* %1664, align 4
  %1666 = getelementptr inbounds float, float* %2, i64 9
  %1667 = load float, float* %1666, align 4
  %1668 = fmul float %1665, %1667
  %1669 = load float, float* %1650, align 4
  %1670 = fadd float %1669, %1668
  store float %1670, float* %1650, align 4
  %1671 = getelementptr inbounds float, float* %1010, i64 7
  %1672 = load float, float* %1671, align 4
  %1673 = getelementptr inbounds float, float* %2, i64 13
  %1674 = load float, float* %1673, align 4
  %1675 = fmul float %1672, %1674
  %1676 = load float, float* %1650, align 4
  %1677 = fadd float %1676, %1675
  store float %1677, float* %1650, align 4
  %1678 = getelementptr inbounds float, float* %1044, i64 6
  store float 0.000000e+00, float* %1678, align 4
  %1679 = getelementptr inbounds float, float* %1044, i64 6
  %1680 = load float, float* %1620, align 4
  %1681 = getelementptr inbounds float, float* %2, i64 2
  %1682 = load float, float* %1681, align 4
  %1683 = fmul float %1680, %1682
  %1684 = load float, float* %1679, align 4
  %1685 = fadd float %1684, %1683
  store float %1685, float* %1679, align 4
  %1686 = getelementptr inbounds float, float* %1010, i64 5
  %1687 = load float, float* %1686, align 4
  %1688 = getelementptr inbounds float, float* %2, i64 6
  %1689 = load float, float* %1688, align 4
  %1690 = fmul float %1687, %1689
  %1691 = load float, float* %1679, align 4
  %1692 = fadd float %1691, %1690
  store float %1692, float* %1679, align 4
  %1693 = getelementptr inbounds float, float* %1010, i64 6
  %1694 = load float, float* %1693, align 4
  %1695 = getelementptr inbounds float, float* %2, i64 10
  %1696 = load float, float* %1695, align 4
  %1697 = fmul float %1694, %1696
  %1698 = load float, float* %1679, align 4
  %1699 = fadd float %1698, %1697
  store float %1699, float* %1679, align 4
  %1700 = getelementptr inbounds float, float* %1010, i64 7
  %1701 = load float, float* %1700, align 4
  %1702 = getelementptr inbounds float, float* %2, i64 14
  %1703 = load float, float* %1702, align 4
  %1704 = fmul float %1701, %1703
  %1705 = load float, float* %1679, align 4
  %1706 = fadd float %1705, %1704
  store float %1706, float* %1679, align 4
  %1707 = getelementptr inbounds float, float* %1044, i64 7
  store float 0.000000e+00, float* %1707, align 4
  %1708 = getelementptr inbounds float, float* %1044, i64 7
  %1709 = load float, float* %1620, align 4
  %1710 = getelementptr inbounds float, float* %2, i64 3
  %1711 = load float, float* %1710, align 4
  %1712 = fmul float %1709, %1711
  %1713 = load float, float* %1708, align 4
  %1714 = fadd float %1713, %1712
  store float %1714, float* %1708, align 4
  %1715 = getelementptr inbounds float, float* %1010, i64 5
  %1716 = load float, float* %1715, align 4
  %1717 = getelementptr inbounds float, float* %2, i64 7
  %1718 = load float, float* %1717, align 4
  %1719 = fmul float %1716, %1718
  %1720 = load float, float* %1708, align 4
  %1721 = fadd float %1720, %1719
  store float %1721, float* %1708, align 4
  %1722 = getelementptr inbounds float, float* %1010, i64 6
  %1723 = load float, float* %1722, align 4
  %1724 = getelementptr inbounds float, float* %2, i64 11
  %1725 = load float, float* %1724, align 4
  %1726 = fmul float %1723, %1725
  %1727 = load float, float* %1708, align 4
  %1728 = fadd float %1727, %1726
  store float %1728, float* %1708, align 4
  %1729 = getelementptr inbounds float, float* %1010, i64 7
  %1730 = load float, float* %1729, align 4
  %1731 = getelementptr inbounds float, float* %2, i64 15
  %1732 = load float, float* %1731, align 4
  %1733 = fmul float %1730, %1732
  %1734 = load float, float* %1708, align 4
  %1735 = fadd float %1734, %1733
  store float %1735, float* %1708, align 4
  %1736 = getelementptr inbounds float, float* %1010, i64 8
  %1737 = getelementptr inbounds float, float* %1044, i64 8
  store float 0.000000e+00, float* %1737, align 4
  %1738 = getelementptr inbounds float, float* %1044, i64 8
  %1739 = load float, float* %1736, align 4
  %1740 = load float, float* %2, align 4
  %1741 = fmul float %1739, %1740
  %1742 = load float, float* %1738, align 4
  %1743 = fadd float %1742, %1741
  store float %1743, float* %1738, align 4
  %1744 = getelementptr inbounds float, float* %1010, i64 9
  %1745 = load float, float* %1744, align 4
  %1746 = getelementptr inbounds float, float* %2, i64 4
  %1747 = load float, float* %1746, align 4
  %1748 = fmul float %1745, %1747
  %1749 = load float, float* %1738, align 4
  %1750 = fadd float %1749, %1748
  store float %1750, float* %1738, align 4
  %1751 = getelementptr inbounds float, float* %1010, i64 10
  %1752 = load float, float* %1751, align 4
  %1753 = getelementptr inbounds float, float* %2, i64 8
  %1754 = load float, float* %1753, align 4
  %1755 = fmul float %1752, %1754
  %1756 = load float, float* %1738, align 4
  %1757 = fadd float %1756, %1755
  store float %1757, float* %1738, align 4
  %1758 = getelementptr inbounds float, float* %1010, i64 11
  %1759 = load float, float* %1758, align 4
  %1760 = getelementptr inbounds float, float* %2, i64 12
  %1761 = load float, float* %1760, align 4
  %1762 = fmul float %1759, %1761
  %1763 = load float, float* %1738, align 4
  %1764 = fadd float %1763, %1762
  store float %1764, float* %1738, align 4
  %1765 = getelementptr inbounds float, float* %1044, i64 9
  store float 0.000000e+00, float* %1765, align 4
  %1766 = getelementptr inbounds float, float* %1044, i64 9
  %1767 = load float, float* %1736, align 4
  %1768 = getelementptr inbounds float, float* %2, i64 1
  %1769 = load float, float* %1768, align 4
  %1770 = fmul float %1767, %1769
  %1771 = load float, float* %1766, align 4
  %1772 = fadd float %1771, %1770
  store float %1772, float* %1766, align 4
  %1773 = getelementptr inbounds float, float* %1010, i64 9
  %1774 = load float, float* %1773, align 4
  %1775 = getelementptr inbounds float, float* %2, i64 5
  %1776 = load float, float* %1775, align 4
  %1777 = fmul float %1774, %1776
  %1778 = load float, float* %1766, align 4
  %1779 = fadd float %1778, %1777
  store float %1779, float* %1766, align 4
  %1780 = getelementptr inbounds float, float* %1010, i64 10
  %1781 = load float, float* %1780, align 4
  %1782 = getelementptr inbounds float, float* %2, i64 9
  %1783 = load float, float* %1782, align 4
  %1784 = fmul float %1781, %1783
  %1785 = load float, float* %1766, align 4
  %1786 = fadd float %1785, %1784
  store float %1786, float* %1766, align 4
  %1787 = getelementptr inbounds float, float* %1010, i64 11
  %1788 = load float, float* %1787, align 4
  %1789 = getelementptr inbounds float, float* %2, i64 13
  %1790 = load float, float* %1789, align 4
  %1791 = fmul float %1788, %1790
  %1792 = load float, float* %1766, align 4
  %1793 = fadd float %1792, %1791
  store float %1793, float* %1766, align 4
  %1794 = getelementptr inbounds float, float* %1044, i64 10
  store float 0.000000e+00, float* %1794, align 4
  %1795 = getelementptr inbounds float, float* %1044, i64 10
  %1796 = load float, float* %1736, align 4
  %1797 = getelementptr inbounds float, float* %2, i64 2
  %1798 = load float, float* %1797, align 4
  %1799 = fmul float %1796, %1798
  %1800 = load float, float* %1795, align 4
  %1801 = fadd float %1800, %1799
  store float %1801, float* %1795, align 4
  %1802 = getelementptr inbounds float, float* %1010, i64 9
  %1803 = load float, float* %1802, align 4
  %1804 = getelementptr inbounds float, float* %2, i64 6
  %1805 = load float, float* %1804, align 4
  %1806 = fmul float %1803, %1805
  %1807 = load float, float* %1795, align 4
  %1808 = fadd float %1807, %1806
  store float %1808, float* %1795, align 4
  %1809 = getelementptr inbounds float, float* %1010, i64 10
  %1810 = load float, float* %1809, align 4
  %1811 = getelementptr inbounds float, float* %2, i64 10
  %1812 = load float, float* %1811, align 4
  %1813 = fmul float %1810, %1812
  %1814 = load float, float* %1795, align 4
  %1815 = fadd float %1814, %1813
  store float %1815, float* %1795, align 4
  %1816 = getelementptr inbounds float, float* %1010, i64 11
  %1817 = load float, float* %1816, align 4
  %1818 = getelementptr inbounds float, float* %2, i64 14
  %1819 = load float, float* %1818, align 4
  %1820 = fmul float %1817, %1819
  %1821 = load float, float* %1795, align 4
  %1822 = fadd float %1821, %1820
  store float %1822, float* %1795, align 4
  %1823 = getelementptr inbounds float, float* %1044, i64 11
  store float 0.000000e+00, float* %1823, align 4
  %1824 = getelementptr inbounds float, float* %1044, i64 11
  %1825 = load float, float* %1736, align 4
  %1826 = getelementptr inbounds float, float* %2, i64 3
  %1827 = load float, float* %1826, align 4
  %1828 = fmul float %1825, %1827
  %1829 = load float, float* %1824, align 4
  %1830 = fadd float %1829, %1828
  store float %1830, float* %1824, align 4
  %1831 = getelementptr inbounds float, float* %1010, i64 9
  %1832 = load float, float* %1831, align 4
  %1833 = getelementptr inbounds float, float* %2, i64 7
  %1834 = load float, float* %1833, align 4
  %1835 = fmul float %1832, %1834
  %1836 = load float, float* %1824, align 4
  %1837 = fadd float %1836, %1835
  store float %1837, float* %1824, align 4
  %1838 = getelementptr inbounds float, float* %1010, i64 10
  %1839 = load float, float* %1838, align 4
  %1840 = getelementptr inbounds float, float* %2, i64 11
  %1841 = load float, float* %1840, align 4
  %1842 = fmul float %1839, %1841
  %1843 = load float, float* %1824, align 4
  %1844 = fadd float %1843, %1842
  store float %1844, float* %1824, align 4
  %1845 = getelementptr inbounds float, float* %1010, i64 11
  %1846 = load float, float* %1845, align 4
  %1847 = getelementptr inbounds float, float* %2, i64 15
  %1848 = load float, float* %1847, align 4
  %1849 = fmul float %1846, %1848
  %1850 = load float, float* %1824, align 4
  %1851 = fadd float %1850, %1849
  store float %1851, float* %1824, align 4
  %1852 = getelementptr inbounds float, float* %1010, i64 12
  %1853 = getelementptr inbounds float, float* %1044, i64 12
  store float 0.000000e+00, float* %1853, align 4
  %1854 = getelementptr inbounds float, float* %1044, i64 12
  %1855 = load float, float* %1852, align 4
  %1856 = load float, float* %2, align 4
  %1857 = fmul float %1855, %1856
  %1858 = load float, float* %1854, align 4
  %1859 = fadd float %1858, %1857
  store float %1859, float* %1854, align 4
  %1860 = getelementptr inbounds float, float* %1010, i64 13
  %1861 = load float, float* %1860, align 4
  %1862 = getelementptr inbounds float, float* %2, i64 4
  %1863 = load float, float* %1862, align 4
  %1864 = fmul float %1861, %1863
  %1865 = load float, float* %1854, align 4
  %1866 = fadd float %1865, %1864
  store float %1866, float* %1854, align 4
  %1867 = getelementptr inbounds float, float* %1010, i64 14
  %1868 = load float, float* %1867, align 4
  %1869 = getelementptr inbounds float, float* %2, i64 8
  %1870 = load float, float* %1869, align 4
  %1871 = fmul float %1868, %1870
  %1872 = load float, float* %1854, align 4
  %1873 = fadd float %1872, %1871
  store float %1873, float* %1854, align 4
  %1874 = getelementptr inbounds float, float* %1010, i64 15
  %1875 = load float, float* %1874, align 4
  %1876 = getelementptr inbounds float, float* %2, i64 12
  %1877 = load float, float* %1876, align 4
  %1878 = fmul float %1875, %1877
  %1879 = load float, float* %1854, align 4
  %1880 = fadd float %1879, %1878
  store float %1880, float* %1854, align 4
  %1881 = getelementptr inbounds float, float* %1044, i64 13
  store float 0.000000e+00, float* %1881, align 4
  %1882 = getelementptr inbounds float, float* %1044, i64 13
  %1883 = load float, float* %1852, align 4
  %1884 = getelementptr inbounds float, float* %2, i64 1
  %1885 = load float, float* %1884, align 4
  %1886 = fmul float %1883, %1885
  %1887 = load float, float* %1882, align 4
  %1888 = fadd float %1887, %1886
  store float %1888, float* %1882, align 4
  %1889 = getelementptr inbounds float, float* %1010, i64 13
  %1890 = load float, float* %1889, align 4
  %1891 = getelementptr inbounds float, float* %2, i64 5
  %1892 = load float, float* %1891, align 4
  %1893 = fmul float %1890, %1892
  %1894 = load float, float* %1882, align 4
  %1895 = fadd float %1894, %1893
  store float %1895, float* %1882, align 4
  %1896 = getelementptr inbounds float, float* %1010, i64 14
  %1897 = load float, float* %1896, align 4
  %1898 = getelementptr inbounds float, float* %2, i64 9
  %1899 = load float, float* %1898, align 4
  %1900 = fmul float %1897, %1899
  %1901 = load float, float* %1882, align 4
  %1902 = fadd float %1901, %1900
  store float %1902, float* %1882, align 4
  %1903 = getelementptr inbounds float, float* %1010, i64 15
  %1904 = load float, float* %1903, align 4
  %1905 = getelementptr inbounds float, float* %2, i64 13
  %1906 = load float, float* %1905, align 4
  %1907 = fmul float %1904, %1906
  %1908 = load float, float* %1882, align 4
  %1909 = fadd float %1908, %1907
  store float %1909, float* %1882, align 4
  %1910 = getelementptr inbounds float, float* %1044, i64 14
  store float 0.000000e+00, float* %1910, align 4
  %1911 = getelementptr inbounds float, float* %1044, i64 14
  %1912 = load float, float* %1852, align 4
  %1913 = getelementptr inbounds float, float* %2, i64 2
  %1914 = load float, float* %1913, align 4
  %1915 = fmul float %1912, %1914
  %1916 = load float, float* %1911, align 4
  %1917 = fadd float %1916, %1915
  store float %1917, float* %1911, align 4
  %1918 = getelementptr inbounds float, float* %1010, i64 13
  %1919 = load float, float* %1918, align 4
  %1920 = getelementptr inbounds float, float* %2, i64 6
  %1921 = load float, float* %1920, align 4
  %1922 = fmul float %1919, %1921
  %1923 = load float, float* %1911, align 4
  %1924 = fadd float %1923, %1922
  store float %1924, float* %1911, align 4
  %1925 = getelementptr inbounds float, float* %1010, i64 14
  %1926 = load float, float* %1925, align 4
  %1927 = getelementptr inbounds float, float* %2, i64 10
  %1928 = load float, float* %1927, align 4
  %1929 = fmul float %1926, %1928
  %1930 = load float, float* %1911, align 4
  %1931 = fadd float %1930, %1929
  store float %1931, float* %1911, align 4
  %1932 = getelementptr inbounds float, float* %1010, i64 15
  %1933 = load float, float* %1932, align 4
  %1934 = getelementptr inbounds float, float* %2, i64 14
  %1935 = load float, float* %1934, align 4
  %1936 = fmul float %1933, %1935
  %1937 = load float, float* %1911, align 4
  %1938 = fadd float %1937, %1936
  store float %1938, float* %1911, align 4
  %1939 = getelementptr inbounds float, float* %1044, i64 15
  store float 0.000000e+00, float* %1939, align 4
  %1940 = getelementptr inbounds float, float* %1044, i64 15
  %1941 = load float, float* %1852, align 4
  %1942 = getelementptr inbounds float, float* %2, i64 3
  %1943 = load float, float* %1942, align 4
  %1944 = fmul float %1941, %1943
  %1945 = load float, float* %1940, align 4
  %1946 = fadd float %1945, %1944
  store float %1946, float* %1940, align 4
  %1947 = getelementptr inbounds float, float* %1010, i64 13
  %1948 = load float, float* %1947, align 4
  %1949 = getelementptr inbounds float, float* %2, i64 7
  %1950 = load float, float* %1949, align 4
  %1951 = fmul float %1948, %1950
  %1952 = load float, float* %1940, align 4
  %1953 = fadd float %1952, %1951
  store float %1953, float* %1940, align 4
  %1954 = getelementptr inbounds float, float* %1010, i64 14
  %1955 = load float, float* %1954, align 4
  %1956 = getelementptr inbounds float, float* %2, i64 11
  %1957 = load float, float* %1956, align 4
  %1958 = fmul float %1955, %1957
  %1959 = load float, float* %1940, align 4
  %1960 = fadd float %1959, %1958
  store float %1960, float* %1940, align 4
  %1961 = getelementptr inbounds float, float* %1010, i64 15
  %1962 = load float, float* %1961, align 4
  %1963 = getelementptr inbounds float, float* %2, i64 15
  %1964 = load float, float* %1963, align 4
  %1965 = fmul float %1962, %1964
  %1966 = load float, float* %1940, align 4
  %1967 = fadd float %1966, %1965
  store float %1967, float* %1940, align 4
  %1968 = call i8* @__memcpy_chk(i8* %28, i8* %1043, i64 64, i64 %30) #8
  call void @free(i8* %823)
  call void @free(i8* %825)
  call void @free(i8* %874)
  call void @free(i8* %876)
  call void @free(i8* %928)
  call void @free(i8* %1009)
  %1969 = call i8* @calloc(i64 4, i64 2) #9
  %1970 = bitcast i8* %1969 to float*
  %1971 = call i8* @calloc(i64 4, i64 2) #9
  %1972 = bitcast i8* %1971 to float*
  %1973 = getelementptr inbounds float, float* %2, i64 10
  %1974 = load float, float* %1973, align 4
  store float %1974, float* %1970, align 4
  %1975 = getelementptr inbounds float, float* %9, i64 10
  %1976 = load float, float* %1975, align 4
  store float %1976, float* %1972, align 4
  %1977 = getelementptr inbounds float, float* %2, i64 14
  %1978 = load float, float* %1977, align 4
  %1979 = getelementptr inbounds float, float* %1970, i64 1
  store float %1978, float* %1979, align 4
  %1980 = getelementptr inbounds float, float* %9, i64 14
  %1981 = load float, float* %1980, align 4
  %1982 = getelementptr inbounds float, float* %1972, i64 1
  store float %1981, float* %1982, align 4
  %1983 = load float, float* %1970, align 4
  %1984 = fcmp ogt float %1983, 0.000000e+00
  %1985 = zext i1 %1984 to i32
  %1986 = fcmp olt float %1983, 0.000000e+00
  %1987 = zext i1 %1986 to i32
  %1988 = sub nsw i32 %1985, %1987
  %1989 = sitofp i32 %1988 to float
  %1990 = load float, float* %1970, align 4
  %1991 = fpext float %1990 to double
  %1992 = call double @llvm.pow.f64(double %1991, double 2.000000e+00) #8
  %1993 = fadd double 0.000000e+00, %1992
  %1994 = fptrunc double %1993 to float
  %1995 = getelementptr inbounds float, float* %1970, i64 1
  %1996 = load float, float* %1995, align 4
  %1997 = fpext float %1996 to double
  %1998 = call double @llvm.pow.f64(double %1997, double 2.000000e+00) #8
  %1999 = fpext float %1994 to double
  %2000 = fadd double %1999, %1998
  %2001 = fptrunc double %2000 to float
  %2002 = fneg float %1989
  %2003 = fpext float %2001 to double
  %2004 = call double @llvm.sqrt.f64(double %2003) #8
  %2005 = fptrunc double %2004 to float
  %2006 = fmul float %2002, %2005
  %2007 = call i8* @calloc(i64 4, i64 2) #9
  %2008 = bitcast i8* %2007 to float*
  %2009 = call i8* @calloc(i64 4, i64 2) #9
  %2010 = load float, float* %1970, align 4
  %2011 = load float, float* %1972, align 4
  %2012 = fmul float %2006, %2011
  %2013 = fadd float %2010, %2012
  store float %2013, float* %2008, align 4
  %2014 = getelementptr inbounds float, float* %1970, i64 1
  %2015 = load float, float* %2014, align 4
  %2016 = getelementptr inbounds float, float* %1972, i64 1
  %2017 = load float, float* %2016, align 4
  %2018 = fmul float %2006, %2017
  %2019 = fadd float %2015, %2018
  %2020 = getelementptr inbounds float, float* %2008, i64 1
  store float %2019, float* %2020, align 4
  %2021 = load float, float* %2008, align 4
  %2022 = fpext float %2021 to double
  %2023 = call double @llvm.pow.f64(double %2022, double 2.000000e+00) #8
  %2024 = fadd double 0.000000e+00, %2023
  %2025 = fptrunc double %2024 to float
  %2026 = getelementptr inbounds float, float* %2008, i64 1
  %2027 = load float, float* %2026, align 4
  %2028 = fpext float %2027 to double
  %2029 = call double @llvm.pow.f64(double %2028, double 2.000000e+00) #8
  %2030 = fpext float %2025 to double
  %2031 = fadd double %2030, %2029
  %2032 = fptrunc double %2031 to float
  %2033 = bitcast i8* %2009 to float*
  %2034 = fpext float %2032 to double
  %2035 = call double @llvm.sqrt.f64(double %2034) #8
  %2036 = fptrunc double %2035 to float
  %2037 = load float, float* %2008, align 4
  %2038 = fdiv float %2037, %2036
  store float %2038, float* %2033, align 4
  %2039 = getelementptr inbounds float, float* %2008, i64 1
  %2040 = load float, float* %2039, align 4
  %2041 = fdiv float %2040, %2036
  %2042 = getelementptr inbounds float, float* %2033, i64 1
  store float %2041, float* %2042, align 4
  %2043 = call i8* @calloc(i64 4, i64 4) #9
  %2044 = bitcast i8* %2043 to float*
  %2045 = load float, float* %2033, align 4
  %2046 = fmul float 2.000000e+00, %2045
  %2047 = load float, float* %2033, align 4
  %2048 = fmul float %2046, %2047
  %2049 = fpext float %2048 to double
  %2050 = fsub double 1.000000e+00, %2049
  %2051 = fptrunc double %2050 to float
  store float %2051, float* %2044, align 4
  %2052 = load float, float* %2033, align 4
  %2053 = fmul float 2.000000e+00, %2052
  %2054 = getelementptr inbounds float, float* %2033, i64 1
  %2055 = load float, float* %2054, align 4
  %2056 = fmul float %2053, %2055
  %2057 = fpext float %2056 to double
  %2058 = fsub double 0.000000e+00, %2057
  %2059 = fptrunc double %2058 to float
  %2060 = getelementptr inbounds float, float* %2044, i64 1
  store float %2059, float* %2060, align 4
  %2061 = getelementptr inbounds float, float* %2033, i64 1
  %2062 = load float, float* %2061, align 4
  %2063 = fmul float 2.000000e+00, %2062
  %2064 = load float, float* %2033, align 4
  %2065 = fmul float %2063, %2064
  %2066 = fpext float %2065 to double
  %2067 = fsub double 0.000000e+00, %2066
  %2068 = fptrunc double %2067 to float
  %2069 = getelementptr inbounds float, float* %2044, i64 2
  store float %2068, float* %2069, align 4
  %2070 = load float, float* %2061, align 4
  %2071 = fmul float 2.000000e+00, %2070
  %2072 = getelementptr inbounds float, float* %2033, i64 1
  %2073 = load float, float* %2072, align 4
  %2074 = fmul float %2071, %2073
  %2075 = fpext float %2074 to double
  %2076 = fsub double 1.000000e+00, %2075
  %2077 = fptrunc double %2076 to float
  %2078 = getelementptr inbounds float, float* %2044, i64 3
  store float %2077, float* %2078, align 4
  %2079 = call i8* @calloc(i64 4, i64 16) #9
  %2080 = bitcast i8* %2079 to float*
  store float 1.000000e+00, float* %2080, align 4
  %2081 = getelementptr inbounds float, float* %2080, i64 1
  store float 0.000000e+00, float* %2081, align 4
  %2082 = getelementptr inbounds float, float* %2080, i64 2
  store float 0.000000e+00, float* %2082, align 4
  %2083 = getelementptr inbounds float, float* %2080, i64 3
  store float 0.000000e+00, float* %2083, align 4
  %2084 = getelementptr inbounds float, float* %2080, i64 4
  store float 0.000000e+00, float* %2084, align 4
  %2085 = getelementptr inbounds float, float* %2080, i64 5
  store float 1.000000e+00, float* %2085, align 4
  %2086 = getelementptr inbounds float, float* %2080, i64 6
  store float 0.000000e+00, float* %2086, align 4
  %2087 = getelementptr inbounds float, float* %2080, i64 7
  store float 0.000000e+00, float* %2087, align 4
  %2088 = getelementptr inbounds float, float* %2080, i64 8
  store float 0.000000e+00, float* %2088, align 4
  %2089 = getelementptr inbounds float, float* %2080, i64 9
  store float 0.000000e+00, float* %2089, align 4
  %2090 = load float, float* %2044, align 4
  %2091 = getelementptr inbounds float, float* %2080, i64 10
  store float %2090, float* %2091, align 4
  %2092 = getelementptr inbounds float, float* %2044, i64 1
  %2093 = load float, float* %2092, align 4
  %2094 = getelementptr inbounds float, float* %2080, i64 11
  store float %2093, float* %2094, align 4
  %2095 = getelementptr inbounds float, float* %2080, i64 12
  store float 0.000000e+00, float* %2095, align 4
  %2096 = getelementptr inbounds float, float* %2080, i64 13
  store float 0.000000e+00, float* %2096, align 4
  %2097 = getelementptr inbounds float, float* %2044, i64 2
  %2098 = load float, float* %2097, align 4
  %2099 = getelementptr inbounds float, float* %2080, i64 14
  store float %2098, float* %2099, align 4
  %2100 = getelementptr inbounds float, float* %2044, i64 3
  %2101 = load float, float* %2100, align 4
  %2102 = getelementptr inbounds float, float* %2080, i64 15
  store float %2101, float* %2102, align 4
  %2103 = call i8* @calloc(i64 4, i64 16) #9
  %2104 = bitcast i8* %2103 to float*
  store float 0.000000e+00, float* %2104, align 4
  %2105 = load float, float* %2080, align 4
  %2106 = load float, float* %1, align 4
  %2107 = fmul float %2105, %2106
  %2108 = load float, float* %2104, align 4
  %2109 = fadd float %2108, %2107
  store float %2109, float* %2104, align 4
  %2110 = getelementptr inbounds float, float* %2080, i64 1
  %2111 = load float, float* %2110, align 4
  %2112 = getelementptr inbounds float, float* %1, i64 4
  %2113 = load float, float* %2112, align 4
  %2114 = fmul float %2111, %2113
  %2115 = load float, float* %2104, align 4
  %2116 = fadd float %2115, %2114
  store float %2116, float* %2104, align 4
  %2117 = getelementptr inbounds float, float* %2080, i64 2
  %2118 = load float, float* %2117, align 4
  %2119 = getelementptr inbounds float, float* %1, i64 8
  %2120 = load float, float* %2119, align 4
  %2121 = fmul float %2118, %2120
  %2122 = load float, float* %2104, align 4
  %2123 = fadd float %2122, %2121
  store float %2123, float* %2104, align 4
  %2124 = getelementptr inbounds float, float* %2080, i64 3
  %2125 = load float, float* %2124, align 4
  %2126 = getelementptr inbounds float, float* %1, i64 12
  %2127 = load float, float* %2126, align 4
  %2128 = fmul float %2125, %2127
  %2129 = load float, float* %2104, align 4
  %2130 = fadd float %2129, %2128
  store float %2130, float* %2104, align 4
  %2131 = getelementptr inbounds float, float* %2104, i64 1
  store float 0.000000e+00, float* %2131, align 4
  %2132 = getelementptr inbounds float, float* %2104, i64 1
  %2133 = load float, float* %2080, align 4
  %2134 = getelementptr inbounds float, float* %1, i64 1
  %2135 = load float, float* %2134, align 4
  %2136 = fmul float %2133, %2135
  %2137 = load float, float* %2132, align 4
  %2138 = fadd float %2137, %2136
  store float %2138, float* %2132, align 4
  %2139 = getelementptr inbounds float, float* %2080, i64 1
  %2140 = load float, float* %2139, align 4
  %2141 = getelementptr inbounds float, float* %1, i64 5
  %2142 = load float, float* %2141, align 4
  %2143 = fmul float %2140, %2142
  %2144 = load float, float* %2132, align 4
  %2145 = fadd float %2144, %2143
  store float %2145, float* %2132, align 4
  %2146 = getelementptr inbounds float, float* %2080, i64 2
  %2147 = load float, float* %2146, align 4
  %2148 = getelementptr inbounds float, float* %1, i64 9
  %2149 = load float, float* %2148, align 4
  %2150 = fmul float %2147, %2149
  %2151 = load float, float* %2132, align 4
  %2152 = fadd float %2151, %2150
  store float %2152, float* %2132, align 4
  %2153 = getelementptr inbounds float, float* %2080, i64 3
  %2154 = load float, float* %2153, align 4
  %2155 = getelementptr inbounds float, float* %1, i64 13
  %2156 = load float, float* %2155, align 4
  %2157 = fmul float %2154, %2156
  %2158 = load float, float* %2132, align 4
  %2159 = fadd float %2158, %2157
  store float %2159, float* %2132, align 4
  %2160 = getelementptr inbounds float, float* %2104, i64 2
  store float 0.000000e+00, float* %2160, align 4
  %2161 = getelementptr inbounds float, float* %2104, i64 2
  %2162 = load float, float* %2080, align 4
  %2163 = getelementptr inbounds float, float* %1, i64 2
  %2164 = load float, float* %2163, align 4
  %2165 = fmul float %2162, %2164
  %2166 = load float, float* %2161, align 4
  %2167 = fadd float %2166, %2165
  store float %2167, float* %2161, align 4
  %2168 = getelementptr inbounds float, float* %2080, i64 1
  %2169 = load float, float* %2168, align 4
  %2170 = getelementptr inbounds float, float* %1, i64 6
  %2171 = load float, float* %2170, align 4
  %2172 = fmul float %2169, %2171
  %2173 = load float, float* %2161, align 4
  %2174 = fadd float %2173, %2172
  store float %2174, float* %2161, align 4
  %2175 = getelementptr inbounds float, float* %2080, i64 2
  %2176 = load float, float* %2175, align 4
  %2177 = getelementptr inbounds float, float* %1, i64 10
  %2178 = load float, float* %2177, align 4
  %2179 = fmul float %2176, %2178
  %2180 = load float, float* %2161, align 4
  %2181 = fadd float %2180, %2179
  store float %2181, float* %2161, align 4
  %2182 = getelementptr inbounds float, float* %2080, i64 3
  %2183 = load float, float* %2182, align 4
  %2184 = getelementptr inbounds float, float* %1, i64 14
  %2185 = load float, float* %2184, align 4
  %2186 = fmul float %2183, %2185
  %2187 = load float, float* %2161, align 4
  %2188 = fadd float %2187, %2186
  store float %2188, float* %2161, align 4
  %2189 = getelementptr inbounds float, float* %2104, i64 3
  store float 0.000000e+00, float* %2189, align 4
  %2190 = getelementptr inbounds float, float* %2104, i64 3
  %2191 = load float, float* %2080, align 4
  %2192 = getelementptr inbounds float, float* %1, i64 3
  %2193 = load float, float* %2192, align 4
  %2194 = fmul float %2191, %2193
  %2195 = load float, float* %2190, align 4
  %2196 = fadd float %2195, %2194
  store float %2196, float* %2190, align 4
  %2197 = getelementptr inbounds float, float* %2080, i64 1
  %2198 = load float, float* %2197, align 4
  %2199 = getelementptr inbounds float, float* %1, i64 7
  %2200 = load float, float* %2199, align 4
  %2201 = fmul float %2198, %2200
  %2202 = load float, float* %2190, align 4
  %2203 = fadd float %2202, %2201
  store float %2203, float* %2190, align 4
  %2204 = getelementptr inbounds float, float* %2080, i64 2
  %2205 = load float, float* %2204, align 4
  %2206 = getelementptr inbounds float, float* %1, i64 11
  %2207 = load float, float* %2206, align 4
  %2208 = fmul float %2205, %2207
  %2209 = load float, float* %2190, align 4
  %2210 = fadd float %2209, %2208
  store float %2210, float* %2190, align 4
  %2211 = getelementptr inbounds float, float* %2080, i64 3
  %2212 = load float, float* %2211, align 4
  %2213 = getelementptr inbounds float, float* %1, i64 15
  %2214 = load float, float* %2213, align 4
  %2215 = fmul float %2212, %2214
  %2216 = load float, float* %2190, align 4
  %2217 = fadd float %2216, %2215
  store float %2217, float* %2190, align 4
  %2218 = getelementptr inbounds float, float* %2080, i64 4
  %2219 = getelementptr inbounds float, float* %2104, i64 4
  store float 0.000000e+00, float* %2219, align 4
  %2220 = getelementptr inbounds float, float* %2104, i64 4
  %2221 = load float, float* %2218, align 4
  %2222 = load float, float* %1, align 4
  %2223 = fmul float %2221, %2222
  %2224 = load float, float* %2220, align 4
  %2225 = fadd float %2224, %2223
  store float %2225, float* %2220, align 4
  %2226 = getelementptr inbounds float, float* %2080, i64 5
  %2227 = load float, float* %2226, align 4
  %2228 = getelementptr inbounds float, float* %1, i64 4
  %2229 = load float, float* %2228, align 4
  %2230 = fmul float %2227, %2229
  %2231 = load float, float* %2220, align 4
  %2232 = fadd float %2231, %2230
  store float %2232, float* %2220, align 4
  %2233 = getelementptr inbounds float, float* %2080, i64 6
  %2234 = load float, float* %2233, align 4
  %2235 = getelementptr inbounds float, float* %1, i64 8
  %2236 = load float, float* %2235, align 4
  %2237 = fmul float %2234, %2236
  %2238 = load float, float* %2220, align 4
  %2239 = fadd float %2238, %2237
  store float %2239, float* %2220, align 4
  %2240 = getelementptr inbounds float, float* %2080, i64 7
  %2241 = load float, float* %2240, align 4
  %2242 = getelementptr inbounds float, float* %1, i64 12
  %2243 = load float, float* %2242, align 4
  %2244 = fmul float %2241, %2243
  %2245 = load float, float* %2220, align 4
  %2246 = fadd float %2245, %2244
  store float %2246, float* %2220, align 4
  %2247 = getelementptr inbounds float, float* %2104, i64 5
  store float 0.000000e+00, float* %2247, align 4
  %2248 = getelementptr inbounds float, float* %2104, i64 5
  %2249 = load float, float* %2218, align 4
  %2250 = getelementptr inbounds float, float* %1, i64 1
  %2251 = load float, float* %2250, align 4
  %2252 = fmul float %2249, %2251
  %2253 = load float, float* %2248, align 4
  %2254 = fadd float %2253, %2252
  store float %2254, float* %2248, align 4
  %2255 = getelementptr inbounds float, float* %2080, i64 5
  %2256 = load float, float* %2255, align 4
  %2257 = getelementptr inbounds float, float* %1, i64 5
  %2258 = load float, float* %2257, align 4
  %2259 = fmul float %2256, %2258
  %2260 = load float, float* %2248, align 4
  %2261 = fadd float %2260, %2259
  store float %2261, float* %2248, align 4
  %2262 = getelementptr inbounds float, float* %2080, i64 6
  %2263 = load float, float* %2262, align 4
  %2264 = getelementptr inbounds float, float* %1, i64 9
  %2265 = load float, float* %2264, align 4
  %2266 = fmul float %2263, %2265
  %2267 = load float, float* %2248, align 4
  %2268 = fadd float %2267, %2266
  store float %2268, float* %2248, align 4
  %2269 = getelementptr inbounds float, float* %2080, i64 7
  %2270 = load float, float* %2269, align 4
  %2271 = getelementptr inbounds float, float* %1, i64 13
  %2272 = load float, float* %2271, align 4
  %2273 = fmul float %2270, %2272
  %2274 = load float, float* %2248, align 4
  %2275 = fadd float %2274, %2273
  store float %2275, float* %2248, align 4
  %2276 = getelementptr inbounds float, float* %2104, i64 6
  store float 0.000000e+00, float* %2276, align 4
  %2277 = getelementptr inbounds float, float* %2104, i64 6
  %2278 = load float, float* %2218, align 4
  %2279 = getelementptr inbounds float, float* %1, i64 2
  %2280 = load float, float* %2279, align 4
  %2281 = fmul float %2278, %2280
  %2282 = load float, float* %2277, align 4
  %2283 = fadd float %2282, %2281
  store float %2283, float* %2277, align 4
  %2284 = getelementptr inbounds float, float* %2080, i64 5
  %2285 = load float, float* %2284, align 4
  %2286 = getelementptr inbounds float, float* %1, i64 6
  %2287 = load float, float* %2286, align 4
  %2288 = fmul float %2285, %2287
  %2289 = load float, float* %2277, align 4
  %2290 = fadd float %2289, %2288
  store float %2290, float* %2277, align 4
  %2291 = getelementptr inbounds float, float* %2080, i64 6
  %2292 = load float, float* %2291, align 4
  %2293 = getelementptr inbounds float, float* %1, i64 10
  %2294 = load float, float* %2293, align 4
  %2295 = fmul float %2292, %2294
  %2296 = load float, float* %2277, align 4
  %2297 = fadd float %2296, %2295
  store float %2297, float* %2277, align 4
  %2298 = getelementptr inbounds float, float* %2080, i64 7
  %2299 = load float, float* %2298, align 4
  %2300 = getelementptr inbounds float, float* %1, i64 14
  %2301 = load float, float* %2300, align 4
  %2302 = fmul float %2299, %2301
  %2303 = load float, float* %2277, align 4
  %2304 = fadd float %2303, %2302
  store float %2304, float* %2277, align 4
  %2305 = getelementptr inbounds float, float* %2104, i64 7
  store float 0.000000e+00, float* %2305, align 4
  %2306 = getelementptr inbounds float, float* %2104, i64 7
  %2307 = load float, float* %2218, align 4
  %2308 = getelementptr inbounds float, float* %1, i64 3
  %2309 = load float, float* %2308, align 4
  %2310 = fmul float %2307, %2309
  %2311 = load float, float* %2306, align 4
  %2312 = fadd float %2311, %2310
  store float %2312, float* %2306, align 4
  %2313 = getelementptr inbounds float, float* %2080, i64 5
  %2314 = load float, float* %2313, align 4
  %2315 = getelementptr inbounds float, float* %1, i64 7
  %2316 = load float, float* %2315, align 4
  %2317 = fmul float %2314, %2316
  %2318 = load float, float* %2306, align 4
  %2319 = fadd float %2318, %2317
  store float %2319, float* %2306, align 4
  %2320 = getelementptr inbounds float, float* %2080, i64 6
  %2321 = load float, float* %2320, align 4
  %2322 = getelementptr inbounds float, float* %1, i64 11
  %2323 = load float, float* %2322, align 4
  %2324 = fmul float %2321, %2323
  %2325 = load float, float* %2306, align 4
  %2326 = fadd float %2325, %2324
  store float %2326, float* %2306, align 4
  %2327 = getelementptr inbounds float, float* %2080, i64 7
  %2328 = load float, float* %2327, align 4
  %2329 = getelementptr inbounds float, float* %1, i64 15
  %2330 = load float, float* %2329, align 4
  %2331 = fmul float %2328, %2330
  %2332 = load float, float* %2306, align 4
  %2333 = fadd float %2332, %2331
  store float %2333, float* %2306, align 4
  %2334 = getelementptr inbounds float, float* %2080, i64 8
  %2335 = getelementptr inbounds float, float* %2104, i64 8
  store float 0.000000e+00, float* %2335, align 4
  %2336 = getelementptr inbounds float, float* %2104, i64 8
  %2337 = load float, float* %2334, align 4
  %2338 = load float, float* %1, align 4
  %2339 = fmul float %2337, %2338
  %2340 = load float, float* %2336, align 4
  %2341 = fadd float %2340, %2339
  store float %2341, float* %2336, align 4
  %2342 = getelementptr inbounds float, float* %2080, i64 9
  %2343 = load float, float* %2342, align 4
  %2344 = getelementptr inbounds float, float* %1, i64 4
  %2345 = load float, float* %2344, align 4
  %2346 = fmul float %2343, %2345
  %2347 = load float, float* %2336, align 4
  %2348 = fadd float %2347, %2346
  store float %2348, float* %2336, align 4
  %2349 = getelementptr inbounds float, float* %2080, i64 10
  %2350 = load float, float* %2349, align 4
  %2351 = getelementptr inbounds float, float* %1, i64 8
  %2352 = load float, float* %2351, align 4
  %2353 = fmul float %2350, %2352
  %2354 = load float, float* %2336, align 4
  %2355 = fadd float %2354, %2353
  store float %2355, float* %2336, align 4
  %2356 = getelementptr inbounds float, float* %2080, i64 11
  %2357 = load float, float* %2356, align 4
  %2358 = getelementptr inbounds float, float* %1, i64 12
  %2359 = load float, float* %2358, align 4
  %2360 = fmul float %2357, %2359
  %2361 = load float, float* %2336, align 4
  %2362 = fadd float %2361, %2360
  store float %2362, float* %2336, align 4
  %2363 = getelementptr inbounds float, float* %2104, i64 9
  store float 0.000000e+00, float* %2363, align 4
  %2364 = getelementptr inbounds float, float* %2104, i64 9
  %2365 = load float, float* %2334, align 4
  %2366 = getelementptr inbounds float, float* %1, i64 1
  %2367 = load float, float* %2366, align 4
  %2368 = fmul float %2365, %2367
  %2369 = load float, float* %2364, align 4
  %2370 = fadd float %2369, %2368
  store float %2370, float* %2364, align 4
  %2371 = getelementptr inbounds float, float* %2080, i64 9
  %2372 = load float, float* %2371, align 4
  %2373 = getelementptr inbounds float, float* %1, i64 5
  %2374 = load float, float* %2373, align 4
  %2375 = fmul float %2372, %2374
  %2376 = load float, float* %2364, align 4
  %2377 = fadd float %2376, %2375
  store float %2377, float* %2364, align 4
  %2378 = getelementptr inbounds float, float* %2080, i64 10
  %2379 = load float, float* %2378, align 4
  %2380 = getelementptr inbounds float, float* %1, i64 9
  %2381 = load float, float* %2380, align 4
  %2382 = fmul float %2379, %2381
  %2383 = load float, float* %2364, align 4
  %2384 = fadd float %2383, %2382
  store float %2384, float* %2364, align 4
  %2385 = getelementptr inbounds float, float* %2080, i64 11
  %2386 = load float, float* %2385, align 4
  %2387 = getelementptr inbounds float, float* %1, i64 13
  %2388 = load float, float* %2387, align 4
  %2389 = fmul float %2386, %2388
  %2390 = load float, float* %2364, align 4
  %2391 = fadd float %2390, %2389
  store float %2391, float* %2364, align 4
  %2392 = getelementptr inbounds float, float* %2104, i64 10
  store float 0.000000e+00, float* %2392, align 4
  %2393 = getelementptr inbounds float, float* %2104, i64 10
  %2394 = load float, float* %2334, align 4
  %2395 = getelementptr inbounds float, float* %1, i64 2
  %2396 = load float, float* %2395, align 4
  %2397 = fmul float %2394, %2396
  %2398 = load float, float* %2393, align 4
  %2399 = fadd float %2398, %2397
  store float %2399, float* %2393, align 4
  %2400 = getelementptr inbounds float, float* %2080, i64 9
  %2401 = load float, float* %2400, align 4
  %2402 = getelementptr inbounds float, float* %1, i64 6
  %2403 = load float, float* %2402, align 4
  %2404 = fmul float %2401, %2403
  %2405 = load float, float* %2393, align 4
  %2406 = fadd float %2405, %2404
  store float %2406, float* %2393, align 4
  %2407 = getelementptr inbounds float, float* %2080, i64 10
  %2408 = load float, float* %2407, align 4
  %2409 = getelementptr inbounds float, float* %1, i64 10
  %2410 = load float, float* %2409, align 4
  %2411 = fmul float %2408, %2410
  %2412 = load float, float* %2393, align 4
  %2413 = fadd float %2412, %2411
  store float %2413, float* %2393, align 4
  %2414 = getelementptr inbounds float, float* %2080, i64 11
  %2415 = load float, float* %2414, align 4
  %2416 = getelementptr inbounds float, float* %1, i64 14
  %2417 = load float, float* %2416, align 4
  %2418 = fmul float %2415, %2417
  %2419 = load float, float* %2393, align 4
  %2420 = fadd float %2419, %2418
  store float %2420, float* %2393, align 4
  %2421 = getelementptr inbounds float, float* %2104, i64 11
  store float 0.000000e+00, float* %2421, align 4
  %2422 = getelementptr inbounds float, float* %2104, i64 11
  %2423 = load float, float* %2334, align 4
  %2424 = getelementptr inbounds float, float* %1, i64 3
  %2425 = load float, float* %2424, align 4
  %2426 = fmul float %2423, %2425
  %2427 = load float, float* %2422, align 4
  %2428 = fadd float %2427, %2426
  store float %2428, float* %2422, align 4
  %2429 = getelementptr inbounds float, float* %2080, i64 9
  %2430 = load float, float* %2429, align 4
  %2431 = getelementptr inbounds float, float* %1, i64 7
  %2432 = load float, float* %2431, align 4
  %2433 = fmul float %2430, %2432
  %2434 = load float, float* %2422, align 4
  %2435 = fadd float %2434, %2433
  store float %2435, float* %2422, align 4
  %2436 = getelementptr inbounds float, float* %2080, i64 10
  %2437 = load float, float* %2436, align 4
  %2438 = getelementptr inbounds float, float* %1, i64 11
  %2439 = load float, float* %2438, align 4
  %2440 = fmul float %2437, %2439
  %2441 = load float, float* %2422, align 4
  %2442 = fadd float %2441, %2440
  store float %2442, float* %2422, align 4
  %2443 = getelementptr inbounds float, float* %2080, i64 11
  %2444 = load float, float* %2443, align 4
  %2445 = getelementptr inbounds float, float* %1, i64 15
  %2446 = load float, float* %2445, align 4
  %2447 = fmul float %2444, %2446
  %2448 = load float, float* %2422, align 4
  %2449 = fadd float %2448, %2447
  store float %2449, float* %2422, align 4
  %2450 = getelementptr inbounds float, float* %2080, i64 12
  %2451 = getelementptr inbounds float, float* %2104, i64 12
  store float 0.000000e+00, float* %2451, align 4
  %2452 = getelementptr inbounds float, float* %2104, i64 12
  %2453 = load float, float* %2450, align 4
  %2454 = load float, float* %1, align 4
  %2455 = fmul float %2453, %2454
  %2456 = load float, float* %2452, align 4
  %2457 = fadd float %2456, %2455
  store float %2457, float* %2452, align 4
  %2458 = getelementptr inbounds float, float* %2080, i64 13
  %2459 = load float, float* %2458, align 4
  %2460 = getelementptr inbounds float, float* %1, i64 4
  %2461 = load float, float* %2460, align 4
  %2462 = fmul float %2459, %2461
  %2463 = load float, float* %2452, align 4
  %2464 = fadd float %2463, %2462
  store float %2464, float* %2452, align 4
  %2465 = getelementptr inbounds float, float* %2080, i64 14
  %2466 = load float, float* %2465, align 4
  %2467 = getelementptr inbounds float, float* %1, i64 8
  %2468 = load float, float* %2467, align 4
  %2469 = fmul float %2466, %2468
  %2470 = load float, float* %2452, align 4
  %2471 = fadd float %2470, %2469
  store float %2471, float* %2452, align 4
  %2472 = getelementptr inbounds float, float* %2080, i64 15
  %2473 = load float, float* %2472, align 4
  %2474 = getelementptr inbounds float, float* %1, i64 12
  %2475 = load float, float* %2474, align 4
  %2476 = fmul float %2473, %2475
  %2477 = load float, float* %2452, align 4
  %2478 = fadd float %2477, %2476
  store float %2478, float* %2452, align 4
  %2479 = getelementptr inbounds float, float* %2104, i64 13
  store float 0.000000e+00, float* %2479, align 4
  %2480 = getelementptr inbounds float, float* %2104, i64 13
  %2481 = load float, float* %2450, align 4
  %2482 = getelementptr inbounds float, float* %1, i64 1
  %2483 = load float, float* %2482, align 4
  %2484 = fmul float %2481, %2483
  %2485 = load float, float* %2480, align 4
  %2486 = fadd float %2485, %2484
  store float %2486, float* %2480, align 4
  %2487 = getelementptr inbounds float, float* %2080, i64 13
  %2488 = load float, float* %2487, align 4
  %2489 = getelementptr inbounds float, float* %1, i64 5
  %2490 = load float, float* %2489, align 4
  %2491 = fmul float %2488, %2490
  %2492 = load float, float* %2480, align 4
  %2493 = fadd float %2492, %2491
  store float %2493, float* %2480, align 4
  %2494 = getelementptr inbounds float, float* %2080, i64 14
  %2495 = load float, float* %2494, align 4
  %2496 = getelementptr inbounds float, float* %1, i64 9
  %2497 = load float, float* %2496, align 4
  %2498 = fmul float %2495, %2497
  %2499 = load float, float* %2480, align 4
  %2500 = fadd float %2499, %2498
  store float %2500, float* %2480, align 4
  %2501 = getelementptr inbounds float, float* %2080, i64 15
  %2502 = load float, float* %2501, align 4
  %2503 = getelementptr inbounds float, float* %1, i64 13
  %2504 = load float, float* %2503, align 4
  %2505 = fmul float %2502, %2504
  %2506 = load float, float* %2480, align 4
  %2507 = fadd float %2506, %2505
  store float %2507, float* %2480, align 4
  %2508 = getelementptr inbounds float, float* %2104, i64 14
  store float 0.000000e+00, float* %2508, align 4
  %2509 = getelementptr inbounds float, float* %2104, i64 14
  %2510 = load float, float* %2450, align 4
  %2511 = getelementptr inbounds float, float* %1, i64 2
  %2512 = load float, float* %2511, align 4
  %2513 = fmul float %2510, %2512
  %2514 = load float, float* %2509, align 4
  %2515 = fadd float %2514, %2513
  store float %2515, float* %2509, align 4
  %2516 = getelementptr inbounds float, float* %2080, i64 13
  %2517 = load float, float* %2516, align 4
  %2518 = getelementptr inbounds float, float* %1, i64 6
  %2519 = load float, float* %2518, align 4
  %2520 = fmul float %2517, %2519
  %2521 = load float, float* %2509, align 4
  %2522 = fadd float %2521, %2520
  store float %2522, float* %2509, align 4
  %2523 = getelementptr inbounds float, float* %2080, i64 14
  %2524 = load float, float* %2523, align 4
  %2525 = getelementptr inbounds float, float* %1, i64 10
  %2526 = load float, float* %2525, align 4
  %2527 = fmul float %2524, %2526
  %2528 = load float, float* %2509, align 4
  %2529 = fadd float %2528, %2527
  store float %2529, float* %2509, align 4
  %2530 = getelementptr inbounds float, float* %2080, i64 15
  %2531 = load float, float* %2530, align 4
  %2532 = getelementptr inbounds float, float* %1, i64 14
  %2533 = load float, float* %2532, align 4
  %2534 = fmul float %2531, %2533
  %2535 = load float, float* %2509, align 4
  %2536 = fadd float %2535, %2534
  store float %2536, float* %2509, align 4
  %2537 = getelementptr inbounds float, float* %2104, i64 15
  store float 0.000000e+00, float* %2537, align 4
  %2538 = getelementptr inbounds float, float* %2104, i64 15
  %2539 = load float, float* %2450, align 4
  %2540 = getelementptr inbounds float, float* %1, i64 3
  %2541 = load float, float* %2540, align 4
  %2542 = fmul float %2539, %2541
  %2543 = load float, float* %2538, align 4
  %2544 = fadd float %2543, %2542
  store float %2544, float* %2538, align 4
  %2545 = getelementptr inbounds float, float* %2080, i64 13
  %2546 = load float, float* %2545, align 4
  %2547 = getelementptr inbounds float, float* %1, i64 7
  %2548 = load float, float* %2547, align 4
  %2549 = fmul float %2546, %2548
  %2550 = load float, float* %2538, align 4
  %2551 = fadd float %2550, %2549
  store float %2551, float* %2538, align 4
  %2552 = getelementptr inbounds float, float* %2080, i64 14
  %2553 = load float, float* %2552, align 4
  %2554 = getelementptr inbounds float, float* %1, i64 11
  %2555 = load float, float* %2554, align 4
  %2556 = fmul float %2553, %2555
  %2557 = load float, float* %2538, align 4
  %2558 = fadd float %2557, %2556
  store float %2558, float* %2538, align 4
  %2559 = getelementptr inbounds float, float* %2080, i64 15
  %2560 = load float, float* %2559, align 4
  %2561 = getelementptr inbounds float, float* %1, i64 15
  %2562 = load float, float* %2561, align 4
  %2563 = fmul float %2560, %2562
  %2564 = load float, float* %2538, align 4
  %2565 = fadd float %2564, %2563
  store float %2565, float* %2538, align 4
  %2566 = call i8* @__memcpy_chk(i8* %25, i8* %2103, i64 64, i64 %27) #8
  store float 0.000000e+00, float* %2104, align 4
  %2567 = load float, float* %2080, align 4
  %2568 = load float, float* %2, align 4
  %2569 = fmul float %2567, %2568
  %2570 = load float, float* %2104, align 4
  %2571 = fadd float %2570, %2569
  store float %2571, float* %2104, align 4
  %2572 = getelementptr inbounds float, float* %2080, i64 1
  %2573 = load float, float* %2572, align 4
  %2574 = getelementptr inbounds float, float* %2, i64 4
  %2575 = load float, float* %2574, align 4
  %2576 = fmul float %2573, %2575
  %2577 = load float, float* %2104, align 4
  %2578 = fadd float %2577, %2576
  store float %2578, float* %2104, align 4
  %2579 = getelementptr inbounds float, float* %2080, i64 2
  %2580 = load float, float* %2579, align 4
  %2581 = getelementptr inbounds float, float* %2, i64 8
  %2582 = load float, float* %2581, align 4
  %2583 = fmul float %2580, %2582
  %2584 = load float, float* %2104, align 4
  %2585 = fadd float %2584, %2583
  store float %2585, float* %2104, align 4
  %2586 = getelementptr inbounds float, float* %2080, i64 3
  %2587 = load float, float* %2586, align 4
  %2588 = getelementptr inbounds float, float* %2, i64 12
  %2589 = load float, float* %2588, align 4
  %2590 = fmul float %2587, %2589
  %2591 = load float, float* %2104, align 4
  %2592 = fadd float %2591, %2590
  store float %2592, float* %2104, align 4
  %2593 = getelementptr inbounds float, float* %2104, i64 1
  store float 0.000000e+00, float* %2593, align 4
  %2594 = getelementptr inbounds float, float* %2104, i64 1
  %2595 = load float, float* %2080, align 4
  %2596 = getelementptr inbounds float, float* %2, i64 1
  %2597 = load float, float* %2596, align 4
  %2598 = fmul float %2595, %2597
  %2599 = load float, float* %2594, align 4
  %2600 = fadd float %2599, %2598
  store float %2600, float* %2594, align 4
  %2601 = getelementptr inbounds float, float* %2080, i64 1
  %2602 = load float, float* %2601, align 4
  %2603 = getelementptr inbounds float, float* %2, i64 5
  %2604 = load float, float* %2603, align 4
  %2605 = fmul float %2602, %2604
  %2606 = load float, float* %2594, align 4
  %2607 = fadd float %2606, %2605
  store float %2607, float* %2594, align 4
  %2608 = getelementptr inbounds float, float* %2080, i64 2
  %2609 = load float, float* %2608, align 4
  %2610 = getelementptr inbounds float, float* %2, i64 9
  %2611 = load float, float* %2610, align 4
  %2612 = fmul float %2609, %2611
  %2613 = load float, float* %2594, align 4
  %2614 = fadd float %2613, %2612
  store float %2614, float* %2594, align 4
  %2615 = getelementptr inbounds float, float* %2080, i64 3
  %2616 = load float, float* %2615, align 4
  %2617 = getelementptr inbounds float, float* %2, i64 13
  %2618 = load float, float* %2617, align 4
  %2619 = fmul float %2616, %2618
  %2620 = load float, float* %2594, align 4
  %2621 = fadd float %2620, %2619
  store float %2621, float* %2594, align 4
  %2622 = getelementptr inbounds float, float* %2104, i64 2
  store float 0.000000e+00, float* %2622, align 4
  %2623 = getelementptr inbounds float, float* %2104, i64 2
  %2624 = load float, float* %2080, align 4
  %2625 = getelementptr inbounds float, float* %2, i64 2
  %2626 = load float, float* %2625, align 4
  %2627 = fmul float %2624, %2626
  %2628 = load float, float* %2623, align 4
  %2629 = fadd float %2628, %2627
  store float %2629, float* %2623, align 4
  %2630 = getelementptr inbounds float, float* %2080, i64 1
  %2631 = load float, float* %2630, align 4
  %2632 = getelementptr inbounds float, float* %2, i64 6
  %2633 = load float, float* %2632, align 4
  %2634 = fmul float %2631, %2633
  %2635 = load float, float* %2623, align 4
  %2636 = fadd float %2635, %2634
  store float %2636, float* %2623, align 4
  %2637 = getelementptr inbounds float, float* %2080, i64 2
  %2638 = load float, float* %2637, align 4
  %2639 = getelementptr inbounds float, float* %2, i64 10
  %2640 = load float, float* %2639, align 4
  %2641 = fmul float %2638, %2640
  %2642 = load float, float* %2623, align 4
  %2643 = fadd float %2642, %2641
  store float %2643, float* %2623, align 4
  %2644 = getelementptr inbounds float, float* %2080, i64 3
  %2645 = load float, float* %2644, align 4
  %2646 = getelementptr inbounds float, float* %2, i64 14
  %2647 = load float, float* %2646, align 4
  %2648 = fmul float %2645, %2647
  %2649 = load float, float* %2623, align 4
  %2650 = fadd float %2649, %2648
  store float %2650, float* %2623, align 4
  %2651 = getelementptr inbounds float, float* %2104, i64 3
  store float 0.000000e+00, float* %2651, align 4
  %2652 = getelementptr inbounds float, float* %2104, i64 3
  %2653 = load float, float* %2080, align 4
  %2654 = getelementptr inbounds float, float* %2, i64 3
  %2655 = load float, float* %2654, align 4
  %2656 = fmul float %2653, %2655
  %2657 = load float, float* %2652, align 4
  %2658 = fadd float %2657, %2656
  store float %2658, float* %2652, align 4
  %2659 = getelementptr inbounds float, float* %2080, i64 1
  %2660 = load float, float* %2659, align 4
  %2661 = getelementptr inbounds float, float* %2, i64 7
  %2662 = load float, float* %2661, align 4
  %2663 = fmul float %2660, %2662
  %2664 = load float, float* %2652, align 4
  %2665 = fadd float %2664, %2663
  store float %2665, float* %2652, align 4
  %2666 = getelementptr inbounds float, float* %2080, i64 2
  %2667 = load float, float* %2666, align 4
  %2668 = getelementptr inbounds float, float* %2, i64 11
  %2669 = load float, float* %2668, align 4
  %2670 = fmul float %2667, %2669
  %2671 = load float, float* %2652, align 4
  %2672 = fadd float %2671, %2670
  store float %2672, float* %2652, align 4
  %2673 = getelementptr inbounds float, float* %2080, i64 3
  %2674 = load float, float* %2673, align 4
  %2675 = getelementptr inbounds float, float* %2, i64 15
  %2676 = load float, float* %2675, align 4
  %2677 = fmul float %2674, %2676
  %2678 = load float, float* %2652, align 4
  %2679 = fadd float %2678, %2677
  store float %2679, float* %2652, align 4
  %2680 = getelementptr inbounds float, float* %2080, i64 4
  %2681 = getelementptr inbounds float, float* %2104, i64 4
  store float 0.000000e+00, float* %2681, align 4
  %2682 = getelementptr inbounds float, float* %2104, i64 4
  %2683 = load float, float* %2680, align 4
  %2684 = load float, float* %2, align 4
  %2685 = fmul float %2683, %2684
  %2686 = load float, float* %2682, align 4
  %2687 = fadd float %2686, %2685
  store float %2687, float* %2682, align 4
  %2688 = getelementptr inbounds float, float* %2080, i64 5
  %2689 = load float, float* %2688, align 4
  %2690 = getelementptr inbounds float, float* %2, i64 4
  %2691 = load float, float* %2690, align 4
  %2692 = fmul float %2689, %2691
  %2693 = load float, float* %2682, align 4
  %2694 = fadd float %2693, %2692
  store float %2694, float* %2682, align 4
  %2695 = getelementptr inbounds float, float* %2080, i64 6
  %2696 = load float, float* %2695, align 4
  %2697 = getelementptr inbounds float, float* %2, i64 8
  %2698 = load float, float* %2697, align 4
  %2699 = fmul float %2696, %2698
  %2700 = load float, float* %2682, align 4
  %2701 = fadd float %2700, %2699
  store float %2701, float* %2682, align 4
  %2702 = getelementptr inbounds float, float* %2080, i64 7
  %2703 = load float, float* %2702, align 4
  %2704 = getelementptr inbounds float, float* %2, i64 12
  %2705 = load float, float* %2704, align 4
  %2706 = fmul float %2703, %2705
  %2707 = load float, float* %2682, align 4
  %2708 = fadd float %2707, %2706
  store float %2708, float* %2682, align 4
  %2709 = getelementptr inbounds float, float* %2104, i64 5
  store float 0.000000e+00, float* %2709, align 4
  %2710 = getelementptr inbounds float, float* %2104, i64 5
  %2711 = load float, float* %2680, align 4
  %2712 = getelementptr inbounds float, float* %2, i64 1
  %2713 = load float, float* %2712, align 4
  %2714 = fmul float %2711, %2713
  %2715 = load float, float* %2710, align 4
  %2716 = fadd float %2715, %2714
  store float %2716, float* %2710, align 4
  %2717 = getelementptr inbounds float, float* %2080, i64 5
  %2718 = load float, float* %2717, align 4
  %2719 = getelementptr inbounds float, float* %2, i64 5
  %2720 = load float, float* %2719, align 4
  %2721 = fmul float %2718, %2720
  %2722 = load float, float* %2710, align 4
  %2723 = fadd float %2722, %2721
  store float %2723, float* %2710, align 4
  %2724 = getelementptr inbounds float, float* %2080, i64 6
  %2725 = load float, float* %2724, align 4
  %2726 = getelementptr inbounds float, float* %2, i64 9
  %2727 = load float, float* %2726, align 4
  %2728 = fmul float %2725, %2727
  %2729 = load float, float* %2710, align 4
  %2730 = fadd float %2729, %2728
  store float %2730, float* %2710, align 4
  %2731 = getelementptr inbounds float, float* %2080, i64 7
  %2732 = load float, float* %2731, align 4
  %2733 = getelementptr inbounds float, float* %2, i64 13
  %2734 = load float, float* %2733, align 4
  %2735 = fmul float %2732, %2734
  %2736 = load float, float* %2710, align 4
  %2737 = fadd float %2736, %2735
  store float %2737, float* %2710, align 4
  %2738 = getelementptr inbounds float, float* %2104, i64 6
  store float 0.000000e+00, float* %2738, align 4
  %2739 = getelementptr inbounds float, float* %2104, i64 6
  %2740 = load float, float* %2680, align 4
  %2741 = getelementptr inbounds float, float* %2, i64 2
  %2742 = load float, float* %2741, align 4
  %2743 = fmul float %2740, %2742
  %2744 = load float, float* %2739, align 4
  %2745 = fadd float %2744, %2743
  store float %2745, float* %2739, align 4
  %2746 = getelementptr inbounds float, float* %2080, i64 5
  %2747 = load float, float* %2746, align 4
  %2748 = getelementptr inbounds float, float* %2, i64 6
  %2749 = load float, float* %2748, align 4
  %2750 = fmul float %2747, %2749
  %2751 = load float, float* %2739, align 4
  %2752 = fadd float %2751, %2750
  store float %2752, float* %2739, align 4
  %2753 = getelementptr inbounds float, float* %2080, i64 6
  %2754 = load float, float* %2753, align 4
  %2755 = getelementptr inbounds float, float* %2, i64 10
  %2756 = load float, float* %2755, align 4
  %2757 = fmul float %2754, %2756
  %2758 = load float, float* %2739, align 4
  %2759 = fadd float %2758, %2757
  store float %2759, float* %2739, align 4
  %2760 = getelementptr inbounds float, float* %2080, i64 7
  %2761 = load float, float* %2760, align 4
  %2762 = getelementptr inbounds float, float* %2, i64 14
  %2763 = load float, float* %2762, align 4
  %2764 = fmul float %2761, %2763
  %2765 = load float, float* %2739, align 4
  %2766 = fadd float %2765, %2764
  store float %2766, float* %2739, align 4
  %2767 = getelementptr inbounds float, float* %2104, i64 7
  store float 0.000000e+00, float* %2767, align 4
  %2768 = getelementptr inbounds float, float* %2104, i64 7
  %2769 = load float, float* %2680, align 4
  %2770 = getelementptr inbounds float, float* %2, i64 3
  %2771 = load float, float* %2770, align 4
  %2772 = fmul float %2769, %2771
  %2773 = load float, float* %2768, align 4
  %2774 = fadd float %2773, %2772
  store float %2774, float* %2768, align 4
  %2775 = getelementptr inbounds float, float* %2080, i64 5
  %2776 = load float, float* %2775, align 4
  %2777 = getelementptr inbounds float, float* %2, i64 7
  %2778 = load float, float* %2777, align 4
  %2779 = fmul float %2776, %2778
  %2780 = load float, float* %2768, align 4
  %2781 = fadd float %2780, %2779
  store float %2781, float* %2768, align 4
  %2782 = getelementptr inbounds float, float* %2080, i64 6
  %2783 = load float, float* %2782, align 4
  %2784 = getelementptr inbounds float, float* %2, i64 11
  %2785 = load float, float* %2784, align 4
  %2786 = fmul float %2783, %2785
  %2787 = load float, float* %2768, align 4
  %2788 = fadd float %2787, %2786
  store float %2788, float* %2768, align 4
  %2789 = getelementptr inbounds float, float* %2080, i64 7
  %2790 = load float, float* %2789, align 4
  %2791 = getelementptr inbounds float, float* %2, i64 15
  %2792 = load float, float* %2791, align 4
  %2793 = fmul float %2790, %2792
  %2794 = load float, float* %2768, align 4
  %2795 = fadd float %2794, %2793
  store float %2795, float* %2768, align 4
  %2796 = getelementptr inbounds float, float* %2080, i64 8
  %2797 = getelementptr inbounds float, float* %2104, i64 8
  store float 0.000000e+00, float* %2797, align 4
  %2798 = getelementptr inbounds float, float* %2104, i64 8
  %2799 = load float, float* %2796, align 4
  %2800 = load float, float* %2, align 4
  %2801 = fmul float %2799, %2800
  %2802 = load float, float* %2798, align 4
  %2803 = fadd float %2802, %2801
  store float %2803, float* %2798, align 4
  %2804 = getelementptr inbounds float, float* %2080, i64 9
  %2805 = load float, float* %2804, align 4
  %2806 = getelementptr inbounds float, float* %2, i64 4
  %2807 = load float, float* %2806, align 4
  %2808 = fmul float %2805, %2807
  %2809 = load float, float* %2798, align 4
  %2810 = fadd float %2809, %2808
  store float %2810, float* %2798, align 4
  %2811 = getelementptr inbounds float, float* %2080, i64 10
  %2812 = load float, float* %2811, align 4
  %2813 = getelementptr inbounds float, float* %2, i64 8
  %2814 = load float, float* %2813, align 4
  %2815 = fmul float %2812, %2814
  %2816 = load float, float* %2798, align 4
  %2817 = fadd float %2816, %2815
  store float %2817, float* %2798, align 4
  %2818 = getelementptr inbounds float, float* %2080, i64 11
  %2819 = load float, float* %2818, align 4
  %2820 = getelementptr inbounds float, float* %2, i64 12
  %2821 = load float, float* %2820, align 4
  %2822 = fmul float %2819, %2821
  %2823 = load float, float* %2798, align 4
  %2824 = fadd float %2823, %2822
  store float %2824, float* %2798, align 4
  %2825 = getelementptr inbounds float, float* %2104, i64 9
  store float 0.000000e+00, float* %2825, align 4
  %2826 = getelementptr inbounds float, float* %2104, i64 9
  %2827 = load float, float* %2796, align 4
  %2828 = getelementptr inbounds float, float* %2, i64 1
  %2829 = load float, float* %2828, align 4
  %2830 = fmul float %2827, %2829
  %2831 = load float, float* %2826, align 4
  %2832 = fadd float %2831, %2830
  store float %2832, float* %2826, align 4
  %2833 = getelementptr inbounds float, float* %2080, i64 9
  %2834 = load float, float* %2833, align 4
  %2835 = getelementptr inbounds float, float* %2, i64 5
  %2836 = load float, float* %2835, align 4
  %2837 = fmul float %2834, %2836
  %2838 = load float, float* %2826, align 4
  %2839 = fadd float %2838, %2837
  store float %2839, float* %2826, align 4
  %2840 = getelementptr inbounds float, float* %2080, i64 10
  %2841 = load float, float* %2840, align 4
  %2842 = getelementptr inbounds float, float* %2, i64 9
  %2843 = load float, float* %2842, align 4
  %2844 = fmul float %2841, %2843
  %2845 = load float, float* %2826, align 4
  %2846 = fadd float %2845, %2844
  store float %2846, float* %2826, align 4
  %2847 = getelementptr inbounds float, float* %2080, i64 11
  %2848 = load float, float* %2847, align 4
  %2849 = getelementptr inbounds float, float* %2, i64 13
  %2850 = load float, float* %2849, align 4
  %2851 = fmul float %2848, %2850
  %2852 = load float, float* %2826, align 4
  %2853 = fadd float %2852, %2851
  store float %2853, float* %2826, align 4
  %2854 = getelementptr inbounds float, float* %2104, i64 10
  store float 0.000000e+00, float* %2854, align 4
  %2855 = getelementptr inbounds float, float* %2104, i64 10
  %2856 = load float, float* %2796, align 4
  %2857 = getelementptr inbounds float, float* %2, i64 2
  %2858 = load float, float* %2857, align 4
  %2859 = fmul float %2856, %2858
  %2860 = load float, float* %2855, align 4
  %2861 = fadd float %2860, %2859
  store float %2861, float* %2855, align 4
  %2862 = getelementptr inbounds float, float* %2080, i64 9
  %2863 = load float, float* %2862, align 4
  %2864 = getelementptr inbounds float, float* %2, i64 6
  %2865 = load float, float* %2864, align 4
  %2866 = fmul float %2863, %2865
  %2867 = load float, float* %2855, align 4
  %2868 = fadd float %2867, %2866
  store float %2868, float* %2855, align 4
  %2869 = getelementptr inbounds float, float* %2080, i64 10
  %2870 = load float, float* %2869, align 4
  %2871 = getelementptr inbounds float, float* %2, i64 10
  %2872 = load float, float* %2871, align 4
  %2873 = fmul float %2870, %2872
  %2874 = load float, float* %2855, align 4
  %2875 = fadd float %2874, %2873
  store float %2875, float* %2855, align 4
  %2876 = getelementptr inbounds float, float* %2080, i64 11
  %2877 = load float, float* %2876, align 4
  %2878 = getelementptr inbounds float, float* %2, i64 14
  %2879 = load float, float* %2878, align 4
  %2880 = fmul float %2877, %2879
  %2881 = load float, float* %2855, align 4
  %2882 = fadd float %2881, %2880
  store float %2882, float* %2855, align 4
  %2883 = getelementptr inbounds float, float* %2104, i64 11
  store float 0.000000e+00, float* %2883, align 4
  %2884 = getelementptr inbounds float, float* %2104, i64 11
  %2885 = load float, float* %2796, align 4
  %2886 = getelementptr inbounds float, float* %2, i64 3
  %2887 = load float, float* %2886, align 4
  %2888 = fmul float %2885, %2887
  %2889 = load float, float* %2884, align 4
  %2890 = fadd float %2889, %2888
  store float %2890, float* %2884, align 4
  %2891 = getelementptr inbounds float, float* %2080, i64 9
  %2892 = load float, float* %2891, align 4
  %2893 = getelementptr inbounds float, float* %2, i64 7
  %2894 = load float, float* %2893, align 4
  %2895 = fmul float %2892, %2894
  %2896 = load float, float* %2884, align 4
  %2897 = fadd float %2896, %2895
  store float %2897, float* %2884, align 4
  %2898 = getelementptr inbounds float, float* %2080, i64 10
  %2899 = load float, float* %2898, align 4
  %2900 = getelementptr inbounds float, float* %2, i64 11
  %2901 = load float, float* %2900, align 4
  %2902 = fmul float %2899, %2901
  %2903 = load float, float* %2884, align 4
  %2904 = fadd float %2903, %2902
  store float %2904, float* %2884, align 4
  %2905 = getelementptr inbounds float, float* %2080, i64 11
  %2906 = load float, float* %2905, align 4
  %2907 = getelementptr inbounds float, float* %2, i64 15
  %2908 = load float, float* %2907, align 4
  %2909 = fmul float %2906, %2908
  %2910 = load float, float* %2884, align 4
  %2911 = fadd float %2910, %2909
  store float %2911, float* %2884, align 4
  %2912 = getelementptr inbounds float, float* %2080, i64 12
  %2913 = getelementptr inbounds float, float* %2104, i64 12
  store float 0.000000e+00, float* %2913, align 4
  %2914 = getelementptr inbounds float, float* %2104, i64 12
  %2915 = load float, float* %2912, align 4
  %2916 = load float, float* %2, align 4
  %2917 = fmul float %2915, %2916
  %2918 = load float, float* %2914, align 4
  %2919 = fadd float %2918, %2917
  store float %2919, float* %2914, align 4
  %2920 = getelementptr inbounds float, float* %2080, i64 13
  %2921 = load float, float* %2920, align 4
  %2922 = getelementptr inbounds float, float* %2, i64 4
  %2923 = load float, float* %2922, align 4
  %2924 = fmul float %2921, %2923
  %2925 = load float, float* %2914, align 4
  %2926 = fadd float %2925, %2924
  store float %2926, float* %2914, align 4
  %2927 = getelementptr inbounds float, float* %2080, i64 14
  %2928 = load float, float* %2927, align 4
  %2929 = getelementptr inbounds float, float* %2, i64 8
  %2930 = load float, float* %2929, align 4
  %2931 = fmul float %2928, %2930
  %2932 = load float, float* %2914, align 4
  %2933 = fadd float %2932, %2931
  store float %2933, float* %2914, align 4
  %2934 = getelementptr inbounds float, float* %2080, i64 15
  %2935 = load float, float* %2934, align 4
  %2936 = getelementptr inbounds float, float* %2, i64 12
  %2937 = load float, float* %2936, align 4
  %2938 = fmul float %2935, %2937
  %2939 = load float, float* %2914, align 4
  %2940 = fadd float %2939, %2938
  store float %2940, float* %2914, align 4
  %2941 = getelementptr inbounds float, float* %2104, i64 13
  store float 0.000000e+00, float* %2941, align 4
  %2942 = getelementptr inbounds float, float* %2104, i64 13
  %2943 = load float, float* %2912, align 4
  %2944 = getelementptr inbounds float, float* %2, i64 1
  %2945 = load float, float* %2944, align 4
  %2946 = fmul float %2943, %2945
  %2947 = load float, float* %2942, align 4
  %2948 = fadd float %2947, %2946
  store float %2948, float* %2942, align 4
  %2949 = getelementptr inbounds float, float* %2080, i64 13
  %2950 = load float, float* %2949, align 4
  %2951 = getelementptr inbounds float, float* %2, i64 5
  %2952 = load float, float* %2951, align 4
  %2953 = fmul float %2950, %2952
  %2954 = load float, float* %2942, align 4
  %2955 = fadd float %2954, %2953
  store float %2955, float* %2942, align 4
  %2956 = getelementptr inbounds float, float* %2080, i64 14
  %2957 = load float, float* %2956, align 4
  %2958 = getelementptr inbounds float, float* %2, i64 9
  %2959 = load float, float* %2958, align 4
  %2960 = fmul float %2957, %2959
  %2961 = load float, float* %2942, align 4
  %2962 = fadd float %2961, %2960
  store float %2962, float* %2942, align 4
  %2963 = getelementptr inbounds float, float* %2080, i64 15
  %2964 = load float, float* %2963, align 4
  %2965 = getelementptr inbounds float, float* %2, i64 13
  %2966 = load float, float* %2965, align 4
  %2967 = fmul float %2964, %2966
  %2968 = load float, float* %2942, align 4
  %2969 = fadd float %2968, %2967
  store float %2969, float* %2942, align 4
  %2970 = getelementptr inbounds float, float* %2104, i64 14
  store float 0.000000e+00, float* %2970, align 4
  %2971 = getelementptr inbounds float, float* %2104, i64 14
  %2972 = load float, float* %2912, align 4
  %2973 = getelementptr inbounds float, float* %2, i64 2
  %2974 = load float, float* %2973, align 4
  %2975 = fmul float %2972, %2974
  %2976 = load float, float* %2971, align 4
  %2977 = fadd float %2976, %2975
  store float %2977, float* %2971, align 4
  %2978 = getelementptr inbounds float, float* %2080, i64 13
  %2979 = load float, float* %2978, align 4
  %2980 = getelementptr inbounds float, float* %2, i64 6
  %2981 = load float, float* %2980, align 4
  %2982 = fmul float %2979, %2981
  %2983 = load float, float* %2971, align 4
  %2984 = fadd float %2983, %2982
  store float %2984, float* %2971, align 4
  %2985 = getelementptr inbounds float, float* %2080, i64 14
  %2986 = load float, float* %2985, align 4
  %2987 = getelementptr inbounds float, float* %2, i64 10
  %2988 = load float, float* %2987, align 4
  %2989 = fmul float %2986, %2988
  %2990 = load float, float* %2971, align 4
  %2991 = fadd float %2990, %2989
  store float %2991, float* %2971, align 4
  %2992 = getelementptr inbounds float, float* %2080, i64 15
  %2993 = load float, float* %2992, align 4
  %2994 = getelementptr inbounds float, float* %2, i64 14
  %2995 = load float, float* %2994, align 4
  %2996 = fmul float %2993, %2995
  %2997 = load float, float* %2971, align 4
  %2998 = fadd float %2997, %2996
  store float %2998, float* %2971, align 4
  %2999 = getelementptr inbounds float, float* %2104, i64 15
  store float 0.000000e+00, float* %2999, align 4
  %3000 = getelementptr inbounds float, float* %2104, i64 15
  %3001 = load float, float* %2912, align 4
  %3002 = getelementptr inbounds float, float* %2, i64 3
  %3003 = load float, float* %3002, align 4
  %3004 = fmul float %3001, %3003
  %3005 = load float, float* %3000, align 4
  %3006 = fadd float %3005, %3004
  store float %3006, float* %3000, align 4
  %3007 = getelementptr inbounds float, float* %2080, i64 13
  %3008 = load float, float* %3007, align 4
  %3009 = getelementptr inbounds float, float* %2, i64 7
  %3010 = load float, float* %3009, align 4
  %3011 = fmul float %3008, %3010
  %3012 = load float, float* %3000, align 4
  %3013 = fadd float %3012, %3011
  store float %3013, float* %3000, align 4
  %3014 = getelementptr inbounds float, float* %2080, i64 14
  %3015 = load float, float* %3014, align 4
  %3016 = getelementptr inbounds float, float* %2, i64 11
  %3017 = load float, float* %3016, align 4
  %3018 = fmul float %3015, %3017
  %3019 = load float, float* %3000, align 4
  %3020 = fadd float %3019, %3018
  store float %3020, float* %3000, align 4
  %3021 = getelementptr inbounds float, float* %2080, i64 15
  %3022 = load float, float* %3021, align 4
  %3023 = getelementptr inbounds float, float* %2, i64 15
  %3024 = load float, float* %3023, align 4
  %3025 = fmul float %3022, %3024
  %3026 = load float, float* %3000, align 4
  %3027 = fadd float %3026, %3025
  store float %3027, float* %3000, align 4
  %3028 = call i8* @__memcpy_chk(i8* %28, i8* %2103, i64 64, i64 %30) #8
  call void @free(i8* %1969)
  call void @free(i8* %1971)
  call void @free(i8* %2007)
  call void @free(i8* %2009)
  call void @free(i8* %2043)
  call void @free(i8* %2079)
  %3029 = getelementptr inbounds float, float* %1, i64 1
  %3030 = load float, float* %3029, align 4
  %3031 = getelementptr inbounds float, float* %1, i64 4
  %3032 = load float, float* %3031, align 4
  %3033 = getelementptr inbounds float, float* %1, i64 1
  store float %3032, float* %3033, align 4
  %3034 = getelementptr inbounds float, float* %1, i64 4
  store float %3030, float* %3034, align 4
  br label %3035

3035:                                             ; preds = %3035, %.preheader33
  %indvars.iv3437 = phi i64 [ 2, %.preheader33 ], [ %indvars.iv.next35.1, %3035 ]
  %3036 = add nuw nsw i64 0, %indvars.iv3437
  %3037 = getelementptr inbounds float, float* %1, i64 %3036
  %3038 = load float, float* %3037, align 4
  %3039 = mul nuw nsw i64 %indvars.iv3437, 4
  %3040 = getelementptr inbounds float, float* %1, i64 %3039
  %3041 = load float, float* %3040, align 4
  %3042 = add nuw nsw i64 0, %indvars.iv3437
  %3043 = getelementptr inbounds float, float* %1, i64 %3042
  store float %3041, float* %3043, align 4
  %3044 = mul nuw nsw i64 %indvars.iv3437, 4
  %3045 = getelementptr inbounds float, float* %1, i64 %3044
  store float %3038, float* %3045, align 4
  %indvars.iv.next35 = add nuw nsw i64 %indvars.iv3437, 1
  %3046 = add nuw nsw i64 0, %indvars.iv.next35
  %3047 = getelementptr inbounds float, float* %1, i64 %3046
  %3048 = load float, float* %3047, align 4
  %3049 = mul nuw nsw i64 %indvars.iv.next35, 4
  %3050 = getelementptr inbounds float, float* %1, i64 %3049
  %3051 = load float, float* %3050, align 4
  %3052 = add nuw nsw i64 0, %indvars.iv.next35
  %3053 = getelementptr inbounds float, float* %1, i64 %3052
  store float %3051, float* %3053, align 4
  %3054 = mul nuw nsw i64 %indvars.iv.next35, 4
  %3055 = getelementptr inbounds float, float* %1, i64 %3054
  store float %3048, float* %3055, align 4
  %indvars.iv.next35.1 = add nuw nsw i64 %indvars.iv.next35, 1
  %exitcond.1 = icmp ne i64 %indvars.iv.next35.1, 4
  br i1 %exitcond.1, label %3035, label %.lr.ph.new.1

.lr.ph.new.1:                                     ; preds = %3035, %.lr.ph.new.1
  %indvars.iv3437.1 = phi i64 [ %indvars.iv.next35.1.1, %.lr.ph.new.1 ], [ 2, %3035 ]
  %3056 = add nuw nsw i64 4, %indvars.iv3437.1
  %3057 = getelementptr inbounds float, float* %1, i64 %3056
  %3058 = load float, float* %3057, align 4
  %3059 = mul nuw nsw i64 %indvars.iv3437.1, 4
  %3060 = add nuw nsw i64 %3059, 1
  %3061 = getelementptr inbounds float, float* %1, i64 %3060
  %3062 = load float, float* %3061, align 4
  %3063 = add nuw nsw i64 4, %indvars.iv3437.1
  %3064 = getelementptr inbounds float, float* %1, i64 %3063
  store float %3062, float* %3064, align 4
  %3065 = mul nuw nsw i64 %indvars.iv3437.1, 4
  %3066 = add nuw nsw i64 %3065, 1
  %3067 = getelementptr inbounds float, float* %1, i64 %3066
  store float %3058, float* %3067, align 4
  %indvars.iv.next35.1149 = add nuw nsw i64 %indvars.iv3437.1, 1
  %3068 = add nuw nsw i64 4, %indvars.iv.next35.1149
  %3069 = getelementptr inbounds float, float* %1, i64 %3068
  %3070 = load float, float* %3069, align 4
  %3071 = mul nuw nsw i64 %indvars.iv.next35.1149, 4
  %3072 = add nuw nsw i64 %3071, 1
  %3073 = getelementptr inbounds float, float* %1, i64 %3072
  %3074 = load float, float* %3073, align 4
  %3075 = add nuw nsw i64 4, %indvars.iv.next35.1149
  %3076 = getelementptr inbounds float, float* %1, i64 %3075
  store float %3074, float* %3076, align 4
  %3077 = mul nuw nsw i64 %indvars.iv.next35.1149, 4
  %3078 = add nuw nsw i64 %3077, 1
  %3079 = getelementptr inbounds float, float* %1, i64 %3078
  store float %3070, float* %3079, align 4
  %indvars.iv.next35.1.1 = add nuw nsw i64 %indvars.iv.next35.1149, 1
  %exitcond.1.1 = icmp ne i64 %indvars.iv.next35.1.1, 4
  br i1 %exitcond.1.1, label %.lr.ph.new.1, label %.prol.preheader.2

.prol.preheader.2:                                ; preds = %.lr.ph.new.1
  %3080 = getelementptr inbounds float, float* %1, i64 11
  %3081 = load float, float* %3080, align 4
  %3082 = getelementptr inbounds float, float* %1, i64 14
  %3083 = load float, float* %3082, align 4
  %3084 = getelementptr inbounds float, float* %1, i64 11
  store float %3083, float* %3084, align 4
  %3085 = getelementptr inbounds float, float* %1, i64 14
  store float %3081, float* %3085, align 4
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
  %7 = getelementptr inbounds [16 x float], [16 x float]* %1, i64 0, i64 0
  %8 = getelementptr inbounds [16 x float], [16 x float]* %2, i64 0, i64 0
  %9 = getelementptr inbounds [16 x float], [16 x float]* %3, i64 0, i64 0
  call void @naive_fixed_qr_decomp(float* %7, float* %8, float* %9)
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
