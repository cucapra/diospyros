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
declare double @llvm.sqrt.f64(double) #1

; Function Attrs: alwaysinline nounwind ssp uwtable
define void @naive_fixed_transpose(float* %0) #0 {
.lr.ph:
  %1 = getelementptr inbounds float, float* %0, i64 1
  %2 = bitcast float* %1 to i32*
  %3 = load i32, i32* %2, align 4
  %4 = getelementptr inbounds float, float* %0, i64 4
  %5 = bitcast float* %4 to i32*
  %6 = load i32, i32* %5, align 4
  %7 = getelementptr inbounds float, float* %0, i64 1
  %8 = bitcast float* %7 to i32*
  store i32 %6, i32* %8, align 4
  %9 = getelementptr inbounds float, float* %0, i64 4
  %10 = bitcast float* %9 to i32*
  store i32 %3, i32* %10, align 4
  br label %11

11:                                               ; preds = %11, %.lr.ph
  %indvars.iv25 = phi i64 [ 2, %.lr.ph ], [ %indvars.iv.next3.1, %11 ]
  %12 = getelementptr inbounds float, float* %0, i64 %indvars.iv25
  %13 = bitcast float* %12 to i32*
  %14 = load i32, i32* %13, align 4
  %15 = shl nuw nsw i64 %indvars.iv25, 2
  %16 = getelementptr inbounds float, float* %0, i64 %15
  %17 = bitcast float* %16 to i32*
  %18 = load i32, i32* %17, align 4
  %19 = getelementptr inbounds float, float* %0, i64 %indvars.iv25
  %20 = bitcast float* %19 to i32*
  store i32 %18, i32* %20, align 4
  %21 = shl nuw nsw i64 %indvars.iv25, 2
  %22 = getelementptr inbounds float, float* %0, i64 %21
  %23 = bitcast float* %22 to i32*
  store i32 %14, i32* %23, align 4
  %indvars.iv.next3 = or i64 %indvars.iv25, 1
  %24 = getelementptr inbounds float, float* %0, i64 %indvars.iv.next3
  %25 = bitcast float* %24 to i32*
  %26 = load i32, i32* %25, align 4
  %27 = shl nuw nsw i64 %indvars.iv.next3, 2
  %28 = getelementptr inbounds float, float* %0, i64 %27
  %29 = bitcast float* %28 to i32*
  %30 = load i32, i32* %29, align 4
  %31 = getelementptr inbounds float, float* %0, i64 %indvars.iv.next3
  %32 = bitcast float* %31 to i32*
  store i32 %30, i32* %32, align 4
  %33 = shl nuw nsw i64 %indvars.iv.next3, 2
  %34 = getelementptr inbounds float, float* %0, i64 %33
  %35 = bitcast float* %34 to i32*
  store i32 %26, i32* %35, align 4
  %indvars.iv.next3.1 = add nuw nsw i64 %indvars.iv25, 2
  %exitcond.1.not = icmp eq i64 %indvars.iv.next3.1, 4
  br i1 %exitcond.1.not, label %.lr.ph.new.1, label %11

.lr.ph.new.1:                                     ; preds = %.lr.ph.new.1, %11
  %indvars.iv25.1 = phi i64 [ %indvars.iv.next3.1.1, %.lr.ph.new.1 ], [ 2, %11 ]
  %36 = add nuw nsw i64 %indvars.iv25.1, 4
  %37 = getelementptr inbounds float, float* %0, i64 %36
  %38 = bitcast float* %37 to i32*
  %39 = load i32, i32* %38, align 4
  %40 = shl nuw nsw i64 %indvars.iv25.1, 2
  %41 = or i64 %40, 1
  %42 = getelementptr inbounds float, float* %0, i64 %41
  %43 = bitcast float* %42 to i32*
  %44 = load i32, i32* %43, align 4
  %45 = add nuw nsw i64 %indvars.iv25.1, 4
  %46 = getelementptr inbounds float, float* %0, i64 %45
  %47 = bitcast float* %46 to i32*
  store i32 %44, i32* %47, align 4
  %48 = shl nuw nsw i64 %indvars.iv25.1, 2
  %49 = or i64 %48, 1
  %50 = getelementptr inbounds float, float* %0, i64 %49
  %51 = bitcast float* %50 to i32*
  store i32 %39, i32* %51, align 4
  %indvars.iv.next3.113 = or i64 %indvars.iv25.1, 1
  %52 = add nuw nsw i64 %indvars.iv25.1, 5
  %53 = getelementptr inbounds float, float* %0, i64 %52
  %54 = bitcast float* %53 to i32*
  %55 = load i32, i32* %54, align 4
  %56 = shl nuw nsw i64 %indvars.iv.next3.113, 2
  %57 = or i64 %56, 1
  %58 = getelementptr inbounds float, float* %0, i64 %57
  %59 = bitcast float* %58 to i32*
  %60 = load i32, i32* %59, align 4
  %61 = add nuw nsw i64 %indvars.iv25.1, 5
  %62 = getelementptr inbounds float, float* %0, i64 %61
  %63 = bitcast float* %62 to i32*
  store i32 %60, i32* %63, align 4
  %64 = shl nuw nsw i64 %indvars.iv.next3.113, 2
  %65 = or i64 %64, 1
  %66 = getelementptr inbounds float, float* %0, i64 %65
  %67 = bitcast float* %66 to i32*
  store i32 %55, i32* %67, align 4
  %indvars.iv.next3.1.1 = add nuw nsw i64 %indvars.iv25.1, 2
  %exitcond.1.1.not = icmp eq i64 %indvars.iv.next3.1.1, 4
  br i1 %exitcond.1.1.not, label %.prol.preheader.2, label %.lr.ph.new.1

.prol.preheader.2:                                ; preds = %.lr.ph.new.1
  %68 = getelementptr inbounds float, float* %0, i64 11
  %69 = bitcast float* %68 to i32*
  %70 = load i32, i32* %69, align 4
  %71 = getelementptr inbounds float, float* %0, i64 14
  %72 = bitcast float* %71 to i32*
  %73 = load i32, i32* %72, align 4
  %74 = getelementptr inbounds float, float* %0, i64 11
  %75 = bitcast float* %74 to i32*
  store i32 %73, i32* %75, align 4
  %76 = getelementptr inbounds float, float* %0, i64 14
  %77 = bitcast float* %76 to i32*
  store i32 %70, i32* %77, align 4
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
  %26 = getelementptr inbounds float, float* %2, i64 1
  %27 = load float, float* %0, align 4
  %28 = getelementptr inbounds float, float* %1, i64 1
  %29 = load float, float* %28, align 4
  %30 = fmul float %27, %29
  %31 = fadd float %30, 0.000000e+00
  store float %31, float* %26, align 4
  %32 = getelementptr inbounds float, float* %0, i64 1
  %33 = load float, float* %32, align 4
  %34 = getelementptr inbounds float, float* %1, i64 5
  %35 = load float, float* %34, align 4
  %36 = fmul float %33, %35
  %37 = fadd float %31, %36
  store float %37, float* %26, align 4
  %38 = getelementptr inbounds float, float* %0, i64 2
  %39 = load float, float* %38, align 4
  %40 = getelementptr inbounds float, float* %1, i64 9
  %41 = load float, float* %40, align 4
  %42 = fmul float %39, %41
  %43 = fadd float %37, %42
  store float %43, float* %26, align 4
  %44 = getelementptr inbounds float, float* %0, i64 3
  %45 = load float, float* %44, align 4
  %46 = getelementptr inbounds float, float* %1, i64 13
  %47 = load float, float* %46, align 4
  %48 = fmul float %45, %47
  %49 = fadd float %43, %48
  store float %49, float* %26, align 4
  %50 = getelementptr inbounds float, float* %2, i64 2
  store float 0.000000e+00, float* %50, align 4
  %51 = getelementptr inbounds float, float* %2, i64 2
  %52 = load float, float* %0, align 4
  %53 = getelementptr inbounds float, float* %1, i64 2
  %54 = load float, float* %53, align 4
  %55 = fmul float %52, %54
  %56 = fadd float %55, 0.000000e+00
  store float %56, float* %51, align 4
  %57 = getelementptr inbounds float, float* %0, i64 1
  %58 = load float, float* %57, align 4
  %59 = getelementptr inbounds float, float* %1, i64 6
  %60 = load float, float* %59, align 4
  %61 = fmul float %58, %60
  %62 = fadd float %56, %61
  store float %62, float* %51, align 4
  %63 = getelementptr inbounds float, float* %0, i64 2
  %64 = load float, float* %63, align 4
  %65 = getelementptr inbounds float, float* %1, i64 10
  %66 = load float, float* %65, align 4
  %67 = fmul float %64, %66
  %68 = fadd float %62, %67
  store float %68, float* %51, align 4
  %69 = getelementptr inbounds float, float* %0, i64 3
  %70 = load float, float* %69, align 4
  %71 = getelementptr inbounds float, float* %1, i64 14
  %72 = load float, float* %71, align 4
  %73 = fmul float %70, %72
  %74 = fadd float %68, %73
  store float %74, float* %51, align 4
  %75 = getelementptr inbounds float, float* %2, i64 3
  store float 0.000000e+00, float* %75, align 4
  %76 = getelementptr inbounds float, float* %2, i64 3
  %77 = load float, float* %0, align 4
  %78 = getelementptr inbounds float, float* %1, i64 3
  %79 = load float, float* %78, align 4
  %80 = fmul float %77, %79
  %81 = fadd float %80, 0.000000e+00
  store float %81, float* %76, align 4
  %82 = getelementptr inbounds float, float* %0, i64 1
  %83 = load float, float* %82, align 4
  %84 = getelementptr inbounds float, float* %1, i64 7
  %85 = load float, float* %84, align 4
  %86 = fmul float %83, %85
  %87 = fadd float %81, %86
  store float %87, float* %76, align 4
  %88 = getelementptr inbounds float, float* %0, i64 2
  %89 = load float, float* %88, align 4
  %90 = getelementptr inbounds float, float* %1, i64 11
  %91 = load float, float* %90, align 4
  %92 = fmul float %89, %91
  %93 = fadd float %87, %92
  store float %93, float* %76, align 4
  %94 = getelementptr inbounds float, float* %0, i64 3
  %95 = load float, float* %94, align 4
  %96 = getelementptr inbounds float, float* %1, i64 15
  %97 = load float, float* %96, align 4
  %98 = fmul float %95, %97
  %99 = fadd float %93, %98
  store float %99, float* %76, align 4
  %100 = getelementptr inbounds float, float* %0, i64 4
  %101 = getelementptr inbounds float, float* %2, i64 4
  store float 0.000000e+00, float* %101, align 4
  %102 = getelementptr inbounds float, float* %2, i64 4
  %103 = load float, float* %100, align 4
  %104 = load float, float* %1, align 4
  %105 = fmul float %103, %104
  %106 = fadd float %105, 0.000000e+00
  store float %106, float* %102, align 4
  %107 = getelementptr inbounds float, float* %0, i64 5
  %108 = load float, float* %107, align 4
  %109 = getelementptr inbounds float, float* %1, i64 4
  %110 = load float, float* %109, align 4
  %111 = fmul float %108, %110
  %112 = fadd float %106, %111
  store float %112, float* %102, align 4
  %113 = getelementptr inbounds float, float* %0, i64 6
  %114 = load float, float* %113, align 4
  %115 = getelementptr inbounds float, float* %1, i64 8
  %116 = load float, float* %115, align 4
  %117 = fmul float %114, %116
  %118 = fadd float %112, %117
  store float %118, float* %102, align 4
  %119 = getelementptr inbounds float, float* %0, i64 7
  %120 = load float, float* %119, align 4
  %121 = getelementptr inbounds float, float* %1, i64 12
  %122 = load float, float* %121, align 4
  %123 = fmul float %120, %122
  %124 = fadd float %118, %123
  store float %124, float* %102, align 4
  %125 = getelementptr inbounds float, float* %2, i64 5
  store float 0.000000e+00, float* %125, align 4
  %126 = getelementptr inbounds float, float* %2, i64 5
  %127 = load float, float* %100, align 4
  %128 = getelementptr inbounds float, float* %1, i64 1
  %129 = load float, float* %128, align 4
  %130 = fmul float %127, %129
  %131 = fadd float %130, 0.000000e+00
  store float %131, float* %126, align 4
  %132 = getelementptr inbounds float, float* %0, i64 5
  %133 = load float, float* %132, align 4
  %134 = getelementptr inbounds float, float* %1, i64 5
  %135 = load float, float* %134, align 4
  %136 = fmul float %133, %135
  %137 = fadd float %131, %136
  store float %137, float* %126, align 4
  %138 = getelementptr inbounds float, float* %0, i64 6
  %139 = load float, float* %138, align 4
  %140 = getelementptr inbounds float, float* %1, i64 9
  %141 = load float, float* %140, align 4
  %142 = fmul float %139, %141
  %143 = fadd float %137, %142
  store float %143, float* %126, align 4
  %144 = getelementptr inbounds float, float* %0, i64 7
  %145 = load float, float* %144, align 4
  %146 = getelementptr inbounds float, float* %1, i64 13
  %147 = load float, float* %146, align 4
  %148 = fmul float %145, %147
  %149 = fadd float %143, %148
  store float %149, float* %126, align 4
  %150 = getelementptr inbounds float, float* %2, i64 6
  store float 0.000000e+00, float* %150, align 4
  %151 = getelementptr inbounds float, float* %2, i64 6
  %152 = load float, float* %100, align 4
  %153 = getelementptr inbounds float, float* %1, i64 2
  %154 = load float, float* %153, align 4
  %155 = fmul float %152, %154
  %156 = fadd float %155, 0.000000e+00
  store float %156, float* %151, align 4
  %157 = getelementptr inbounds float, float* %0, i64 5
  %158 = load float, float* %157, align 4
  %159 = getelementptr inbounds float, float* %1, i64 6
  %160 = load float, float* %159, align 4
  %161 = fmul float %158, %160
  %162 = fadd float %156, %161
  store float %162, float* %151, align 4
  %163 = getelementptr inbounds float, float* %0, i64 6
  %164 = load float, float* %163, align 4
  %165 = getelementptr inbounds float, float* %1, i64 10
  %166 = load float, float* %165, align 4
  %167 = fmul float %164, %166
  %168 = fadd float %162, %167
  store float %168, float* %151, align 4
  %169 = getelementptr inbounds float, float* %0, i64 7
  %170 = load float, float* %169, align 4
  %171 = getelementptr inbounds float, float* %1, i64 14
  %172 = load float, float* %171, align 4
  %173 = fmul float %170, %172
  %174 = fadd float %168, %173
  store float %174, float* %151, align 4
  %175 = getelementptr inbounds float, float* %2, i64 7
  store float 0.000000e+00, float* %175, align 4
  %176 = getelementptr inbounds float, float* %2, i64 7
  %177 = load float, float* %100, align 4
  %178 = getelementptr inbounds float, float* %1, i64 3
  %179 = load float, float* %178, align 4
  %180 = fmul float %177, %179
  %181 = fadd float %180, 0.000000e+00
  store float %181, float* %176, align 4
  %182 = getelementptr inbounds float, float* %0, i64 5
  %183 = load float, float* %182, align 4
  %184 = getelementptr inbounds float, float* %1, i64 7
  %185 = load float, float* %184, align 4
  %186 = fmul float %183, %185
  %187 = fadd float %181, %186
  store float %187, float* %176, align 4
  %188 = getelementptr inbounds float, float* %0, i64 6
  %189 = load float, float* %188, align 4
  %190 = getelementptr inbounds float, float* %1, i64 11
  %191 = load float, float* %190, align 4
  %192 = fmul float %189, %191
  %193 = fadd float %187, %192
  store float %193, float* %176, align 4
  %194 = getelementptr inbounds float, float* %0, i64 7
  %195 = load float, float* %194, align 4
  %196 = getelementptr inbounds float, float* %1, i64 15
  %197 = load float, float* %196, align 4
  %198 = fmul float %195, %197
  %199 = fadd float %193, %198
  store float %199, float* %176, align 4
  %200 = getelementptr inbounds float, float* %0, i64 8
  %201 = getelementptr inbounds float, float* %2, i64 8
  store float 0.000000e+00, float* %201, align 4
  %202 = getelementptr inbounds float, float* %2, i64 8
  %203 = load float, float* %200, align 4
  %204 = load float, float* %1, align 4
  %205 = fmul float %203, %204
  %206 = fadd float %205, 0.000000e+00
  store float %206, float* %202, align 4
  %207 = getelementptr inbounds float, float* %0, i64 9
  %208 = load float, float* %207, align 4
  %209 = getelementptr inbounds float, float* %1, i64 4
  %210 = load float, float* %209, align 4
  %211 = fmul float %208, %210
  %212 = fadd float %206, %211
  store float %212, float* %202, align 4
  %213 = getelementptr inbounds float, float* %0, i64 10
  %214 = load float, float* %213, align 4
  %215 = getelementptr inbounds float, float* %1, i64 8
  %216 = load float, float* %215, align 4
  %217 = fmul float %214, %216
  %218 = fadd float %212, %217
  store float %218, float* %202, align 4
  %219 = getelementptr inbounds float, float* %0, i64 11
  %220 = load float, float* %219, align 4
  %221 = getelementptr inbounds float, float* %1, i64 12
  %222 = load float, float* %221, align 4
  %223 = fmul float %220, %222
  %224 = fadd float %218, %223
  store float %224, float* %202, align 4
  %225 = getelementptr inbounds float, float* %2, i64 9
  store float 0.000000e+00, float* %225, align 4
  %226 = getelementptr inbounds float, float* %2, i64 9
  %227 = load float, float* %200, align 4
  %228 = getelementptr inbounds float, float* %1, i64 1
  %229 = load float, float* %228, align 4
  %230 = fmul float %227, %229
  %231 = fadd float %230, 0.000000e+00
  store float %231, float* %226, align 4
  %232 = getelementptr inbounds float, float* %0, i64 9
  %233 = load float, float* %232, align 4
  %234 = getelementptr inbounds float, float* %1, i64 5
  %235 = load float, float* %234, align 4
  %236 = fmul float %233, %235
  %237 = fadd float %231, %236
  store float %237, float* %226, align 4
  %238 = getelementptr inbounds float, float* %0, i64 10
  %239 = load float, float* %238, align 4
  %240 = getelementptr inbounds float, float* %1, i64 9
  %241 = load float, float* %240, align 4
  %242 = fmul float %239, %241
  %243 = fadd float %237, %242
  store float %243, float* %226, align 4
  %244 = getelementptr inbounds float, float* %0, i64 11
  %245 = load float, float* %244, align 4
  %246 = getelementptr inbounds float, float* %1, i64 13
  %247 = load float, float* %246, align 4
  %248 = fmul float %245, %247
  %249 = fadd float %243, %248
  store float %249, float* %226, align 4
  %250 = getelementptr inbounds float, float* %2, i64 10
  store float 0.000000e+00, float* %250, align 4
  %251 = getelementptr inbounds float, float* %2, i64 10
  %252 = load float, float* %200, align 4
  %253 = getelementptr inbounds float, float* %1, i64 2
  %254 = load float, float* %253, align 4
  %255 = fmul float %252, %254
  %256 = fadd float %255, 0.000000e+00
  store float %256, float* %251, align 4
  %257 = getelementptr inbounds float, float* %0, i64 9
  %258 = load float, float* %257, align 4
  %259 = getelementptr inbounds float, float* %1, i64 6
  %260 = load float, float* %259, align 4
  %261 = fmul float %258, %260
  %262 = fadd float %256, %261
  store float %262, float* %251, align 4
  %263 = getelementptr inbounds float, float* %0, i64 10
  %264 = load float, float* %263, align 4
  %265 = getelementptr inbounds float, float* %1, i64 10
  %266 = load float, float* %265, align 4
  %267 = fmul float %264, %266
  %268 = fadd float %262, %267
  store float %268, float* %251, align 4
  %269 = getelementptr inbounds float, float* %0, i64 11
  %270 = load float, float* %269, align 4
  %271 = getelementptr inbounds float, float* %1, i64 14
  %272 = load float, float* %271, align 4
  %273 = fmul float %270, %272
  %274 = fadd float %268, %273
  store float %274, float* %251, align 4
  %275 = getelementptr inbounds float, float* %2, i64 11
  store float 0.000000e+00, float* %275, align 4
  %276 = getelementptr inbounds float, float* %2, i64 11
  %277 = load float, float* %200, align 4
  %278 = getelementptr inbounds float, float* %1, i64 3
  %279 = load float, float* %278, align 4
  %280 = fmul float %277, %279
  %281 = fadd float %280, 0.000000e+00
  store float %281, float* %276, align 4
  %282 = getelementptr inbounds float, float* %0, i64 9
  %283 = load float, float* %282, align 4
  %284 = getelementptr inbounds float, float* %1, i64 7
  %285 = load float, float* %284, align 4
  %286 = fmul float %283, %285
  %287 = fadd float %281, %286
  store float %287, float* %276, align 4
  %288 = getelementptr inbounds float, float* %0, i64 10
  %289 = load float, float* %288, align 4
  %290 = getelementptr inbounds float, float* %1, i64 11
  %291 = load float, float* %290, align 4
  %292 = fmul float %289, %291
  %293 = fadd float %287, %292
  store float %293, float* %276, align 4
  %294 = getelementptr inbounds float, float* %0, i64 11
  %295 = load float, float* %294, align 4
  %296 = getelementptr inbounds float, float* %1, i64 15
  %297 = load float, float* %296, align 4
  %298 = fmul float %295, %297
  %299 = fadd float %293, %298
  store float %299, float* %276, align 4
  %300 = getelementptr inbounds float, float* %0, i64 12
  %301 = getelementptr inbounds float, float* %2, i64 12
  store float 0.000000e+00, float* %301, align 4
  %302 = getelementptr inbounds float, float* %2, i64 12
  %303 = load float, float* %300, align 4
  %304 = load float, float* %1, align 4
  %305 = fmul float %303, %304
  %306 = fadd float %305, 0.000000e+00
  store float %306, float* %302, align 4
  %307 = getelementptr inbounds float, float* %0, i64 13
  %308 = load float, float* %307, align 4
  %309 = getelementptr inbounds float, float* %1, i64 4
  %310 = load float, float* %309, align 4
  %311 = fmul float %308, %310
  %312 = fadd float %306, %311
  store float %312, float* %302, align 4
  %313 = getelementptr inbounds float, float* %0, i64 14
  %314 = load float, float* %313, align 4
  %315 = getelementptr inbounds float, float* %1, i64 8
  %316 = load float, float* %315, align 4
  %317 = fmul float %314, %316
  %318 = fadd float %312, %317
  store float %318, float* %302, align 4
  %319 = getelementptr inbounds float, float* %0, i64 15
  %320 = load float, float* %319, align 4
  %321 = getelementptr inbounds float, float* %1, i64 12
  %322 = load float, float* %321, align 4
  %323 = fmul float %320, %322
  %324 = fadd float %318, %323
  store float %324, float* %302, align 4
  %325 = getelementptr inbounds float, float* %2, i64 13
  store float 0.000000e+00, float* %325, align 4
  %326 = getelementptr inbounds float, float* %2, i64 13
  %327 = load float, float* %300, align 4
  %328 = getelementptr inbounds float, float* %1, i64 1
  %329 = load float, float* %328, align 4
  %330 = fmul float %327, %329
  %331 = fadd float %330, 0.000000e+00
  store float %331, float* %326, align 4
  %332 = getelementptr inbounds float, float* %0, i64 13
  %333 = load float, float* %332, align 4
  %334 = getelementptr inbounds float, float* %1, i64 5
  %335 = load float, float* %334, align 4
  %336 = fmul float %333, %335
  %337 = fadd float %331, %336
  store float %337, float* %326, align 4
  %338 = getelementptr inbounds float, float* %0, i64 14
  %339 = load float, float* %338, align 4
  %340 = getelementptr inbounds float, float* %1, i64 9
  %341 = load float, float* %340, align 4
  %342 = fmul float %339, %341
  %343 = fadd float %337, %342
  store float %343, float* %326, align 4
  %344 = getelementptr inbounds float, float* %0, i64 15
  %345 = load float, float* %344, align 4
  %346 = getelementptr inbounds float, float* %1, i64 13
  %347 = load float, float* %346, align 4
  %348 = fmul float %345, %347
  %349 = fadd float %343, %348
  store float %349, float* %326, align 4
  %350 = getelementptr inbounds float, float* %2, i64 14
  store float 0.000000e+00, float* %350, align 4
  %351 = getelementptr inbounds float, float* %2, i64 14
  %352 = load float, float* %300, align 4
  %353 = getelementptr inbounds float, float* %1, i64 2
  %354 = load float, float* %353, align 4
  %355 = fmul float %352, %354
  %356 = fadd float %355, 0.000000e+00
  store float %356, float* %351, align 4
  %357 = getelementptr inbounds float, float* %0, i64 13
  %358 = load float, float* %357, align 4
  %359 = getelementptr inbounds float, float* %1, i64 6
  %360 = load float, float* %359, align 4
  %361 = fmul float %358, %360
  %362 = fadd float %356, %361
  store float %362, float* %351, align 4
  %363 = getelementptr inbounds float, float* %0, i64 14
  %364 = load float, float* %363, align 4
  %365 = getelementptr inbounds float, float* %1, i64 10
  %366 = load float, float* %365, align 4
  %367 = fmul float %364, %366
  %368 = fadd float %362, %367
  store float %368, float* %351, align 4
  %369 = getelementptr inbounds float, float* %0, i64 15
  %370 = load float, float* %369, align 4
  %371 = getelementptr inbounds float, float* %1, i64 14
  %372 = load float, float* %371, align 4
  %373 = fmul float %370, %372
  %374 = fadd float %368, %373
  store float %374, float* %351, align 4
  %375 = getelementptr inbounds float, float* %2, i64 15
  store float 0.000000e+00, float* %375, align 4
  %376 = getelementptr inbounds float, float* %2, i64 15
  %377 = load float, float* %300, align 4
  %378 = getelementptr inbounds float, float* %1, i64 3
  %379 = load float, float* %378, align 4
  %380 = fmul float %377, %379
  %381 = fadd float %380, 0.000000e+00
  store float %381, float* %376, align 4
  %382 = getelementptr inbounds float, float* %0, i64 13
  %383 = load float, float* %382, align 4
  %384 = getelementptr inbounds float, float* %1, i64 7
  %385 = load float, float* %384, align 4
  %386 = fmul float %383, %385
  %387 = fadd float %381, %386
  store float %387, float* %376, align 4
  %388 = getelementptr inbounds float, float* %0, i64 14
  %389 = load float, float* %388, align 4
  %390 = getelementptr inbounds float, float* %1, i64 11
  %391 = load float, float* %390, align 4
  %392 = fmul float %389, %391
  %393 = fadd float %387, %392
  store float %393, float* %376, align 4
  %394 = getelementptr inbounds float, float* %0, i64 15
  %395 = load float, float* %394, align 4
  %396 = getelementptr inbounds float, float* %1, i64 15
  %397 = load float, float* %396, align 4
  %398 = fmul float %395, %397
  %399 = fadd float %393, %398
  store float %399, float* %376, align 4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define void @naive_fixed_qr_decomp(float* %0, float* %1, float* %2) #2 {
.preheader26:
  %3 = bitcast float* %2 to i8*
  %4 = bitcast float* %0 to i8*
  %5 = bitcast float* %2 to i8*
  %6 = call i64 @llvm.objectsize.i64.p0i8(i8* %5, i1 false, i1 true, i1 false)
  %7 = call i8* @__memcpy_chk(i8* %3, i8* %4, i64 64, i64 %6) #7
  %8 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #8
  %9 = bitcast i8* %8 to float*
  store float 1.000000e+00, float* %9, align 4
  %10 = getelementptr inbounds i8, i8* %8, i64 4
  %11 = bitcast i8* %10 to float*
  store float 0.000000e+00, float* %11, align 4
  %12 = getelementptr inbounds i8, i8* %8, i64 8
  %13 = bitcast i8* %12 to float*
  store float 0.000000e+00, float* %13, align 4
  %14 = getelementptr inbounds i8, i8* %8, i64 12
  %15 = bitcast i8* %14 to float*
  store float 0.000000e+00, float* %15, align 4
  %16 = getelementptr inbounds i8, i8* %8, i64 16
  %17 = bitcast i8* %16 to float*
  store float 0.000000e+00, float* %17, align 4
  %18 = getelementptr inbounds i8, i8* %8, i64 20
  %19 = bitcast i8* %18 to float*
  store float 1.000000e+00, float* %19, align 4
  %20 = getelementptr inbounds i8, i8* %8, i64 24
  %21 = bitcast i8* %20 to float*
  store float 0.000000e+00, float* %21, align 4
  %22 = getelementptr inbounds i8, i8* %8, i64 28
  %23 = bitcast i8* %22 to float*
  store float 0.000000e+00, float* %23, align 4
  %24 = getelementptr inbounds i8, i8* %8, i64 32
  %25 = bitcast i8* %24 to float*
  store float 0.000000e+00, float* %25, align 4
  %26 = getelementptr inbounds i8, i8* %8, i64 36
  %27 = bitcast i8* %26 to float*
  store float 0.000000e+00, float* %27, align 4
  %28 = getelementptr inbounds i8, i8* %8, i64 40
  %29 = bitcast i8* %28 to float*
  store float 1.000000e+00, float* %29, align 4
  %30 = getelementptr inbounds i8, i8* %8, i64 44
  %31 = bitcast i8* %30 to float*
  store float 0.000000e+00, float* %31, align 4
  %32 = getelementptr inbounds i8, i8* %8, i64 48
  %33 = bitcast i8* %32 to float*
  store float 0.000000e+00, float* %33, align 4
  %34 = getelementptr inbounds i8, i8* %8, i64 52
  %35 = bitcast i8* %34 to float*
  store float 0.000000e+00, float* %35, align 4
  %36 = getelementptr inbounds i8, i8* %8, i64 56
  %37 = bitcast i8* %36 to float*
  store float 0.000000e+00, float* %37, align 4
  %38 = getelementptr inbounds i8, i8* %8, i64 60
  %39 = bitcast i8* %38 to float*
  store float 1.000000e+00, float* %39, align 4
  %40 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #8
  %41 = bitcast i8* %40 to float*
  %42 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #8
  %43 = bitcast i8* %42 to float*
  %44 = bitcast float* %2 to i32*
  %45 = load i32, i32* %44, align 4
  %46 = bitcast i8* %40 to i32*
  store i32 %45, i32* %46, align 4
  %47 = bitcast i8* %8 to i32*
  %48 = load i32, i32* %47, align 4
  %49 = bitcast i8* %42 to i32*
  store i32 %48, i32* %49, align 4
  %50 = getelementptr inbounds float, float* %2, i64 4
  %51 = bitcast float* %50 to i32*
  %52 = load i32, i32* %51, align 4
  %53 = getelementptr inbounds i8, i8* %40, i64 4
  %54 = bitcast i8* %53 to i32*
  store i32 %52, i32* %54, align 4
  %55 = getelementptr inbounds i8, i8* %8, i64 16
  %56 = bitcast i8* %55 to i32*
  %57 = load i32, i32* %56, align 4
  %58 = getelementptr inbounds i8, i8* %42, i64 4
  %59 = bitcast i8* %58 to i32*
  store i32 %57, i32* %59, align 4
  %60 = getelementptr inbounds float, float* %2, i64 8
  %61 = bitcast float* %60 to i32*
  %62 = load i32, i32* %61, align 4
  %63 = getelementptr inbounds i8, i8* %40, i64 8
  %64 = bitcast i8* %63 to i32*
  store i32 %62, i32* %64, align 4
  %65 = getelementptr inbounds i8, i8* %8, i64 32
  %66 = bitcast i8* %65 to i32*
  %67 = load i32, i32* %66, align 4
  %68 = getelementptr inbounds i8, i8* %42, i64 8
  %69 = bitcast i8* %68 to i32*
  store i32 %67, i32* %69, align 4
  %70 = getelementptr inbounds float, float* %2, i64 12
  %71 = bitcast float* %70 to i32*
  %72 = load i32, i32* %71, align 4
  %73 = getelementptr inbounds i8, i8* %40, i64 12
  %74 = bitcast i8* %73 to i32*
  store i32 %72, i32* %74, align 4
  %75 = getelementptr inbounds i8, i8* %8, i64 48
  %76 = bitcast i8* %75 to i32*
  %77 = load i32, i32* %76, align 4
  %78 = getelementptr inbounds i8, i8* %42, i64 12
  %79 = bitcast i8* %78 to i32*
  store i32 %77, i32* %79, align 4
  %80 = load float, float* %41, align 4
  %81 = fcmp ogt float %80, 0.000000e+00
  %82 = zext i1 %81 to i32
  %83 = fcmp olt float %80, 0.000000e+00
  %.neg = sext i1 %83 to i32
  %84 = add nsw i32 %.neg, %82
  %85 = sitofp i32 %84 to float
  %86 = load float, float* %41, align 4
  %87 = fpext float %86 to double
  %square = fmul double %87, %87
  %88 = fadd double %square, 0.000000e+00
  %89 = fptrunc double %88 to float
  %90 = getelementptr inbounds i8, i8* %40, i64 4
  %91 = bitcast i8* %90 to float*
  %92 = load float, float* %91, align 4
  %93 = fpext float %92 to double
  %square173 = fmul double %93, %93
  %94 = fpext float %89 to double
  %95 = fadd double %square173, %94
  %96 = fptrunc double %95 to float
  %97 = getelementptr inbounds i8, i8* %40, i64 8
  %98 = bitcast i8* %97 to float*
  %99 = load float, float* %98, align 4
  %100 = fpext float %99 to double
  %square174 = fmul double %100, %100
  %101 = fpext float %96 to double
  %102 = fadd double %square174, %101
  %103 = fptrunc double %102 to float
  %104 = getelementptr inbounds i8, i8* %40, i64 12
  %105 = bitcast i8* %104 to float*
  %106 = load float, float* %105, align 4
  %107 = fpext float %106 to double
  %square175 = fmul double %107, %107
  %108 = fpext float %103 to double
  %109 = fadd double %square175, %108
  %110 = fptrunc double %109 to float
  %111 = fneg float %85
  %112 = call float @llvm.sqrt.f32(float %110)
  %113 = fmul float %112, %111
  %114 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #8
  %115 = bitcast i8* %114 to float*
  %116 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #8
  %117 = load float, float* %41, align 4
  %118 = load float, float* %43, align 4
  %119 = fmul float %113, %118
  %120 = fadd float %117, %119
  store float %120, float* %115, align 4
  %121 = getelementptr inbounds i8, i8* %40, i64 4
  %122 = bitcast i8* %121 to float*
  %123 = load float, float* %122, align 4
  %124 = getelementptr inbounds i8, i8* %42, i64 4
  %125 = bitcast i8* %124 to float*
  %126 = load float, float* %125, align 4
  %127 = fmul float %113, %126
  %128 = fadd float %123, %127
  %129 = getelementptr inbounds i8, i8* %114, i64 4
  %130 = bitcast i8* %129 to float*
  store float %128, float* %130, align 4
  %131 = getelementptr inbounds i8, i8* %40, i64 8
  %132 = bitcast i8* %131 to float*
  %133 = load float, float* %132, align 4
  %134 = getelementptr inbounds i8, i8* %42, i64 8
  %135 = bitcast i8* %134 to float*
  %136 = load float, float* %135, align 4
  %137 = fmul float %113, %136
  %138 = fadd float %133, %137
  %139 = getelementptr inbounds i8, i8* %114, i64 8
  %140 = bitcast i8* %139 to float*
  store float %138, float* %140, align 4
  %141 = getelementptr inbounds i8, i8* %40, i64 12
  %142 = bitcast i8* %141 to float*
  %143 = load float, float* %142, align 4
  %144 = getelementptr inbounds i8, i8* %42, i64 12
  %145 = bitcast i8* %144 to float*
  %146 = load float, float* %145, align 4
  %147 = fmul float %113, %146
  %148 = fadd float %143, %147
  %149 = getelementptr inbounds i8, i8* %114, i64 12
  %150 = bitcast i8* %149 to float*
  store float %148, float* %150, align 4
  %151 = load float, float* %115, align 4
  %152 = fpext float %151 to double
  %square176 = fmul double %152, %152
  %153 = fadd double %square176, 0.000000e+00
  %154 = fptrunc double %153 to float
  %155 = getelementptr inbounds i8, i8* %114, i64 4
  %156 = bitcast i8* %155 to float*
  %157 = load float, float* %156, align 4
  %158 = fpext float %157 to double
  %square177 = fmul double %158, %158
  %159 = fpext float %154 to double
  %160 = fadd double %square177, %159
  %161 = fptrunc double %160 to float
  %162 = getelementptr inbounds i8, i8* %114, i64 8
  %163 = bitcast i8* %162 to float*
  %164 = load float, float* %163, align 4
  %165 = fpext float %164 to double
  %square178 = fmul double %165, %165
  %166 = fpext float %161 to double
  %167 = fadd double %square178, %166
  %168 = fptrunc double %167 to float
  %169 = getelementptr inbounds i8, i8* %114, i64 12
  %170 = bitcast i8* %169 to float*
  %171 = load float, float* %170, align 4
  %172 = fpext float %171 to double
  %square179 = fmul double %172, %172
  %173 = fpext float %168 to double
  %174 = fadd double %square179, %173
  %175 = fptrunc double %174 to float
  %176 = bitcast i8* %116 to float*
  %177 = call float @llvm.sqrt.f32(float %175)
  %178 = load float, float* %115, align 4
  %179 = fdiv float %178, %177
  store float %179, float* %176, align 4
  %180 = getelementptr inbounds i8, i8* %114, i64 4
  %181 = bitcast i8* %180 to float*
  %182 = load float, float* %181, align 4
  %183 = fdiv float %182, %177
  %184 = getelementptr inbounds i8, i8* %116, i64 4
  %185 = bitcast i8* %184 to float*
  store float %183, float* %185, align 4
  %186 = getelementptr inbounds i8, i8* %114, i64 8
  %187 = bitcast i8* %186 to float*
  %188 = load float, float* %187, align 4
  %189 = fdiv float %188, %177
  %190 = getelementptr inbounds i8, i8* %116, i64 8
  %191 = bitcast i8* %190 to float*
  store float %189, float* %191, align 4
  %192 = getelementptr inbounds i8, i8* %114, i64 12
  %193 = bitcast i8* %192 to float*
  %194 = load float, float* %193, align 4
  %195 = fdiv float %194, %177
  %196 = getelementptr inbounds i8, i8* %116, i64 12
  %197 = bitcast i8* %196 to float*
  store float %195, float* %197, align 4
  %198 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #8
  %199 = bitcast i8* %198 to float*
  %200 = load float, float* %176, align 4
  %201 = fmul float %200, 2.000000e+00
  %202 = fmul float %201, %200
  %203 = fsub float 1.000000e+00, %202
  store float %203, float* %199, align 4
  %204 = load float, float* %176, align 4
  %205 = fmul float %204, 2.000000e+00
  %206 = getelementptr inbounds i8, i8* %116, i64 4
  %207 = bitcast i8* %206 to float*
  %208 = load float, float* %207, align 4
  %209 = fmul float %205, %208
  %210 = fsub float 0.000000e+00, %209
  %211 = getelementptr inbounds i8, i8* %198, i64 4
  %212 = bitcast i8* %211 to float*
  store float %210, float* %212, align 4
  %213 = load float, float* %176, align 4
  %214 = fmul float %213, 2.000000e+00
  %215 = getelementptr inbounds i8, i8* %116, i64 8
  %216 = bitcast i8* %215 to float*
  %217 = load float, float* %216, align 4
  %218 = fmul float %214, %217
  %219 = fsub float 0.000000e+00, %218
  %220 = getelementptr inbounds i8, i8* %198, i64 8
  %221 = bitcast i8* %220 to float*
  store float %219, float* %221, align 4
  %222 = load float, float* %176, align 4
  %223 = fmul float %222, 2.000000e+00
  %224 = getelementptr inbounds i8, i8* %116, i64 12
  %225 = bitcast i8* %224 to float*
  %226 = load float, float* %225, align 4
  %227 = fmul float %223, %226
  %228 = fsub float 0.000000e+00, %227
  %229 = getelementptr inbounds i8, i8* %198, i64 12
  %230 = bitcast i8* %229 to float*
  store float %228, float* %230, align 4
  %231 = getelementptr inbounds i8, i8* %116, i64 4
  %232 = bitcast i8* %231 to float*
  %233 = load float, float* %232, align 4
  %234 = fmul float %233, 2.000000e+00
  %235 = load float, float* %176, align 4
  %236 = fmul float %234, %235
  %237 = fsub float 0.000000e+00, %236
  %238 = getelementptr inbounds i8, i8* %198, i64 16
  %239 = bitcast i8* %238 to float*
  store float %237, float* %239, align 4
  %240 = load float, float* %232, align 4
  %241 = fmul float %240, 2.000000e+00
  %242 = fmul float %241, %240
  %243 = fsub float 1.000000e+00, %242
  %244 = getelementptr inbounds i8, i8* %198, i64 20
  %245 = bitcast i8* %244 to float*
  store float %243, float* %245, align 4
  %246 = load float, float* %232, align 4
  %247 = fmul float %246, 2.000000e+00
  %248 = getelementptr inbounds i8, i8* %116, i64 8
  %249 = bitcast i8* %248 to float*
  %250 = load float, float* %249, align 4
  %251 = fmul float %247, %250
  %252 = fsub float 0.000000e+00, %251
  %253 = getelementptr inbounds i8, i8* %198, i64 24
  %254 = bitcast i8* %253 to float*
  store float %252, float* %254, align 4
  %255 = load float, float* %232, align 4
  %256 = fmul float %255, 2.000000e+00
  %257 = getelementptr inbounds i8, i8* %116, i64 12
  %258 = bitcast i8* %257 to float*
  %259 = load float, float* %258, align 4
  %260 = fmul float %256, %259
  %261 = fsub float 0.000000e+00, %260
  %262 = getelementptr inbounds i8, i8* %198, i64 28
  %263 = bitcast i8* %262 to float*
  store float %261, float* %263, align 4
  %264 = getelementptr inbounds i8, i8* %116, i64 8
  %265 = bitcast i8* %264 to float*
  %266 = load float, float* %265, align 4
  %267 = fmul float %266, 2.000000e+00
  %268 = load float, float* %176, align 4
  %269 = fmul float %267, %268
  %270 = fsub float 0.000000e+00, %269
  %271 = getelementptr inbounds i8, i8* %198, i64 32
  %272 = bitcast i8* %271 to float*
  store float %270, float* %272, align 4
  %273 = load float, float* %265, align 4
  %274 = fmul float %273, 2.000000e+00
  %275 = getelementptr inbounds i8, i8* %116, i64 4
  %276 = bitcast i8* %275 to float*
  %277 = load float, float* %276, align 4
  %278 = fmul float %274, %277
  %279 = fsub float 0.000000e+00, %278
  %280 = getelementptr inbounds i8, i8* %198, i64 36
  %281 = bitcast i8* %280 to float*
  store float %279, float* %281, align 4
  %282 = load float, float* %265, align 4
  %283 = fmul float %282, 2.000000e+00
  %284 = fmul float %283, %282
  %285 = fsub float 1.000000e+00, %284
  %286 = getelementptr inbounds i8, i8* %198, i64 40
  %287 = bitcast i8* %286 to float*
  store float %285, float* %287, align 4
  %288 = load float, float* %265, align 4
  %289 = fmul float %288, 2.000000e+00
  %290 = getelementptr inbounds i8, i8* %116, i64 12
  %291 = bitcast i8* %290 to float*
  %292 = load float, float* %291, align 4
  %293 = fmul float %289, %292
  %294 = fsub float 0.000000e+00, %293
  %295 = getelementptr inbounds i8, i8* %198, i64 44
  %296 = bitcast i8* %295 to float*
  store float %294, float* %296, align 4
  %297 = getelementptr inbounds i8, i8* %116, i64 12
  %298 = bitcast i8* %297 to float*
  %299 = load float, float* %298, align 4
  %300 = fmul float %299, 2.000000e+00
  %301 = load float, float* %176, align 4
  %302 = fmul float %300, %301
  %303 = fsub float 0.000000e+00, %302
  %304 = getelementptr inbounds i8, i8* %198, i64 48
  %305 = bitcast i8* %304 to float*
  store float %303, float* %305, align 4
  %306 = load float, float* %298, align 4
  %307 = fmul float %306, 2.000000e+00
  %308 = getelementptr inbounds i8, i8* %116, i64 4
  %309 = bitcast i8* %308 to float*
  %310 = load float, float* %309, align 4
  %311 = fmul float %307, %310
  %312 = fsub float 0.000000e+00, %311
  %313 = getelementptr inbounds i8, i8* %198, i64 52
  %314 = bitcast i8* %313 to float*
  store float %312, float* %314, align 4
  %315 = load float, float* %298, align 4
  %316 = fmul float %315, 2.000000e+00
  %317 = getelementptr inbounds i8, i8* %116, i64 8
  %318 = bitcast i8* %317 to float*
  %319 = load float, float* %318, align 4
  %320 = fmul float %316, %319
  %321 = fsub float 0.000000e+00, %320
  %322 = getelementptr inbounds i8, i8* %198, i64 56
  %323 = bitcast i8* %322 to float*
  store float %321, float* %323, align 4
  %324 = load float, float* %298, align 4
  %325 = fmul float %324, 2.000000e+00
  %326 = fmul float %325, %324
  %327 = fsub float 1.000000e+00, %326
  %328 = getelementptr inbounds i8, i8* %198, i64 60
  %329 = bitcast i8* %328 to float*
  store float %327, float* %329, align 4
  %330 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #8
  %331 = bitcast i8* %330 to float*
  %332 = bitcast i8* %198 to i32*
  %333 = load i32, i32* %332, align 4
  %334 = bitcast i8* %330 to i32*
  store i32 %333, i32* %334, align 4
  %335 = getelementptr inbounds i8, i8* %198, i64 4
  %336 = bitcast i8* %335 to i32*
  %337 = load i32, i32* %336, align 4
  %338 = getelementptr inbounds i8, i8* %330, i64 4
  %339 = bitcast i8* %338 to i32*
  store i32 %337, i32* %339, align 4
  %340 = getelementptr inbounds i8, i8* %198, i64 8
  %341 = bitcast i8* %340 to i32*
  %342 = load i32, i32* %341, align 4
  %343 = getelementptr inbounds i8, i8* %330, i64 8
  %344 = bitcast i8* %343 to i32*
  store i32 %342, i32* %344, align 4
  %345 = getelementptr inbounds i8, i8* %198, i64 12
  %346 = bitcast i8* %345 to i32*
  %347 = load i32, i32* %346, align 4
  %348 = getelementptr inbounds i8, i8* %330, i64 12
  %349 = bitcast i8* %348 to i32*
  store i32 %347, i32* %349, align 4
  %350 = getelementptr inbounds i8, i8* %198, i64 16
  %351 = bitcast i8* %350 to i32*
  %352 = load i32, i32* %351, align 4
  %353 = getelementptr inbounds i8, i8* %330, i64 16
  %354 = bitcast i8* %353 to i32*
  store i32 %352, i32* %354, align 4
  %355 = getelementptr inbounds i8, i8* %198, i64 20
  %356 = bitcast i8* %355 to i32*
  %357 = load i32, i32* %356, align 4
  %358 = getelementptr inbounds i8, i8* %330, i64 20
  %359 = bitcast i8* %358 to i32*
  store i32 %357, i32* %359, align 4
  %360 = getelementptr inbounds i8, i8* %198, i64 24
  %361 = bitcast i8* %360 to i32*
  %362 = load i32, i32* %361, align 4
  %363 = getelementptr inbounds i8, i8* %330, i64 24
  %364 = bitcast i8* %363 to i32*
  store i32 %362, i32* %364, align 4
  %365 = getelementptr inbounds i8, i8* %198, i64 28
  %366 = bitcast i8* %365 to i32*
  %367 = load i32, i32* %366, align 4
  %368 = getelementptr inbounds i8, i8* %330, i64 28
  %369 = bitcast i8* %368 to i32*
  store i32 %367, i32* %369, align 4
  %370 = getelementptr inbounds i8, i8* %198, i64 32
  %371 = bitcast i8* %370 to i32*
  %372 = load i32, i32* %371, align 4
  %373 = getelementptr inbounds i8, i8* %330, i64 32
  %374 = bitcast i8* %373 to i32*
  store i32 %372, i32* %374, align 4
  %375 = getelementptr inbounds i8, i8* %198, i64 36
  %376 = bitcast i8* %375 to i32*
  %377 = load i32, i32* %376, align 4
  %378 = getelementptr inbounds i8, i8* %330, i64 36
  %379 = bitcast i8* %378 to i32*
  store i32 %377, i32* %379, align 4
  %380 = getelementptr inbounds i8, i8* %198, i64 40
  %381 = bitcast i8* %380 to i32*
  %382 = load i32, i32* %381, align 4
  %383 = getelementptr inbounds i8, i8* %330, i64 40
  %384 = bitcast i8* %383 to i32*
  store i32 %382, i32* %384, align 4
  %385 = getelementptr inbounds i8, i8* %198, i64 44
  %386 = bitcast i8* %385 to i32*
  %387 = load i32, i32* %386, align 4
  %388 = getelementptr inbounds i8, i8* %330, i64 44
  %389 = bitcast i8* %388 to i32*
  store i32 %387, i32* %389, align 4
  %390 = getelementptr inbounds i8, i8* %198, i64 48
  %391 = bitcast i8* %390 to i32*
  %392 = load i32, i32* %391, align 4
  %393 = getelementptr inbounds i8, i8* %330, i64 48
  %394 = bitcast i8* %393 to i32*
  store i32 %392, i32* %394, align 4
  %395 = getelementptr inbounds i8, i8* %198, i64 52
  %396 = bitcast i8* %395 to i32*
  %397 = load i32, i32* %396, align 4
  %398 = getelementptr inbounds i8, i8* %330, i64 52
  %399 = bitcast i8* %398 to i32*
  store i32 %397, i32* %399, align 4
  %400 = getelementptr inbounds i8, i8* %198, i64 56
  %401 = bitcast i8* %400 to i32*
  %402 = load i32, i32* %401, align 4
  %403 = getelementptr inbounds i8, i8* %330, i64 56
  %404 = bitcast i8* %403 to i32*
  store i32 %402, i32* %404, align 4
  %405 = getelementptr inbounds i8, i8* %198, i64 60
  %406 = bitcast i8* %405 to i32*
  %407 = load i32, i32* %406, align 4
  %408 = getelementptr inbounds i8, i8* %330, i64 60
  %409 = bitcast i8* %408 to i32*
  store i32 %407, i32* %409, align 4
  store float 0.000000e+00, float* %2, align 4
  %410 = load float, float* %331, align 4
  %411 = load float, float* %0, align 4
  %412 = fmul float %410, %411
  %413 = fadd float %412, 0.000000e+00
  store float %413, float* %2, align 4
  %414 = getelementptr inbounds i8, i8* %330, i64 4
  %415 = bitcast i8* %414 to float*
  %416 = load float, float* %415, align 4
  %417 = getelementptr inbounds float, float* %0, i64 4
  %418 = load float, float* %417, align 4
  %419 = fmul float %416, %418
  %420 = load float, float* %2, align 4
  %421 = fadd float %420, %419
  store float %421, float* %2, align 4
  %422 = getelementptr inbounds i8, i8* %330, i64 8
  %423 = bitcast i8* %422 to float*
  %424 = load float, float* %423, align 4
  %425 = getelementptr inbounds float, float* %0, i64 8
  %426 = load float, float* %425, align 4
  %427 = fmul float %424, %426
  %428 = load float, float* %2, align 4
  %429 = fadd float %428, %427
  store float %429, float* %2, align 4
  %430 = getelementptr inbounds i8, i8* %330, i64 12
  %431 = bitcast i8* %430 to float*
  %432 = load float, float* %431, align 4
  %433 = getelementptr inbounds float, float* %0, i64 12
  %434 = load float, float* %433, align 4
  %435 = fmul float %432, %434
  %436 = load float, float* %2, align 4
  %437 = fadd float %436, %435
  store float %437, float* %2, align 4
  %438 = getelementptr inbounds float, float* %2, i64 1
  store float 0.000000e+00, float* %438, align 4
  %439 = getelementptr inbounds float, float* %2, i64 1
  %440 = load float, float* %331, align 4
  %441 = getelementptr inbounds float, float* %0, i64 1
  %442 = load float, float* %441, align 4
  %443 = fmul float %440, %442
  %444 = fadd float %443, 0.000000e+00
  store float %444, float* %439, align 4
  %445 = getelementptr inbounds i8, i8* %330, i64 4
  %446 = bitcast i8* %445 to float*
  %447 = load float, float* %446, align 4
  %448 = getelementptr inbounds float, float* %0, i64 5
  %449 = load float, float* %448, align 4
  %450 = fmul float %447, %449
  %451 = load float, float* %439, align 4
  %452 = fadd float %451, %450
  store float %452, float* %439, align 4
  %453 = getelementptr inbounds i8, i8* %330, i64 8
  %454 = bitcast i8* %453 to float*
  %455 = load float, float* %454, align 4
  %456 = getelementptr inbounds float, float* %0, i64 9
  %457 = load float, float* %456, align 4
  %458 = fmul float %455, %457
  %459 = load float, float* %439, align 4
  %460 = fadd float %459, %458
  store float %460, float* %439, align 4
  %461 = getelementptr inbounds i8, i8* %330, i64 12
  %462 = bitcast i8* %461 to float*
  %463 = load float, float* %462, align 4
  %464 = getelementptr inbounds float, float* %0, i64 13
  %465 = load float, float* %464, align 4
  %466 = fmul float %463, %465
  %467 = load float, float* %439, align 4
  %468 = fadd float %467, %466
  store float %468, float* %439, align 4
  %469 = getelementptr inbounds float, float* %2, i64 2
  store float 0.000000e+00, float* %469, align 4
  %470 = getelementptr inbounds float, float* %2, i64 2
  %471 = load float, float* %331, align 4
  %472 = getelementptr inbounds float, float* %0, i64 2
  %473 = load float, float* %472, align 4
  %474 = fmul float %471, %473
  %475 = fadd float %474, 0.000000e+00
  store float %475, float* %470, align 4
  %476 = getelementptr inbounds i8, i8* %330, i64 4
  %477 = bitcast i8* %476 to float*
  %478 = load float, float* %477, align 4
  %479 = getelementptr inbounds float, float* %0, i64 6
  %480 = load float, float* %479, align 4
  %481 = fmul float %478, %480
  %482 = load float, float* %470, align 4
  %483 = fadd float %482, %481
  store float %483, float* %470, align 4
  %484 = getelementptr inbounds i8, i8* %330, i64 8
  %485 = bitcast i8* %484 to float*
  %486 = load float, float* %485, align 4
  %487 = getelementptr inbounds float, float* %0, i64 10
  %488 = load float, float* %487, align 4
  %489 = fmul float %486, %488
  %490 = load float, float* %470, align 4
  %491 = fadd float %490, %489
  store float %491, float* %470, align 4
  %492 = getelementptr inbounds i8, i8* %330, i64 12
  %493 = bitcast i8* %492 to float*
  %494 = load float, float* %493, align 4
  %495 = getelementptr inbounds float, float* %0, i64 14
  %496 = load float, float* %495, align 4
  %497 = fmul float %494, %496
  %498 = load float, float* %470, align 4
  %499 = fadd float %498, %497
  store float %499, float* %470, align 4
  %500 = getelementptr inbounds float, float* %2, i64 3
  store float 0.000000e+00, float* %500, align 4
  %501 = getelementptr inbounds float, float* %2, i64 3
  %502 = load float, float* %331, align 4
  %503 = getelementptr inbounds float, float* %0, i64 3
  %504 = load float, float* %503, align 4
  %505 = fmul float %502, %504
  %506 = fadd float %505, 0.000000e+00
  store float %506, float* %501, align 4
  %507 = getelementptr inbounds i8, i8* %330, i64 4
  %508 = bitcast i8* %507 to float*
  %509 = load float, float* %508, align 4
  %510 = getelementptr inbounds float, float* %0, i64 7
  %511 = load float, float* %510, align 4
  %512 = fmul float %509, %511
  %513 = load float, float* %501, align 4
  %514 = fadd float %513, %512
  store float %514, float* %501, align 4
  %515 = getelementptr inbounds i8, i8* %330, i64 8
  %516 = bitcast i8* %515 to float*
  %517 = load float, float* %516, align 4
  %518 = getelementptr inbounds float, float* %0, i64 11
  %519 = load float, float* %518, align 4
  %520 = fmul float %517, %519
  %521 = load float, float* %501, align 4
  %522 = fadd float %521, %520
  store float %522, float* %501, align 4
  %523 = getelementptr inbounds i8, i8* %330, i64 12
  %524 = bitcast i8* %523 to float*
  %525 = load float, float* %524, align 4
  %526 = getelementptr inbounds float, float* %0, i64 15
  %527 = load float, float* %526, align 4
  %528 = fmul float %525, %527
  %529 = load float, float* %501, align 4
  %530 = fadd float %529, %528
  store float %530, float* %501, align 4
  %531 = getelementptr inbounds i8, i8* %330, i64 16
  %532 = bitcast i8* %531 to float*
  %533 = getelementptr inbounds float, float* %2, i64 4
  store float 0.000000e+00, float* %533, align 4
  %534 = getelementptr inbounds float, float* %2, i64 4
  %535 = load float, float* %532, align 4
  %536 = load float, float* %0, align 4
  %537 = fmul float %535, %536
  %538 = fadd float %537, 0.000000e+00
  store float %538, float* %534, align 4
  %539 = getelementptr inbounds i8, i8* %330, i64 20
  %540 = bitcast i8* %539 to float*
  %541 = load float, float* %540, align 4
  %542 = getelementptr inbounds float, float* %0, i64 4
  %543 = load float, float* %542, align 4
  %544 = fmul float %541, %543
  %545 = load float, float* %534, align 4
  %546 = fadd float %545, %544
  store float %546, float* %534, align 4
  %547 = getelementptr inbounds i8, i8* %330, i64 24
  %548 = bitcast i8* %547 to float*
  %549 = load float, float* %548, align 4
  %550 = getelementptr inbounds float, float* %0, i64 8
  %551 = load float, float* %550, align 4
  %552 = fmul float %549, %551
  %553 = load float, float* %534, align 4
  %554 = fadd float %553, %552
  store float %554, float* %534, align 4
  %555 = getelementptr inbounds i8, i8* %330, i64 28
  %556 = bitcast i8* %555 to float*
  %557 = load float, float* %556, align 4
  %558 = getelementptr inbounds float, float* %0, i64 12
  %559 = load float, float* %558, align 4
  %560 = fmul float %557, %559
  %561 = load float, float* %534, align 4
  %562 = fadd float %561, %560
  store float %562, float* %534, align 4
  %563 = getelementptr inbounds float, float* %2, i64 5
  store float 0.000000e+00, float* %563, align 4
  %564 = getelementptr inbounds float, float* %2, i64 5
  %565 = load float, float* %532, align 4
  %566 = getelementptr inbounds float, float* %0, i64 1
  %567 = load float, float* %566, align 4
  %568 = fmul float %565, %567
  %569 = fadd float %568, 0.000000e+00
  store float %569, float* %564, align 4
  %570 = getelementptr inbounds i8, i8* %330, i64 20
  %571 = bitcast i8* %570 to float*
  %572 = load float, float* %571, align 4
  %573 = getelementptr inbounds float, float* %0, i64 5
  %574 = load float, float* %573, align 4
  %575 = fmul float %572, %574
  %576 = load float, float* %564, align 4
  %577 = fadd float %576, %575
  store float %577, float* %564, align 4
  %578 = getelementptr inbounds i8, i8* %330, i64 24
  %579 = bitcast i8* %578 to float*
  %580 = load float, float* %579, align 4
  %581 = getelementptr inbounds float, float* %0, i64 9
  %582 = load float, float* %581, align 4
  %583 = fmul float %580, %582
  %584 = load float, float* %564, align 4
  %585 = fadd float %584, %583
  store float %585, float* %564, align 4
  %586 = getelementptr inbounds i8, i8* %330, i64 28
  %587 = bitcast i8* %586 to float*
  %588 = load float, float* %587, align 4
  %589 = getelementptr inbounds float, float* %0, i64 13
  %590 = load float, float* %589, align 4
  %591 = fmul float %588, %590
  %592 = load float, float* %564, align 4
  %593 = fadd float %592, %591
  store float %593, float* %564, align 4
  %594 = getelementptr inbounds float, float* %2, i64 6
  store float 0.000000e+00, float* %594, align 4
  %595 = getelementptr inbounds float, float* %2, i64 6
  %596 = load float, float* %532, align 4
  %597 = getelementptr inbounds float, float* %0, i64 2
  %598 = load float, float* %597, align 4
  %599 = fmul float %596, %598
  %600 = fadd float %599, 0.000000e+00
  store float %600, float* %595, align 4
  %601 = getelementptr inbounds i8, i8* %330, i64 20
  %602 = bitcast i8* %601 to float*
  %603 = load float, float* %602, align 4
  %604 = getelementptr inbounds float, float* %0, i64 6
  %605 = load float, float* %604, align 4
  %606 = fmul float %603, %605
  %607 = load float, float* %595, align 4
  %608 = fadd float %607, %606
  store float %608, float* %595, align 4
  %609 = getelementptr inbounds i8, i8* %330, i64 24
  %610 = bitcast i8* %609 to float*
  %611 = load float, float* %610, align 4
  %612 = getelementptr inbounds float, float* %0, i64 10
  %613 = load float, float* %612, align 4
  %614 = fmul float %611, %613
  %615 = load float, float* %595, align 4
  %616 = fadd float %615, %614
  store float %616, float* %595, align 4
  %617 = getelementptr inbounds i8, i8* %330, i64 28
  %618 = bitcast i8* %617 to float*
  %619 = load float, float* %618, align 4
  %620 = getelementptr inbounds float, float* %0, i64 14
  %621 = load float, float* %620, align 4
  %622 = fmul float %619, %621
  %623 = load float, float* %595, align 4
  %624 = fadd float %623, %622
  store float %624, float* %595, align 4
  %625 = getelementptr inbounds float, float* %2, i64 7
  store float 0.000000e+00, float* %625, align 4
  %626 = getelementptr inbounds float, float* %2, i64 7
  %627 = load float, float* %532, align 4
  %628 = getelementptr inbounds float, float* %0, i64 3
  %629 = load float, float* %628, align 4
  %630 = fmul float %627, %629
  %631 = fadd float %630, 0.000000e+00
  store float %631, float* %626, align 4
  %632 = getelementptr inbounds i8, i8* %330, i64 20
  %633 = bitcast i8* %632 to float*
  %634 = load float, float* %633, align 4
  %635 = getelementptr inbounds float, float* %0, i64 7
  %636 = load float, float* %635, align 4
  %637 = fmul float %634, %636
  %638 = load float, float* %626, align 4
  %639 = fadd float %638, %637
  store float %639, float* %626, align 4
  %640 = getelementptr inbounds i8, i8* %330, i64 24
  %641 = bitcast i8* %640 to float*
  %642 = load float, float* %641, align 4
  %643 = getelementptr inbounds float, float* %0, i64 11
  %644 = load float, float* %643, align 4
  %645 = fmul float %642, %644
  %646 = load float, float* %626, align 4
  %647 = fadd float %646, %645
  store float %647, float* %626, align 4
  %648 = getelementptr inbounds i8, i8* %330, i64 28
  %649 = bitcast i8* %648 to float*
  %650 = load float, float* %649, align 4
  %651 = getelementptr inbounds float, float* %0, i64 15
  %652 = load float, float* %651, align 4
  %653 = fmul float %650, %652
  %654 = load float, float* %626, align 4
  %655 = fadd float %654, %653
  store float %655, float* %626, align 4
  %656 = getelementptr inbounds i8, i8* %330, i64 32
  %657 = bitcast i8* %656 to float*
  %658 = getelementptr inbounds float, float* %2, i64 8
  store float 0.000000e+00, float* %658, align 4
  %659 = getelementptr inbounds float, float* %2, i64 8
  %660 = load float, float* %657, align 4
  %661 = load float, float* %0, align 4
  %662 = fmul float %660, %661
  %663 = fadd float %662, 0.000000e+00
  store float %663, float* %659, align 4
  %664 = getelementptr inbounds i8, i8* %330, i64 36
  %665 = bitcast i8* %664 to float*
  %666 = load float, float* %665, align 4
  %667 = getelementptr inbounds float, float* %0, i64 4
  %668 = load float, float* %667, align 4
  %669 = fmul float %666, %668
  %670 = load float, float* %659, align 4
  %671 = fadd float %670, %669
  store float %671, float* %659, align 4
  %672 = getelementptr inbounds i8, i8* %330, i64 40
  %673 = bitcast i8* %672 to float*
  %674 = load float, float* %673, align 4
  %675 = getelementptr inbounds float, float* %0, i64 8
  %676 = load float, float* %675, align 4
  %677 = fmul float %674, %676
  %678 = load float, float* %659, align 4
  %679 = fadd float %678, %677
  store float %679, float* %659, align 4
  %680 = getelementptr inbounds i8, i8* %330, i64 44
  %681 = bitcast i8* %680 to float*
  %682 = load float, float* %681, align 4
  %683 = getelementptr inbounds float, float* %0, i64 12
  %684 = load float, float* %683, align 4
  %685 = fmul float %682, %684
  %686 = load float, float* %659, align 4
  %687 = fadd float %686, %685
  store float %687, float* %659, align 4
  %688 = getelementptr inbounds float, float* %2, i64 9
  store float 0.000000e+00, float* %688, align 4
  %689 = getelementptr inbounds float, float* %2, i64 9
  %690 = load float, float* %657, align 4
  %691 = getelementptr inbounds float, float* %0, i64 1
  %692 = load float, float* %691, align 4
  %693 = fmul float %690, %692
  %694 = fadd float %693, 0.000000e+00
  store float %694, float* %689, align 4
  %695 = getelementptr inbounds i8, i8* %330, i64 36
  %696 = bitcast i8* %695 to float*
  %697 = load float, float* %696, align 4
  %698 = getelementptr inbounds float, float* %0, i64 5
  %699 = load float, float* %698, align 4
  %700 = fmul float %697, %699
  %701 = load float, float* %689, align 4
  %702 = fadd float %701, %700
  store float %702, float* %689, align 4
  %703 = getelementptr inbounds i8, i8* %330, i64 40
  %704 = bitcast i8* %703 to float*
  %705 = load float, float* %704, align 4
  %706 = getelementptr inbounds float, float* %0, i64 9
  %707 = load float, float* %706, align 4
  %708 = fmul float %705, %707
  %709 = load float, float* %689, align 4
  %710 = fadd float %709, %708
  store float %710, float* %689, align 4
  %711 = getelementptr inbounds i8, i8* %330, i64 44
  %712 = bitcast i8* %711 to float*
  %713 = load float, float* %712, align 4
  %714 = getelementptr inbounds float, float* %0, i64 13
  %715 = load float, float* %714, align 4
  %716 = fmul float %713, %715
  %717 = load float, float* %689, align 4
  %718 = fadd float %717, %716
  store float %718, float* %689, align 4
  %719 = getelementptr inbounds float, float* %2, i64 10
  store float 0.000000e+00, float* %719, align 4
  %720 = getelementptr inbounds float, float* %2, i64 10
  %721 = load float, float* %657, align 4
  %722 = getelementptr inbounds float, float* %0, i64 2
  %723 = load float, float* %722, align 4
  %724 = fmul float %721, %723
  %725 = fadd float %724, 0.000000e+00
  store float %725, float* %720, align 4
  %726 = getelementptr inbounds i8, i8* %330, i64 36
  %727 = bitcast i8* %726 to float*
  %728 = load float, float* %727, align 4
  %729 = getelementptr inbounds float, float* %0, i64 6
  %730 = load float, float* %729, align 4
  %731 = fmul float %728, %730
  %732 = load float, float* %720, align 4
  %733 = fadd float %732, %731
  store float %733, float* %720, align 4
  %734 = getelementptr inbounds i8, i8* %330, i64 40
  %735 = bitcast i8* %734 to float*
  %736 = load float, float* %735, align 4
  %737 = getelementptr inbounds float, float* %0, i64 10
  %738 = load float, float* %737, align 4
  %739 = fmul float %736, %738
  %740 = load float, float* %720, align 4
  %741 = fadd float %740, %739
  store float %741, float* %720, align 4
  %742 = getelementptr inbounds i8, i8* %330, i64 44
  %743 = bitcast i8* %742 to float*
  %744 = load float, float* %743, align 4
  %745 = getelementptr inbounds float, float* %0, i64 14
  %746 = load float, float* %745, align 4
  %747 = fmul float %744, %746
  %748 = load float, float* %720, align 4
  %749 = fadd float %748, %747
  store float %749, float* %720, align 4
  %750 = getelementptr inbounds float, float* %2, i64 11
  store float 0.000000e+00, float* %750, align 4
  %751 = getelementptr inbounds float, float* %2, i64 11
  %752 = load float, float* %657, align 4
  %753 = getelementptr inbounds float, float* %0, i64 3
  %754 = load float, float* %753, align 4
  %755 = fmul float %752, %754
  %756 = fadd float %755, 0.000000e+00
  store float %756, float* %751, align 4
  %757 = getelementptr inbounds i8, i8* %330, i64 36
  %758 = bitcast i8* %757 to float*
  %759 = load float, float* %758, align 4
  %760 = getelementptr inbounds float, float* %0, i64 7
  %761 = load float, float* %760, align 4
  %762 = fmul float %759, %761
  %763 = load float, float* %751, align 4
  %764 = fadd float %763, %762
  store float %764, float* %751, align 4
  %765 = getelementptr inbounds i8, i8* %330, i64 40
  %766 = bitcast i8* %765 to float*
  %767 = load float, float* %766, align 4
  %768 = getelementptr inbounds float, float* %0, i64 11
  %769 = load float, float* %768, align 4
  %770 = fmul float %767, %769
  %771 = load float, float* %751, align 4
  %772 = fadd float %771, %770
  store float %772, float* %751, align 4
  %773 = getelementptr inbounds i8, i8* %330, i64 44
  %774 = bitcast i8* %773 to float*
  %775 = load float, float* %774, align 4
  %776 = getelementptr inbounds float, float* %0, i64 15
  %777 = load float, float* %776, align 4
  %778 = fmul float %775, %777
  %779 = load float, float* %751, align 4
  %780 = fadd float %779, %778
  store float %780, float* %751, align 4
  %781 = getelementptr inbounds i8, i8* %330, i64 48
  %782 = bitcast i8* %781 to float*
  %783 = getelementptr inbounds float, float* %2, i64 12
  store float 0.000000e+00, float* %783, align 4
  %784 = getelementptr inbounds float, float* %2, i64 12
  %785 = load float, float* %782, align 4
  %786 = load float, float* %0, align 4
  %787 = fmul float %785, %786
  %788 = fadd float %787, 0.000000e+00
  store float %788, float* %784, align 4
  %789 = getelementptr inbounds i8, i8* %330, i64 52
  %790 = bitcast i8* %789 to float*
  %791 = load float, float* %790, align 4
  %792 = getelementptr inbounds float, float* %0, i64 4
  %793 = load float, float* %792, align 4
  %794 = fmul float %791, %793
  %795 = load float, float* %784, align 4
  %796 = fadd float %795, %794
  store float %796, float* %784, align 4
  %797 = getelementptr inbounds i8, i8* %330, i64 56
  %798 = bitcast i8* %797 to float*
  %799 = load float, float* %798, align 4
  %800 = getelementptr inbounds float, float* %0, i64 8
  %801 = load float, float* %800, align 4
  %802 = fmul float %799, %801
  %803 = load float, float* %784, align 4
  %804 = fadd float %803, %802
  store float %804, float* %784, align 4
  %805 = getelementptr inbounds i8, i8* %330, i64 60
  %806 = bitcast i8* %805 to float*
  %807 = load float, float* %806, align 4
  %808 = getelementptr inbounds float, float* %0, i64 12
  %809 = load float, float* %808, align 4
  %810 = fmul float %807, %809
  %811 = load float, float* %784, align 4
  %812 = fadd float %811, %810
  store float %812, float* %784, align 4
  %813 = getelementptr inbounds float, float* %2, i64 13
  store float 0.000000e+00, float* %813, align 4
  %814 = getelementptr inbounds float, float* %2, i64 13
  %815 = load float, float* %782, align 4
  %816 = getelementptr inbounds float, float* %0, i64 1
  %817 = load float, float* %816, align 4
  %818 = fmul float %815, %817
  %819 = fadd float %818, 0.000000e+00
  store float %819, float* %814, align 4
  %820 = getelementptr inbounds i8, i8* %330, i64 52
  %821 = bitcast i8* %820 to float*
  %822 = load float, float* %821, align 4
  %823 = getelementptr inbounds float, float* %0, i64 5
  %824 = load float, float* %823, align 4
  %825 = fmul float %822, %824
  %826 = load float, float* %814, align 4
  %827 = fadd float %826, %825
  store float %827, float* %814, align 4
  %828 = getelementptr inbounds i8, i8* %330, i64 56
  %829 = bitcast i8* %828 to float*
  %830 = load float, float* %829, align 4
  %831 = getelementptr inbounds float, float* %0, i64 9
  %832 = load float, float* %831, align 4
  %833 = fmul float %830, %832
  %834 = load float, float* %814, align 4
  %835 = fadd float %834, %833
  store float %835, float* %814, align 4
  %836 = getelementptr inbounds i8, i8* %330, i64 60
  %837 = bitcast i8* %836 to float*
  %838 = load float, float* %837, align 4
  %839 = getelementptr inbounds float, float* %0, i64 13
  %840 = load float, float* %839, align 4
  %841 = fmul float %838, %840
  %842 = load float, float* %814, align 4
  %843 = fadd float %842, %841
  store float %843, float* %814, align 4
  %844 = getelementptr inbounds float, float* %2, i64 14
  store float 0.000000e+00, float* %844, align 4
  %845 = getelementptr inbounds float, float* %2, i64 14
  %846 = load float, float* %782, align 4
  %847 = getelementptr inbounds float, float* %0, i64 2
  %848 = load float, float* %847, align 4
  %849 = fmul float %846, %848
  %850 = fadd float %849, 0.000000e+00
  store float %850, float* %845, align 4
  %851 = getelementptr inbounds i8, i8* %330, i64 52
  %852 = bitcast i8* %851 to float*
  %853 = load float, float* %852, align 4
  %854 = getelementptr inbounds float, float* %0, i64 6
  %855 = load float, float* %854, align 4
  %856 = fmul float %853, %855
  %857 = load float, float* %845, align 4
  %858 = fadd float %857, %856
  store float %858, float* %845, align 4
  %859 = getelementptr inbounds i8, i8* %330, i64 56
  %860 = bitcast i8* %859 to float*
  %861 = load float, float* %860, align 4
  %862 = getelementptr inbounds float, float* %0, i64 10
  %863 = load float, float* %862, align 4
  %864 = fmul float %861, %863
  %865 = load float, float* %845, align 4
  %866 = fadd float %865, %864
  store float %866, float* %845, align 4
  %867 = getelementptr inbounds i8, i8* %330, i64 60
  %868 = bitcast i8* %867 to float*
  %869 = load float, float* %868, align 4
  %870 = getelementptr inbounds float, float* %0, i64 14
  %871 = load float, float* %870, align 4
  %872 = fmul float %869, %871
  %873 = load float, float* %845, align 4
  %874 = fadd float %873, %872
  store float %874, float* %845, align 4
  %875 = getelementptr inbounds float, float* %2, i64 15
  store float 0.000000e+00, float* %875, align 4
  %876 = getelementptr inbounds float, float* %2, i64 15
  %877 = load float, float* %782, align 4
  %878 = getelementptr inbounds float, float* %0, i64 3
  %879 = load float, float* %878, align 4
  %880 = fmul float %877, %879
  %881 = fadd float %880, 0.000000e+00
  store float %881, float* %876, align 4
  %882 = getelementptr inbounds i8, i8* %330, i64 52
  %883 = bitcast i8* %882 to float*
  %884 = load float, float* %883, align 4
  %885 = getelementptr inbounds float, float* %0, i64 7
  %886 = load float, float* %885, align 4
  %887 = fmul float %884, %886
  %888 = load float, float* %876, align 4
  %889 = fadd float %888, %887
  store float %889, float* %876, align 4
  %890 = getelementptr inbounds i8, i8* %330, i64 56
  %891 = bitcast i8* %890 to float*
  %892 = load float, float* %891, align 4
  %893 = getelementptr inbounds float, float* %0, i64 11
  %894 = load float, float* %893, align 4
  %895 = fmul float %892, %894
  %896 = load float, float* %876, align 4
  %897 = fadd float %896, %895
  store float %897, float* %876, align 4
  %898 = getelementptr inbounds i8, i8* %330, i64 60
  %899 = bitcast i8* %898 to float*
  %900 = load float, float* %899, align 4
  %901 = getelementptr inbounds float, float* %0, i64 15
  %902 = load float, float* %901, align 4
  %903 = fmul float %900, %902
  %904 = load float, float* %876, align 4
  %905 = fadd float %904, %903
  store float %905, float* %876, align 4
  %906 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #8
  %907 = bitcast i8* %906 to float*
  %908 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #8
  %909 = bitcast i8* %908 to float*
  %910 = getelementptr inbounds float, float* %2, i64 5
  %911 = bitcast float* %910 to i32*
  %912 = load i32, i32* %911, align 4
  %913 = bitcast i8* %906 to i32*
  store i32 %912, i32* %913, align 4
  %914 = getelementptr inbounds i8, i8* %8, i64 20
  %915 = bitcast i8* %914 to i32*
  %916 = load i32, i32* %915, align 4
  %917 = bitcast i8* %908 to i32*
  store i32 %916, i32* %917, align 4
  %918 = getelementptr inbounds float, float* %2, i64 9
  %919 = bitcast float* %918 to i32*
  %920 = load i32, i32* %919, align 4
  %921 = getelementptr inbounds i8, i8* %906, i64 4
  %922 = bitcast i8* %921 to i32*
  store i32 %920, i32* %922, align 4
  %923 = getelementptr inbounds i8, i8* %8, i64 36
  %924 = bitcast i8* %923 to i32*
  %925 = load i32, i32* %924, align 4
  %926 = getelementptr inbounds i8, i8* %908, i64 4
  %927 = bitcast i8* %926 to i32*
  store i32 %925, i32* %927, align 4
  %928 = getelementptr inbounds float, float* %2, i64 13
  %929 = bitcast float* %928 to i32*
  %930 = load i32, i32* %929, align 4
  %931 = getelementptr inbounds i8, i8* %906, i64 8
  %932 = bitcast i8* %931 to i32*
  store i32 %930, i32* %932, align 4
  %933 = getelementptr inbounds i8, i8* %8, i64 52
  %934 = bitcast i8* %933 to i32*
  %935 = load i32, i32* %934, align 4
  %936 = getelementptr inbounds i8, i8* %908, i64 8
  %937 = bitcast i8* %936 to i32*
  store i32 %935, i32* %937, align 4
  %938 = load float, float* %907, align 4
  %939 = fcmp ogt float %938, 0.000000e+00
  %940 = zext i1 %939 to i32
  %941 = fcmp olt float %938, 0.000000e+00
  %.neg180 = sext i1 %941 to i32
  %942 = add nsw i32 %.neg180, %940
  %943 = sitofp i32 %942 to float
  %944 = load float, float* %907, align 4
  %945 = fpext float %944 to double
  %square181 = fmul double %945, %945
  %946 = fadd double %square181, 0.000000e+00
  %947 = fptrunc double %946 to float
  %948 = getelementptr inbounds i8, i8* %906, i64 4
  %949 = bitcast i8* %948 to float*
  %950 = load float, float* %949, align 4
  %951 = fpext float %950 to double
  %square182 = fmul double %951, %951
  %952 = fpext float %947 to double
  %953 = fadd double %square182, %952
  %954 = fptrunc double %953 to float
  %955 = getelementptr inbounds i8, i8* %906, i64 8
  %956 = bitcast i8* %955 to float*
  %957 = load float, float* %956, align 4
  %958 = fpext float %957 to double
  %square183 = fmul double %958, %958
  %959 = fpext float %954 to double
  %960 = fadd double %square183, %959
  %961 = fptrunc double %960 to float
  %962 = fneg float %943
  %963 = call float @llvm.sqrt.f32(float %961)
  %964 = fmul float %963, %962
  %965 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #8
  %966 = bitcast i8* %965 to float*
  %967 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #8
  %968 = load float, float* %907, align 4
  %969 = load float, float* %909, align 4
  %970 = fmul float %964, %969
  %971 = fadd float %968, %970
  store float %971, float* %966, align 4
  %972 = getelementptr inbounds i8, i8* %906, i64 4
  %973 = bitcast i8* %972 to float*
  %974 = load float, float* %973, align 4
  %975 = getelementptr inbounds i8, i8* %908, i64 4
  %976 = bitcast i8* %975 to float*
  %977 = load float, float* %976, align 4
  %978 = fmul float %964, %977
  %979 = fadd float %974, %978
  %980 = getelementptr inbounds i8, i8* %965, i64 4
  %981 = bitcast i8* %980 to float*
  store float %979, float* %981, align 4
  %982 = getelementptr inbounds i8, i8* %906, i64 8
  %983 = bitcast i8* %982 to float*
  %984 = load float, float* %983, align 4
  %985 = getelementptr inbounds i8, i8* %908, i64 8
  %986 = bitcast i8* %985 to float*
  %987 = load float, float* %986, align 4
  %988 = fmul float %964, %987
  %989 = fadd float %984, %988
  %990 = getelementptr inbounds i8, i8* %965, i64 8
  %991 = bitcast i8* %990 to float*
  store float %989, float* %991, align 4
  %992 = load float, float* %966, align 4
  %993 = fpext float %992 to double
  %square184 = fmul double %993, %993
  %994 = fadd double %square184, 0.000000e+00
  %995 = fptrunc double %994 to float
  %996 = getelementptr inbounds i8, i8* %965, i64 4
  %997 = bitcast i8* %996 to float*
  %998 = load float, float* %997, align 4
  %999 = fpext float %998 to double
  %square185 = fmul double %999, %999
  %1000 = fpext float %995 to double
  %1001 = fadd double %square185, %1000
  %1002 = fptrunc double %1001 to float
  %1003 = getelementptr inbounds i8, i8* %965, i64 8
  %1004 = bitcast i8* %1003 to float*
  %1005 = load float, float* %1004, align 4
  %1006 = fpext float %1005 to double
  %square186 = fmul double %1006, %1006
  %1007 = fpext float %1002 to double
  %1008 = fadd double %square186, %1007
  %1009 = fptrunc double %1008 to float
  %1010 = bitcast i8* %967 to float*
  %1011 = call float @llvm.sqrt.f32(float %1009)
  %1012 = load float, float* %966, align 4
  %1013 = fdiv float %1012, %1011
  store float %1013, float* %1010, align 4
  %1014 = getelementptr inbounds i8, i8* %965, i64 4
  %1015 = bitcast i8* %1014 to float*
  %1016 = load float, float* %1015, align 4
  %1017 = fdiv float %1016, %1011
  %1018 = getelementptr inbounds i8, i8* %967, i64 4
  %1019 = bitcast i8* %1018 to float*
  store float %1017, float* %1019, align 4
  %1020 = getelementptr inbounds i8, i8* %965, i64 8
  %1021 = bitcast i8* %1020 to float*
  %1022 = load float, float* %1021, align 4
  %1023 = fdiv float %1022, %1011
  %1024 = getelementptr inbounds i8, i8* %967, i64 8
  %1025 = bitcast i8* %1024 to float*
  store float %1023, float* %1025, align 4
  %1026 = call dereferenceable_or_null(36) i8* @calloc(i64 4, i64 9) #8
  %1027 = bitcast i8* %1026 to float*
  %1028 = load float, float* %1010, align 4
  %1029 = fmul float %1028, 2.000000e+00
  %1030 = fmul float %1029, %1028
  %1031 = fsub float 1.000000e+00, %1030
  store float %1031, float* %1027, align 4
  %1032 = load float, float* %1010, align 4
  %1033 = fmul float %1032, 2.000000e+00
  %1034 = getelementptr inbounds i8, i8* %967, i64 4
  %1035 = bitcast i8* %1034 to float*
  %1036 = load float, float* %1035, align 4
  %1037 = fmul float %1033, %1036
  %1038 = fsub float 0.000000e+00, %1037
  %1039 = getelementptr inbounds i8, i8* %1026, i64 4
  %1040 = bitcast i8* %1039 to float*
  store float %1038, float* %1040, align 4
  %1041 = load float, float* %1010, align 4
  %1042 = fmul float %1041, 2.000000e+00
  %1043 = getelementptr inbounds i8, i8* %967, i64 8
  %1044 = bitcast i8* %1043 to float*
  %1045 = load float, float* %1044, align 4
  %1046 = fmul float %1042, %1045
  %1047 = fsub float 0.000000e+00, %1046
  %1048 = getelementptr inbounds i8, i8* %1026, i64 8
  %1049 = bitcast i8* %1048 to float*
  store float %1047, float* %1049, align 4
  %1050 = getelementptr inbounds i8, i8* %967, i64 4
  %1051 = bitcast i8* %1050 to float*
  %1052 = load float, float* %1051, align 4
  %1053 = fmul float %1052, 2.000000e+00
  %1054 = load float, float* %1010, align 4
  %1055 = fmul float %1053, %1054
  %1056 = fsub float 0.000000e+00, %1055
  %1057 = getelementptr inbounds i8, i8* %1026, i64 12
  %1058 = bitcast i8* %1057 to float*
  store float %1056, float* %1058, align 4
  %1059 = load float, float* %1051, align 4
  %1060 = fmul float %1059, 2.000000e+00
  %1061 = fmul float %1060, %1059
  %1062 = fsub float 1.000000e+00, %1061
  %1063 = getelementptr inbounds i8, i8* %1026, i64 16
  %1064 = bitcast i8* %1063 to float*
  store float %1062, float* %1064, align 4
  %1065 = load float, float* %1051, align 4
  %1066 = fmul float %1065, 2.000000e+00
  %1067 = getelementptr inbounds i8, i8* %967, i64 8
  %1068 = bitcast i8* %1067 to float*
  %1069 = load float, float* %1068, align 4
  %1070 = fmul float %1066, %1069
  %1071 = fsub float 0.000000e+00, %1070
  %1072 = getelementptr inbounds i8, i8* %1026, i64 20
  %1073 = bitcast i8* %1072 to float*
  store float %1071, float* %1073, align 4
  %1074 = getelementptr inbounds i8, i8* %967, i64 8
  %1075 = bitcast i8* %1074 to float*
  %1076 = load float, float* %1075, align 4
  %1077 = fmul float %1076, 2.000000e+00
  %1078 = load float, float* %1010, align 4
  %1079 = fmul float %1077, %1078
  %1080 = fsub float 0.000000e+00, %1079
  %1081 = getelementptr inbounds i8, i8* %1026, i64 24
  %1082 = bitcast i8* %1081 to float*
  store float %1080, float* %1082, align 4
  %1083 = load float, float* %1075, align 4
  %1084 = fmul float %1083, 2.000000e+00
  %1085 = getelementptr inbounds i8, i8* %967, i64 4
  %1086 = bitcast i8* %1085 to float*
  %1087 = load float, float* %1086, align 4
  %1088 = fmul float %1084, %1087
  %1089 = fsub float 0.000000e+00, %1088
  %1090 = getelementptr inbounds i8, i8* %1026, i64 28
  %1091 = bitcast i8* %1090 to float*
  store float %1089, float* %1091, align 4
  %1092 = load float, float* %1075, align 4
  %1093 = fmul float %1092, 2.000000e+00
  %1094 = fmul float %1093, %1092
  %1095 = fsub float 1.000000e+00, %1094
  %1096 = getelementptr inbounds i8, i8* %1026, i64 32
  %1097 = bitcast i8* %1096 to float*
  store float %1095, float* %1097, align 4
  %1098 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #8
  %1099 = bitcast i8* %1098 to float*
  store float 1.000000e+00, float* %1099, align 4
  %1100 = getelementptr inbounds i8, i8* %1098, i64 4
  %1101 = bitcast i8* %1100 to float*
  store float 0.000000e+00, float* %1101, align 4
  %1102 = getelementptr inbounds i8, i8* %1098, i64 8
  %1103 = bitcast i8* %1102 to float*
  store float 0.000000e+00, float* %1103, align 4
  %1104 = getelementptr inbounds i8, i8* %1098, i64 12
  %1105 = bitcast i8* %1104 to float*
  store float 0.000000e+00, float* %1105, align 4
  %1106 = getelementptr inbounds i8, i8* %1098, i64 16
  %1107 = bitcast i8* %1106 to float*
  store float 0.000000e+00, float* %1107, align 4
  %1108 = bitcast i8* %1026 to i32*
  %1109 = load i32, i32* %1108, align 4
  %1110 = getelementptr inbounds i8, i8* %1098, i64 20
  %1111 = bitcast i8* %1110 to i32*
  store i32 %1109, i32* %1111, align 4
  %1112 = getelementptr inbounds i8, i8* %1026, i64 4
  %1113 = bitcast i8* %1112 to i32*
  %1114 = load i32, i32* %1113, align 4
  %1115 = getelementptr inbounds i8, i8* %1098, i64 24
  %1116 = bitcast i8* %1115 to i32*
  store i32 %1114, i32* %1116, align 4
  %1117 = getelementptr inbounds i8, i8* %1026, i64 8
  %1118 = bitcast i8* %1117 to i32*
  %1119 = load i32, i32* %1118, align 4
  %1120 = getelementptr inbounds i8, i8* %1098, i64 28
  %1121 = bitcast i8* %1120 to i32*
  store i32 %1119, i32* %1121, align 4
  %1122 = getelementptr inbounds i8, i8* %1098, i64 32
  %1123 = bitcast i8* %1122 to float*
  store float 0.000000e+00, float* %1123, align 4
  %1124 = getelementptr inbounds i8, i8* %1026, i64 12
  %1125 = bitcast i8* %1124 to i32*
  %1126 = load i32, i32* %1125, align 4
  %1127 = getelementptr inbounds i8, i8* %1098, i64 36
  %1128 = bitcast i8* %1127 to i32*
  store i32 %1126, i32* %1128, align 4
  %1129 = getelementptr inbounds i8, i8* %1026, i64 16
  %1130 = bitcast i8* %1129 to i32*
  %1131 = load i32, i32* %1130, align 4
  %1132 = getelementptr inbounds i8, i8* %1098, i64 40
  %1133 = bitcast i8* %1132 to i32*
  store i32 %1131, i32* %1133, align 4
  %1134 = getelementptr inbounds i8, i8* %1026, i64 20
  %1135 = bitcast i8* %1134 to i32*
  %1136 = load i32, i32* %1135, align 4
  %1137 = getelementptr inbounds i8, i8* %1098, i64 44
  %1138 = bitcast i8* %1137 to i32*
  store i32 %1136, i32* %1138, align 4
  %1139 = getelementptr inbounds i8, i8* %1098, i64 48
  %1140 = bitcast i8* %1139 to float*
  store float 0.000000e+00, float* %1140, align 4
  %1141 = getelementptr inbounds i8, i8* %1026, i64 24
  %1142 = bitcast i8* %1141 to i32*
  %1143 = load i32, i32* %1142, align 4
  %1144 = getelementptr inbounds i8, i8* %1098, i64 52
  %1145 = bitcast i8* %1144 to i32*
  store i32 %1143, i32* %1145, align 4
  %1146 = getelementptr inbounds i8, i8* %1026, i64 28
  %1147 = bitcast i8* %1146 to i32*
  %1148 = load i32, i32* %1147, align 4
  %1149 = getelementptr inbounds i8, i8* %1098, i64 56
  %1150 = bitcast i8* %1149 to i32*
  store i32 %1148, i32* %1150, align 4
  %1151 = getelementptr inbounds i8, i8* %1026, i64 32
  %1152 = bitcast i8* %1151 to i32*
  %1153 = load i32, i32* %1152, align 4
  %1154 = getelementptr inbounds i8, i8* %1098, i64 60
  %1155 = bitcast i8* %1154 to i32*
  store i32 %1153, i32* %1155, align 4
  store float 0.000000e+00, float* %2, align 4
  %1156 = load float, float* %1099, align 4
  %1157 = load float, float* %0, align 4
  %1158 = fmul float %1156, %1157
  %1159 = fadd float %1158, 0.000000e+00
  store float %1159, float* %2, align 4
  %1160 = getelementptr inbounds i8, i8* %1098, i64 4
  %1161 = bitcast i8* %1160 to float*
  %1162 = load float, float* %1161, align 4
  %1163 = getelementptr inbounds float, float* %0, i64 4
  %1164 = load float, float* %1163, align 4
  %1165 = fmul float %1162, %1164
  %1166 = load float, float* %2, align 4
  %1167 = fadd float %1166, %1165
  store float %1167, float* %2, align 4
  %1168 = getelementptr inbounds i8, i8* %1098, i64 8
  %1169 = bitcast i8* %1168 to float*
  %1170 = load float, float* %1169, align 4
  %1171 = getelementptr inbounds float, float* %0, i64 8
  %1172 = load float, float* %1171, align 4
  %1173 = fmul float %1170, %1172
  %1174 = load float, float* %2, align 4
  %1175 = fadd float %1174, %1173
  store float %1175, float* %2, align 4
  %1176 = getelementptr inbounds i8, i8* %1098, i64 12
  %1177 = bitcast i8* %1176 to float*
  %1178 = load float, float* %1177, align 4
  %1179 = getelementptr inbounds float, float* %0, i64 12
  %1180 = load float, float* %1179, align 4
  %1181 = fmul float %1178, %1180
  %1182 = load float, float* %2, align 4
  %1183 = fadd float %1182, %1181
  store float %1183, float* %2, align 4
  %1184 = getelementptr inbounds float, float* %2, i64 1
  store float 0.000000e+00, float* %1184, align 4
  %1185 = getelementptr inbounds float, float* %2, i64 1
  %1186 = load float, float* %1099, align 4
  %1187 = getelementptr inbounds float, float* %0, i64 1
  %1188 = load float, float* %1187, align 4
  %1189 = fmul float %1186, %1188
  %1190 = fadd float %1189, 0.000000e+00
  store float %1190, float* %1185, align 4
  %1191 = getelementptr inbounds i8, i8* %1098, i64 4
  %1192 = bitcast i8* %1191 to float*
  %1193 = load float, float* %1192, align 4
  %1194 = getelementptr inbounds float, float* %0, i64 5
  %1195 = load float, float* %1194, align 4
  %1196 = fmul float %1193, %1195
  %1197 = load float, float* %1185, align 4
  %1198 = fadd float %1197, %1196
  store float %1198, float* %1185, align 4
  %1199 = getelementptr inbounds i8, i8* %1098, i64 8
  %1200 = bitcast i8* %1199 to float*
  %1201 = load float, float* %1200, align 4
  %1202 = getelementptr inbounds float, float* %0, i64 9
  %1203 = load float, float* %1202, align 4
  %1204 = fmul float %1201, %1203
  %1205 = load float, float* %1185, align 4
  %1206 = fadd float %1205, %1204
  store float %1206, float* %1185, align 4
  %1207 = getelementptr inbounds i8, i8* %1098, i64 12
  %1208 = bitcast i8* %1207 to float*
  %1209 = load float, float* %1208, align 4
  %1210 = getelementptr inbounds float, float* %0, i64 13
  %1211 = load float, float* %1210, align 4
  %1212 = fmul float %1209, %1211
  %1213 = load float, float* %1185, align 4
  %1214 = fadd float %1213, %1212
  store float %1214, float* %1185, align 4
  %1215 = getelementptr inbounds float, float* %2, i64 2
  store float 0.000000e+00, float* %1215, align 4
  %1216 = getelementptr inbounds float, float* %2, i64 2
  %1217 = load float, float* %1099, align 4
  %1218 = getelementptr inbounds float, float* %0, i64 2
  %1219 = load float, float* %1218, align 4
  %1220 = fmul float %1217, %1219
  %1221 = fadd float %1220, 0.000000e+00
  store float %1221, float* %1216, align 4
  %1222 = getelementptr inbounds i8, i8* %1098, i64 4
  %1223 = bitcast i8* %1222 to float*
  %1224 = load float, float* %1223, align 4
  %1225 = getelementptr inbounds float, float* %0, i64 6
  %1226 = load float, float* %1225, align 4
  %1227 = fmul float %1224, %1226
  %1228 = load float, float* %1216, align 4
  %1229 = fadd float %1228, %1227
  store float %1229, float* %1216, align 4
  %1230 = getelementptr inbounds i8, i8* %1098, i64 8
  %1231 = bitcast i8* %1230 to float*
  %1232 = load float, float* %1231, align 4
  %1233 = getelementptr inbounds float, float* %0, i64 10
  %1234 = load float, float* %1233, align 4
  %1235 = fmul float %1232, %1234
  %1236 = load float, float* %1216, align 4
  %1237 = fadd float %1236, %1235
  store float %1237, float* %1216, align 4
  %1238 = getelementptr inbounds i8, i8* %1098, i64 12
  %1239 = bitcast i8* %1238 to float*
  %1240 = load float, float* %1239, align 4
  %1241 = getelementptr inbounds float, float* %0, i64 14
  %1242 = load float, float* %1241, align 4
  %1243 = fmul float %1240, %1242
  %1244 = load float, float* %1216, align 4
  %1245 = fadd float %1244, %1243
  store float %1245, float* %1216, align 4
  %1246 = getelementptr inbounds float, float* %2, i64 3
  store float 0.000000e+00, float* %1246, align 4
  %1247 = getelementptr inbounds float, float* %2, i64 3
  %1248 = load float, float* %1099, align 4
  %1249 = getelementptr inbounds float, float* %0, i64 3
  %1250 = load float, float* %1249, align 4
  %1251 = fmul float %1248, %1250
  %1252 = fadd float %1251, 0.000000e+00
  store float %1252, float* %1247, align 4
  %1253 = getelementptr inbounds i8, i8* %1098, i64 4
  %1254 = bitcast i8* %1253 to float*
  %1255 = load float, float* %1254, align 4
  %1256 = getelementptr inbounds float, float* %0, i64 7
  %1257 = load float, float* %1256, align 4
  %1258 = fmul float %1255, %1257
  %1259 = load float, float* %1247, align 4
  %1260 = fadd float %1259, %1258
  store float %1260, float* %1247, align 4
  %1261 = getelementptr inbounds i8, i8* %1098, i64 8
  %1262 = bitcast i8* %1261 to float*
  %1263 = load float, float* %1262, align 4
  %1264 = getelementptr inbounds float, float* %0, i64 11
  %1265 = load float, float* %1264, align 4
  %1266 = fmul float %1263, %1265
  %1267 = load float, float* %1247, align 4
  %1268 = fadd float %1267, %1266
  store float %1268, float* %1247, align 4
  %1269 = getelementptr inbounds i8, i8* %1098, i64 12
  %1270 = bitcast i8* %1269 to float*
  %1271 = load float, float* %1270, align 4
  %1272 = getelementptr inbounds float, float* %0, i64 15
  %1273 = load float, float* %1272, align 4
  %1274 = fmul float %1271, %1273
  %1275 = load float, float* %1247, align 4
  %1276 = fadd float %1275, %1274
  store float %1276, float* %1247, align 4
  %1277 = getelementptr inbounds i8, i8* %1098, i64 16
  %1278 = bitcast i8* %1277 to float*
  %1279 = getelementptr inbounds float, float* %2, i64 4
  store float 0.000000e+00, float* %1279, align 4
  %1280 = getelementptr inbounds float, float* %2, i64 4
  %1281 = load float, float* %1278, align 4
  %1282 = load float, float* %0, align 4
  %1283 = fmul float %1281, %1282
  %1284 = fadd float %1283, 0.000000e+00
  store float %1284, float* %1280, align 4
  %1285 = getelementptr inbounds i8, i8* %1098, i64 20
  %1286 = bitcast i8* %1285 to float*
  %1287 = load float, float* %1286, align 4
  %1288 = getelementptr inbounds float, float* %0, i64 4
  %1289 = load float, float* %1288, align 4
  %1290 = fmul float %1287, %1289
  %1291 = load float, float* %1280, align 4
  %1292 = fadd float %1291, %1290
  store float %1292, float* %1280, align 4
  %1293 = getelementptr inbounds i8, i8* %1098, i64 24
  %1294 = bitcast i8* %1293 to float*
  %1295 = load float, float* %1294, align 4
  %1296 = getelementptr inbounds float, float* %0, i64 8
  %1297 = load float, float* %1296, align 4
  %1298 = fmul float %1295, %1297
  %1299 = load float, float* %1280, align 4
  %1300 = fadd float %1299, %1298
  store float %1300, float* %1280, align 4
  %1301 = getelementptr inbounds i8, i8* %1098, i64 28
  %1302 = bitcast i8* %1301 to float*
  %1303 = load float, float* %1302, align 4
  %1304 = getelementptr inbounds float, float* %0, i64 12
  %1305 = load float, float* %1304, align 4
  %1306 = fmul float %1303, %1305
  %1307 = load float, float* %1280, align 4
  %1308 = fadd float %1307, %1306
  store float %1308, float* %1280, align 4
  %1309 = getelementptr inbounds float, float* %2, i64 5
  store float 0.000000e+00, float* %1309, align 4
  %1310 = getelementptr inbounds float, float* %2, i64 5
  %1311 = load float, float* %1278, align 4
  %1312 = getelementptr inbounds float, float* %0, i64 1
  %1313 = load float, float* %1312, align 4
  %1314 = fmul float %1311, %1313
  %1315 = fadd float %1314, 0.000000e+00
  store float %1315, float* %1310, align 4
  %1316 = getelementptr inbounds i8, i8* %1098, i64 20
  %1317 = bitcast i8* %1316 to float*
  %1318 = load float, float* %1317, align 4
  %1319 = getelementptr inbounds float, float* %0, i64 5
  %1320 = load float, float* %1319, align 4
  %1321 = fmul float %1318, %1320
  %1322 = load float, float* %1310, align 4
  %1323 = fadd float %1322, %1321
  store float %1323, float* %1310, align 4
  %1324 = getelementptr inbounds i8, i8* %1098, i64 24
  %1325 = bitcast i8* %1324 to float*
  %1326 = load float, float* %1325, align 4
  %1327 = getelementptr inbounds float, float* %0, i64 9
  %1328 = load float, float* %1327, align 4
  %1329 = fmul float %1326, %1328
  %1330 = load float, float* %1310, align 4
  %1331 = fadd float %1330, %1329
  store float %1331, float* %1310, align 4
  %1332 = getelementptr inbounds i8, i8* %1098, i64 28
  %1333 = bitcast i8* %1332 to float*
  %1334 = load float, float* %1333, align 4
  %1335 = getelementptr inbounds float, float* %0, i64 13
  %1336 = load float, float* %1335, align 4
  %1337 = fmul float %1334, %1336
  %1338 = load float, float* %1310, align 4
  %1339 = fadd float %1338, %1337
  store float %1339, float* %1310, align 4
  %1340 = getelementptr inbounds float, float* %2, i64 6
  store float 0.000000e+00, float* %1340, align 4
  %1341 = getelementptr inbounds float, float* %2, i64 6
  %1342 = load float, float* %1278, align 4
  %1343 = getelementptr inbounds float, float* %0, i64 2
  %1344 = load float, float* %1343, align 4
  %1345 = fmul float %1342, %1344
  %1346 = fadd float %1345, 0.000000e+00
  store float %1346, float* %1341, align 4
  %1347 = getelementptr inbounds i8, i8* %1098, i64 20
  %1348 = bitcast i8* %1347 to float*
  %1349 = load float, float* %1348, align 4
  %1350 = getelementptr inbounds float, float* %0, i64 6
  %1351 = load float, float* %1350, align 4
  %1352 = fmul float %1349, %1351
  %1353 = load float, float* %1341, align 4
  %1354 = fadd float %1353, %1352
  store float %1354, float* %1341, align 4
  %1355 = getelementptr inbounds i8, i8* %1098, i64 24
  %1356 = bitcast i8* %1355 to float*
  %1357 = load float, float* %1356, align 4
  %1358 = getelementptr inbounds float, float* %0, i64 10
  %1359 = load float, float* %1358, align 4
  %1360 = fmul float %1357, %1359
  %1361 = load float, float* %1341, align 4
  %1362 = fadd float %1361, %1360
  store float %1362, float* %1341, align 4
  %1363 = getelementptr inbounds i8, i8* %1098, i64 28
  %1364 = bitcast i8* %1363 to float*
  %1365 = load float, float* %1364, align 4
  %1366 = getelementptr inbounds float, float* %0, i64 14
  %1367 = load float, float* %1366, align 4
  %1368 = fmul float %1365, %1367
  %1369 = load float, float* %1341, align 4
  %1370 = fadd float %1369, %1368
  store float %1370, float* %1341, align 4
  %1371 = getelementptr inbounds float, float* %2, i64 7
  store float 0.000000e+00, float* %1371, align 4
  %1372 = getelementptr inbounds float, float* %2, i64 7
  %1373 = load float, float* %1278, align 4
  %1374 = getelementptr inbounds float, float* %0, i64 3
  %1375 = load float, float* %1374, align 4
  %1376 = fmul float %1373, %1375
  %1377 = fadd float %1376, 0.000000e+00
  store float %1377, float* %1372, align 4
  %1378 = getelementptr inbounds i8, i8* %1098, i64 20
  %1379 = bitcast i8* %1378 to float*
  %1380 = load float, float* %1379, align 4
  %1381 = getelementptr inbounds float, float* %0, i64 7
  %1382 = load float, float* %1381, align 4
  %1383 = fmul float %1380, %1382
  %1384 = load float, float* %1372, align 4
  %1385 = fadd float %1384, %1383
  store float %1385, float* %1372, align 4
  %1386 = getelementptr inbounds i8, i8* %1098, i64 24
  %1387 = bitcast i8* %1386 to float*
  %1388 = load float, float* %1387, align 4
  %1389 = getelementptr inbounds float, float* %0, i64 11
  %1390 = load float, float* %1389, align 4
  %1391 = fmul float %1388, %1390
  %1392 = load float, float* %1372, align 4
  %1393 = fadd float %1392, %1391
  store float %1393, float* %1372, align 4
  %1394 = getelementptr inbounds i8, i8* %1098, i64 28
  %1395 = bitcast i8* %1394 to float*
  %1396 = load float, float* %1395, align 4
  %1397 = getelementptr inbounds float, float* %0, i64 15
  %1398 = load float, float* %1397, align 4
  %1399 = fmul float %1396, %1398
  %1400 = load float, float* %1372, align 4
  %1401 = fadd float %1400, %1399
  store float %1401, float* %1372, align 4
  %1402 = getelementptr inbounds i8, i8* %1098, i64 32
  %1403 = bitcast i8* %1402 to float*
  %1404 = getelementptr inbounds float, float* %2, i64 8
  store float 0.000000e+00, float* %1404, align 4
  %1405 = getelementptr inbounds float, float* %2, i64 8
  %1406 = load float, float* %1403, align 4
  %1407 = load float, float* %0, align 4
  %1408 = fmul float %1406, %1407
  %1409 = fadd float %1408, 0.000000e+00
  store float %1409, float* %1405, align 4
  %1410 = getelementptr inbounds i8, i8* %1098, i64 36
  %1411 = bitcast i8* %1410 to float*
  %1412 = load float, float* %1411, align 4
  %1413 = getelementptr inbounds float, float* %0, i64 4
  %1414 = load float, float* %1413, align 4
  %1415 = fmul float %1412, %1414
  %1416 = load float, float* %1405, align 4
  %1417 = fadd float %1416, %1415
  store float %1417, float* %1405, align 4
  %1418 = getelementptr inbounds i8, i8* %1098, i64 40
  %1419 = bitcast i8* %1418 to float*
  %1420 = load float, float* %1419, align 4
  %1421 = getelementptr inbounds float, float* %0, i64 8
  %1422 = load float, float* %1421, align 4
  %1423 = fmul float %1420, %1422
  %1424 = load float, float* %1405, align 4
  %1425 = fadd float %1424, %1423
  store float %1425, float* %1405, align 4
  %1426 = getelementptr inbounds i8, i8* %1098, i64 44
  %1427 = bitcast i8* %1426 to float*
  %1428 = load float, float* %1427, align 4
  %1429 = getelementptr inbounds float, float* %0, i64 12
  %1430 = load float, float* %1429, align 4
  %1431 = fmul float %1428, %1430
  %1432 = load float, float* %1405, align 4
  %1433 = fadd float %1432, %1431
  store float %1433, float* %1405, align 4
  %1434 = getelementptr inbounds float, float* %2, i64 9
  store float 0.000000e+00, float* %1434, align 4
  %1435 = getelementptr inbounds float, float* %2, i64 9
  %1436 = load float, float* %1403, align 4
  %1437 = getelementptr inbounds float, float* %0, i64 1
  %1438 = load float, float* %1437, align 4
  %1439 = fmul float %1436, %1438
  %1440 = fadd float %1439, 0.000000e+00
  store float %1440, float* %1435, align 4
  %1441 = getelementptr inbounds i8, i8* %1098, i64 36
  %1442 = bitcast i8* %1441 to float*
  %1443 = load float, float* %1442, align 4
  %1444 = getelementptr inbounds float, float* %0, i64 5
  %1445 = load float, float* %1444, align 4
  %1446 = fmul float %1443, %1445
  %1447 = load float, float* %1435, align 4
  %1448 = fadd float %1447, %1446
  store float %1448, float* %1435, align 4
  %1449 = getelementptr inbounds i8, i8* %1098, i64 40
  %1450 = bitcast i8* %1449 to float*
  %1451 = load float, float* %1450, align 4
  %1452 = getelementptr inbounds float, float* %0, i64 9
  %1453 = load float, float* %1452, align 4
  %1454 = fmul float %1451, %1453
  %1455 = load float, float* %1435, align 4
  %1456 = fadd float %1455, %1454
  store float %1456, float* %1435, align 4
  %1457 = getelementptr inbounds i8, i8* %1098, i64 44
  %1458 = bitcast i8* %1457 to float*
  %1459 = load float, float* %1458, align 4
  %1460 = getelementptr inbounds float, float* %0, i64 13
  %1461 = load float, float* %1460, align 4
  %1462 = fmul float %1459, %1461
  %1463 = load float, float* %1435, align 4
  %1464 = fadd float %1463, %1462
  store float %1464, float* %1435, align 4
  %1465 = getelementptr inbounds float, float* %2, i64 10
  store float 0.000000e+00, float* %1465, align 4
  %1466 = getelementptr inbounds float, float* %2, i64 10
  %1467 = load float, float* %1403, align 4
  %1468 = getelementptr inbounds float, float* %0, i64 2
  %1469 = load float, float* %1468, align 4
  %1470 = fmul float %1467, %1469
  %1471 = fadd float %1470, 0.000000e+00
  store float %1471, float* %1466, align 4
  %1472 = getelementptr inbounds i8, i8* %1098, i64 36
  %1473 = bitcast i8* %1472 to float*
  %1474 = load float, float* %1473, align 4
  %1475 = getelementptr inbounds float, float* %0, i64 6
  %1476 = load float, float* %1475, align 4
  %1477 = fmul float %1474, %1476
  %1478 = load float, float* %1466, align 4
  %1479 = fadd float %1478, %1477
  store float %1479, float* %1466, align 4
  %1480 = getelementptr inbounds i8, i8* %1098, i64 40
  %1481 = bitcast i8* %1480 to float*
  %1482 = load float, float* %1481, align 4
  %1483 = getelementptr inbounds float, float* %0, i64 10
  %1484 = load float, float* %1483, align 4
  %1485 = fmul float %1482, %1484
  %1486 = load float, float* %1466, align 4
  %1487 = fadd float %1486, %1485
  store float %1487, float* %1466, align 4
  %1488 = getelementptr inbounds i8, i8* %1098, i64 44
  %1489 = bitcast i8* %1488 to float*
  %1490 = load float, float* %1489, align 4
  %1491 = getelementptr inbounds float, float* %0, i64 14
  %1492 = load float, float* %1491, align 4
  %1493 = fmul float %1490, %1492
  %1494 = load float, float* %1466, align 4
  %1495 = fadd float %1494, %1493
  store float %1495, float* %1466, align 4
  %1496 = getelementptr inbounds float, float* %2, i64 11
  store float 0.000000e+00, float* %1496, align 4
  %1497 = getelementptr inbounds float, float* %2, i64 11
  %1498 = load float, float* %1403, align 4
  %1499 = getelementptr inbounds float, float* %0, i64 3
  %1500 = load float, float* %1499, align 4
  %1501 = fmul float %1498, %1500
  %1502 = fadd float %1501, 0.000000e+00
  store float %1502, float* %1497, align 4
  %1503 = getelementptr inbounds i8, i8* %1098, i64 36
  %1504 = bitcast i8* %1503 to float*
  %1505 = load float, float* %1504, align 4
  %1506 = getelementptr inbounds float, float* %0, i64 7
  %1507 = load float, float* %1506, align 4
  %1508 = fmul float %1505, %1507
  %1509 = load float, float* %1497, align 4
  %1510 = fadd float %1509, %1508
  store float %1510, float* %1497, align 4
  %1511 = getelementptr inbounds i8, i8* %1098, i64 40
  %1512 = bitcast i8* %1511 to float*
  %1513 = load float, float* %1512, align 4
  %1514 = getelementptr inbounds float, float* %0, i64 11
  %1515 = load float, float* %1514, align 4
  %1516 = fmul float %1513, %1515
  %1517 = load float, float* %1497, align 4
  %1518 = fadd float %1517, %1516
  store float %1518, float* %1497, align 4
  %1519 = getelementptr inbounds i8, i8* %1098, i64 44
  %1520 = bitcast i8* %1519 to float*
  %1521 = load float, float* %1520, align 4
  %1522 = getelementptr inbounds float, float* %0, i64 15
  %1523 = load float, float* %1522, align 4
  %1524 = fmul float %1521, %1523
  %1525 = load float, float* %1497, align 4
  %1526 = fadd float %1525, %1524
  store float %1526, float* %1497, align 4
  %1527 = getelementptr inbounds i8, i8* %1098, i64 48
  %1528 = bitcast i8* %1527 to float*
  %1529 = getelementptr inbounds float, float* %2, i64 12
  store float 0.000000e+00, float* %1529, align 4
  %1530 = getelementptr inbounds float, float* %2, i64 12
  %1531 = load float, float* %1528, align 4
  %1532 = load float, float* %0, align 4
  %1533 = fmul float %1531, %1532
  %1534 = fadd float %1533, 0.000000e+00
  store float %1534, float* %1530, align 4
  %1535 = getelementptr inbounds i8, i8* %1098, i64 52
  %1536 = bitcast i8* %1535 to float*
  %1537 = load float, float* %1536, align 4
  %1538 = getelementptr inbounds float, float* %0, i64 4
  %1539 = load float, float* %1538, align 4
  %1540 = fmul float %1537, %1539
  %1541 = load float, float* %1530, align 4
  %1542 = fadd float %1541, %1540
  store float %1542, float* %1530, align 4
  %1543 = getelementptr inbounds i8, i8* %1098, i64 56
  %1544 = bitcast i8* %1543 to float*
  %1545 = load float, float* %1544, align 4
  %1546 = getelementptr inbounds float, float* %0, i64 8
  %1547 = load float, float* %1546, align 4
  %1548 = fmul float %1545, %1547
  %1549 = load float, float* %1530, align 4
  %1550 = fadd float %1549, %1548
  store float %1550, float* %1530, align 4
  %1551 = getelementptr inbounds i8, i8* %1098, i64 60
  %1552 = bitcast i8* %1551 to float*
  %1553 = load float, float* %1552, align 4
  %1554 = getelementptr inbounds float, float* %0, i64 12
  %1555 = load float, float* %1554, align 4
  %1556 = fmul float %1553, %1555
  %1557 = load float, float* %1530, align 4
  %1558 = fadd float %1557, %1556
  store float %1558, float* %1530, align 4
  %1559 = getelementptr inbounds float, float* %2, i64 13
  store float 0.000000e+00, float* %1559, align 4
  %1560 = getelementptr inbounds float, float* %2, i64 13
  %1561 = load float, float* %1528, align 4
  %1562 = getelementptr inbounds float, float* %0, i64 1
  %1563 = load float, float* %1562, align 4
  %1564 = fmul float %1561, %1563
  %1565 = fadd float %1564, 0.000000e+00
  store float %1565, float* %1560, align 4
  %1566 = getelementptr inbounds i8, i8* %1098, i64 52
  %1567 = bitcast i8* %1566 to float*
  %1568 = load float, float* %1567, align 4
  %1569 = getelementptr inbounds float, float* %0, i64 5
  %1570 = load float, float* %1569, align 4
  %1571 = fmul float %1568, %1570
  %1572 = load float, float* %1560, align 4
  %1573 = fadd float %1572, %1571
  store float %1573, float* %1560, align 4
  %1574 = getelementptr inbounds i8, i8* %1098, i64 56
  %1575 = bitcast i8* %1574 to float*
  %1576 = load float, float* %1575, align 4
  %1577 = getelementptr inbounds float, float* %0, i64 9
  %1578 = load float, float* %1577, align 4
  %1579 = fmul float %1576, %1578
  %1580 = load float, float* %1560, align 4
  %1581 = fadd float %1580, %1579
  store float %1581, float* %1560, align 4
  %1582 = getelementptr inbounds i8, i8* %1098, i64 60
  %1583 = bitcast i8* %1582 to float*
  %1584 = load float, float* %1583, align 4
  %1585 = getelementptr inbounds float, float* %0, i64 13
  %1586 = load float, float* %1585, align 4
  %1587 = fmul float %1584, %1586
  %1588 = load float, float* %1560, align 4
  %1589 = fadd float %1588, %1587
  store float %1589, float* %1560, align 4
  %1590 = getelementptr inbounds float, float* %2, i64 14
  store float 0.000000e+00, float* %1590, align 4
  %1591 = getelementptr inbounds float, float* %2, i64 14
  %1592 = load float, float* %1528, align 4
  %1593 = getelementptr inbounds float, float* %0, i64 2
  %1594 = load float, float* %1593, align 4
  %1595 = fmul float %1592, %1594
  %1596 = fadd float %1595, 0.000000e+00
  store float %1596, float* %1591, align 4
  %1597 = getelementptr inbounds i8, i8* %1098, i64 52
  %1598 = bitcast i8* %1597 to float*
  %1599 = load float, float* %1598, align 4
  %1600 = getelementptr inbounds float, float* %0, i64 6
  %1601 = load float, float* %1600, align 4
  %1602 = fmul float %1599, %1601
  %1603 = load float, float* %1591, align 4
  %1604 = fadd float %1603, %1602
  store float %1604, float* %1591, align 4
  %1605 = getelementptr inbounds i8, i8* %1098, i64 56
  %1606 = bitcast i8* %1605 to float*
  %1607 = load float, float* %1606, align 4
  %1608 = getelementptr inbounds float, float* %0, i64 10
  %1609 = load float, float* %1608, align 4
  %1610 = fmul float %1607, %1609
  %1611 = load float, float* %1591, align 4
  %1612 = fadd float %1611, %1610
  store float %1612, float* %1591, align 4
  %1613 = getelementptr inbounds i8, i8* %1098, i64 60
  %1614 = bitcast i8* %1613 to float*
  %1615 = load float, float* %1614, align 4
  %1616 = getelementptr inbounds float, float* %0, i64 14
  %1617 = load float, float* %1616, align 4
  %1618 = fmul float %1615, %1617
  %1619 = load float, float* %1591, align 4
  %1620 = fadd float %1619, %1618
  store float %1620, float* %1591, align 4
  %1621 = getelementptr inbounds float, float* %2, i64 15
  store float 0.000000e+00, float* %1621, align 4
  %1622 = getelementptr inbounds float, float* %2, i64 15
  %1623 = load float, float* %1528, align 4
  %1624 = getelementptr inbounds float, float* %0, i64 3
  %1625 = load float, float* %1624, align 4
  %1626 = fmul float %1623, %1625
  %1627 = fadd float %1626, 0.000000e+00
  store float %1627, float* %1622, align 4
  %1628 = getelementptr inbounds i8, i8* %1098, i64 52
  %1629 = bitcast i8* %1628 to float*
  %1630 = load float, float* %1629, align 4
  %1631 = getelementptr inbounds float, float* %0, i64 7
  %1632 = load float, float* %1631, align 4
  %1633 = fmul float %1630, %1632
  %1634 = load float, float* %1622, align 4
  %1635 = fadd float %1634, %1633
  store float %1635, float* %1622, align 4
  %1636 = getelementptr inbounds i8, i8* %1098, i64 56
  %1637 = bitcast i8* %1636 to float*
  %1638 = load float, float* %1637, align 4
  %1639 = getelementptr inbounds float, float* %0, i64 11
  %1640 = load float, float* %1639, align 4
  %1641 = fmul float %1638, %1640
  %1642 = load float, float* %1622, align 4
  %1643 = fadd float %1642, %1641
  store float %1643, float* %1622, align 4
  %1644 = getelementptr inbounds i8, i8* %1098, i64 60
  %1645 = bitcast i8* %1644 to float*
  %1646 = load float, float* %1645, align 4
  %1647 = getelementptr inbounds float, float* %0, i64 15
  %1648 = load float, float* %1647, align 4
  %1649 = fmul float %1646, %1648
  %1650 = load float, float* %1622, align 4
  %1651 = fadd float %1650, %1649
  store float %1651, float* %1622, align 4
  %1652 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #8
  %1653 = bitcast i8* %1652 to float*
  %1654 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #8
  %1655 = bitcast i8* %1654 to float*
  %1656 = getelementptr inbounds float, float* %2, i64 10
  %1657 = bitcast float* %1656 to i32*
  %1658 = load i32, i32* %1657, align 4
  %1659 = bitcast i8* %1652 to i32*
  store i32 %1658, i32* %1659, align 4
  %1660 = getelementptr inbounds i8, i8* %8, i64 40
  %1661 = bitcast i8* %1660 to i32*
  %1662 = load i32, i32* %1661, align 4
  %1663 = bitcast i8* %1654 to i32*
  store i32 %1662, i32* %1663, align 4
  %1664 = getelementptr inbounds float, float* %2, i64 14
  %1665 = bitcast float* %1664 to i32*
  %1666 = load i32, i32* %1665, align 4
  %1667 = getelementptr inbounds i8, i8* %1652, i64 4
  %1668 = bitcast i8* %1667 to i32*
  store i32 %1666, i32* %1668, align 4
  %1669 = getelementptr inbounds i8, i8* %8, i64 56
  %1670 = bitcast i8* %1669 to i32*
  %1671 = load i32, i32* %1670, align 4
  %1672 = getelementptr inbounds i8, i8* %1654, i64 4
  %1673 = bitcast i8* %1672 to i32*
  store i32 %1671, i32* %1673, align 4
  %1674 = load float, float* %1653, align 4
  %1675 = fcmp ogt float %1674, 0.000000e+00
  %1676 = zext i1 %1675 to i32
  %1677 = fcmp olt float %1674, 0.000000e+00
  %.neg187 = sext i1 %1677 to i32
  %1678 = add nsw i32 %.neg187, %1676
  %1679 = sitofp i32 %1678 to float
  %1680 = load float, float* %1653, align 4
  %1681 = fpext float %1680 to double
  %square188 = fmul double %1681, %1681
  %1682 = fadd double %square188, 0.000000e+00
  %1683 = fptrunc double %1682 to float
  %1684 = getelementptr inbounds i8, i8* %1652, i64 4
  %1685 = bitcast i8* %1684 to float*
  %1686 = load float, float* %1685, align 4
  %1687 = fpext float %1686 to double
  %square189 = fmul double %1687, %1687
  %1688 = fpext float %1683 to double
  %1689 = fadd double %square189, %1688
  %1690 = fptrunc double %1689 to float
  %1691 = fneg float %1679
  %1692 = call float @llvm.sqrt.f32(float %1690)
  %1693 = fmul float %1692, %1691
  %1694 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #8
  %1695 = bitcast i8* %1694 to float*
  %1696 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #8
  %1697 = load float, float* %1653, align 4
  %1698 = load float, float* %1655, align 4
  %1699 = fmul float %1693, %1698
  %1700 = fadd float %1697, %1699
  store float %1700, float* %1695, align 4
  %1701 = getelementptr inbounds i8, i8* %1652, i64 4
  %1702 = bitcast i8* %1701 to float*
  %1703 = load float, float* %1702, align 4
  %1704 = getelementptr inbounds i8, i8* %1654, i64 4
  %1705 = bitcast i8* %1704 to float*
  %1706 = load float, float* %1705, align 4
  %1707 = fmul float %1693, %1706
  %1708 = fadd float %1703, %1707
  %1709 = getelementptr inbounds i8, i8* %1694, i64 4
  %1710 = bitcast i8* %1709 to float*
  store float %1708, float* %1710, align 4
  %1711 = load float, float* %1695, align 4
  %1712 = fpext float %1711 to double
  %square190 = fmul double %1712, %1712
  %1713 = fadd double %square190, 0.000000e+00
  %1714 = fptrunc double %1713 to float
  %1715 = getelementptr inbounds i8, i8* %1694, i64 4
  %1716 = bitcast i8* %1715 to float*
  %1717 = load float, float* %1716, align 4
  %1718 = fpext float %1717 to double
  %square191 = fmul double %1718, %1718
  %1719 = fpext float %1714 to double
  %1720 = fadd double %square191, %1719
  %1721 = fptrunc double %1720 to float
  %1722 = bitcast i8* %1696 to float*
  %1723 = call float @llvm.sqrt.f32(float %1721)
  %1724 = load float, float* %1695, align 4
  %1725 = fdiv float %1724, %1723
  store float %1725, float* %1722, align 4
  %1726 = getelementptr inbounds i8, i8* %1694, i64 4
  %1727 = bitcast i8* %1726 to float*
  %1728 = load float, float* %1727, align 4
  %1729 = fdiv float %1728, %1723
  %1730 = getelementptr inbounds i8, i8* %1696, i64 4
  %1731 = bitcast i8* %1730 to float*
  store float %1729, float* %1731, align 4
  %1732 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #8
  %1733 = bitcast i8* %1732 to float*
  %1734 = load float, float* %1722, align 4
  %1735 = fmul float %1734, 2.000000e+00
  %1736 = fmul float %1735, %1734
  %1737 = fsub float 1.000000e+00, %1736
  store float %1737, float* %1733, align 4
  %1738 = load float, float* %1722, align 4
  %1739 = fmul float %1738, 2.000000e+00
  %1740 = getelementptr inbounds i8, i8* %1696, i64 4
  %1741 = bitcast i8* %1740 to float*
  %1742 = load float, float* %1741, align 4
  %1743 = fmul float %1739, %1742
  %1744 = fsub float 0.000000e+00, %1743
  %1745 = getelementptr inbounds i8, i8* %1732, i64 4
  %1746 = bitcast i8* %1745 to float*
  store float %1744, float* %1746, align 4
  %1747 = getelementptr inbounds i8, i8* %1696, i64 4
  %1748 = bitcast i8* %1747 to float*
  %1749 = load float, float* %1748, align 4
  %1750 = fmul float %1749, 2.000000e+00
  %1751 = load float, float* %1722, align 4
  %1752 = fmul float %1750, %1751
  %1753 = fsub float 0.000000e+00, %1752
  %1754 = getelementptr inbounds i8, i8* %1732, i64 8
  %1755 = bitcast i8* %1754 to float*
  store float %1753, float* %1755, align 4
  %1756 = load float, float* %1748, align 4
  %1757 = fmul float %1756, 2.000000e+00
  %1758 = fmul float %1757, %1756
  %1759 = fsub float 1.000000e+00, %1758
  %1760 = getelementptr inbounds i8, i8* %1732, i64 12
  %1761 = bitcast i8* %1760 to float*
  store float %1759, float* %1761, align 4
  %1762 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #8
  %1763 = bitcast i8* %1762 to float*
  store float 1.000000e+00, float* %1763, align 4
  %1764 = getelementptr inbounds i8, i8* %1762, i64 4
  %1765 = bitcast i8* %1764 to float*
  store float 0.000000e+00, float* %1765, align 4
  %1766 = getelementptr inbounds i8, i8* %1762, i64 8
  %1767 = bitcast i8* %1766 to float*
  store float 0.000000e+00, float* %1767, align 4
  %1768 = getelementptr inbounds i8, i8* %1762, i64 12
  %1769 = bitcast i8* %1768 to float*
  store float 0.000000e+00, float* %1769, align 4
  %1770 = getelementptr inbounds i8, i8* %1762, i64 16
  %1771 = bitcast i8* %1770 to float*
  store float 0.000000e+00, float* %1771, align 4
  %1772 = getelementptr inbounds i8, i8* %1762, i64 20
  %1773 = bitcast i8* %1772 to float*
  store float 1.000000e+00, float* %1773, align 4
  %1774 = getelementptr inbounds i8, i8* %1762, i64 24
  %1775 = bitcast i8* %1774 to float*
  store float 0.000000e+00, float* %1775, align 4
  %1776 = getelementptr inbounds i8, i8* %1762, i64 28
  %1777 = bitcast i8* %1776 to float*
  store float 0.000000e+00, float* %1777, align 4
  %1778 = getelementptr inbounds i8, i8* %1762, i64 32
  %1779 = bitcast i8* %1778 to float*
  store float 0.000000e+00, float* %1779, align 4
  %1780 = getelementptr inbounds i8, i8* %1762, i64 36
  %1781 = bitcast i8* %1780 to float*
  store float 0.000000e+00, float* %1781, align 4
  %1782 = bitcast i8* %1732 to i32*
  %1783 = load i32, i32* %1782, align 4
  %1784 = getelementptr inbounds i8, i8* %1762, i64 40
  %1785 = bitcast i8* %1784 to i32*
  store i32 %1783, i32* %1785, align 4
  %1786 = getelementptr inbounds i8, i8* %1732, i64 4
  %1787 = bitcast i8* %1786 to i32*
  %1788 = load i32, i32* %1787, align 4
  %1789 = getelementptr inbounds i8, i8* %1762, i64 44
  %1790 = bitcast i8* %1789 to i32*
  store i32 %1788, i32* %1790, align 4
  %1791 = getelementptr inbounds i8, i8* %1762, i64 48
  %1792 = bitcast i8* %1791 to float*
  store float 0.000000e+00, float* %1792, align 4
  %1793 = getelementptr inbounds i8, i8* %1762, i64 52
  %1794 = bitcast i8* %1793 to float*
  store float 0.000000e+00, float* %1794, align 4
  %1795 = getelementptr inbounds i8, i8* %1732, i64 8
  %1796 = bitcast i8* %1795 to i32*
  %1797 = load i32, i32* %1796, align 4
  %1798 = getelementptr inbounds i8, i8* %1762, i64 56
  %1799 = bitcast i8* %1798 to i32*
  store i32 %1797, i32* %1799, align 4
  %1800 = getelementptr inbounds i8, i8* %1732, i64 12
  %1801 = bitcast i8* %1800 to i32*
  %1802 = load i32, i32* %1801, align 4
  %1803 = getelementptr inbounds i8, i8* %1762, i64 60
  %1804 = bitcast i8* %1803 to i32*
  store i32 %1802, i32* %1804, align 4
  store float 0.000000e+00, float* %2, align 4
  %1805 = load float, float* %1763, align 4
  %1806 = load float, float* %0, align 4
  %1807 = fmul float %1805, %1806
  %1808 = fadd float %1807, 0.000000e+00
  store float %1808, float* %2, align 4
  %1809 = getelementptr inbounds i8, i8* %1762, i64 4
  %1810 = bitcast i8* %1809 to float*
  %1811 = load float, float* %1810, align 4
  %1812 = getelementptr inbounds float, float* %0, i64 4
  %1813 = load float, float* %1812, align 4
  %1814 = fmul float %1811, %1813
  %1815 = load float, float* %2, align 4
  %1816 = fadd float %1815, %1814
  store float %1816, float* %2, align 4
  %1817 = getelementptr inbounds i8, i8* %1762, i64 8
  %1818 = bitcast i8* %1817 to float*
  %1819 = load float, float* %1818, align 4
  %1820 = getelementptr inbounds float, float* %0, i64 8
  %1821 = load float, float* %1820, align 4
  %1822 = fmul float %1819, %1821
  %1823 = load float, float* %2, align 4
  %1824 = fadd float %1823, %1822
  store float %1824, float* %2, align 4
  %1825 = getelementptr inbounds i8, i8* %1762, i64 12
  %1826 = bitcast i8* %1825 to float*
  %1827 = load float, float* %1826, align 4
  %1828 = getelementptr inbounds float, float* %0, i64 12
  %1829 = load float, float* %1828, align 4
  %1830 = fmul float %1827, %1829
  %1831 = load float, float* %2, align 4
  %1832 = fadd float %1831, %1830
  store float %1832, float* %2, align 4
  %1833 = getelementptr inbounds float, float* %2, i64 1
  store float 0.000000e+00, float* %1833, align 4
  %1834 = getelementptr inbounds float, float* %2, i64 1
  %1835 = load float, float* %1763, align 4
  %1836 = getelementptr inbounds float, float* %0, i64 1
  %1837 = load float, float* %1836, align 4
  %1838 = fmul float %1835, %1837
  %1839 = fadd float %1838, 0.000000e+00
  store float %1839, float* %1834, align 4
  %1840 = getelementptr inbounds i8, i8* %1762, i64 4
  %1841 = bitcast i8* %1840 to float*
  %1842 = load float, float* %1841, align 4
  %1843 = getelementptr inbounds float, float* %0, i64 5
  %1844 = load float, float* %1843, align 4
  %1845 = fmul float %1842, %1844
  %1846 = load float, float* %1834, align 4
  %1847 = fadd float %1846, %1845
  store float %1847, float* %1834, align 4
  %1848 = getelementptr inbounds i8, i8* %1762, i64 8
  %1849 = bitcast i8* %1848 to float*
  %1850 = load float, float* %1849, align 4
  %1851 = getelementptr inbounds float, float* %0, i64 9
  %1852 = load float, float* %1851, align 4
  %1853 = fmul float %1850, %1852
  %1854 = load float, float* %1834, align 4
  %1855 = fadd float %1854, %1853
  store float %1855, float* %1834, align 4
  %1856 = getelementptr inbounds i8, i8* %1762, i64 12
  %1857 = bitcast i8* %1856 to float*
  %1858 = load float, float* %1857, align 4
  %1859 = getelementptr inbounds float, float* %0, i64 13
  %1860 = load float, float* %1859, align 4
  %1861 = fmul float %1858, %1860
  %1862 = load float, float* %1834, align 4
  %1863 = fadd float %1862, %1861
  store float %1863, float* %1834, align 4
  %1864 = getelementptr inbounds float, float* %2, i64 2
  store float 0.000000e+00, float* %1864, align 4
  %1865 = getelementptr inbounds float, float* %2, i64 2
  %1866 = load float, float* %1763, align 4
  %1867 = getelementptr inbounds float, float* %0, i64 2
  %1868 = load float, float* %1867, align 4
  %1869 = fmul float %1866, %1868
  %1870 = fadd float %1869, 0.000000e+00
  store float %1870, float* %1865, align 4
  %1871 = getelementptr inbounds i8, i8* %1762, i64 4
  %1872 = bitcast i8* %1871 to float*
  %1873 = load float, float* %1872, align 4
  %1874 = getelementptr inbounds float, float* %0, i64 6
  %1875 = load float, float* %1874, align 4
  %1876 = fmul float %1873, %1875
  %1877 = load float, float* %1865, align 4
  %1878 = fadd float %1877, %1876
  store float %1878, float* %1865, align 4
  %1879 = getelementptr inbounds i8, i8* %1762, i64 8
  %1880 = bitcast i8* %1879 to float*
  %1881 = load float, float* %1880, align 4
  %1882 = getelementptr inbounds float, float* %0, i64 10
  %1883 = load float, float* %1882, align 4
  %1884 = fmul float %1881, %1883
  %1885 = load float, float* %1865, align 4
  %1886 = fadd float %1885, %1884
  store float %1886, float* %1865, align 4
  %1887 = getelementptr inbounds i8, i8* %1762, i64 12
  %1888 = bitcast i8* %1887 to float*
  %1889 = load float, float* %1888, align 4
  %1890 = getelementptr inbounds float, float* %0, i64 14
  %1891 = load float, float* %1890, align 4
  %1892 = fmul float %1889, %1891
  %1893 = load float, float* %1865, align 4
  %1894 = fadd float %1893, %1892
  store float %1894, float* %1865, align 4
  %1895 = getelementptr inbounds float, float* %2, i64 3
  store float 0.000000e+00, float* %1895, align 4
  %1896 = getelementptr inbounds float, float* %2, i64 3
  %1897 = load float, float* %1763, align 4
  %1898 = getelementptr inbounds float, float* %0, i64 3
  %1899 = load float, float* %1898, align 4
  %1900 = fmul float %1897, %1899
  %1901 = fadd float %1900, 0.000000e+00
  store float %1901, float* %1896, align 4
  %1902 = getelementptr inbounds i8, i8* %1762, i64 4
  %1903 = bitcast i8* %1902 to float*
  %1904 = load float, float* %1903, align 4
  %1905 = getelementptr inbounds float, float* %0, i64 7
  %1906 = load float, float* %1905, align 4
  %1907 = fmul float %1904, %1906
  %1908 = load float, float* %1896, align 4
  %1909 = fadd float %1908, %1907
  store float %1909, float* %1896, align 4
  %1910 = getelementptr inbounds i8, i8* %1762, i64 8
  %1911 = bitcast i8* %1910 to float*
  %1912 = load float, float* %1911, align 4
  %1913 = getelementptr inbounds float, float* %0, i64 11
  %1914 = load float, float* %1913, align 4
  %1915 = fmul float %1912, %1914
  %1916 = load float, float* %1896, align 4
  %1917 = fadd float %1916, %1915
  store float %1917, float* %1896, align 4
  %1918 = getelementptr inbounds i8, i8* %1762, i64 12
  %1919 = bitcast i8* %1918 to float*
  %1920 = load float, float* %1919, align 4
  %1921 = getelementptr inbounds float, float* %0, i64 15
  %1922 = load float, float* %1921, align 4
  %1923 = fmul float %1920, %1922
  %1924 = load float, float* %1896, align 4
  %1925 = fadd float %1924, %1923
  store float %1925, float* %1896, align 4
  %1926 = getelementptr inbounds i8, i8* %1762, i64 16
  %1927 = bitcast i8* %1926 to float*
  %1928 = getelementptr inbounds float, float* %2, i64 4
  store float 0.000000e+00, float* %1928, align 4
  %1929 = getelementptr inbounds float, float* %2, i64 4
  %1930 = load float, float* %1927, align 4
  %1931 = load float, float* %0, align 4
  %1932 = fmul float %1930, %1931
  %1933 = fadd float %1932, 0.000000e+00
  store float %1933, float* %1929, align 4
  %1934 = getelementptr inbounds i8, i8* %1762, i64 20
  %1935 = bitcast i8* %1934 to float*
  %1936 = load float, float* %1935, align 4
  %1937 = getelementptr inbounds float, float* %0, i64 4
  %1938 = load float, float* %1937, align 4
  %1939 = fmul float %1936, %1938
  %1940 = load float, float* %1929, align 4
  %1941 = fadd float %1940, %1939
  store float %1941, float* %1929, align 4
  %1942 = getelementptr inbounds i8, i8* %1762, i64 24
  %1943 = bitcast i8* %1942 to float*
  %1944 = load float, float* %1943, align 4
  %1945 = getelementptr inbounds float, float* %0, i64 8
  %1946 = load float, float* %1945, align 4
  %1947 = fmul float %1944, %1946
  %1948 = load float, float* %1929, align 4
  %1949 = fadd float %1948, %1947
  store float %1949, float* %1929, align 4
  %1950 = getelementptr inbounds i8, i8* %1762, i64 28
  %1951 = bitcast i8* %1950 to float*
  %1952 = load float, float* %1951, align 4
  %1953 = getelementptr inbounds float, float* %0, i64 12
  %1954 = load float, float* %1953, align 4
  %1955 = fmul float %1952, %1954
  %1956 = load float, float* %1929, align 4
  %1957 = fadd float %1956, %1955
  store float %1957, float* %1929, align 4
  %1958 = getelementptr inbounds float, float* %2, i64 5
  store float 0.000000e+00, float* %1958, align 4
  %1959 = getelementptr inbounds float, float* %2, i64 5
  %1960 = load float, float* %1927, align 4
  %1961 = getelementptr inbounds float, float* %0, i64 1
  %1962 = load float, float* %1961, align 4
  %1963 = fmul float %1960, %1962
  %1964 = fadd float %1963, 0.000000e+00
  store float %1964, float* %1959, align 4
  %1965 = getelementptr inbounds i8, i8* %1762, i64 20
  %1966 = bitcast i8* %1965 to float*
  %1967 = load float, float* %1966, align 4
  %1968 = getelementptr inbounds float, float* %0, i64 5
  %1969 = load float, float* %1968, align 4
  %1970 = fmul float %1967, %1969
  %1971 = load float, float* %1959, align 4
  %1972 = fadd float %1971, %1970
  store float %1972, float* %1959, align 4
  %1973 = getelementptr inbounds i8, i8* %1762, i64 24
  %1974 = bitcast i8* %1973 to float*
  %1975 = load float, float* %1974, align 4
  %1976 = getelementptr inbounds float, float* %0, i64 9
  %1977 = load float, float* %1976, align 4
  %1978 = fmul float %1975, %1977
  %1979 = load float, float* %1959, align 4
  %1980 = fadd float %1979, %1978
  store float %1980, float* %1959, align 4
  %1981 = getelementptr inbounds i8, i8* %1762, i64 28
  %1982 = bitcast i8* %1981 to float*
  %1983 = load float, float* %1982, align 4
  %1984 = getelementptr inbounds float, float* %0, i64 13
  %1985 = load float, float* %1984, align 4
  %1986 = fmul float %1983, %1985
  %1987 = load float, float* %1959, align 4
  %1988 = fadd float %1987, %1986
  store float %1988, float* %1959, align 4
  %1989 = getelementptr inbounds float, float* %2, i64 6
  store float 0.000000e+00, float* %1989, align 4
  %1990 = getelementptr inbounds float, float* %2, i64 6
  %1991 = load float, float* %1927, align 4
  %1992 = getelementptr inbounds float, float* %0, i64 2
  %1993 = load float, float* %1992, align 4
  %1994 = fmul float %1991, %1993
  %1995 = fadd float %1994, 0.000000e+00
  store float %1995, float* %1990, align 4
  %1996 = getelementptr inbounds i8, i8* %1762, i64 20
  %1997 = bitcast i8* %1996 to float*
  %1998 = load float, float* %1997, align 4
  %1999 = getelementptr inbounds float, float* %0, i64 6
  %2000 = load float, float* %1999, align 4
  %2001 = fmul float %1998, %2000
  %2002 = load float, float* %1990, align 4
  %2003 = fadd float %2002, %2001
  store float %2003, float* %1990, align 4
  %2004 = getelementptr inbounds i8, i8* %1762, i64 24
  %2005 = bitcast i8* %2004 to float*
  %2006 = load float, float* %2005, align 4
  %2007 = getelementptr inbounds float, float* %0, i64 10
  %2008 = load float, float* %2007, align 4
  %2009 = fmul float %2006, %2008
  %2010 = load float, float* %1990, align 4
  %2011 = fadd float %2010, %2009
  store float %2011, float* %1990, align 4
  %2012 = getelementptr inbounds i8, i8* %1762, i64 28
  %2013 = bitcast i8* %2012 to float*
  %2014 = load float, float* %2013, align 4
  %2015 = getelementptr inbounds float, float* %0, i64 14
  %2016 = load float, float* %2015, align 4
  %2017 = fmul float %2014, %2016
  %2018 = load float, float* %1990, align 4
  %2019 = fadd float %2018, %2017
  store float %2019, float* %1990, align 4
  %2020 = getelementptr inbounds float, float* %2, i64 7
  store float 0.000000e+00, float* %2020, align 4
  %2021 = getelementptr inbounds float, float* %2, i64 7
  %2022 = load float, float* %1927, align 4
  %2023 = getelementptr inbounds float, float* %0, i64 3
  %2024 = load float, float* %2023, align 4
  %2025 = fmul float %2022, %2024
  %2026 = fadd float %2025, 0.000000e+00
  store float %2026, float* %2021, align 4
  %2027 = getelementptr inbounds i8, i8* %1762, i64 20
  %2028 = bitcast i8* %2027 to float*
  %2029 = load float, float* %2028, align 4
  %2030 = getelementptr inbounds float, float* %0, i64 7
  %2031 = load float, float* %2030, align 4
  %2032 = fmul float %2029, %2031
  %2033 = load float, float* %2021, align 4
  %2034 = fadd float %2033, %2032
  store float %2034, float* %2021, align 4
  %2035 = getelementptr inbounds i8, i8* %1762, i64 24
  %2036 = bitcast i8* %2035 to float*
  %2037 = load float, float* %2036, align 4
  %2038 = getelementptr inbounds float, float* %0, i64 11
  %2039 = load float, float* %2038, align 4
  %2040 = fmul float %2037, %2039
  %2041 = load float, float* %2021, align 4
  %2042 = fadd float %2041, %2040
  store float %2042, float* %2021, align 4
  %2043 = getelementptr inbounds i8, i8* %1762, i64 28
  %2044 = bitcast i8* %2043 to float*
  %2045 = load float, float* %2044, align 4
  %2046 = getelementptr inbounds float, float* %0, i64 15
  %2047 = load float, float* %2046, align 4
  %2048 = fmul float %2045, %2047
  %2049 = load float, float* %2021, align 4
  %2050 = fadd float %2049, %2048
  store float %2050, float* %2021, align 4
  %2051 = getelementptr inbounds i8, i8* %1762, i64 32
  %2052 = bitcast i8* %2051 to float*
  %2053 = getelementptr inbounds float, float* %2, i64 8
  store float 0.000000e+00, float* %2053, align 4
  %2054 = getelementptr inbounds float, float* %2, i64 8
  %2055 = load float, float* %2052, align 4
  %2056 = load float, float* %0, align 4
  %2057 = fmul float %2055, %2056
  %2058 = fadd float %2057, 0.000000e+00
  store float %2058, float* %2054, align 4
  %2059 = getelementptr inbounds i8, i8* %1762, i64 36
  %2060 = bitcast i8* %2059 to float*
  %2061 = load float, float* %2060, align 4
  %2062 = getelementptr inbounds float, float* %0, i64 4
  %2063 = load float, float* %2062, align 4
  %2064 = fmul float %2061, %2063
  %2065 = load float, float* %2054, align 4
  %2066 = fadd float %2065, %2064
  store float %2066, float* %2054, align 4
  %2067 = getelementptr inbounds i8, i8* %1762, i64 40
  %2068 = bitcast i8* %2067 to float*
  %2069 = load float, float* %2068, align 4
  %2070 = getelementptr inbounds float, float* %0, i64 8
  %2071 = load float, float* %2070, align 4
  %2072 = fmul float %2069, %2071
  %2073 = load float, float* %2054, align 4
  %2074 = fadd float %2073, %2072
  store float %2074, float* %2054, align 4
  %2075 = getelementptr inbounds i8, i8* %1762, i64 44
  %2076 = bitcast i8* %2075 to float*
  %2077 = load float, float* %2076, align 4
  %2078 = getelementptr inbounds float, float* %0, i64 12
  %2079 = load float, float* %2078, align 4
  %2080 = fmul float %2077, %2079
  %2081 = load float, float* %2054, align 4
  %2082 = fadd float %2081, %2080
  store float %2082, float* %2054, align 4
  %2083 = getelementptr inbounds float, float* %2, i64 9
  store float 0.000000e+00, float* %2083, align 4
  %2084 = getelementptr inbounds float, float* %2, i64 9
  %2085 = load float, float* %2052, align 4
  %2086 = getelementptr inbounds float, float* %0, i64 1
  %2087 = load float, float* %2086, align 4
  %2088 = fmul float %2085, %2087
  %2089 = fadd float %2088, 0.000000e+00
  store float %2089, float* %2084, align 4
  %2090 = getelementptr inbounds i8, i8* %1762, i64 36
  %2091 = bitcast i8* %2090 to float*
  %2092 = load float, float* %2091, align 4
  %2093 = getelementptr inbounds float, float* %0, i64 5
  %2094 = load float, float* %2093, align 4
  %2095 = fmul float %2092, %2094
  %2096 = load float, float* %2084, align 4
  %2097 = fadd float %2096, %2095
  store float %2097, float* %2084, align 4
  %2098 = getelementptr inbounds i8, i8* %1762, i64 40
  %2099 = bitcast i8* %2098 to float*
  %2100 = load float, float* %2099, align 4
  %2101 = getelementptr inbounds float, float* %0, i64 9
  %2102 = load float, float* %2101, align 4
  %2103 = fmul float %2100, %2102
  %2104 = load float, float* %2084, align 4
  %2105 = fadd float %2104, %2103
  store float %2105, float* %2084, align 4
  %2106 = getelementptr inbounds i8, i8* %1762, i64 44
  %2107 = bitcast i8* %2106 to float*
  %2108 = load float, float* %2107, align 4
  %2109 = getelementptr inbounds float, float* %0, i64 13
  %2110 = load float, float* %2109, align 4
  %2111 = fmul float %2108, %2110
  %2112 = load float, float* %2084, align 4
  %2113 = fadd float %2112, %2111
  store float %2113, float* %2084, align 4
  %2114 = getelementptr inbounds float, float* %2, i64 10
  store float 0.000000e+00, float* %2114, align 4
  %2115 = getelementptr inbounds float, float* %2, i64 10
  %2116 = load float, float* %2052, align 4
  %2117 = getelementptr inbounds float, float* %0, i64 2
  %2118 = load float, float* %2117, align 4
  %2119 = fmul float %2116, %2118
  %2120 = fadd float %2119, 0.000000e+00
  store float %2120, float* %2115, align 4
  %2121 = getelementptr inbounds i8, i8* %1762, i64 36
  %2122 = bitcast i8* %2121 to float*
  %2123 = load float, float* %2122, align 4
  %2124 = getelementptr inbounds float, float* %0, i64 6
  %2125 = load float, float* %2124, align 4
  %2126 = fmul float %2123, %2125
  %2127 = load float, float* %2115, align 4
  %2128 = fadd float %2127, %2126
  store float %2128, float* %2115, align 4
  %2129 = getelementptr inbounds i8, i8* %1762, i64 40
  %2130 = bitcast i8* %2129 to float*
  %2131 = load float, float* %2130, align 4
  %2132 = getelementptr inbounds float, float* %0, i64 10
  %2133 = load float, float* %2132, align 4
  %2134 = fmul float %2131, %2133
  %2135 = load float, float* %2115, align 4
  %2136 = fadd float %2135, %2134
  store float %2136, float* %2115, align 4
  %2137 = getelementptr inbounds i8, i8* %1762, i64 44
  %2138 = bitcast i8* %2137 to float*
  %2139 = load float, float* %2138, align 4
  %2140 = getelementptr inbounds float, float* %0, i64 14
  %2141 = load float, float* %2140, align 4
  %2142 = fmul float %2139, %2141
  %2143 = load float, float* %2115, align 4
  %2144 = fadd float %2143, %2142
  store float %2144, float* %2115, align 4
  %2145 = getelementptr inbounds float, float* %2, i64 11
  store float 0.000000e+00, float* %2145, align 4
  %2146 = getelementptr inbounds float, float* %2, i64 11
  %2147 = load float, float* %2052, align 4
  %2148 = getelementptr inbounds float, float* %0, i64 3
  %2149 = load float, float* %2148, align 4
  %2150 = fmul float %2147, %2149
  %2151 = fadd float %2150, 0.000000e+00
  store float %2151, float* %2146, align 4
  %2152 = getelementptr inbounds i8, i8* %1762, i64 36
  %2153 = bitcast i8* %2152 to float*
  %2154 = load float, float* %2153, align 4
  %2155 = getelementptr inbounds float, float* %0, i64 7
  %2156 = load float, float* %2155, align 4
  %2157 = fmul float %2154, %2156
  %2158 = load float, float* %2146, align 4
  %2159 = fadd float %2158, %2157
  store float %2159, float* %2146, align 4
  %2160 = getelementptr inbounds i8, i8* %1762, i64 40
  %2161 = bitcast i8* %2160 to float*
  %2162 = load float, float* %2161, align 4
  %2163 = getelementptr inbounds float, float* %0, i64 11
  %2164 = load float, float* %2163, align 4
  %2165 = fmul float %2162, %2164
  %2166 = load float, float* %2146, align 4
  %2167 = fadd float %2166, %2165
  store float %2167, float* %2146, align 4
  %2168 = getelementptr inbounds i8, i8* %1762, i64 44
  %2169 = bitcast i8* %2168 to float*
  %2170 = load float, float* %2169, align 4
  %2171 = getelementptr inbounds float, float* %0, i64 15
  %2172 = load float, float* %2171, align 4
  %2173 = fmul float %2170, %2172
  %2174 = load float, float* %2146, align 4
  %2175 = fadd float %2174, %2173
  store float %2175, float* %2146, align 4
  %2176 = getelementptr inbounds i8, i8* %1762, i64 48
  %2177 = bitcast i8* %2176 to float*
  %2178 = getelementptr inbounds float, float* %2, i64 12
  store float 0.000000e+00, float* %2178, align 4
  %2179 = getelementptr inbounds float, float* %2, i64 12
  %2180 = load float, float* %2177, align 4
  %2181 = load float, float* %0, align 4
  %2182 = fmul float %2180, %2181
  %2183 = fadd float %2182, 0.000000e+00
  store float %2183, float* %2179, align 4
  %2184 = getelementptr inbounds i8, i8* %1762, i64 52
  %2185 = bitcast i8* %2184 to float*
  %2186 = load float, float* %2185, align 4
  %2187 = getelementptr inbounds float, float* %0, i64 4
  %2188 = load float, float* %2187, align 4
  %2189 = fmul float %2186, %2188
  %2190 = load float, float* %2179, align 4
  %2191 = fadd float %2190, %2189
  store float %2191, float* %2179, align 4
  %2192 = getelementptr inbounds i8, i8* %1762, i64 56
  %2193 = bitcast i8* %2192 to float*
  %2194 = load float, float* %2193, align 4
  %2195 = getelementptr inbounds float, float* %0, i64 8
  %2196 = load float, float* %2195, align 4
  %2197 = fmul float %2194, %2196
  %2198 = load float, float* %2179, align 4
  %2199 = fadd float %2198, %2197
  store float %2199, float* %2179, align 4
  %2200 = getelementptr inbounds i8, i8* %1762, i64 60
  %2201 = bitcast i8* %2200 to float*
  %2202 = load float, float* %2201, align 4
  %2203 = getelementptr inbounds float, float* %0, i64 12
  %2204 = load float, float* %2203, align 4
  %2205 = fmul float %2202, %2204
  %2206 = load float, float* %2179, align 4
  %2207 = fadd float %2206, %2205
  store float %2207, float* %2179, align 4
  %2208 = getelementptr inbounds float, float* %2, i64 13
  store float 0.000000e+00, float* %2208, align 4
  %2209 = getelementptr inbounds float, float* %2, i64 13
  %2210 = load float, float* %2177, align 4
  %2211 = getelementptr inbounds float, float* %0, i64 1
  %2212 = load float, float* %2211, align 4
  %2213 = fmul float %2210, %2212
  %2214 = fadd float %2213, 0.000000e+00
  store float %2214, float* %2209, align 4
  %2215 = getelementptr inbounds i8, i8* %1762, i64 52
  %2216 = bitcast i8* %2215 to float*
  %2217 = load float, float* %2216, align 4
  %2218 = getelementptr inbounds float, float* %0, i64 5
  %2219 = load float, float* %2218, align 4
  %2220 = fmul float %2217, %2219
  %2221 = load float, float* %2209, align 4
  %2222 = fadd float %2221, %2220
  store float %2222, float* %2209, align 4
  %2223 = getelementptr inbounds i8, i8* %1762, i64 56
  %2224 = bitcast i8* %2223 to float*
  %2225 = load float, float* %2224, align 4
  %2226 = getelementptr inbounds float, float* %0, i64 9
  %2227 = load float, float* %2226, align 4
  %2228 = fmul float %2225, %2227
  %2229 = load float, float* %2209, align 4
  %2230 = fadd float %2229, %2228
  store float %2230, float* %2209, align 4
  %2231 = getelementptr inbounds i8, i8* %1762, i64 60
  %2232 = bitcast i8* %2231 to float*
  %2233 = load float, float* %2232, align 4
  %2234 = getelementptr inbounds float, float* %0, i64 13
  %2235 = load float, float* %2234, align 4
  %2236 = fmul float %2233, %2235
  %2237 = load float, float* %2209, align 4
  %2238 = fadd float %2237, %2236
  store float %2238, float* %2209, align 4
  %2239 = getelementptr inbounds float, float* %2, i64 14
  store float 0.000000e+00, float* %2239, align 4
  %2240 = getelementptr inbounds float, float* %2, i64 14
  %2241 = load float, float* %2177, align 4
  %2242 = getelementptr inbounds float, float* %0, i64 2
  %2243 = load float, float* %2242, align 4
  %2244 = fmul float %2241, %2243
  %2245 = fadd float %2244, 0.000000e+00
  store float %2245, float* %2240, align 4
  %2246 = getelementptr inbounds i8, i8* %1762, i64 52
  %2247 = bitcast i8* %2246 to float*
  %2248 = load float, float* %2247, align 4
  %2249 = getelementptr inbounds float, float* %0, i64 6
  %2250 = load float, float* %2249, align 4
  %2251 = fmul float %2248, %2250
  %2252 = load float, float* %2240, align 4
  %2253 = fadd float %2252, %2251
  store float %2253, float* %2240, align 4
  %2254 = getelementptr inbounds i8, i8* %1762, i64 56
  %2255 = bitcast i8* %2254 to float*
  %2256 = load float, float* %2255, align 4
  %2257 = getelementptr inbounds float, float* %0, i64 10
  %2258 = load float, float* %2257, align 4
  %2259 = fmul float %2256, %2258
  %2260 = load float, float* %2240, align 4
  %2261 = fadd float %2260, %2259
  store float %2261, float* %2240, align 4
  %2262 = getelementptr inbounds i8, i8* %1762, i64 60
  %2263 = bitcast i8* %2262 to float*
  %2264 = load float, float* %2263, align 4
  %2265 = getelementptr inbounds float, float* %0, i64 14
  %2266 = load float, float* %2265, align 4
  %2267 = fmul float %2264, %2266
  %2268 = load float, float* %2240, align 4
  %2269 = fadd float %2268, %2267
  store float %2269, float* %2240, align 4
  %2270 = getelementptr inbounds float, float* %2, i64 15
  store float 0.000000e+00, float* %2270, align 4
  %2271 = getelementptr inbounds float, float* %2, i64 15
  %2272 = load float, float* %2177, align 4
  %2273 = getelementptr inbounds float, float* %0, i64 3
  %2274 = load float, float* %2273, align 4
  %2275 = fmul float %2272, %2274
  %2276 = fadd float %2275, 0.000000e+00
  store float %2276, float* %2271, align 4
  %2277 = getelementptr inbounds i8, i8* %1762, i64 52
  %2278 = bitcast i8* %2277 to float*
  %2279 = load float, float* %2278, align 4
  %2280 = getelementptr inbounds float, float* %0, i64 7
  %2281 = load float, float* %2280, align 4
  %2282 = fmul float %2279, %2281
  %2283 = load float, float* %2271, align 4
  %2284 = fadd float %2283, %2282
  store float %2284, float* %2271, align 4
  %2285 = getelementptr inbounds i8, i8* %1762, i64 56
  %2286 = bitcast i8* %2285 to float*
  %2287 = load float, float* %2286, align 4
  %2288 = getelementptr inbounds float, float* %0, i64 11
  %2289 = load float, float* %2288, align 4
  %2290 = fmul float %2287, %2289
  %2291 = load float, float* %2271, align 4
  %2292 = fadd float %2291, %2290
  store float %2292, float* %2271, align 4
  %2293 = getelementptr inbounds i8, i8* %1762, i64 60
  %2294 = bitcast i8* %2293 to float*
  %2295 = load float, float* %2294, align 4
  %2296 = getelementptr inbounds float, float* %0, i64 15
  %2297 = load float, float* %2296, align 4
  %2298 = fmul float %2295, %2297
  %2299 = load float, float* %2271, align 4
  %2300 = fadd float %2299, %2298
  store float %2300, float* %2271, align 4
  %2301 = getelementptr inbounds float, float* %1, i64 1
  %2302 = bitcast float* %2301 to i32*
  %2303 = load i32, i32* %2302, align 4
  %2304 = getelementptr inbounds float, float* %1, i64 4
  %2305 = bitcast float* %2304 to i32*
  %2306 = load i32, i32* %2305, align 4
  %2307 = getelementptr inbounds float, float* %1, i64 1
  %2308 = bitcast float* %2307 to i32*
  store i32 %2306, i32* %2308, align 4
  %2309 = getelementptr inbounds float, float* %1, i64 4
  %2310 = bitcast float* %2309 to i32*
  store i32 %2303, i32* %2310, align 4
  br label %2311

2311:                                             ; preds = %2311, %.preheader26
  %indvars.iv2730 = phi i64 [ 2, %.preheader26 ], [ %indvars.iv.next28.1, %2311 ]
  %2312 = getelementptr inbounds float, float* %1, i64 %indvars.iv2730
  %2313 = bitcast float* %2312 to i32*
  %2314 = load i32, i32* %2313, align 4
  %2315 = shl nuw nsw i64 %indvars.iv2730, 2
  %2316 = getelementptr inbounds float, float* %1, i64 %2315
  %2317 = bitcast float* %2316 to i32*
  %2318 = load i32, i32* %2317, align 4
  %2319 = getelementptr inbounds float, float* %1, i64 %indvars.iv2730
  %2320 = bitcast float* %2319 to i32*
  store i32 %2318, i32* %2320, align 4
  %2321 = shl nuw nsw i64 %indvars.iv2730, 2
  %2322 = getelementptr inbounds float, float* %1, i64 %2321
  %2323 = bitcast float* %2322 to i32*
  store i32 %2314, i32* %2323, align 4
  %indvars.iv.next28 = or i64 %indvars.iv2730, 1
  %2324 = getelementptr inbounds float, float* %1, i64 %indvars.iv.next28
  %2325 = bitcast float* %2324 to i32*
  %2326 = load i32, i32* %2325, align 4
  %2327 = shl nuw nsw i64 %indvars.iv.next28, 2
  %2328 = getelementptr inbounds float, float* %1, i64 %2327
  %2329 = bitcast float* %2328 to i32*
  %2330 = load i32, i32* %2329, align 4
  %2331 = getelementptr inbounds float, float* %1, i64 %indvars.iv.next28
  %2332 = bitcast float* %2331 to i32*
  store i32 %2330, i32* %2332, align 4
  %2333 = shl nuw nsw i64 %indvars.iv.next28, 2
  %2334 = getelementptr inbounds float, float* %1, i64 %2333
  %2335 = bitcast float* %2334 to i32*
  store i32 %2326, i32* %2335, align 4
  %indvars.iv.next28.1 = add nuw nsw i64 %indvars.iv2730, 2
  %exitcond.1.not = icmp eq i64 %indvars.iv.next28.1, 4
  br i1 %exitcond.1.not, label %.lr.ph.new.1, label %2311

.lr.ph.new.1:                                     ; preds = %.lr.ph.new.1, %2311
  %indvars.iv2730.1 = phi i64 [ %indvars.iv.next28.1.1, %.lr.ph.new.1 ], [ 2, %2311 ]
  %2336 = add nuw nsw i64 %indvars.iv2730.1, 4
  %2337 = getelementptr inbounds float, float* %1, i64 %2336
  %2338 = bitcast float* %2337 to i32*
  %2339 = load i32, i32* %2338, align 4
  %2340 = shl nuw nsw i64 %indvars.iv2730.1, 2
  %2341 = or i64 %2340, 1
  %2342 = getelementptr inbounds float, float* %1, i64 %2341
  %2343 = bitcast float* %2342 to i32*
  %2344 = load i32, i32* %2343, align 4
  %2345 = add nuw nsw i64 %indvars.iv2730.1, 4
  %2346 = getelementptr inbounds float, float* %1, i64 %2345
  %2347 = bitcast float* %2346 to i32*
  store i32 %2344, i32* %2347, align 4
  %2348 = shl nuw nsw i64 %indvars.iv2730.1, 2
  %2349 = or i64 %2348, 1
  %2350 = getelementptr inbounds float, float* %1, i64 %2349
  %2351 = bitcast float* %2350 to i32*
  store i32 %2339, i32* %2351, align 4
  %indvars.iv.next28.1124 = or i64 %indvars.iv2730.1, 1
  %2352 = add nuw nsw i64 %indvars.iv2730.1, 5
  %2353 = getelementptr inbounds float, float* %1, i64 %2352
  %2354 = bitcast float* %2353 to i32*
  %2355 = load i32, i32* %2354, align 4
  %2356 = shl nuw nsw i64 %indvars.iv.next28.1124, 2
  %2357 = or i64 %2356, 1
  %2358 = getelementptr inbounds float, float* %1, i64 %2357
  %2359 = bitcast float* %2358 to i32*
  %2360 = load i32, i32* %2359, align 4
  %2361 = add nuw nsw i64 %indvars.iv2730.1, 5
  %2362 = getelementptr inbounds float, float* %1, i64 %2361
  %2363 = bitcast float* %2362 to i32*
  store i32 %2360, i32* %2363, align 4
  %2364 = shl nuw nsw i64 %indvars.iv.next28.1124, 2
  %2365 = or i64 %2364, 1
  %2366 = getelementptr inbounds float, float* %1, i64 %2365
  %2367 = bitcast float* %2366 to i32*
  store i32 %2355, i32* %2367, align 4
  %indvars.iv.next28.1.1 = add nuw nsw i64 %indvars.iv2730.1, 2
  %exitcond.1.1.not = icmp eq i64 %indvars.iv.next28.1.1, 4
  br i1 %exitcond.1.1.not, label %.prol.preheader.2, label %.lr.ph.new.1

.prol.preheader.2:                                ; preds = %.lr.ph.new.1
  %2368 = getelementptr inbounds float, float* %1, i64 11
  %2369 = bitcast float* %2368 to i32*
  %2370 = load i32, i32* %2369, align 4
  %2371 = getelementptr inbounds float, float* %1, i64 14
  %2372 = bitcast float* %2371 to i32*
  %2373 = load i32, i32* %2372, align 4
  %2374 = getelementptr inbounds float, float* %1, i64 11
  %2375 = bitcast float* %2374 to i32*
  store i32 %2373, i32* %2375, align 4
  %2376 = getelementptr inbounds float, float* %1, i64 14
  %2377 = bitcast float* %2376 to i32*
  store i32 %2370, i32* %2377, align 4
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
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #5

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #6

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32(float) #1

attributes #0 = { alwaysinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable willreturn }
attributes #2 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { allocsize(0,1) "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { argmemonly nounwind willreturn }
attributes #6 = { argmemonly nounwind willreturn writeonly }
attributes #7 = { nounwind }
attributes #8 = { nounwind allocsize(0,1) }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
