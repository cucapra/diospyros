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
.preheader33:
  %3 = bitcast float* %2 to i8*
  %4 = bitcast float* %0 to i8*
  %5 = bitcast float* %2 to i8*
  %6 = call i64 @llvm.objectsize.i64.p0i8(i8* %5, i1 false, i1 true, i1 false)
  %7 = call i8* @__memcpy_chk(i8* %3, i8* %4, i64 64, i64 %6) #8
  %8 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #9
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
  %40 = bitcast float* %1 to i8*
  %41 = bitcast float* %1 to i8*
  %42 = call i64 @llvm.objectsize.i64.p0i8(i8* %41, i1 false, i1 true, i1 false)
  %43 = bitcast float* %2 to i8*
  %44 = bitcast float* %2 to i8*
  %45 = call i64 @llvm.objectsize.i64.p0i8(i8* %44, i1 false, i1 true, i1 false)
  %46 = bitcast float* %1 to i8*
  %47 = bitcast float* %1 to i8*
  %48 = call i64 @llvm.objectsize.i64.p0i8(i8* %47, i1 false, i1 true, i1 false)
  %49 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #9
  %50 = bitcast i8* %49 to float*
  %51 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #9
  %52 = bitcast i8* %51 to float*
  %53 = bitcast float* %2 to i32*
  %54 = load i32, i32* %53, align 4
  %55 = bitcast i8* %49 to i32*
  store i32 %54, i32* %55, align 4
  %56 = bitcast i8* %8 to i32*
  %57 = load i32, i32* %56, align 4
  %58 = bitcast i8* %51 to i32*
  store i32 %57, i32* %58, align 4
  %59 = getelementptr inbounds float, float* %2, i64 4
  %60 = bitcast float* %59 to i32*
  %61 = load i32, i32* %60, align 4
  %62 = getelementptr inbounds i8, i8* %49, i64 4
  %63 = bitcast i8* %62 to i32*
  store i32 %61, i32* %63, align 4
  %64 = getelementptr inbounds i8, i8* %8, i64 16
  %65 = bitcast i8* %64 to i32*
  %66 = load i32, i32* %65, align 4
  %67 = getelementptr inbounds i8, i8* %51, i64 4
  %68 = bitcast i8* %67 to i32*
  store i32 %66, i32* %68, align 4
  %69 = getelementptr inbounds float, float* %2, i64 8
  %70 = bitcast float* %69 to i32*
  %71 = load i32, i32* %70, align 4
  %72 = getelementptr inbounds i8, i8* %49, i64 8
  %73 = bitcast i8* %72 to i32*
  store i32 %71, i32* %73, align 4
  %74 = getelementptr inbounds i8, i8* %8, i64 32
  %75 = bitcast i8* %74 to i32*
  %76 = load i32, i32* %75, align 4
  %77 = getelementptr inbounds i8, i8* %51, i64 8
  %78 = bitcast i8* %77 to i32*
  store i32 %76, i32* %78, align 4
  %79 = getelementptr inbounds float, float* %2, i64 12
  %80 = bitcast float* %79 to i32*
  %81 = load i32, i32* %80, align 4
  %82 = getelementptr inbounds i8, i8* %49, i64 12
  %83 = bitcast i8* %82 to i32*
  store i32 %81, i32* %83, align 4
  %84 = getelementptr inbounds i8, i8* %8, i64 48
  %85 = bitcast i8* %84 to i32*
  %86 = load i32, i32* %85, align 4
  %87 = getelementptr inbounds i8, i8* %51, i64 12
  %88 = bitcast i8* %87 to i32*
  store i32 %86, i32* %88, align 4
  %89 = load float, float* %50, align 4
  %90 = fcmp ogt float %89, 0.000000e+00
  %91 = zext i1 %90 to i32
  %92 = fcmp olt float %89, 0.000000e+00
  %.neg = sext i1 %92 to i32
  %93 = add nsw i32 %.neg, %91
  %94 = sitofp i32 %93 to float
  %95 = load float, float* %50, align 4
  %96 = fpext float %95 to double
  %square = fmul double %96, %96
  %97 = fadd double %square, 0.000000e+00
  %98 = fptrunc double %97 to float
  %99 = getelementptr inbounds i8, i8* %49, i64 4
  %100 = bitcast i8* %99 to float*
  %101 = load float, float* %100, align 4
  %102 = fpext float %101 to double
  %square202 = fmul double %102, %102
  %103 = fpext float %98 to double
  %104 = fadd double %square202, %103
  %105 = fptrunc double %104 to float
  %106 = getelementptr inbounds i8, i8* %49, i64 8
  %107 = bitcast i8* %106 to float*
  %108 = load float, float* %107, align 4
  %109 = fpext float %108 to double
  %square203 = fmul double %109, %109
  %110 = fpext float %105 to double
  %111 = fadd double %square203, %110
  %112 = fptrunc double %111 to float
  %113 = getelementptr inbounds i8, i8* %49, i64 12
  %114 = bitcast i8* %113 to float*
  %115 = load float, float* %114, align 4
  %116 = fpext float %115 to double
  %square204 = fmul double %116, %116
  %117 = fpext float %112 to double
  %118 = fadd double %square204, %117
  %119 = fptrunc double %118 to float
  %120 = fneg float %94
  %121 = call float @llvm.sqrt.f32(float %119)
  %122 = fmul float %121, %120
  %123 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #9
  %124 = bitcast i8* %123 to float*
  %125 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #9
  %126 = load float, float* %50, align 4
  %127 = load float, float* %52, align 4
  %128 = fmul float %122, %127
  %129 = fadd float %126, %128
  store float %129, float* %124, align 4
  %130 = getelementptr inbounds i8, i8* %49, i64 4
  %131 = bitcast i8* %130 to float*
  %132 = load float, float* %131, align 4
  %133 = getelementptr inbounds i8, i8* %51, i64 4
  %134 = bitcast i8* %133 to float*
  %135 = load float, float* %134, align 4
  %136 = fmul float %122, %135
  %137 = fadd float %132, %136
  %138 = getelementptr inbounds i8, i8* %123, i64 4
  %139 = bitcast i8* %138 to float*
  store float %137, float* %139, align 4
  %140 = getelementptr inbounds i8, i8* %49, i64 8
  %141 = bitcast i8* %140 to float*
  %142 = load float, float* %141, align 4
  %143 = getelementptr inbounds i8, i8* %51, i64 8
  %144 = bitcast i8* %143 to float*
  %145 = load float, float* %144, align 4
  %146 = fmul float %122, %145
  %147 = fadd float %142, %146
  %148 = getelementptr inbounds i8, i8* %123, i64 8
  %149 = bitcast i8* %148 to float*
  store float %147, float* %149, align 4
  %150 = getelementptr inbounds i8, i8* %49, i64 12
  %151 = bitcast i8* %150 to float*
  %152 = load float, float* %151, align 4
  %153 = getelementptr inbounds i8, i8* %51, i64 12
  %154 = bitcast i8* %153 to float*
  %155 = load float, float* %154, align 4
  %156 = fmul float %122, %155
  %157 = fadd float %152, %156
  %158 = getelementptr inbounds i8, i8* %123, i64 12
  %159 = bitcast i8* %158 to float*
  store float %157, float* %159, align 4
  %160 = load float, float* %124, align 4
  %161 = fpext float %160 to double
  %square205 = fmul double %161, %161
  %162 = fadd double %square205, 0.000000e+00
  %163 = fptrunc double %162 to float
  %164 = getelementptr inbounds i8, i8* %123, i64 4
  %165 = bitcast i8* %164 to float*
  %166 = load float, float* %165, align 4
  %167 = fpext float %166 to double
  %square206 = fmul double %167, %167
  %168 = fpext float %163 to double
  %169 = fadd double %square206, %168
  %170 = fptrunc double %169 to float
  %171 = getelementptr inbounds i8, i8* %123, i64 8
  %172 = bitcast i8* %171 to float*
  %173 = load float, float* %172, align 4
  %174 = fpext float %173 to double
  %square207 = fmul double %174, %174
  %175 = fpext float %170 to double
  %176 = fadd double %square207, %175
  %177 = fptrunc double %176 to float
  %178 = getelementptr inbounds i8, i8* %123, i64 12
  %179 = bitcast i8* %178 to float*
  %180 = load float, float* %179, align 4
  %181 = fpext float %180 to double
  %square208 = fmul double %181, %181
  %182 = fpext float %177 to double
  %183 = fadd double %square208, %182
  %184 = fptrunc double %183 to float
  %185 = bitcast i8* %125 to float*
  %186 = call float @llvm.sqrt.f32(float %184)
  %187 = load float, float* %124, align 4
  %188 = fdiv float %187, %186
  store float %188, float* %185, align 4
  %189 = getelementptr inbounds i8, i8* %123, i64 4
  %190 = bitcast i8* %189 to float*
  %191 = load float, float* %190, align 4
  %192 = fdiv float %191, %186
  %193 = getelementptr inbounds i8, i8* %125, i64 4
  %194 = bitcast i8* %193 to float*
  store float %192, float* %194, align 4
  %195 = getelementptr inbounds i8, i8* %123, i64 8
  %196 = bitcast i8* %195 to float*
  %197 = load float, float* %196, align 4
  %198 = fdiv float %197, %186
  %199 = getelementptr inbounds i8, i8* %125, i64 8
  %200 = bitcast i8* %199 to float*
  store float %198, float* %200, align 4
  %201 = getelementptr inbounds i8, i8* %123, i64 12
  %202 = bitcast i8* %201 to float*
  %203 = load float, float* %202, align 4
  %204 = fdiv float %203, %186
  %205 = getelementptr inbounds i8, i8* %125, i64 12
  %206 = bitcast i8* %205 to float*
  store float %204, float* %206, align 4
  %207 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #9
  %208 = bitcast i8* %207 to float*
  %209 = load float, float* %185, align 4
  %210 = fmul float %209, 2.000000e+00
  %211 = fmul float %210, %209
  %212 = fsub float 1.000000e+00, %211
  store float %212, float* %208, align 4
  %213 = load float, float* %185, align 4
  %214 = fmul float %213, 2.000000e+00
  %215 = getelementptr inbounds i8, i8* %125, i64 4
  %216 = bitcast i8* %215 to float*
  %217 = load float, float* %216, align 4
  %218 = fmul float %214, %217
  %219 = fsub float 0.000000e+00, %218
  %220 = getelementptr inbounds i8, i8* %207, i64 4
  %221 = bitcast i8* %220 to float*
  store float %219, float* %221, align 4
  %222 = load float, float* %185, align 4
  %223 = fmul float %222, 2.000000e+00
  %224 = getelementptr inbounds i8, i8* %125, i64 8
  %225 = bitcast i8* %224 to float*
  %226 = load float, float* %225, align 4
  %227 = fmul float %223, %226
  %228 = fsub float 0.000000e+00, %227
  %229 = getelementptr inbounds i8, i8* %207, i64 8
  %230 = bitcast i8* %229 to float*
  store float %228, float* %230, align 4
  %231 = load float, float* %185, align 4
  %232 = fmul float %231, 2.000000e+00
  %233 = getelementptr inbounds i8, i8* %125, i64 12
  %234 = bitcast i8* %233 to float*
  %235 = load float, float* %234, align 4
  %236 = fmul float %232, %235
  %237 = fsub float 0.000000e+00, %236
  %238 = getelementptr inbounds i8, i8* %207, i64 12
  %239 = bitcast i8* %238 to float*
  store float %237, float* %239, align 4
  %240 = getelementptr inbounds i8, i8* %125, i64 4
  %241 = bitcast i8* %240 to float*
  %242 = load float, float* %241, align 4
  %243 = fmul float %242, 2.000000e+00
  %244 = load float, float* %185, align 4
  %245 = fmul float %243, %244
  %246 = fsub float 0.000000e+00, %245
  %247 = getelementptr inbounds i8, i8* %207, i64 16
  %248 = bitcast i8* %247 to float*
  store float %246, float* %248, align 4
  %249 = load float, float* %241, align 4
  %250 = fmul float %249, 2.000000e+00
  %251 = fmul float %250, %249
  %252 = fsub float 1.000000e+00, %251
  %253 = getelementptr inbounds i8, i8* %207, i64 20
  %254 = bitcast i8* %253 to float*
  store float %252, float* %254, align 4
  %255 = load float, float* %241, align 4
  %256 = fmul float %255, 2.000000e+00
  %257 = getelementptr inbounds i8, i8* %125, i64 8
  %258 = bitcast i8* %257 to float*
  %259 = load float, float* %258, align 4
  %260 = fmul float %256, %259
  %261 = fsub float 0.000000e+00, %260
  %262 = getelementptr inbounds i8, i8* %207, i64 24
  %263 = bitcast i8* %262 to float*
  store float %261, float* %263, align 4
  %264 = load float, float* %241, align 4
  %265 = fmul float %264, 2.000000e+00
  %266 = getelementptr inbounds i8, i8* %125, i64 12
  %267 = bitcast i8* %266 to float*
  %268 = load float, float* %267, align 4
  %269 = fmul float %265, %268
  %270 = fsub float 0.000000e+00, %269
  %271 = getelementptr inbounds i8, i8* %207, i64 28
  %272 = bitcast i8* %271 to float*
  store float %270, float* %272, align 4
  %273 = getelementptr inbounds i8, i8* %125, i64 8
  %274 = bitcast i8* %273 to float*
  %275 = load float, float* %274, align 4
  %276 = fmul float %275, 2.000000e+00
  %277 = load float, float* %185, align 4
  %278 = fmul float %276, %277
  %279 = fsub float 0.000000e+00, %278
  %280 = getelementptr inbounds i8, i8* %207, i64 32
  %281 = bitcast i8* %280 to float*
  store float %279, float* %281, align 4
  %282 = load float, float* %274, align 4
  %283 = fmul float %282, 2.000000e+00
  %284 = getelementptr inbounds i8, i8* %125, i64 4
  %285 = bitcast i8* %284 to float*
  %286 = load float, float* %285, align 4
  %287 = fmul float %283, %286
  %288 = fsub float 0.000000e+00, %287
  %289 = getelementptr inbounds i8, i8* %207, i64 36
  %290 = bitcast i8* %289 to float*
  store float %288, float* %290, align 4
  %291 = load float, float* %274, align 4
  %292 = fmul float %291, 2.000000e+00
  %293 = fmul float %292, %291
  %294 = fsub float 1.000000e+00, %293
  %295 = getelementptr inbounds i8, i8* %207, i64 40
  %296 = bitcast i8* %295 to float*
  store float %294, float* %296, align 4
  %297 = load float, float* %274, align 4
  %298 = fmul float %297, 2.000000e+00
  %299 = getelementptr inbounds i8, i8* %125, i64 12
  %300 = bitcast i8* %299 to float*
  %301 = load float, float* %300, align 4
  %302 = fmul float %298, %301
  %303 = fsub float 0.000000e+00, %302
  %304 = getelementptr inbounds i8, i8* %207, i64 44
  %305 = bitcast i8* %304 to float*
  store float %303, float* %305, align 4
  %306 = getelementptr inbounds i8, i8* %125, i64 12
  %307 = bitcast i8* %306 to float*
  %308 = load float, float* %307, align 4
  %309 = fmul float %308, 2.000000e+00
  %310 = load float, float* %185, align 4
  %311 = fmul float %309, %310
  %312 = fsub float 0.000000e+00, %311
  %313 = getelementptr inbounds i8, i8* %207, i64 48
  %314 = bitcast i8* %313 to float*
  store float %312, float* %314, align 4
  %315 = load float, float* %307, align 4
  %316 = fmul float %315, 2.000000e+00
  %317 = getelementptr inbounds i8, i8* %125, i64 4
  %318 = bitcast i8* %317 to float*
  %319 = load float, float* %318, align 4
  %320 = fmul float %316, %319
  %321 = fsub float 0.000000e+00, %320
  %322 = getelementptr inbounds i8, i8* %207, i64 52
  %323 = bitcast i8* %322 to float*
  store float %321, float* %323, align 4
  %324 = load float, float* %307, align 4
  %325 = fmul float %324, 2.000000e+00
  %326 = getelementptr inbounds i8, i8* %125, i64 8
  %327 = bitcast i8* %326 to float*
  %328 = load float, float* %327, align 4
  %329 = fmul float %325, %328
  %330 = fsub float 0.000000e+00, %329
  %331 = getelementptr inbounds i8, i8* %207, i64 56
  %332 = bitcast i8* %331 to float*
  store float %330, float* %332, align 4
  %333 = load float, float* %307, align 4
  %334 = fmul float %333, 2.000000e+00
  %335 = fmul float %334, %333
  %336 = fsub float 1.000000e+00, %335
  %337 = getelementptr inbounds i8, i8* %207, i64 60
  %338 = bitcast i8* %337 to float*
  store float %336, float* %338, align 4
  %339 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #9
  %340 = bitcast i8* %339 to float*
  %341 = bitcast i8* %207 to i32*
  %342 = load i32, i32* %341, align 4
  %343 = bitcast i8* %339 to i32*
  store i32 %342, i32* %343, align 4
  %344 = getelementptr inbounds i8, i8* %207, i64 4
  %345 = bitcast i8* %344 to i32*
  %346 = load i32, i32* %345, align 4
  %347 = getelementptr inbounds i8, i8* %339, i64 4
  %348 = bitcast i8* %347 to i32*
  store i32 %346, i32* %348, align 4
  %349 = getelementptr inbounds i8, i8* %207, i64 8
  %350 = bitcast i8* %349 to i32*
  %351 = load i32, i32* %350, align 4
  %352 = getelementptr inbounds i8, i8* %339, i64 8
  %353 = bitcast i8* %352 to i32*
  store i32 %351, i32* %353, align 4
  %354 = getelementptr inbounds i8, i8* %207, i64 12
  %355 = bitcast i8* %354 to i32*
  %356 = load i32, i32* %355, align 4
  %357 = getelementptr inbounds i8, i8* %339, i64 12
  %358 = bitcast i8* %357 to i32*
  store i32 %356, i32* %358, align 4
  %359 = getelementptr inbounds i8, i8* %207, i64 16
  %360 = bitcast i8* %359 to i32*
  %361 = load i32, i32* %360, align 4
  %362 = getelementptr inbounds i8, i8* %339, i64 16
  %363 = bitcast i8* %362 to i32*
  store i32 %361, i32* %363, align 4
  %364 = getelementptr inbounds i8, i8* %207, i64 20
  %365 = bitcast i8* %364 to i32*
  %366 = load i32, i32* %365, align 4
  %367 = getelementptr inbounds i8, i8* %339, i64 20
  %368 = bitcast i8* %367 to i32*
  store i32 %366, i32* %368, align 4
  %369 = getelementptr inbounds i8, i8* %207, i64 24
  %370 = bitcast i8* %369 to i32*
  %371 = load i32, i32* %370, align 4
  %372 = getelementptr inbounds i8, i8* %339, i64 24
  %373 = bitcast i8* %372 to i32*
  store i32 %371, i32* %373, align 4
  %374 = getelementptr inbounds i8, i8* %207, i64 28
  %375 = bitcast i8* %374 to i32*
  %376 = load i32, i32* %375, align 4
  %377 = getelementptr inbounds i8, i8* %339, i64 28
  %378 = bitcast i8* %377 to i32*
  store i32 %376, i32* %378, align 4
  %379 = getelementptr inbounds i8, i8* %207, i64 32
  %380 = bitcast i8* %379 to i32*
  %381 = load i32, i32* %380, align 4
  %382 = getelementptr inbounds i8, i8* %339, i64 32
  %383 = bitcast i8* %382 to i32*
  store i32 %381, i32* %383, align 4
  %384 = getelementptr inbounds i8, i8* %207, i64 36
  %385 = bitcast i8* %384 to i32*
  %386 = load i32, i32* %385, align 4
  %387 = getelementptr inbounds i8, i8* %339, i64 36
  %388 = bitcast i8* %387 to i32*
  store i32 %386, i32* %388, align 4
  %389 = getelementptr inbounds i8, i8* %207, i64 40
  %390 = bitcast i8* %389 to i32*
  %391 = load i32, i32* %390, align 4
  %392 = getelementptr inbounds i8, i8* %339, i64 40
  %393 = bitcast i8* %392 to i32*
  store i32 %391, i32* %393, align 4
  %394 = getelementptr inbounds i8, i8* %207, i64 44
  %395 = bitcast i8* %394 to i32*
  %396 = load i32, i32* %395, align 4
  %397 = getelementptr inbounds i8, i8* %339, i64 44
  %398 = bitcast i8* %397 to i32*
  store i32 %396, i32* %398, align 4
  %399 = getelementptr inbounds i8, i8* %207, i64 48
  %400 = bitcast i8* %399 to i32*
  %401 = load i32, i32* %400, align 4
  %402 = getelementptr inbounds i8, i8* %339, i64 48
  %403 = bitcast i8* %402 to i32*
  store i32 %401, i32* %403, align 4
  %404 = getelementptr inbounds i8, i8* %207, i64 52
  %405 = bitcast i8* %404 to i32*
  %406 = load i32, i32* %405, align 4
  %407 = getelementptr inbounds i8, i8* %339, i64 52
  %408 = bitcast i8* %407 to i32*
  store i32 %406, i32* %408, align 4
  %409 = getelementptr inbounds i8, i8* %207, i64 56
  %410 = bitcast i8* %409 to i32*
  %411 = load i32, i32* %410, align 4
  %412 = getelementptr inbounds i8, i8* %339, i64 56
  %413 = bitcast i8* %412 to i32*
  store i32 %411, i32* %413, align 4
  %414 = getelementptr inbounds i8, i8* %207, i64 60
  %415 = bitcast i8* %414 to i32*
  %416 = load i32, i32* %415, align 4
  %417 = getelementptr inbounds i8, i8* %339, i64 60
  %418 = bitcast i8* %417 to i32*
  store i32 %416, i32* %418, align 4
  %419 = call i8* @__memcpy_chk(i8* %46, i8* %339, i64 64, i64 %48) #8
  store float 0.000000e+00, float* %2, align 4
  %420 = load float, float* %340, align 4
  %421 = load float, float* %0, align 4
  %422 = fmul float %420, %421
  %423 = fadd float %422, 0.000000e+00
  store float %423, float* %2, align 4
  %424 = getelementptr inbounds i8, i8* %339, i64 4
  %425 = bitcast i8* %424 to float*
  %426 = load float, float* %425, align 4
  %427 = getelementptr inbounds float, float* %0, i64 4
  %428 = load float, float* %427, align 4
  %429 = fmul float %426, %428
  %430 = load float, float* %2, align 4
  %431 = fadd float %430, %429
  store float %431, float* %2, align 4
  %432 = getelementptr inbounds i8, i8* %339, i64 8
  %433 = bitcast i8* %432 to float*
  %434 = load float, float* %433, align 4
  %435 = getelementptr inbounds float, float* %0, i64 8
  %436 = load float, float* %435, align 4
  %437 = fmul float %434, %436
  %438 = load float, float* %2, align 4
  %439 = fadd float %438, %437
  store float %439, float* %2, align 4
  %440 = getelementptr inbounds i8, i8* %339, i64 12
  %441 = bitcast i8* %440 to float*
  %442 = load float, float* %441, align 4
  %443 = getelementptr inbounds float, float* %0, i64 12
  %444 = load float, float* %443, align 4
  %445 = fmul float %442, %444
  %446 = load float, float* %2, align 4
  %447 = fadd float %446, %445
  store float %447, float* %2, align 4
  %448 = getelementptr inbounds float, float* %2, i64 1
  store float 0.000000e+00, float* %448, align 4
  %449 = getelementptr inbounds float, float* %2, i64 1
  %450 = load float, float* %340, align 4
  %451 = getelementptr inbounds float, float* %0, i64 1
  %452 = load float, float* %451, align 4
  %453 = fmul float %450, %452
  %454 = fadd float %453, 0.000000e+00
  store float %454, float* %449, align 4
  %455 = getelementptr inbounds i8, i8* %339, i64 4
  %456 = bitcast i8* %455 to float*
  %457 = load float, float* %456, align 4
  %458 = getelementptr inbounds float, float* %0, i64 5
  %459 = load float, float* %458, align 4
  %460 = fmul float %457, %459
  %461 = load float, float* %449, align 4
  %462 = fadd float %461, %460
  store float %462, float* %449, align 4
  %463 = getelementptr inbounds i8, i8* %339, i64 8
  %464 = bitcast i8* %463 to float*
  %465 = load float, float* %464, align 4
  %466 = getelementptr inbounds float, float* %0, i64 9
  %467 = load float, float* %466, align 4
  %468 = fmul float %465, %467
  %469 = load float, float* %449, align 4
  %470 = fadd float %469, %468
  store float %470, float* %449, align 4
  %471 = getelementptr inbounds i8, i8* %339, i64 12
  %472 = bitcast i8* %471 to float*
  %473 = load float, float* %472, align 4
  %474 = getelementptr inbounds float, float* %0, i64 13
  %475 = load float, float* %474, align 4
  %476 = fmul float %473, %475
  %477 = load float, float* %449, align 4
  %478 = fadd float %477, %476
  store float %478, float* %449, align 4
  %479 = getelementptr inbounds float, float* %2, i64 2
  store float 0.000000e+00, float* %479, align 4
  %480 = getelementptr inbounds float, float* %2, i64 2
  %481 = load float, float* %340, align 4
  %482 = getelementptr inbounds float, float* %0, i64 2
  %483 = load float, float* %482, align 4
  %484 = fmul float %481, %483
  %485 = fadd float %484, 0.000000e+00
  store float %485, float* %480, align 4
  %486 = getelementptr inbounds i8, i8* %339, i64 4
  %487 = bitcast i8* %486 to float*
  %488 = load float, float* %487, align 4
  %489 = getelementptr inbounds float, float* %0, i64 6
  %490 = load float, float* %489, align 4
  %491 = fmul float %488, %490
  %492 = load float, float* %480, align 4
  %493 = fadd float %492, %491
  store float %493, float* %480, align 4
  %494 = getelementptr inbounds i8, i8* %339, i64 8
  %495 = bitcast i8* %494 to float*
  %496 = load float, float* %495, align 4
  %497 = getelementptr inbounds float, float* %0, i64 10
  %498 = load float, float* %497, align 4
  %499 = fmul float %496, %498
  %500 = load float, float* %480, align 4
  %501 = fadd float %500, %499
  store float %501, float* %480, align 4
  %502 = getelementptr inbounds i8, i8* %339, i64 12
  %503 = bitcast i8* %502 to float*
  %504 = load float, float* %503, align 4
  %505 = getelementptr inbounds float, float* %0, i64 14
  %506 = load float, float* %505, align 4
  %507 = fmul float %504, %506
  %508 = load float, float* %480, align 4
  %509 = fadd float %508, %507
  store float %509, float* %480, align 4
  %510 = getelementptr inbounds float, float* %2, i64 3
  store float 0.000000e+00, float* %510, align 4
  %511 = getelementptr inbounds float, float* %2, i64 3
  %512 = load float, float* %340, align 4
  %513 = getelementptr inbounds float, float* %0, i64 3
  %514 = load float, float* %513, align 4
  %515 = fmul float %512, %514
  %516 = fadd float %515, 0.000000e+00
  store float %516, float* %511, align 4
  %517 = getelementptr inbounds i8, i8* %339, i64 4
  %518 = bitcast i8* %517 to float*
  %519 = load float, float* %518, align 4
  %520 = getelementptr inbounds float, float* %0, i64 7
  %521 = load float, float* %520, align 4
  %522 = fmul float %519, %521
  %523 = load float, float* %511, align 4
  %524 = fadd float %523, %522
  store float %524, float* %511, align 4
  %525 = getelementptr inbounds i8, i8* %339, i64 8
  %526 = bitcast i8* %525 to float*
  %527 = load float, float* %526, align 4
  %528 = getelementptr inbounds float, float* %0, i64 11
  %529 = load float, float* %528, align 4
  %530 = fmul float %527, %529
  %531 = load float, float* %511, align 4
  %532 = fadd float %531, %530
  store float %532, float* %511, align 4
  %533 = getelementptr inbounds i8, i8* %339, i64 12
  %534 = bitcast i8* %533 to float*
  %535 = load float, float* %534, align 4
  %536 = getelementptr inbounds float, float* %0, i64 15
  %537 = load float, float* %536, align 4
  %538 = fmul float %535, %537
  %539 = load float, float* %511, align 4
  %540 = fadd float %539, %538
  store float %540, float* %511, align 4
  %541 = getelementptr inbounds i8, i8* %339, i64 16
  %542 = bitcast i8* %541 to float*
  %543 = getelementptr inbounds float, float* %2, i64 4
  store float 0.000000e+00, float* %543, align 4
  %544 = getelementptr inbounds float, float* %2, i64 4
  %545 = load float, float* %542, align 4
  %546 = load float, float* %0, align 4
  %547 = fmul float %545, %546
  %548 = fadd float %547, 0.000000e+00
  store float %548, float* %544, align 4
  %549 = getelementptr inbounds i8, i8* %339, i64 20
  %550 = bitcast i8* %549 to float*
  %551 = load float, float* %550, align 4
  %552 = getelementptr inbounds float, float* %0, i64 4
  %553 = load float, float* %552, align 4
  %554 = fmul float %551, %553
  %555 = load float, float* %544, align 4
  %556 = fadd float %555, %554
  store float %556, float* %544, align 4
  %557 = getelementptr inbounds i8, i8* %339, i64 24
  %558 = bitcast i8* %557 to float*
  %559 = load float, float* %558, align 4
  %560 = getelementptr inbounds float, float* %0, i64 8
  %561 = load float, float* %560, align 4
  %562 = fmul float %559, %561
  %563 = load float, float* %544, align 4
  %564 = fadd float %563, %562
  store float %564, float* %544, align 4
  %565 = getelementptr inbounds i8, i8* %339, i64 28
  %566 = bitcast i8* %565 to float*
  %567 = load float, float* %566, align 4
  %568 = getelementptr inbounds float, float* %0, i64 12
  %569 = load float, float* %568, align 4
  %570 = fmul float %567, %569
  %571 = load float, float* %544, align 4
  %572 = fadd float %571, %570
  store float %572, float* %544, align 4
  %573 = getelementptr inbounds float, float* %2, i64 5
  store float 0.000000e+00, float* %573, align 4
  %574 = getelementptr inbounds float, float* %2, i64 5
  %575 = load float, float* %542, align 4
  %576 = getelementptr inbounds float, float* %0, i64 1
  %577 = load float, float* %576, align 4
  %578 = fmul float %575, %577
  %579 = fadd float %578, 0.000000e+00
  store float %579, float* %574, align 4
  %580 = getelementptr inbounds i8, i8* %339, i64 20
  %581 = bitcast i8* %580 to float*
  %582 = load float, float* %581, align 4
  %583 = getelementptr inbounds float, float* %0, i64 5
  %584 = load float, float* %583, align 4
  %585 = fmul float %582, %584
  %586 = load float, float* %574, align 4
  %587 = fadd float %586, %585
  store float %587, float* %574, align 4
  %588 = getelementptr inbounds i8, i8* %339, i64 24
  %589 = bitcast i8* %588 to float*
  %590 = load float, float* %589, align 4
  %591 = getelementptr inbounds float, float* %0, i64 9
  %592 = load float, float* %591, align 4
  %593 = fmul float %590, %592
  %594 = load float, float* %574, align 4
  %595 = fadd float %594, %593
  store float %595, float* %574, align 4
  %596 = getelementptr inbounds i8, i8* %339, i64 28
  %597 = bitcast i8* %596 to float*
  %598 = load float, float* %597, align 4
  %599 = getelementptr inbounds float, float* %0, i64 13
  %600 = load float, float* %599, align 4
  %601 = fmul float %598, %600
  %602 = load float, float* %574, align 4
  %603 = fadd float %602, %601
  store float %603, float* %574, align 4
  %604 = getelementptr inbounds float, float* %2, i64 6
  store float 0.000000e+00, float* %604, align 4
  %605 = getelementptr inbounds float, float* %2, i64 6
  %606 = load float, float* %542, align 4
  %607 = getelementptr inbounds float, float* %0, i64 2
  %608 = load float, float* %607, align 4
  %609 = fmul float %606, %608
  %610 = fadd float %609, 0.000000e+00
  store float %610, float* %605, align 4
  %611 = getelementptr inbounds i8, i8* %339, i64 20
  %612 = bitcast i8* %611 to float*
  %613 = load float, float* %612, align 4
  %614 = getelementptr inbounds float, float* %0, i64 6
  %615 = load float, float* %614, align 4
  %616 = fmul float %613, %615
  %617 = load float, float* %605, align 4
  %618 = fadd float %617, %616
  store float %618, float* %605, align 4
  %619 = getelementptr inbounds i8, i8* %339, i64 24
  %620 = bitcast i8* %619 to float*
  %621 = load float, float* %620, align 4
  %622 = getelementptr inbounds float, float* %0, i64 10
  %623 = load float, float* %622, align 4
  %624 = fmul float %621, %623
  %625 = load float, float* %605, align 4
  %626 = fadd float %625, %624
  store float %626, float* %605, align 4
  %627 = getelementptr inbounds i8, i8* %339, i64 28
  %628 = bitcast i8* %627 to float*
  %629 = load float, float* %628, align 4
  %630 = getelementptr inbounds float, float* %0, i64 14
  %631 = load float, float* %630, align 4
  %632 = fmul float %629, %631
  %633 = load float, float* %605, align 4
  %634 = fadd float %633, %632
  store float %634, float* %605, align 4
  %635 = getelementptr inbounds float, float* %2, i64 7
  store float 0.000000e+00, float* %635, align 4
  %636 = getelementptr inbounds float, float* %2, i64 7
  %637 = load float, float* %542, align 4
  %638 = getelementptr inbounds float, float* %0, i64 3
  %639 = load float, float* %638, align 4
  %640 = fmul float %637, %639
  %641 = fadd float %640, 0.000000e+00
  store float %641, float* %636, align 4
  %642 = getelementptr inbounds i8, i8* %339, i64 20
  %643 = bitcast i8* %642 to float*
  %644 = load float, float* %643, align 4
  %645 = getelementptr inbounds float, float* %0, i64 7
  %646 = load float, float* %645, align 4
  %647 = fmul float %644, %646
  %648 = load float, float* %636, align 4
  %649 = fadd float %648, %647
  store float %649, float* %636, align 4
  %650 = getelementptr inbounds i8, i8* %339, i64 24
  %651 = bitcast i8* %650 to float*
  %652 = load float, float* %651, align 4
  %653 = getelementptr inbounds float, float* %0, i64 11
  %654 = load float, float* %653, align 4
  %655 = fmul float %652, %654
  %656 = load float, float* %636, align 4
  %657 = fadd float %656, %655
  store float %657, float* %636, align 4
  %658 = getelementptr inbounds i8, i8* %339, i64 28
  %659 = bitcast i8* %658 to float*
  %660 = load float, float* %659, align 4
  %661 = getelementptr inbounds float, float* %0, i64 15
  %662 = load float, float* %661, align 4
  %663 = fmul float %660, %662
  %664 = load float, float* %636, align 4
  %665 = fadd float %664, %663
  store float %665, float* %636, align 4
  %666 = getelementptr inbounds i8, i8* %339, i64 32
  %667 = bitcast i8* %666 to float*
  %668 = getelementptr inbounds float, float* %2, i64 8
  store float 0.000000e+00, float* %668, align 4
  %669 = getelementptr inbounds float, float* %2, i64 8
  %670 = load float, float* %667, align 4
  %671 = load float, float* %0, align 4
  %672 = fmul float %670, %671
  %673 = fadd float %672, 0.000000e+00
  store float %673, float* %669, align 4
  %674 = getelementptr inbounds i8, i8* %339, i64 36
  %675 = bitcast i8* %674 to float*
  %676 = load float, float* %675, align 4
  %677 = getelementptr inbounds float, float* %0, i64 4
  %678 = load float, float* %677, align 4
  %679 = fmul float %676, %678
  %680 = load float, float* %669, align 4
  %681 = fadd float %680, %679
  store float %681, float* %669, align 4
  %682 = getelementptr inbounds i8, i8* %339, i64 40
  %683 = bitcast i8* %682 to float*
  %684 = load float, float* %683, align 4
  %685 = getelementptr inbounds float, float* %0, i64 8
  %686 = load float, float* %685, align 4
  %687 = fmul float %684, %686
  %688 = load float, float* %669, align 4
  %689 = fadd float %688, %687
  store float %689, float* %669, align 4
  %690 = getelementptr inbounds i8, i8* %339, i64 44
  %691 = bitcast i8* %690 to float*
  %692 = load float, float* %691, align 4
  %693 = getelementptr inbounds float, float* %0, i64 12
  %694 = load float, float* %693, align 4
  %695 = fmul float %692, %694
  %696 = load float, float* %669, align 4
  %697 = fadd float %696, %695
  store float %697, float* %669, align 4
  %698 = getelementptr inbounds float, float* %2, i64 9
  store float 0.000000e+00, float* %698, align 4
  %699 = getelementptr inbounds float, float* %2, i64 9
  %700 = load float, float* %667, align 4
  %701 = getelementptr inbounds float, float* %0, i64 1
  %702 = load float, float* %701, align 4
  %703 = fmul float %700, %702
  %704 = fadd float %703, 0.000000e+00
  store float %704, float* %699, align 4
  %705 = getelementptr inbounds i8, i8* %339, i64 36
  %706 = bitcast i8* %705 to float*
  %707 = load float, float* %706, align 4
  %708 = getelementptr inbounds float, float* %0, i64 5
  %709 = load float, float* %708, align 4
  %710 = fmul float %707, %709
  %711 = load float, float* %699, align 4
  %712 = fadd float %711, %710
  store float %712, float* %699, align 4
  %713 = getelementptr inbounds i8, i8* %339, i64 40
  %714 = bitcast i8* %713 to float*
  %715 = load float, float* %714, align 4
  %716 = getelementptr inbounds float, float* %0, i64 9
  %717 = load float, float* %716, align 4
  %718 = fmul float %715, %717
  %719 = load float, float* %699, align 4
  %720 = fadd float %719, %718
  store float %720, float* %699, align 4
  %721 = getelementptr inbounds i8, i8* %339, i64 44
  %722 = bitcast i8* %721 to float*
  %723 = load float, float* %722, align 4
  %724 = getelementptr inbounds float, float* %0, i64 13
  %725 = load float, float* %724, align 4
  %726 = fmul float %723, %725
  %727 = load float, float* %699, align 4
  %728 = fadd float %727, %726
  store float %728, float* %699, align 4
  %729 = getelementptr inbounds float, float* %2, i64 10
  store float 0.000000e+00, float* %729, align 4
  %730 = getelementptr inbounds float, float* %2, i64 10
  %731 = load float, float* %667, align 4
  %732 = getelementptr inbounds float, float* %0, i64 2
  %733 = load float, float* %732, align 4
  %734 = fmul float %731, %733
  %735 = fadd float %734, 0.000000e+00
  store float %735, float* %730, align 4
  %736 = getelementptr inbounds i8, i8* %339, i64 36
  %737 = bitcast i8* %736 to float*
  %738 = load float, float* %737, align 4
  %739 = getelementptr inbounds float, float* %0, i64 6
  %740 = load float, float* %739, align 4
  %741 = fmul float %738, %740
  %742 = load float, float* %730, align 4
  %743 = fadd float %742, %741
  store float %743, float* %730, align 4
  %744 = getelementptr inbounds i8, i8* %339, i64 40
  %745 = bitcast i8* %744 to float*
  %746 = load float, float* %745, align 4
  %747 = getelementptr inbounds float, float* %0, i64 10
  %748 = load float, float* %747, align 4
  %749 = fmul float %746, %748
  %750 = load float, float* %730, align 4
  %751 = fadd float %750, %749
  store float %751, float* %730, align 4
  %752 = getelementptr inbounds i8, i8* %339, i64 44
  %753 = bitcast i8* %752 to float*
  %754 = load float, float* %753, align 4
  %755 = getelementptr inbounds float, float* %0, i64 14
  %756 = load float, float* %755, align 4
  %757 = fmul float %754, %756
  %758 = load float, float* %730, align 4
  %759 = fadd float %758, %757
  store float %759, float* %730, align 4
  %760 = getelementptr inbounds float, float* %2, i64 11
  store float 0.000000e+00, float* %760, align 4
  %761 = getelementptr inbounds float, float* %2, i64 11
  %762 = load float, float* %667, align 4
  %763 = getelementptr inbounds float, float* %0, i64 3
  %764 = load float, float* %763, align 4
  %765 = fmul float %762, %764
  %766 = fadd float %765, 0.000000e+00
  store float %766, float* %761, align 4
  %767 = getelementptr inbounds i8, i8* %339, i64 36
  %768 = bitcast i8* %767 to float*
  %769 = load float, float* %768, align 4
  %770 = getelementptr inbounds float, float* %0, i64 7
  %771 = load float, float* %770, align 4
  %772 = fmul float %769, %771
  %773 = load float, float* %761, align 4
  %774 = fadd float %773, %772
  store float %774, float* %761, align 4
  %775 = getelementptr inbounds i8, i8* %339, i64 40
  %776 = bitcast i8* %775 to float*
  %777 = load float, float* %776, align 4
  %778 = getelementptr inbounds float, float* %0, i64 11
  %779 = load float, float* %778, align 4
  %780 = fmul float %777, %779
  %781 = load float, float* %761, align 4
  %782 = fadd float %781, %780
  store float %782, float* %761, align 4
  %783 = getelementptr inbounds i8, i8* %339, i64 44
  %784 = bitcast i8* %783 to float*
  %785 = load float, float* %784, align 4
  %786 = getelementptr inbounds float, float* %0, i64 15
  %787 = load float, float* %786, align 4
  %788 = fmul float %785, %787
  %789 = load float, float* %761, align 4
  %790 = fadd float %789, %788
  store float %790, float* %761, align 4
  %791 = getelementptr inbounds i8, i8* %339, i64 48
  %792 = bitcast i8* %791 to float*
  %793 = getelementptr inbounds float, float* %2, i64 12
  store float 0.000000e+00, float* %793, align 4
  %794 = getelementptr inbounds float, float* %2, i64 12
  %795 = load float, float* %792, align 4
  %796 = load float, float* %0, align 4
  %797 = fmul float %795, %796
  %798 = fadd float %797, 0.000000e+00
  store float %798, float* %794, align 4
  %799 = getelementptr inbounds i8, i8* %339, i64 52
  %800 = bitcast i8* %799 to float*
  %801 = load float, float* %800, align 4
  %802 = getelementptr inbounds float, float* %0, i64 4
  %803 = load float, float* %802, align 4
  %804 = fmul float %801, %803
  %805 = load float, float* %794, align 4
  %806 = fadd float %805, %804
  store float %806, float* %794, align 4
  %807 = getelementptr inbounds i8, i8* %339, i64 56
  %808 = bitcast i8* %807 to float*
  %809 = load float, float* %808, align 4
  %810 = getelementptr inbounds float, float* %0, i64 8
  %811 = load float, float* %810, align 4
  %812 = fmul float %809, %811
  %813 = load float, float* %794, align 4
  %814 = fadd float %813, %812
  store float %814, float* %794, align 4
  %815 = getelementptr inbounds i8, i8* %339, i64 60
  %816 = bitcast i8* %815 to float*
  %817 = load float, float* %816, align 4
  %818 = getelementptr inbounds float, float* %0, i64 12
  %819 = load float, float* %818, align 4
  %820 = fmul float %817, %819
  %821 = load float, float* %794, align 4
  %822 = fadd float %821, %820
  store float %822, float* %794, align 4
  %823 = getelementptr inbounds float, float* %2, i64 13
  store float 0.000000e+00, float* %823, align 4
  %824 = getelementptr inbounds float, float* %2, i64 13
  %825 = load float, float* %792, align 4
  %826 = getelementptr inbounds float, float* %0, i64 1
  %827 = load float, float* %826, align 4
  %828 = fmul float %825, %827
  %829 = fadd float %828, 0.000000e+00
  store float %829, float* %824, align 4
  %830 = getelementptr inbounds i8, i8* %339, i64 52
  %831 = bitcast i8* %830 to float*
  %832 = load float, float* %831, align 4
  %833 = getelementptr inbounds float, float* %0, i64 5
  %834 = load float, float* %833, align 4
  %835 = fmul float %832, %834
  %836 = load float, float* %824, align 4
  %837 = fadd float %836, %835
  store float %837, float* %824, align 4
  %838 = getelementptr inbounds i8, i8* %339, i64 56
  %839 = bitcast i8* %838 to float*
  %840 = load float, float* %839, align 4
  %841 = getelementptr inbounds float, float* %0, i64 9
  %842 = load float, float* %841, align 4
  %843 = fmul float %840, %842
  %844 = load float, float* %824, align 4
  %845 = fadd float %844, %843
  store float %845, float* %824, align 4
  %846 = getelementptr inbounds i8, i8* %339, i64 60
  %847 = bitcast i8* %846 to float*
  %848 = load float, float* %847, align 4
  %849 = getelementptr inbounds float, float* %0, i64 13
  %850 = load float, float* %849, align 4
  %851 = fmul float %848, %850
  %852 = load float, float* %824, align 4
  %853 = fadd float %852, %851
  store float %853, float* %824, align 4
  %854 = getelementptr inbounds float, float* %2, i64 14
  store float 0.000000e+00, float* %854, align 4
  %855 = getelementptr inbounds float, float* %2, i64 14
  %856 = load float, float* %792, align 4
  %857 = getelementptr inbounds float, float* %0, i64 2
  %858 = load float, float* %857, align 4
  %859 = fmul float %856, %858
  %860 = fadd float %859, 0.000000e+00
  store float %860, float* %855, align 4
  %861 = getelementptr inbounds i8, i8* %339, i64 52
  %862 = bitcast i8* %861 to float*
  %863 = load float, float* %862, align 4
  %864 = getelementptr inbounds float, float* %0, i64 6
  %865 = load float, float* %864, align 4
  %866 = fmul float %863, %865
  %867 = load float, float* %855, align 4
  %868 = fadd float %867, %866
  store float %868, float* %855, align 4
  %869 = getelementptr inbounds i8, i8* %339, i64 56
  %870 = bitcast i8* %869 to float*
  %871 = load float, float* %870, align 4
  %872 = getelementptr inbounds float, float* %0, i64 10
  %873 = load float, float* %872, align 4
  %874 = fmul float %871, %873
  %875 = load float, float* %855, align 4
  %876 = fadd float %875, %874
  store float %876, float* %855, align 4
  %877 = getelementptr inbounds i8, i8* %339, i64 60
  %878 = bitcast i8* %877 to float*
  %879 = load float, float* %878, align 4
  %880 = getelementptr inbounds float, float* %0, i64 14
  %881 = load float, float* %880, align 4
  %882 = fmul float %879, %881
  %883 = load float, float* %855, align 4
  %884 = fadd float %883, %882
  store float %884, float* %855, align 4
  %885 = getelementptr inbounds float, float* %2, i64 15
  store float 0.000000e+00, float* %885, align 4
  %886 = getelementptr inbounds float, float* %2, i64 15
  %887 = load float, float* %792, align 4
  %888 = getelementptr inbounds float, float* %0, i64 3
  %889 = load float, float* %888, align 4
  %890 = fmul float %887, %889
  %891 = fadd float %890, 0.000000e+00
  store float %891, float* %886, align 4
  %892 = getelementptr inbounds i8, i8* %339, i64 52
  %893 = bitcast i8* %892 to float*
  %894 = load float, float* %893, align 4
  %895 = getelementptr inbounds float, float* %0, i64 7
  %896 = load float, float* %895, align 4
  %897 = fmul float %894, %896
  %898 = load float, float* %886, align 4
  %899 = fadd float %898, %897
  store float %899, float* %886, align 4
  %900 = getelementptr inbounds i8, i8* %339, i64 56
  %901 = bitcast i8* %900 to float*
  %902 = load float, float* %901, align 4
  %903 = getelementptr inbounds float, float* %0, i64 11
  %904 = load float, float* %903, align 4
  %905 = fmul float %902, %904
  %906 = load float, float* %886, align 4
  %907 = fadd float %906, %905
  store float %907, float* %886, align 4
  %908 = getelementptr inbounds i8, i8* %339, i64 60
  %909 = bitcast i8* %908 to float*
  %910 = load float, float* %909, align 4
  %911 = getelementptr inbounds float, float* %0, i64 15
  %912 = load float, float* %911, align 4
  %913 = fmul float %910, %912
  %914 = load float, float* %886, align 4
  %915 = fadd float %914, %913
  store float %915, float* %886, align 4
  call void @free(i8* %49)
  call void @free(i8* %51)
  call void @free(i8* %123)
  call void @free(i8* %125)
  call void @free(i8* %207)
  call void @free(i8* %339)
  %916 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #9
  %917 = bitcast i8* %916 to float*
  %918 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #9
  %919 = bitcast i8* %918 to float*
  %920 = getelementptr inbounds float, float* %2, i64 5
  %921 = bitcast float* %920 to i32*
  %922 = load i32, i32* %921, align 4
  %923 = bitcast i8* %916 to i32*
  store i32 %922, i32* %923, align 4
  %924 = getelementptr inbounds i8, i8* %8, i64 20
  %925 = bitcast i8* %924 to i32*
  %926 = load i32, i32* %925, align 4
  %927 = bitcast i8* %918 to i32*
  store i32 %926, i32* %927, align 4
  %928 = getelementptr inbounds float, float* %2, i64 9
  %929 = bitcast float* %928 to i32*
  %930 = load i32, i32* %929, align 4
  %931 = getelementptr inbounds i8, i8* %916, i64 4
  %932 = bitcast i8* %931 to i32*
  store i32 %930, i32* %932, align 4
  %933 = getelementptr inbounds i8, i8* %8, i64 36
  %934 = bitcast i8* %933 to i32*
  %935 = load i32, i32* %934, align 4
  %936 = getelementptr inbounds i8, i8* %918, i64 4
  %937 = bitcast i8* %936 to i32*
  store i32 %935, i32* %937, align 4
  %938 = getelementptr inbounds float, float* %2, i64 13
  %939 = bitcast float* %938 to i32*
  %940 = load i32, i32* %939, align 4
  %941 = getelementptr inbounds i8, i8* %916, i64 8
  %942 = bitcast i8* %941 to i32*
  store i32 %940, i32* %942, align 4
  %943 = getelementptr inbounds i8, i8* %8, i64 52
  %944 = bitcast i8* %943 to i32*
  %945 = load i32, i32* %944, align 4
  %946 = getelementptr inbounds i8, i8* %918, i64 8
  %947 = bitcast i8* %946 to i32*
  store i32 %945, i32* %947, align 4
  %948 = load float, float* %917, align 4
  %949 = fcmp ogt float %948, 0.000000e+00
  %950 = zext i1 %949 to i32
  %951 = fcmp olt float %948, 0.000000e+00
  %.neg209 = sext i1 %951 to i32
  %952 = add nsw i32 %.neg209, %950
  %953 = sitofp i32 %952 to float
  %954 = load float, float* %917, align 4
  %955 = fpext float %954 to double
  %square210 = fmul double %955, %955
  %956 = fadd double %square210, 0.000000e+00
  %957 = fptrunc double %956 to float
  %958 = getelementptr inbounds i8, i8* %916, i64 4
  %959 = bitcast i8* %958 to float*
  %960 = load float, float* %959, align 4
  %961 = fpext float %960 to double
  %square211 = fmul double %961, %961
  %962 = fpext float %957 to double
  %963 = fadd double %square211, %962
  %964 = fptrunc double %963 to float
  %965 = getelementptr inbounds i8, i8* %916, i64 8
  %966 = bitcast i8* %965 to float*
  %967 = load float, float* %966, align 4
  %968 = fpext float %967 to double
  %square212 = fmul double %968, %968
  %969 = fpext float %964 to double
  %970 = fadd double %square212, %969
  %971 = fptrunc double %970 to float
  %972 = fneg float %953
  %973 = call float @llvm.sqrt.f32(float %971)
  %974 = fmul float %973, %972
  %975 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #9
  %976 = bitcast i8* %975 to float*
  %977 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #9
  %978 = load float, float* %917, align 4
  %979 = load float, float* %919, align 4
  %980 = fmul float %974, %979
  %981 = fadd float %978, %980
  store float %981, float* %976, align 4
  %982 = getelementptr inbounds i8, i8* %916, i64 4
  %983 = bitcast i8* %982 to float*
  %984 = load float, float* %983, align 4
  %985 = getelementptr inbounds i8, i8* %918, i64 4
  %986 = bitcast i8* %985 to float*
  %987 = load float, float* %986, align 4
  %988 = fmul float %974, %987
  %989 = fadd float %984, %988
  %990 = getelementptr inbounds i8, i8* %975, i64 4
  %991 = bitcast i8* %990 to float*
  store float %989, float* %991, align 4
  %992 = getelementptr inbounds i8, i8* %916, i64 8
  %993 = bitcast i8* %992 to float*
  %994 = load float, float* %993, align 4
  %995 = getelementptr inbounds i8, i8* %918, i64 8
  %996 = bitcast i8* %995 to float*
  %997 = load float, float* %996, align 4
  %998 = fmul float %974, %997
  %999 = fadd float %994, %998
  %1000 = getelementptr inbounds i8, i8* %975, i64 8
  %1001 = bitcast i8* %1000 to float*
  store float %999, float* %1001, align 4
  %1002 = load float, float* %976, align 4
  %1003 = fpext float %1002 to double
  %square213 = fmul double %1003, %1003
  %1004 = fadd double %square213, 0.000000e+00
  %1005 = fptrunc double %1004 to float
  %1006 = getelementptr inbounds i8, i8* %975, i64 4
  %1007 = bitcast i8* %1006 to float*
  %1008 = load float, float* %1007, align 4
  %1009 = fpext float %1008 to double
  %square214 = fmul double %1009, %1009
  %1010 = fpext float %1005 to double
  %1011 = fadd double %square214, %1010
  %1012 = fptrunc double %1011 to float
  %1013 = getelementptr inbounds i8, i8* %975, i64 8
  %1014 = bitcast i8* %1013 to float*
  %1015 = load float, float* %1014, align 4
  %1016 = fpext float %1015 to double
  %square215 = fmul double %1016, %1016
  %1017 = fpext float %1012 to double
  %1018 = fadd double %square215, %1017
  %1019 = fptrunc double %1018 to float
  %1020 = bitcast i8* %977 to float*
  %1021 = call float @llvm.sqrt.f32(float %1019)
  %1022 = load float, float* %976, align 4
  %1023 = fdiv float %1022, %1021
  store float %1023, float* %1020, align 4
  %1024 = getelementptr inbounds i8, i8* %975, i64 4
  %1025 = bitcast i8* %1024 to float*
  %1026 = load float, float* %1025, align 4
  %1027 = fdiv float %1026, %1021
  %1028 = getelementptr inbounds i8, i8* %977, i64 4
  %1029 = bitcast i8* %1028 to float*
  store float %1027, float* %1029, align 4
  %1030 = getelementptr inbounds i8, i8* %975, i64 8
  %1031 = bitcast i8* %1030 to float*
  %1032 = load float, float* %1031, align 4
  %1033 = fdiv float %1032, %1021
  %1034 = getelementptr inbounds i8, i8* %977, i64 8
  %1035 = bitcast i8* %1034 to float*
  store float %1033, float* %1035, align 4
  %1036 = call dereferenceable_or_null(36) i8* @calloc(i64 4, i64 9) #9
  %1037 = bitcast i8* %1036 to float*
  %1038 = load float, float* %1020, align 4
  %1039 = fmul float %1038, 2.000000e+00
  %1040 = fmul float %1039, %1038
  %1041 = fsub float 1.000000e+00, %1040
  store float %1041, float* %1037, align 4
  %1042 = load float, float* %1020, align 4
  %1043 = fmul float %1042, 2.000000e+00
  %1044 = getelementptr inbounds i8, i8* %977, i64 4
  %1045 = bitcast i8* %1044 to float*
  %1046 = load float, float* %1045, align 4
  %1047 = fmul float %1043, %1046
  %1048 = fsub float 0.000000e+00, %1047
  %1049 = getelementptr inbounds i8, i8* %1036, i64 4
  %1050 = bitcast i8* %1049 to float*
  store float %1048, float* %1050, align 4
  %1051 = load float, float* %1020, align 4
  %1052 = fmul float %1051, 2.000000e+00
  %1053 = getelementptr inbounds i8, i8* %977, i64 8
  %1054 = bitcast i8* %1053 to float*
  %1055 = load float, float* %1054, align 4
  %1056 = fmul float %1052, %1055
  %1057 = fsub float 0.000000e+00, %1056
  %1058 = getelementptr inbounds i8, i8* %1036, i64 8
  %1059 = bitcast i8* %1058 to float*
  store float %1057, float* %1059, align 4
  %1060 = getelementptr inbounds i8, i8* %977, i64 4
  %1061 = bitcast i8* %1060 to float*
  %1062 = load float, float* %1061, align 4
  %1063 = fmul float %1062, 2.000000e+00
  %1064 = load float, float* %1020, align 4
  %1065 = fmul float %1063, %1064
  %1066 = fsub float 0.000000e+00, %1065
  %1067 = getelementptr inbounds i8, i8* %1036, i64 12
  %1068 = bitcast i8* %1067 to float*
  store float %1066, float* %1068, align 4
  %1069 = load float, float* %1061, align 4
  %1070 = fmul float %1069, 2.000000e+00
  %1071 = fmul float %1070, %1069
  %1072 = fsub float 1.000000e+00, %1071
  %1073 = getelementptr inbounds i8, i8* %1036, i64 16
  %1074 = bitcast i8* %1073 to float*
  store float %1072, float* %1074, align 4
  %1075 = load float, float* %1061, align 4
  %1076 = fmul float %1075, 2.000000e+00
  %1077 = getelementptr inbounds i8, i8* %977, i64 8
  %1078 = bitcast i8* %1077 to float*
  %1079 = load float, float* %1078, align 4
  %1080 = fmul float %1076, %1079
  %1081 = fsub float 0.000000e+00, %1080
  %1082 = getelementptr inbounds i8, i8* %1036, i64 20
  %1083 = bitcast i8* %1082 to float*
  store float %1081, float* %1083, align 4
  %1084 = getelementptr inbounds i8, i8* %977, i64 8
  %1085 = bitcast i8* %1084 to float*
  %1086 = load float, float* %1085, align 4
  %1087 = fmul float %1086, 2.000000e+00
  %1088 = load float, float* %1020, align 4
  %1089 = fmul float %1087, %1088
  %1090 = fsub float 0.000000e+00, %1089
  %1091 = getelementptr inbounds i8, i8* %1036, i64 24
  %1092 = bitcast i8* %1091 to float*
  store float %1090, float* %1092, align 4
  %1093 = load float, float* %1085, align 4
  %1094 = fmul float %1093, 2.000000e+00
  %1095 = getelementptr inbounds i8, i8* %977, i64 4
  %1096 = bitcast i8* %1095 to float*
  %1097 = load float, float* %1096, align 4
  %1098 = fmul float %1094, %1097
  %1099 = fsub float 0.000000e+00, %1098
  %1100 = getelementptr inbounds i8, i8* %1036, i64 28
  %1101 = bitcast i8* %1100 to float*
  store float %1099, float* %1101, align 4
  %1102 = load float, float* %1085, align 4
  %1103 = fmul float %1102, 2.000000e+00
  %1104 = fmul float %1103, %1102
  %1105 = fsub float 1.000000e+00, %1104
  %1106 = getelementptr inbounds i8, i8* %1036, i64 32
  %1107 = bitcast i8* %1106 to float*
  store float %1105, float* %1107, align 4
  %1108 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #9
  %1109 = bitcast i8* %1108 to float*
  store float 1.000000e+00, float* %1109, align 4
  %1110 = getelementptr inbounds i8, i8* %1108, i64 4
  %1111 = bitcast i8* %1110 to float*
  store float 0.000000e+00, float* %1111, align 4
  %1112 = getelementptr inbounds i8, i8* %1108, i64 8
  %1113 = bitcast i8* %1112 to float*
  store float 0.000000e+00, float* %1113, align 4
  %1114 = getelementptr inbounds i8, i8* %1108, i64 12
  %1115 = bitcast i8* %1114 to float*
  store float 0.000000e+00, float* %1115, align 4
  %1116 = getelementptr inbounds i8, i8* %1108, i64 16
  %1117 = bitcast i8* %1116 to float*
  store float 0.000000e+00, float* %1117, align 4
  %1118 = bitcast i8* %1036 to i32*
  %1119 = load i32, i32* %1118, align 4
  %1120 = getelementptr inbounds i8, i8* %1108, i64 20
  %1121 = bitcast i8* %1120 to i32*
  store i32 %1119, i32* %1121, align 4
  %1122 = getelementptr inbounds i8, i8* %1036, i64 4
  %1123 = bitcast i8* %1122 to i32*
  %1124 = load i32, i32* %1123, align 4
  %1125 = getelementptr inbounds i8, i8* %1108, i64 24
  %1126 = bitcast i8* %1125 to i32*
  store i32 %1124, i32* %1126, align 4
  %1127 = getelementptr inbounds i8, i8* %1036, i64 8
  %1128 = bitcast i8* %1127 to i32*
  %1129 = load i32, i32* %1128, align 4
  %1130 = getelementptr inbounds i8, i8* %1108, i64 28
  %1131 = bitcast i8* %1130 to i32*
  store i32 %1129, i32* %1131, align 4
  %1132 = getelementptr inbounds i8, i8* %1108, i64 32
  %1133 = bitcast i8* %1132 to float*
  store float 0.000000e+00, float* %1133, align 4
  %1134 = getelementptr inbounds i8, i8* %1036, i64 12
  %1135 = bitcast i8* %1134 to i32*
  %1136 = load i32, i32* %1135, align 4
  %1137 = getelementptr inbounds i8, i8* %1108, i64 36
  %1138 = bitcast i8* %1137 to i32*
  store i32 %1136, i32* %1138, align 4
  %1139 = getelementptr inbounds i8, i8* %1036, i64 16
  %1140 = bitcast i8* %1139 to i32*
  %1141 = load i32, i32* %1140, align 4
  %1142 = getelementptr inbounds i8, i8* %1108, i64 40
  %1143 = bitcast i8* %1142 to i32*
  store i32 %1141, i32* %1143, align 4
  %1144 = getelementptr inbounds i8, i8* %1036, i64 20
  %1145 = bitcast i8* %1144 to i32*
  %1146 = load i32, i32* %1145, align 4
  %1147 = getelementptr inbounds i8, i8* %1108, i64 44
  %1148 = bitcast i8* %1147 to i32*
  store i32 %1146, i32* %1148, align 4
  %1149 = getelementptr inbounds i8, i8* %1108, i64 48
  %1150 = bitcast i8* %1149 to float*
  store float 0.000000e+00, float* %1150, align 4
  %1151 = getelementptr inbounds i8, i8* %1036, i64 24
  %1152 = bitcast i8* %1151 to i32*
  %1153 = load i32, i32* %1152, align 4
  %1154 = getelementptr inbounds i8, i8* %1108, i64 52
  %1155 = bitcast i8* %1154 to i32*
  store i32 %1153, i32* %1155, align 4
  %1156 = getelementptr inbounds i8, i8* %1036, i64 28
  %1157 = bitcast i8* %1156 to i32*
  %1158 = load i32, i32* %1157, align 4
  %1159 = getelementptr inbounds i8, i8* %1108, i64 56
  %1160 = bitcast i8* %1159 to i32*
  store i32 %1158, i32* %1160, align 4
  %1161 = getelementptr inbounds i8, i8* %1036, i64 32
  %1162 = bitcast i8* %1161 to i32*
  %1163 = load i32, i32* %1162, align 4
  %1164 = getelementptr inbounds i8, i8* %1108, i64 60
  %1165 = bitcast i8* %1164 to i32*
  store i32 %1163, i32* %1165, align 4
  %1166 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #9
  %1167 = bitcast i8* %1166 to float*
  store float 0.000000e+00, float* %1167, align 4
  %1168 = load float, float* %1109, align 4
  %1169 = load float, float* %1, align 4
  %1170 = fmul float %1168, %1169
  %1171 = fadd float %1170, 0.000000e+00
  store float %1171, float* %1167, align 4
  %1172 = getelementptr inbounds i8, i8* %1108, i64 4
  %1173 = bitcast i8* %1172 to float*
  %1174 = load float, float* %1173, align 4
  %1175 = getelementptr inbounds float, float* %1, i64 4
  %1176 = load float, float* %1175, align 4
  %1177 = fmul float %1174, %1176
  %1178 = load float, float* %1167, align 4
  %1179 = fadd float %1178, %1177
  store float %1179, float* %1167, align 4
  %1180 = getelementptr inbounds i8, i8* %1108, i64 8
  %1181 = bitcast i8* %1180 to float*
  %1182 = load float, float* %1181, align 4
  %1183 = getelementptr inbounds float, float* %1, i64 8
  %1184 = load float, float* %1183, align 4
  %1185 = fmul float %1182, %1184
  %1186 = load float, float* %1167, align 4
  %1187 = fadd float %1186, %1185
  store float %1187, float* %1167, align 4
  %1188 = getelementptr inbounds i8, i8* %1108, i64 12
  %1189 = bitcast i8* %1188 to float*
  %1190 = load float, float* %1189, align 4
  %1191 = getelementptr inbounds float, float* %1, i64 12
  %1192 = load float, float* %1191, align 4
  %1193 = fmul float %1190, %1192
  %1194 = load float, float* %1167, align 4
  %1195 = fadd float %1194, %1193
  store float %1195, float* %1167, align 4
  %1196 = getelementptr inbounds i8, i8* %1166, i64 4
  %1197 = bitcast i8* %1196 to float*
  store float 0.000000e+00, float* %1197, align 4
  %1198 = getelementptr inbounds i8, i8* %1166, i64 4
  %1199 = bitcast i8* %1198 to float*
  %1200 = load float, float* %1109, align 4
  %1201 = getelementptr inbounds float, float* %1, i64 1
  %1202 = load float, float* %1201, align 4
  %1203 = fmul float %1200, %1202
  %1204 = load float, float* %1199, align 4
  %1205 = fadd float %1204, %1203
  store float %1205, float* %1199, align 4
  %1206 = getelementptr inbounds i8, i8* %1108, i64 4
  %1207 = bitcast i8* %1206 to float*
  %1208 = load float, float* %1207, align 4
  %1209 = getelementptr inbounds float, float* %1, i64 5
  %1210 = load float, float* %1209, align 4
  %1211 = fmul float %1208, %1210
  %1212 = load float, float* %1199, align 4
  %1213 = fadd float %1212, %1211
  store float %1213, float* %1199, align 4
  %1214 = getelementptr inbounds i8, i8* %1108, i64 8
  %1215 = bitcast i8* %1214 to float*
  %1216 = load float, float* %1215, align 4
  %1217 = getelementptr inbounds float, float* %1, i64 9
  %1218 = load float, float* %1217, align 4
  %1219 = fmul float %1216, %1218
  %1220 = load float, float* %1199, align 4
  %1221 = fadd float %1220, %1219
  store float %1221, float* %1199, align 4
  %1222 = getelementptr inbounds i8, i8* %1108, i64 12
  %1223 = bitcast i8* %1222 to float*
  %1224 = load float, float* %1223, align 4
  %1225 = getelementptr inbounds float, float* %1, i64 13
  %1226 = load float, float* %1225, align 4
  %1227 = fmul float %1224, %1226
  %1228 = load float, float* %1199, align 4
  %1229 = fadd float %1228, %1227
  store float %1229, float* %1199, align 4
  %1230 = getelementptr inbounds i8, i8* %1166, i64 8
  %1231 = bitcast i8* %1230 to float*
  store float 0.000000e+00, float* %1231, align 4
  %1232 = getelementptr inbounds i8, i8* %1166, i64 8
  %1233 = bitcast i8* %1232 to float*
  %1234 = load float, float* %1109, align 4
  %1235 = getelementptr inbounds float, float* %1, i64 2
  %1236 = load float, float* %1235, align 4
  %1237 = fmul float %1234, %1236
  %1238 = load float, float* %1233, align 4
  %1239 = fadd float %1238, %1237
  store float %1239, float* %1233, align 4
  %1240 = getelementptr inbounds i8, i8* %1108, i64 4
  %1241 = bitcast i8* %1240 to float*
  %1242 = load float, float* %1241, align 4
  %1243 = getelementptr inbounds float, float* %1, i64 6
  %1244 = load float, float* %1243, align 4
  %1245 = fmul float %1242, %1244
  %1246 = load float, float* %1233, align 4
  %1247 = fadd float %1246, %1245
  store float %1247, float* %1233, align 4
  %1248 = getelementptr inbounds i8, i8* %1108, i64 8
  %1249 = bitcast i8* %1248 to float*
  %1250 = load float, float* %1249, align 4
  %1251 = getelementptr inbounds float, float* %1, i64 10
  %1252 = load float, float* %1251, align 4
  %1253 = fmul float %1250, %1252
  %1254 = load float, float* %1233, align 4
  %1255 = fadd float %1254, %1253
  store float %1255, float* %1233, align 4
  %1256 = getelementptr inbounds i8, i8* %1108, i64 12
  %1257 = bitcast i8* %1256 to float*
  %1258 = load float, float* %1257, align 4
  %1259 = getelementptr inbounds float, float* %1, i64 14
  %1260 = load float, float* %1259, align 4
  %1261 = fmul float %1258, %1260
  %1262 = load float, float* %1233, align 4
  %1263 = fadd float %1262, %1261
  store float %1263, float* %1233, align 4
  %1264 = getelementptr inbounds i8, i8* %1166, i64 12
  %1265 = bitcast i8* %1264 to float*
  store float 0.000000e+00, float* %1265, align 4
  %1266 = getelementptr inbounds i8, i8* %1166, i64 12
  %1267 = bitcast i8* %1266 to float*
  %1268 = load float, float* %1109, align 4
  %1269 = getelementptr inbounds float, float* %1, i64 3
  %1270 = load float, float* %1269, align 4
  %1271 = fmul float %1268, %1270
  %1272 = load float, float* %1267, align 4
  %1273 = fadd float %1272, %1271
  store float %1273, float* %1267, align 4
  %1274 = getelementptr inbounds i8, i8* %1108, i64 4
  %1275 = bitcast i8* %1274 to float*
  %1276 = load float, float* %1275, align 4
  %1277 = getelementptr inbounds float, float* %1, i64 7
  %1278 = load float, float* %1277, align 4
  %1279 = fmul float %1276, %1278
  %1280 = load float, float* %1267, align 4
  %1281 = fadd float %1280, %1279
  store float %1281, float* %1267, align 4
  %1282 = getelementptr inbounds i8, i8* %1108, i64 8
  %1283 = bitcast i8* %1282 to float*
  %1284 = load float, float* %1283, align 4
  %1285 = getelementptr inbounds float, float* %1, i64 11
  %1286 = load float, float* %1285, align 4
  %1287 = fmul float %1284, %1286
  %1288 = load float, float* %1267, align 4
  %1289 = fadd float %1288, %1287
  store float %1289, float* %1267, align 4
  %1290 = getelementptr inbounds i8, i8* %1108, i64 12
  %1291 = bitcast i8* %1290 to float*
  %1292 = load float, float* %1291, align 4
  %1293 = getelementptr inbounds float, float* %1, i64 15
  %1294 = load float, float* %1293, align 4
  %1295 = fmul float %1292, %1294
  %1296 = load float, float* %1267, align 4
  %1297 = fadd float %1296, %1295
  store float %1297, float* %1267, align 4
  %1298 = getelementptr inbounds i8, i8* %1108, i64 16
  %1299 = bitcast i8* %1298 to float*
  %1300 = getelementptr inbounds i8, i8* %1166, i64 16
  %1301 = bitcast i8* %1300 to float*
  store float 0.000000e+00, float* %1301, align 4
  %1302 = getelementptr inbounds i8, i8* %1166, i64 16
  %1303 = bitcast i8* %1302 to float*
  %1304 = load float, float* %1299, align 4
  %1305 = load float, float* %1, align 4
  %1306 = fmul float %1304, %1305
  %1307 = fadd float %1306, 0.000000e+00
  store float %1307, float* %1303, align 4
  %1308 = getelementptr inbounds i8, i8* %1108, i64 20
  %1309 = bitcast i8* %1308 to float*
  %1310 = load float, float* %1309, align 4
  %1311 = getelementptr inbounds float, float* %1, i64 4
  %1312 = load float, float* %1311, align 4
  %1313 = fmul float %1310, %1312
  %1314 = load float, float* %1303, align 4
  %1315 = fadd float %1314, %1313
  store float %1315, float* %1303, align 4
  %1316 = getelementptr inbounds i8, i8* %1108, i64 24
  %1317 = bitcast i8* %1316 to float*
  %1318 = load float, float* %1317, align 4
  %1319 = getelementptr inbounds float, float* %1, i64 8
  %1320 = load float, float* %1319, align 4
  %1321 = fmul float %1318, %1320
  %1322 = load float, float* %1303, align 4
  %1323 = fadd float %1322, %1321
  store float %1323, float* %1303, align 4
  %1324 = getelementptr inbounds i8, i8* %1108, i64 28
  %1325 = bitcast i8* %1324 to float*
  %1326 = load float, float* %1325, align 4
  %1327 = getelementptr inbounds float, float* %1, i64 12
  %1328 = load float, float* %1327, align 4
  %1329 = fmul float %1326, %1328
  %1330 = load float, float* %1303, align 4
  %1331 = fadd float %1330, %1329
  store float %1331, float* %1303, align 4
  %1332 = getelementptr inbounds i8, i8* %1166, i64 20
  %1333 = bitcast i8* %1332 to float*
  store float 0.000000e+00, float* %1333, align 4
  %1334 = getelementptr inbounds i8, i8* %1166, i64 20
  %1335 = bitcast i8* %1334 to float*
  %1336 = load float, float* %1299, align 4
  %1337 = getelementptr inbounds float, float* %1, i64 1
  %1338 = load float, float* %1337, align 4
  %1339 = fmul float %1336, %1338
  %1340 = load float, float* %1335, align 4
  %1341 = fadd float %1340, %1339
  store float %1341, float* %1335, align 4
  %1342 = getelementptr inbounds i8, i8* %1108, i64 20
  %1343 = bitcast i8* %1342 to float*
  %1344 = load float, float* %1343, align 4
  %1345 = getelementptr inbounds float, float* %1, i64 5
  %1346 = load float, float* %1345, align 4
  %1347 = fmul float %1344, %1346
  %1348 = load float, float* %1335, align 4
  %1349 = fadd float %1348, %1347
  store float %1349, float* %1335, align 4
  %1350 = getelementptr inbounds i8, i8* %1108, i64 24
  %1351 = bitcast i8* %1350 to float*
  %1352 = load float, float* %1351, align 4
  %1353 = getelementptr inbounds float, float* %1, i64 9
  %1354 = load float, float* %1353, align 4
  %1355 = fmul float %1352, %1354
  %1356 = load float, float* %1335, align 4
  %1357 = fadd float %1356, %1355
  store float %1357, float* %1335, align 4
  %1358 = getelementptr inbounds i8, i8* %1108, i64 28
  %1359 = bitcast i8* %1358 to float*
  %1360 = load float, float* %1359, align 4
  %1361 = getelementptr inbounds float, float* %1, i64 13
  %1362 = load float, float* %1361, align 4
  %1363 = fmul float %1360, %1362
  %1364 = load float, float* %1335, align 4
  %1365 = fadd float %1364, %1363
  store float %1365, float* %1335, align 4
  %1366 = getelementptr inbounds i8, i8* %1166, i64 24
  %1367 = bitcast i8* %1366 to float*
  store float 0.000000e+00, float* %1367, align 4
  %1368 = getelementptr inbounds i8, i8* %1166, i64 24
  %1369 = bitcast i8* %1368 to float*
  %1370 = load float, float* %1299, align 4
  %1371 = getelementptr inbounds float, float* %1, i64 2
  %1372 = load float, float* %1371, align 4
  %1373 = fmul float %1370, %1372
  %1374 = load float, float* %1369, align 4
  %1375 = fadd float %1374, %1373
  store float %1375, float* %1369, align 4
  %1376 = getelementptr inbounds i8, i8* %1108, i64 20
  %1377 = bitcast i8* %1376 to float*
  %1378 = load float, float* %1377, align 4
  %1379 = getelementptr inbounds float, float* %1, i64 6
  %1380 = load float, float* %1379, align 4
  %1381 = fmul float %1378, %1380
  %1382 = load float, float* %1369, align 4
  %1383 = fadd float %1382, %1381
  store float %1383, float* %1369, align 4
  %1384 = getelementptr inbounds i8, i8* %1108, i64 24
  %1385 = bitcast i8* %1384 to float*
  %1386 = load float, float* %1385, align 4
  %1387 = getelementptr inbounds float, float* %1, i64 10
  %1388 = load float, float* %1387, align 4
  %1389 = fmul float %1386, %1388
  %1390 = load float, float* %1369, align 4
  %1391 = fadd float %1390, %1389
  store float %1391, float* %1369, align 4
  %1392 = getelementptr inbounds i8, i8* %1108, i64 28
  %1393 = bitcast i8* %1392 to float*
  %1394 = load float, float* %1393, align 4
  %1395 = getelementptr inbounds float, float* %1, i64 14
  %1396 = load float, float* %1395, align 4
  %1397 = fmul float %1394, %1396
  %1398 = load float, float* %1369, align 4
  %1399 = fadd float %1398, %1397
  store float %1399, float* %1369, align 4
  %1400 = getelementptr inbounds i8, i8* %1166, i64 28
  %1401 = bitcast i8* %1400 to float*
  store float 0.000000e+00, float* %1401, align 4
  %1402 = getelementptr inbounds i8, i8* %1166, i64 28
  %1403 = bitcast i8* %1402 to float*
  %1404 = load float, float* %1299, align 4
  %1405 = getelementptr inbounds float, float* %1, i64 3
  %1406 = load float, float* %1405, align 4
  %1407 = fmul float %1404, %1406
  %1408 = load float, float* %1403, align 4
  %1409 = fadd float %1408, %1407
  store float %1409, float* %1403, align 4
  %1410 = getelementptr inbounds i8, i8* %1108, i64 20
  %1411 = bitcast i8* %1410 to float*
  %1412 = load float, float* %1411, align 4
  %1413 = getelementptr inbounds float, float* %1, i64 7
  %1414 = load float, float* %1413, align 4
  %1415 = fmul float %1412, %1414
  %1416 = load float, float* %1403, align 4
  %1417 = fadd float %1416, %1415
  store float %1417, float* %1403, align 4
  %1418 = getelementptr inbounds i8, i8* %1108, i64 24
  %1419 = bitcast i8* %1418 to float*
  %1420 = load float, float* %1419, align 4
  %1421 = getelementptr inbounds float, float* %1, i64 11
  %1422 = load float, float* %1421, align 4
  %1423 = fmul float %1420, %1422
  %1424 = load float, float* %1403, align 4
  %1425 = fadd float %1424, %1423
  store float %1425, float* %1403, align 4
  %1426 = getelementptr inbounds i8, i8* %1108, i64 28
  %1427 = bitcast i8* %1426 to float*
  %1428 = load float, float* %1427, align 4
  %1429 = getelementptr inbounds float, float* %1, i64 15
  %1430 = load float, float* %1429, align 4
  %1431 = fmul float %1428, %1430
  %1432 = load float, float* %1403, align 4
  %1433 = fadd float %1432, %1431
  store float %1433, float* %1403, align 4
  %1434 = getelementptr inbounds i8, i8* %1108, i64 32
  %1435 = bitcast i8* %1434 to float*
  %1436 = getelementptr inbounds i8, i8* %1166, i64 32
  %1437 = bitcast i8* %1436 to float*
  store float 0.000000e+00, float* %1437, align 4
  %1438 = getelementptr inbounds i8, i8* %1166, i64 32
  %1439 = bitcast i8* %1438 to float*
  %1440 = load float, float* %1435, align 4
  %1441 = load float, float* %1, align 4
  %1442 = fmul float %1440, %1441
  %1443 = fadd float %1442, 0.000000e+00
  store float %1443, float* %1439, align 4
  %1444 = getelementptr inbounds i8, i8* %1108, i64 36
  %1445 = bitcast i8* %1444 to float*
  %1446 = load float, float* %1445, align 4
  %1447 = getelementptr inbounds float, float* %1, i64 4
  %1448 = load float, float* %1447, align 4
  %1449 = fmul float %1446, %1448
  %1450 = load float, float* %1439, align 4
  %1451 = fadd float %1450, %1449
  store float %1451, float* %1439, align 4
  %1452 = getelementptr inbounds i8, i8* %1108, i64 40
  %1453 = bitcast i8* %1452 to float*
  %1454 = load float, float* %1453, align 4
  %1455 = getelementptr inbounds float, float* %1, i64 8
  %1456 = load float, float* %1455, align 4
  %1457 = fmul float %1454, %1456
  %1458 = load float, float* %1439, align 4
  %1459 = fadd float %1458, %1457
  store float %1459, float* %1439, align 4
  %1460 = getelementptr inbounds i8, i8* %1108, i64 44
  %1461 = bitcast i8* %1460 to float*
  %1462 = load float, float* %1461, align 4
  %1463 = getelementptr inbounds float, float* %1, i64 12
  %1464 = load float, float* %1463, align 4
  %1465 = fmul float %1462, %1464
  %1466 = load float, float* %1439, align 4
  %1467 = fadd float %1466, %1465
  store float %1467, float* %1439, align 4
  %1468 = getelementptr inbounds i8, i8* %1166, i64 36
  %1469 = bitcast i8* %1468 to float*
  store float 0.000000e+00, float* %1469, align 4
  %1470 = getelementptr inbounds i8, i8* %1166, i64 36
  %1471 = bitcast i8* %1470 to float*
  %1472 = load float, float* %1435, align 4
  %1473 = getelementptr inbounds float, float* %1, i64 1
  %1474 = load float, float* %1473, align 4
  %1475 = fmul float %1472, %1474
  %1476 = load float, float* %1471, align 4
  %1477 = fadd float %1476, %1475
  store float %1477, float* %1471, align 4
  %1478 = getelementptr inbounds i8, i8* %1108, i64 36
  %1479 = bitcast i8* %1478 to float*
  %1480 = load float, float* %1479, align 4
  %1481 = getelementptr inbounds float, float* %1, i64 5
  %1482 = load float, float* %1481, align 4
  %1483 = fmul float %1480, %1482
  %1484 = load float, float* %1471, align 4
  %1485 = fadd float %1484, %1483
  store float %1485, float* %1471, align 4
  %1486 = getelementptr inbounds i8, i8* %1108, i64 40
  %1487 = bitcast i8* %1486 to float*
  %1488 = load float, float* %1487, align 4
  %1489 = getelementptr inbounds float, float* %1, i64 9
  %1490 = load float, float* %1489, align 4
  %1491 = fmul float %1488, %1490
  %1492 = load float, float* %1471, align 4
  %1493 = fadd float %1492, %1491
  store float %1493, float* %1471, align 4
  %1494 = getelementptr inbounds i8, i8* %1108, i64 44
  %1495 = bitcast i8* %1494 to float*
  %1496 = load float, float* %1495, align 4
  %1497 = getelementptr inbounds float, float* %1, i64 13
  %1498 = load float, float* %1497, align 4
  %1499 = fmul float %1496, %1498
  %1500 = load float, float* %1471, align 4
  %1501 = fadd float %1500, %1499
  store float %1501, float* %1471, align 4
  %1502 = getelementptr inbounds i8, i8* %1166, i64 40
  %1503 = bitcast i8* %1502 to float*
  store float 0.000000e+00, float* %1503, align 4
  %1504 = getelementptr inbounds i8, i8* %1166, i64 40
  %1505 = bitcast i8* %1504 to float*
  %1506 = load float, float* %1435, align 4
  %1507 = getelementptr inbounds float, float* %1, i64 2
  %1508 = load float, float* %1507, align 4
  %1509 = fmul float %1506, %1508
  %1510 = load float, float* %1505, align 4
  %1511 = fadd float %1510, %1509
  store float %1511, float* %1505, align 4
  %1512 = getelementptr inbounds i8, i8* %1108, i64 36
  %1513 = bitcast i8* %1512 to float*
  %1514 = load float, float* %1513, align 4
  %1515 = getelementptr inbounds float, float* %1, i64 6
  %1516 = load float, float* %1515, align 4
  %1517 = fmul float %1514, %1516
  %1518 = load float, float* %1505, align 4
  %1519 = fadd float %1518, %1517
  store float %1519, float* %1505, align 4
  %1520 = getelementptr inbounds i8, i8* %1108, i64 40
  %1521 = bitcast i8* %1520 to float*
  %1522 = load float, float* %1521, align 4
  %1523 = getelementptr inbounds float, float* %1, i64 10
  %1524 = load float, float* %1523, align 4
  %1525 = fmul float %1522, %1524
  %1526 = load float, float* %1505, align 4
  %1527 = fadd float %1526, %1525
  store float %1527, float* %1505, align 4
  %1528 = getelementptr inbounds i8, i8* %1108, i64 44
  %1529 = bitcast i8* %1528 to float*
  %1530 = load float, float* %1529, align 4
  %1531 = getelementptr inbounds float, float* %1, i64 14
  %1532 = load float, float* %1531, align 4
  %1533 = fmul float %1530, %1532
  %1534 = load float, float* %1505, align 4
  %1535 = fadd float %1534, %1533
  store float %1535, float* %1505, align 4
  %1536 = getelementptr inbounds i8, i8* %1166, i64 44
  %1537 = bitcast i8* %1536 to float*
  store float 0.000000e+00, float* %1537, align 4
  %1538 = getelementptr inbounds i8, i8* %1166, i64 44
  %1539 = bitcast i8* %1538 to float*
  %1540 = load float, float* %1435, align 4
  %1541 = getelementptr inbounds float, float* %1, i64 3
  %1542 = load float, float* %1541, align 4
  %1543 = fmul float %1540, %1542
  %1544 = load float, float* %1539, align 4
  %1545 = fadd float %1544, %1543
  store float %1545, float* %1539, align 4
  %1546 = getelementptr inbounds i8, i8* %1108, i64 36
  %1547 = bitcast i8* %1546 to float*
  %1548 = load float, float* %1547, align 4
  %1549 = getelementptr inbounds float, float* %1, i64 7
  %1550 = load float, float* %1549, align 4
  %1551 = fmul float %1548, %1550
  %1552 = load float, float* %1539, align 4
  %1553 = fadd float %1552, %1551
  store float %1553, float* %1539, align 4
  %1554 = getelementptr inbounds i8, i8* %1108, i64 40
  %1555 = bitcast i8* %1554 to float*
  %1556 = load float, float* %1555, align 4
  %1557 = getelementptr inbounds float, float* %1, i64 11
  %1558 = load float, float* %1557, align 4
  %1559 = fmul float %1556, %1558
  %1560 = load float, float* %1539, align 4
  %1561 = fadd float %1560, %1559
  store float %1561, float* %1539, align 4
  %1562 = getelementptr inbounds i8, i8* %1108, i64 44
  %1563 = bitcast i8* %1562 to float*
  %1564 = load float, float* %1563, align 4
  %1565 = getelementptr inbounds float, float* %1, i64 15
  %1566 = load float, float* %1565, align 4
  %1567 = fmul float %1564, %1566
  %1568 = load float, float* %1539, align 4
  %1569 = fadd float %1568, %1567
  store float %1569, float* %1539, align 4
  %1570 = getelementptr inbounds i8, i8* %1108, i64 48
  %1571 = bitcast i8* %1570 to float*
  %1572 = getelementptr inbounds i8, i8* %1166, i64 48
  %1573 = bitcast i8* %1572 to float*
  store float 0.000000e+00, float* %1573, align 4
  %1574 = getelementptr inbounds i8, i8* %1166, i64 48
  %1575 = bitcast i8* %1574 to float*
  %1576 = load float, float* %1571, align 4
  %1577 = load float, float* %1, align 4
  %1578 = fmul float %1576, %1577
  %1579 = fadd float %1578, 0.000000e+00
  store float %1579, float* %1575, align 4
  %1580 = getelementptr inbounds i8, i8* %1108, i64 52
  %1581 = bitcast i8* %1580 to float*
  %1582 = load float, float* %1581, align 4
  %1583 = getelementptr inbounds float, float* %1, i64 4
  %1584 = load float, float* %1583, align 4
  %1585 = fmul float %1582, %1584
  %1586 = load float, float* %1575, align 4
  %1587 = fadd float %1586, %1585
  store float %1587, float* %1575, align 4
  %1588 = getelementptr inbounds i8, i8* %1108, i64 56
  %1589 = bitcast i8* %1588 to float*
  %1590 = load float, float* %1589, align 4
  %1591 = getelementptr inbounds float, float* %1, i64 8
  %1592 = load float, float* %1591, align 4
  %1593 = fmul float %1590, %1592
  %1594 = load float, float* %1575, align 4
  %1595 = fadd float %1594, %1593
  store float %1595, float* %1575, align 4
  %1596 = getelementptr inbounds i8, i8* %1108, i64 60
  %1597 = bitcast i8* %1596 to float*
  %1598 = load float, float* %1597, align 4
  %1599 = getelementptr inbounds float, float* %1, i64 12
  %1600 = load float, float* %1599, align 4
  %1601 = fmul float %1598, %1600
  %1602 = load float, float* %1575, align 4
  %1603 = fadd float %1602, %1601
  store float %1603, float* %1575, align 4
  %1604 = getelementptr inbounds i8, i8* %1166, i64 52
  %1605 = bitcast i8* %1604 to float*
  store float 0.000000e+00, float* %1605, align 4
  %1606 = getelementptr inbounds i8, i8* %1166, i64 52
  %1607 = bitcast i8* %1606 to float*
  %1608 = load float, float* %1571, align 4
  %1609 = getelementptr inbounds float, float* %1, i64 1
  %1610 = load float, float* %1609, align 4
  %1611 = fmul float %1608, %1610
  %1612 = load float, float* %1607, align 4
  %1613 = fadd float %1612, %1611
  store float %1613, float* %1607, align 4
  %1614 = getelementptr inbounds i8, i8* %1108, i64 52
  %1615 = bitcast i8* %1614 to float*
  %1616 = load float, float* %1615, align 4
  %1617 = getelementptr inbounds float, float* %1, i64 5
  %1618 = load float, float* %1617, align 4
  %1619 = fmul float %1616, %1618
  %1620 = load float, float* %1607, align 4
  %1621 = fadd float %1620, %1619
  store float %1621, float* %1607, align 4
  %1622 = getelementptr inbounds i8, i8* %1108, i64 56
  %1623 = bitcast i8* %1622 to float*
  %1624 = load float, float* %1623, align 4
  %1625 = getelementptr inbounds float, float* %1, i64 9
  %1626 = load float, float* %1625, align 4
  %1627 = fmul float %1624, %1626
  %1628 = load float, float* %1607, align 4
  %1629 = fadd float %1628, %1627
  store float %1629, float* %1607, align 4
  %1630 = getelementptr inbounds i8, i8* %1108, i64 60
  %1631 = bitcast i8* %1630 to float*
  %1632 = load float, float* %1631, align 4
  %1633 = getelementptr inbounds float, float* %1, i64 13
  %1634 = load float, float* %1633, align 4
  %1635 = fmul float %1632, %1634
  %1636 = load float, float* %1607, align 4
  %1637 = fadd float %1636, %1635
  store float %1637, float* %1607, align 4
  %1638 = getelementptr inbounds i8, i8* %1166, i64 56
  %1639 = bitcast i8* %1638 to float*
  store float 0.000000e+00, float* %1639, align 4
  %1640 = getelementptr inbounds i8, i8* %1166, i64 56
  %1641 = bitcast i8* %1640 to float*
  %1642 = load float, float* %1571, align 4
  %1643 = getelementptr inbounds float, float* %1, i64 2
  %1644 = load float, float* %1643, align 4
  %1645 = fmul float %1642, %1644
  %1646 = load float, float* %1641, align 4
  %1647 = fadd float %1646, %1645
  store float %1647, float* %1641, align 4
  %1648 = getelementptr inbounds i8, i8* %1108, i64 52
  %1649 = bitcast i8* %1648 to float*
  %1650 = load float, float* %1649, align 4
  %1651 = getelementptr inbounds float, float* %1, i64 6
  %1652 = load float, float* %1651, align 4
  %1653 = fmul float %1650, %1652
  %1654 = load float, float* %1641, align 4
  %1655 = fadd float %1654, %1653
  store float %1655, float* %1641, align 4
  %1656 = getelementptr inbounds i8, i8* %1108, i64 56
  %1657 = bitcast i8* %1656 to float*
  %1658 = load float, float* %1657, align 4
  %1659 = getelementptr inbounds float, float* %1, i64 10
  %1660 = load float, float* %1659, align 4
  %1661 = fmul float %1658, %1660
  %1662 = load float, float* %1641, align 4
  %1663 = fadd float %1662, %1661
  store float %1663, float* %1641, align 4
  %1664 = getelementptr inbounds i8, i8* %1108, i64 60
  %1665 = bitcast i8* %1664 to float*
  %1666 = load float, float* %1665, align 4
  %1667 = getelementptr inbounds float, float* %1, i64 14
  %1668 = load float, float* %1667, align 4
  %1669 = fmul float %1666, %1668
  %1670 = load float, float* %1641, align 4
  %1671 = fadd float %1670, %1669
  store float %1671, float* %1641, align 4
  %1672 = getelementptr inbounds i8, i8* %1166, i64 60
  %1673 = bitcast i8* %1672 to float*
  store float 0.000000e+00, float* %1673, align 4
  %1674 = getelementptr inbounds i8, i8* %1166, i64 60
  %1675 = bitcast i8* %1674 to float*
  %1676 = load float, float* %1571, align 4
  %1677 = getelementptr inbounds float, float* %1, i64 3
  %1678 = load float, float* %1677, align 4
  %1679 = fmul float %1676, %1678
  %1680 = load float, float* %1675, align 4
  %1681 = fadd float %1680, %1679
  store float %1681, float* %1675, align 4
  %1682 = getelementptr inbounds i8, i8* %1108, i64 52
  %1683 = bitcast i8* %1682 to float*
  %1684 = load float, float* %1683, align 4
  %1685 = getelementptr inbounds float, float* %1, i64 7
  %1686 = load float, float* %1685, align 4
  %1687 = fmul float %1684, %1686
  %1688 = load float, float* %1675, align 4
  %1689 = fadd float %1688, %1687
  store float %1689, float* %1675, align 4
  %1690 = getelementptr inbounds i8, i8* %1108, i64 56
  %1691 = bitcast i8* %1690 to float*
  %1692 = load float, float* %1691, align 4
  %1693 = getelementptr inbounds float, float* %1, i64 11
  %1694 = load float, float* %1693, align 4
  %1695 = fmul float %1692, %1694
  %1696 = load float, float* %1675, align 4
  %1697 = fadd float %1696, %1695
  store float %1697, float* %1675, align 4
  %1698 = getelementptr inbounds i8, i8* %1108, i64 60
  %1699 = bitcast i8* %1698 to float*
  %1700 = load float, float* %1699, align 4
  %1701 = getelementptr inbounds float, float* %1, i64 15
  %1702 = load float, float* %1701, align 4
  %1703 = fmul float %1700, %1702
  %1704 = load float, float* %1675, align 4
  %1705 = fadd float %1704, %1703
  store float %1705, float* %1675, align 4
  %1706 = call i8* @__memcpy_chk(i8* %40, i8* %1166, i64 64, i64 %42) #8
  store float 0.000000e+00, float* %1167, align 4
  %1707 = load float, float* %1109, align 4
  %1708 = load float, float* %2, align 4
  %1709 = fmul float %1707, %1708
  %1710 = fadd float %1709, 0.000000e+00
  store float %1710, float* %1167, align 4
  %1711 = getelementptr inbounds i8, i8* %1108, i64 4
  %1712 = bitcast i8* %1711 to float*
  %1713 = load float, float* %1712, align 4
  %1714 = getelementptr inbounds float, float* %2, i64 4
  %1715 = load float, float* %1714, align 4
  %1716 = fmul float %1713, %1715
  %1717 = load float, float* %1167, align 4
  %1718 = fadd float %1717, %1716
  store float %1718, float* %1167, align 4
  %1719 = getelementptr inbounds i8, i8* %1108, i64 8
  %1720 = bitcast i8* %1719 to float*
  %1721 = load float, float* %1720, align 4
  %1722 = getelementptr inbounds float, float* %2, i64 8
  %1723 = load float, float* %1722, align 4
  %1724 = fmul float %1721, %1723
  %1725 = load float, float* %1167, align 4
  %1726 = fadd float %1725, %1724
  store float %1726, float* %1167, align 4
  %1727 = getelementptr inbounds i8, i8* %1108, i64 12
  %1728 = bitcast i8* %1727 to float*
  %1729 = load float, float* %1728, align 4
  %1730 = getelementptr inbounds float, float* %2, i64 12
  %1731 = load float, float* %1730, align 4
  %1732 = fmul float %1729, %1731
  %1733 = load float, float* %1167, align 4
  %1734 = fadd float %1733, %1732
  store float %1734, float* %1167, align 4
  %1735 = getelementptr inbounds i8, i8* %1166, i64 4
  %1736 = bitcast i8* %1735 to float*
  store float 0.000000e+00, float* %1736, align 4
  %1737 = getelementptr inbounds i8, i8* %1166, i64 4
  %1738 = bitcast i8* %1737 to float*
  %1739 = load float, float* %1109, align 4
  %1740 = getelementptr inbounds float, float* %2, i64 1
  %1741 = load float, float* %1740, align 4
  %1742 = fmul float %1739, %1741
  %1743 = load float, float* %1738, align 4
  %1744 = fadd float %1743, %1742
  store float %1744, float* %1738, align 4
  %1745 = getelementptr inbounds i8, i8* %1108, i64 4
  %1746 = bitcast i8* %1745 to float*
  %1747 = load float, float* %1746, align 4
  %1748 = getelementptr inbounds float, float* %2, i64 5
  %1749 = load float, float* %1748, align 4
  %1750 = fmul float %1747, %1749
  %1751 = load float, float* %1738, align 4
  %1752 = fadd float %1751, %1750
  store float %1752, float* %1738, align 4
  %1753 = getelementptr inbounds i8, i8* %1108, i64 8
  %1754 = bitcast i8* %1753 to float*
  %1755 = load float, float* %1754, align 4
  %1756 = getelementptr inbounds float, float* %2, i64 9
  %1757 = load float, float* %1756, align 4
  %1758 = fmul float %1755, %1757
  %1759 = load float, float* %1738, align 4
  %1760 = fadd float %1759, %1758
  store float %1760, float* %1738, align 4
  %1761 = getelementptr inbounds i8, i8* %1108, i64 12
  %1762 = bitcast i8* %1761 to float*
  %1763 = load float, float* %1762, align 4
  %1764 = getelementptr inbounds float, float* %2, i64 13
  %1765 = load float, float* %1764, align 4
  %1766 = fmul float %1763, %1765
  %1767 = load float, float* %1738, align 4
  %1768 = fadd float %1767, %1766
  store float %1768, float* %1738, align 4
  %1769 = getelementptr inbounds i8, i8* %1166, i64 8
  %1770 = bitcast i8* %1769 to float*
  store float 0.000000e+00, float* %1770, align 4
  %1771 = getelementptr inbounds i8, i8* %1166, i64 8
  %1772 = bitcast i8* %1771 to float*
  %1773 = load float, float* %1109, align 4
  %1774 = getelementptr inbounds float, float* %2, i64 2
  %1775 = load float, float* %1774, align 4
  %1776 = fmul float %1773, %1775
  %1777 = load float, float* %1772, align 4
  %1778 = fadd float %1777, %1776
  store float %1778, float* %1772, align 4
  %1779 = getelementptr inbounds i8, i8* %1108, i64 4
  %1780 = bitcast i8* %1779 to float*
  %1781 = load float, float* %1780, align 4
  %1782 = getelementptr inbounds float, float* %2, i64 6
  %1783 = load float, float* %1782, align 4
  %1784 = fmul float %1781, %1783
  %1785 = load float, float* %1772, align 4
  %1786 = fadd float %1785, %1784
  store float %1786, float* %1772, align 4
  %1787 = getelementptr inbounds i8, i8* %1108, i64 8
  %1788 = bitcast i8* %1787 to float*
  %1789 = load float, float* %1788, align 4
  %1790 = getelementptr inbounds float, float* %2, i64 10
  %1791 = load float, float* %1790, align 4
  %1792 = fmul float %1789, %1791
  %1793 = load float, float* %1772, align 4
  %1794 = fadd float %1793, %1792
  store float %1794, float* %1772, align 4
  %1795 = getelementptr inbounds i8, i8* %1108, i64 12
  %1796 = bitcast i8* %1795 to float*
  %1797 = load float, float* %1796, align 4
  %1798 = getelementptr inbounds float, float* %2, i64 14
  %1799 = load float, float* %1798, align 4
  %1800 = fmul float %1797, %1799
  %1801 = load float, float* %1772, align 4
  %1802 = fadd float %1801, %1800
  store float %1802, float* %1772, align 4
  %1803 = getelementptr inbounds i8, i8* %1166, i64 12
  %1804 = bitcast i8* %1803 to float*
  store float 0.000000e+00, float* %1804, align 4
  %1805 = getelementptr inbounds i8, i8* %1166, i64 12
  %1806 = bitcast i8* %1805 to float*
  %1807 = load float, float* %1109, align 4
  %1808 = getelementptr inbounds float, float* %2, i64 3
  %1809 = load float, float* %1808, align 4
  %1810 = fmul float %1807, %1809
  %1811 = load float, float* %1806, align 4
  %1812 = fadd float %1811, %1810
  store float %1812, float* %1806, align 4
  %1813 = getelementptr inbounds i8, i8* %1108, i64 4
  %1814 = bitcast i8* %1813 to float*
  %1815 = load float, float* %1814, align 4
  %1816 = getelementptr inbounds float, float* %2, i64 7
  %1817 = load float, float* %1816, align 4
  %1818 = fmul float %1815, %1817
  %1819 = load float, float* %1806, align 4
  %1820 = fadd float %1819, %1818
  store float %1820, float* %1806, align 4
  %1821 = getelementptr inbounds i8, i8* %1108, i64 8
  %1822 = bitcast i8* %1821 to float*
  %1823 = load float, float* %1822, align 4
  %1824 = getelementptr inbounds float, float* %2, i64 11
  %1825 = load float, float* %1824, align 4
  %1826 = fmul float %1823, %1825
  %1827 = load float, float* %1806, align 4
  %1828 = fadd float %1827, %1826
  store float %1828, float* %1806, align 4
  %1829 = getelementptr inbounds i8, i8* %1108, i64 12
  %1830 = bitcast i8* %1829 to float*
  %1831 = load float, float* %1830, align 4
  %1832 = getelementptr inbounds float, float* %2, i64 15
  %1833 = load float, float* %1832, align 4
  %1834 = fmul float %1831, %1833
  %1835 = load float, float* %1806, align 4
  %1836 = fadd float %1835, %1834
  store float %1836, float* %1806, align 4
  %1837 = getelementptr inbounds i8, i8* %1108, i64 16
  %1838 = bitcast i8* %1837 to float*
  %1839 = getelementptr inbounds i8, i8* %1166, i64 16
  %1840 = bitcast i8* %1839 to float*
  store float 0.000000e+00, float* %1840, align 4
  %1841 = getelementptr inbounds i8, i8* %1166, i64 16
  %1842 = bitcast i8* %1841 to float*
  %1843 = load float, float* %1838, align 4
  %1844 = load float, float* %2, align 4
  %1845 = fmul float %1843, %1844
  %1846 = fadd float %1845, 0.000000e+00
  store float %1846, float* %1842, align 4
  %1847 = getelementptr inbounds i8, i8* %1108, i64 20
  %1848 = bitcast i8* %1847 to float*
  %1849 = load float, float* %1848, align 4
  %1850 = getelementptr inbounds float, float* %2, i64 4
  %1851 = load float, float* %1850, align 4
  %1852 = fmul float %1849, %1851
  %1853 = load float, float* %1842, align 4
  %1854 = fadd float %1853, %1852
  store float %1854, float* %1842, align 4
  %1855 = getelementptr inbounds i8, i8* %1108, i64 24
  %1856 = bitcast i8* %1855 to float*
  %1857 = load float, float* %1856, align 4
  %1858 = getelementptr inbounds float, float* %2, i64 8
  %1859 = load float, float* %1858, align 4
  %1860 = fmul float %1857, %1859
  %1861 = load float, float* %1842, align 4
  %1862 = fadd float %1861, %1860
  store float %1862, float* %1842, align 4
  %1863 = getelementptr inbounds i8, i8* %1108, i64 28
  %1864 = bitcast i8* %1863 to float*
  %1865 = load float, float* %1864, align 4
  %1866 = getelementptr inbounds float, float* %2, i64 12
  %1867 = load float, float* %1866, align 4
  %1868 = fmul float %1865, %1867
  %1869 = load float, float* %1842, align 4
  %1870 = fadd float %1869, %1868
  store float %1870, float* %1842, align 4
  %1871 = getelementptr inbounds i8, i8* %1166, i64 20
  %1872 = bitcast i8* %1871 to float*
  store float 0.000000e+00, float* %1872, align 4
  %1873 = getelementptr inbounds i8, i8* %1166, i64 20
  %1874 = bitcast i8* %1873 to float*
  %1875 = load float, float* %1838, align 4
  %1876 = getelementptr inbounds float, float* %2, i64 1
  %1877 = load float, float* %1876, align 4
  %1878 = fmul float %1875, %1877
  %1879 = load float, float* %1874, align 4
  %1880 = fadd float %1879, %1878
  store float %1880, float* %1874, align 4
  %1881 = getelementptr inbounds i8, i8* %1108, i64 20
  %1882 = bitcast i8* %1881 to float*
  %1883 = load float, float* %1882, align 4
  %1884 = getelementptr inbounds float, float* %2, i64 5
  %1885 = load float, float* %1884, align 4
  %1886 = fmul float %1883, %1885
  %1887 = load float, float* %1874, align 4
  %1888 = fadd float %1887, %1886
  store float %1888, float* %1874, align 4
  %1889 = getelementptr inbounds i8, i8* %1108, i64 24
  %1890 = bitcast i8* %1889 to float*
  %1891 = load float, float* %1890, align 4
  %1892 = getelementptr inbounds float, float* %2, i64 9
  %1893 = load float, float* %1892, align 4
  %1894 = fmul float %1891, %1893
  %1895 = load float, float* %1874, align 4
  %1896 = fadd float %1895, %1894
  store float %1896, float* %1874, align 4
  %1897 = getelementptr inbounds i8, i8* %1108, i64 28
  %1898 = bitcast i8* %1897 to float*
  %1899 = load float, float* %1898, align 4
  %1900 = getelementptr inbounds float, float* %2, i64 13
  %1901 = load float, float* %1900, align 4
  %1902 = fmul float %1899, %1901
  %1903 = load float, float* %1874, align 4
  %1904 = fadd float %1903, %1902
  store float %1904, float* %1874, align 4
  %1905 = getelementptr inbounds i8, i8* %1166, i64 24
  %1906 = bitcast i8* %1905 to float*
  store float 0.000000e+00, float* %1906, align 4
  %1907 = getelementptr inbounds i8, i8* %1166, i64 24
  %1908 = bitcast i8* %1907 to float*
  %1909 = load float, float* %1838, align 4
  %1910 = getelementptr inbounds float, float* %2, i64 2
  %1911 = load float, float* %1910, align 4
  %1912 = fmul float %1909, %1911
  %1913 = load float, float* %1908, align 4
  %1914 = fadd float %1913, %1912
  store float %1914, float* %1908, align 4
  %1915 = getelementptr inbounds i8, i8* %1108, i64 20
  %1916 = bitcast i8* %1915 to float*
  %1917 = load float, float* %1916, align 4
  %1918 = getelementptr inbounds float, float* %2, i64 6
  %1919 = load float, float* %1918, align 4
  %1920 = fmul float %1917, %1919
  %1921 = load float, float* %1908, align 4
  %1922 = fadd float %1921, %1920
  store float %1922, float* %1908, align 4
  %1923 = getelementptr inbounds i8, i8* %1108, i64 24
  %1924 = bitcast i8* %1923 to float*
  %1925 = load float, float* %1924, align 4
  %1926 = getelementptr inbounds float, float* %2, i64 10
  %1927 = load float, float* %1926, align 4
  %1928 = fmul float %1925, %1927
  %1929 = load float, float* %1908, align 4
  %1930 = fadd float %1929, %1928
  store float %1930, float* %1908, align 4
  %1931 = getelementptr inbounds i8, i8* %1108, i64 28
  %1932 = bitcast i8* %1931 to float*
  %1933 = load float, float* %1932, align 4
  %1934 = getelementptr inbounds float, float* %2, i64 14
  %1935 = load float, float* %1934, align 4
  %1936 = fmul float %1933, %1935
  %1937 = load float, float* %1908, align 4
  %1938 = fadd float %1937, %1936
  store float %1938, float* %1908, align 4
  %1939 = getelementptr inbounds i8, i8* %1166, i64 28
  %1940 = bitcast i8* %1939 to float*
  store float 0.000000e+00, float* %1940, align 4
  %1941 = getelementptr inbounds i8, i8* %1166, i64 28
  %1942 = bitcast i8* %1941 to float*
  %1943 = load float, float* %1838, align 4
  %1944 = getelementptr inbounds float, float* %2, i64 3
  %1945 = load float, float* %1944, align 4
  %1946 = fmul float %1943, %1945
  %1947 = load float, float* %1942, align 4
  %1948 = fadd float %1947, %1946
  store float %1948, float* %1942, align 4
  %1949 = getelementptr inbounds i8, i8* %1108, i64 20
  %1950 = bitcast i8* %1949 to float*
  %1951 = load float, float* %1950, align 4
  %1952 = getelementptr inbounds float, float* %2, i64 7
  %1953 = load float, float* %1952, align 4
  %1954 = fmul float %1951, %1953
  %1955 = load float, float* %1942, align 4
  %1956 = fadd float %1955, %1954
  store float %1956, float* %1942, align 4
  %1957 = getelementptr inbounds i8, i8* %1108, i64 24
  %1958 = bitcast i8* %1957 to float*
  %1959 = load float, float* %1958, align 4
  %1960 = getelementptr inbounds float, float* %2, i64 11
  %1961 = load float, float* %1960, align 4
  %1962 = fmul float %1959, %1961
  %1963 = load float, float* %1942, align 4
  %1964 = fadd float %1963, %1962
  store float %1964, float* %1942, align 4
  %1965 = getelementptr inbounds i8, i8* %1108, i64 28
  %1966 = bitcast i8* %1965 to float*
  %1967 = load float, float* %1966, align 4
  %1968 = getelementptr inbounds float, float* %2, i64 15
  %1969 = load float, float* %1968, align 4
  %1970 = fmul float %1967, %1969
  %1971 = load float, float* %1942, align 4
  %1972 = fadd float %1971, %1970
  store float %1972, float* %1942, align 4
  %1973 = getelementptr inbounds i8, i8* %1108, i64 32
  %1974 = bitcast i8* %1973 to float*
  %1975 = getelementptr inbounds i8, i8* %1166, i64 32
  %1976 = bitcast i8* %1975 to float*
  store float 0.000000e+00, float* %1976, align 4
  %1977 = getelementptr inbounds i8, i8* %1166, i64 32
  %1978 = bitcast i8* %1977 to float*
  %1979 = load float, float* %1974, align 4
  %1980 = load float, float* %2, align 4
  %1981 = fmul float %1979, %1980
  %1982 = fadd float %1981, 0.000000e+00
  store float %1982, float* %1978, align 4
  %1983 = getelementptr inbounds i8, i8* %1108, i64 36
  %1984 = bitcast i8* %1983 to float*
  %1985 = load float, float* %1984, align 4
  %1986 = getelementptr inbounds float, float* %2, i64 4
  %1987 = load float, float* %1986, align 4
  %1988 = fmul float %1985, %1987
  %1989 = load float, float* %1978, align 4
  %1990 = fadd float %1989, %1988
  store float %1990, float* %1978, align 4
  %1991 = getelementptr inbounds i8, i8* %1108, i64 40
  %1992 = bitcast i8* %1991 to float*
  %1993 = load float, float* %1992, align 4
  %1994 = getelementptr inbounds float, float* %2, i64 8
  %1995 = load float, float* %1994, align 4
  %1996 = fmul float %1993, %1995
  %1997 = load float, float* %1978, align 4
  %1998 = fadd float %1997, %1996
  store float %1998, float* %1978, align 4
  %1999 = getelementptr inbounds i8, i8* %1108, i64 44
  %2000 = bitcast i8* %1999 to float*
  %2001 = load float, float* %2000, align 4
  %2002 = getelementptr inbounds float, float* %2, i64 12
  %2003 = load float, float* %2002, align 4
  %2004 = fmul float %2001, %2003
  %2005 = load float, float* %1978, align 4
  %2006 = fadd float %2005, %2004
  store float %2006, float* %1978, align 4
  %2007 = getelementptr inbounds i8, i8* %1166, i64 36
  %2008 = bitcast i8* %2007 to float*
  store float 0.000000e+00, float* %2008, align 4
  %2009 = getelementptr inbounds i8, i8* %1166, i64 36
  %2010 = bitcast i8* %2009 to float*
  %2011 = load float, float* %1974, align 4
  %2012 = getelementptr inbounds float, float* %2, i64 1
  %2013 = load float, float* %2012, align 4
  %2014 = fmul float %2011, %2013
  %2015 = load float, float* %2010, align 4
  %2016 = fadd float %2015, %2014
  store float %2016, float* %2010, align 4
  %2017 = getelementptr inbounds i8, i8* %1108, i64 36
  %2018 = bitcast i8* %2017 to float*
  %2019 = load float, float* %2018, align 4
  %2020 = getelementptr inbounds float, float* %2, i64 5
  %2021 = load float, float* %2020, align 4
  %2022 = fmul float %2019, %2021
  %2023 = load float, float* %2010, align 4
  %2024 = fadd float %2023, %2022
  store float %2024, float* %2010, align 4
  %2025 = getelementptr inbounds i8, i8* %1108, i64 40
  %2026 = bitcast i8* %2025 to float*
  %2027 = load float, float* %2026, align 4
  %2028 = getelementptr inbounds float, float* %2, i64 9
  %2029 = load float, float* %2028, align 4
  %2030 = fmul float %2027, %2029
  %2031 = load float, float* %2010, align 4
  %2032 = fadd float %2031, %2030
  store float %2032, float* %2010, align 4
  %2033 = getelementptr inbounds i8, i8* %1108, i64 44
  %2034 = bitcast i8* %2033 to float*
  %2035 = load float, float* %2034, align 4
  %2036 = getelementptr inbounds float, float* %2, i64 13
  %2037 = load float, float* %2036, align 4
  %2038 = fmul float %2035, %2037
  %2039 = load float, float* %2010, align 4
  %2040 = fadd float %2039, %2038
  store float %2040, float* %2010, align 4
  %2041 = getelementptr inbounds i8, i8* %1166, i64 40
  %2042 = bitcast i8* %2041 to float*
  store float 0.000000e+00, float* %2042, align 4
  %2043 = getelementptr inbounds i8, i8* %1166, i64 40
  %2044 = bitcast i8* %2043 to float*
  %2045 = load float, float* %1974, align 4
  %2046 = getelementptr inbounds float, float* %2, i64 2
  %2047 = load float, float* %2046, align 4
  %2048 = fmul float %2045, %2047
  %2049 = load float, float* %2044, align 4
  %2050 = fadd float %2049, %2048
  store float %2050, float* %2044, align 4
  %2051 = getelementptr inbounds i8, i8* %1108, i64 36
  %2052 = bitcast i8* %2051 to float*
  %2053 = load float, float* %2052, align 4
  %2054 = getelementptr inbounds float, float* %2, i64 6
  %2055 = load float, float* %2054, align 4
  %2056 = fmul float %2053, %2055
  %2057 = load float, float* %2044, align 4
  %2058 = fadd float %2057, %2056
  store float %2058, float* %2044, align 4
  %2059 = getelementptr inbounds i8, i8* %1108, i64 40
  %2060 = bitcast i8* %2059 to float*
  %2061 = load float, float* %2060, align 4
  %2062 = getelementptr inbounds float, float* %2, i64 10
  %2063 = load float, float* %2062, align 4
  %2064 = fmul float %2061, %2063
  %2065 = load float, float* %2044, align 4
  %2066 = fadd float %2065, %2064
  store float %2066, float* %2044, align 4
  %2067 = getelementptr inbounds i8, i8* %1108, i64 44
  %2068 = bitcast i8* %2067 to float*
  %2069 = load float, float* %2068, align 4
  %2070 = getelementptr inbounds float, float* %2, i64 14
  %2071 = load float, float* %2070, align 4
  %2072 = fmul float %2069, %2071
  %2073 = load float, float* %2044, align 4
  %2074 = fadd float %2073, %2072
  store float %2074, float* %2044, align 4
  %2075 = getelementptr inbounds i8, i8* %1166, i64 44
  %2076 = bitcast i8* %2075 to float*
  store float 0.000000e+00, float* %2076, align 4
  %2077 = getelementptr inbounds i8, i8* %1166, i64 44
  %2078 = bitcast i8* %2077 to float*
  %2079 = load float, float* %1974, align 4
  %2080 = getelementptr inbounds float, float* %2, i64 3
  %2081 = load float, float* %2080, align 4
  %2082 = fmul float %2079, %2081
  %2083 = load float, float* %2078, align 4
  %2084 = fadd float %2083, %2082
  store float %2084, float* %2078, align 4
  %2085 = getelementptr inbounds i8, i8* %1108, i64 36
  %2086 = bitcast i8* %2085 to float*
  %2087 = load float, float* %2086, align 4
  %2088 = getelementptr inbounds float, float* %2, i64 7
  %2089 = load float, float* %2088, align 4
  %2090 = fmul float %2087, %2089
  %2091 = load float, float* %2078, align 4
  %2092 = fadd float %2091, %2090
  store float %2092, float* %2078, align 4
  %2093 = getelementptr inbounds i8, i8* %1108, i64 40
  %2094 = bitcast i8* %2093 to float*
  %2095 = load float, float* %2094, align 4
  %2096 = getelementptr inbounds float, float* %2, i64 11
  %2097 = load float, float* %2096, align 4
  %2098 = fmul float %2095, %2097
  %2099 = load float, float* %2078, align 4
  %2100 = fadd float %2099, %2098
  store float %2100, float* %2078, align 4
  %2101 = getelementptr inbounds i8, i8* %1108, i64 44
  %2102 = bitcast i8* %2101 to float*
  %2103 = load float, float* %2102, align 4
  %2104 = getelementptr inbounds float, float* %2, i64 15
  %2105 = load float, float* %2104, align 4
  %2106 = fmul float %2103, %2105
  %2107 = load float, float* %2078, align 4
  %2108 = fadd float %2107, %2106
  store float %2108, float* %2078, align 4
  %2109 = getelementptr inbounds i8, i8* %1108, i64 48
  %2110 = bitcast i8* %2109 to float*
  %2111 = getelementptr inbounds i8, i8* %1166, i64 48
  %2112 = bitcast i8* %2111 to float*
  store float 0.000000e+00, float* %2112, align 4
  %2113 = getelementptr inbounds i8, i8* %1166, i64 48
  %2114 = bitcast i8* %2113 to float*
  %2115 = load float, float* %2110, align 4
  %2116 = load float, float* %2, align 4
  %2117 = fmul float %2115, %2116
  %2118 = fadd float %2117, 0.000000e+00
  store float %2118, float* %2114, align 4
  %2119 = getelementptr inbounds i8, i8* %1108, i64 52
  %2120 = bitcast i8* %2119 to float*
  %2121 = load float, float* %2120, align 4
  %2122 = getelementptr inbounds float, float* %2, i64 4
  %2123 = load float, float* %2122, align 4
  %2124 = fmul float %2121, %2123
  %2125 = load float, float* %2114, align 4
  %2126 = fadd float %2125, %2124
  store float %2126, float* %2114, align 4
  %2127 = getelementptr inbounds i8, i8* %1108, i64 56
  %2128 = bitcast i8* %2127 to float*
  %2129 = load float, float* %2128, align 4
  %2130 = getelementptr inbounds float, float* %2, i64 8
  %2131 = load float, float* %2130, align 4
  %2132 = fmul float %2129, %2131
  %2133 = load float, float* %2114, align 4
  %2134 = fadd float %2133, %2132
  store float %2134, float* %2114, align 4
  %2135 = getelementptr inbounds i8, i8* %1108, i64 60
  %2136 = bitcast i8* %2135 to float*
  %2137 = load float, float* %2136, align 4
  %2138 = getelementptr inbounds float, float* %2, i64 12
  %2139 = load float, float* %2138, align 4
  %2140 = fmul float %2137, %2139
  %2141 = load float, float* %2114, align 4
  %2142 = fadd float %2141, %2140
  store float %2142, float* %2114, align 4
  %2143 = getelementptr inbounds i8, i8* %1166, i64 52
  %2144 = bitcast i8* %2143 to float*
  store float 0.000000e+00, float* %2144, align 4
  %2145 = getelementptr inbounds i8, i8* %1166, i64 52
  %2146 = bitcast i8* %2145 to float*
  %2147 = load float, float* %2110, align 4
  %2148 = getelementptr inbounds float, float* %2, i64 1
  %2149 = load float, float* %2148, align 4
  %2150 = fmul float %2147, %2149
  %2151 = load float, float* %2146, align 4
  %2152 = fadd float %2151, %2150
  store float %2152, float* %2146, align 4
  %2153 = getelementptr inbounds i8, i8* %1108, i64 52
  %2154 = bitcast i8* %2153 to float*
  %2155 = load float, float* %2154, align 4
  %2156 = getelementptr inbounds float, float* %2, i64 5
  %2157 = load float, float* %2156, align 4
  %2158 = fmul float %2155, %2157
  %2159 = load float, float* %2146, align 4
  %2160 = fadd float %2159, %2158
  store float %2160, float* %2146, align 4
  %2161 = getelementptr inbounds i8, i8* %1108, i64 56
  %2162 = bitcast i8* %2161 to float*
  %2163 = load float, float* %2162, align 4
  %2164 = getelementptr inbounds float, float* %2, i64 9
  %2165 = load float, float* %2164, align 4
  %2166 = fmul float %2163, %2165
  %2167 = load float, float* %2146, align 4
  %2168 = fadd float %2167, %2166
  store float %2168, float* %2146, align 4
  %2169 = getelementptr inbounds i8, i8* %1108, i64 60
  %2170 = bitcast i8* %2169 to float*
  %2171 = load float, float* %2170, align 4
  %2172 = getelementptr inbounds float, float* %2, i64 13
  %2173 = load float, float* %2172, align 4
  %2174 = fmul float %2171, %2173
  %2175 = load float, float* %2146, align 4
  %2176 = fadd float %2175, %2174
  store float %2176, float* %2146, align 4
  %2177 = getelementptr inbounds i8, i8* %1166, i64 56
  %2178 = bitcast i8* %2177 to float*
  store float 0.000000e+00, float* %2178, align 4
  %2179 = getelementptr inbounds i8, i8* %1166, i64 56
  %2180 = bitcast i8* %2179 to float*
  %2181 = load float, float* %2110, align 4
  %2182 = getelementptr inbounds float, float* %2, i64 2
  %2183 = load float, float* %2182, align 4
  %2184 = fmul float %2181, %2183
  %2185 = load float, float* %2180, align 4
  %2186 = fadd float %2185, %2184
  store float %2186, float* %2180, align 4
  %2187 = getelementptr inbounds i8, i8* %1108, i64 52
  %2188 = bitcast i8* %2187 to float*
  %2189 = load float, float* %2188, align 4
  %2190 = getelementptr inbounds float, float* %2, i64 6
  %2191 = load float, float* %2190, align 4
  %2192 = fmul float %2189, %2191
  %2193 = load float, float* %2180, align 4
  %2194 = fadd float %2193, %2192
  store float %2194, float* %2180, align 4
  %2195 = getelementptr inbounds i8, i8* %1108, i64 56
  %2196 = bitcast i8* %2195 to float*
  %2197 = load float, float* %2196, align 4
  %2198 = getelementptr inbounds float, float* %2, i64 10
  %2199 = load float, float* %2198, align 4
  %2200 = fmul float %2197, %2199
  %2201 = load float, float* %2180, align 4
  %2202 = fadd float %2201, %2200
  store float %2202, float* %2180, align 4
  %2203 = getelementptr inbounds i8, i8* %1108, i64 60
  %2204 = bitcast i8* %2203 to float*
  %2205 = load float, float* %2204, align 4
  %2206 = getelementptr inbounds float, float* %2, i64 14
  %2207 = load float, float* %2206, align 4
  %2208 = fmul float %2205, %2207
  %2209 = load float, float* %2180, align 4
  %2210 = fadd float %2209, %2208
  store float %2210, float* %2180, align 4
  %2211 = getelementptr inbounds i8, i8* %1166, i64 60
  %2212 = bitcast i8* %2211 to float*
  store float 0.000000e+00, float* %2212, align 4
  %2213 = getelementptr inbounds i8, i8* %1166, i64 60
  %2214 = bitcast i8* %2213 to float*
  %2215 = load float, float* %2110, align 4
  %2216 = getelementptr inbounds float, float* %2, i64 3
  %2217 = load float, float* %2216, align 4
  %2218 = fmul float %2215, %2217
  %2219 = load float, float* %2214, align 4
  %2220 = fadd float %2219, %2218
  store float %2220, float* %2214, align 4
  %2221 = getelementptr inbounds i8, i8* %1108, i64 52
  %2222 = bitcast i8* %2221 to float*
  %2223 = load float, float* %2222, align 4
  %2224 = getelementptr inbounds float, float* %2, i64 7
  %2225 = load float, float* %2224, align 4
  %2226 = fmul float %2223, %2225
  %2227 = load float, float* %2214, align 4
  %2228 = fadd float %2227, %2226
  store float %2228, float* %2214, align 4
  %2229 = getelementptr inbounds i8, i8* %1108, i64 56
  %2230 = bitcast i8* %2229 to float*
  %2231 = load float, float* %2230, align 4
  %2232 = getelementptr inbounds float, float* %2, i64 11
  %2233 = load float, float* %2232, align 4
  %2234 = fmul float %2231, %2233
  %2235 = load float, float* %2214, align 4
  %2236 = fadd float %2235, %2234
  store float %2236, float* %2214, align 4
  %2237 = getelementptr inbounds i8, i8* %1108, i64 60
  %2238 = bitcast i8* %2237 to float*
  %2239 = load float, float* %2238, align 4
  %2240 = getelementptr inbounds float, float* %2, i64 15
  %2241 = load float, float* %2240, align 4
  %2242 = fmul float %2239, %2241
  %2243 = load float, float* %2214, align 4
  %2244 = fadd float %2243, %2242
  store float %2244, float* %2214, align 4
  %2245 = call i8* @__memcpy_chk(i8* %43, i8* %1166, i64 64, i64 %45) #8
  call void @free(i8* %916)
  call void @free(i8* %918)
  call void @free(i8* %975)
  call void @free(i8* %977)
  call void @free(i8* %1036)
  call void @free(i8* %1108)
  %2246 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #9
  %2247 = bitcast i8* %2246 to float*
  %2248 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #9
  %2249 = bitcast i8* %2248 to float*
  %2250 = getelementptr inbounds float, float* %2, i64 10
  %2251 = bitcast float* %2250 to i32*
  %2252 = load i32, i32* %2251, align 4
  %2253 = bitcast i8* %2246 to i32*
  store i32 %2252, i32* %2253, align 4
  %2254 = getelementptr inbounds i8, i8* %8, i64 40
  %2255 = bitcast i8* %2254 to i32*
  %2256 = load i32, i32* %2255, align 4
  %2257 = bitcast i8* %2248 to i32*
  store i32 %2256, i32* %2257, align 4
  %2258 = getelementptr inbounds float, float* %2, i64 14
  %2259 = bitcast float* %2258 to i32*
  %2260 = load i32, i32* %2259, align 4
  %2261 = getelementptr inbounds i8, i8* %2246, i64 4
  %2262 = bitcast i8* %2261 to i32*
  store i32 %2260, i32* %2262, align 4
  %2263 = getelementptr inbounds i8, i8* %8, i64 56
  %2264 = bitcast i8* %2263 to i32*
  %2265 = load i32, i32* %2264, align 4
  %2266 = getelementptr inbounds i8, i8* %2248, i64 4
  %2267 = bitcast i8* %2266 to i32*
  store i32 %2265, i32* %2267, align 4
  %2268 = load float, float* %2247, align 4
  %2269 = fcmp ogt float %2268, 0.000000e+00
  %2270 = zext i1 %2269 to i32
  %2271 = fcmp olt float %2268, 0.000000e+00
  %.neg216 = sext i1 %2271 to i32
  %2272 = add nsw i32 %.neg216, %2270
  %2273 = sitofp i32 %2272 to float
  %2274 = load float, float* %2247, align 4
  %2275 = fpext float %2274 to double
  %square217 = fmul double %2275, %2275
  %2276 = fadd double %square217, 0.000000e+00
  %2277 = fptrunc double %2276 to float
  %2278 = getelementptr inbounds i8, i8* %2246, i64 4
  %2279 = bitcast i8* %2278 to float*
  %2280 = load float, float* %2279, align 4
  %2281 = fpext float %2280 to double
  %square218 = fmul double %2281, %2281
  %2282 = fpext float %2277 to double
  %2283 = fadd double %square218, %2282
  %2284 = fptrunc double %2283 to float
  %2285 = fneg float %2273
  %2286 = call float @llvm.sqrt.f32(float %2284)
  %2287 = fmul float %2286, %2285
  %2288 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #9
  %2289 = bitcast i8* %2288 to float*
  %2290 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #9
  %2291 = load float, float* %2247, align 4
  %2292 = load float, float* %2249, align 4
  %2293 = fmul float %2287, %2292
  %2294 = fadd float %2291, %2293
  store float %2294, float* %2289, align 4
  %2295 = getelementptr inbounds i8, i8* %2246, i64 4
  %2296 = bitcast i8* %2295 to float*
  %2297 = load float, float* %2296, align 4
  %2298 = getelementptr inbounds i8, i8* %2248, i64 4
  %2299 = bitcast i8* %2298 to float*
  %2300 = load float, float* %2299, align 4
  %2301 = fmul float %2287, %2300
  %2302 = fadd float %2297, %2301
  %2303 = getelementptr inbounds i8, i8* %2288, i64 4
  %2304 = bitcast i8* %2303 to float*
  store float %2302, float* %2304, align 4
  %2305 = load float, float* %2289, align 4
  %2306 = fpext float %2305 to double
  %square219 = fmul double %2306, %2306
  %2307 = fadd double %square219, 0.000000e+00
  %2308 = fptrunc double %2307 to float
  %2309 = getelementptr inbounds i8, i8* %2288, i64 4
  %2310 = bitcast i8* %2309 to float*
  %2311 = load float, float* %2310, align 4
  %2312 = fpext float %2311 to double
  %square220 = fmul double %2312, %2312
  %2313 = fpext float %2308 to double
  %2314 = fadd double %square220, %2313
  %2315 = fptrunc double %2314 to float
  %2316 = bitcast i8* %2290 to float*
  %2317 = call float @llvm.sqrt.f32(float %2315)
  %2318 = load float, float* %2289, align 4
  %2319 = fdiv float %2318, %2317
  store float %2319, float* %2316, align 4
  %2320 = getelementptr inbounds i8, i8* %2288, i64 4
  %2321 = bitcast i8* %2320 to float*
  %2322 = load float, float* %2321, align 4
  %2323 = fdiv float %2322, %2317
  %2324 = getelementptr inbounds i8, i8* %2290, i64 4
  %2325 = bitcast i8* %2324 to float*
  store float %2323, float* %2325, align 4
  %2326 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #9
  %2327 = bitcast i8* %2326 to float*
  %2328 = load float, float* %2316, align 4
  %2329 = fmul float %2328, 2.000000e+00
  %2330 = fmul float %2329, %2328
  %2331 = fsub float 1.000000e+00, %2330
  store float %2331, float* %2327, align 4
  %2332 = load float, float* %2316, align 4
  %2333 = fmul float %2332, 2.000000e+00
  %2334 = getelementptr inbounds i8, i8* %2290, i64 4
  %2335 = bitcast i8* %2334 to float*
  %2336 = load float, float* %2335, align 4
  %2337 = fmul float %2333, %2336
  %2338 = fsub float 0.000000e+00, %2337
  %2339 = getelementptr inbounds i8, i8* %2326, i64 4
  %2340 = bitcast i8* %2339 to float*
  store float %2338, float* %2340, align 4
  %2341 = getelementptr inbounds i8, i8* %2290, i64 4
  %2342 = bitcast i8* %2341 to float*
  %2343 = load float, float* %2342, align 4
  %2344 = fmul float %2343, 2.000000e+00
  %2345 = load float, float* %2316, align 4
  %2346 = fmul float %2344, %2345
  %2347 = fsub float 0.000000e+00, %2346
  %2348 = getelementptr inbounds i8, i8* %2326, i64 8
  %2349 = bitcast i8* %2348 to float*
  store float %2347, float* %2349, align 4
  %2350 = load float, float* %2342, align 4
  %2351 = fmul float %2350, 2.000000e+00
  %2352 = fmul float %2351, %2350
  %2353 = fsub float 1.000000e+00, %2352
  %2354 = getelementptr inbounds i8, i8* %2326, i64 12
  %2355 = bitcast i8* %2354 to float*
  store float %2353, float* %2355, align 4
  %2356 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #9
  %2357 = bitcast i8* %2356 to float*
  store float 1.000000e+00, float* %2357, align 4
  %2358 = getelementptr inbounds i8, i8* %2356, i64 4
  %2359 = bitcast i8* %2358 to float*
  store float 0.000000e+00, float* %2359, align 4
  %2360 = getelementptr inbounds i8, i8* %2356, i64 8
  %2361 = bitcast i8* %2360 to float*
  store float 0.000000e+00, float* %2361, align 4
  %2362 = getelementptr inbounds i8, i8* %2356, i64 12
  %2363 = bitcast i8* %2362 to float*
  store float 0.000000e+00, float* %2363, align 4
  %2364 = getelementptr inbounds i8, i8* %2356, i64 16
  %2365 = bitcast i8* %2364 to float*
  store float 0.000000e+00, float* %2365, align 4
  %2366 = getelementptr inbounds i8, i8* %2356, i64 20
  %2367 = bitcast i8* %2366 to float*
  store float 1.000000e+00, float* %2367, align 4
  %2368 = getelementptr inbounds i8, i8* %2356, i64 24
  %2369 = bitcast i8* %2368 to float*
  store float 0.000000e+00, float* %2369, align 4
  %2370 = getelementptr inbounds i8, i8* %2356, i64 28
  %2371 = bitcast i8* %2370 to float*
  store float 0.000000e+00, float* %2371, align 4
  %2372 = getelementptr inbounds i8, i8* %2356, i64 32
  %2373 = bitcast i8* %2372 to float*
  store float 0.000000e+00, float* %2373, align 4
  %2374 = getelementptr inbounds i8, i8* %2356, i64 36
  %2375 = bitcast i8* %2374 to float*
  store float 0.000000e+00, float* %2375, align 4
  %2376 = bitcast i8* %2326 to i32*
  %2377 = load i32, i32* %2376, align 4
  %2378 = getelementptr inbounds i8, i8* %2356, i64 40
  %2379 = bitcast i8* %2378 to i32*
  store i32 %2377, i32* %2379, align 4
  %2380 = getelementptr inbounds i8, i8* %2326, i64 4
  %2381 = bitcast i8* %2380 to i32*
  %2382 = load i32, i32* %2381, align 4
  %2383 = getelementptr inbounds i8, i8* %2356, i64 44
  %2384 = bitcast i8* %2383 to i32*
  store i32 %2382, i32* %2384, align 4
  %2385 = getelementptr inbounds i8, i8* %2356, i64 48
  %2386 = bitcast i8* %2385 to float*
  store float 0.000000e+00, float* %2386, align 4
  %2387 = getelementptr inbounds i8, i8* %2356, i64 52
  %2388 = bitcast i8* %2387 to float*
  store float 0.000000e+00, float* %2388, align 4
  %2389 = getelementptr inbounds i8, i8* %2326, i64 8
  %2390 = bitcast i8* %2389 to i32*
  %2391 = load i32, i32* %2390, align 4
  %2392 = getelementptr inbounds i8, i8* %2356, i64 56
  %2393 = bitcast i8* %2392 to i32*
  store i32 %2391, i32* %2393, align 4
  %2394 = getelementptr inbounds i8, i8* %2326, i64 12
  %2395 = bitcast i8* %2394 to i32*
  %2396 = load i32, i32* %2395, align 4
  %2397 = getelementptr inbounds i8, i8* %2356, i64 60
  %2398 = bitcast i8* %2397 to i32*
  store i32 %2396, i32* %2398, align 4
  %2399 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #9
  %2400 = bitcast i8* %2399 to float*
  store float 0.000000e+00, float* %2400, align 4
  %2401 = load float, float* %2357, align 4
  %2402 = load float, float* %1, align 4
  %2403 = fmul float %2401, %2402
  %2404 = fadd float %2403, 0.000000e+00
  store float %2404, float* %2400, align 4
  %2405 = getelementptr inbounds i8, i8* %2356, i64 4
  %2406 = bitcast i8* %2405 to float*
  %2407 = load float, float* %2406, align 4
  %2408 = getelementptr inbounds float, float* %1, i64 4
  %2409 = load float, float* %2408, align 4
  %2410 = fmul float %2407, %2409
  %2411 = load float, float* %2400, align 4
  %2412 = fadd float %2411, %2410
  store float %2412, float* %2400, align 4
  %2413 = getelementptr inbounds i8, i8* %2356, i64 8
  %2414 = bitcast i8* %2413 to float*
  %2415 = load float, float* %2414, align 4
  %2416 = getelementptr inbounds float, float* %1, i64 8
  %2417 = load float, float* %2416, align 4
  %2418 = fmul float %2415, %2417
  %2419 = load float, float* %2400, align 4
  %2420 = fadd float %2419, %2418
  store float %2420, float* %2400, align 4
  %2421 = getelementptr inbounds i8, i8* %2356, i64 12
  %2422 = bitcast i8* %2421 to float*
  %2423 = load float, float* %2422, align 4
  %2424 = getelementptr inbounds float, float* %1, i64 12
  %2425 = load float, float* %2424, align 4
  %2426 = fmul float %2423, %2425
  %2427 = load float, float* %2400, align 4
  %2428 = fadd float %2427, %2426
  store float %2428, float* %2400, align 4
  %2429 = getelementptr inbounds i8, i8* %2399, i64 4
  %2430 = bitcast i8* %2429 to float*
  store float 0.000000e+00, float* %2430, align 4
  %2431 = getelementptr inbounds i8, i8* %2399, i64 4
  %2432 = bitcast i8* %2431 to float*
  %2433 = load float, float* %2357, align 4
  %2434 = getelementptr inbounds float, float* %1, i64 1
  %2435 = load float, float* %2434, align 4
  %2436 = fmul float %2433, %2435
  %2437 = load float, float* %2432, align 4
  %2438 = fadd float %2437, %2436
  store float %2438, float* %2432, align 4
  %2439 = getelementptr inbounds i8, i8* %2356, i64 4
  %2440 = bitcast i8* %2439 to float*
  %2441 = load float, float* %2440, align 4
  %2442 = getelementptr inbounds float, float* %1, i64 5
  %2443 = load float, float* %2442, align 4
  %2444 = fmul float %2441, %2443
  %2445 = load float, float* %2432, align 4
  %2446 = fadd float %2445, %2444
  store float %2446, float* %2432, align 4
  %2447 = getelementptr inbounds i8, i8* %2356, i64 8
  %2448 = bitcast i8* %2447 to float*
  %2449 = load float, float* %2448, align 4
  %2450 = getelementptr inbounds float, float* %1, i64 9
  %2451 = load float, float* %2450, align 4
  %2452 = fmul float %2449, %2451
  %2453 = load float, float* %2432, align 4
  %2454 = fadd float %2453, %2452
  store float %2454, float* %2432, align 4
  %2455 = getelementptr inbounds i8, i8* %2356, i64 12
  %2456 = bitcast i8* %2455 to float*
  %2457 = load float, float* %2456, align 4
  %2458 = getelementptr inbounds float, float* %1, i64 13
  %2459 = load float, float* %2458, align 4
  %2460 = fmul float %2457, %2459
  %2461 = load float, float* %2432, align 4
  %2462 = fadd float %2461, %2460
  store float %2462, float* %2432, align 4
  %2463 = getelementptr inbounds i8, i8* %2399, i64 8
  %2464 = bitcast i8* %2463 to float*
  store float 0.000000e+00, float* %2464, align 4
  %2465 = getelementptr inbounds i8, i8* %2399, i64 8
  %2466 = bitcast i8* %2465 to float*
  %2467 = load float, float* %2357, align 4
  %2468 = getelementptr inbounds float, float* %1, i64 2
  %2469 = load float, float* %2468, align 4
  %2470 = fmul float %2467, %2469
  %2471 = load float, float* %2466, align 4
  %2472 = fadd float %2471, %2470
  store float %2472, float* %2466, align 4
  %2473 = getelementptr inbounds i8, i8* %2356, i64 4
  %2474 = bitcast i8* %2473 to float*
  %2475 = load float, float* %2474, align 4
  %2476 = getelementptr inbounds float, float* %1, i64 6
  %2477 = load float, float* %2476, align 4
  %2478 = fmul float %2475, %2477
  %2479 = load float, float* %2466, align 4
  %2480 = fadd float %2479, %2478
  store float %2480, float* %2466, align 4
  %2481 = getelementptr inbounds i8, i8* %2356, i64 8
  %2482 = bitcast i8* %2481 to float*
  %2483 = load float, float* %2482, align 4
  %2484 = getelementptr inbounds float, float* %1, i64 10
  %2485 = load float, float* %2484, align 4
  %2486 = fmul float %2483, %2485
  %2487 = load float, float* %2466, align 4
  %2488 = fadd float %2487, %2486
  store float %2488, float* %2466, align 4
  %2489 = getelementptr inbounds i8, i8* %2356, i64 12
  %2490 = bitcast i8* %2489 to float*
  %2491 = load float, float* %2490, align 4
  %2492 = getelementptr inbounds float, float* %1, i64 14
  %2493 = load float, float* %2492, align 4
  %2494 = fmul float %2491, %2493
  %2495 = load float, float* %2466, align 4
  %2496 = fadd float %2495, %2494
  store float %2496, float* %2466, align 4
  %2497 = getelementptr inbounds i8, i8* %2399, i64 12
  %2498 = bitcast i8* %2497 to float*
  store float 0.000000e+00, float* %2498, align 4
  %2499 = getelementptr inbounds i8, i8* %2399, i64 12
  %2500 = bitcast i8* %2499 to float*
  %2501 = load float, float* %2357, align 4
  %2502 = getelementptr inbounds float, float* %1, i64 3
  %2503 = load float, float* %2502, align 4
  %2504 = fmul float %2501, %2503
  %2505 = load float, float* %2500, align 4
  %2506 = fadd float %2505, %2504
  store float %2506, float* %2500, align 4
  %2507 = getelementptr inbounds i8, i8* %2356, i64 4
  %2508 = bitcast i8* %2507 to float*
  %2509 = load float, float* %2508, align 4
  %2510 = getelementptr inbounds float, float* %1, i64 7
  %2511 = load float, float* %2510, align 4
  %2512 = fmul float %2509, %2511
  %2513 = load float, float* %2500, align 4
  %2514 = fadd float %2513, %2512
  store float %2514, float* %2500, align 4
  %2515 = getelementptr inbounds i8, i8* %2356, i64 8
  %2516 = bitcast i8* %2515 to float*
  %2517 = load float, float* %2516, align 4
  %2518 = getelementptr inbounds float, float* %1, i64 11
  %2519 = load float, float* %2518, align 4
  %2520 = fmul float %2517, %2519
  %2521 = load float, float* %2500, align 4
  %2522 = fadd float %2521, %2520
  store float %2522, float* %2500, align 4
  %2523 = getelementptr inbounds i8, i8* %2356, i64 12
  %2524 = bitcast i8* %2523 to float*
  %2525 = load float, float* %2524, align 4
  %2526 = getelementptr inbounds float, float* %1, i64 15
  %2527 = load float, float* %2526, align 4
  %2528 = fmul float %2525, %2527
  %2529 = load float, float* %2500, align 4
  %2530 = fadd float %2529, %2528
  store float %2530, float* %2500, align 4
  %2531 = getelementptr inbounds i8, i8* %2356, i64 16
  %2532 = bitcast i8* %2531 to float*
  %2533 = getelementptr inbounds i8, i8* %2399, i64 16
  %2534 = bitcast i8* %2533 to float*
  store float 0.000000e+00, float* %2534, align 4
  %2535 = getelementptr inbounds i8, i8* %2399, i64 16
  %2536 = bitcast i8* %2535 to float*
  %2537 = load float, float* %2532, align 4
  %2538 = load float, float* %1, align 4
  %2539 = fmul float %2537, %2538
  %2540 = fadd float %2539, 0.000000e+00
  store float %2540, float* %2536, align 4
  %2541 = getelementptr inbounds i8, i8* %2356, i64 20
  %2542 = bitcast i8* %2541 to float*
  %2543 = load float, float* %2542, align 4
  %2544 = getelementptr inbounds float, float* %1, i64 4
  %2545 = load float, float* %2544, align 4
  %2546 = fmul float %2543, %2545
  %2547 = load float, float* %2536, align 4
  %2548 = fadd float %2547, %2546
  store float %2548, float* %2536, align 4
  %2549 = getelementptr inbounds i8, i8* %2356, i64 24
  %2550 = bitcast i8* %2549 to float*
  %2551 = load float, float* %2550, align 4
  %2552 = getelementptr inbounds float, float* %1, i64 8
  %2553 = load float, float* %2552, align 4
  %2554 = fmul float %2551, %2553
  %2555 = load float, float* %2536, align 4
  %2556 = fadd float %2555, %2554
  store float %2556, float* %2536, align 4
  %2557 = getelementptr inbounds i8, i8* %2356, i64 28
  %2558 = bitcast i8* %2557 to float*
  %2559 = load float, float* %2558, align 4
  %2560 = getelementptr inbounds float, float* %1, i64 12
  %2561 = load float, float* %2560, align 4
  %2562 = fmul float %2559, %2561
  %2563 = load float, float* %2536, align 4
  %2564 = fadd float %2563, %2562
  store float %2564, float* %2536, align 4
  %2565 = getelementptr inbounds i8, i8* %2399, i64 20
  %2566 = bitcast i8* %2565 to float*
  store float 0.000000e+00, float* %2566, align 4
  %2567 = getelementptr inbounds i8, i8* %2399, i64 20
  %2568 = bitcast i8* %2567 to float*
  %2569 = load float, float* %2532, align 4
  %2570 = getelementptr inbounds float, float* %1, i64 1
  %2571 = load float, float* %2570, align 4
  %2572 = fmul float %2569, %2571
  %2573 = load float, float* %2568, align 4
  %2574 = fadd float %2573, %2572
  store float %2574, float* %2568, align 4
  %2575 = getelementptr inbounds i8, i8* %2356, i64 20
  %2576 = bitcast i8* %2575 to float*
  %2577 = load float, float* %2576, align 4
  %2578 = getelementptr inbounds float, float* %1, i64 5
  %2579 = load float, float* %2578, align 4
  %2580 = fmul float %2577, %2579
  %2581 = load float, float* %2568, align 4
  %2582 = fadd float %2581, %2580
  store float %2582, float* %2568, align 4
  %2583 = getelementptr inbounds i8, i8* %2356, i64 24
  %2584 = bitcast i8* %2583 to float*
  %2585 = load float, float* %2584, align 4
  %2586 = getelementptr inbounds float, float* %1, i64 9
  %2587 = load float, float* %2586, align 4
  %2588 = fmul float %2585, %2587
  %2589 = load float, float* %2568, align 4
  %2590 = fadd float %2589, %2588
  store float %2590, float* %2568, align 4
  %2591 = getelementptr inbounds i8, i8* %2356, i64 28
  %2592 = bitcast i8* %2591 to float*
  %2593 = load float, float* %2592, align 4
  %2594 = getelementptr inbounds float, float* %1, i64 13
  %2595 = load float, float* %2594, align 4
  %2596 = fmul float %2593, %2595
  %2597 = load float, float* %2568, align 4
  %2598 = fadd float %2597, %2596
  store float %2598, float* %2568, align 4
  %2599 = getelementptr inbounds i8, i8* %2399, i64 24
  %2600 = bitcast i8* %2599 to float*
  store float 0.000000e+00, float* %2600, align 4
  %2601 = getelementptr inbounds i8, i8* %2399, i64 24
  %2602 = bitcast i8* %2601 to float*
  %2603 = load float, float* %2532, align 4
  %2604 = getelementptr inbounds float, float* %1, i64 2
  %2605 = load float, float* %2604, align 4
  %2606 = fmul float %2603, %2605
  %2607 = load float, float* %2602, align 4
  %2608 = fadd float %2607, %2606
  store float %2608, float* %2602, align 4
  %2609 = getelementptr inbounds i8, i8* %2356, i64 20
  %2610 = bitcast i8* %2609 to float*
  %2611 = load float, float* %2610, align 4
  %2612 = getelementptr inbounds float, float* %1, i64 6
  %2613 = load float, float* %2612, align 4
  %2614 = fmul float %2611, %2613
  %2615 = load float, float* %2602, align 4
  %2616 = fadd float %2615, %2614
  store float %2616, float* %2602, align 4
  %2617 = getelementptr inbounds i8, i8* %2356, i64 24
  %2618 = bitcast i8* %2617 to float*
  %2619 = load float, float* %2618, align 4
  %2620 = getelementptr inbounds float, float* %1, i64 10
  %2621 = load float, float* %2620, align 4
  %2622 = fmul float %2619, %2621
  %2623 = load float, float* %2602, align 4
  %2624 = fadd float %2623, %2622
  store float %2624, float* %2602, align 4
  %2625 = getelementptr inbounds i8, i8* %2356, i64 28
  %2626 = bitcast i8* %2625 to float*
  %2627 = load float, float* %2626, align 4
  %2628 = getelementptr inbounds float, float* %1, i64 14
  %2629 = load float, float* %2628, align 4
  %2630 = fmul float %2627, %2629
  %2631 = load float, float* %2602, align 4
  %2632 = fadd float %2631, %2630
  store float %2632, float* %2602, align 4
  %2633 = getelementptr inbounds i8, i8* %2399, i64 28
  %2634 = bitcast i8* %2633 to float*
  store float 0.000000e+00, float* %2634, align 4
  %2635 = getelementptr inbounds i8, i8* %2399, i64 28
  %2636 = bitcast i8* %2635 to float*
  %2637 = load float, float* %2532, align 4
  %2638 = getelementptr inbounds float, float* %1, i64 3
  %2639 = load float, float* %2638, align 4
  %2640 = fmul float %2637, %2639
  %2641 = load float, float* %2636, align 4
  %2642 = fadd float %2641, %2640
  store float %2642, float* %2636, align 4
  %2643 = getelementptr inbounds i8, i8* %2356, i64 20
  %2644 = bitcast i8* %2643 to float*
  %2645 = load float, float* %2644, align 4
  %2646 = getelementptr inbounds float, float* %1, i64 7
  %2647 = load float, float* %2646, align 4
  %2648 = fmul float %2645, %2647
  %2649 = load float, float* %2636, align 4
  %2650 = fadd float %2649, %2648
  store float %2650, float* %2636, align 4
  %2651 = getelementptr inbounds i8, i8* %2356, i64 24
  %2652 = bitcast i8* %2651 to float*
  %2653 = load float, float* %2652, align 4
  %2654 = getelementptr inbounds float, float* %1, i64 11
  %2655 = load float, float* %2654, align 4
  %2656 = fmul float %2653, %2655
  %2657 = load float, float* %2636, align 4
  %2658 = fadd float %2657, %2656
  store float %2658, float* %2636, align 4
  %2659 = getelementptr inbounds i8, i8* %2356, i64 28
  %2660 = bitcast i8* %2659 to float*
  %2661 = load float, float* %2660, align 4
  %2662 = getelementptr inbounds float, float* %1, i64 15
  %2663 = load float, float* %2662, align 4
  %2664 = fmul float %2661, %2663
  %2665 = load float, float* %2636, align 4
  %2666 = fadd float %2665, %2664
  store float %2666, float* %2636, align 4
  %2667 = getelementptr inbounds i8, i8* %2356, i64 32
  %2668 = bitcast i8* %2667 to float*
  %2669 = getelementptr inbounds i8, i8* %2399, i64 32
  %2670 = bitcast i8* %2669 to float*
  store float 0.000000e+00, float* %2670, align 4
  %2671 = getelementptr inbounds i8, i8* %2399, i64 32
  %2672 = bitcast i8* %2671 to float*
  %2673 = load float, float* %2668, align 4
  %2674 = load float, float* %1, align 4
  %2675 = fmul float %2673, %2674
  %2676 = fadd float %2675, 0.000000e+00
  store float %2676, float* %2672, align 4
  %2677 = getelementptr inbounds i8, i8* %2356, i64 36
  %2678 = bitcast i8* %2677 to float*
  %2679 = load float, float* %2678, align 4
  %2680 = getelementptr inbounds float, float* %1, i64 4
  %2681 = load float, float* %2680, align 4
  %2682 = fmul float %2679, %2681
  %2683 = load float, float* %2672, align 4
  %2684 = fadd float %2683, %2682
  store float %2684, float* %2672, align 4
  %2685 = getelementptr inbounds i8, i8* %2356, i64 40
  %2686 = bitcast i8* %2685 to float*
  %2687 = load float, float* %2686, align 4
  %2688 = getelementptr inbounds float, float* %1, i64 8
  %2689 = load float, float* %2688, align 4
  %2690 = fmul float %2687, %2689
  %2691 = load float, float* %2672, align 4
  %2692 = fadd float %2691, %2690
  store float %2692, float* %2672, align 4
  %2693 = getelementptr inbounds i8, i8* %2356, i64 44
  %2694 = bitcast i8* %2693 to float*
  %2695 = load float, float* %2694, align 4
  %2696 = getelementptr inbounds float, float* %1, i64 12
  %2697 = load float, float* %2696, align 4
  %2698 = fmul float %2695, %2697
  %2699 = load float, float* %2672, align 4
  %2700 = fadd float %2699, %2698
  store float %2700, float* %2672, align 4
  %2701 = getelementptr inbounds i8, i8* %2399, i64 36
  %2702 = bitcast i8* %2701 to float*
  store float 0.000000e+00, float* %2702, align 4
  %2703 = getelementptr inbounds i8, i8* %2399, i64 36
  %2704 = bitcast i8* %2703 to float*
  %2705 = load float, float* %2668, align 4
  %2706 = getelementptr inbounds float, float* %1, i64 1
  %2707 = load float, float* %2706, align 4
  %2708 = fmul float %2705, %2707
  %2709 = load float, float* %2704, align 4
  %2710 = fadd float %2709, %2708
  store float %2710, float* %2704, align 4
  %2711 = getelementptr inbounds i8, i8* %2356, i64 36
  %2712 = bitcast i8* %2711 to float*
  %2713 = load float, float* %2712, align 4
  %2714 = getelementptr inbounds float, float* %1, i64 5
  %2715 = load float, float* %2714, align 4
  %2716 = fmul float %2713, %2715
  %2717 = load float, float* %2704, align 4
  %2718 = fadd float %2717, %2716
  store float %2718, float* %2704, align 4
  %2719 = getelementptr inbounds i8, i8* %2356, i64 40
  %2720 = bitcast i8* %2719 to float*
  %2721 = load float, float* %2720, align 4
  %2722 = getelementptr inbounds float, float* %1, i64 9
  %2723 = load float, float* %2722, align 4
  %2724 = fmul float %2721, %2723
  %2725 = load float, float* %2704, align 4
  %2726 = fadd float %2725, %2724
  store float %2726, float* %2704, align 4
  %2727 = getelementptr inbounds i8, i8* %2356, i64 44
  %2728 = bitcast i8* %2727 to float*
  %2729 = load float, float* %2728, align 4
  %2730 = getelementptr inbounds float, float* %1, i64 13
  %2731 = load float, float* %2730, align 4
  %2732 = fmul float %2729, %2731
  %2733 = load float, float* %2704, align 4
  %2734 = fadd float %2733, %2732
  store float %2734, float* %2704, align 4
  %2735 = getelementptr inbounds i8, i8* %2399, i64 40
  %2736 = bitcast i8* %2735 to float*
  store float 0.000000e+00, float* %2736, align 4
  %2737 = getelementptr inbounds i8, i8* %2399, i64 40
  %2738 = bitcast i8* %2737 to float*
  %2739 = load float, float* %2668, align 4
  %2740 = getelementptr inbounds float, float* %1, i64 2
  %2741 = load float, float* %2740, align 4
  %2742 = fmul float %2739, %2741
  %2743 = load float, float* %2738, align 4
  %2744 = fadd float %2743, %2742
  store float %2744, float* %2738, align 4
  %2745 = getelementptr inbounds i8, i8* %2356, i64 36
  %2746 = bitcast i8* %2745 to float*
  %2747 = load float, float* %2746, align 4
  %2748 = getelementptr inbounds float, float* %1, i64 6
  %2749 = load float, float* %2748, align 4
  %2750 = fmul float %2747, %2749
  %2751 = load float, float* %2738, align 4
  %2752 = fadd float %2751, %2750
  store float %2752, float* %2738, align 4
  %2753 = getelementptr inbounds i8, i8* %2356, i64 40
  %2754 = bitcast i8* %2753 to float*
  %2755 = load float, float* %2754, align 4
  %2756 = getelementptr inbounds float, float* %1, i64 10
  %2757 = load float, float* %2756, align 4
  %2758 = fmul float %2755, %2757
  %2759 = load float, float* %2738, align 4
  %2760 = fadd float %2759, %2758
  store float %2760, float* %2738, align 4
  %2761 = getelementptr inbounds i8, i8* %2356, i64 44
  %2762 = bitcast i8* %2761 to float*
  %2763 = load float, float* %2762, align 4
  %2764 = getelementptr inbounds float, float* %1, i64 14
  %2765 = load float, float* %2764, align 4
  %2766 = fmul float %2763, %2765
  %2767 = load float, float* %2738, align 4
  %2768 = fadd float %2767, %2766
  store float %2768, float* %2738, align 4
  %2769 = getelementptr inbounds i8, i8* %2399, i64 44
  %2770 = bitcast i8* %2769 to float*
  store float 0.000000e+00, float* %2770, align 4
  %2771 = getelementptr inbounds i8, i8* %2399, i64 44
  %2772 = bitcast i8* %2771 to float*
  %2773 = load float, float* %2668, align 4
  %2774 = getelementptr inbounds float, float* %1, i64 3
  %2775 = load float, float* %2774, align 4
  %2776 = fmul float %2773, %2775
  %2777 = load float, float* %2772, align 4
  %2778 = fadd float %2777, %2776
  store float %2778, float* %2772, align 4
  %2779 = getelementptr inbounds i8, i8* %2356, i64 36
  %2780 = bitcast i8* %2779 to float*
  %2781 = load float, float* %2780, align 4
  %2782 = getelementptr inbounds float, float* %1, i64 7
  %2783 = load float, float* %2782, align 4
  %2784 = fmul float %2781, %2783
  %2785 = load float, float* %2772, align 4
  %2786 = fadd float %2785, %2784
  store float %2786, float* %2772, align 4
  %2787 = getelementptr inbounds i8, i8* %2356, i64 40
  %2788 = bitcast i8* %2787 to float*
  %2789 = load float, float* %2788, align 4
  %2790 = getelementptr inbounds float, float* %1, i64 11
  %2791 = load float, float* %2790, align 4
  %2792 = fmul float %2789, %2791
  %2793 = load float, float* %2772, align 4
  %2794 = fadd float %2793, %2792
  store float %2794, float* %2772, align 4
  %2795 = getelementptr inbounds i8, i8* %2356, i64 44
  %2796 = bitcast i8* %2795 to float*
  %2797 = load float, float* %2796, align 4
  %2798 = getelementptr inbounds float, float* %1, i64 15
  %2799 = load float, float* %2798, align 4
  %2800 = fmul float %2797, %2799
  %2801 = load float, float* %2772, align 4
  %2802 = fadd float %2801, %2800
  store float %2802, float* %2772, align 4
  %2803 = getelementptr inbounds i8, i8* %2356, i64 48
  %2804 = bitcast i8* %2803 to float*
  %2805 = getelementptr inbounds i8, i8* %2399, i64 48
  %2806 = bitcast i8* %2805 to float*
  store float 0.000000e+00, float* %2806, align 4
  %2807 = getelementptr inbounds i8, i8* %2399, i64 48
  %2808 = bitcast i8* %2807 to float*
  %2809 = load float, float* %2804, align 4
  %2810 = load float, float* %1, align 4
  %2811 = fmul float %2809, %2810
  %2812 = fadd float %2811, 0.000000e+00
  store float %2812, float* %2808, align 4
  %2813 = getelementptr inbounds i8, i8* %2356, i64 52
  %2814 = bitcast i8* %2813 to float*
  %2815 = load float, float* %2814, align 4
  %2816 = getelementptr inbounds float, float* %1, i64 4
  %2817 = load float, float* %2816, align 4
  %2818 = fmul float %2815, %2817
  %2819 = load float, float* %2808, align 4
  %2820 = fadd float %2819, %2818
  store float %2820, float* %2808, align 4
  %2821 = getelementptr inbounds i8, i8* %2356, i64 56
  %2822 = bitcast i8* %2821 to float*
  %2823 = load float, float* %2822, align 4
  %2824 = getelementptr inbounds float, float* %1, i64 8
  %2825 = load float, float* %2824, align 4
  %2826 = fmul float %2823, %2825
  %2827 = load float, float* %2808, align 4
  %2828 = fadd float %2827, %2826
  store float %2828, float* %2808, align 4
  %2829 = getelementptr inbounds i8, i8* %2356, i64 60
  %2830 = bitcast i8* %2829 to float*
  %2831 = load float, float* %2830, align 4
  %2832 = getelementptr inbounds float, float* %1, i64 12
  %2833 = load float, float* %2832, align 4
  %2834 = fmul float %2831, %2833
  %2835 = load float, float* %2808, align 4
  %2836 = fadd float %2835, %2834
  store float %2836, float* %2808, align 4
  %2837 = getelementptr inbounds i8, i8* %2399, i64 52
  %2838 = bitcast i8* %2837 to float*
  store float 0.000000e+00, float* %2838, align 4
  %2839 = getelementptr inbounds i8, i8* %2399, i64 52
  %2840 = bitcast i8* %2839 to float*
  %2841 = load float, float* %2804, align 4
  %2842 = getelementptr inbounds float, float* %1, i64 1
  %2843 = load float, float* %2842, align 4
  %2844 = fmul float %2841, %2843
  %2845 = load float, float* %2840, align 4
  %2846 = fadd float %2845, %2844
  store float %2846, float* %2840, align 4
  %2847 = getelementptr inbounds i8, i8* %2356, i64 52
  %2848 = bitcast i8* %2847 to float*
  %2849 = load float, float* %2848, align 4
  %2850 = getelementptr inbounds float, float* %1, i64 5
  %2851 = load float, float* %2850, align 4
  %2852 = fmul float %2849, %2851
  %2853 = load float, float* %2840, align 4
  %2854 = fadd float %2853, %2852
  store float %2854, float* %2840, align 4
  %2855 = getelementptr inbounds i8, i8* %2356, i64 56
  %2856 = bitcast i8* %2855 to float*
  %2857 = load float, float* %2856, align 4
  %2858 = getelementptr inbounds float, float* %1, i64 9
  %2859 = load float, float* %2858, align 4
  %2860 = fmul float %2857, %2859
  %2861 = load float, float* %2840, align 4
  %2862 = fadd float %2861, %2860
  store float %2862, float* %2840, align 4
  %2863 = getelementptr inbounds i8, i8* %2356, i64 60
  %2864 = bitcast i8* %2863 to float*
  %2865 = load float, float* %2864, align 4
  %2866 = getelementptr inbounds float, float* %1, i64 13
  %2867 = load float, float* %2866, align 4
  %2868 = fmul float %2865, %2867
  %2869 = load float, float* %2840, align 4
  %2870 = fadd float %2869, %2868
  store float %2870, float* %2840, align 4
  %2871 = getelementptr inbounds i8, i8* %2399, i64 56
  %2872 = bitcast i8* %2871 to float*
  store float 0.000000e+00, float* %2872, align 4
  %2873 = getelementptr inbounds i8, i8* %2399, i64 56
  %2874 = bitcast i8* %2873 to float*
  %2875 = load float, float* %2804, align 4
  %2876 = getelementptr inbounds float, float* %1, i64 2
  %2877 = load float, float* %2876, align 4
  %2878 = fmul float %2875, %2877
  %2879 = load float, float* %2874, align 4
  %2880 = fadd float %2879, %2878
  store float %2880, float* %2874, align 4
  %2881 = getelementptr inbounds i8, i8* %2356, i64 52
  %2882 = bitcast i8* %2881 to float*
  %2883 = load float, float* %2882, align 4
  %2884 = getelementptr inbounds float, float* %1, i64 6
  %2885 = load float, float* %2884, align 4
  %2886 = fmul float %2883, %2885
  %2887 = load float, float* %2874, align 4
  %2888 = fadd float %2887, %2886
  store float %2888, float* %2874, align 4
  %2889 = getelementptr inbounds i8, i8* %2356, i64 56
  %2890 = bitcast i8* %2889 to float*
  %2891 = load float, float* %2890, align 4
  %2892 = getelementptr inbounds float, float* %1, i64 10
  %2893 = load float, float* %2892, align 4
  %2894 = fmul float %2891, %2893
  %2895 = load float, float* %2874, align 4
  %2896 = fadd float %2895, %2894
  store float %2896, float* %2874, align 4
  %2897 = getelementptr inbounds i8, i8* %2356, i64 60
  %2898 = bitcast i8* %2897 to float*
  %2899 = load float, float* %2898, align 4
  %2900 = getelementptr inbounds float, float* %1, i64 14
  %2901 = load float, float* %2900, align 4
  %2902 = fmul float %2899, %2901
  %2903 = load float, float* %2874, align 4
  %2904 = fadd float %2903, %2902
  store float %2904, float* %2874, align 4
  %2905 = getelementptr inbounds i8, i8* %2399, i64 60
  %2906 = bitcast i8* %2905 to float*
  store float 0.000000e+00, float* %2906, align 4
  %2907 = getelementptr inbounds i8, i8* %2399, i64 60
  %2908 = bitcast i8* %2907 to float*
  %2909 = load float, float* %2804, align 4
  %2910 = getelementptr inbounds float, float* %1, i64 3
  %2911 = load float, float* %2910, align 4
  %2912 = fmul float %2909, %2911
  %2913 = load float, float* %2908, align 4
  %2914 = fadd float %2913, %2912
  store float %2914, float* %2908, align 4
  %2915 = getelementptr inbounds i8, i8* %2356, i64 52
  %2916 = bitcast i8* %2915 to float*
  %2917 = load float, float* %2916, align 4
  %2918 = getelementptr inbounds float, float* %1, i64 7
  %2919 = load float, float* %2918, align 4
  %2920 = fmul float %2917, %2919
  %2921 = load float, float* %2908, align 4
  %2922 = fadd float %2921, %2920
  store float %2922, float* %2908, align 4
  %2923 = getelementptr inbounds i8, i8* %2356, i64 56
  %2924 = bitcast i8* %2923 to float*
  %2925 = load float, float* %2924, align 4
  %2926 = getelementptr inbounds float, float* %1, i64 11
  %2927 = load float, float* %2926, align 4
  %2928 = fmul float %2925, %2927
  %2929 = load float, float* %2908, align 4
  %2930 = fadd float %2929, %2928
  store float %2930, float* %2908, align 4
  %2931 = getelementptr inbounds i8, i8* %2356, i64 60
  %2932 = bitcast i8* %2931 to float*
  %2933 = load float, float* %2932, align 4
  %2934 = getelementptr inbounds float, float* %1, i64 15
  %2935 = load float, float* %2934, align 4
  %2936 = fmul float %2933, %2935
  %2937 = load float, float* %2908, align 4
  %2938 = fadd float %2937, %2936
  store float %2938, float* %2908, align 4
  %2939 = call i8* @__memcpy_chk(i8* nonnull %40, i8* %2399, i64 64, i64 %42) #8
  store float 0.000000e+00, float* %2400, align 4
  %2940 = load float, float* %2357, align 4
  %2941 = load float, float* %2, align 4
  %2942 = fmul float %2940, %2941
  %2943 = fadd float %2942, 0.000000e+00
  store float %2943, float* %2400, align 4
  %2944 = getelementptr inbounds i8, i8* %2356, i64 4
  %2945 = bitcast i8* %2944 to float*
  %2946 = load float, float* %2945, align 4
  %2947 = getelementptr inbounds float, float* %2, i64 4
  %2948 = load float, float* %2947, align 4
  %2949 = fmul float %2946, %2948
  %2950 = load float, float* %2400, align 4
  %2951 = fadd float %2950, %2949
  store float %2951, float* %2400, align 4
  %2952 = getelementptr inbounds i8, i8* %2356, i64 8
  %2953 = bitcast i8* %2952 to float*
  %2954 = load float, float* %2953, align 4
  %2955 = getelementptr inbounds float, float* %2, i64 8
  %2956 = load float, float* %2955, align 4
  %2957 = fmul float %2954, %2956
  %2958 = load float, float* %2400, align 4
  %2959 = fadd float %2958, %2957
  store float %2959, float* %2400, align 4
  %2960 = getelementptr inbounds i8, i8* %2356, i64 12
  %2961 = bitcast i8* %2960 to float*
  %2962 = load float, float* %2961, align 4
  %2963 = getelementptr inbounds float, float* %2, i64 12
  %2964 = load float, float* %2963, align 4
  %2965 = fmul float %2962, %2964
  %2966 = load float, float* %2400, align 4
  %2967 = fadd float %2966, %2965
  store float %2967, float* %2400, align 4
  %2968 = getelementptr inbounds i8, i8* %2399, i64 4
  %2969 = bitcast i8* %2968 to float*
  store float 0.000000e+00, float* %2969, align 4
  %2970 = getelementptr inbounds i8, i8* %2399, i64 4
  %2971 = bitcast i8* %2970 to float*
  %2972 = load float, float* %2357, align 4
  %2973 = getelementptr inbounds float, float* %2, i64 1
  %2974 = load float, float* %2973, align 4
  %2975 = fmul float %2972, %2974
  %2976 = load float, float* %2971, align 4
  %2977 = fadd float %2976, %2975
  store float %2977, float* %2971, align 4
  %2978 = getelementptr inbounds i8, i8* %2356, i64 4
  %2979 = bitcast i8* %2978 to float*
  %2980 = load float, float* %2979, align 4
  %2981 = getelementptr inbounds float, float* %2, i64 5
  %2982 = load float, float* %2981, align 4
  %2983 = fmul float %2980, %2982
  %2984 = load float, float* %2971, align 4
  %2985 = fadd float %2984, %2983
  store float %2985, float* %2971, align 4
  %2986 = getelementptr inbounds i8, i8* %2356, i64 8
  %2987 = bitcast i8* %2986 to float*
  %2988 = load float, float* %2987, align 4
  %2989 = getelementptr inbounds float, float* %2, i64 9
  %2990 = load float, float* %2989, align 4
  %2991 = fmul float %2988, %2990
  %2992 = load float, float* %2971, align 4
  %2993 = fadd float %2992, %2991
  store float %2993, float* %2971, align 4
  %2994 = getelementptr inbounds i8, i8* %2356, i64 12
  %2995 = bitcast i8* %2994 to float*
  %2996 = load float, float* %2995, align 4
  %2997 = getelementptr inbounds float, float* %2, i64 13
  %2998 = load float, float* %2997, align 4
  %2999 = fmul float %2996, %2998
  %3000 = load float, float* %2971, align 4
  %3001 = fadd float %3000, %2999
  store float %3001, float* %2971, align 4
  %3002 = getelementptr inbounds i8, i8* %2399, i64 8
  %3003 = bitcast i8* %3002 to float*
  store float 0.000000e+00, float* %3003, align 4
  %3004 = getelementptr inbounds i8, i8* %2399, i64 8
  %3005 = bitcast i8* %3004 to float*
  %3006 = load float, float* %2357, align 4
  %3007 = getelementptr inbounds float, float* %2, i64 2
  %3008 = load float, float* %3007, align 4
  %3009 = fmul float %3006, %3008
  %3010 = load float, float* %3005, align 4
  %3011 = fadd float %3010, %3009
  store float %3011, float* %3005, align 4
  %3012 = getelementptr inbounds i8, i8* %2356, i64 4
  %3013 = bitcast i8* %3012 to float*
  %3014 = load float, float* %3013, align 4
  %3015 = getelementptr inbounds float, float* %2, i64 6
  %3016 = load float, float* %3015, align 4
  %3017 = fmul float %3014, %3016
  %3018 = load float, float* %3005, align 4
  %3019 = fadd float %3018, %3017
  store float %3019, float* %3005, align 4
  %3020 = getelementptr inbounds i8, i8* %2356, i64 8
  %3021 = bitcast i8* %3020 to float*
  %3022 = load float, float* %3021, align 4
  %3023 = getelementptr inbounds float, float* %2, i64 10
  %3024 = load float, float* %3023, align 4
  %3025 = fmul float %3022, %3024
  %3026 = load float, float* %3005, align 4
  %3027 = fadd float %3026, %3025
  store float %3027, float* %3005, align 4
  %3028 = getelementptr inbounds i8, i8* %2356, i64 12
  %3029 = bitcast i8* %3028 to float*
  %3030 = load float, float* %3029, align 4
  %3031 = getelementptr inbounds float, float* %2, i64 14
  %3032 = load float, float* %3031, align 4
  %3033 = fmul float %3030, %3032
  %3034 = load float, float* %3005, align 4
  %3035 = fadd float %3034, %3033
  store float %3035, float* %3005, align 4
  %3036 = getelementptr inbounds i8, i8* %2399, i64 12
  %3037 = bitcast i8* %3036 to float*
  store float 0.000000e+00, float* %3037, align 4
  %3038 = getelementptr inbounds i8, i8* %2399, i64 12
  %3039 = bitcast i8* %3038 to float*
  %3040 = load float, float* %2357, align 4
  %3041 = getelementptr inbounds float, float* %2, i64 3
  %3042 = load float, float* %3041, align 4
  %3043 = fmul float %3040, %3042
  %3044 = load float, float* %3039, align 4
  %3045 = fadd float %3044, %3043
  store float %3045, float* %3039, align 4
  %3046 = getelementptr inbounds i8, i8* %2356, i64 4
  %3047 = bitcast i8* %3046 to float*
  %3048 = load float, float* %3047, align 4
  %3049 = getelementptr inbounds float, float* %2, i64 7
  %3050 = load float, float* %3049, align 4
  %3051 = fmul float %3048, %3050
  %3052 = load float, float* %3039, align 4
  %3053 = fadd float %3052, %3051
  store float %3053, float* %3039, align 4
  %3054 = getelementptr inbounds i8, i8* %2356, i64 8
  %3055 = bitcast i8* %3054 to float*
  %3056 = load float, float* %3055, align 4
  %3057 = getelementptr inbounds float, float* %2, i64 11
  %3058 = load float, float* %3057, align 4
  %3059 = fmul float %3056, %3058
  %3060 = load float, float* %3039, align 4
  %3061 = fadd float %3060, %3059
  store float %3061, float* %3039, align 4
  %3062 = getelementptr inbounds i8, i8* %2356, i64 12
  %3063 = bitcast i8* %3062 to float*
  %3064 = load float, float* %3063, align 4
  %3065 = getelementptr inbounds float, float* %2, i64 15
  %3066 = load float, float* %3065, align 4
  %3067 = fmul float %3064, %3066
  %3068 = load float, float* %3039, align 4
  %3069 = fadd float %3068, %3067
  store float %3069, float* %3039, align 4
  %3070 = getelementptr inbounds i8, i8* %2356, i64 16
  %3071 = bitcast i8* %3070 to float*
  %3072 = getelementptr inbounds i8, i8* %2399, i64 16
  %3073 = bitcast i8* %3072 to float*
  store float 0.000000e+00, float* %3073, align 4
  %3074 = getelementptr inbounds i8, i8* %2399, i64 16
  %3075 = bitcast i8* %3074 to float*
  %3076 = load float, float* %3071, align 4
  %3077 = load float, float* %2, align 4
  %3078 = fmul float %3076, %3077
  %3079 = fadd float %3078, 0.000000e+00
  store float %3079, float* %3075, align 4
  %3080 = getelementptr inbounds i8, i8* %2356, i64 20
  %3081 = bitcast i8* %3080 to float*
  %3082 = load float, float* %3081, align 4
  %3083 = getelementptr inbounds float, float* %2, i64 4
  %3084 = load float, float* %3083, align 4
  %3085 = fmul float %3082, %3084
  %3086 = load float, float* %3075, align 4
  %3087 = fadd float %3086, %3085
  store float %3087, float* %3075, align 4
  %3088 = getelementptr inbounds i8, i8* %2356, i64 24
  %3089 = bitcast i8* %3088 to float*
  %3090 = load float, float* %3089, align 4
  %3091 = getelementptr inbounds float, float* %2, i64 8
  %3092 = load float, float* %3091, align 4
  %3093 = fmul float %3090, %3092
  %3094 = load float, float* %3075, align 4
  %3095 = fadd float %3094, %3093
  store float %3095, float* %3075, align 4
  %3096 = getelementptr inbounds i8, i8* %2356, i64 28
  %3097 = bitcast i8* %3096 to float*
  %3098 = load float, float* %3097, align 4
  %3099 = getelementptr inbounds float, float* %2, i64 12
  %3100 = load float, float* %3099, align 4
  %3101 = fmul float %3098, %3100
  %3102 = load float, float* %3075, align 4
  %3103 = fadd float %3102, %3101
  store float %3103, float* %3075, align 4
  %3104 = getelementptr inbounds i8, i8* %2399, i64 20
  %3105 = bitcast i8* %3104 to float*
  store float 0.000000e+00, float* %3105, align 4
  %3106 = getelementptr inbounds i8, i8* %2399, i64 20
  %3107 = bitcast i8* %3106 to float*
  %3108 = load float, float* %3071, align 4
  %3109 = getelementptr inbounds float, float* %2, i64 1
  %3110 = load float, float* %3109, align 4
  %3111 = fmul float %3108, %3110
  %3112 = load float, float* %3107, align 4
  %3113 = fadd float %3112, %3111
  store float %3113, float* %3107, align 4
  %3114 = getelementptr inbounds i8, i8* %2356, i64 20
  %3115 = bitcast i8* %3114 to float*
  %3116 = load float, float* %3115, align 4
  %3117 = getelementptr inbounds float, float* %2, i64 5
  %3118 = load float, float* %3117, align 4
  %3119 = fmul float %3116, %3118
  %3120 = load float, float* %3107, align 4
  %3121 = fadd float %3120, %3119
  store float %3121, float* %3107, align 4
  %3122 = getelementptr inbounds i8, i8* %2356, i64 24
  %3123 = bitcast i8* %3122 to float*
  %3124 = load float, float* %3123, align 4
  %3125 = getelementptr inbounds float, float* %2, i64 9
  %3126 = load float, float* %3125, align 4
  %3127 = fmul float %3124, %3126
  %3128 = load float, float* %3107, align 4
  %3129 = fadd float %3128, %3127
  store float %3129, float* %3107, align 4
  %3130 = getelementptr inbounds i8, i8* %2356, i64 28
  %3131 = bitcast i8* %3130 to float*
  %3132 = load float, float* %3131, align 4
  %3133 = getelementptr inbounds float, float* %2, i64 13
  %3134 = load float, float* %3133, align 4
  %3135 = fmul float %3132, %3134
  %3136 = load float, float* %3107, align 4
  %3137 = fadd float %3136, %3135
  store float %3137, float* %3107, align 4
  %3138 = getelementptr inbounds i8, i8* %2399, i64 24
  %3139 = bitcast i8* %3138 to float*
  store float 0.000000e+00, float* %3139, align 4
  %3140 = getelementptr inbounds i8, i8* %2399, i64 24
  %3141 = bitcast i8* %3140 to float*
  %3142 = load float, float* %3071, align 4
  %3143 = getelementptr inbounds float, float* %2, i64 2
  %3144 = load float, float* %3143, align 4
  %3145 = fmul float %3142, %3144
  %3146 = load float, float* %3141, align 4
  %3147 = fadd float %3146, %3145
  store float %3147, float* %3141, align 4
  %3148 = getelementptr inbounds i8, i8* %2356, i64 20
  %3149 = bitcast i8* %3148 to float*
  %3150 = load float, float* %3149, align 4
  %3151 = getelementptr inbounds float, float* %2, i64 6
  %3152 = load float, float* %3151, align 4
  %3153 = fmul float %3150, %3152
  %3154 = load float, float* %3141, align 4
  %3155 = fadd float %3154, %3153
  store float %3155, float* %3141, align 4
  %3156 = getelementptr inbounds i8, i8* %2356, i64 24
  %3157 = bitcast i8* %3156 to float*
  %3158 = load float, float* %3157, align 4
  %3159 = getelementptr inbounds float, float* %2, i64 10
  %3160 = load float, float* %3159, align 4
  %3161 = fmul float %3158, %3160
  %3162 = load float, float* %3141, align 4
  %3163 = fadd float %3162, %3161
  store float %3163, float* %3141, align 4
  %3164 = getelementptr inbounds i8, i8* %2356, i64 28
  %3165 = bitcast i8* %3164 to float*
  %3166 = load float, float* %3165, align 4
  %3167 = getelementptr inbounds float, float* %2, i64 14
  %3168 = load float, float* %3167, align 4
  %3169 = fmul float %3166, %3168
  %3170 = load float, float* %3141, align 4
  %3171 = fadd float %3170, %3169
  store float %3171, float* %3141, align 4
  %3172 = getelementptr inbounds i8, i8* %2399, i64 28
  %3173 = bitcast i8* %3172 to float*
  store float 0.000000e+00, float* %3173, align 4
  %3174 = getelementptr inbounds i8, i8* %2399, i64 28
  %3175 = bitcast i8* %3174 to float*
  %3176 = load float, float* %3071, align 4
  %3177 = getelementptr inbounds float, float* %2, i64 3
  %3178 = load float, float* %3177, align 4
  %3179 = fmul float %3176, %3178
  %3180 = load float, float* %3175, align 4
  %3181 = fadd float %3180, %3179
  store float %3181, float* %3175, align 4
  %3182 = getelementptr inbounds i8, i8* %2356, i64 20
  %3183 = bitcast i8* %3182 to float*
  %3184 = load float, float* %3183, align 4
  %3185 = getelementptr inbounds float, float* %2, i64 7
  %3186 = load float, float* %3185, align 4
  %3187 = fmul float %3184, %3186
  %3188 = load float, float* %3175, align 4
  %3189 = fadd float %3188, %3187
  store float %3189, float* %3175, align 4
  %3190 = getelementptr inbounds i8, i8* %2356, i64 24
  %3191 = bitcast i8* %3190 to float*
  %3192 = load float, float* %3191, align 4
  %3193 = getelementptr inbounds float, float* %2, i64 11
  %3194 = load float, float* %3193, align 4
  %3195 = fmul float %3192, %3194
  %3196 = load float, float* %3175, align 4
  %3197 = fadd float %3196, %3195
  store float %3197, float* %3175, align 4
  %3198 = getelementptr inbounds i8, i8* %2356, i64 28
  %3199 = bitcast i8* %3198 to float*
  %3200 = load float, float* %3199, align 4
  %3201 = getelementptr inbounds float, float* %2, i64 15
  %3202 = load float, float* %3201, align 4
  %3203 = fmul float %3200, %3202
  %3204 = load float, float* %3175, align 4
  %3205 = fadd float %3204, %3203
  store float %3205, float* %3175, align 4
  %3206 = getelementptr inbounds i8, i8* %2356, i64 32
  %3207 = bitcast i8* %3206 to float*
  %3208 = getelementptr inbounds i8, i8* %2399, i64 32
  %3209 = bitcast i8* %3208 to float*
  store float 0.000000e+00, float* %3209, align 4
  %3210 = getelementptr inbounds i8, i8* %2399, i64 32
  %3211 = bitcast i8* %3210 to float*
  %3212 = load float, float* %3207, align 4
  %3213 = load float, float* %2, align 4
  %3214 = fmul float %3212, %3213
  %3215 = fadd float %3214, 0.000000e+00
  store float %3215, float* %3211, align 4
  %3216 = getelementptr inbounds i8, i8* %2356, i64 36
  %3217 = bitcast i8* %3216 to float*
  %3218 = load float, float* %3217, align 4
  %3219 = getelementptr inbounds float, float* %2, i64 4
  %3220 = load float, float* %3219, align 4
  %3221 = fmul float %3218, %3220
  %3222 = load float, float* %3211, align 4
  %3223 = fadd float %3222, %3221
  store float %3223, float* %3211, align 4
  %3224 = getelementptr inbounds i8, i8* %2356, i64 40
  %3225 = bitcast i8* %3224 to float*
  %3226 = load float, float* %3225, align 4
  %3227 = getelementptr inbounds float, float* %2, i64 8
  %3228 = load float, float* %3227, align 4
  %3229 = fmul float %3226, %3228
  %3230 = load float, float* %3211, align 4
  %3231 = fadd float %3230, %3229
  store float %3231, float* %3211, align 4
  %3232 = getelementptr inbounds i8, i8* %2356, i64 44
  %3233 = bitcast i8* %3232 to float*
  %3234 = load float, float* %3233, align 4
  %3235 = getelementptr inbounds float, float* %2, i64 12
  %3236 = load float, float* %3235, align 4
  %3237 = fmul float %3234, %3236
  %3238 = load float, float* %3211, align 4
  %3239 = fadd float %3238, %3237
  store float %3239, float* %3211, align 4
  %3240 = getelementptr inbounds i8, i8* %2399, i64 36
  %3241 = bitcast i8* %3240 to float*
  store float 0.000000e+00, float* %3241, align 4
  %3242 = getelementptr inbounds i8, i8* %2399, i64 36
  %3243 = bitcast i8* %3242 to float*
  %3244 = load float, float* %3207, align 4
  %3245 = getelementptr inbounds float, float* %2, i64 1
  %3246 = load float, float* %3245, align 4
  %3247 = fmul float %3244, %3246
  %3248 = load float, float* %3243, align 4
  %3249 = fadd float %3248, %3247
  store float %3249, float* %3243, align 4
  %3250 = getelementptr inbounds i8, i8* %2356, i64 36
  %3251 = bitcast i8* %3250 to float*
  %3252 = load float, float* %3251, align 4
  %3253 = getelementptr inbounds float, float* %2, i64 5
  %3254 = load float, float* %3253, align 4
  %3255 = fmul float %3252, %3254
  %3256 = load float, float* %3243, align 4
  %3257 = fadd float %3256, %3255
  store float %3257, float* %3243, align 4
  %3258 = getelementptr inbounds i8, i8* %2356, i64 40
  %3259 = bitcast i8* %3258 to float*
  %3260 = load float, float* %3259, align 4
  %3261 = getelementptr inbounds float, float* %2, i64 9
  %3262 = load float, float* %3261, align 4
  %3263 = fmul float %3260, %3262
  %3264 = load float, float* %3243, align 4
  %3265 = fadd float %3264, %3263
  store float %3265, float* %3243, align 4
  %3266 = getelementptr inbounds i8, i8* %2356, i64 44
  %3267 = bitcast i8* %3266 to float*
  %3268 = load float, float* %3267, align 4
  %3269 = getelementptr inbounds float, float* %2, i64 13
  %3270 = load float, float* %3269, align 4
  %3271 = fmul float %3268, %3270
  %3272 = load float, float* %3243, align 4
  %3273 = fadd float %3272, %3271
  store float %3273, float* %3243, align 4
  %3274 = getelementptr inbounds i8, i8* %2399, i64 40
  %3275 = bitcast i8* %3274 to float*
  store float 0.000000e+00, float* %3275, align 4
  %3276 = getelementptr inbounds i8, i8* %2399, i64 40
  %3277 = bitcast i8* %3276 to float*
  %3278 = load float, float* %3207, align 4
  %3279 = getelementptr inbounds float, float* %2, i64 2
  %3280 = load float, float* %3279, align 4
  %3281 = fmul float %3278, %3280
  %3282 = load float, float* %3277, align 4
  %3283 = fadd float %3282, %3281
  store float %3283, float* %3277, align 4
  %3284 = getelementptr inbounds i8, i8* %2356, i64 36
  %3285 = bitcast i8* %3284 to float*
  %3286 = load float, float* %3285, align 4
  %3287 = getelementptr inbounds float, float* %2, i64 6
  %3288 = load float, float* %3287, align 4
  %3289 = fmul float %3286, %3288
  %3290 = load float, float* %3277, align 4
  %3291 = fadd float %3290, %3289
  store float %3291, float* %3277, align 4
  %3292 = getelementptr inbounds i8, i8* %2356, i64 40
  %3293 = bitcast i8* %3292 to float*
  %3294 = load float, float* %3293, align 4
  %3295 = getelementptr inbounds float, float* %2, i64 10
  %3296 = load float, float* %3295, align 4
  %3297 = fmul float %3294, %3296
  %3298 = load float, float* %3277, align 4
  %3299 = fadd float %3298, %3297
  store float %3299, float* %3277, align 4
  %3300 = getelementptr inbounds i8, i8* %2356, i64 44
  %3301 = bitcast i8* %3300 to float*
  %3302 = load float, float* %3301, align 4
  %3303 = getelementptr inbounds float, float* %2, i64 14
  %3304 = load float, float* %3303, align 4
  %3305 = fmul float %3302, %3304
  %3306 = load float, float* %3277, align 4
  %3307 = fadd float %3306, %3305
  store float %3307, float* %3277, align 4
  %3308 = getelementptr inbounds i8, i8* %2399, i64 44
  %3309 = bitcast i8* %3308 to float*
  store float 0.000000e+00, float* %3309, align 4
  %3310 = getelementptr inbounds i8, i8* %2399, i64 44
  %3311 = bitcast i8* %3310 to float*
  %3312 = load float, float* %3207, align 4
  %3313 = getelementptr inbounds float, float* %2, i64 3
  %3314 = load float, float* %3313, align 4
  %3315 = fmul float %3312, %3314
  %3316 = load float, float* %3311, align 4
  %3317 = fadd float %3316, %3315
  store float %3317, float* %3311, align 4
  %3318 = getelementptr inbounds i8, i8* %2356, i64 36
  %3319 = bitcast i8* %3318 to float*
  %3320 = load float, float* %3319, align 4
  %3321 = getelementptr inbounds float, float* %2, i64 7
  %3322 = load float, float* %3321, align 4
  %3323 = fmul float %3320, %3322
  %3324 = load float, float* %3311, align 4
  %3325 = fadd float %3324, %3323
  store float %3325, float* %3311, align 4
  %3326 = getelementptr inbounds i8, i8* %2356, i64 40
  %3327 = bitcast i8* %3326 to float*
  %3328 = load float, float* %3327, align 4
  %3329 = getelementptr inbounds float, float* %2, i64 11
  %3330 = load float, float* %3329, align 4
  %3331 = fmul float %3328, %3330
  %3332 = load float, float* %3311, align 4
  %3333 = fadd float %3332, %3331
  store float %3333, float* %3311, align 4
  %3334 = getelementptr inbounds i8, i8* %2356, i64 44
  %3335 = bitcast i8* %3334 to float*
  %3336 = load float, float* %3335, align 4
  %3337 = getelementptr inbounds float, float* %2, i64 15
  %3338 = load float, float* %3337, align 4
  %3339 = fmul float %3336, %3338
  %3340 = load float, float* %3311, align 4
  %3341 = fadd float %3340, %3339
  store float %3341, float* %3311, align 4
  %3342 = getelementptr inbounds i8, i8* %2356, i64 48
  %3343 = bitcast i8* %3342 to float*
  %3344 = getelementptr inbounds i8, i8* %2399, i64 48
  %3345 = bitcast i8* %3344 to float*
  store float 0.000000e+00, float* %3345, align 4
  %3346 = getelementptr inbounds i8, i8* %2399, i64 48
  %3347 = bitcast i8* %3346 to float*
  %3348 = load float, float* %3343, align 4
  %3349 = load float, float* %2, align 4
  %3350 = fmul float %3348, %3349
  %3351 = fadd float %3350, 0.000000e+00
  store float %3351, float* %3347, align 4
  %3352 = getelementptr inbounds i8, i8* %2356, i64 52
  %3353 = bitcast i8* %3352 to float*
  %3354 = load float, float* %3353, align 4
  %3355 = getelementptr inbounds float, float* %2, i64 4
  %3356 = load float, float* %3355, align 4
  %3357 = fmul float %3354, %3356
  %3358 = load float, float* %3347, align 4
  %3359 = fadd float %3358, %3357
  store float %3359, float* %3347, align 4
  %3360 = getelementptr inbounds i8, i8* %2356, i64 56
  %3361 = bitcast i8* %3360 to float*
  %3362 = load float, float* %3361, align 4
  %3363 = getelementptr inbounds float, float* %2, i64 8
  %3364 = load float, float* %3363, align 4
  %3365 = fmul float %3362, %3364
  %3366 = load float, float* %3347, align 4
  %3367 = fadd float %3366, %3365
  store float %3367, float* %3347, align 4
  %3368 = getelementptr inbounds i8, i8* %2356, i64 60
  %3369 = bitcast i8* %3368 to float*
  %3370 = load float, float* %3369, align 4
  %3371 = getelementptr inbounds float, float* %2, i64 12
  %3372 = load float, float* %3371, align 4
  %3373 = fmul float %3370, %3372
  %3374 = load float, float* %3347, align 4
  %3375 = fadd float %3374, %3373
  store float %3375, float* %3347, align 4
  %3376 = getelementptr inbounds i8, i8* %2399, i64 52
  %3377 = bitcast i8* %3376 to float*
  store float 0.000000e+00, float* %3377, align 4
  %3378 = getelementptr inbounds i8, i8* %2399, i64 52
  %3379 = bitcast i8* %3378 to float*
  %3380 = load float, float* %3343, align 4
  %3381 = getelementptr inbounds float, float* %2, i64 1
  %3382 = load float, float* %3381, align 4
  %3383 = fmul float %3380, %3382
  %3384 = load float, float* %3379, align 4
  %3385 = fadd float %3384, %3383
  store float %3385, float* %3379, align 4
  %3386 = getelementptr inbounds i8, i8* %2356, i64 52
  %3387 = bitcast i8* %3386 to float*
  %3388 = load float, float* %3387, align 4
  %3389 = getelementptr inbounds float, float* %2, i64 5
  %3390 = load float, float* %3389, align 4
  %3391 = fmul float %3388, %3390
  %3392 = load float, float* %3379, align 4
  %3393 = fadd float %3392, %3391
  store float %3393, float* %3379, align 4
  %3394 = getelementptr inbounds i8, i8* %2356, i64 56
  %3395 = bitcast i8* %3394 to float*
  %3396 = load float, float* %3395, align 4
  %3397 = getelementptr inbounds float, float* %2, i64 9
  %3398 = load float, float* %3397, align 4
  %3399 = fmul float %3396, %3398
  %3400 = load float, float* %3379, align 4
  %3401 = fadd float %3400, %3399
  store float %3401, float* %3379, align 4
  %3402 = getelementptr inbounds i8, i8* %2356, i64 60
  %3403 = bitcast i8* %3402 to float*
  %3404 = load float, float* %3403, align 4
  %3405 = getelementptr inbounds float, float* %2, i64 13
  %3406 = load float, float* %3405, align 4
  %3407 = fmul float %3404, %3406
  %3408 = load float, float* %3379, align 4
  %3409 = fadd float %3408, %3407
  store float %3409, float* %3379, align 4
  %3410 = getelementptr inbounds i8, i8* %2399, i64 56
  %3411 = bitcast i8* %3410 to float*
  store float 0.000000e+00, float* %3411, align 4
  %3412 = getelementptr inbounds i8, i8* %2399, i64 56
  %3413 = bitcast i8* %3412 to float*
  %3414 = load float, float* %3343, align 4
  %3415 = getelementptr inbounds float, float* %2, i64 2
  %3416 = load float, float* %3415, align 4
  %3417 = fmul float %3414, %3416
  %3418 = load float, float* %3413, align 4
  %3419 = fadd float %3418, %3417
  store float %3419, float* %3413, align 4
  %3420 = getelementptr inbounds i8, i8* %2356, i64 52
  %3421 = bitcast i8* %3420 to float*
  %3422 = load float, float* %3421, align 4
  %3423 = getelementptr inbounds float, float* %2, i64 6
  %3424 = load float, float* %3423, align 4
  %3425 = fmul float %3422, %3424
  %3426 = load float, float* %3413, align 4
  %3427 = fadd float %3426, %3425
  store float %3427, float* %3413, align 4
  %3428 = getelementptr inbounds i8, i8* %2356, i64 56
  %3429 = bitcast i8* %3428 to float*
  %3430 = load float, float* %3429, align 4
  %3431 = getelementptr inbounds float, float* %2, i64 10
  %3432 = load float, float* %3431, align 4
  %3433 = fmul float %3430, %3432
  %3434 = load float, float* %3413, align 4
  %3435 = fadd float %3434, %3433
  store float %3435, float* %3413, align 4
  %3436 = getelementptr inbounds i8, i8* %2356, i64 60
  %3437 = bitcast i8* %3436 to float*
  %3438 = load float, float* %3437, align 4
  %3439 = getelementptr inbounds float, float* %2, i64 14
  %3440 = load float, float* %3439, align 4
  %3441 = fmul float %3438, %3440
  %3442 = load float, float* %3413, align 4
  %3443 = fadd float %3442, %3441
  store float %3443, float* %3413, align 4
  %3444 = getelementptr inbounds i8, i8* %2399, i64 60
  %3445 = bitcast i8* %3444 to float*
  store float 0.000000e+00, float* %3445, align 4
  %3446 = getelementptr inbounds i8, i8* %2399, i64 60
  %3447 = bitcast i8* %3446 to float*
  %3448 = load float, float* %3343, align 4
  %3449 = getelementptr inbounds float, float* %2, i64 3
  %3450 = load float, float* %3449, align 4
  %3451 = fmul float %3448, %3450
  %3452 = load float, float* %3447, align 4
  %3453 = fadd float %3452, %3451
  store float %3453, float* %3447, align 4
  %3454 = getelementptr inbounds i8, i8* %2356, i64 52
  %3455 = bitcast i8* %3454 to float*
  %3456 = load float, float* %3455, align 4
  %3457 = getelementptr inbounds float, float* %2, i64 7
  %3458 = load float, float* %3457, align 4
  %3459 = fmul float %3456, %3458
  %3460 = load float, float* %3447, align 4
  %3461 = fadd float %3460, %3459
  store float %3461, float* %3447, align 4
  %3462 = getelementptr inbounds i8, i8* %2356, i64 56
  %3463 = bitcast i8* %3462 to float*
  %3464 = load float, float* %3463, align 4
  %3465 = getelementptr inbounds float, float* %2, i64 11
  %3466 = load float, float* %3465, align 4
  %3467 = fmul float %3464, %3466
  %3468 = load float, float* %3447, align 4
  %3469 = fadd float %3468, %3467
  store float %3469, float* %3447, align 4
  %3470 = getelementptr inbounds i8, i8* %2356, i64 60
  %3471 = bitcast i8* %3470 to float*
  %3472 = load float, float* %3471, align 4
  %3473 = getelementptr inbounds float, float* %2, i64 15
  %3474 = load float, float* %3473, align 4
  %3475 = fmul float %3472, %3474
  %3476 = load float, float* %3447, align 4
  %3477 = fadd float %3476, %3475
  store float %3477, float* %3447, align 4
  %3478 = call i8* @__memcpy_chk(i8* nonnull %43, i8* %2399, i64 64, i64 %45) #8
  call void @free(i8* %2246)
  call void @free(i8* %2248)
  call void @free(i8* %2288)
  call void @free(i8* %2290)
  call void @free(i8* %2326)
  call void @free(i8* %2356)
  %3479 = getelementptr inbounds float, float* %1, i64 1
  %3480 = bitcast float* %3479 to i32*
  %3481 = load i32, i32* %3480, align 4
  %3482 = getelementptr inbounds float, float* %1, i64 4
  %3483 = bitcast float* %3482 to i32*
  %3484 = load i32, i32* %3483, align 4
  %3485 = getelementptr inbounds float, float* %1, i64 1
  %3486 = bitcast float* %3485 to i32*
  store i32 %3484, i32* %3486, align 4
  %3487 = getelementptr inbounds float, float* %1, i64 4
  %3488 = bitcast float* %3487 to i32*
  store i32 %3481, i32* %3488, align 4
  br label %3489

3489:                                             ; preds = %3489, %.preheader33
  %indvars.iv3437 = phi i64 [ 2, %.preheader33 ], [ %indvars.iv.next35.1, %3489 ]
  %3490 = getelementptr inbounds float, float* %1, i64 %indvars.iv3437
  %3491 = bitcast float* %3490 to i32*
  %3492 = load i32, i32* %3491, align 4
  %3493 = shl nuw nsw i64 %indvars.iv3437, 2
  %3494 = getelementptr inbounds float, float* %1, i64 %3493
  %3495 = bitcast float* %3494 to i32*
  %3496 = load i32, i32* %3495, align 4
  %3497 = getelementptr inbounds float, float* %1, i64 %indvars.iv3437
  %3498 = bitcast float* %3497 to i32*
  store i32 %3496, i32* %3498, align 4
  %3499 = shl nuw nsw i64 %indvars.iv3437, 2
  %3500 = getelementptr inbounds float, float* %1, i64 %3499
  %3501 = bitcast float* %3500 to i32*
  store i32 %3492, i32* %3501, align 4
  %indvars.iv.next35 = or i64 %indvars.iv3437, 1
  %3502 = getelementptr inbounds float, float* %1, i64 %indvars.iv.next35
  %3503 = bitcast float* %3502 to i32*
  %3504 = load i32, i32* %3503, align 4
  %3505 = shl nuw nsw i64 %indvars.iv.next35, 2
  %3506 = getelementptr inbounds float, float* %1, i64 %3505
  %3507 = bitcast float* %3506 to i32*
  %3508 = load i32, i32* %3507, align 4
  %3509 = getelementptr inbounds float, float* %1, i64 %indvars.iv.next35
  %3510 = bitcast float* %3509 to i32*
  store i32 %3508, i32* %3510, align 4
  %3511 = shl nuw nsw i64 %indvars.iv.next35, 2
  %3512 = getelementptr inbounds float, float* %1, i64 %3511
  %3513 = bitcast float* %3512 to i32*
  store i32 %3504, i32* %3513, align 4
  %indvars.iv.next35.1 = add nuw nsw i64 %indvars.iv3437, 2
  %exitcond.1.not = icmp eq i64 %indvars.iv.next35.1, 4
  br i1 %exitcond.1.not, label %.lr.ph.new.1, label %3489

.lr.ph.new.1:                                     ; preds = %.lr.ph.new.1, %3489
  %indvars.iv3437.1 = phi i64 [ %indvars.iv.next35.1.1, %.lr.ph.new.1 ], [ 2, %3489 ]
  %3514 = add nuw nsw i64 %indvars.iv3437.1, 4
  %3515 = getelementptr inbounds float, float* %1, i64 %3514
  %3516 = bitcast float* %3515 to i32*
  %3517 = load i32, i32* %3516, align 4
  %3518 = shl nuw nsw i64 %indvars.iv3437.1, 2
  %3519 = or i64 %3518, 1
  %3520 = getelementptr inbounds float, float* %1, i64 %3519
  %3521 = bitcast float* %3520 to i32*
  %3522 = load i32, i32* %3521, align 4
  %3523 = add nuw nsw i64 %indvars.iv3437.1, 4
  %3524 = getelementptr inbounds float, float* %1, i64 %3523
  %3525 = bitcast float* %3524 to i32*
  store i32 %3522, i32* %3525, align 4
  %3526 = shl nuw nsw i64 %indvars.iv3437.1, 2
  %3527 = or i64 %3526, 1
  %3528 = getelementptr inbounds float, float* %1, i64 %3527
  %3529 = bitcast float* %3528 to i32*
  store i32 %3517, i32* %3529, align 4
  %indvars.iv.next35.1149 = or i64 %indvars.iv3437.1, 1
  %3530 = add nuw nsw i64 %indvars.iv3437.1, 5
  %3531 = getelementptr inbounds float, float* %1, i64 %3530
  %3532 = bitcast float* %3531 to i32*
  %3533 = load i32, i32* %3532, align 4
  %3534 = shl nuw nsw i64 %indvars.iv.next35.1149, 2
  %3535 = or i64 %3534, 1
  %3536 = getelementptr inbounds float, float* %1, i64 %3535
  %3537 = bitcast float* %3536 to i32*
  %3538 = load i32, i32* %3537, align 4
  %3539 = add nuw nsw i64 %indvars.iv3437.1, 5
  %3540 = getelementptr inbounds float, float* %1, i64 %3539
  %3541 = bitcast float* %3540 to i32*
  store i32 %3538, i32* %3541, align 4
  %3542 = shl nuw nsw i64 %indvars.iv.next35.1149, 2
  %3543 = or i64 %3542, 1
  %3544 = getelementptr inbounds float, float* %1, i64 %3543
  %3545 = bitcast float* %3544 to i32*
  store i32 %3533, i32* %3545, align 4
  %indvars.iv.next35.1.1 = add nuw nsw i64 %indvars.iv3437.1, 2
  %exitcond.1.1.not = icmp eq i64 %indvars.iv.next35.1.1, 4
  br i1 %exitcond.1.1.not, label %.prol.preheader.2, label %.lr.ph.new.1

.prol.preheader.2:                                ; preds = %.lr.ph.new.1
  %3546 = getelementptr inbounds float, float* %1, i64 11
  %3547 = bitcast float* %3546 to i32*
  %3548 = load i32, i32* %3547, align 4
  %3549 = getelementptr inbounds float, float* %1, i64 14
  %3550 = bitcast float* %3549 to i32*
  %3551 = load i32, i32* %3550, align 4
  %3552 = getelementptr inbounds float, float* %1, i64 11
  %3553 = bitcast float* %3552 to i32*
  store i32 %3551, i32* %3553, align 4
  %3554 = getelementptr inbounds float, float* %1, i64 14
  %3555 = bitcast float* %3554 to i32*
  store i32 %3548, i32* %3555, align 4
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
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #6

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #7

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.sqrt.f32(float) #1

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
