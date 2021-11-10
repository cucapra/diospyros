; ModuleID = 'opt.ll'
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

._crit_edge:                                      ; preds = %.epil.preheader, %._crit_edge.unr-lcssa, %2
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
  %3 = load float, float* %0, align 4
  %4 = load float, float* %1, align 4
  %5 = fmul float %3, %4
  %6 = fadd float %5, 0.000000e+00
  %7 = getelementptr inbounds float, float* %0, i64 1
  %8 = load float, float* %7, align 4
  %9 = getelementptr inbounds float, float* %1, i64 4
  %10 = load float, float* %9, align 4
  %11 = fmul float %8, %10
  %12 = fadd float %6, %11
  %13 = getelementptr inbounds float, float* %0, i64 2
  %14 = load float, float* %13, align 4
  %15 = getelementptr inbounds float, float* %1, i64 8
  %16 = load float, float* %15, align 4
  %17 = fmul float %14, %16
  %18 = fadd float %12, %17
  %19 = getelementptr inbounds float, float* %0, i64 3
  %20 = load float, float* %19, align 4
  %21 = getelementptr inbounds float, float* %1, i64 12
  %22 = load float, float* %21, align 4
  %23 = fmul float %20, %22
  %24 = fadd float %18, %23
  %25 = getelementptr inbounds float, float* %2, i64 1
  %26 = getelementptr inbounds float, float* %2, i64 1
  %27 = load float, float* %0, align 4
  %28 = getelementptr inbounds float, float* %1, i64 1
  %29 = load float, float* %28, align 4
  %30 = fmul float %27, %29
  %31 = fadd float %30, 0.000000e+00
  %32 = getelementptr inbounds float, float* %0, i64 1
  %33 = load float, float* %32, align 4
  %34 = getelementptr inbounds float, float* %1, i64 5
  %35 = load float, float* %34, align 4
  %36 = fmul float %33, %35
  %37 = fadd float %31, %36
  %38 = getelementptr inbounds float, float* %0, i64 2
  %39 = load float, float* %38, align 4
  %40 = getelementptr inbounds float, float* %1, i64 9
  %41 = load float, float* %40, align 4
  %42 = fmul float %39, %41
  %43 = fadd float %37, %42
  %44 = getelementptr inbounds float, float* %0, i64 3
  %45 = load float, float* %44, align 4
  %46 = getelementptr inbounds float, float* %1, i64 13
  %47 = load float, float* %46, align 4
  %48 = fmul float %45, %47
  %49 = fadd float %43, %48
  %50 = getelementptr inbounds float, float* %2, i64 2
  %51 = getelementptr inbounds float, float* %2, i64 2
  %52 = load float, float* %0, align 4
  %53 = getelementptr inbounds float, float* %1, i64 2
  %54 = load float, float* %53, align 4
  %55 = fmul float %52, %54
  %56 = fadd float %55, 0.000000e+00
  %57 = getelementptr inbounds float, float* %0, i64 1
  %58 = load float, float* %57, align 4
  %59 = getelementptr inbounds float, float* %1, i64 6
  %60 = load float, float* %59, align 4
  %61 = fmul float %58, %60
  %62 = fadd float %56, %61
  %63 = getelementptr inbounds float, float* %0, i64 2
  %64 = load float, float* %63, align 4
  %65 = getelementptr inbounds float, float* %1, i64 10
  %66 = load float, float* %65, align 4
  %67 = fmul float %64, %66
  %68 = fadd float %62, %67
  %69 = getelementptr inbounds float, float* %0, i64 3
  %70 = load float, float* %69, align 4
  %71 = getelementptr inbounds float, float* %1, i64 14
  %72 = load float, float* %71, align 4
  %73 = fmul float %70, %72
  %74 = fadd float %68, %73
  %75 = getelementptr inbounds float, float* %2, i64 3
  %76 = getelementptr inbounds float, float* %2, i64 3
  %77 = load float, float* %0, align 4
  %78 = getelementptr inbounds float, float* %1, i64 3
  %79 = load float, float* %78, align 4
  %80 = fmul float %77, %79
  %81 = fadd float %80, 0.000000e+00
  %82 = getelementptr inbounds float, float* %0, i64 1
  %83 = load float, float* %82, align 4
  %84 = getelementptr inbounds float, float* %1, i64 7
  %85 = load float, float* %84, align 4
  %86 = fmul float %83, %85
  %87 = fadd float %81, %86
  %88 = getelementptr inbounds float, float* %0, i64 2
  %89 = load float, float* %88, align 4
  %90 = getelementptr inbounds float, float* %1, i64 11
  %91 = load float, float* %90, align 4
  %92 = fmul float %89, %91
  %93 = fadd float %87, %92
  %94 = getelementptr inbounds float, float* %0, i64 3
  %95 = load float, float* %94, align 4
  %96 = getelementptr inbounds float, float* %1, i64 15
  %97 = load float, float* %96, align 4
  %98 = fmul float %95, %97
  %99 = fadd float %93, %98
  %100 = getelementptr inbounds float, float* %0, i64 4
  %101 = getelementptr inbounds float, float* %2, i64 4
  %102 = getelementptr inbounds float, float* %2, i64 4
  %103 = load float, float* %100, align 4
  %104 = load float, float* %1, align 4
  %105 = fmul float %103, %104
  %106 = fadd float %105, 0.000000e+00
  %107 = getelementptr inbounds float, float* %0, i64 5
  %108 = load float, float* %107, align 4
  %109 = getelementptr inbounds float, float* %1, i64 4
  %110 = load float, float* %109, align 4
  %111 = fmul float %108, %110
  %112 = fadd float %106, %111
  %113 = getelementptr inbounds float, float* %0, i64 6
  %114 = load float, float* %113, align 4
  %115 = getelementptr inbounds float, float* %1, i64 8
  %116 = load float, float* %115, align 4
  %117 = fmul float %114, %116
  %118 = fadd float %112, %117
  %119 = getelementptr inbounds float, float* %0, i64 7
  %120 = load float, float* %119, align 4
  %121 = getelementptr inbounds float, float* %1, i64 12
  %122 = load float, float* %121, align 4
  %123 = fmul float %120, %122
  %124 = fadd float %118, %123
  %125 = getelementptr inbounds float, float* %2, i64 5
  %126 = getelementptr inbounds float, float* %2, i64 5
  %127 = load float, float* %100, align 4
  %128 = getelementptr inbounds float, float* %1, i64 1
  %129 = load float, float* %128, align 4
  %130 = fmul float %127, %129
  %131 = fadd float %130, 0.000000e+00
  %132 = getelementptr inbounds float, float* %0, i64 5
  %133 = load float, float* %132, align 4
  %134 = getelementptr inbounds float, float* %1, i64 5
  %135 = load float, float* %134, align 4
  %136 = fmul float %133, %135
  %137 = fadd float %131, %136
  %138 = getelementptr inbounds float, float* %0, i64 6
  %139 = load float, float* %138, align 4
  %140 = getelementptr inbounds float, float* %1, i64 9
  %141 = load float, float* %140, align 4
  %142 = fmul float %139, %141
  %143 = fadd float %137, %142
  %144 = getelementptr inbounds float, float* %0, i64 7
  %145 = load float, float* %144, align 4
  %146 = getelementptr inbounds float, float* %1, i64 13
  %147 = load float, float* %146, align 4
  %148 = fmul float %145, %147
  %149 = fadd float %143, %148
  %150 = getelementptr inbounds float, float* %2, i64 6
  %151 = getelementptr inbounds float, float* %2, i64 6
  %152 = load float, float* %100, align 4
  %153 = getelementptr inbounds float, float* %1, i64 2
  %154 = load float, float* %153, align 4
  %155 = fmul float %152, %154
  %156 = fadd float %155, 0.000000e+00
  %157 = getelementptr inbounds float, float* %0, i64 5
  %158 = load float, float* %157, align 4
  %159 = getelementptr inbounds float, float* %1, i64 6
  %160 = load float, float* %159, align 4
  %161 = fmul float %158, %160
  %162 = fadd float %156, %161
  %163 = getelementptr inbounds float, float* %0, i64 6
  %164 = load float, float* %163, align 4
  %165 = getelementptr inbounds float, float* %1, i64 10
  %166 = load float, float* %165, align 4
  %167 = fmul float %164, %166
  %168 = fadd float %162, %167
  %169 = getelementptr inbounds float, float* %0, i64 7
  %170 = load float, float* %169, align 4
  %171 = getelementptr inbounds float, float* %1, i64 14
  %172 = load float, float* %171, align 4
  %173 = fmul float %170, %172
  %174 = fadd float %168, %173
  %175 = getelementptr inbounds float, float* %2, i64 7
  %176 = getelementptr inbounds float, float* %2, i64 7
  %177 = load float, float* %100, align 4
  %178 = getelementptr inbounds float, float* %1, i64 3
  %179 = load float, float* %178, align 4
  %180 = fmul float %177, %179
  %181 = fadd float %180, 0.000000e+00
  %182 = getelementptr inbounds float, float* %0, i64 5
  %183 = load float, float* %182, align 4
  %184 = getelementptr inbounds float, float* %1, i64 7
  %185 = load float, float* %184, align 4
  %186 = fmul float %183, %185
  %187 = fadd float %181, %186
  %188 = getelementptr inbounds float, float* %0, i64 6
  %189 = load float, float* %188, align 4
  %190 = getelementptr inbounds float, float* %1, i64 11
  %191 = load float, float* %190, align 4
  %192 = fmul float %189, %191
  %193 = fadd float %187, %192
  %194 = getelementptr inbounds float, float* %0, i64 7
  %195 = load float, float* %194, align 4
  %196 = getelementptr inbounds float, float* %1, i64 15
  %197 = load float, float* %196, align 4
  %198 = fmul float %195, %197
  %199 = fadd float %193, %198
  %200 = getelementptr inbounds float, float* %0, i64 8
  %201 = getelementptr inbounds float, float* %2, i64 8
  %202 = getelementptr inbounds float, float* %2, i64 8
  %203 = load float, float* %200, align 4
  %204 = load float, float* %1, align 4
  %205 = fmul float %203, %204
  %206 = fadd float %205, 0.000000e+00
  %207 = getelementptr inbounds float, float* %0, i64 9
  %208 = load float, float* %207, align 4
  %209 = getelementptr inbounds float, float* %1, i64 4
  %210 = load float, float* %209, align 4
  %211 = fmul float %208, %210
  %212 = fadd float %206, %211
  %213 = getelementptr inbounds float, float* %0, i64 10
  %214 = load float, float* %213, align 4
  %215 = getelementptr inbounds float, float* %1, i64 8
  %216 = load float, float* %215, align 4
  %217 = fmul float %214, %216
  %218 = fadd float %212, %217
  %219 = getelementptr inbounds float, float* %0, i64 11
  %220 = load float, float* %219, align 4
  %221 = getelementptr inbounds float, float* %1, i64 12
  %222 = load float, float* %221, align 4
  %223 = fmul float %220, %222
  %224 = fadd float %218, %223
  %225 = getelementptr inbounds float, float* %2, i64 9
  %226 = getelementptr inbounds float, float* %2, i64 9
  %227 = load float, float* %200, align 4
  %228 = getelementptr inbounds float, float* %1, i64 1
  %229 = load float, float* %228, align 4
  %230 = fmul float %227, %229
  %231 = fadd float %230, 0.000000e+00
  %232 = getelementptr inbounds float, float* %0, i64 9
  %233 = load float, float* %232, align 4
  %234 = getelementptr inbounds float, float* %1, i64 5
  %235 = load float, float* %234, align 4
  %236 = fmul float %233, %235
  %237 = fadd float %231, %236
  %238 = getelementptr inbounds float, float* %0, i64 10
  %239 = load float, float* %238, align 4
  %240 = getelementptr inbounds float, float* %1, i64 9
  %241 = load float, float* %240, align 4
  %242 = fmul float %239, %241
  %243 = fadd float %237, %242
  %244 = getelementptr inbounds float, float* %0, i64 11
  %245 = load float, float* %244, align 4
  %246 = getelementptr inbounds float, float* %1, i64 13
  %247 = load float, float* %246, align 4
  %248 = fmul float %245, %247
  %249 = fadd float %243, %248
  %250 = getelementptr inbounds float, float* %2, i64 10
  %251 = getelementptr inbounds float, float* %2, i64 10
  %252 = load float, float* %200, align 4
  %253 = getelementptr inbounds float, float* %1, i64 2
  %254 = load float, float* %253, align 4
  %255 = fmul float %252, %254
  %256 = fadd float %255, 0.000000e+00
  %257 = getelementptr inbounds float, float* %0, i64 9
  %258 = load float, float* %257, align 4
  %259 = getelementptr inbounds float, float* %1, i64 6
  %260 = load float, float* %259, align 4
  %261 = fmul float %258, %260
  %262 = fadd float %256, %261
  %263 = getelementptr inbounds float, float* %0, i64 10
  %264 = load float, float* %263, align 4
  %265 = getelementptr inbounds float, float* %1, i64 10
  %266 = load float, float* %265, align 4
  %267 = fmul float %264, %266
  %268 = fadd float %262, %267
  %269 = getelementptr inbounds float, float* %0, i64 11
  %270 = load float, float* %269, align 4
  %271 = getelementptr inbounds float, float* %1, i64 14
  %272 = load float, float* %271, align 4
  %273 = fmul float %270, %272
  %274 = fadd float %268, %273
  %275 = getelementptr inbounds float, float* %2, i64 11
  %276 = getelementptr inbounds float, float* %2, i64 11
  %277 = load float, float* %200, align 4
  %278 = getelementptr inbounds float, float* %1, i64 3
  %279 = load float, float* %278, align 4
  %280 = fmul float %277, %279
  %281 = fadd float %280, 0.000000e+00
  %282 = getelementptr inbounds float, float* %0, i64 9
  %283 = load float, float* %282, align 4
  %284 = getelementptr inbounds float, float* %1, i64 7
  %285 = load float, float* %284, align 4
  %286 = fmul float %283, %285
  %287 = fadd float %281, %286
  %288 = getelementptr inbounds float, float* %0, i64 10
  %289 = load float, float* %288, align 4
  %290 = getelementptr inbounds float, float* %1, i64 11
  %291 = load float, float* %290, align 4
  %292 = fmul float %289, %291
  %293 = fadd float %287, %292
  %294 = getelementptr inbounds float, float* %0, i64 11
  %295 = load float, float* %294, align 4
  %296 = getelementptr inbounds float, float* %1, i64 15
  %297 = load float, float* %296, align 4
  %298 = fmul float %295, %297
  %299 = fadd float %293, %298
  %300 = getelementptr inbounds float, float* %0, i64 12
  %301 = getelementptr inbounds float, float* %2, i64 12
  %302 = getelementptr inbounds float, float* %2, i64 12
  %303 = load float, float* %300, align 4
  %304 = load float, float* %1, align 4
  %305 = fmul float %303, %304
  %306 = fadd float %305, 0.000000e+00
  %307 = getelementptr inbounds float, float* %0, i64 13
  %308 = load float, float* %307, align 4
  %309 = getelementptr inbounds float, float* %1, i64 4
  %310 = load float, float* %309, align 4
  %311 = fmul float %308, %310
  %312 = fadd float %306, %311
  %313 = getelementptr inbounds float, float* %0, i64 14
  %314 = load float, float* %313, align 4
  %315 = getelementptr inbounds float, float* %1, i64 8
  %316 = load float, float* %315, align 4
  %317 = fmul float %314, %316
  %318 = fadd float %312, %317
  %319 = getelementptr inbounds float, float* %0, i64 15
  %320 = load float, float* %319, align 4
  %321 = getelementptr inbounds float, float* %1, i64 12
  %322 = load float, float* %321, align 4
  %323 = fmul float %320, %322
  %324 = fadd float %318, %323
  %325 = getelementptr inbounds float, float* %2, i64 13
  %326 = getelementptr inbounds float, float* %2, i64 13
  %327 = load float, float* %300, align 4
  %328 = getelementptr inbounds float, float* %1, i64 1
  %329 = load float, float* %328, align 4
  %330 = fmul float %327, %329
  %331 = fadd float %330, 0.000000e+00
  %332 = getelementptr inbounds float, float* %0, i64 13
  %333 = load float, float* %332, align 4
  %334 = getelementptr inbounds float, float* %1, i64 5
  %335 = load float, float* %334, align 4
  %336 = fmul float %333, %335
  %337 = fadd float %331, %336
  %338 = getelementptr inbounds float, float* %0, i64 14
  %339 = load float, float* %338, align 4
  %340 = getelementptr inbounds float, float* %1, i64 9
  %341 = load float, float* %340, align 4
  %342 = fmul float %339, %341
  %343 = fadd float %337, %342
  %344 = getelementptr inbounds float, float* %0, i64 15
  %345 = load float, float* %344, align 4
  %346 = getelementptr inbounds float, float* %1, i64 13
  %347 = load float, float* %346, align 4
  %348 = fmul float %345, %347
  %349 = fadd float %343, %348
  %350 = getelementptr inbounds float, float* %2, i64 14
  %351 = getelementptr inbounds float, float* %2, i64 14
  %352 = load float, float* %300, align 4
  %353 = getelementptr inbounds float, float* %1, i64 2
  %354 = load float, float* %353, align 4
  %355 = fmul float %352, %354
  %356 = fadd float %355, 0.000000e+00
  %357 = getelementptr inbounds float, float* %0, i64 13
  %358 = load float, float* %357, align 4
  %359 = getelementptr inbounds float, float* %1, i64 6
  %360 = load float, float* %359, align 4
  %361 = fmul float %358, %360
  %362 = fadd float %356, %361
  %363 = getelementptr inbounds float, float* %0, i64 14
  %364 = load float, float* %363, align 4
  %365 = getelementptr inbounds float, float* %1, i64 10
  %366 = load float, float* %365, align 4
  %367 = fmul float %364, %366
  %368 = fadd float %362, %367
  %369 = getelementptr inbounds float, float* %0, i64 15
  %370 = load float, float* %369, align 4
  %371 = getelementptr inbounds float, float* %1, i64 14
  %372 = load float, float* %371, align 4
  %373 = fmul float %370, %372
  %374 = fadd float %368, %373
  %375 = getelementptr inbounds float, float* %2, i64 15
  %376 = getelementptr inbounds float, float* %2, i64 15
  %377 = load float, float* %300, align 4
  %378 = getelementptr inbounds float, float* %1, i64 3
  %379 = load float, float* %378, align 4
  %380 = fmul float %377, %379
  %381 = fadd float %380, 0.000000e+00
  %382 = getelementptr inbounds float, float* %0, i64 13
  %383 = load float, float* %382, align 4
  %384 = getelementptr inbounds float, float* %1, i64 7
  %385 = load float, float* %384, align 4
  %386 = fmul float %383, %385
  %387 = fadd float %381, %386
  %388 = getelementptr inbounds float, float* %0, i64 14
  %389 = load float, float* %388, align 4
  %390 = getelementptr inbounds float, float* %1, i64 11
  %391 = load float, float* %390, align 4
  %392 = fmul float %389, %391
  %393 = fadd float %387, %392
  %394 = getelementptr inbounds float, float* %0, i64 15
  %395 = load float, float* %394, align 4
  %396 = getelementptr inbounds float, float* %1, i64 15
  %397 = load float, float* %396, align 4
  %398 = fmul float %395, %397
  %399 = fadd float %393, %398
  %400 = load float, float* %0, align 4
  %401 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 0.000000e+00>, float %400, i32 3
  %402 = load float, float* %1, align 4
  %403 = insertelement <4 x float> zeroinitializer, float %402, i32 3
  %404 = fmul <4 x float> %401, %403
  %405 = load float, float* %0, align 4
  %406 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %405, i32 2
  %407 = insertelement <4 x float> %406, float 1.000000e+00, i32 3
  %408 = load float, float* %1, align 4
  %409 = insertelement <4 x float> zeroinitializer, float %408, i32 2
  %410 = insertelement <4 x float> %409, float 0.000000e+00, i32 3
  %411 = call <4 x float> @llvm.fma.f32(<4 x float> %407, <4 x float> %410, <4 x float> %404)
  %412 = getelementptr inbounds float, float* %0, i64 1
  %413 = load float, float* %412, align 4
  %414 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 0.000000e+00>, float %413, i32 3
  %415 = getelementptr inbounds float, float* %1, i64 4
  %416 = load float, float* %415, align 4
  %417 = insertelement <4 x float> zeroinitializer, float %416, i32 3
  %418 = call <4 x float> @llvm.fma.f32.1(<4 x float> %414, <4 x float> %417, <4 x float> %411)
  %419 = load float, float* %0, align 4
  %420 = insertelement <4 x float> zeroinitializer, float %419, i32 1
  %421 = getelementptr inbounds float, float* %0, i64 1
  %422 = load float, float* %421, align 4
  %423 = insertelement <4 x float> %420, float %422, i32 2
  %424 = getelementptr inbounds float, float* %0, i64 2
  %425 = load float, float* %424, align 4
  %426 = insertelement <4 x float> %423, float %425, i32 3
  %427 = load float, float* %1, align 4
  %428 = insertelement <4 x float> zeroinitializer, float %427, i32 1
  %429 = getelementptr inbounds float, float* %1, i64 4
  %430 = load float, float* %429, align 4
  %431 = insertelement <4 x float> %428, float %430, i32 2
  %432 = getelementptr inbounds float, float* %1, i64 8
  %433 = load float, float* %432, align 4
  %434 = insertelement <4 x float> %431, float %433, i32 3
  %435 = call <4 x float> @llvm.fma.f32.2(<4 x float> %426, <4 x float> %434, <4 x float> %418)
  %436 = load float, float* %0, align 4
  %437 = insertelement <4 x float> zeroinitializer, float %436, i32 0
  %438 = insertelement <4 x float> %437, float 1.000000e+00, i32 1
  %439 = insertelement <4 x float> %438, float 1.000000e+00, i32 2
  %440 = insertelement <4 x float> %439, float 1.000000e+00, i32 3
  %441 = load float, float* %1, align 4
  %442 = insertelement <4 x float> zeroinitializer, float %441, i32 0
  %443 = insertelement <4 x float> %442, float 0.000000e+00, i32 1
  %444 = insertelement <4 x float> %443, float 0.000000e+00, i32 2
  %445 = insertelement <4 x float> %444, float 0.000000e+00, i32 3
  %446 = fmul <4 x float> %440, %445
  %447 = fadd <4 x float> %446, zeroinitializer
  %448 = getelementptr inbounds float, float* %0, i64 1
  %449 = load float, float* %448, align 4
  %450 = insertelement <4 x float> zeroinitializer, float %449, i32 0
  %451 = insertelement <4 x float> %450, float 1.000000e+00, i32 1
  %452 = insertelement <4 x float> %451, float 1.000000e+00, i32 2
  %453 = load float, float* %0, align 4
  %454 = insertelement <4 x float> %452, float %453, i32 3
  %455 = getelementptr inbounds float, float* %1, i64 4
  %456 = load float, float* %455, align 4
  %457 = insertelement <4 x float> zeroinitializer, float %456, i32 0
  %458 = insertelement <4 x float> %457, float 0.000000e+00, i32 1
  %459 = insertelement <4 x float> %458, float 0.000000e+00, i32 2
  %460 = getelementptr inbounds float, float* %1, i64 1
  %461 = load float, float* %460, align 4
  %462 = insertelement <4 x float> %459, float %461, i32 3
  %463 = call <4 x float> @llvm.fma.f32.3(<4 x float> %454, <4 x float> %462, <4 x float> %447)
  %464 = getelementptr inbounds float, float* %0, i64 2
  %465 = load float, float* %464, align 4
  %466 = insertelement <4 x float> zeroinitializer, float %465, i32 0
  %467 = insertelement <4 x float> %466, float 1.000000e+00, i32 1
  %468 = insertelement <4 x float> %467, float 1.000000e+00, i32 2
  %469 = insertelement <4 x float> %468, float 1.000000e+00, i32 3
  %470 = getelementptr inbounds float, float* %1, i64 8
  %471 = load float, float* %470, align 4
  %472 = insertelement <4 x float> zeroinitializer, float %471, i32 0
  %473 = insertelement <4 x float> %472, float 0.000000e+00, i32 1
  %474 = insertelement <4 x float> %473, float 0.000000e+00, i32 2
  %475 = insertelement <4 x float> %474, float 0.000000e+00, i32 3
  %476 = call <4 x float> @llvm.fma.f32.4(<4 x float> %469, <4 x float> %475, <4 x float> %463)
  %477 = getelementptr inbounds float, float* %0, i64 3
  %478 = load float, float* %477, align 4
  %479 = insertelement <4 x float> zeroinitializer, float %478, i32 0
  %480 = insertelement <4 x float> %479, float 0.000000e+00, i32 1
  %481 = load float, float* %0, align 4
  %482 = insertelement <4 x float> %480, float %481, i32 2
  %483 = getelementptr inbounds float, float* %0, i64 1
  %484 = load float, float* %483, align 4
  %485 = insertelement <4 x float> %482, float %484, i32 3
  %486 = getelementptr inbounds float, float* %1, i64 12
  %487 = load float, float* %486, align 4
  %488 = insertelement <4 x float> zeroinitializer, float %487, i32 0
  %489 = insertelement <4 x float> %488, float 0.000000e+00, i32 1
  %490 = getelementptr inbounds float, float* %1, i64 1
  %491 = load float, float* %490, align 4
  %492 = insertelement <4 x float> %489, float %491, i32 2
  %493 = getelementptr inbounds float, float* %1, i64 5
  %494 = load float, float* %493, align 4
  %495 = insertelement <4 x float> %492, float %494, i32 3
  %496 = call <4 x float> @llvm.fma.f32.5(<4 x float> %485, <4 x float> %495, <4 x float> %476)
  %497 = shufflevector <4 x float> %435, <4 x float> %496, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %498 = load float, float* %0, align 4
  %499 = insertelement <4 x float> <float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %498, i32 1
  %500 = insertelement <4 x float> %499, float 1.000000e+00, i32 2
  %501 = insertelement <4 x float> %500, float 1.000000e+00, i32 3
  %502 = getelementptr inbounds float, float* %1, i64 1
  %503 = load float, float* %502, align 4
  %504 = insertelement <4 x float> zeroinitializer, float %503, i32 1
  %505 = insertelement <4 x float> %504, float 0.000000e+00, i32 2
  %506 = insertelement <4 x float> %505, float 0.000000e+00, i32 3
  %507 = fmul <4 x float> %501, %506
  %508 = load float, float* %0, align 4
  %509 = insertelement <4 x float> zeroinitializer, float %508, i32 0
  %510 = insertelement <4 x float> %509, float 1.000000e+00, i32 1
  %511 = insertelement <4 x float> %510, float 1.000000e+00, i32 2
  %512 = insertelement <4 x float> %511, float 1.000000e+00, i32 3
  %513 = getelementptr inbounds float, float* %1, i64 1
  %514 = load float, float* %513, align 4
  %515 = insertelement <4 x float> zeroinitializer, float %514, i32 0
  %516 = insertelement <4 x float> %515, float 0.000000e+00, i32 1
  %517 = insertelement <4 x float> %516, float 0.000000e+00, i32 2
  %518 = insertelement <4 x float> %517, float 0.000000e+00, i32 3
  %519 = call <4 x float> @llvm.fma.f32.6(<4 x float> %512, <4 x float> %518, <4 x float> %507)
  %520 = getelementptr inbounds float, float* %0, i64 1
  %521 = load float, float* %520, align 4
  %522 = insertelement <4 x float> <float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %521, i32 1
  %523 = insertelement <4 x float> %522, float 1.000000e+00, i32 2
  %524 = insertelement <4 x float> %523, float 1.000000e+00, i32 3
  %525 = getelementptr inbounds float, float* %1, i64 5
  %526 = load float, float* %525, align 4
  %527 = insertelement <4 x float> zeroinitializer, float %526, i32 1
  %528 = insertelement <4 x float> %527, float 0.000000e+00, i32 2
  %529 = insertelement <4 x float> %528, float 0.000000e+00, i32 3
  %530 = call <4 x float> @llvm.fma.f32.7(<4 x float> %524, <4 x float> %529, <4 x float> %519)
  %531 = getelementptr inbounds float, float* %0, i64 1
  %532 = load float, float* %531, align 4
  %533 = insertelement <4 x float> zeroinitializer, float %532, i32 0
  %534 = getelementptr inbounds float, float* %0, i64 2
  %535 = load float, float* %534, align 4
  %536 = insertelement <4 x float> %533, float %535, i32 1
  %537 = insertelement <4 x float> %536, float 1.000000e+00, i32 2
  %538 = load float, float* %0, align 4
  %539 = insertelement <4 x float> %537, float %538, i32 3
  %540 = getelementptr inbounds float, float* %1, i64 5
  %541 = load float, float* %540, align 4
  %542 = insertelement <4 x float> zeroinitializer, float %541, i32 0
  %543 = getelementptr inbounds float, float* %1, i64 9
  %544 = load float, float* %543, align 4
  %545 = insertelement <4 x float> %542, float %544, i32 1
  %546 = insertelement <4 x float> %545, float 0.000000e+00, i32 2
  %547 = getelementptr inbounds float, float* %1, i64 2
  %548 = load float, float* %547, align 4
  %549 = insertelement <4 x float> %546, float %548, i32 3
  %550 = call <4 x float> @llvm.fma.f32.8(<4 x float> %539, <4 x float> %549, <4 x float> %530)
  %551 = getelementptr inbounds float, float* %0, i64 2
  %552 = load float, float* %551, align 4
  %553 = insertelement <4 x float> zeroinitializer, float %552, i32 0
  %554 = getelementptr inbounds float, float* %0, i64 3
  %555 = load float, float* %554, align 4
  %556 = insertelement <4 x float> %553, float %555, i32 1
  %557 = insertelement <4 x float> %556, float 1.000000e+00, i32 2
  %558 = insertelement <4 x float> %557, float 1.000000e+00, i32 3
  %559 = getelementptr inbounds float, float* %1, i64 9
  %560 = load float, float* %559, align 4
  %561 = insertelement <4 x float> zeroinitializer, float %560, i32 0
  %562 = getelementptr inbounds float, float* %1, i64 13
  %563 = load float, float* %562, align 4
  %564 = insertelement <4 x float> %561, float %563, i32 1
  %565 = insertelement <4 x float> %564, float 0.000000e+00, i32 2
  %566 = insertelement <4 x float> %565, float 0.000000e+00, i32 3
  %567 = call <4 x float> @llvm.fma.f32.9(<4 x float> %558, <4 x float> %566, <4 x float> %550)
  %568 = load float, float* %0, align 4
  %569 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %568, i32 2
  %570 = insertelement <4 x float> %569, float 1.000000e+00, i32 3
  %571 = getelementptr inbounds float, float* %1, i64 2
  %572 = load float, float* %571, align 4
  %573 = insertelement <4 x float> zeroinitializer, float %572, i32 2
  %574 = insertelement <4 x float> %573, float 0.000000e+00, i32 3
  %575 = fmul <4 x float> %570, %574
  %576 = load float, float* %0, align 4
  %577 = insertelement <4 x float> <float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %576, i32 1
  %578 = insertelement <4 x float> %577, float 1.000000e+00, i32 2
  %579 = insertelement <4 x float> %578, float 1.000000e+00, i32 3
  %580 = getelementptr inbounds float, float* %1, i64 2
  %581 = load float, float* %580, align 4
  %582 = insertelement <4 x float> zeroinitializer, float %581, i32 1
  %583 = insertelement <4 x float> %582, float 0.000000e+00, i32 2
  %584 = insertelement <4 x float> %583, float 0.000000e+00, i32 3
  %585 = call <4 x float> @llvm.fma.f32.10(<4 x float> %579, <4 x float> %584, <4 x float> %575)
  %586 = load float, float* %0, align 4
  %587 = insertelement <4 x float> zeroinitializer, float %586, i32 0
  %588 = insertelement <4 x float> %587, float 1.000000e+00, i32 1
  %589 = getelementptr inbounds float, float* %0, i64 1
  %590 = load float, float* %589, align 4
  %591 = insertelement <4 x float> %588, float %590, i32 2
  %592 = insertelement <4 x float> %591, float 1.000000e+00, i32 3
  %593 = getelementptr inbounds float, float* %1, i64 2
  %594 = load float, float* %593, align 4
  %595 = insertelement <4 x float> zeroinitializer, float %594, i32 0
  %596 = insertelement <4 x float> %595, float 0.000000e+00, i32 1
  %597 = getelementptr inbounds float, float* %1, i64 6
  %598 = load float, float* %597, align 4
  %599 = insertelement <4 x float> %596, float %598, i32 2
  %600 = insertelement <4 x float> %599, float 0.000000e+00, i32 3
  %601 = call <4 x float> @llvm.fma.f32.11(<4 x float> %592, <4 x float> %600, <4 x float> %585)
  %602 = getelementptr inbounds float, float* %0, i64 1
  %603 = load float, float* %602, align 4
  %604 = insertelement <4 x float> <float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %603, i32 1
  %605 = getelementptr inbounds float, float* %0, i64 2
  %606 = load float, float* %605, align 4
  %607 = insertelement <4 x float> %604, float %606, i32 2
  %608 = insertelement <4 x float> %607, float 1.000000e+00, i32 3
  %609 = getelementptr inbounds float, float* %1, i64 6
  %610 = load float, float* %609, align 4
  %611 = insertelement <4 x float> zeroinitializer, float %610, i32 1
  %612 = getelementptr inbounds float, float* %1, i64 10
  %613 = load float, float* %612, align 4
  %614 = insertelement <4 x float> %611, float %613, i32 2
  %615 = insertelement <4 x float> %614, float 0.000000e+00, i32 3
  %616 = call <4 x float> @llvm.fma.f32.12(<4 x float> %608, <4 x float> %615, <4 x float> %601)
  %617 = getelementptr inbounds float, float* %0, i64 1
  %618 = load float, float* %617, align 4
  %619 = insertelement <4 x float> zeroinitializer, float %618, i32 0
  %620 = getelementptr inbounds float, float* %0, i64 2
  %621 = load float, float* %620, align 4
  %622 = insertelement <4 x float> %619, float %621, i32 1
  %623 = getelementptr inbounds float, float* %0, i64 3
  %624 = load float, float* %623, align 4
  %625 = insertelement <4 x float> %622, float %624, i32 2
  %626 = insertelement <4 x float> %625, float 0.000000e+00, i32 3
  %627 = getelementptr inbounds float, float* %1, i64 6
  %628 = load float, float* %627, align 4
  %629 = insertelement <4 x float> zeroinitializer, float %628, i32 0
  %630 = getelementptr inbounds float, float* %1, i64 10
  %631 = load float, float* %630, align 4
  %632 = insertelement <4 x float> %629, float %631, i32 1
  %633 = getelementptr inbounds float, float* %1, i64 14
  %634 = load float, float* %633, align 4
  %635 = insertelement <4 x float> %632, float %634, i32 2
  %636 = insertelement <4 x float> %635, float 0.000000e+00, i32 3
  %637 = call <4 x float> @llvm.fma.f32.13(<4 x float> %626, <4 x float> %636, <4 x float> %616)
  %638 = shufflevector <4 x float> %567, <4 x float> %637, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %639 = shufflevector <8 x float> %497, <8 x float> %638, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %640 = load float, float* %0, align 4
  %641 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 0.000000e+00>, float %640, i32 3
  %642 = getelementptr inbounds float, float* %1, i64 3
  %643 = load float, float* %642, align 4
  %644 = insertelement <4 x float> zeroinitializer, float %643, i32 3
  %645 = fmul <4 x float> %641, %644
  %646 = load float, float* %0, align 4
  %647 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %646, i32 2
  %648 = insertelement <4 x float> %647, float 1.000000e+00, i32 3
  %649 = getelementptr inbounds float, float* %1, i64 3
  %650 = load float, float* %649, align 4
  %651 = insertelement <4 x float> zeroinitializer, float %650, i32 2
  %652 = insertelement <4 x float> %651, float 0.000000e+00, i32 3
  %653 = call <4 x float> @llvm.fma.f32.14(<4 x float> %648, <4 x float> %652, <4 x float> %645)
  %654 = load float, float* %0, align 4
  %655 = insertelement <4 x float> <float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %654, i32 1
  %656 = insertelement <4 x float> %655, float 1.000000e+00, i32 2
  %657 = getelementptr inbounds float, float* %0, i64 1
  %658 = load float, float* %657, align 4
  %659 = insertelement <4 x float> %656, float %658, i32 3
  %660 = getelementptr inbounds float, float* %1, i64 3
  %661 = load float, float* %660, align 4
  %662 = insertelement <4 x float> zeroinitializer, float %661, i32 1
  %663 = insertelement <4 x float> %662, float 0.000000e+00, i32 2
  %664 = getelementptr inbounds float, float* %1, i64 7
  %665 = load float, float* %664, align 4
  %666 = insertelement <4 x float> %663, float %665, i32 3
  %667 = call <4 x float> @llvm.fma.f32.15(<4 x float> %659, <4 x float> %666, <4 x float> %653)
  %668 = getelementptr inbounds float, float* %0, i64 1
  %669 = load float, float* %668, align 4
  %670 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %669, i32 2
  %671 = getelementptr inbounds float, float* %0, i64 2
  %672 = load float, float* %671, align 4
  %673 = insertelement <4 x float> %670, float %672, i32 3
  %674 = getelementptr inbounds float, float* %1, i64 7
  %675 = load float, float* %674, align 4
  %676 = insertelement <4 x float> zeroinitializer, float %675, i32 2
  %677 = getelementptr inbounds float, float* %1, i64 11
  %678 = load float, float* %677, align 4
  %679 = insertelement <4 x float> %676, float %678, i32 3
  %680 = call <4 x float> @llvm.fma.f32.16(<4 x float> %673, <4 x float> %679, <4 x float> %667)
  %681 = load float, float* %0, align 4
  %682 = insertelement <4 x float> zeroinitializer, float %681, i32 0
  %683 = getelementptr inbounds float, float* %0, i64 1
  %684 = load float, float* %683, align 4
  %685 = insertelement <4 x float> %682, float %684, i32 1
  %686 = getelementptr inbounds float, float* %0, i64 2
  %687 = load float, float* %686, align 4
  %688 = insertelement <4 x float> %685, float %687, i32 2
  %689 = getelementptr inbounds float, float* %0, i64 3
  %690 = load float, float* %689, align 4
  %691 = insertelement <4 x float> %688, float %690, i32 3
  %692 = getelementptr inbounds float, float* %1, i64 3
  %693 = load float, float* %692, align 4
  %694 = insertelement <4 x float> zeroinitializer, float %693, i32 0
  %695 = getelementptr inbounds float, float* %1, i64 7
  %696 = load float, float* %695, align 4
  %697 = insertelement <4 x float> %694, float %696, i32 1
  %698 = getelementptr inbounds float, float* %1, i64 11
  %699 = load float, float* %698, align 4
  %700 = insertelement <4 x float> %697, float %699, i32 2
  %701 = getelementptr inbounds float, float* %1, i64 15
  %702 = load float, float* %701, align 4
  %703 = insertelement <4 x float> %700, float %702, i32 3
  %704 = call <4 x float> @llvm.fma.f32.17(<4 x float> %691, <4 x float> %703, <4 x float> %680)
  %705 = getelementptr inbounds float, float* %0, i64 4
  %706 = load float, float* %705, align 4
  %707 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 0.000000e+00>, float %706, i32 3
  %708 = load float, float* %1, align 4
  %709 = insertelement <4 x float> zeroinitializer, float %708, i32 3
  %710 = fmul <4 x float> %707, %709
  %711 = getelementptr inbounds float, float* %0, i64 4
  %712 = load float, float* %711, align 4
  %713 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %712, i32 2
  %714 = insertelement <4 x float> %713, float 1.000000e+00, i32 3
  %715 = load float, float* %1, align 4
  %716 = insertelement <4 x float> zeroinitializer, float %715, i32 2
  %717 = insertelement <4 x float> %716, float 0.000000e+00, i32 3
  %718 = call <4 x float> @llvm.fma.f32.18(<4 x float> %714, <4 x float> %717, <4 x float> %710)
  %719 = getelementptr inbounds float, float* %0, i64 5
  %720 = load float, float* %719, align 4
  %721 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 0.000000e+00>, float %720, i32 3
  %722 = getelementptr inbounds float, float* %1, i64 4
  %723 = load float, float* %722, align 4
  %724 = insertelement <4 x float> zeroinitializer, float %723, i32 3
  %725 = call <4 x float> @llvm.fma.f32.19(<4 x float> %721, <4 x float> %724, <4 x float> %718)
  %726 = getelementptr inbounds float, float* %0, i64 4
  %727 = load float, float* %726, align 4
  %728 = insertelement <4 x float> zeroinitializer, float %727, i32 1
  %729 = getelementptr inbounds float, float* %0, i64 5
  %730 = load float, float* %729, align 4
  %731 = insertelement <4 x float> %728, float %730, i32 2
  %732 = getelementptr inbounds float, float* %0, i64 6
  %733 = load float, float* %732, align 4
  %734 = insertelement <4 x float> %731, float %733, i32 3
  %735 = load float, float* %1, align 4
  %736 = insertelement <4 x float> zeroinitializer, float %735, i32 1
  %737 = getelementptr inbounds float, float* %1, i64 4
  %738 = load float, float* %737, align 4
  %739 = insertelement <4 x float> %736, float %738, i32 2
  %740 = getelementptr inbounds float, float* %1, i64 8
  %741 = load float, float* %740, align 4
  %742 = insertelement <4 x float> %739, float %741, i32 3
  %743 = call <4 x float> @llvm.fma.f32.20(<4 x float> %734, <4 x float> %742, <4 x float> %725)
  %744 = shufflevector <4 x float> %704, <4 x float> %743, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %745 = getelementptr inbounds float, float* %0, i64 4
  %746 = load float, float* %745, align 4
  %747 = insertelement <4 x float> zeroinitializer, float %746, i32 0
  %748 = insertelement <4 x float> %747, float 1.000000e+00, i32 1
  %749 = insertelement <4 x float> %748, float 1.000000e+00, i32 2
  %750 = insertelement <4 x float> %749, float 1.000000e+00, i32 3
  %751 = load float, float* %1, align 4
  %752 = insertelement <4 x float> zeroinitializer, float %751, i32 0
  %753 = insertelement <4 x float> %752, float 0.000000e+00, i32 1
  %754 = insertelement <4 x float> %753, float 0.000000e+00, i32 2
  %755 = insertelement <4 x float> %754, float 0.000000e+00, i32 3
  %756 = fmul <4 x float> %750, %755
  %757 = fadd <4 x float> %756, zeroinitializer
  %758 = getelementptr inbounds float, float* %0, i64 5
  %759 = load float, float* %758, align 4
  %760 = insertelement <4 x float> zeroinitializer, float %759, i32 0
  %761 = insertelement <4 x float> %760, float 1.000000e+00, i32 1
  %762 = insertelement <4 x float> %761, float 1.000000e+00, i32 2
  %763 = getelementptr inbounds float, float* %0, i64 4
  %764 = load float, float* %763, align 4
  %765 = insertelement <4 x float> %762, float %764, i32 3
  %766 = getelementptr inbounds float, float* %1, i64 4
  %767 = load float, float* %766, align 4
  %768 = insertelement <4 x float> zeroinitializer, float %767, i32 0
  %769 = insertelement <4 x float> %768, float 0.000000e+00, i32 1
  %770 = insertelement <4 x float> %769, float 0.000000e+00, i32 2
  %771 = getelementptr inbounds float, float* %1, i64 1
  %772 = load float, float* %771, align 4
  %773 = insertelement <4 x float> %770, float %772, i32 3
  %774 = call <4 x float> @llvm.fma.f32.21(<4 x float> %765, <4 x float> %773, <4 x float> %757)
  %775 = getelementptr inbounds float, float* %0, i64 6
  %776 = load float, float* %775, align 4
  %777 = insertelement <4 x float> zeroinitializer, float %776, i32 0
  %778 = insertelement <4 x float> %777, float 1.000000e+00, i32 1
  %779 = insertelement <4 x float> %778, float 1.000000e+00, i32 2
  %780 = insertelement <4 x float> %779, float 1.000000e+00, i32 3
  %781 = getelementptr inbounds float, float* %1, i64 8
  %782 = load float, float* %781, align 4
  %783 = insertelement <4 x float> zeroinitializer, float %782, i32 0
  %784 = insertelement <4 x float> %783, float 0.000000e+00, i32 1
  %785 = insertelement <4 x float> %784, float 0.000000e+00, i32 2
  %786 = insertelement <4 x float> %785, float 0.000000e+00, i32 3
  %787 = call <4 x float> @llvm.fma.f32.22(<4 x float> %780, <4 x float> %786, <4 x float> %774)
  %788 = getelementptr inbounds float, float* %0, i64 7
  %789 = load float, float* %788, align 4
  %790 = insertelement <4 x float> zeroinitializer, float %789, i32 0
  %791 = insertelement <4 x float> %790, float 0.000000e+00, i32 1
  %792 = getelementptr inbounds float, float* %0, i64 4
  %793 = load float, float* %792, align 4
  %794 = insertelement <4 x float> %791, float %793, i32 2
  %795 = getelementptr inbounds float, float* %0, i64 5
  %796 = load float, float* %795, align 4
  %797 = insertelement <4 x float> %794, float %796, i32 3
  %798 = getelementptr inbounds float, float* %1, i64 12
  %799 = load float, float* %798, align 4
  %800 = insertelement <4 x float> zeroinitializer, float %799, i32 0
  %801 = insertelement <4 x float> %800, float 0.000000e+00, i32 1
  %802 = getelementptr inbounds float, float* %1, i64 1
  %803 = load float, float* %802, align 4
  %804 = insertelement <4 x float> %801, float %803, i32 2
  %805 = getelementptr inbounds float, float* %1, i64 5
  %806 = load float, float* %805, align 4
  %807 = insertelement <4 x float> %804, float %806, i32 3
  %808 = call <4 x float> @llvm.fma.f32.23(<4 x float> %797, <4 x float> %807, <4 x float> %787)
  %809 = getelementptr inbounds float, float* %0, i64 4
  %810 = load float, float* %809, align 4
  %811 = insertelement <4 x float> <float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %810, i32 1
  %812 = insertelement <4 x float> %811, float 1.000000e+00, i32 2
  %813 = insertelement <4 x float> %812, float 1.000000e+00, i32 3
  %814 = getelementptr inbounds float, float* %1, i64 1
  %815 = load float, float* %814, align 4
  %816 = insertelement <4 x float> zeroinitializer, float %815, i32 1
  %817 = insertelement <4 x float> %816, float 0.000000e+00, i32 2
  %818 = insertelement <4 x float> %817, float 0.000000e+00, i32 3
  %819 = fmul <4 x float> %813, %818
  %820 = getelementptr inbounds float, float* %0, i64 4
  %821 = load float, float* %820, align 4
  %822 = insertelement <4 x float> zeroinitializer, float %821, i32 0
  %823 = insertelement <4 x float> %822, float 1.000000e+00, i32 1
  %824 = insertelement <4 x float> %823, float 1.000000e+00, i32 2
  %825 = insertelement <4 x float> %824, float 1.000000e+00, i32 3
  %826 = getelementptr inbounds float, float* %1, i64 1
  %827 = load float, float* %826, align 4
  %828 = insertelement <4 x float> zeroinitializer, float %827, i32 0
  %829 = insertelement <4 x float> %828, float 0.000000e+00, i32 1
  %830 = insertelement <4 x float> %829, float 0.000000e+00, i32 2
  %831 = insertelement <4 x float> %830, float 0.000000e+00, i32 3
  %832 = call <4 x float> @llvm.fma.f32.24(<4 x float> %825, <4 x float> %831, <4 x float> %819)
  %833 = getelementptr inbounds float, float* %0, i64 5
  %834 = load float, float* %833, align 4
  %835 = insertelement <4 x float> <float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %834, i32 1
  %836 = insertelement <4 x float> %835, float 1.000000e+00, i32 2
  %837 = insertelement <4 x float> %836, float 1.000000e+00, i32 3
  %838 = getelementptr inbounds float, float* %1, i64 5
  %839 = load float, float* %838, align 4
  %840 = insertelement <4 x float> zeroinitializer, float %839, i32 1
  %841 = insertelement <4 x float> %840, float 0.000000e+00, i32 2
  %842 = insertelement <4 x float> %841, float 0.000000e+00, i32 3
  %843 = call <4 x float> @llvm.fma.f32.25(<4 x float> %837, <4 x float> %842, <4 x float> %832)
  %844 = getelementptr inbounds float, float* %0, i64 5
  %845 = load float, float* %844, align 4
  %846 = insertelement <4 x float> zeroinitializer, float %845, i32 0
  %847 = getelementptr inbounds float, float* %0, i64 6
  %848 = load float, float* %847, align 4
  %849 = insertelement <4 x float> %846, float %848, i32 1
  %850 = insertelement <4 x float> %849, float 1.000000e+00, i32 2
  %851 = getelementptr inbounds float, float* %0, i64 4
  %852 = load float, float* %851, align 4
  %853 = insertelement <4 x float> %850, float %852, i32 3
  %854 = getelementptr inbounds float, float* %1, i64 5
  %855 = load float, float* %854, align 4
  %856 = insertelement <4 x float> zeroinitializer, float %855, i32 0
  %857 = getelementptr inbounds float, float* %1, i64 9
  %858 = load float, float* %857, align 4
  %859 = insertelement <4 x float> %856, float %858, i32 1
  %860 = insertelement <4 x float> %859, float 0.000000e+00, i32 2
  %861 = getelementptr inbounds float, float* %1, i64 2
  %862 = load float, float* %861, align 4
  %863 = insertelement <4 x float> %860, float %862, i32 3
  %864 = call <4 x float> @llvm.fma.f32.26(<4 x float> %853, <4 x float> %863, <4 x float> %843)
  %865 = getelementptr inbounds float, float* %0, i64 6
  %866 = load float, float* %865, align 4
  %867 = insertelement <4 x float> zeroinitializer, float %866, i32 0
  %868 = getelementptr inbounds float, float* %0, i64 7
  %869 = load float, float* %868, align 4
  %870 = insertelement <4 x float> %867, float %869, i32 1
  %871 = insertelement <4 x float> %870, float 1.000000e+00, i32 2
  %872 = insertelement <4 x float> %871, float 1.000000e+00, i32 3
  %873 = getelementptr inbounds float, float* %1, i64 9
  %874 = load float, float* %873, align 4
  %875 = insertelement <4 x float> zeroinitializer, float %874, i32 0
  %876 = getelementptr inbounds float, float* %1, i64 13
  %877 = load float, float* %876, align 4
  %878 = insertelement <4 x float> %875, float %877, i32 1
  %879 = insertelement <4 x float> %878, float 0.000000e+00, i32 2
  %880 = insertelement <4 x float> %879, float 0.000000e+00, i32 3
  %881 = call <4 x float> @llvm.fma.f32.27(<4 x float> %872, <4 x float> %880, <4 x float> %864)
  %882 = shufflevector <4 x float> %808, <4 x float> %881, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %883 = shufflevector <8 x float> %744, <8 x float> %882, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %884 = shufflevector <16 x float> %639, <16 x float> %883, <32 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31>
  %885 = getelementptr inbounds float, float* %0, i64 4
  %886 = load float, float* %885, align 4
  %887 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %886, i32 2
  %888 = insertelement <4 x float> %887, float 1.000000e+00, i32 3
  %889 = getelementptr inbounds float, float* %1, i64 2
  %890 = load float, float* %889, align 4
  %891 = insertelement <4 x float> zeroinitializer, float %890, i32 2
  %892 = insertelement <4 x float> %891, float 0.000000e+00, i32 3
  %893 = fmul <4 x float> %888, %892
  %894 = getelementptr inbounds float, float* %0, i64 4
  %895 = load float, float* %894, align 4
  %896 = insertelement <4 x float> <float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %895, i32 1
  %897 = insertelement <4 x float> %896, float 1.000000e+00, i32 2
  %898 = insertelement <4 x float> %897, float 1.000000e+00, i32 3
  %899 = getelementptr inbounds float, float* %1, i64 2
  %900 = load float, float* %899, align 4
  %901 = insertelement <4 x float> zeroinitializer, float %900, i32 1
  %902 = insertelement <4 x float> %901, float 0.000000e+00, i32 2
  %903 = insertelement <4 x float> %902, float 0.000000e+00, i32 3
  %904 = call <4 x float> @llvm.fma.f32.28(<4 x float> %898, <4 x float> %903, <4 x float> %893)
  %905 = getelementptr inbounds float, float* %0, i64 4
  %906 = load float, float* %905, align 4
  %907 = insertelement <4 x float> zeroinitializer, float %906, i32 0
  %908 = insertelement <4 x float> %907, float 1.000000e+00, i32 1
  %909 = getelementptr inbounds float, float* %0, i64 5
  %910 = load float, float* %909, align 4
  %911 = insertelement <4 x float> %908, float %910, i32 2
  %912 = insertelement <4 x float> %911, float 1.000000e+00, i32 3
  %913 = getelementptr inbounds float, float* %1, i64 2
  %914 = load float, float* %913, align 4
  %915 = insertelement <4 x float> zeroinitializer, float %914, i32 0
  %916 = insertelement <4 x float> %915, float 0.000000e+00, i32 1
  %917 = getelementptr inbounds float, float* %1, i64 6
  %918 = load float, float* %917, align 4
  %919 = insertelement <4 x float> %916, float %918, i32 2
  %920 = insertelement <4 x float> %919, float 0.000000e+00, i32 3
  %921 = call <4 x float> @llvm.fma.f32.29(<4 x float> %912, <4 x float> %920, <4 x float> %904)
  %922 = getelementptr inbounds float, float* %0, i64 5
  %923 = load float, float* %922, align 4
  %924 = insertelement <4 x float> <float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %923, i32 1
  %925 = getelementptr inbounds float, float* %0, i64 6
  %926 = load float, float* %925, align 4
  %927 = insertelement <4 x float> %924, float %926, i32 2
  %928 = insertelement <4 x float> %927, float 1.000000e+00, i32 3
  %929 = getelementptr inbounds float, float* %1, i64 6
  %930 = load float, float* %929, align 4
  %931 = insertelement <4 x float> zeroinitializer, float %930, i32 1
  %932 = getelementptr inbounds float, float* %1, i64 10
  %933 = load float, float* %932, align 4
  %934 = insertelement <4 x float> %931, float %933, i32 2
  %935 = insertelement <4 x float> %934, float 0.000000e+00, i32 3
  %936 = call <4 x float> @llvm.fma.f32.30(<4 x float> %928, <4 x float> %935, <4 x float> %921)
  %937 = getelementptr inbounds float, float* %0, i64 5
  %938 = load float, float* %937, align 4
  %939 = insertelement <4 x float> zeroinitializer, float %938, i32 0
  %940 = getelementptr inbounds float, float* %0, i64 6
  %941 = load float, float* %940, align 4
  %942 = insertelement <4 x float> %939, float %941, i32 1
  %943 = getelementptr inbounds float, float* %0, i64 7
  %944 = load float, float* %943, align 4
  %945 = insertelement <4 x float> %942, float %944, i32 2
  %946 = insertelement <4 x float> %945, float 0.000000e+00, i32 3
  %947 = getelementptr inbounds float, float* %1, i64 6
  %948 = load float, float* %947, align 4
  %949 = insertelement <4 x float> zeroinitializer, float %948, i32 0
  %950 = getelementptr inbounds float, float* %1, i64 10
  %951 = load float, float* %950, align 4
  %952 = insertelement <4 x float> %949, float %951, i32 1
  %953 = getelementptr inbounds float, float* %1, i64 14
  %954 = load float, float* %953, align 4
  %955 = insertelement <4 x float> %952, float %954, i32 2
  %956 = insertelement <4 x float> %955, float 0.000000e+00, i32 3
  %957 = call <4 x float> @llvm.fma.f32.31(<4 x float> %946, <4 x float> %956, <4 x float> %936)
  %958 = getelementptr inbounds float, float* %0, i64 4
  %959 = load float, float* %958, align 4
  %960 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 0.000000e+00>, float %959, i32 3
  %961 = getelementptr inbounds float, float* %1, i64 3
  %962 = load float, float* %961, align 4
  %963 = insertelement <4 x float> zeroinitializer, float %962, i32 3
  %964 = fmul <4 x float> %960, %963
  %965 = getelementptr inbounds float, float* %0, i64 4
  %966 = load float, float* %965, align 4
  %967 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %966, i32 2
  %968 = insertelement <4 x float> %967, float 1.000000e+00, i32 3
  %969 = getelementptr inbounds float, float* %1, i64 3
  %970 = load float, float* %969, align 4
  %971 = insertelement <4 x float> zeroinitializer, float %970, i32 2
  %972 = insertelement <4 x float> %971, float 0.000000e+00, i32 3
  %973 = call <4 x float> @llvm.fma.f32.32(<4 x float> %968, <4 x float> %972, <4 x float> %964)
  %974 = getelementptr inbounds float, float* %0, i64 4
  %975 = load float, float* %974, align 4
  %976 = insertelement <4 x float> <float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %975, i32 1
  %977 = insertelement <4 x float> %976, float 1.000000e+00, i32 2
  %978 = getelementptr inbounds float, float* %0, i64 5
  %979 = load float, float* %978, align 4
  %980 = insertelement <4 x float> %977, float %979, i32 3
  %981 = getelementptr inbounds float, float* %1, i64 3
  %982 = load float, float* %981, align 4
  %983 = insertelement <4 x float> zeroinitializer, float %982, i32 1
  %984 = insertelement <4 x float> %983, float 0.000000e+00, i32 2
  %985 = getelementptr inbounds float, float* %1, i64 7
  %986 = load float, float* %985, align 4
  %987 = insertelement <4 x float> %984, float %986, i32 3
  %988 = call <4 x float> @llvm.fma.f32.33(<4 x float> %980, <4 x float> %987, <4 x float> %973)
  %989 = getelementptr inbounds float, float* %0, i64 5
  %990 = load float, float* %989, align 4
  %991 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %990, i32 2
  %992 = getelementptr inbounds float, float* %0, i64 6
  %993 = load float, float* %992, align 4
  %994 = insertelement <4 x float> %991, float %993, i32 3
  %995 = getelementptr inbounds float, float* %1, i64 7
  %996 = load float, float* %995, align 4
  %997 = insertelement <4 x float> zeroinitializer, float %996, i32 2
  %998 = getelementptr inbounds float, float* %1, i64 11
  %999 = load float, float* %998, align 4
  %1000 = insertelement <4 x float> %997, float %999, i32 3
  %1001 = call <4 x float> @llvm.fma.f32.34(<4 x float> %994, <4 x float> %1000, <4 x float> %988)
  %1002 = getelementptr inbounds float, float* %0, i64 4
  %1003 = load float, float* %1002, align 4
  %1004 = insertelement <4 x float> zeroinitializer, float %1003, i32 0
  %1005 = getelementptr inbounds float, float* %0, i64 5
  %1006 = load float, float* %1005, align 4
  %1007 = insertelement <4 x float> %1004, float %1006, i32 1
  %1008 = getelementptr inbounds float, float* %0, i64 6
  %1009 = load float, float* %1008, align 4
  %1010 = insertelement <4 x float> %1007, float %1009, i32 2
  %1011 = getelementptr inbounds float, float* %0, i64 7
  %1012 = load float, float* %1011, align 4
  %1013 = insertelement <4 x float> %1010, float %1012, i32 3
  %1014 = getelementptr inbounds float, float* %1, i64 3
  %1015 = load float, float* %1014, align 4
  %1016 = insertelement <4 x float> zeroinitializer, float %1015, i32 0
  %1017 = getelementptr inbounds float, float* %1, i64 7
  %1018 = load float, float* %1017, align 4
  %1019 = insertelement <4 x float> %1016, float %1018, i32 1
  %1020 = getelementptr inbounds float, float* %1, i64 11
  %1021 = load float, float* %1020, align 4
  %1022 = insertelement <4 x float> %1019, float %1021, i32 2
  %1023 = getelementptr inbounds float, float* %1, i64 15
  %1024 = load float, float* %1023, align 4
  %1025 = insertelement <4 x float> %1022, float %1024, i32 3
  %1026 = call <4 x float> @llvm.fma.f32.35(<4 x float> %1013, <4 x float> %1025, <4 x float> %1001)
  %1027 = shufflevector <4 x float> %957, <4 x float> %1026, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %1028 = getelementptr inbounds float, float* %0, i64 8
  %1029 = load float, float* %1028, align 4
  %1030 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 0.000000e+00>, float %1029, i32 3
  %1031 = load float, float* %1, align 4
  %1032 = insertelement <4 x float> zeroinitializer, float %1031, i32 3
  %1033 = fmul <4 x float> %1030, %1032
  %1034 = getelementptr inbounds float, float* %0, i64 8
  %1035 = load float, float* %1034, align 4
  %1036 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %1035, i32 2
  %1037 = insertelement <4 x float> %1036, float 1.000000e+00, i32 3
  %1038 = load float, float* %1, align 4
  %1039 = insertelement <4 x float> zeroinitializer, float %1038, i32 2
  %1040 = insertelement <4 x float> %1039, float 0.000000e+00, i32 3
  %1041 = call <4 x float> @llvm.fma.f32.36(<4 x float> %1037, <4 x float> %1040, <4 x float> %1033)
  %1042 = getelementptr inbounds float, float* %0, i64 9
  %1043 = load float, float* %1042, align 4
  %1044 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 0.000000e+00>, float %1043, i32 3
  %1045 = getelementptr inbounds float, float* %1, i64 4
  %1046 = load float, float* %1045, align 4
  %1047 = insertelement <4 x float> zeroinitializer, float %1046, i32 3
  %1048 = call <4 x float> @llvm.fma.f32.37(<4 x float> %1044, <4 x float> %1047, <4 x float> %1041)
  %1049 = getelementptr inbounds float, float* %0, i64 8
  %1050 = load float, float* %1049, align 4
  %1051 = insertelement <4 x float> zeroinitializer, float %1050, i32 1
  %1052 = getelementptr inbounds float, float* %0, i64 9
  %1053 = load float, float* %1052, align 4
  %1054 = insertelement <4 x float> %1051, float %1053, i32 2
  %1055 = getelementptr inbounds float, float* %0, i64 10
  %1056 = load float, float* %1055, align 4
  %1057 = insertelement <4 x float> %1054, float %1056, i32 3
  %1058 = load float, float* %1, align 4
  %1059 = insertelement <4 x float> zeroinitializer, float %1058, i32 1
  %1060 = getelementptr inbounds float, float* %1, i64 4
  %1061 = load float, float* %1060, align 4
  %1062 = insertelement <4 x float> %1059, float %1061, i32 2
  %1063 = getelementptr inbounds float, float* %1, i64 8
  %1064 = load float, float* %1063, align 4
  %1065 = insertelement <4 x float> %1062, float %1064, i32 3
  %1066 = call <4 x float> @llvm.fma.f32.38(<4 x float> %1057, <4 x float> %1065, <4 x float> %1048)
  %1067 = getelementptr inbounds float, float* %0, i64 8
  %1068 = load float, float* %1067, align 4
  %1069 = insertelement <4 x float> zeroinitializer, float %1068, i32 0
  %1070 = insertelement <4 x float> %1069, float 1.000000e+00, i32 1
  %1071 = insertelement <4 x float> %1070, float 1.000000e+00, i32 2
  %1072 = insertelement <4 x float> %1071, float 1.000000e+00, i32 3
  %1073 = load float, float* %1, align 4
  %1074 = insertelement <4 x float> zeroinitializer, float %1073, i32 0
  %1075 = insertelement <4 x float> %1074, float 0.000000e+00, i32 1
  %1076 = insertelement <4 x float> %1075, float 0.000000e+00, i32 2
  %1077 = insertelement <4 x float> %1076, float 0.000000e+00, i32 3
  %1078 = fmul <4 x float> %1072, %1077
  %1079 = fadd <4 x float> %1078, zeroinitializer
  %1080 = getelementptr inbounds float, float* %0, i64 9
  %1081 = load float, float* %1080, align 4
  %1082 = insertelement <4 x float> zeroinitializer, float %1081, i32 0
  %1083 = insertelement <4 x float> %1082, float 1.000000e+00, i32 1
  %1084 = insertelement <4 x float> %1083, float 1.000000e+00, i32 2
  %1085 = getelementptr inbounds float, float* %0, i64 8
  %1086 = load float, float* %1085, align 4
  %1087 = insertelement <4 x float> %1084, float %1086, i32 3
  %1088 = getelementptr inbounds float, float* %1, i64 4
  %1089 = load float, float* %1088, align 4
  %1090 = insertelement <4 x float> zeroinitializer, float %1089, i32 0
  %1091 = insertelement <4 x float> %1090, float 0.000000e+00, i32 1
  %1092 = insertelement <4 x float> %1091, float 0.000000e+00, i32 2
  %1093 = getelementptr inbounds float, float* %1, i64 1
  %1094 = load float, float* %1093, align 4
  %1095 = insertelement <4 x float> %1092, float %1094, i32 3
  %1096 = call <4 x float> @llvm.fma.f32.39(<4 x float> %1087, <4 x float> %1095, <4 x float> %1079)
  %1097 = getelementptr inbounds float, float* %0, i64 10
  %1098 = load float, float* %1097, align 4
  %1099 = insertelement <4 x float> zeroinitializer, float %1098, i32 0
  %1100 = insertelement <4 x float> %1099, float 1.000000e+00, i32 1
  %1101 = insertelement <4 x float> %1100, float 1.000000e+00, i32 2
  %1102 = insertelement <4 x float> %1101, float 1.000000e+00, i32 3
  %1103 = getelementptr inbounds float, float* %1, i64 8
  %1104 = load float, float* %1103, align 4
  %1105 = insertelement <4 x float> zeroinitializer, float %1104, i32 0
  %1106 = insertelement <4 x float> %1105, float 0.000000e+00, i32 1
  %1107 = insertelement <4 x float> %1106, float 0.000000e+00, i32 2
  %1108 = insertelement <4 x float> %1107, float 0.000000e+00, i32 3
  %1109 = call <4 x float> @llvm.fma.f32.40(<4 x float> %1102, <4 x float> %1108, <4 x float> %1096)
  %1110 = getelementptr inbounds float, float* %0, i64 11
  %1111 = load float, float* %1110, align 4
  %1112 = insertelement <4 x float> zeroinitializer, float %1111, i32 0
  %1113 = insertelement <4 x float> %1112, float 0.000000e+00, i32 1
  %1114 = getelementptr inbounds float, float* %0, i64 8
  %1115 = load float, float* %1114, align 4
  %1116 = insertelement <4 x float> %1113, float %1115, i32 2
  %1117 = getelementptr inbounds float, float* %0, i64 9
  %1118 = load float, float* %1117, align 4
  %1119 = insertelement <4 x float> %1116, float %1118, i32 3
  %1120 = getelementptr inbounds float, float* %1, i64 12
  %1121 = load float, float* %1120, align 4
  %1122 = insertelement <4 x float> zeroinitializer, float %1121, i32 0
  %1123 = insertelement <4 x float> %1122, float 0.000000e+00, i32 1
  %1124 = getelementptr inbounds float, float* %1, i64 1
  %1125 = load float, float* %1124, align 4
  %1126 = insertelement <4 x float> %1123, float %1125, i32 2
  %1127 = getelementptr inbounds float, float* %1, i64 5
  %1128 = load float, float* %1127, align 4
  %1129 = insertelement <4 x float> %1126, float %1128, i32 3
  %1130 = call <4 x float> @llvm.fma.f32.41(<4 x float> %1119, <4 x float> %1129, <4 x float> %1109)
  %1131 = shufflevector <4 x float> %1066, <4 x float> %1130, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %1132 = shufflevector <8 x float> %1027, <8 x float> %1131, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %1133 = getelementptr inbounds float, float* %0, i64 8
  %1134 = load float, float* %1133, align 4
  %1135 = insertelement <4 x float> <float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %1134, i32 1
  %1136 = insertelement <4 x float> %1135, float 1.000000e+00, i32 2
  %1137 = insertelement <4 x float> %1136, float 1.000000e+00, i32 3
  %1138 = getelementptr inbounds float, float* %1, i64 1
  %1139 = load float, float* %1138, align 4
  %1140 = insertelement <4 x float> zeroinitializer, float %1139, i32 1
  %1141 = insertelement <4 x float> %1140, float 0.000000e+00, i32 2
  %1142 = insertelement <4 x float> %1141, float 0.000000e+00, i32 3
  %1143 = fmul <4 x float> %1137, %1142
  %1144 = getelementptr inbounds float, float* %0, i64 8
  %1145 = load float, float* %1144, align 4
  %1146 = insertelement <4 x float> zeroinitializer, float %1145, i32 0
  %1147 = insertelement <4 x float> %1146, float 1.000000e+00, i32 1
  %1148 = insertelement <4 x float> %1147, float 1.000000e+00, i32 2
  %1149 = insertelement <4 x float> %1148, float 1.000000e+00, i32 3
  %1150 = getelementptr inbounds float, float* %1, i64 1
  %1151 = load float, float* %1150, align 4
  %1152 = insertelement <4 x float> zeroinitializer, float %1151, i32 0
  %1153 = insertelement <4 x float> %1152, float 0.000000e+00, i32 1
  %1154 = insertelement <4 x float> %1153, float 0.000000e+00, i32 2
  %1155 = insertelement <4 x float> %1154, float 0.000000e+00, i32 3
  %1156 = call <4 x float> @llvm.fma.f32.42(<4 x float> %1149, <4 x float> %1155, <4 x float> %1143)
  %1157 = getelementptr inbounds float, float* %0, i64 9
  %1158 = load float, float* %1157, align 4
  %1159 = insertelement <4 x float> <float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %1158, i32 1
  %1160 = insertelement <4 x float> %1159, float 1.000000e+00, i32 2
  %1161 = insertelement <4 x float> %1160, float 1.000000e+00, i32 3
  %1162 = getelementptr inbounds float, float* %1, i64 5
  %1163 = load float, float* %1162, align 4
  %1164 = insertelement <4 x float> zeroinitializer, float %1163, i32 1
  %1165 = insertelement <4 x float> %1164, float 0.000000e+00, i32 2
  %1166 = insertelement <4 x float> %1165, float 0.000000e+00, i32 3
  %1167 = call <4 x float> @llvm.fma.f32.43(<4 x float> %1161, <4 x float> %1166, <4 x float> %1156)
  %1168 = getelementptr inbounds float, float* %0, i64 9
  %1169 = load float, float* %1168, align 4
  %1170 = insertelement <4 x float> zeroinitializer, float %1169, i32 0
  %1171 = getelementptr inbounds float, float* %0, i64 10
  %1172 = load float, float* %1171, align 4
  %1173 = insertelement <4 x float> %1170, float %1172, i32 1
  %1174 = insertelement <4 x float> %1173, float 1.000000e+00, i32 2
  %1175 = getelementptr inbounds float, float* %0, i64 8
  %1176 = load float, float* %1175, align 4
  %1177 = insertelement <4 x float> %1174, float %1176, i32 3
  %1178 = getelementptr inbounds float, float* %1, i64 5
  %1179 = load float, float* %1178, align 4
  %1180 = insertelement <4 x float> zeroinitializer, float %1179, i32 0
  %1181 = getelementptr inbounds float, float* %1, i64 9
  %1182 = load float, float* %1181, align 4
  %1183 = insertelement <4 x float> %1180, float %1182, i32 1
  %1184 = insertelement <4 x float> %1183, float 0.000000e+00, i32 2
  %1185 = getelementptr inbounds float, float* %1, i64 2
  %1186 = load float, float* %1185, align 4
  %1187 = insertelement <4 x float> %1184, float %1186, i32 3
  %1188 = call <4 x float> @llvm.fma.f32.44(<4 x float> %1177, <4 x float> %1187, <4 x float> %1167)
  %1189 = getelementptr inbounds float, float* %0, i64 10
  %1190 = load float, float* %1189, align 4
  %1191 = insertelement <4 x float> zeroinitializer, float %1190, i32 0
  %1192 = getelementptr inbounds float, float* %0, i64 11
  %1193 = load float, float* %1192, align 4
  %1194 = insertelement <4 x float> %1191, float %1193, i32 1
  %1195 = insertelement <4 x float> %1194, float 1.000000e+00, i32 2
  %1196 = insertelement <4 x float> %1195, float 1.000000e+00, i32 3
  %1197 = getelementptr inbounds float, float* %1, i64 9
  %1198 = load float, float* %1197, align 4
  %1199 = insertelement <4 x float> zeroinitializer, float %1198, i32 0
  %1200 = getelementptr inbounds float, float* %1, i64 13
  %1201 = load float, float* %1200, align 4
  %1202 = insertelement <4 x float> %1199, float %1201, i32 1
  %1203 = insertelement <4 x float> %1202, float 0.000000e+00, i32 2
  %1204 = insertelement <4 x float> %1203, float 0.000000e+00, i32 3
  %1205 = call <4 x float> @llvm.fma.f32.45(<4 x float> %1196, <4 x float> %1204, <4 x float> %1188)
  %1206 = getelementptr inbounds float, float* %0, i64 8
  %1207 = load float, float* %1206, align 4
  %1208 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %1207, i32 2
  %1209 = insertelement <4 x float> %1208, float 1.000000e+00, i32 3
  %1210 = getelementptr inbounds float, float* %1, i64 2
  %1211 = load float, float* %1210, align 4
  %1212 = insertelement <4 x float> zeroinitializer, float %1211, i32 2
  %1213 = insertelement <4 x float> %1212, float 0.000000e+00, i32 3
  %1214 = fmul <4 x float> %1209, %1213
  %1215 = getelementptr inbounds float, float* %0, i64 8
  %1216 = load float, float* %1215, align 4
  %1217 = insertelement <4 x float> <float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %1216, i32 1
  %1218 = insertelement <4 x float> %1217, float 1.000000e+00, i32 2
  %1219 = insertelement <4 x float> %1218, float 1.000000e+00, i32 3
  %1220 = getelementptr inbounds float, float* %1, i64 2
  %1221 = load float, float* %1220, align 4
  %1222 = insertelement <4 x float> zeroinitializer, float %1221, i32 1
  %1223 = insertelement <4 x float> %1222, float 0.000000e+00, i32 2
  %1224 = insertelement <4 x float> %1223, float 0.000000e+00, i32 3
  %1225 = call <4 x float> @llvm.fma.f32.46(<4 x float> %1219, <4 x float> %1224, <4 x float> %1214)
  %1226 = getelementptr inbounds float, float* %0, i64 8
  %1227 = load float, float* %1226, align 4
  %1228 = insertelement <4 x float> zeroinitializer, float %1227, i32 0
  %1229 = insertelement <4 x float> %1228, float 1.000000e+00, i32 1
  %1230 = getelementptr inbounds float, float* %0, i64 9
  %1231 = load float, float* %1230, align 4
  %1232 = insertelement <4 x float> %1229, float %1231, i32 2
  %1233 = insertelement <4 x float> %1232, float 1.000000e+00, i32 3
  %1234 = getelementptr inbounds float, float* %1, i64 2
  %1235 = load float, float* %1234, align 4
  %1236 = insertelement <4 x float> zeroinitializer, float %1235, i32 0
  %1237 = insertelement <4 x float> %1236, float 0.000000e+00, i32 1
  %1238 = getelementptr inbounds float, float* %1, i64 6
  %1239 = load float, float* %1238, align 4
  %1240 = insertelement <4 x float> %1237, float %1239, i32 2
  %1241 = insertelement <4 x float> %1240, float 0.000000e+00, i32 3
  %1242 = call <4 x float> @llvm.fma.f32.47(<4 x float> %1233, <4 x float> %1241, <4 x float> %1225)
  %1243 = getelementptr inbounds float, float* %0, i64 9
  %1244 = load float, float* %1243, align 4
  %1245 = insertelement <4 x float> <float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %1244, i32 1
  %1246 = getelementptr inbounds float, float* %0, i64 10
  %1247 = load float, float* %1246, align 4
  %1248 = insertelement <4 x float> %1245, float %1247, i32 2
  %1249 = insertelement <4 x float> %1248, float 1.000000e+00, i32 3
  %1250 = getelementptr inbounds float, float* %1, i64 6
  %1251 = load float, float* %1250, align 4
  %1252 = insertelement <4 x float> zeroinitializer, float %1251, i32 1
  %1253 = getelementptr inbounds float, float* %1, i64 10
  %1254 = load float, float* %1253, align 4
  %1255 = insertelement <4 x float> %1252, float %1254, i32 2
  %1256 = insertelement <4 x float> %1255, float 0.000000e+00, i32 3
  %1257 = call <4 x float> @llvm.fma.f32.48(<4 x float> %1249, <4 x float> %1256, <4 x float> %1242)
  %1258 = getelementptr inbounds float, float* %0, i64 9
  %1259 = load float, float* %1258, align 4
  %1260 = insertelement <4 x float> zeroinitializer, float %1259, i32 0
  %1261 = getelementptr inbounds float, float* %0, i64 10
  %1262 = load float, float* %1261, align 4
  %1263 = insertelement <4 x float> %1260, float %1262, i32 1
  %1264 = getelementptr inbounds float, float* %0, i64 11
  %1265 = load float, float* %1264, align 4
  %1266 = insertelement <4 x float> %1263, float %1265, i32 2
  %1267 = insertelement <4 x float> %1266, float 0.000000e+00, i32 3
  %1268 = getelementptr inbounds float, float* %1, i64 6
  %1269 = load float, float* %1268, align 4
  %1270 = insertelement <4 x float> zeroinitializer, float %1269, i32 0
  %1271 = getelementptr inbounds float, float* %1, i64 10
  %1272 = load float, float* %1271, align 4
  %1273 = insertelement <4 x float> %1270, float %1272, i32 1
  %1274 = getelementptr inbounds float, float* %1, i64 14
  %1275 = load float, float* %1274, align 4
  %1276 = insertelement <4 x float> %1273, float %1275, i32 2
  %1277 = insertelement <4 x float> %1276, float 0.000000e+00, i32 3
  %1278 = call <4 x float> @llvm.fma.f32.49(<4 x float> %1267, <4 x float> %1277, <4 x float> %1257)
  %1279 = shufflevector <4 x float> %1205, <4 x float> %1278, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %1280 = getelementptr inbounds float, float* %0, i64 8
  %1281 = load float, float* %1280, align 4
  %1282 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 0.000000e+00>, float %1281, i32 3
  %1283 = getelementptr inbounds float, float* %1, i64 3
  %1284 = load float, float* %1283, align 4
  %1285 = insertelement <4 x float> zeroinitializer, float %1284, i32 3
  %1286 = fmul <4 x float> %1282, %1285
  %1287 = getelementptr inbounds float, float* %0, i64 8
  %1288 = load float, float* %1287, align 4
  %1289 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %1288, i32 2
  %1290 = insertelement <4 x float> %1289, float 1.000000e+00, i32 3
  %1291 = getelementptr inbounds float, float* %1, i64 3
  %1292 = load float, float* %1291, align 4
  %1293 = insertelement <4 x float> zeroinitializer, float %1292, i32 2
  %1294 = insertelement <4 x float> %1293, float 0.000000e+00, i32 3
  %1295 = call <4 x float> @llvm.fma.f32.50(<4 x float> %1290, <4 x float> %1294, <4 x float> %1286)
  %1296 = getelementptr inbounds float, float* %0, i64 8
  %1297 = load float, float* %1296, align 4
  %1298 = insertelement <4 x float> <float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %1297, i32 1
  %1299 = insertelement <4 x float> %1298, float 1.000000e+00, i32 2
  %1300 = getelementptr inbounds float, float* %0, i64 9
  %1301 = load float, float* %1300, align 4
  %1302 = insertelement <4 x float> %1299, float %1301, i32 3
  %1303 = getelementptr inbounds float, float* %1, i64 3
  %1304 = load float, float* %1303, align 4
  %1305 = insertelement <4 x float> zeroinitializer, float %1304, i32 1
  %1306 = insertelement <4 x float> %1305, float 0.000000e+00, i32 2
  %1307 = getelementptr inbounds float, float* %1, i64 7
  %1308 = load float, float* %1307, align 4
  %1309 = insertelement <4 x float> %1306, float %1308, i32 3
  %1310 = call <4 x float> @llvm.fma.f32.51(<4 x float> %1302, <4 x float> %1309, <4 x float> %1295)
  %1311 = getelementptr inbounds float, float* %0, i64 9
  %1312 = load float, float* %1311, align 4
  %1313 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %1312, i32 2
  %1314 = getelementptr inbounds float, float* %0, i64 10
  %1315 = load float, float* %1314, align 4
  %1316 = insertelement <4 x float> %1313, float %1315, i32 3
  %1317 = getelementptr inbounds float, float* %1, i64 7
  %1318 = load float, float* %1317, align 4
  %1319 = insertelement <4 x float> zeroinitializer, float %1318, i32 2
  %1320 = getelementptr inbounds float, float* %1, i64 11
  %1321 = load float, float* %1320, align 4
  %1322 = insertelement <4 x float> %1319, float %1321, i32 3
  %1323 = call <4 x float> @llvm.fma.f32.52(<4 x float> %1316, <4 x float> %1322, <4 x float> %1310)
  %1324 = getelementptr inbounds float, float* %0, i64 8
  %1325 = load float, float* %1324, align 4
  %1326 = insertelement <4 x float> zeroinitializer, float %1325, i32 0
  %1327 = getelementptr inbounds float, float* %0, i64 9
  %1328 = load float, float* %1327, align 4
  %1329 = insertelement <4 x float> %1326, float %1328, i32 1
  %1330 = getelementptr inbounds float, float* %0, i64 10
  %1331 = load float, float* %1330, align 4
  %1332 = insertelement <4 x float> %1329, float %1331, i32 2
  %1333 = getelementptr inbounds float, float* %0, i64 11
  %1334 = load float, float* %1333, align 4
  %1335 = insertelement <4 x float> %1332, float %1334, i32 3
  %1336 = getelementptr inbounds float, float* %1, i64 3
  %1337 = load float, float* %1336, align 4
  %1338 = insertelement <4 x float> zeroinitializer, float %1337, i32 0
  %1339 = getelementptr inbounds float, float* %1, i64 7
  %1340 = load float, float* %1339, align 4
  %1341 = insertelement <4 x float> %1338, float %1340, i32 1
  %1342 = getelementptr inbounds float, float* %1, i64 11
  %1343 = load float, float* %1342, align 4
  %1344 = insertelement <4 x float> %1341, float %1343, i32 2
  %1345 = getelementptr inbounds float, float* %1, i64 15
  %1346 = load float, float* %1345, align 4
  %1347 = insertelement <4 x float> %1344, float %1346, i32 3
  %1348 = call <4 x float> @llvm.fma.f32.53(<4 x float> %1335, <4 x float> %1347, <4 x float> %1323)
  %1349 = getelementptr inbounds float, float* %0, i64 12
  %1350 = load float, float* %1349, align 4
  %1351 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 0.000000e+00>, float %1350, i32 3
  %1352 = load float, float* %1, align 4
  %1353 = insertelement <4 x float> zeroinitializer, float %1352, i32 3
  %1354 = fmul <4 x float> %1351, %1353
  %1355 = getelementptr inbounds float, float* %0, i64 12
  %1356 = load float, float* %1355, align 4
  %1357 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %1356, i32 2
  %1358 = insertelement <4 x float> %1357, float 1.000000e+00, i32 3
  %1359 = load float, float* %1, align 4
  %1360 = insertelement <4 x float> zeroinitializer, float %1359, i32 2
  %1361 = insertelement <4 x float> %1360, float 0.000000e+00, i32 3
  %1362 = call <4 x float> @llvm.fma.f32.54(<4 x float> %1358, <4 x float> %1361, <4 x float> %1354)
  %1363 = getelementptr inbounds float, float* %0, i64 13
  %1364 = load float, float* %1363, align 4
  %1365 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 0.000000e+00>, float %1364, i32 3
  %1366 = getelementptr inbounds float, float* %1, i64 4
  %1367 = load float, float* %1366, align 4
  %1368 = insertelement <4 x float> zeroinitializer, float %1367, i32 3
  %1369 = call <4 x float> @llvm.fma.f32.55(<4 x float> %1365, <4 x float> %1368, <4 x float> %1362)
  %1370 = getelementptr inbounds float, float* %0, i64 12
  %1371 = load float, float* %1370, align 4
  %1372 = insertelement <4 x float> zeroinitializer, float %1371, i32 1
  %1373 = getelementptr inbounds float, float* %0, i64 13
  %1374 = load float, float* %1373, align 4
  %1375 = insertelement <4 x float> %1372, float %1374, i32 2
  %1376 = getelementptr inbounds float, float* %0, i64 14
  %1377 = load float, float* %1376, align 4
  %1378 = insertelement <4 x float> %1375, float %1377, i32 3
  %1379 = load float, float* %1, align 4
  %1380 = insertelement <4 x float> zeroinitializer, float %1379, i32 1
  %1381 = getelementptr inbounds float, float* %1, i64 4
  %1382 = load float, float* %1381, align 4
  %1383 = insertelement <4 x float> %1380, float %1382, i32 2
  %1384 = getelementptr inbounds float, float* %1, i64 8
  %1385 = load float, float* %1384, align 4
  %1386 = insertelement <4 x float> %1383, float %1385, i32 3
  %1387 = call <4 x float> @llvm.fma.f32.56(<4 x float> %1378, <4 x float> %1386, <4 x float> %1369)
  %1388 = shufflevector <4 x float> %1348, <4 x float> %1387, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %1389 = shufflevector <8 x float> %1279, <8 x float> %1388, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %1390 = shufflevector <16 x float> %1132, <16 x float> %1389, <32 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31>
  %1391 = shufflevector <32 x float> %884, <32 x float> %1390, <64 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31, i32 32, i32 33, i32 34, i32 35, i32 36, i32 37, i32 38, i32 39, i32 40, i32 41, i32 42, i32 43, i32 44, i32 45, i32 46, i32 47, i32 48, i32 49, i32 50, i32 51, i32 52, i32 53, i32 54, i32 55, i32 56, i32 57, i32 58, i32 59, i32 60, i32 61, i32 62, i32 63>
  %1392 = getelementptr inbounds float, float* %0, i64 12
  %1393 = load float, float* %1392, align 4
  %1394 = insertelement <4 x float> zeroinitializer, float %1393, i32 0
  %1395 = insertelement <4 x float> %1394, float 1.000000e+00, i32 1
  %1396 = insertelement <4 x float> %1395, float 1.000000e+00, i32 2
  %1397 = insertelement <4 x float> %1396, float 1.000000e+00, i32 3
  %1398 = load float, float* %1, align 4
  %1399 = insertelement <4 x float> zeroinitializer, float %1398, i32 0
  %1400 = insertelement <4 x float> %1399, float 0.000000e+00, i32 1
  %1401 = insertelement <4 x float> %1400, float 0.000000e+00, i32 2
  %1402 = insertelement <4 x float> %1401, float 0.000000e+00, i32 3
  %1403 = fmul <4 x float> %1397, %1402
  %1404 = fadd <4 x float> %1403, zeroinitializer
  %1405 = getelementptr inbounds float, float* %0, i64 13
  %1406 = load float, float* %1405, align 4
  %1407 = insertelement <4 x float> zeroinitializer, float %1406, i32 0
  %1408 = insertelement <4 x float> %1407, float 1.000000e+00, i32 1
  %1409 = insertelement <4 x float> %1408, float 1.000000e+00, i32 2
  %1410 = getelementptr inbounds float, float* %0, i64 12
  %1411 = load float, float* %1410, align 4
  %1412 = insertelement <4 x float> %1409, float %1411, i32 3
  %1413 = getelementptr inbounds float, float* %1, i64 4
  %1414 = load float, float* %1413, align 4
  %1415 = insertelement <4 x float> zeroinitializer, float %1414, i32 0
  %1416 = insertelement <4 x float> %1415, float 0.000000e+00, i32 1
  %1417 = insertelement <4 x float> %1416, float 0.000000e+00, i32 2
  %1418 = getelementptr inbounds float, float* %1, i64 1
  %1419 = load float, float* %1418, align 4
  %1420 = insertelement <4 x float> %1417, float %1419, i32 3
  %1421 = call <4 x float> @llvm.fma.f32.57(<4 x float> %1412, <4 x float> %1420, <4 x float> %1404)
  %1422 = getelementptr inbounds float, float* %0, i64 14
  %1423 = load float, float* %1422, align 4
  %1424 = insertelement <4 x float> zeroinitializer, float %1423, i32 0
  %1425 = insertelement <4 x float> %1424, float 1.000000e+00, i32 1
  %1426 = insertelement <4 x float> %1425, float 1.000000e+00, i32 2
  %1427 = insertelement <4 x float> %1426, float 1.000000e+00, i32 3
  %1428 = getelementptr inbounds float, float* %1, i64 8
  %1429 = load float, float* %1428, align 4
  %1430 = insertelement <4 x float> zeroinitializer, float %1429, i32 0
  %1431 = insertelement <4 x float> %1430, float 0.000000e+00, i32 1
  %1432 = insertelement <4 x float> %1431, float 0.000000e+00, i32 2
  %1433 = insertelement <4 x float> %1432, float 0.000000e+00, i32 3
  %1434 = call <4 x float> @llvm.fma.f32.58(<4 x float> %1427, <4 x float> %1433, <4 x float> %1421)
  %1435 = getelementptr inbounds float, float* %0, i64 15
  %1436 = load float, float* %1435, align 4
  %1437 = insertelement <4 x float> zeroinitializer, float %1436, i32 0
  %1438 = insertelement <4 x float> %1437, float 0.000000e+00, i32 1
  %1439 = getelementptr inbounds float, float* %0, i64 12
  %1440 = load float, float* %1439, align 4
  %1441 = insertelement <4 x float> %1438, float %1440, i32 2
  %1442 = getelementptr inbounds float, float* %0, i64 13
  %1443 = load float, float* %1442, align 4
  %1444 = insertelement <4 x float> %1441, float %1443, i32 3
  %1445 = getelementptr inbounds float, float* %1, i64 12
  %1446 = load float, float* %1445, align 4
  %1447 = insertelement <4 x float> zeroinitializer, float %1446, i32 0
  %1448 = insertelement <4 x float> %1447, float 0.000000e+00, i32 1
  %1449 = getelementptr inbounds float, float* %1, i64 1
  %1450 = load float, float* %1449, align 4
  %1451 = insertelement <4 x float> %1448, float %1450, i32 2
  %1452 = getelementptr inbounds float, float* %1, i64 5
  %1453 = load float, float* %1452, align 4
  %1454 = insertelement <4 x float> %1451, float %1453, i32 3
  %1455 = call <4 x float> @llvm.fma.f32.59(<4 x float> %1444, <4 x float> %1454, <4 x float> %1434)
  %1456 = getelementptr inbounds float, float* %0, i64 12
  %1457 = load float, float* %1456, align 4
  %1458 = insertelement <4 x float> <float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %1457, i32 1
  %1459 = insertelement <4 x float> %1458, float 1.000000e+00, i32 2
  %1460 = insertelement <4 x float> %1459, float 1.000000e+00, i32 3
  %1461 = getelementptr inbounds float, float* %1, i64 1
  %1462 = load float, float* %1461, align 4
  %1463 = insertelement <4 x float> zeroinitializer, float %1462, i32 1
  %1464 = insertelement <4 x float> %1463, float 0.000000e+00, i32 2
  %1465 = insertelement <4 x float> %1464, float 0.000000e+00, i32 3
  %1466 = fmul <4 x float> %1460, %1465
  %1467 = getelementptr inbounds float, float* %0, i64 12
  %1468 = load float, float* %1467, align 4
  %1469 = insertelement <4 x float> zeroinitializer, float %1468, i32 0
  %1470 = insertelement <4 x float> %1469, float 1.000000e+00, i32 1
  %1471 = insertelement <4 x float> %1470, float 1.000000e+00, i32 2
  %1472 = insertelement <4 x float> %1471, float 1.000000e+00, i32 3
  %1473 = getelementptr inbounds float, float* %1, i64 1
  %1474 = load float, float* %1473, align 4
  %1475 = insertelement <4 x float> zeroinitializer, float %1474, i32 0
  %1476 = insertelement <4 x float> %1475, float 0.000000e+00, i32 1
  %1477 = insertelement <4 x float> %1476, float 0.000000e+00, i32 2
  %1478 = insertelement <4 x float> %1477, float 0.000000e+00, i32 3
  %1479 = call <4 x float> @llvm.fma.f32.60(<4 x float> %1472, <4 x float> %1478, <4 x float> %1466)
  %1480 = getelementptr inbounds float, float* %0, i64 13
  %1481 = load float, float* %1480, align 4
  %1482 = insertelement <4 x float> <float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %1481, i32 1
  %1483 = insertelement <4 x float> %1482, float 1.000000e+00, i32 2
  %1484 = insertelement <4 x float> %1483, float 1.000000e+00, i32 3
  %1485 = getelementptr inbounds float, float* %1, i64 5
  %1486 = load float, float* %1485, align 4
  %1487 = insertelement <4 x float> zeroinitializer, float %1486, i32 1
  %1488 = insertelement <4 x float> %1487, float 0.000000e+00, i32 2
  %1489 = insertelement <4 x float> %1488, float 0.000000e+00, i32 3
  %1490 = call <4 x float> @llvm.fma.f32.61(<4 x float> %1484, <4 x float> %1489, <4 x float> %1479)
  %1491 = getelementptr inbounds float, float* %0, i64 13
  %1492 = load float, float* %1491, align 4
  %1493 = insertelement <4 x float> zeroinitializer, float %1492, i32 0
  %1494 = getelementptr inbounds float, float* %0, i64 14
  %1495 = load float, float* %1494, align 4
  %1496 = insertelement <4 x float> %1493, float %1495, i32 1
  %1497 = insertelement <4 x float> %1496, float 1.000000e+00, i32 2
  %1498 = getelementptr inbounds float, float* %0, i64 12
  %1499 = load float, float* %1498, align 4
  %1500 = insertelement <4 x float> %1497, float %1499, i32 3
  %1501 = getelementptr inbounds float, float* %1, i64 5
  %1502 = load float, float* %1501, align 4
  %1503 = insertelement <4 x float> zeroinitializer, float %1502, i32 0
  %1504 = getelementptr inbounds float, float* %1, i64 9
  %1505 = load float, float* %1504, align 4
  %1506 = insertelement <4 x float> %1503, float %1505, i32 1
  %1507 = insertelement <4 x float> %1506, float 0.000000e+00, i32 2
  %1508 = getelementptr inbounds float, float* %1, i64 2
  %1509 = load float, float* %1508, align 4
  %1510 = insertelement <4 x float> %1507, float %1509, i32 3
  %1511 = call <4 x float> @llvm.fma.f32.62(<4 x float> %1500, <4 x float> %1510, <4 x float> %1490)
  %1512 = getelementptr inbounds float, float* %0, i64 14
  %1513 = load float, float* %1512, align 4
  %1514 = insertelement <4 x float> zeroinitializer, float %1513, i32 0
  %1515 = getelementptr inbounds float, float* %0, i64 15
  %1516 = load float, float* %1515, align 4
  %1517 = insertelement <4 x float> %1514, float %1516, i32 1
  %1518 = insertelement <4 x float> %1517, float 1.000000e+00, i32 2
  %1519 = insertelement <4 x float> %1518, float 1.000000e+00, i32 3
  %1520 = getelementptr inbounds float, float* %1, i64 9
  %1521 = load float, float* %1520, align 4
  %1522 = insertelement <4 x float> zeroinitializer, float %1521, i32 0
  %1523 = getelementptr inbounds float, float* %1, i64 13
  %1524 = load float, float* %1523, align 4
  %1525 = insertelement <4 x float> %1522, float %1524, i32 1
  %1526 = insertelement <4 x float> %1525, float 0.000000e+00, i32 2
  %1527 = insertelement <4 x float> %1526, float 0.000000e+00, i32 3
  %1528 = call <4 x float> @llvm.fma.f32.63(<4 x float> %1519, <4 x float> %1527, <4 x float> %1511)
  %1529 = shufflevector <4 x float> %1455, <4 x float> %1528, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %1530 = getelementptr inbounds float, float* %0, i64 12
  %1531 = load float, float* %1530, align 4
  %1532 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %1531, i32 2
  %1533 = insertelement <4 x float> %1532, float 1.000000e+00, i32 3
  %1534 = getelementptr inbounds float, float* %1, i64 2
  %1535 = load float, float* %1534, align 4
  %1536 = insertelement <4 x float> zeroinitializer, float %1535, i32 2
  %1537 = insertelement <4 x float> %1536, float 0.000000e+00, i32 3
  %1538 = fmul <4 x float> %1533, %1537
  %1539 = getelementptr inbounds float, float* %0, i64 12
  %1540 = load float, float* %1539, align 4
  %1541 = insertelement <4 x float> <float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %1540, i32 1
  %1542 = insertelement <4 x float> %1541, float 1.000000e+00, i32 2
  %1543 = insertelement <4 x float> %1542, float 1.000000e+00, i32 3
  %1544 = getelementptr inbounds float, float* %1, i64 2
  %1545 = load float, float* %1544, align 4
  %1546 = insertelement <4 x float> zeroinitializer, float %1545, i32 1
  %1547 = insertelement <4 x float> %1546, float 0.000000e+00, i32 2
  %1548 = insertelement <4 x float> %1547, float 0.000000e+00, i32 3
  %1549 = call <4 x float> @llvm.fma.f32.64(<4 x float> %1543, <4 x float> %1548, <4 x float> %1538)
  %1550 = getelementptr inbounds float, float* %0, i64 12
  %1551 = load float, float* %1550, align 4
  %1552 = insertelement <4 x float> zeroinitializer, float %1551, i32 0
  %1553 = insertelement <4 x float> %1552, float 1.000000e+00, i32 1
  %1554 = getelementptr inbounds float, float* %0, i64 13
  %1555 = load float, float* %1554, align 4
  %1556 = insertelement <4 x float> %1553, float %1555, i32 2
  %1557 = insertelement <4 x float> %1556, float 1.000000e+00, i32 3
  %1558 = getelementptr inbounds float, float* %1, i64 2
  %1559 = load float, float* %1558, align 4
  %1560 = insertelement <4 x float> zeroinitializer, float %1559, i32 0
  %1561 = insertelement <4 x float> %1560, float 0.000000e+00, i32 1
  %1562 = getelementptr inbounds float, float* %1, i64 6
  %1563 = load float, float* %1562, align 4
  %1564 = insertelement <4 x float> %1561, float %1563, i32 2
  %1565 = insertelement <4 x float> %1564, float 0.000000e+00, i32 3
  %1566 = call <4 x float> @llvm.fma.f32.65(<4 x float> %1557, <4 x float> %1565, <4 x float> %1549)
  %1567 = getelementptr inbounds float, float* %0, i64 13
  %1568 = load float, float* %1567, align 4
  %1569 = insertelement <4 x float> <float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %1568, i32 1
  %1570 = getelementptr inbounds float, float* %0, i64 14
  %1571 = load float, float* %1570, align 4
  %1572 = insertelement <4 x float> %1569, float %1571, i32 2
  %1573 = insertelement <4 x float> %1572, float 1.000000e+00, i32 3
  %1574 = getelementptr inbounds float, float* %1, i64 6
  %1575 = load float, float* %1574, align 4
  %1576 = insertelement <4 x float> zeroinitializer, float %1575, i32 1
  %1577 = getelementptr inbounds float, float* %1, i64 10
  %1578 = load float, float* %1577, align 4
  %1579 = insertelement <4 x float> %1576, float %1578, i32 2
  %1580 = insertelement <4 x float> %1579, float 0.000000e+00, i32 3
  %1581 = call <4 x float> @llvm.fma.f32.66(<4 x float> %1573, <4 x float> %1580, <4 x float> %1566)
  %1582 = getelementptr inbounds float, float* %0, i64 13
  %1583 = load float, float* %1582, align 4
  %1584 = insertelement <4 x float> zeroinitializer, float %1583, i32 0
  %1585 = getelementptr inbounds float, float* %0, i64 14
  %1586 = load float, float* %1585, align 4
  %1587 = insertelement <4 x float> %1584, float %1586, i32 1
  %1588 = getelementptr inbounds float, float* %0, i64 15
  %1589 = load float, float* %1588, align 4
  %1590 = insertelement <4 x float> %1587, float %1589, i32 2
  %1591 = insertelement <4 x float> %1590, float 0.000000e+00, i32 3
  %1592 = getelementptr inbounds float, float* %1, i64 6
  %1593 = load float, float* %1592, align 4
  %1594 = insertelement <4 x float> zeroinitializer, float %1593, i32 0
  %1595 = getelementptr inbounds float, float* %1, i64 10
  %1596 = load float, float* %1595, align 4
  %1597 = insertelement <4 x float> %1594, float %1596, i32 1
  %1598 = getelementptr inbounds float, float* %1, i64 14
  %1599 = load float, float* %1598, align 4
  %1600 = insertelement <4 x float> %1597, float %1599, i32 2
  %1601 = insertelement <4 x float> %1600, float 0.000000e+00, i32 3
  %1602 = call <4 x float> @llvm.fma.f32.67(<4 x float> %1591, <4 x float> %1601, <4 x float> %1581)
  %1603 = getelementptr inbounds float, float* %0, i64 12
  %1604 = load float, float* %1603, align 4
  %1605 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 0.000000e+00>, float %1604, i32 3
  %1606 = getelementptr inbounds float, float* %1, i64 3
  %1607 = load float, float* %1606, align 4
  %1608 = insertelement <4 x float> zeroinitializer, float %1607, i32 3
  %1609 = fmul <4 x float> %1605, %1608
  %1610 = getelementptr inbounds float, float* %0, i64 12
  %1611 = load float, float* %1610, align 4
  %1612 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %1611, i32 2
  %1613 = insertelement <4 x float> %1612, float 1.000000e+00, i32 3
  %1614 = getelementptr inbounds float, float* %1, i64 3
  %1615 = load float, float* %1614, align 4
  %1616 = insertelement <4 x float> zeroinitializer, float %1615, i32 2
  %1617 = insertelement <4 x float> %1616, float 0.000000e+00, i32 3
  %1618 = call <4 x float> @llvm.fma.f32.68(<4 x float> %1613, <4 x float> %1617, <4 x float> %1609)
  %1619 = getelementptr inbounds float, float* %0, i64 12
  %1620 = load float, float* %1619, align 4
  %1621 = insertelement <4 x float> <float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %1620, i32 1
  %1622 = insertelement <4 x float> %1621, float 1.000000e+00, i32 2
  %1623 = getelementptr inbounds float, float* %0, i64 13
  %1624 = load float, float* %1623, align 4
  %1625 = insertelement <4 x float> %1622, float %1624, i32 3
  %1626 = getelementptr inbounds float, float* %1, i64 3
  %1627 = load float, float* %1626, align 4
  %1628 = insertelement <4 x float> zeroinitializer, float %1627, i32 1
  %1629 = insertelement <4 x float> %1628, float 0.000000e+00, i32 2
  %1630 = getelementptr inbounds float, float* %1, i64 7
  %1631 = load float, float* %1630, align 4
  %1632 = insertelement <4 x float> %1629, float %1631, i32 3
  %1633 = call <4 x float> @llvm.fma.f32.69(<4 x float> %1625, <4 x float> %1632, <4 x float> %1618)
  %1634 = getelementptr inbounds float, float* %0, i64 13
  %1635 = load float, float* %1634, align 4
  %1636 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %1635, i32 2
  %1637 = getelementptr inbounds float, float* %0, i64 14
  %1638 = load float, float* %1637, align 4
  %1639 = insertelement <4 x float> %1636, float %1638, i32 3
  %1640 = getelementptr inbounds float, float* %1, i64 7
  %1641 = load float, float* %1640, align 4
  %1642 = insertelement <4 x float> zeroinitializer, float %1641, i32 2
  %1643 = getelementptr inbounds float, float* %1, i64 11
  %1644 = load float, float* %1643, align 4
  %1645 = insertelement <4 x float> %1642, float %1644, i32 3
  %1646 = call <4 x float> @llvm.fma.f32.70(<4 x float> %1639, <4 x float> %1645, <4 x float> %1633)
  %1647 = getelementptr inbounds float, float* %0, i64 12
  %1648 = load float, float* %1647, align 4
  %1649 = insertelement <4 x float> zeroinitializer, float %1648, i32 0
  %1650 = getelementptr inbounds float, float* %0, i64 13
  %1651 = load float, float* %1650, align 4
  %1652 = insertelement <4 x float> %1649, float %1651, i32 1
  %1653 = getelementptr inbounds float, float* %0, i64 14
  %1654 = load float, float* %1653, align 4
  %1655 = insertelement <4 x float> %1652, float %1654, i32 2
  %1656 = getelementptr inbounds float, float* %0, i64 15
  %1657 = load float, float* %1656, align 4
  %1658 = insertelement <4 x float> %1655, float %1657, i32 3
  %1659 = getelementptr inbounds float, float* %1, i64 3
  %1660 = load float, float* %1659, align 4
  %1661 = insertelement <4 x float> zeroinitializer, float %1660, i32 0
  %1662 = getelementptr inbounds float, float* %1, i64 7
  %1663 = load float, float* %1662, align 4
  %1664 = insertelement <4 x float> %1661, float %1663, i32 1
  %1665 = getelementptr inbounds float, float* %1, i64 11
  %1666 = load float, float* %1665, align 4
  %1667 = insertelement <4 x float> %1664, float %1666, i32 2
  %1668 = getelementptr inbounds float, float* %1, i64 15
  %1669 = load float, float* %1668, align 4
  %1670 = insertelement <4 x float> %1667, float %1669, i32 3
  %1671 = call <4 x float> @llvm.fma.f32.71(<4 x float> %1658, <4 x float> %1670, <4 x float> %1646)
  %1672 = shufflevector <4 x float> %1602, <4 x float> %1671, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %1673 = shufflevector <8 x float> %1529, <8 x float> %1672, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %1674 = shufflevector <16 x float> %1673, <16 x float> zeroinitializer, <32 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31>
  %1675 = shufflevector <32 x float> %1674, <32 x float> zeroinitializer, <64 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31, i32 32, i32 33, i32 34, i32 35, i32 36, i32 37, i32 38, i32 39, i32 40, i32 41, i32 42, i32 43, i32 44, i32 45, i32 46, i32 47, i32 48, i32 49, i32 50, i32 51, i32 52, i32 53, i32 54, i32 55, i32 56, i32 57, i32 58, i32 59, i32 60, i32 61, i32 62, i32 63>
  %1676 = shufflevector <64 x float> %1391, <64 x float> %1675, <128 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31, i32 32, i32 33, i32 34, i32 35, i32 36, i32 37, i32 38, i32 39, i32 40, i32 41, i32 42, i32 43, i32 44, i32 45, i32 46, i32 47, i32 48, i32 49, i32 50, i32 51, i32 52, i32 53, i32 54, i32 55, i32 56, i32 57, i32 58, i32 59, i32 60, i32 61, i32 62, i32 63, i32 64, i32 65, i32 66, i32 67, i32 68, i32 69, i32 70, i32 71, i32 72, i32 73, i32 74, i32 75, i32 76, i32 77, i32 78, i32 79, i32 80, i32 81, i32 82, i32 83, i32 84, i32 85, i32 86, i32 87, i32 88, i32 89, i32 90, i32 91, i32 92, i32 93, i32 94, i32 95, i32 96, i32 97, i32 98, i32 99, i32 100, i32 101, i32 102, i32 103, i32 104, i32 105, i32 106, i32 107, i32 108, i32 109, i32 110, i32 111, i32 112, i32 113, i32 114, i32 115, i32 116, i32 117, i32 118, i32 119, i32 120, i32 121, i32 122, i32 123, i32 124, i32 125, i32 126, i32 127>
  %1677 = extractelement <128 x float> %1676, i32 0
  store float %1677, float* %2, align 4
  %1678 = extractelement <128 x float> %1676, i32 1
  store float %1678, float* %2, align 4
  %1679 = extractelement <128 x float> %1676, i32 2
  store float %1679, float* %2, align 4
  %1680 = extractelement <128 x float> %1676, i32 3
  store float %1680, float* %2, align 4
  %1681 = extractelement <128 x float> %1676, i32 4
  store float %1681, float* %2, align 4
  %1682 = extractelement <128 x float> %1676, i32 5
  %1683 = getelementptr inbounds float, float* %2, i64 1
  store float %1682, float* %1683, align 4
  %1684 = extractelement <128 x float> %1676, i32 6
  %1685 = getelementptr inbounds float, float* %2, i64 1
  store float %1684, float* %1685, align 4
  %1686 = extractelement <128 x float> %1676, i32 7
  %1687 = getelementptr inbounds float, float* %2, i64 1
  store float %1686, float* %1687, align 4
  %1688 = extractelement <128 x float> %1676, i32 8
  %1689 = getelementptr inbounds float, float* %2, i64 1
  store float %1688, float* %1689, align 4
  %1690 = extractelement <128 x float> %1676, i32 9
  %1691 = getelementptr inbounds float, float* %2, i64 1
  store float %1690, float* %1691, align 4
  %1692 = extractelement <128 x float> %1676, i32 10
  %1693 = getelementptr inbounds float, float* %2, i64 2
  store float %1692, float* %1693, align 4
  %1694 = extractelement <128 x float> %1676, i32 11
  %1695 = getelementptr inbounds float, float* %2, i64 2
  store float %1694, float* %1695, align 4
  %1696 = extractelement <128 x float> %1676, i32 12
  %1697 = getelementptr inbounds float, float* %2, i64 2
  store float %1696, float* %1697, align 4
  %1698 = extractelement <128 x float> %1676, i32 13
  %1699 = getelementptr inbounds float, float* %2, i64 2
  store float %1698, float* %1699, align 4
  %1700 = extractelement <128 x float> %1676, i32 14
  %1701 = getelementptr inbounds float, float* %2, i64 2
  store float %1700, float* %1701, align 4
  %1702 = extractelement <128 x float> %1676, i32 15
  %1703 = getelementptr inbounds float, float* %2, i64 3
  store float %1702, float* %1703, align 4
  %1704 = extractelement <128 x float> %1676, i32 16
  %1705 = getelementptr inbounds float, float* %2, i64 3
  store float %1704, float* %1705, align 4
  %1706 = extractelement <128 x float> %1676, i32 17
  %1707 = getelementptr inbounds float, float* %2, i64 3
  store float %1706, float* %1707, align 4
  %1708 = extractelement <128 x float> %1676, i32 18
  %1709 = getelementptr inbounds float, float* %2, i64 3
  store float %1708, float* %1709, align 4
  %1710 = extractelement <128 x float> %1676, i32 19
  %1711 = getelementptr inbounds float, float* %2, i64 3
  store float %1710, float* %1711, align 4
  %1712 = extractelement <128 x float> %1676, i32 20
  %1713 = getelementptr inbounds float, float* %2, i64 4
  store float %1712, float* %1713, align 4
  %1714 = extractelement <128 x float> %1676, i32 21
  %1715 = getelementptr inbounds float, float* %2, i64 4
  store float %1714, float* %1715, align 4
  %1716 = extractelement <128 x float> %1676, i32 22
  %1717 = getelementptr inbounds float, float* %2, i64 4
  store float %1716, float* %1717, align 4
  %1718 = extractelement <128 x float> %1676, i32 23
  %1719 = getelementptr inbounds float, float* %2, i64 4
  store float %1718, float* %1719, align 4
  %1720 = extractelement <128 x float> %1676, i32 24
  %1721 = getelementptr inbounds float, float* %2, i64 4
  store float %1720, float* %1721, align 4
  %1722 = extractelement <128 x float> %1676, i32 25
  %1723 = getelementptr inbounds float, float* %2, i64 5
  store float %1722, float* %1723, align 4
  %1724 = extractelement <128 x float> %1676, i32 26
  %1725 = getelementptr inbounds float, float* %2, i64 5
  store float %1724, float* %1725, align 4
  %1726 = extractelement <128 x float> %1676, i32 27
  %1727 = getelementptr inbounds float, float* %2, i64 5
  store float %1726, float* %1727, align 4
  %1728 = extractelement <128 x float> %1676, i32 28
  %1729 = getelementptr inbounds float, float* %2, i64 5
  store float %1728, float* %1729, align 4
  %1730 = extractelement <128 x float> %1676, i32 29
  %1731 = getelementptr inbounds float, float* %2, i64 5
  store float %1730, float* %1731, align 4
  %1732 = extractelement <128 x float> %1676, i32 30
  %1733 = getelementptr inbounds float, float* %2, i64 6
  store float %1732, float* %1733, align 4
  %1734 = extractelement <128 x float> %1676, i32 31
  %1735 = getelementptr inbounds float, float* %2, i64 6
  store float %1734, float* %1735, align 4
  %1736 = extractelement <128 x float> %1676, i32 32
  %1737 = getelementptr inbounds float, float* %2, i64 6
  store float %1736, float* %1737, align 4
  %1738 = extractelement <128 x float> %1676, i32 33
  %1739 = getelementptr inbounds float, float* %2, i64 6
  store float %1738, float* %1739, align 4
  %1740 = extractelement <128 x float> %1676, i32 34
  %1741 = getelementptr inbounds float, float* %2, i64 6
  store float %1740, float* %1741, align 4
  %1742 = extractelement <128 x float> %1676, i32 35
  %1743 = getelementptr inbounds float, float* %2, i64 7
  store float %1742, float* %1743, align 4
  %1744 = extractelement <128 x float> %1676, i32 36
  %1745 = getelementptr inbounds float, float* %2, i64 7
  store float %1744, float* %1745, align 4
  %1746 = extractelement <128 x float> %1676, i32 37
  %1747 = getelementptr inbounds float, float* %2, i64 7
  store float %1746, float* %1747, align 4
  %1748 = extractelement <128 x float> %1676, i32 38
  %1749 = getelementptr inbounds float, float* %2, i64 7
  store float %1748, float* %1749, align 4
  %1750 = extractelement <128 x float> %1676, i32 39
  %1751 = getelementptr inbounds float, float* %2, i64 7
  store float %1750, float* %1751, align 4
  %1752 = extractelement <128 x float> %1676, i32 40
  %1753 = getelementptr inbounds float, float* %2, i64 8
  store float %1752, float* %1753, align 4
  %1754 = extractelement <128 x float> %1676, i32 41
  %1755 = getelementptr inbounds float, float* %2, i64 8
  store float %1754, float* %1755, align 4
  %1756 = extractelement <128 x float> %1676, i32 42
  %1757 = getelementptr inbounds float, float* %2, i64 8
  store float %1756, float* %1757, align 4
  %1758 = extractelement <128 x float> %1676, i32 43
  %1759 = getelementptr inbounds float, float* %2, i64 8
  store float %1758, float* %1759, align 4
  %1760 = extractelement <128 x float> %1676, i32 44
  %1761 = getelementptr inbounds float, float* %2, i64 8
  store float %1760, float* %1761, align 4
  %1762 = extractelement <128 x float> %1676, i32 45
  %1763 = getelementptr inbounds float, float* %2, i64 9
  store float %1762, float* %1763, align 4
  %1764 = extractelement <128 x float> %1676, i32 46
  %1765 = getelementptr inbounds float, float* %2, i64 9
  store float %1764, float* %1765, align 4
  %1766 = extractelement <128 x float> %1676, i32 47
  %1767 = getelementptr inbounds float, float* %2, i64 9
  store float %1766, float* %1767, align 4
  %1768 = extractelement <128 x float> %1676, i32 48
  %1769 = getelementptr inbounds float, float* %2, i64 9
  store float %1768, float* %1769, align 4
  %1770 = extractelement <128 x float> %1676, i32 49
  %1771 = getelementptr inbounds float, float* %2, i64 9
  store float %1770, float* %1771, align 4
  %1772 = extractelement <128 x float> %1676, i32 50
  %1773 = getelementptr inbounds float, float* %2, i64 10
  store float %1772, float* %1773, align 4
  %1774 = extractelement <128 x float> %1676, i32 51
  %1775 = getelementptr inbounds float, float* %2, i64 10
  store float %1774, float* %1775, align 4
  %1776 = extractelement <128 x float> %1676, i32 52
  %1777 = getelementptr inbounds float, float* %2, i64 10
  store float %1776, float* %1777, align 4
  %1778 = extractelement <128 x float> %1676, i32 53
  %1779 = getelementptr inbounds float, float* %2, i64 10
  store float %1778, float* %1779, align 4
  %1780 = extractelement <128 x float> %1676, i32 54
  %1781 = getelementptr inbounds float, float* %2, i64 10
  store float %1780, float* %1781, align 4
  %1782 = extractelement <128 x float> %1676, i32 55
  %1783 = getelementptr inbounds float, float* %2, i64 11
  store float %1782, float* %1783, align 4
  %1784 = extractelement <128 x float> %1676, i32 56
  %1785 = getelementptr inbounds float, float* %2, i64 11
  store float %1784, float* %1785, align 4
  %1786 = extractelement <128 x float> %1676, i32 57
  %1787 = getelementptr inbounds float, float* %2, i64 11
  store float %1786, float* %1787, align 4
  %1788 = extractelement <128 x float> %1676, i32 58
  %1789 = getelementptr inbounds float, float* %2, i64 11
  store float %1788, float* %1789, align 4
  %1790 = extractelement <128 x float> %1676, i32 59
  %1791 = getelementptr inbounds float, float* %2, i64 11
  store float %1790, float* %1791, align 4
  %1792 = extractelement <128 x float> %1676, i32 60
  %1793 = getelementptr inbounds float, float* %2, i64 12
  store float %1792, float* %1793, align 4
  %1794 = extractelement <128 x float> %1676, i32 61
  %1795 = getelementptr inbounds float, float* %2, i64 12
  store float %1794, float* %1795, align 4
  %1796 = extractelement <128 x float> %1676, i32 62
  %1797 = getelementptr inbounds float, float* %2, i64 12
  store float %1796, float* %1797, align 4
  %1798 = extractelement <128 x float> %1676, i32 63
  %1799 = getelementptr inbounds float, float* %2, i64 12
  store float %1798, float* %1799, align 4
  %1800 = extractelement <128 x float> %1676, i32 64
  %1801 = getelementptr inbounds float, float* %2, i64 12
  store float %1800, float* %1801, align 4
  %1802 = extractelement <128 x float> %1676, i32 65
  %1803 = getelementptr inbounds float, float* %2, i64 13
  store float %1802, float* %1803, align 4
  %1804 = extractelement <128 x float> %1676, i32 66
  %1805 = getelementptr inbounds float, float* %2, i64 13
  store float %1804, float* %1805, align 4
  %1806 = extractelement <128 x float> %1676, i32 67
  %1807 = getelementptr inbounds float, float* %2, i64 13
  store float %1806, float* %1807, align 4
  %1808 = extractelement <128 x float> %1676, i32 68
  %1809 = getelementptr inbounds float, float* %2, i64 13
  store float %1808, float* %1809, align 4
  %1810 = extractelement <128 x float> %1676, i32 69
  %1811 = getelementptr inbounds float, float* %2, i64 13
  store float %1810, float* %1811, align 4
  %1812 = extractelement <128 x float> %1676, i32 70
  %1813 = getelementptr inbounds float, float* %2, i64 14
  store float %1812, float* %1813, align 4
  %1814 = extractelement <128 x float> %1676, i32 71
  %1815 = getelementptr inbounds float, float* %2, i64 14
  store float %1814, float* %1815, align 4
  %1816 = extractelement <128 x float> %1676, i32 72
  %1817 = getelementptr inbounds float, float* %2, i64 14
  store float %1816, float* %1817, align 4
  %1818 = extractelement <128 x float> %1676, i32 73
  %1819 = getelementptr inbounds float, float* %2, i64 14
  store float %1818, float* %1819, align 4
  %1820 = extractelement <128 x float> %1676, i32 74
  %1821 = getelementptr inbounds float, float* %2, i64 14
  store float %1820, float* %1821, align 4
  %1822 = extractelement <128 x float> %1676, i32 75
  %1823 = getelementptr inbounds float, float* %2, i64 15
  store float %1822, float* %1823, align 4
  %1824 = extractelement <128 x float> %1676, i32 76
  %1825 = getelementptr inbounds float, float* %2, i64 15
  store float %1824, float* %1825, align 4
  %1826 = extractelement <128 x float> %1676, i32 77
  %1827 = getelementptr inbounds float, float* %2, i64 15
  store float %1826, float* %1827, align 4
  %1828 = extractelement <128 x float> %1676, i32 78
  %1829 = getelementptr inbounds float, float* %2, i64 15
  store float %1828, float* %1829, align 4
  %1830 = extractelement <128 x float> %1676, i32 79
  %1831 = getelementptr inbounds float, float* %2, i64 15
  store float %1830, float* %1831, align 4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define void @naive_fixed_qr_decomp(float* %0, float* %1, float* %2) #2 {
.preheader33:
  %3 = bitcast float* %2 to i8*
  %4 = bitcast float* %0 to i8*
  %5 = bitcast float* %2 to i8*
  %6 = call i64 @llvm.objectsize.i64.p0i8(i8* %5, i1 false, i1 true, i1 false)
  %7 = call i8* @__memcpy_chk(i8* %3, i8* %4, i64 64, i64 %6) #9
  %8 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9 = bitcast i8* %8 to float*
  %10 = getelementptr inbounds i8, i8* %8, i64 4
  %11 = bitcast i8* %10 to float*
  %12 = getelementptr inbounds i8, i8* %8, i64 8
  %13 = bitcast i8* %12 to float*
  %14 = getelementptr inbounds i8, i8* %8, i64 12
  %15 = bitcast i8* %14 to float*
  %16 = getelementptr inbounds i8, i8* %8, i64 16
  %17 = bitcast i8* %16 to float*
  %18 = getelementptr inbounds i8, i8* %8, i64 20
  %19 = bitcast i8* %18 to float*
  %20 = getelementptr inbounds i8, i8* %8, i64 24
  %21 = bitcast i8* %20 to float*
  %22 = getelementptr inbounds i8, i8* %8, i64 28
  %23 = bitcast i8* %22 to float*
  %24 = getelementptr inbounds i8, i8* %8, i64 32
  %25 = bitcast i8* %24 to float*
  %26 = getelementptr inbounds i8, i8* %8, i64 36
  %27 = bitcast i8* %26 to float*
  %28 = getelementptr inbounds i8, i8* %8, i64 40
  %29 = bitcast i8* %28 to float*
  %30 = getelementptr inbounds i8, i8* %8, i64 44
  %31 = bitcast i8* %30 to float*
  %32 = getelementptr inbounds i8, i8* %8, i64 48
  %33 = bitcast i8* %32 to float*
  %34 = getelementptr inbounds i8, i8* %8, i64 52
  %35 = bitcast i8* %34 to float*
  %36 = getelementptr inbounds i8, i8* %8, i64 56
  %37 = bitcast i8* %36 to float*
  %38 = getelementptr inbounds i8, i8* %8, i64 60
  %39 = bitcast i8* %38 to float*
  %40 = bitcast float* %1 to i8*
  %41 = bitcast float* %1 to i8*
  %42 = call i64 @llvm.objectsize.i64.p0i8(i8* %41, i1 false, i1 true, i1 false)
  %43 = bitcast float* %2 to i8*
  %44 = bitcast float* %2 to i8*
  %45 = call i64 @llvm.objectsize.i64.p0i8(i8* %44, i1 false, i1 true, i1 false)
  %46 = bitcast float* %1 to i8*
  %47 = bitcast float* %1 to i8*
  %48 = call i64 @llvm.objectsize.i64.p0i8(i8* %47, i1 false, i1 true, i1 false)
  %49 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %50 = bitcast i8* %49 to float*
  %51 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %52 = bitcast i8* %51 to float*
  %53 = bitcast float* %2 to i32*
  %54 = load i32, i32* %53, align 4
  %55 = bitcast i8* %49 to i32*
  %56 = bitcast i8* %8 to i32*
  %57 = load i32, i32* %56, align 4
  %58 = bitcast i8* %51 to i32*
  %59 = getelementptr inbounds float, float* %2, i64 4
  %60 = bitcast float* %59 to i32*
  %61 = load i32, i32* %60, align 4
  %62 = getelementptr inbounds i8, i8* %49, i64 4
  %63 = bitcast i8* %62 to i32*
  %64 = getelementptr inbounds i8, i8* %8, i64 16
  %65 = bitcast i8* %64 to i32*
  %66 = load i32, i32* %65, align 4
  %67 = getelementptr inbounds i8, i8* %51, i64 4
  %68 = bitcast i8* %67 to i32*
  %69 = getelementptr inbounds float, float* %2, i64 8
  %70 = bitcast float* %69 to i32*
  %71 = load i32, i32* %70, align 4
  %72 = getelementptr inbounds i8, i8* %49, i64 8
  %73 = bitcast i8* %72 to i32*
  %74 = getelementptr inbounds i8, i8* %8, i64 32
  %75 = bitcast i8* %74 to i32*
  %76 = load i32, i32* %75, align 4
  %77 = getelementptr inbounds i8, i8* %51, i64 8
  %78 = bitcast i8* %77 to i32*
  %79 = getelementptr inbounds float, float* %2, i64 12
  %80 = bitcast float* %79 to i32*
  %81 = load i32, i32* %80, align 4
  %82 = getelementptr inbounds i8, i8* %49, i64 12
  %83 = bitcast i8* %82 to i32*
  %84 = getelementptr inbounds i8, i8* %8, i64 48
  %85 = bitcast i8* %84 to i32*
  %86 = load i32, i32* %85, align 4
  %87 = getelementptr inbounds i8, i8* %51, i64 12
  %88 = bitcast i8* %87 to i32*
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
  %123 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %124 = bitcast i8* %123 to float*
  %125 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %126 = load float, float* %50, align 4
  %127 = load float, float* %52, align 4
  %128 = fmul float %122, %127
  %129 = fadd float %126, %128
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
  %189 = getelementptr inbounds i8, i8* %123, i64 4
  %190 = bitcast i8* %189 to float*
  %191 = load float, float* %190, align 4
  %192 = fdiv float %191, %186
  %193 = getelementptr inbounds i8, i8* %125, i64 4
  %194 = bitcast i8* %193 to float*
  %195 = getelementptr inbounds i8, i8* %123, i64 8
  %196 = bitcast i8* %195 to float*
  %197 = load float, float* %196, align 4
  %198 = fdiv float %197, %186
  %199 = getelementptr inbounds i8, i8* %125, i64 8
  %200 = bitcast i8* %199 to float*
  %201 = getelementptr inbounds i8, i8* %123, i64 12
  %202 = bitcast i8* %201 to float*
  %203 = load float, float* %202, align 4
  %204 = fdiv float %203, %186
  %205 = getelementptr inbounds i8, i8* %125, i64 12
  %206 = bitcast i8* %205 to float*
  %207 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %208 = bitcast i8* %207 to float*
  %209 = load float, float* %185, align 4
  %210 = fmul float %209, 2.000000e+00
  %211 = fmul float %210, %209
  %212 = fsub float 1.000000e+00, %211
  %213 = load float, float* %185, align 4
  %214 = fmul float %213, 2.000000e+00
  %215 = getelementptr inbounds i8, i8* %125, i64 4
  %216 = bitcast i8* %215 to float*
  %217 = load float, float* %216, align 4
  %218 = fmul float %214, %217
  %219 = fsub float 0.000000e+00, %218
  %220 = getelementptr inbounds i8, i8* %207, i64 4
  %221 = bitcast i8* %220 to float*
  %222 = load float, float* %185, align 4
  %223 = fmul float %222, 2.000000e+00
  %224 = getelementptr inbounds i8, i8* %125, i64 8
  %225 = bitcast i8* %224 to float*
  %226 = load float, float* %225, align 4
  %227 = fmul float %223, %226
  %228 = fsub float 0.000000e+00, %227
  %229 = getelementptr inbounds i8, i8* %207, i64 8
  %230 = bitcast i8* %229 to float*
  %231 = load float, float* %185, align 4
  %232 = fmul float %231, 2.000000e+00
  %233 = getelementptr inbounds i8, i8* %125, i64 12
  %234 = bitcast i8* %233 to float*
  %235 = load float, float* %234, align 4
  %236 = fmul float %232, %235
  %237 = fsub float 0.000000e+00, %236
  %238 = getelementptr inbounds i8, i8* %207, i64 12
  %239 = bitcast i8* %238 to float*
  %240 = getelementptr inbounds i8, i8* %125, i64 4
  %241 = bitcast i8* %240 to float*
  %242 = load float, float* %241, align 4
  %243 = fmul float %242, 2.000000e+00
  %244 = load float, float* %185, align 4
  %245 = fmul float %243, %244
  %246 = fsub float 0.000000e+00, %245
  %247 = getelementptr inbounds i8, i8* %207, i64 16
  %248 = bitcast i8* %247 to float*
  %249 = load float, float* %241, align 4
  %250 = fmul float %249, 2.000000e+00
  %251 = fmul float %250, %249
  %252 = fsub float 1.000000e+00, %251
  %253 = getelementptr inbounds i8, i8* %207, i64 20
  %254 = bitcast i8* %253 to float*
  %255 = load float, float* %241, align 4
  %256 = fmul float %255, 2.000000e+00
  %257 = getelementptr inbounds i8, i8* %125, i64 8
  %258 = bitcast i8* %257 to float*
  %259 = load float, float* %258, align 4
  %260 = fmul float %256, %259
  %261 = fsub float 0.000000e+00, %260
  %262 = getelementptr inbounds i8, i8* %207, i64 24
  %263 = bitcast i8* %262 to float*
  %264 = load float, float* %241, align 4
  %265 = fmul float %264, 2.000000e+00
  %266 = getelementptr inbounds i8, i8* %125, i64 12
  %267 = bitcast i8* %266 to float*
  %268 = load float, float* %267, align 4
  %269 = fmul float %265, %268
  %270 = fsub float 0.000000e+00, %269
  %271 = getelementptr inbounds i8, i8* %207, i64 28
  %272 = bitcast i8* %271 to float*
  %273 = getelementptr inbounds i8, i8* %125, i64 8
  %274 = bitcast i8* %273 to float*
  %275 = load float, float* %274, align 4
  %276 = fmul float %275, 2.000000e+00
  %277 = load float, float* %185, align 4
  %278 = fmul float %276, %277
  %279 = fsub float 0.000000e+00, %278
  %280 = getelementptr inbounds i8, i8* %207, i64 32
  %281 = bitcast i8* %280 to float*
  %282 = load float, float* %274, align 4
  %283 = fmul float %282, 2.000000e+00
  %284 = getelementptr inbounds i8, i8* %125, i64 4
  %285 = bitcast i8* %284 to float*
  %286 = load float, float* %285, align 4
  %287 = fmul float %283, %286
  %288 = fsub float 0.000000e+00, %287
  %289 = getelementptr inbounds i8, i8* %207, i64 36
  %290 = bitcast i8* %289 to float*
  %291 = load float, float* %274, align 4
  %292 = fmul float %291, 2.000000e+00
  %293 = fmul float %292, %291
  %294 = fsub float 1.000000e+00, %293
  %295 = getelementptr inbounds i8, i8* %207, i64 40
  %296 = bitcast i8* %295 to float*
  %297 = load float, float* %274, align 4
  %298 = fmul float %297, 2.000000e+00
  %299 = getelementptr inbounds i8, i8* %125, i64 12
  %300 = bitcast i8* %299 to float*
  %301 = load float, float* %300, align 4
  %302 = fmul float %298, %301
  %303 = fsub float 0.000000e+00, %302
  %304 = getelementptr inbounds i8, i8* %207, i64 44
  %305 = bitcast i8* %304 to float*
  %306 = getelementptr inbounds i8, i8* %125, i64 12
  %307 = bitcast i8* %306 to float*
  %308 = load float, float* %307, align 4
  %309 = fmul float %308, 2.000000e+00
  %310 = load float, float* %185, align 4
  %311 = fmul float %309, %310
  %312 = fsub float 0.000000e+00, %311
  %313 = getelementptr inbounds i8, i8* %207, i64 48
  %314 = bitcast i8* %313 to float*
  %315 = load float, float* %307, align 4
  %316 = fmul float %315, 2.000000e+00
  %317 = getelementptr inbounds i8, i8* %125, i64 4
  %318 = bitcast i8* %317 to float*
  %319 = load float, float* %318, align 4
  %320 = fmul float %316, %319
  %321 = fsub float 0.000000e+00, %320
  %322 = getelementptr inbounds i8, i8* %207, i64 52
  %323 = bitcast i8* %322 to float*
  %324 = load float, float* %307, align 4
  %325 = fmul float %324, 2.000000e+00
  %326 = getelementptr inbounds i8, i8* %125, i64 8
  %327 = bitcast i8* %326 to float*
  %328 = load float, float* %327, align 4
  %329 = fmul float %325, %328
  %330 = fsub float 0.000000e+00, %329
  %331 = getelementptr inbounds i8, i8* %207, i64 56
  %332 = bitcast i8* %331 to float*
  %333 = load float, float* %307, align 4
  %334 = fmul float %333, 2.000000e+00
  %335 = fmul float %334, %333
  %336 = fsub float 1.000000e+00, %335
  %337 = getelementptr inbounds i8, i8* %207, i64 60
  %338 = bitcast i8* %337 to float*
  %339 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %340 = bitcast i8* %339 to float*
  %341 = bitcast i8* %207 to i32*
  %342 = load i32, i32* %341, align 4
  %343 = bitcast i8* %339 to i32*
  %344 = getelementptr inbounds i8, i8* %207, i64 4
  %345 = bitcast i8* %344 to i32*
  %346 = load i32, i32* %345, align 4
  %347 = getelementptr inbounds i8, i8* %339, i64 4
  %348 = bitcast i8* %347 to i32*
  %349 = getelementptr inbounds i8, i8* %207, i64 8
  %350 = bitcast i8* %349 to i32*
  %351 = load i32, i32* %350, align 4
  %352 = getelementptr inbounds i8, i8* %339, i64 8
  %353 = bitcast i8* %352 to i32*
  %354 = getelementptr inbounds i8, i8* %207, i64 12
  %355 = bitcast i8* %354 to i32*
  %356 = load i32, i32* %355, align 4
  %357 = getelementptr inbounds i8, i8* %339, i64 12
  %358 = bitcast i8* %357 to i32*
  %359 = getelementptr inbounds i8, i8* %207, i64 16
  %360 = bitcast i8* %359 to i32*
  %361 = load i32, i32* %360, align 4
  %362 = getelementptr inbounds i8, i8* %339, i64 16
  %363 = bitcast i8* %362 to i32*
  %364 = getelementptr inbounds i8, i8* %207, i64 20
  %365 = bitcast i8* %364 to i32*
  %366 = load i32, i32* %365, align 4
  %367 = getelementptr inbounds i8, i8* %339, i64 20
  %368 = bitcast i8* %367 to i32*
  %369 = getelementptr inbounds i8, i8* %207, i64 24
  %370 = bitcast i8* %369 to i32*
  %371 = load i32, i32* %370, align 4
  %372 = getelementptr inbounds i8, i8* %339, i64 24
  %373 = bitcast i8* %372 to i32*
  %374 = getelementptr inbounds i8, i8* %207, i64 28
  %375 = bitcast i8* %374 to i32*
  %376 = load i32, i32* %375, align 4
  %377 = getelementptr inbounds i8, i8* %339, i64 28
  %378 = bitcast i8* %377 to i32*
  %379 = getelementptr inbounds i8, i8* %207, i64 32
  %380 = bitcast i8* %379 to i32*
  %381 = load i32, i32* %380, align 4
  %382 = getelementptr inbounds i8, i8* %339, i64 32
  %383 = bitcast i8* %382 to i32*
  %384 = getelementptr inbounds i8, i8* %207, i64 36
  %385 = bitcast i8* %384 to i32*
  %386 = load i32, i32* %385, align 4
  %387 = getelementptr inbounds i8, i8* %339, i64 36
  %388 = bitcast i8* %387 to i32*
  %389 = getelementptr inbounds i8, i8* %207, i64 40
  %390 = bitcast i8* %389 to i32*
  %391 = load i32, i32* %390, align 4
  %392 = getelementptr inbounds i8, i8* %339, i64 40
  %393 = bitcast i8* %392 to i32*
  %394 = getelementptr inbounds i8, i8* %207, i64 44
  %395 = bitcast i8* %394 to i32*
  %396 = load i32, i32* %395, align 4
  %397 = getelementptr inbounds i8, i8* %339, i64 44
  %398 = bitcast i8* %397 to i32*
  %399 = getelementptr inbounds i8, i8* %207, i64 48
  %400 = bitcast i8* %399 to i32*
  %401 = load i32, i32* %400, align 4
  %402 = getelementptr inbounds i8, i8* %339, i64 48
  %403 = bitcast i8* %402 to i32*
  %404 = getelementptr inbounds i8, i8* %207, i64 52
  %405 = bitcast i8* %404 to i32*
  %406 = load i32, i32* %405, align 4
  %407 = getelementptr inbounds i8, i8* %339, i64 52
  %408 = bitcast i8* %407 to i32*
  %409 = getelementptr inbounds i8, i8* %207, i64 56
  %410 = bitcast i8* %409 to i32*
  %411 = load i32, i32* %410, align 4
  %412 = getelementptr inbounds i8, i8* %339, i64 56
  %413 = bitcast i8* %412 to i32*
  %414 = getelementptr inbounds i8, i8* %207, i64 60
  %415 = bitcast i8* %414 to i32*
  %416 = load i32, i32* %415, align 4
  %417 = getelementptr inbounds i8, i8* %339, i64 60
  %418 = bitcast i8* %417 to i32*
  %419 = call i8* @__memcpy_chk(i8* %46, i8* %339, i64 64, i64 %48) #9
  %420 = load float, float* %340, align 4
  %421 = load float, float* %0, align 4
  %422 = fmul float %420, %421
  %423 = fadd float %422, 0.000000e+00
  %424 = getelementptr inbounds i8, i8* %339, i64 4
  %425 = bitcast i8* %424 to float*
  %426 = load float, float* %425, align 4
  %427 = getelementptr inbounds float, float* %0, i64 4
  %428 = load float, float* %427, align 4
  %429 = fmul float %426, %428
  %430 = load float, float* %2, align 4
  %431 = fadd float %430, %429
  %432 = getelementptr inbounds i8, i8* %339, i64 8
  %433 = bitcast i8* %432 to float*
  %434 = load float, float* %433, align 4
  %435 = getelementptr inbounds float, float* %0, i64 8
  %436 = load float, float* %435, align 4
  %437 = fmul float %434, %436
  %438 = load float, float* %2, align 4
  %439 = fadd float %438, %437
  %440 = getelementptr inbounds i8, i8* %339, i64 12
  %441 = bitcast i8* %440 to float*
  %442 = load float, float* %441, align 4
  %443 = getelementptr inbounds float, float* %0, i64 12
  %444 = load float, float* %443, align 4
  %445 = fmul float %442, %444
  %446 = load float, float* %2, align 4
  %447 = fadd float %446, %445
  %448 = getelementptr inbounds float, float* %2, i64 1
  %449 = getelementptr inbounds float, float* %2, i64 1
  %450 = load float, float* %340, align 4
  %451 = getelementptr inbounds float, float* %0, i64 1
  %452 = load float, float* %451, align 4
  %453 = fmul float %450, %452
  %454 = fadd float %453, 0.000000e+00
  %455 = getelementptr inbounds i8, i8* %339, i64 4
  %456 = bitcast i8* %455 to float*
  %457 = load float, float* %456, align 4
  %458 = getelementptr inbounds float, float* %0, i64 5
  %459 = load float, float* %458, align 4
  %460 = fmul float %457, %459
  %461 = load float, float* %449, align 4
  %462 = fadd float %461, %460
  %463 = getelementptr inbounds i8, i8* %339, i64 8
  %464 = bitcast i8* %463 to float*
  %465 = load float, float* %464, align 4
  %466 = getelementptr inbounds float, float* %0, i64 9
  %467 = load float, float* %466, align 4
  %468 = fmul float %465, %467
  %469 = load float, float* %449, align 4
  %470 = fadd float %469, %468
  %471 = getelementptr inbounds i8, i8* %339, i64 12
  %472 = bitcast i8* %471 to float*
  %473 = load float, float* %472, align 4
  %474 = getelementptr inbounds float, float* %0, i64 13
  %475 = load float, float* %474, align 4
  %476 = fmul float %473, %475
  %477 = load float, float* %449, align 4
  %478 = fadd float %477, %476
  %479 = getelementptr inbounds float, float* %2, i64 2
  %480 = getelementptr inbounds float, float* %2, i64 2
  %481 = load float, float* %340, align 4
  %482 = getelementptr inbounds float, float* %0, i64 2
  %483 = load float, float* %482, align 4
  %484 = fmul float %481, %483
  %485 = fadd float %484, 0.000000e+00
  %486 = getelementptr inbounds i8, i8* %339, i64 4
  %487 = bitcast i8* %486 to float*
  %488 = load float, float* %487, align 4
  %489 = getelementptr inbounds float, float* %0, i64 6
  %490 = load float, float* %489, align 4
  %491 = fmul float %488, %490
  %492 = load float, float* %480, align 4
  %493 = fadd float %492, %491
  %494 = getelementptr inbounds i8, i8* %339, i64 8
  %495 = bitcast i8* %494 to float*
  %496 = load float, float* %495, align 4
  %497 = getelementptr inbounds float, float* %0, i64 10
  %498 = load float, float* %497, align 4
  %499 = fmul float %496, %498
  %500 = load float, float* %480, align 4
  %501 = fadd float %500, %499
  %502 = getelementptr inbounds i8, i8* %339, i64 12
  %503 = bitcast i8* %502 to float*
  %504 = load float, float* %503, align 4
  %505 = getelementptr inbounds float, float* %0, i64 14
  %506 = load float, float* %505, align 4
  %507 = fmul float %504, %506
  %508 = load float, float* %480, align 4
  %509 = fadd float %508, %507
  %510 = getelementptr inbounds float, float* %2, i64 3
  %511 = getelementptr inbounds float, float* %2, i64 3
  %512 = load float, float* %340, align 4
  %513 = getelementptr inbounds float, float* %0, i64 3
  %514 = load float, float* %513, align 4
  %515 = fmul float %512, %514
  %516 = fadd float %515, 0.000000e+00
  %517 = getelementptr inbounds i8, i8* %339, i64 4
  %518 = bitcast i8* %517 to float*
  %519 = load float, float* %518, align 4
  %520 = getelementptr inbounds float, float* %0, i64 7
  %521 = load float, float* %520, align 4
  %522 = fmul float %519, %521
  %523 = load float, float* %511, align 4
  %524 = fadd float %523, %522
  %525 = getelementptr inbounds i8, i8* %339, i64 8
  %526 = bitcast i8* %525 to float*
  %527 = load float, float* %526, align 4
  %528 = getelementptr inbounds float, float* %0, i64 11
  %529 = load float, float* %528, align 4
  %530 = fmul float %527, %529
  %531 = load float, float* %511, align 4
  %532 = fadd float %531, %530
  %533 = getelementptr inbounds i8, i8* %339, i64 12
  %534 = bitcast i8* %533 to float*
  %535 = load float, float* %534, align 4
  %536 = getelementptr inbounds float, float* %0, i64 15
  %537 = load float, float* %536, align 4
  %538 = fmul float %535, %537
  %539 = load float, float* %511, align 4
  %540 = fadd float %539, %538
  %541 = getelementptr inbounds i8, i8* %339, i64 16
  %542 = bitcast i8* %541 to float*
  %543 = getelementptr inbounds float, float* %2, i64 4
  %544 = getelementptr inbounds float, float* %2, i64 4
  %545 = load float, float* %542, align 4
  %546 = load float, float* %0, align 4
  %547 = fmul float %545, %546
  %548 = fadd float %547, 0.000000e+00
  %549 = getelementptr inbounds i8, i8* %339, i64 20
  %550 = bitcast i8* %549 to float*
  %551 = load float, float* %550, align 4
  %552 = getelementptr inbounds float, float* %0, i64 4
  %553 = load float, float* %552, align 4
  %554 = fmul float %551, %553
  %555 = load float, float* %544, align 4
  %556 = fadd float %555, %554
  %557 = getelementptr inbounds i8, i8* %339, i64 24
  %558 = bitcast i8* %557 to float*
  %559 = load float, float* %558, align 4
  %560 = getelementptr inbounds float, float* %0, i64 8
  %561 = load float, float* %560, align 4
  %562 = fmul float %559, %561
  %563 = load float, float* %544, align 4
  %564 = fadd float %563, %562
  %565 = getelementptr inbounds i8, i8* %339, i64 28
  %566 = bitcast i8* %565 to float*
  %567 = load float, float* %566, align 4
  %568 = getelementptr inbounds float, float* %0, i64 12
  %569 = load float, float* %568, align 4
  %570 = fmul float %567, %569
  %571 = load float, float* %544, align 4
  %572 = fadd float %571, %570
  %573 = getelementptr inbounds float, float* %2, i64 5
  %574 = getelementptr inbounds float, float* %2, i64 5
  %575 = load float, float* %542, align 4
  %576 = getelementptr inbounds float, float* %0, i64 1
  %577 = load float, float* %576, align 4
  %578 = fmul float %575, %577
  %579 = fadd float %578, 0.000000e+00
  %580 = getelementptr inbounds i8, i8* %339, i64 20
  %581 = bitcast i8* %580 to float*
  %582 = load float, float* %581, align 4
  %583 = getelementptr inbounds float, float* %0, i64 5
  %584 = load float, float* %583, align 4
  %585 = fmul float %582, %584
  %586 = load float, float* %574, align 4
  %587 = fadd float %586, %585
  %588 = getelementptr inbounds i8, i8* %339, i64 24
  %589 = bitcast i8* %588 to float*
  %590 = load float, float* %589, align 4
  %591 = getelementptr inbounds float, float* %0, i64 9
  %592 = load float, float* %591, align 4
  %593 = fmul float %590, %592
  %594 = load float, float* %574, align 4
  %595 = fadd float %594, %593
  %596 = getelementptr inbounds i8, i8* %339, i64 28
  %597 = bitcast i8* %596 to float*
  %598 = load float, float* %597, align 4
  %599 = getelementptr inbounds float, float* %0, i64 13
  %600 = load float, float* %599, align 4
  %601 = fmul float %598, %600
  %602 = load float, float* %574, align 4
  %603 = fadd float %602, %601
  %604 = getelementptr inbounds float, float* %2, i64 6
  %605 = getelementptr inbounds float, float* %2, i64 6
  %606 = load float, float* %542, align 4
  %607 = getelementptr inbounds float, float* %0, i64 2
  %608 = load float, float* %607, align 4
  %609 = fmul float %606, %608
  %610 = fadd float %609, 0.000000e+00
  %611 = getelementptr inbounds i8, i8* %339, i64 20
  %612 = bitcast i8* %611 to float*
  %613 = load float, float* %612, align 4
  %614 = getelementptr inbounds float, float* %0, i64 6
  %615 = load float, float* %614, align 4
  %616 = fmul float %613, %615
  %617 = load float, float* %605, align 4
  %618 = fadd float %617, %616
  %619 = getelementptr inbounds i8, i8* %339, i64 24
  %620 = bitcast i8* %619 to float*
  %621 = load float, float* %620, align 4
  %622 = getelementptr inbounds float, float* %0, i64 10
  %623 = load float, float* %622, align 4
  %624 = fmul float %621, %623
  %625 = load float, float* %605, align 4
  %626 = fadd float %625, %624
  %627 = getelementptr inbounds i8, i8* %339, i64 28
  %628 = bitcast i8* %627 to float*
  %629 = load float, float* %628, align 4
  %630 = getelementptr inbounds float, float* %0, i64 14
  %631 = load float, float* %630, align 4
  %632 = fmul float %629, %631
  %633 = load float, float* %605, align 4
  %634 = fadd float %633, %632
  %635 = getelementptr inbounds float, float* %2, i64 7
  %636 = getelementptr inbounds float, float* %2, i64 7
  %637 = load float, float* %542, align 4
  %638 = getelementptr inbounds float, float* %0, i64 3
  %639 = load float, float* %638, align 4
  %640 = fmul float %637, %639
  %641 = fadd float %640, 0.000000e+00
  %642 = getelementptr inbounds i8, i8* %339, i64 20
  %643 = bitcast i8* %642 to float*
  %644 = load float, float* %643, align 4
  %645 = getelementptr inbounds float, float* %0, i64 7
  %646 = load float, float* %645, align 4
  %647 = fmul float %644, %646
  %648 = load float, float* %636, align 4
  %649 = fadd float %648, %647
  %650 = getelementptr inbounds i8, i8* %339, i64 24
  %651 = bitcast i8* %650 to float*
  %652 = load float, float* %651, align 4
  %653 = getelementptr inbounds float, float* %0, i64 11
  %654 = load float, float* %653, align 4
  %655 = fmul float %652, %654
  %656 = load float, float* %636, align 4
  %657 = fadd float %656, %655
  %658 = getelementptr inbounds i8, i8* %339, i64 28
  %659 = bitcast i8* %658 to float*
  %660 = load float, float* %659, align 4
  %661 = getelementptr inbounds float, float* %0, i64 15
  %662 = load float, float* %661, align 4
  %663 = fmul float %660, %662
  %664 = load float, float* %636, align 4
  %665 = fadd float %664, %663
  %666 = getelementptr inbounds i8, i8* %339, i64 32
  %667 = bitcast i8* %666 to float*
  %668 = getelementptr inbounds float, float* %2, i64 8
  %669 = getelementptr inbounds float, float* %2, i64 8
  %670 = load float, float* %667, align 4
  %671 = load float, float* %0, align 4
  %672 = fmul float %670, %671
  %673 = fadd float %672, 0.000000e+00
  %674 = getelementptr inbounds i8, i8* %339, i64 36
  %675 = bitcast i8* %674 to float*
  %676 = load float, float* %675, align 4
  %677 = getelementptr inbounds float, float* %0, i64 4
  %678 = load float, float* %677, align 4
  %679 = fmul float %676, %678
  %680 = load float, float* %669, align 4
  %681 = fadd float %680, %679
  %682 = getelementptr inbounds i8, i8* %339, i64 40
  %683 = bitcast i8* %682 to float*
  %684 = load float, float* %683, align 4
  %685 = getelementptr inbounds float, float* %0, i64 8
  %686 = load float, float* %685, align 4
  %687 = fmul float %684, %686
  %688 = load float, float* %669, align 4
  %689 = fadd float %688, %687
  %690 = getelementptr inbounds i8, i8* %339, i64 44
  %691 = bitcast i8* %690 to float*
  %692 = load float, float* %691, align 4
  %693 = getelementptr inbounds float, float* %0, i64 12
  %694 = load float, float* %693, align 4
  %695 = fmul float %692, %694
  %696 = load float, float* %669, align 4
  %697 = fadd float %696, %695
  %698 = getelementptr inbounds float, float* %2, i64 9
  %699 = getelementptr inbounds float, float* %2, i64 9
  %700 = load float, float* %667, align 4
  %701 = getelementptr inbounds float, float* %0, i64 1
  %702 = load float, float* %701, align 4
  %703 = fmul float %700, %702
  %704 = fadd float %703, 0.000000e+00
  %705 = getelementptr inbounds i8, i8* %339, i64 36
  %706 = bitcast i8* %705 to float*
  %707 = load float, float* %706, align 4
  %708 = getelementptr inbounds float, float* %0, i64 5
  %709 = load float, float* %708, align 4
  %710 = fmul float %707, %709
  %711 = load float, float* %699, align 4
  %712 = fadd float %711, %710
  %713 = getelementptr inbounds i8, i8* %339, i64 40
  %714 = bitcast i8* %713 to float*
  %715 = load float, float* %714, align 4
  %716 = getelementptr inbounds float, float* %0, i64 9
  %717 = load float, float* %716, align 4
  %718 = fmul float %715, %717
  %719 = load float, float* %699, align 4
  %720 = fadd float %719, %718
  %721 = getelementptr inbounds i8, i8* %339, i64 44
  %722 = bitcast i8* %721 to float*
  %723 = load float, float* %722, align 4
  %724 = getelementptr inbounds float, float* %0, i64 13
  %725 = load float, float* %724, align 4
  %726 = fmul float %723, %725
  %727 = load float, float* %699, align 4
  %728 = fadd float %727, %726
  %729 = getelementptr inbounds float, float* %2, i64 10
  %730 = getelementptr inbounds float, float* %2, i64 10
  %731 = load float, float* %667, align 4
  %732 = getelementptr inbounds float, float* %0, i64 2
  %733 = load float, float* %732, align 4
  %734 = fmul float %731, %733
  %735 = fadd float %734, 0.000000e+00
  %736 = getelementptr inbounds i8, i8* %339, i64 36
  %737 = bitcast i8* %736 to float*
  %738 = load float, float* %737, align 4
  %739 = getelementptr inbounds float, float* %0, i64 6
  %740 = load float, float* %739, align 4
  %741 = fmul float %738, %740
  %742 = load float, float* %730, align 4
  %743 = fadd float %742, %741
  %744 = getelementptr inbounds i8, i8* %339, i64 40
  %745 = bitcast i8* %744 to float*
  %746 = load float, float* %745, align 4
  %747 = getelementptr inbounds float, float* %0, i64 10
  %748 = load float, float* %747, align 4
  %749 = fmul float %746, %748
  %750 = load float, float* %730, align 4
  %751 = fadd float %750, %749
  %752 = getelementptr inbounds i8, i8* %339, i64 44
  %753 = bitcast i8* %752 to float*
  %754 = load float, float* %753, align 4
  %755 = getelementptr inbounds float, float* %0, i64 14
  %756 = load float, float* %755, align 4
  %757 = fmul float %754, %756
  %758 = load float, float* %730, align 4
  %759 = fadd float %758, %757
  %760 = getelementptr inbounds float, float* %2, i64 11
  %761 = getelementptr inbounds float, float* %2, i64 11
  %762 = load float, float* %667, align 4
  %763 = getelementptr inbounds float, float* %0, i64 3
  %764 = load float, float* %763, align 4
  %765 = fmul float %762, %764
  %766 = fadd float %765, 0.000000e+00
  %767 = getelementptr inbounds i8, i8* %339, i64 36
  %768 = bitcast i8* %767 to float*
  %769 = load float, float* %768, align 4
  %770 = getelementptr inbounds float, float* %0, i64 7
  %771 = load float, float* %770, align 4
  %772 = fmul float %769, %771
  %773 = load float, float* %761, align 4
  %774 = fadd float %773, %772
  %775 = getelementptr inbounds i8, i8* %339, i64 40
  %776 = bitcast i8* %775 to float*
  %777 = load float, float* %776, align 4
  %778 = getelementptr inbounds float, float* %0, i64 11
  %779 = load float, float* %778, align 4
  %780 = fmul float %777, %779
  %781 = load float, float* %761, align 4
  %782 = fadd float %781, %780
  %783 = getelementptr inbounds i8, i8* %339, i64 44
  %784 = bitcast i8* %783 to float*
  %785 = load float, float* %784, align 4
  %786 = getelementptr inbounds float, float* %0, i64 15
  %787 = load float, float* %786, align 4
  %788 = fmul float %785, %787
  %789 = load float, float* %761, align 4
  %790 = fadd float %789, %788
  %791 = getelementptr inbounds i8, i8* %339, i64 48
  %792 = bitcast i8* %791 to float*
  %793 = getelementptr inbounds float, float* %2, i64 12
  %794 = getelementptr inbounds float, float* %2, i64 12
  %795 = load float, float* %792, align 4
  %796 = load float, float* %0, align 4
  %797 = fmul float %795, %796
  %798 = fadd float %797, 0.000000e+00
  %799 = getelementptr inbounds i8, i8* %339, i64 52
  %800 = bitcast i8* %799 to float*
  %801 = load float, float* %800, align 4
  %802 = getelementptr inbounds float, float* %0, i64 4
  %803 = load float, float* %802, align 4
  %804 = fmul float %801, %803
  %805 = load float, float* %794, align 4
  %806 = fadd float %805, %804
  %807 = getelementptr inbounds i8, i8* %339, i64 56
  %808 = bitcast i8* %807 to float*
  %809 = load float, float* %808, align 4
  %810 = getelementptr inbounds float, float* %0, i64 8
  %811 = load float, float* %810, align 4
  %812 = fmul float %809, %811
  %813 = load float, float* %794, align 4
  %814 = fadd float %813, %812
  %815 = getelementptr inbounds i8, i8* %339, i64 60
  %816 = bitcast i8* %815 to float*
  %817 = load float, float* %816, align 4
  %818 = getelementptr inbounds float, float* %0, i64 12
  %819 = load float, float* %818, align 4
  %820 = fmul float %817, %819
  %821 = load float, float* %794, align 4
  %822 = fadd float %821, %820
  %823 = getelementptr inbounds float, float* %2, i64 13
  %824 = getelementptr inbounds float, float* %2, i64 13
  %825 = load float, float* %792, align 4
  %826 = getelementptr inbounds float, float* %0, i64 1
  %827 = load float, float* %826, align 4
  %828 = fmul float %825, %827
  %829 = fadd float %828, 0.000000e+00
  %830 = getelementptr inbounds i8, i8* %339, i64 52
  %831 = bitcast i8* %830 to float*
  %832 = load float, float* %831, align 4
  %833 = getelementptr inbounds float, float* %0, i64 5
  %834 = load float, float* %833, align 4
  %835 = fmul float %832, %834
  %836 = load float, float* %824, align 4
  %837 = fadd float %836, %835
  %838 = getelementptr inbounds i8, i8* %339, i64 56
  %839 = bitcast i8* %838 to float*
  %840 = load float, float* %839, align 4
  %841 = getelementptr inbounds float, float* %0, i64 9
  %842 = load float, float* %841, align 4
  %843 = fmul float %840, %842
  %844 = load float, float* %824, align 4
  %845 = fadd float %844, %843
  %846 = getelementptr inbounds i8, i8* %339, i64 60
  %847 = bitcast i8* %846 to float*
  %848 = load float, float* %847, align 4
  %849 = getelementptr inbounds float, float* %0, i64 13
  %850 = load float, float* %849, align 4
  %851 = fmul float %848, %850
  %852 = load float, float* %824, align 4
  %853 = fadd float %852, %851
  %854 = getelementptr inbounds float, float* %2, i64 14
  %855 = getelementptr inbounds float, float* %2, i64 14
  %856 = load float, float* %792, align 4
  %857 = getelementptr inbounds float, float* %0, i64 2
  %858 = load float, float* %857, align 4
  %859 = fmul float %856, %858
  %860 = fadd float %859, 0.000000e+00
  %861 = getelementptr inbounds i8, i8* %339, i64 52
  %862 = bitcast i8* %861 to float*
  %863 = load float, float* %862, align 4
  %864 = getelementptr inbounds float, float* %0, i64 6
  %865 = load float, float* %864, align 4
  %866 = fmul float %863, %865
  %867 = load float, float* %855, align 4
  %868 = fadd float %867, %866
  %869 = getelementptr inbounds i8, i8* %339, i64 56
  %870 = bitcast i8* %869 to float*
  %871 = load float, float* %870, align 4
  %872 = getelementptr inbounds float, float* %0, i64 10
  %873 = load float, float* %872, align 4
  %874 = fmul float %871, %873
  %875 = load float, float* %855, align 4
  %876 = fadd float %875, %874
  %877 = getelementptr inbounds i8, i8* %339, i64 60
  %878 = bitcast i8* %877 to float*
  %879 = load float, float* %878, align 4
  %880 = getelementptr inbounds float, float* %0, i64 14
  %881 = load float, float* %880, align 4
  %882 = fmul float %879, %881
  %883 = load float, float* %855, align 4
  %884 = fadd float %883, %882
  %885 = getelementptr inbounds float, float* %2, i64 15
  %886 = getelementptr inbounds float, float* %2, i64 15
  %887 = load float, float* %792, align 4
  %888 = getelementptr inbounds float, float* %0, i64 3
  %889 = load float, float* %888, align 4
  %890 = fmul float %887, %889
  %891 = fadd float %890, 0.000000e+00
  %892 = getelementptr inbounds i8, i8* %339, i64 52
  %893 = bitcast i8* %892 to float*
  %894 = load float, float* %893, align 4
  %895 = getelementptr inbounds float, float* %0, i64 7
  %896 = load float, float* %895, align 4
  %897 = fmul float %894, %896
  %898 = load float, float* %886, align 4
  %899 = fadd float %898, %897
  %900 = getelementptr inbounds i8, i8* %339, i64 56
  %901 = bitcast i8* %900 to float*
  %902 = load float, float* %901, align 4
  %903 = getelementptr inbounds float, float* %0, i64 11
  %904 = load float, float* %903, align 4
  %905 = fmul float %902, %904
  %906 = load float, float* %886, align 4
  %907 = fadd float %906, %905
  %908 = getelementptr inbounds i8, i8* %339, i64 60
  %909 = bitcast i8* %908 to float*
  %910 = load float, float* %909, align 4
  %911 = getelementptr inbounds float, float* %0, i64 15
  %912 = load float, float* %911, align 4
  %913 = fmul float %910, %912
  %914 = load float, float* %886, align 4
  %915 = fadd float %914, %913
  call void @free(i8* %49)
  call void @free(i8* %51)
  call void @free(i8* %123)
  call void @free(i8* %125)
  call void @free(i8* %207)
  call void @free(i8* %339)
  %916 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %917 = bitcast i8* %916 to float*
  %918 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %919 = bitcast i8* %918 to float*
  %920 = getelementptr inbounds float, float* %2, i64 5
  %921 = bitcast float* %920 to i32*
  %922 = load i32, i32* %921, align 4
  %923 = bitcast i8* %916 to i32*
  %924 = getelementptr inbounds i8, i8* %8, i64 20
  %925 = bitcast i8* %924 to i32*
  %926 = load i32, i32* %925, align 4
  %927 = bitcast i8* %918 to i32*
  %928 = getelementptr inbounds float, float* %2, i64 9
  %929 = bitcast float* %928 to i32*
  %930 = load i32, i32* %929, align 4
  %931 = getelementptr inbounds i8, i8* %916, i64 4
  %932 = bitcast i8* %931 to i32*
  %933 = getelementptr inbounds i8, i8* %8, i64 36
  %934 = bitcast i8* %933 to i32*
  %935 = load i32, i32* %934, align 4
  %936 = getelementptr inbounds i8, i8* %918, i64 4
  %937 = bitcast i8* %936 to i32*
  %938 = getelementptr inbounds float, float* %2, i64 13
  %939 = bitcast float* %938 to i32*
  %940 = load i32, i32* %939, align 4
  %941 = getelementptr inbounds i8, i8* %916, i64 8
  %942 = bitcast i8* %941 to i32*
  %943 = getelementptr inbounds i8, i8* %8, i64 52
  %944 = bitcast i8* %943 to i32*
  %945 = load i32, i32* %944, align 4
  %946 = getelementptr inbounds i8, i8* %918, i64 8
  %947 = bitcast i8* %946 to i32*
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
  %975 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %976 = bitcast i8* %975 to float*
  %977 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %978 = load float, float* %917, align 4
  %979 = load float, float* %919, align 4
  %980 = fmul float %974, %979
  %981 = fadd float %978, %980
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
  %1024 = getelementptr inbounds i8, i8* %975, i64 4
  %1025 = bitcast i8* %1024 to float*
  %1026 = load float, float* %1025, align 4
  %1027 = fdiv float %1026, %1021
  %1028 = getelementptr inbounds i8, i8* %977, i64 4
  %1029 = bitcast i8* %1028 to float*
  %1030 = getelementptr inbounds i8, i8* %975, i64 8
  %1031 = bitcast i8* %1030 to float*
  %1032 = load float, float* %1031, align 4
  %1033 = fdiv float %1032, %1021
  %1034 = getelementptr inbounds i8, i8* %977, i64 8
  %1035 = bitcast i8* %1034 to float*
  %1036 = call dereferenceable_or_null(36) i8* @calloc(i64 4, i64 9) #10
  %1037 = bitcast i8* %1036 to float*
  %1038 = load float, float* %1020, align 4
  %1039 = fmul float %1038, 2.000000e+00
  %1040 = fmul float %1039, %1038
  %1041 = fsub float 1.000000e+00, %1040
  %1042 = load float, float* %1020, align 4
  %1043 = fmul float %1042, 2.000000e+00
  %1044 = getelementptr inbounds i8, i8* %977, i64 4
  %1045 = bitcast i8* %1044 to float*
  %1046 = load float, float* %1045, align 4
  %1047 = fmul float %1043, %1046
  %1048 = fsub float 0.000000e+00, %1047
  %1049 = getelementptr inbounds i8, i8* %1036, i64 4
  %1050 = bitcast i8* %1049 to float*
  %1051 = load float, float* %1020, align 4
  %1052 = fmul float %1051, 2.000000e+00
  %1053 = getelementptr inbounds i8, i8* %977, i64 8
  %1054 = bitcast i8* %1053 to float*
  %1055 = load float, float* %1054, align 4
  %1056 = fmul float %1052, %1055
  %1057 = fsub float 0.000000e+00, %1056
  %1058 = getelementptr inbounds i8, i8* %1036, i64 8
  %1059 = bitcast i8* %1058 to float*
  %1060 = getelementptr inbounds i8, i8* %977, i64 4
  %1061 = bitcast i8* %1060 to float*
  %1062 = load float, float* %1061, align 4
  %1063 = fmul float %1062, 2.000000e+00
  %1064 = load float, float* %1020, align 4
  %1065 = fmul float %1063, %1064
  %1066 = fsub float 0.000000e+00, %1065
  %1067 = getelementptr inbounds i8, i8* %1036, i64 12
  %1068 = bitcast i8* %1067 to float*
  %1069 = load float, float* %1061, align 4
  %1070 = fmul float %1069, 2.000000e+00
  %1071 = fmul float %1070, %1069
  %1072 = fsub float 1.000000e+00, %1071
  %1073 = getelementptr inbounds i8, i8* %1036, i64 16
  %1074 = bitcast i8* %1073 to float*
  %1075 = load float, float* %1061, align 4
  %1076 = fmul float %1075, 2.000000e+00
  %1077 = getelementptr inbounds i8, i8* %977, i64 8
  %1078 = bitcast i8* %1077 to float*
  %1079 = load float, float* %1078, align 4
  %1080 = fmul float %1076, %1079
  %1081 = fsub float 0.000000e+00, %1080
  %1082 = getelementptr inbounds i8, i8* %1036, i64 20
  %1083 = bitcast i8* %1082 to float*
  %1084 = getelementptr inbounds i8, i8* %977, i64 8
  %1085 = bitcast i8* %1084 to float*
  %1086 = load float, float* %1085, align 4
  %1087 = fmul float %1086, 2.000000e+00
  %1088 = load float, float* %1020, align 4
  %1089 = fmul float %1087, %1088
  %1090 = fsub float 0.000000e+00, %1089
  %1091 = getelementptr inbounds i8, i8* %1036, i64 24
  %1092 = bitcast i8* %1091 to float*
  %1093 = load float, float* %1085, align 4
  %1094 = fmul float %1093, 2.000000e+00
  %1095 = getelementptr inbounds i8, i8* %977, i64 4
  %1096 = bitcast i8* %1095 to float*
  %1097 = load float, float* %1096, align 4
  %1098 = fmul float %1094, %1097
  %1099 = fsub float 0.000000e+00, %1098
  %1100 = getelementptr inbounds i8, i8* %1036, i64 28
  %1101 = bitcast i8* %1100 to float*
  %1102 = load float, float* %1085, align 4
  %1103 = fmul float %1102, 2.000000e+00
  %1104 = fmul float %1103, %1102
  %1105 = fsub float 1.000000e+00, %1104
  %1106 = getelementptr inbounds i8, i8* %1036, i64 32
  %1107 = bitcast i8* %1106 to float*
  %1108 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %1109 = bitcast i8* %1108 to float*
  %1110 = getelementptr inbounds i8, i8* %1108, i64 4
  %1111 = bitcast i8* %1110 to float*
  %1112 = getelementptr inbounds i8, i8* %1108, i64 8
  %1113 = bitcast i8* %1112 to float*
  %1114 = getelementptr inbounds i8, i8* %1108, i64 12
  %1115 = bitcast i8* %1114 to float*
  %1116 = getelementptr inbounds i8, i8* %1108, i64 16
  %1117 = bitcast i8* %1116 to float*
  %1118 = bitcast i8* %1036 to i32*
  %1119 = load i32, i32* %1118, align 4
  %1120 = getelementptr inbounds i8, i8* %1108, i64 20
  %1121 = bitcast i8* %1120 to i32*
  %1122 = getelementptr inbounds i8, i8* %1036, i64 4
  %1123 = bitcast i8* %1122 to i32*
  %1124 = load i32, i32* %1123, align 4
  %1125 = getelementptr inbounds i8, i8* %1108, i64 24
  %1126 = bitcast i8* %1125 to i32*
  %1127 = getelementptr inbounds i8, i8* %1036, i64 8
  %1128 = bitcast i8* %1127 to i32*
  %1129 = load i32, i32* %1128, align 4
  %1130 = getelementptr inbounds i8, i8* %1108, i64 28
  %1131 = bitcast i8* %1130 to i32*
  %1132 = getelementptr inbounds i8, i8* %1108, i64 32
  %1133 = bitcast i8* %1132 to float*
  %1134 = getelementptr inbounds i8, i8* %1036, i64 12
  %1135 = bitcast i8* %1134 to i32*
  %1136 = load i32, i32* %1135, align 4
  %1137 = getelementptr inbounds i8, i8* %1108, i64 36
  %1138 = bitcast i8* %1137 to i32*
  %1139 = getelementptr inbounds i8, i8* %1036, i64 16
  %1140 = bitcast i8* %1139 to i32*
  %1141 = load i32, i32* %1140, align 4
  %1142 = getelementptr inbounds i8, i8* %1108, i64 40
  %1143 = bitcast i8* %1142 to i32*
  %1144 = getelementptr inbounds i8, i8* %1036, i64 20
  %1145 = bitcast i8* %1144 to i32*
  %1146 = load i32, i32* %1145, align 4
  %1147 = getelementptr inbounds i8, i8* %1108, i64 44
  %1148 = bitcast i8* %1147 to i32*
  %1149 = getelementptr inbounds i8, i8* %1108, i64 48
  %1150 = bitcast i8* %1149 to float*
  %1151 = getelementptr inbounds i8, i8* %1036, i64 24
  %1152 = bitcast i8* %1151 to i32*
  %1153 = load i32, i32* %1152, align 4
  %1154 = getelementptr inbounds i8, i8* %1108, i64 52
  %1155 = bitcast i8* %1154 to i32*
  %1156 = getelementptr inbounds i8, i8* %1036, i64 28
  %1157 = bitcast i8* %1156 to i32*
  %1158 = load i32, i32* %1157, align 4
  %1159 = getelementptr inbounds i8, i8* %1108, i64 56
  %1160 = bitcast i8* %1159 to i32*
  %1161 = getelementptr inbounds i8, i8* %1036, i64 32
  %1162 = bitcast i8* %1161 to i32*
  %1163 = load i32, i32* %1162, align 4
  %1164 = getelementptr inbounds i8, i8* %1108, i64 60
  %1165 = bitcast i8* %1164 to i32*
  %1166 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %1167 = bitcast i8* %1166 to float*
  %1168 = load float, float* %1109, align 4
  %1169 = load float, float* %1, align 4
  %1170 = fmul float %1168, %1169
  %1171 = fadd float %1170, 0.000000e+00
  %1172 = getelementptr inbounds i8, i8* %1108, i64 4
  %1173 = bitcast i8* %1172 to float*
  %1174 = load float, float* %1173, align 4
  %1175 = getelementptr inbounds float, float* %1, i64 4
  %1176 = load float, float* %1175, align 4
  %1177 = fmul float %1174, %1176
  %1178 = load float, float* %1167, align 4
  %1179 = fadd float %1178, %1177
  %1180 = getelementptr inbounds i8, i8* %1108, i64 8
  %1181 = bitcast i8* %1180 to float*
  %1182 = load float, float* %1181, align 4
  %1183 = getelementptr inbounds float, float* %1, i64 8
  %1184 = load float, float* %1183, align 4
  %1185 = fmul float %1182, %1184
  %1186 = load float, float* %1167, align 4
  %1187 = fadd float %1186, %1185
  %1188 = getelementptr inbounds i8, i8* %1108, i64 12
  %1189 = bitcast i8* %1188 to float*
  %1190 = load float, float* %1189, align 4
  %1191 = getelementptr inbounds float, float* %1, i64 12
  %1192 = load float, float* %1191, align 4
  %1193 = fmul float %1190, %1192
  %1194 = load float, float* %1167, align 4
  %1195 = fadd float %1194, %1193
  %1196 = getelementptr inbounds i8, i8* %1166, i64 4
  %1197 = bitcast i8* %1196 to float*
  %1198 = getelementptr inbounds i8, i8* %1166, i64 4
  %1199 = bitcast i8* %1198 to float*
  %1200 = load float, float* %1109, align 4
  %1201 = getelementptr inbounds float, float* %1, i64 1
  %1202 = load float, float* %1201, align 4
  %1203 = fmul float %1200, %1202
  %1204 = load float, float* %1199, align 4
  %1205 = fadd float %1204, %1203
  %1206 = getelementptr inbounds i8, i8* %1108, i64 4
  %1207 = bitcast i8* %1206 to float*
  %1208 = load float, float* %1207, align 4
  %1209 = getelementptr inbounds float, float* %1, i64 5
  %1210 = load float, float* %1209, align 4
  %1211 = fmul float %1208, %1210
  %1212 = load float, float* %1199, align 4
  %1213 = fadd float %1212, %1211
  %1214 = getelementptr inbounds i8, i8* %1108, i64 8
  %1215 = bitcast i8* %1214 to float*
  %1216 = load float, float* %1215, align 4
  %1217 = getelementptr inbounds float, float* %1, i64 9
  %1218 = load float, float* %1217, align 4
  %1219 = fmul float %1216, %1218
  %1220 = load float, float* %1199, align 4
  %1221 = fadd float %1220, %1219
  %1222 = getelementptr inbounds i8, i8* %1108, i64 12
  %1223 = bitcast i8* %1222 to float*
  %1224 = load float, float* %1223, align 4
  %1225 = getelementptr inbounds float, float* %1, i64 13
  %1226 = load float, float* %1225, align 4
  %1227 = fmul float %1224, %1226
  %1228 = load float, float* %1199, align 4
  %1229 = fadd float %1228, %1227
  %1230 = getelementptr inbounds i8, i8* %1166, i64 8
  %1231 = bitcast i8* %1230 to float*
  %1232 = getelementptr inbounds i8, i8* %1166, i64 8
  %1233 = bitcast i8* %1232 to float*
  %1234 = load float, float* %1109, align 4
  %1235 = getelementptr inbounds float, float* %1, i64 2
  %1236 = load float, float* %1235, align 4
  %1237 = fmul float %1234, %1236
  %1238 = load float, float* %1233, align 4
  %1239 = fadd float %1238, %1237
  %1240 = getelementptr inbounds i8, i8* %1108, i64 4
  %1241 = bitcast i8* %1240 to float*
  %1242 = load float, float* %1241, align 4
  %1243 = getelementptr inbounds float, float* %1, i64 6
  %1244 = load float, float* %1243, align 4
  %1245 = fmul float %1242, %1244
  %1246 = load float, float* %1233, align 4
  %1247 = fadd float %1246, %1245
  %1248 = getelementptr inbounds i8, i8* %1108, i64 8
  %1249 = bitcast i8* %1248 to float*
  %1250 = load float, float* %1249, align 4
  %1251 = getelementptr inbounds float, float* %1, i64 10
  %1252 = load float, float* %1251, align 4
  %1253 = fmul float %1250, %1252
  %1254 = load float, float* %1233, align 4
  %1255 = fadd float %1254, %1253
  %1256 = getelementptr inbounds i8, i8* %1108, i64 12
  %1257 = bitcast i8* %1256 to float*
  %1258 = load float, float* %1257, align 4
  %1259 = getelementptr inbounds float, float* %1, i64 14
  %1260 = load float, float* %1259, align 4
  %1261 = fmul float %1258, %1260
  %1262 = load float, float* %1233, align 4
  %1263 = fadd float %1262, %1261
  %1264 = getelementptr inbounds i8, i8* %1166, i64 12
  %1265 = bitcast i8* %1264 to float*
  %1266 = getelementptr inbounds i8, i8* %1166, i64 12
  %1267 = bitcast i8* %1266 to float*
  %1268 = load float, float* %1109, align 4
  %1269 = getelementptr inbounds float, float* %1, i64 3
  %1270 = load float, float* %1269, align 4
  %1271 = fmul float %1268, %1270
  %1272 = load float, float* %1267, align 4
  %1273 = fadd float %1272, %1271
  %1274 = getelementptr inbounds i8, i8* %1108, i64 4
  %1275 = bitcast i8* %1274 to float*
  %1276 = load float, float* %1275, align 4
  %1277 = getelementptr inbounds float, float* %1, i64 7
  %1278 = load float, float* %1277, align 4
  %1279 = fmul float %1276, %1278
  %1280 = load float, float* %1267, align 4
  %1281 = fadd float %1280, %1279
  %1282 = getelementptr inbounds i8, i8* %1108, i64 8
  %1283 = bitcast i8* %1282 to float*
  %1284 = load float, float* %1283, align 4
  %1285 = getelementptr inbounds float, float* %1, i64 11
  %1286 = load float, float* %1285, align 4
  %1287 = fmul float %1284, %1286
  %1288 = load float, float* %1267, align 4
  %1289 = fadd float %1288, %1287
  %1290 = getelementptr inbounds i8, i8* %1108, i64 12
  %1291 = bitcast i8* %1290 to float*
  %1292 = load float, float* %1291, align 4
  %1293 = getelementptr inbounds float, float* %1, i64 15
  %1294 = load float, float* %1293, align 4
  %1295 = fmul float %1292, %1294
  %1296 = load float, float* %1267, align 4
  %1297 = fadd float %1296, %1295
  %1298 = getelementptr inbounds i8, i8* %1108, i64 16
  %1299 = bitcast i8* %1298 to float*
  %1300 = getelementptr inbounds i8, i8* %1166, i64 16
  %1301 = bitcast i8* %1300 to float*
  %1302 = getelementptr inbounds i8, i8* %1166, i64 16
  %1303 = bitcast i8* %1302 to float*
  %1304 = load float, float* %1299, align 4
  %1305 = load float, float* %1, align 4
  %1306 = fmul float %1304, %1305
  %1307 = fadd float %1306, 0.000000e+00
  %1308 = getelementptr inbounds i8, i8* %1108, i64 20
  %1309 = bitcast i8* %1308 to float*
  %1310 = load float, float* %1309, align 4
  %1311 = getelementptr inbounds float, float* %1, i64 4
  %1312 = load float, float* %1311, align 4
  %1313 = fmul float %1310, %1312
  %1314 = load float, float* %1303, align 4
  %1315 = fadd float %1314, %1313
  %1316 = getelementptr inbounds i8, i8* %1108, i64 24
  %1317 = bitcast i8* %1316 to float*
  %1318 = load float, float* %1317, align 4
  %1319 = getelementptr inbounds float, float* %1, i64 8
  %1320 = load float, float* %1319, align 4
  %1321 = fmul float %1318, %1320
  %1322 = load float, float* %1303, align 4
  %1323 = fadd float %1322, %1321
  %1324 = getelementptr inbounds i8, i8* %1108, i64 28
  %1325 = bitcast i8* %1324 to float*
  %1326 = load float, float* %1325, align 4
  %1327 = getelementptr inbounds float, float* %1, i64 12
  %1328 = load float, float* %1327, align 4
  %1329 = fmul float %1326, %1328
  %1330 = load float, float* %1303, align 4
  %1331 = fadd float %1330, %1329
  %1332 = getelementptr inbounds i8, i8* %1166, i64 20
  %1333 = bitcast i8* %1332 to float*
  %1334 = getelementptr inbounds i8, i8* %1166, i64 20
  %1335 = bitcast i8* %1334 to float*
  %1336 = load float, float* %1299, align 4
  %1337 = getelementptr inbounds float, float* %1, i64 1
  %1338 = load float, float* %1337, align 4
  %1339 = fmul float %1336, %1338
  %1340 = load float, float* %1335, align 4
  %1341 = fadd float %1340, %1339
  %1342 = getelementptr inbounds i8, i8* %1108, i64 20
  %1343 = bitcast i8* %1342 to float*
  %1344 = load float, float* %1343, align 4
  %1345 = getelementptr inbounds float, float* %1, i64 5
  %1346 = load float, float* %1345, align 4
  %1347 = fmul float %1344, %1346
  %1348 = load float, float* %1335, align 4
  %1349 = fadd float %1348, %1347
  %1350 = getelementptr inbounds i8, i8* %1108, i64 24
  %1351 = bitcast i8* %1350 to float*
  %1352 = load float, float* %1351, align 4
  %1353 = getelementptr inbounds float, float* %1, i64 9
  %1354 = load float, float* %1353, align 4
  %1355 = fmul float %1352, %1354
  %1356 = load float, float* %1335, align 4
  %1357 = fadd float %1356, %1355
  %1358 = getelementptr inbounds i8, i8* %1108, i64 28
  %1359 = bitcast i8* %1358 to float*
  %1360 = load float, float* %1359, align 4
  %1361 = getelementptr inbounds float, float* %1, i64 13
  %1362 = load float, float* %1361, align 4
  %1363 = fmul float %1360, %1362
  %1364 = load float, float* %1335, align 4
  %1365 = fadd float %1364, %1363
  %1366 = getelementptr inbounds i8, i8* %1166, i64 24
  %1367 = bitcast i8* %1366 to float*
  %1368 = getelementptr inbounds i8, i8* %1166, i64 24
  %1369 = bitcast i8* %1368 to float*
  %1370 = load float, float* %1299, align 4
  %1371 = getelementptr inbounds float, float* %1, i64 2
  %1372 = load float, float* %1371, align 4
  %1373 = fmul float %1370, %1372
  %1374 = load float, float* %1369, align 4
  %1375 = fadd float %1374, %1373
  %1376 = getelementptr inbounds i8, i8* %1108, i64 20
  %1377 = bitcast i8* %1376 to float*
  %1378 = load float, float* %1377, align 4
  %1379 = getelementptr inbounds float, float* %1, i64 6
  %1380 = load float, float* %1379, align 4
  %1381 = fmul float %1378, %1380
  %1382 = load float, float* %1369, align 4
  %1383 = fadd float %1382, %1381
  %1384 = getelementptr inbounds i8, i8* %1108, i64 24
  %1385 = bitcast i8* %1384 to float*
  %1386 = load float, float* %1385, align 4
  %1387 = getelementptr inbounds float, float* %1, i64 10
  %1388 = load float, float* %1387, align 4
  %1389 = fmul float %1386, %1388
  %1390 = load float, float* %1369, align 4
  %1391 = fadd float %1390, %1389
  %1392 = getelementptr inbounds i8, i8* %1108, i64 28
  %1393 = bitcast i8* %1392 to float*
  %1394 = load float, float* %1393, align 4
  %1395 = getelementptr inbounds float, float* %1, i64 14
  %1396 = load float, float* %1395, align 4
  %1397 = fmul float %1394, %1396
  %1398 = load float, float* %1369, align 4
  %1399 = fadd float %1398, %1397
  %1400 = getelementptr inbounds i8, i8* %1166, i64 28
  %1401 = bitcast i8* %1400 to float*
  %1402 = getelementptr inbounds i8, i8* %1166, i64 28
  %1403 = bitcast i8* %1402 to float*
  %1404 = load float, float* %1299, align 4
  %1405 = getelementptr inbounds float, float* %1, i64 3
  %1406 = load float, float* %1405, align 4
  %1407 = fmul float %1404, %1406
  %1408 = load float, float* %1403, align 4
  %1409 = fadd float %1408, %1407
  %1410 = getelementptr inbounds i8, i8* %1108, i64 20
  %1411 = bitcast i8* %1410 to float*
  %1412 = load float, float* %1411, align 4
  %1413 = getelementptr inbounds float, float* %1, i64 7
  %1414 = load float, float* %1413, align 4
  %1415 = fmul float %1412, %1414
  %1416 = load float, float* %1403, align 4
  %1417 = fadd float %1416, %1415
  %1418 = getelementptr inbounds i8, i8* %1108, i64 24
  %1419 = bitcast i8* %1418 to float*
  %1420 = load float, float* %1419, align 4
  %1421 = getelementptr inbounds float, float* %1, i64 11
  %1422 = load float, float* %1421, align 4
  %1423 = fmul float %1420, %1422
  %1424 = load float, float* %1403, align 4
  %1425 = fadd float %1424, %1423
  %1426 = getelementptr inbounds i8, i8* %1108, i64 28
  %1427 = bitcast i8* %1426 to float*
  %1428 = load float, float* %1427, align 4
  %1429 = getelementptr inbounds float, float* %1, i64 15
  %1430 = load float, float* %1429, align 4
  %1431 = fmul float %1428, %1430
  %1432 = load float, float* %1403, align 4
  %1433 = fadd float %1432, %1431
  %1434 = getelementptr inbounds i8, i8* %1108, i64 32
  %1435 = bitcast i8* %1434 to float*
  %1436 = getelementptr inbounds i8, i8* %1166, i64 32
  %1437 = bitcast i8* %1436 to float*
  %1438 = getelementptr inbounds i8, i8* %1166, i64 32
  %1439 = bitcast i8* %1438 to float*
  %1440 = load float, float* %1435, align 4
  %1441 = load float, float* %1, align 4
  %1442 = fmul float %1440, %1441
  %1443 = fadd float %1442, 0.000000e+00
  %1444 = getelementptr inbounds i8, i8* %1108, i64 36
  %1445 = bitcast i8* %1444 to float*
  %1446 = load float, float* %1445, align 4
  %1447 = getelementptr inbounds float, float* %1, i64 4
  %1448 = load float, float* %1447, align 4
  %1449 = fmul float %1446, %1448
  %1450 = load float, float* %1439, align 4
  %1451 = fadd float %1450, %1449
  %1452 = getelementptr inbounds i8, i8* %1108, i64 40
  %1453 = bitcast i8* %1452 to float*
  %1454 = load float, float* %1453, align 4
  %1455 = getelementptr inbounds float, float* %1, i64 8
  %1456 = load float, float* %1455, align 4
  %1457 = fmul float %1454, %1456
  %1458 = load float, float* %1439, align 4
  %1459 = fadd float %1458, %1457
  %1460 = getelementptr inbounds i8, i8* %1108, i64 44
  %1461 = bitcast i8* %1460 to float*
  %1462 = load float, float* %1461, align 4
  %1463 = getelementptr inbounds float, float* %1, i64 12
  %1464 = load float, float* %1463, align 4
  %1465 = fmul float %1462, %1464
  %1466 = load float, float* %1439, align 4
  %1467 = fadd float %1466, %1465
  %1468 = getelementptr inbounds i8, i8* %1166, i64 36
  %1469 = bitcast i8* %1468 to float*
  %1470 = getelementptr inbounds i8, i8* %1166, i64 36
  %1471 = bitcast i8* %1470 to float*
  %1472 = load float, float* %1435, align 4
  %1473 = getelementptr inbounds float, float* %1, i64 1
  %1474 = load float, float* %1473, align 4
  %1475 = fmul float %1472, %1474
  %1476 = load float, float* %1471, align 4
  %1477 = fadd float %1476, %1475
  %1478 = getelementptr inbounds i8, i8* %1108, i64 36
  %1479 = bitcast i8* %1478 to float*
  %1480 = load float, float* %1479, align 4
  %1481 = getelementptr inbounds float, float* %1, i64 5
  %1482 = load float, float* %1481, align 4
  %1483 = fmul float %1480, %1482
  %1484 = load float, float* %1471, align 4
  %1485 = fadd float %1484, %1483
  %1486 = getelementptr inbounds i8, i8* %1108, i64 40
  %1487 = bitcast i8* %1486 to float*
  %1488 = load float, float* %1487, align 4
  %1489 = getelementptr inbounds float, float* %1, i64 9
  %1490 = load float, float* %1489, align 4
  %1491 = fmul float %1488, %1490
  %1492 = load float, float* %1471, align 4
  %1493 = fadd float %1492, %1491
  %1494 = getelementptr inbounds i8, i8* %1108, i64 44
  %1495 = bitcast i8* %1494 to float*
  %1496 = load float, float* %1495, align 4
  %1497 = getelementptr inbounds float, float* %1, i64 13
  %1498 = load float, float* %1497, align 4
  %1499 = fmul float %1496, %1498
  %1500 = load float, float* %1471, align 4
  %1501 = fadd float %1500, %1499
  %1502 = getelementptr inbounds i8, i8* %1166, i64 40
  %1503 = bitcast i8* %1502 to float*
  %1504 = getelementptr inbounds i8, i8* %1166, i64 40
  %1505 = bitcast i8* %1504 to float*
  %1506 = load float, float* %1435, align 4
  %1507 = getelementptr inbounds float, float* %1, i64 2
  %1508 = load float, float* %1507, align 4
  %1509 = fmul float %1506, %1508
  %1510 = load float, float* %1505, align 4
  %1511 = fadd float %1510, %1509
  %1512 = getelementptr inbounds i8, i8* %1108, i64 36
  %1513 = bitcast i8* %1512 to float*
  %1514 = load float, float* %1513, align 4
  %1515 = getelementptr inbounds float, float* %1, i64 6
  %1516 = load float, float* %1515, align 4
  %1517 = fmul float %1514, %1516
  %1518 = load float, float* %1505, align 4
  %1519 = fadd float %1518, %1517
  %1520 = getelementptr inbounds i8, i8* %1108, i64 40
  %1521 = bitcast i8* %1520 to float*
  %1522 = load float, float* %1521, align 4
  %1523 = getelementptr inbounds float, float* %1, i64 10
  %1524 = load float, float* %1523, align 4
  %1525 = fmul float %1522, %1524
  %1526 = load float, float* %1505, align 4
  %1527 = fadd float %1526, %1525
  %1528 = getelementptr inbounds i8, i8* %1108, i64 44
  %1529 = bitcast i8* %1528 to float*
  %1530 = load float, float* %1529, align 4
  %1531 = getelementptr inbounds float, float* %1, i64 14
  %1532 = load float, float* %1531, align 4
  %1533 = fmul float %1530, %1532
  %1534 = load float, float* %1505, align 4
  %1535 = fadd float %1534, %1533
  %1536 = getelementptr inbounds i8, i8* %1166, i64 44
  %1537 = bitcast i8* %1536 to float*
  %1538 = getelementptr inbounds i8, i8* %1166, i64 44
  %1539 = bitcast i8* %1538 to float*
  %1540 = load float, float* %1435, align 4
  %1541 = getelementptr inbounds float, float* %1, i64 3
  %1542 = load float, float* %1541, align 4
  %1543 = fmul float %1540, %1542
  %1544 = load float, float* %1539, align 4
  %1545 = fadd float %1544, %1543
  %1546 = getelementptr inbounds i8, i8* %1108, i64 36
  %1547 = bitcast i8* %1546 to float*
  %1548 = load float, float* %1547, align 4
  %1549 = getelementptr inbounds float, float* %1, i64 7
  %1550 = load float, float* %1549, align 4
  %1551 = fmul float %1548, %1550
  %1552 = load float, float* %1539, align 4
  %1553 = fadd float %1552, %1551
  %1554 = getelementptr inbounds i8, i8* %1108, i64 40
  %1555 = bitcast i8* %1554 to float*
  %1556 = load float, float* %1555, align 4
  %1557 = getelementptr inbounds float, float* %1, i64 11
  %1558 = load float, float* %1557, align 4
  %1559 = fmul float %1556, %1558
  %1560 = load float, float* %1539, align 4
  %1561 = fadd float %1560, %1559
  %1562 = getelementptr inbounds i8, i8* %1108, i64 44
  %1563 = bitcast i8* %1562 to float*
  %1564 = load float, float* %1563, align 4
  %1565 = getelementptr inbounds float, float* %1, i64 15
  %1566 = load float, float* %1565, align 4
  %1567 = fmul float %1564, %1566
  %1568 = load float, float* %1539, align 4
  %1569 = fadd float %1568, %1567
  %1570 = getelementptr inbounds i8, i8* %1108, i64 48
  %1571 = bitcast i8* %1570 to float*
  %1572 = getelementptr inbounds i8, i8* %1166, i64 48
  %1573 = bitcast i8* %1572 to float*
  %1574 = getelementptr inbounds i8, i8* %1166, i64 48
  %1575 = bitcast i8* %1574 to float*
  %1576 = load float, float* %1571, align 4
  %1577 = load float, float* %1, align 4
  %1578 = fmul float %1576, %1577
  %1579 = fadd float %1578, 0.000000e+00
  %1580 = getelementptr inbounds i8, i8* %1108, i64 52
  %1581 = bitcast i8* %1580 to float*
  %1582 = load float, float* %1581, align 4
  %1583 = getelementptr inbounds float, float* %1, i64 4
  %1584 = load float, float* %1583, align 4
  %1585 = fmul float %1582, %1584
  %1586 = load float, float* %1575, align 4
  %1587 = fadd float %1586, %1585
  %1588 = getelementptr inbounds i8, i8* %1108, i64 56
  %1589 = bitcast i8* %1588 to float*
  %1590 = load float, float* %1589, align 4
  %1591 = getelementptr inbounds float, float* %1, i64 8
  %1592 = load float, float* %1591, align 4
  %1593 = fmul float %1590, %1592
  %1594 = load float, float* %1575, align 4
  %1595 = fadd float %1594, %1593
  %1596 = getelementptr inbounds i8, i8* %1108, i64 60
  %1597 = bitcast i8* %1596 to float*
  %1598 = load float, float* %1597, align 4
  %1599 = getelementptr inbounds float, float* %1, i64 12
  %1600 = load float, float* %1599, align 4
  %1601 = fmul float %1598, %1600
  %1602 = load float, float* %1575, align 4
  %1603 = fadd float %1602, %1601
  %1604 = getelementptr inbounds i8, i8* %1166, i64 52
  %1605 = bitcast i8* %1604 to float*
  %1606 = getelementptr inbounds i8, i8* %1166, i64 52
  %1607 = bitcast i8* %1606 to float*
  %1608 = load float, float* %1571, align 4
  %1609 = getelementptr inbounds float, float* %1, i64 1
  %1610 = load float, float* %1609, align 4
  %1611 = fmul float %1608, %1610
  %1612 = load float, float* %1607, align 4
  %1613 = fadd float %1612, %1611
  %1614 = getelementptr inbounds i8, i8* %1108, i64 52
  %1615 = bitcast i8* %1614 to float*
  %1616 = load float, float* %1615, align 4
  %1617 = getelementptr inbounds float, float* %1, i64 5
  %1618 = load float, float* %1617, align 4
  %1619 = fmul float %1616, %1618
  %1620 = load float, float* %1607, align 4
  %1621 = fadd float %1620, %1619
  %1622 = getelementptr inbounds i8, i8* %1108, i64 56
  %1623 = bitcast i8* %1622 to float*
  %1624 = load float, float* %1623, align 4
  %1625 = getelementptr inbounds float, float* %1, i64 9
  %1626 = load float, float* %1625, align 4
  %1627 = fmul float %1624, %1626
  %1628 = load float, float* %1607, align 4
  %1629 = fadd float %1628, %1627
  %1630 = getelementptr inbounds i8, i8* %1108, i64 60
  %1631 = bitcast i8* %1630 to float*
  %1632 = load float, float* %1631, align 4
  %1633 = getelementptr inbounds float, float* %1, i64 13
  %1634 = load float, float* %1633, align 4
  %1635 = fmul float %1632, %1634
  %1636 = load float, float* %1607, align 4
  %1637 = fadd float %1636, %1635
  %1638 = getelementptr inbounds i8, i8* %1166, i64 56
  %1639 = bitcast i8* %1638 to float*
  %1640 = getelementptr inbounds i8, i8* %1166, i64 56
  %1641 = bitcast i8* %1640 to float*
  %1642 = load float, float* %1571, align 4
  %1643 = getelementptr inbounds float, float* %1, i64 2
  %1644 = load float, float* %1643, align 4
  %1645 = fmul float %1642, %1644
  %1646 = load float, float* %1641, align 4
  %1647 = fadd float %1646, %1645
  %1648 = getelementptr inbounds i8, i8* %1108, i64 52
  %1649 = bitcast i8* %1648 to float*
  %1650 = load float, float* %1649, align 4
  %1651 = getelementptr inbounds float, float* %1, i64 6
  %1652 = load float, float* %1651, align 4
  %1653 = fmul float %1650, %1652
  %1654 = load float, float* %1641, align 4
  %1655 = fadd float %1654, %1653
  %1656 = getelementptr inbounds i8, i8* %1108, i64 56
  %1657 = bitcast i8* %1656 to float*
  %1658 = load float, float* %1657, align 4
  %1659 = getelementptr inbounds float, float* %1, i64 10
  %1660 = load float, float* %1659, align 4
  %1661 = fmul float %1658, %1660
  %1662 = load float, float* %1641, align 4
  %1663 = fadd float %1662, %1661
  %1664 = getelementptr inbounds i8, i8* %1108, i64 60
  %1665 = bitcast i8* %1664 to float*
  %1666 = load float, float* %1665, align 4
  %1667 = getelementptr inbounds float, float* %1, i64 14
  %1668 = load float, float* %1667, align 4
  %1669 = fmul float %1666, %1668
  %1670 = load float, float* %1641, align 4
  %1671 = fadd float %1670, %1669
  %1672 = getelementptr inbounds i8, i8* %1166, i64 60
  %1673 = bitcast i8* %1672 to float*
  %1674 = getelementptr inbounds i8, i8* %1166, i64 60
  %1675 = bitcast i8* %1674 to float*
  %1676 = load float, float* %1571, align 4
  %1677 = getelementptr inbounds float, float* %1, i64 3
  %1678 = load float, float* %1677, align 4
  %1679 = fmul float %1676, %1678
  %1680 = load float, float* %1675, align 4
  %1681 = fadd float %1680, %1679
  %1682 = getelementptr inbounds i8, i8* %1108, i64 52
  %1683 = bitcast i8* %1682 to float*
  %1684 = load float, float* %1683, align 4
  %1685 = getelementptr inbounds float, float* %1, i64 7
  %1686 = load float, float* %1685, align 4
  %1687 = fmul float %1684, %1686
  %1688 = load float, float* %1675, align 4
  %1689 = fadd float %1688, %1687
  %1690 = getelementptr inbounds i8, i8* %1108, i64 56
  %1691 = bitcast i8* %1690 to float*
  %1692 = load float, float* %1691, align 4
  %1693 = getelementptr inbounds float, float* %1, i64 11
  %1694 = load float, float* %1693, align 4
  %1695 = fmul float %1692, %1694
  %1696 = load float, float* %1675, align 4
  %1697 = fadd float %1696, %1695
  %1698 = getelementptr inbounds i8, i8* %1108, i64 60
  %1699 = bitcast i8* %1698 to float*
  %1700 = load float, float* %1699, align 4
  %1701 = getelementptr inbounds float, float* %1, i64 15
  %1702 = load float, float* %1701, align 4
  %1703 = fmul float %1700, %1702
  %1704 = load float, float* %1675, align 4
  %1705 = fadd float %1704, %1703
  %1706 = call i8* @__memcpy_chk(i8* %40, i8* %1166, i64 64, i64 %42) #9
  %1707 = load float, float* %1109, align 4
  %1708 = load float, float* %2, align 4
  %1709 = fmul float %1707, %1708
  %1710 = fadd float %1709, 0.000000e+00
  %1711 = getelementptr inbounds i8, i8* %1108, i64 4
  %1712 = bitcast i8* %1711 to float*
  %1713 = load float, float* %1712, align 4
  %1714 = getelementptr inbounds float, float* %2, i64 4
  %1715 = load float, float* %1714, align 4
  %1716 = fmul float %1713, %1715
  %1717 = load float, float* %1167, align 4
  %1718 = fadd float %1717, %1716
  %1719 = getelementptr inbounds i8, i8* %1108, i64 8
  %1720 = bitcast i8* %1719 to float*
  %1721 = load float, float* %1720, align 4
  %1722 = getelementptr inbounds float, float* %2, i64 8
  %1723 = load float, float* %1722, align 4
  %1724 = fmul float %1721, %1723
  %1725 = load float, float* %1167, align 4
  %1726 = fadd float %1725, %1724
  %1727 = getelementptr inbounds i8, i8* %1108, i64 12
  %1728 = bitcast i8* %1727 to float*
  %1729 = load float, float* %1728, align 4
  %1730 = getelementptr inbounds float, float* %2, i64 12
  %1731 = load float, float* %1730, align 4
  %1732 = fmul float %1729, %1731
  %1733 = load float, float* %1167, align 4
  %1734 = fadd float %1733, %1732
  %1735 = getelementptr inbounds i8, i8* %1166, i64 4
  %1736 = bitcast i8* %1735 to float*
  %1737 = getelementptr inbounds i8, i8* %1166, i64 4
  %1738 = bitcast i8* %1737 to float*
  %1739 = load float, float* %1109, align 4
  %1740 = getelementptr inbounds float, float* %2, i64 1
  %1741 = load float, float* %1740, align 4
  %1742 = fmul float %1739, %1741
  %1743 = load float, float* %1738, align 4
  %1744 = fadd float %1743, %1742
  %1745 = getelementptr inbounds i8, i8* %1108, i64 4
  %1746 = bitcast i8* %1745 to float*
  %1747 = load float, float* %1746, align 4
  %1748 = getelementptr inbounds float, float* %2, i64 5
  %1749 = load float, float* %1748, align 4
  %1750 = fmul float %1747, %1749
  %1751 = load float, float* %1738, align 4
  %1752 = fadd float %1751, %1750
  %1753 = getelementptr inbounds i8, i8* %1108, i64 8
  %1754 = bitcast i8* %1753 to float*
  %1755 = load float, float* %1754, align 4
  %1756 = getelementptr inbounds float, float* %2, i64 9
  %1757 = load float, float* %1756, align 4
  %1758 = fmul float %1755, %1757
  %1759 = load float, float* %1738, align 4
  %1760 = fadd float %1759, %1758
  %1761 = getelementptr inbounds i8, i8* %1108, i64 12
  %1762 = bitcast i8* %1761 to float*
  %1763 = load float, float* %1762, align 4
  %1764 = getelementptr inbounds float, float* %2, i64 13
  %1765 = load float, float* %1764, align 4
  %1766 = fmul float %1763, %1765
  %1767 = load float, float* %1738, align 4
  %1768 = fadd float %1767, %1766
  %1769 = getelementptr inbounds i8, i8* %1166, i64 8
  %1770 = bitcast i8* %1769 to float*
  %1771 = getelementptr inbounds i8, i8* %1166, i64 8
  %1772 = bitcast i8* %1771 to float*
  %1773 = load float, float* %1109, align 4
  %1774 = getelementptr inbounds float, float* %2, i64 2
  %1775 = load float, float* %1774, align 4
  %1776 = fmul float %1773, %1775
  %1777 = load float, float* %1772, align 4
  %1778 = fadd float %1777, %1776
  %1779 = getelementptr inbounds i8, i8* %1108, i64 4
  %1780 = bitcast i8* %1779 to float*
  %1781 = load float, float* %1780, align 4
  %1782 = getelementptr inbounds float, float* %2, i64 6
  %1783 = load float, float* %1782, align 4
  %1784 = fmul float %1781, %1783
  %1785 = load float, float* %1772, align 4
  %1786 = fadd float %1785, %1784
  %1787 = getelementptr inbounds i8, i8* %1108, i64 8
  %1788 = bitcast i8* %1787 to float*
  %1789 = load float, float* %1788, align 4
  %1790 = getelementptr inbounds float, float* %2, i64 10
  %1791 = load float, float* %1790, align 4
  %1792 = fmul float %1789, %1791
  %1793 = load float, float* %1772, align 4
  %1794 = fadd float %1793, %1792
  %1795 = getelementptr inbounds i8, i8* %1108, i64 12
  %1796 = bitcast i8* %1795 to float*
  %1797 = load float, float* %1796, align 4
  %1798 = getelementptr inbounds float, float* %2, i64 14
  %1799 = load float, float* %1798, align 4
  %1800 = fmul float %1797, %1799
  %1801 = load float, float* %1772, align 4
  %1802 = fadd float %1801, %1800
  %1803 = getelementptr inbounds i8, i8* %1166, i64 12
  %1804 = bitcast i8* %1803 to float*
  %1805 = getelementptr inbounds i8, i8* %1166, i64 12
  %1806 = bitcast i8* %1805 to float*
  %1807 = load float, float* %1109, align 4
  %1808 = getelementptr inbounds float, float* %2, i64 3
  %1809 = load float, float* %1808, align 4
  %1810 = fmul float %1807, %1809
  %1811 = load float, float* %1806, align 4
  %1812 = fadd float %1811, %1810
  %1813 = getelementptr inbounds i8, i8* %1108, i64 4
  %1814 = bitcast i8* %1813 to float*
  %1815 = load float, float* %1814, align 4
  %1816 = getelementptr inbounds float, float* %2, i64 7
  %1817 = load float, float* %1816, align 4
  %1818 = fmul float %1815, %1817
  %1819 = load float, float* %1806, align 4
  %1820 = fadd float %1819, %1818
  %1821 = getelementptr inbounds i8, i8* %1108, i64 8
  %1822 = bitcast i8* %1821 to float*
  %1823 = load float, float* %1822, align 4
  %1824 = getelementptr inbounds float, float* %2, i64 11
  %1825 = load float, float* %1824, align 4
  %1826 = fmul float %1823, %1825
  %1827 = load float, float* %1806, align 4
  %1828 = fadd float %1827, %1826
  %1829 = getelementptr inbounds i8, i8* %1108, i64 12
  %1830 = bitcast i8* %1829 to float*
  %1831 = load float, float* %1830, align 4
  %1832 = getelementptr inbounds float, float* %2, i64 15
  %1833 = load float, float* %1832, align 4
  %1834 = fmul float %1831, %1833
  %1835 = load float, float* %1806, align 4
  %1836 = fadd float %1835, %1834
  %1837 = getelementptr inbounds i8, i8* %1108, i64 16
  %1838 = bitcast i8* %1837 to float*
  %1839 = getelementptr inbounds i8, i8* %1166, i64 16
  %1840 = bitcast i8* %1839 to float*
  %1841 = getelementptr inbounds i8, i8* %1166, i64 16
  %1842 = bitcast i8* %1841 to float*
  %1843 = load float, float* %1838, align 4
  %1844 = load float, float* %2, align 4
  %1845 = fmul float %1843, %1844
  %1846 = fadd float %1845, 0.000000e+00
  %1847 = getelementptr inbounds i8, i8* %1108, i64 20
  %1848 = bitcast i8* %1847 to float*
  %1849 = load float, float* %1848, align 4
  %1850 = getelementptr inbounds float, float* %2, i64 4
  %1851 = load float, float* %1850, align 4
  %1852 = fmul float %1849, %1851
  %1853 = load float, float* %1842, align 4
  %1854 = fadd float %1853, %1852
  %1855 = getelementptr inbounds i8, i8* %1108, i64 24
  %1856 = bitcast i8* %1855 to float*
  %1857 = load float, float* %1856, align 4
  %1858 = getelementptr inbounds float, float* %2, i64 8
  %1859 = load float, float* %1858, align 4
  %1860 = fmul float %1857, %1859
  %1861 = load float, float* %1842, align 4
  %1862 = fadd float %1861, %1860
  %1863 = getelementptr inbounds i8, i8* %1108, i64 28
  %1864 = bitcast i8* %1863 to float*
  %1865 = load float, float* %1864, align 4
  %1866 = getelementptr inbounds float, float* %2, i64 12
  %1867 = load float, float* %1866, align 4
  %1868 = fmul float %1865, %1867
  %1869 = load float, float* %1842, align 4
  %1870 = fadd float %1869, %1868
  %1871 = getelementptr inbounds i8, i8* %1166, i64 20
  %1872 = bitcast i8* %1871 to float*
  %1873 = getelementptr inbounds i8, i8* %1166, i64 20
  %1874 = bitcast i8* %1873 to float*
  %1875 = load float, float* %1838, align 4
  %1876 = getelementptr inbounds float, float* %2, i64 1
  %1877 = load float, float* %1876, align 4
  %1878 = fmul float %1875, %1877
  %1879 = load float, float* %1874, align 4
  %1880 = fadd float %1879, %1878
  %1881 = getelementptr inbounds i8, i8* %1108, i64 20
  %1882 = bitcast i8* %1881 to float*
  %1883 = load float, float* %1882, align 4
  %1884 = getelementptr inbounds float, float* %2, i64 5
  %1885 = load float, float* %1884, align 4
  %1886 = fmul float %1883, %1885
  %1887 = load float, float* %1874, align 4
  %1888 = fadd float %1887, %1886
  %1889 = getelementptr inbounds i8, i8* %1108, i64 24
  %1890 = bitcast i8* %1889 to float*
  %1891 = load float, float* %1890, align 4
  %1892 = getelementptr inbounds float, float* %2, i64 9
  %1893 = load float, float* %1892, align 4
  %1894 = fmul float %1891, %1893
  %1895 = load float, float* %1874, align 4
  %1896 = fadd float %1895, %1894
  %1897 = getelementptr inbounds i8, i8* %1108, i64 28
  %1898 = bitcast i8* %1897 to float*
  %1899 = load float, float* %1898, align 4
  %1900 = getelementptr inbounds float, float* %2, i64 13
  %1901 = load float, float* %1900, align 4
  %1902 = fmul float %1899, %1901
  %1903 = load float, float* %1874, align 4
  %1904 = fadd float %1903, %1902
  %1905 = getelementptr inbounds i8, i8* %1166, i64 24
  %1906 = bitcast i8* %1905 to float*
  %1907 = getelementptr inbounds i8, i8* %1166, i64 24
  %1908 = bitcast i8* %1907 to float*
  %1909 = load float, float* %1838, align 4
  %1910 = getelementptr inbounds float, float* %2, i64 2
  %1911 = load float, float* %1910, align 4
  %1912 = fmul float %1909, %1911
  %1913 = load float, float* %1908, align 4
  %1914 = fadd float %1913, %1912
  %1915 = getelementptr inbounds i8, i8* %1108, i64 20
  %1916 = bitcast i8* %1915 to float*
  %1917 = load float, float* %1916, align 4
  %1918 = getelementptr inbounds float, float* %2, i64 6
  %1919 = load float, float* %1918, align 4
  %1920 = fmul float %1917, %1919
  %1921 = load float, float* %1908, align 4
  %1922 = fadd float %1921, %1920
  %1923 = getelementptr inbounds i8, i8* %1108, i64 24
  %1924 = bitcast i8* %1923 to float*
  %1925 = load float, float* %1924, align 4
  %1926 = getelementptr inbounds float, float* %2, i64 10
  %1927 = load float, float* %1926, align 4
  %1928 = fmul float %1925, %1927
  %1929 = load float, float* %1908, align 4
  %1930 = fadd float %1929, %1928
  %1931 = getelementptr inbounds i8, i8* %1108, i64 28
  %1932 = bitcast i8* %1931 to float*
  %1933 = load float, float* %1932, align 4
  %1934 = getelementptr inbounds float, float* %2, i64 14
  %1935 = load float, float* %1934, align 4
  %1936 = fmul float %1933, %1935
  %1937 = load float, float* %1908, align 4
  %1938 = fadd float %1937, %1936
  %1939 = getelementptr inbounds i8, i8* %1166, i64 28
  %1940 = bitcast i8* %1939 to float*
  %1941 = getelementptr inbounds i8, i8* %1166, i64 28
  %1942 = bitcast i8* %1941 to float*
  %1943 = load float, float* %1838, align 4
  %1944 = getelementptr inbounds float, float* %2, i64 3
  %1945 = load float, float* %1944, align 4
  %1946 = fmul float %1943, %1945
  %1947 = load float, float* %1942, align 4
  %1948 = fadd float %1947, %1946
  %1949 = getelementptr inbounds i8, i8* %1108, i64 20
  %1950 = bitcast i8* %1949 to float*
  %1951 = load float, float* %1950, align 4
  %1952 = getelementptr inbounds float, float* %2, i64 7
  %1953 = load float, float* %1952, align 4
  %1954 = fmul float %1951, %1953
  %1955 = load float, float* %1942, align 4
  %1956 = fadd float %1955, %1954
  %1957 = getelementptr inbounds i8, i8* %1108, i64 24
  %1958 = bitcast i8* %1957 to float*
  %1959 = load float, float* %1958, align 4
  %1960 = getelementptr inbounds float, float* %2, i64 11
  %1961 = load float, float* %1960, align 4
  %1962 = fmul float %1959, %1961
  %1963 = load float, float* %1942, align 4
  %1964 = fadd float %1963, %1962
  %1965 = getelementptr inbounds i8, i8* %1108, i64 28
  %1966 = bitcast i8* %1965 to float*
  %1967 = load float, float* %1966, align 4
  %1968 = getelementptr inbounds float, float* %2, i64 15
  %1969 = load float, float* %1968, align 4
  %1970 = fmul float %1967, %1969
  %1971 = load float, float* %1942, align 4
  %1972 = fadd float %1971, %1970
  %1973 = getelementptr inbounds i8, i8* %1108, i64 32
  %1974 = bitcast i8* %1973 to float*
  %1975 = getelementptr inbounds i8, i8* %1166, i64 32
  %1976 = bitcast i8* %1975 to float*
  %1977 = getelementptr inbounds i8, i8* %1166, i64 32
  %1978 = bitcast i8* %1977 to float*
  %1979 = load float, float* %1974, align 4
  %1980 = load float, float* %2, align 4
  %1981 = fmul float %1979, %1980
  %1982 = fadd float %1981, 0.000000e+00
  %1983 = getelementptr inbounds i8, i8* %1108, i64 36
  %1984 = bitcast i8* %1983 to float*
  %1985 = load float, float* %1984, align 4
  %1986 = getelementptr inbounds float, float* %2, i64 4
  %1987 = load float, float* %1986, align 4
  %1988 = fmul float %1985, %1987
  %1989 = load float, float* %1978, align 4
  %1990 = fadd float %1989, %1988
  %1991 = getelementptr inbounds i8, i8* %1108, i64 40
  %1992 = bitcast i8* %1991 to float*
  %1993 = load float, float* %1992, align 4
  %1994 = getelementptr inbounds float, float* %2, i64 8
  %1995 = load float, float* %1994, align 4
  %1996 = fmul float %1993, %1995
  %1997 = load float, float* %1978, align 4
  %1998 = fadd float %1997, %1996
  %1999 = getelementptr inbounds i8, i8* %1108, i64 44
  %2000 = bitcast i8* %1999 to float*
  %2001 = load float, float* %2000, align 4
  %2002 = getelementptr inbounds float, float* %2, i64 12
  %2003 = load float, float* %2002, align 4
  %2004 = fmul float %2001, %2003
  %2005 = load float, float* %1978, align 4
  %2006 = fadd float %2005, %2004
  %2007 = getelementptr inbounds i8, i8* %1166, i64 36
  %2008 = bitcast i8* %2007 to float*
  %2009 = getelementptr inbounds i8, i8* %1166, i64 36
  %2010 = bitcast i8* %2009 to float*
  %2011 = load float, float* %1974, align 4
  %2012 = getelementptr inbounds float, float* %2, i64 1
  %2013 = load float, float* %2012, align 4
  %2014 = fmul float %2011, %2013
  %2015 = load float, float* %2010, align 4
  %2016 = fadd float %2015, %2014
  %2017 = getelementptr inbounds i8, i8* %1108, i64 36
  %2018 = bitcast i8* %2017 to float*
  %2019 = load float, float* %2018, align 4
  %2020 = getelementptr inbounds float, float* %2, i64 5
  %2021 = load float, float* %2020, align 4
  %2022 = fmul float %2019, %2021
  %2023 = load float, float* %2010, align 4
  %2024 = fadd float %2023, %2022
  %2025 = getelementptr inbounds i8, i8* %1108, i64 40
  %2026 = bitcast i8* %2025 to float*
  %2027 = load float, float* %2026, align 4
  %2028 = getelementptr inbounds float, float* %2, i64 9
  %2029 = load float, float* %2028, align 4
  %2030 = fmul float %2027, %2029
  %2031 = load float, float* %2010, align 4
  %2032 = fadd float %2031, %2030
  %2033 = getelementptr inbounds i8, i8* %1108, i64 44
  %2034 = bitcast i8* %2033 to float*
  %2035 = load float, float* %2034, align 4
  %2036 = getelementptr inbounds float, float* %2, i64 13
  %2037 = load float, float* %2036, align 4
  %2038 = fmul float %2035, %2037
  %2039 = load float, float* %2010, align 4
  %2040 = fadd float %2039, %2038
  %2041 = getelementptr inbounds i8, i8* %1166, i64 40
  %2042 = bitcast i8* %2041 to float*
  %2043 = getelementptr inbounds i8, i8* %1166, i64 40
  %2044 = bitcast i8* %2043 to float*
  %2045 = load float, float* %1974, align 4
  %2046 = getelementptr inbounds float, float* %2, i64 2
  %2047 = load float, float* %2046, align 4
  %2048 = fmul float %2045, %2047
  %2049 = load float, float* %2044, align 4
  %2050 = fadd float %2049, %2048
  %2051 = getelementptr inbounds i8, i8* %1108, i64 36
  %2052 = bitcast i8* %2051 to float*
  %2053 = load float, float* %2052, align 4
  %2054 = getelementptr inbounds float, float* %2, i64 6
  %2055 = load float, float* %2054, align 4
  %2056 = fmul float %2053, %2055
  %2057 = load float, float* %2044, align 4
  %2058 = fadd float %2057, %2056
  %2059 = getelementptr inbounds i8, i8* %1108, i64 40
  %2060 = bitcast i8* %2059 to float*
  %2061 = load float, float* %2060, align 4
  %2062 = getelementptr inbounds float, float* %2, i64 10
  %2063 = load float, float* %2062, align 4
  %2064 = fmul float %2061, %2063
  %2065 = load float, float* %2044, align 4
  %2066 = fadd float %2065, %2064
  %2067 = getelementptr inbounds i8, i8* %1108, i64 44
  %2068 = bitcast i8* %2067 to float*
  %2069 = load float, float* %2068, align 4
  %2070 = getelementptr inbounds float, float* %2, i64 14
  %2071 = load float, float* %2070, align 4
  %2072 = fmul float %2069, %2071
  %2073 = load float, float* %2044, align 4
  %2074 = fadd float %2073, %2072
  %2075 = getelementptr inbounds i8, i8* %1166, i64 44
  %2076 = bitcast i8* %2075 to float*
  %2077 = getelementptr inbounds i8, i8* %1166, i64 44
  %2078 = bitcast i8* %2077 to float*
  %2079 = load float, float* %1974, align 4
  %2080 = getelementptr inbounds float, float* %2, i64 3
  %2081 = load float, float* %2080, align 4
  %2082 = fmul float %2079, %2081
  %2083 = load float, float* %2078, align 4
  %2084 = fadd float %2083, %2082
  %2085 = getelementptr inbounds i8, i8* %1108, i64 36
  %2086 = bitcast i8* %2085 to float*
  %2087 = load float, float* %2086, align 4
  %2088 = getelementptr inbounds float, float* %2, i64 7
  %2089 = load float, float* %2088, align 4
  %2090 = fmul float %2087, %2089
  %2091 = load float, float* %2078, align 4
  %2092 = fadd float %2091, %2090
  %2093 = getelementptr inbounds i8, i8* %1108, i64 40
  %2094 = bitcast i8* %2093 to float*
  %2095 = load float, float* %2094, align 4
  %2096 = getelementptr inbounds float, float* %2, i64 11
  %2097 = load float, float* %2096, align 4
  %2098 = fmul float %2095, %2097
  %2099 = load float, float* %2078, align 4
  %2100 = fadd float %2099, %2098
  %2101 = getelementptr inbounds i8, i8* %1108, i64 44
  %2102 = bitcast i8* %2101 to float*
  %2103 = load float, float* %2102, align 4
  %2104 = getelementptr inbounds float, float* %2, i64 15
  %2105 = load float, float* %2104, align 4
  %2106 = fmul float %2103, %2105
  %2107 = load float, float* %2078, align 4
  %2108 = fadd float %2107, %2106
  %2109 = getelementptr inbounds i8, i8* %1108, i64 48
  %2110 = bitcast i8* %2109 to float*
  %2111 = getelementptr inbounds i8, i8* %1166, i64 48
  %2112 = bitcast i8* %2111 to float*
  %2113 = getelementptr inbounds i8, i8* %1166, i64 48
  %2114 = bitcast i8* %2113 to float*
  %2115 = load float, float* %2110, align 4
  %2116 = load float, float* %2, align 4
  %2117 = fmul float %2115, %2116
  %2118 = fadd float %2117, 0.000000e+00
  %2119 = getelementptr inbounds i8, i8* %1108, i64 52
  %2120 = bitcast i8* %2119 to float*
  %2121 = load float, float* %2120, align 4
  %2122 = getelementptr inbounds float, float* %2, i64 4
  %2123 = load float, float* %2122, align 4
  %2124 = fmul float %2121, %2123
  %2125 = load float, float* %2114, align 4
  %2126 = fadd float %2125, %2124
  %2127 = getelementptr inbounds i8, i8* %1108, i64 56
  %2128 = bitcast i8* %2127 to float*
  %2129 = load float, float* %2128, align 4
  %2130 = getelementptr inbounds float, float* %2, i64 8
  %2131 = load float, float* %2130, align 4
  %2132 = fmul float %2129, %2131
  %2133 = load float, float* %2114, align 4
  %2134 = fadd float %2133, %2132
  %2135 = getelementptr inbounds i8, i8* %1108, i64 60
  %2136 = bitcast i8* %2135 to float*
  %2137 = load float, float* %2136, align 4
  %2138 = getelementptr inbounds float, float* %2, i64 12
  %2139 = load float, float* %2138, align 4
  %2140 = fmul float %2137, %2139
  %2141 = load float, float* %2114, align 4
  %2142 = fadd float %2141, %2140
  %2143 = getelementptr inbounds i8, i8* %1166, i64 52
  %2144 = bitcast i8* %2143 to float*
  %2145 = getelementptr inbounds i8, i8* %1166, i64 52
  %2146 = bitcast i8* %2145 to float*
  %2147 = load float, float* %2110, align 4
  %2148 = getelementptr inbounds float, float* %2, i64 1
  %2149 = load float, float* %2148, align 4
  %2150 = fmul float %2147, %2149
  %2151 = load float, float* %2146, align 4
  %2152 = fadd float %2151, %2150
  %2153 = getelementptr inbounds i8, i8* %1108, i64 52
  %2154 = bitcast i8* %2153 to float*
  %2155 = load float, float* %2154, align 4
  %2156 = getelementptr inbounds float, float* %2, i64 5
  %2157 = load float, float* %2156, align 4
  %2158 = fmul float %2155, %2157
  %2159 = load float, float* %2146, align 4
  %2160 = fadd float %2159, %2158
  %2161 = getelementptr inbounds i8, i8* %1108, i64 56
  %2162 = bitcast i8* %2161 to float*
  %2163 = load float, float* %2162, align 4
  %2164 = getelementptr inbounds float, float* %2, i64 9
  %2165 = load float, float* %2164, align 4
  %2166 = fmul float %2163, %2165
  %2167 = load float, float* %2146, align 4
  %2168 = fadd float %2167, %2166
  %2169 = getelementptr inbounds i8, i8* %1108, i64 60
  %2170 = bitcast i8* %2169 to float*
  %2171 = load float, float* %2170, align 4
  %2172 = getelementptr inbounds float, float* %2, i64 13
  %2173 = load float, float* %2172, align 4
  %2174 = fmul float %2171, %2173
  %2175 = load float, float* %2146, align 4
  %2176 = fadd float %2175, %2174
  %2177 = getelementptr inbounds i8, i8* %1166, i64 56
  %2178 = bitcast i8* %2177 to float*
  %2179 = getelementptr inbounds i8, i8* %1166, i64 56
  %2180 = bitcast i8* %2179 to float*
  %2181 = load float, float* %2110, align 4
  %2182 = getelementptr inbounds float, float* %2, i64 2
  %2183 = load float, float* %2182, align 4
  %2184 = fmul float %2181, %2183
  %2185 = load float, float* %2180, align 4
  %2186 = fadd float %2185, %2184
  %2187 = getelementptr inbounds i8, i8* %1108, i64 52
  %2188 = bitcast i8* %2187 to float*
  %2189 = load float, float* %2188, align 4
  %2190 = getelementptr inbounds float, float* %2, i64 6
  %2191 = load float, float* %2190, align 4
  %2192 = fmul float %2189, %2191
  %2193 = load float, float* %2180, align 4
  %2194 = fadd float %2193, %2192
  %2195 = getelementptr inbounds i8, i8* %1108, i64 56
  %2196 = bitcast i8* %2195 to float*
  %2197 = load float, float* %2196, align 4
  %2198 = getelementptr inbounds float, float* %2, i64 10
  %2199 = load float, float* %2198, align 4
  %2200 = fmul float %2197, %2199
  %2201 = load float, float* %2180, align 4
  %2202 = fadd float %2201, %2200
  %2203 = getelementptr inbounds i8, i8* %1108, i64 60
  %2204 = bitcast i8* %2203 to float*
  %2205 = load float, float* %2204, align 4
  %2206 = getelementptr inbounds float, float* %2, i64 14
  %2207 = load float, float* %2206, align 4
  %2208 = fmul float %2205, %2207
  %2209 = load float, float* %2180, align 4
  %2210 = fadd float %2209, %2208
  %2211 = getelementptr inbounds i8, i8* %1166, i64 60
  %2212 = bitcast i8* %2211 to float*
  %2213 = getelementptr inbounds i8, i8* %1166, i64 60
  %2214 = bitcast i8* %2213 to float*
  %2215 = load float, float* %2110, align 4
  %2216 = getelementptr inbounds float, float* %2, i64 3
  %2217 = load float, float* %2216, align 4
  %2218 = fmul float %2215, %2217
  %2219 = load float, float* %2214, align 4
  %2220 = fadd float %2219, %2218
  %2221 = getelementptr inbounds i8, i8* %1108, i64 52
  %2222 = bitcast i8* %2221 to float*
  %2223 = load float, float* %2222, align 4
  %2224 = getelementptr inbounds float, float* %2, i64 7
  %2225 = load float, float* %2224, align 4
  %2226 = fmul float %2223, %2225
  %2227 = load float, float* %2214, align 4
  %2228 = fadd float %2227, %2226
  %2229 = getelementptr inbounds i8, i8* %1108, i64 56
  %2230 = bitcast i8* %2229 to float*
  %2231 = load float, float* %2230, align 4
  %2232 = getelementptr inbounds float, float* %2, i64 11
  %2233 = load float, float* %2232, align 4
  %2234 = fmul float %2231, %2233
  %2235 = load float, float* %2214, align 4
  %2236 = fadd float %2235, %2234
  %2237 = getelementptr inbounds i8, i8* %1108, i64 60
  %2238 = bitcast i8* %2237 to float*
  %2239 = load float, float* %2238, align 4
  %2240 = getelementptr inbounds float, float* %2, i64 15
  %2241 = load float, float* %2240, align 4
  %2242 = fmul float %2239, %2241
  %2243 = load float, float* %2214, align 4
  %2244 = fadd float %2243, %2242
  %2245 = call i8* @__memcpy_chk(i8* %43, i8* %1166, i64 64, i64 %45) #9
  call void @free(i8* %916)
  call void @free(i8* %918)
  call void @free(i8* %975)
  call void @free(i8* %977)
  call void @free(i8* %1036)
  call void @free(i8* %1108)
  %2246 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %2247 = bitcast i8* %2246 to float*
  %2248 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %2249 = bitcast i8* %2248 to float*
  %2250 = getelementptr inbounds float, float* %2, i64 10
  %2251 = bitcast float* %2250 to i32*
  %2252 = load i32, i32* %2251, align 4
  %2253 = bitcast i8* %2246 to i32*
  %2254 = getelementptr inbounds i8, i8* %8, i64 40
  %2255 = bitcast i8* %2254 to i32*
  %2256 = load i32, i32* %2255, align 4
  %2257 = bitcast i8* %2248 to i32*
  %2258 = getelementptr inbounds float, float* %2, i64 14
  %2259 = bitcast float* %2258 to i32*
  %2260 = load i32, i32* %2259, align 4
  %2261 = getelementptr inbounds i8, i8* %2246, i64 4
  %2262 = bitcast i8* %2261 to i32*
  %2263 = getelementptr inbounds i8, i8* %8, i64 56
  %2264 = bitcast i8* %2263 to i32*
  %2265 = load i32, i32* %2264, align 4
  %2266 = getelementptr inbounds i8, i8* %2248, i64 4
  %2267 = bitcast i8* %2266 to i32*
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
  %2288 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %2289 = bitcast i8* %2288 to float*
  %2290 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %2291 = load float, float* %2247, align 4
  %2292 = load float, float* %2249, align 4
  %2293 = fmul float %2287, %2292
  %2294 = fadd float %2291, %2293
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
  %2320 = getelementptr inbounds i8, i8* %2288, i64 4
  %2321 = bitcast i8* %2320 to float*
  %2322 = load float, float* %2321, align 4
  %2323 = fdiv float %2322, %2317
  %2324 = getelementptr inbounds i8, i8* %2290, i64 4
  %2325 = bitcast i8* %2324 to float*
  %2326 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %2327 = bitcast i8* %2326 to float*
  %2328 = load float, float* %2316, align 4
  %2329 = fmul float %2328, 2.000000e+00
  %2330 = fmul float %2329, %2328
  %2331 = fsub float 1.000000e+00, %2330
  %2332 = load float, float* %2316, align 4
  %2333 = fmul float %2332, 2.000000e+00
  %2334 = getelementptr inbounds i8, i8* %2290, i64 4
  %2335 = bitcast i8* %2334 to float*
  %2336 = load float, float* %2335, align 4
  %2337 = fmul float %2333, %2336
  %2338 = fsub float 0.000000e+00, %2337
  %2339 = getelementptr inbounds i8, i8* %2326, i64 4
  %2340 = bitcast i8* %2339 to float*
  %2341 = getelementptr inbounds i8, i8* %2290, i64 4
  %2342 = bitcast i8* %2341 to float*
  %2343 = load float, float* %2342, align 4
  %2344 = fmul float %2343, 2.000000e+00
  %2345 = load float, float* %2316, align 4
  %2346 = fmul float %2344, %2345
  %2347 = fsub float 0.000000e+00, %2346
  %2348 = getelementptr inbounds i8, i8* %2326, i64 8
  %2349 = bitcast i8* %2348 to float*
  %2350 = load float, float* %2342, align 4
  %2351 = fmul float %2350, 2.000000e+00
  %2352 = fmul float %2351, %2350
  %2353 = fsub float 1.000000e+00, %2352
  %2354 = getelementptr inbounds i8, i8* %2326, i64 12
  %2355 = bitcast i8* %2354 to float*
  %2356 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %2357 = bitcast i8* %2356 to float*
  %2358 = getelementptr inbounds i8, i8* %2356, i64 4
  %2359 = bitcast i8* %2358 to float*
  %2360 = getelementptr inbounds i8, i8* %2356, i64 8
  %2361 = bitcast i8* %2360 to float*
  %2362 = getelementptr inbounds i8, i8* %2356, i64 12
  %2363 = bitcast i8* %2362 to float*
  %2364 = getelementptr inbounds i8, i8* %2356, i64 16
  %2365 = bitcast i8* %2364 to float*
  %2366 = getelementptr inbounds i8, i8* %2356, i64 20
  %2367 = bitcast i8* %2366 to float*
  %2368 = getelementptr inbounds i8, i8* %2356, i64 24
  %2369 = bitcast i8* %2368 to float*
  %2370 = getelementptr inbounds i8, i8* %2356, i64 28
  %2371 = bitcast i8* %2370 to float*
  %2372 = getelementptr inbounds i8, i8* %2356, i64 32
  %2373 = bitcast i8* %2372 to float*
  %2374 = getelementptr inbounds i8, i8* %2356, i64 36
  %2375 = bitcast i8* %2374 to float*
  %2376 = bitcast i8* %2326 to i32*
  %2377 = load i32, i32* %2376, align 4
  %2378 = getelementptr inbounds i8, i8* %2356, i64 40
  %2379 = bitcast i8* %2378 to i32*
  %2380 = getelementptr inbounds i8, i8* %2326, i64 4
  %2381 = bitcast i8* %2380 to i32*
  %2382 = load i32, i32* %2381, align 4
  %2383 = getelementptr inbounds i8, i8* %2356, i64 44
  %2384 = bitcast i8* %2383 to i32*
  %2385 = getelementptr inbounds i8, i8* %2356, i64 48
  %2386 = bitcast i8* %2385 to float*
  %2387 = getelementptr inbounds i8, i8* %2356, i64 52
  %2388 = bitcast i8* %2387 to float*
  %2389 = getelementptr inbounds i8, i8* %2326, i64 8
  %2390 = bitcast i8* %2389 to i32*
  %2391 = load i32, i32* %2390, align 4
  %2392 = getelementptr inbounds i8, i8* %2356, i64 56
  %2393 = bitcast i8* %2392 to i32*
  %2394 = getelementptr inbounds i8, i8* %2326, i64 12
  %2395 = bitcast i8* %2394 to i32*
  %2396 = load i32, i32* %2395, align 4
  %2397 = getelementptr inbounds i8, i8* %2356, i64 60
  %2398 = bitcast i8* %2397 to i32*
  %2399 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %2400 = bitcast i8* %2399 to float*
  %2401 = load float, float* %2357, align 4
  %2402 = load float, float* %1, align 4
  %2403 = fmul float %2401, %2402
  %2404 = fadd float %2403, 0.000000e+00
  %2405 = getelementptr inbounds i8, i8* %2356, i64 4
  %2406 = bitcast i8* %2405 to float*
  %2407 = load float, float* %2406, align 4
  %2408 = getelementptr inbounds float, float* %1, i64 4
  %2409 = load float, float* %2408, align 4
  %2410 = fmul float %2407, %2409
  %2411 = load float, float* %2400, align 4
  %2412 = fadd float %2411, %2410
  %2413 = getelementptr inbounds i8, i8* %2356, i64 8
  %2414 = bitcast i8* %2413 to float*
  %2415 = load float, float* %2414, align 4
  %2416 = getelementptr inbounds float, float* %1, i64 8
  %2417 = load float, float* %2416, align 4
  %2418 = fmul float %2415, %2417
  %2419 = load float, float* %2400, align 4
  %2420 = fadd float %2419, %2418
  %2421 = getelementptr inbounds i8, i8* %2356, i64 12
  %2422 = bitcast i8* %2421 to float*
  %2423 = load float, float* %2422, align 4
  %2424 = getelementptr inbounds float, float* %1, i64 12
  %2425 = load float, float* %2424, align 4
  %2426 = fmul float %2423, %2425
  %2427 = load float, float* %2400, align 4
  %2428 = fadd float %2427, %2426
  %2429 = getelementptr inbounds i8, i8* %2399, i64 4
  %2430 = bitcast i8* %2429 to float*
  %2431 = getelementptr inbounds i8, i8* %2399, i64 4
  %2432 = bitcast i8* %2431 to float*
  %2433 = load float, float* %2357, align 4
  %2434 = getelementptr inbounds float, float* %1, i64 1
  %2435 = load float, float* %2434, align 4
  %2436 = fmul float %2433, %2435
  %2437 = load float, float* %2432, align 4
  %2438 = fadd float %2437, %2436
  %2439 = getelementptr inbounds i8, i8* %2356, i64 4
  %2440 = bitcast i8* %2439 to float*
  %2441 = load float, float* %2440, align 4
  %2442 = getelementptr inbounds float, float* %1, i64 5
  %2443 = load float, float* %2442, align 4
  %2444 = fmul float %2441, %2443
  %2445 = load float, float* %2432, align 4
  %2446 = fadd float %2445, %2444
  %2447 = getelementptr inbounds i8, i8* %2356, i64 8
  %2448 = bitcast i8* %2447 to float*
  %2449 = load float, float* %2448, align 4
  %2450 = getelementptr inbounds float, float* %1, i64 9
  %2451 = load float, float* %2450, align 4
  %2452 = fmul float %2449, %2451
  %2453 = load float, float* %2432, align 4
  %2454 = fadd float %2453, %2452
  %2455 = getelementptr inbounds i8, i8* %2356, i64 12
  %2456 = bitcast i8* %2455 to float*
  %2457 = load float, float* %2456, align 4
  %2458 = getelementptr inbounds float, float* %1, i64 13
  %2459 = load float, float* %2458, align 4
  %2460 = fmul float %2457, %2459
  %2461 = load float, float* %2432, align 4
  %2462 = fadd float %2461, %2460
  %2463 = getelementptr inbounds i8, i8* %2399, i64 8
  %2464 = bitcast i8* %2463 to float*
  %2465 = getelementptr inbounds i8, i8* %2399, i64 8
  %2466 = bitcast i8* %2465 to float*
  %2467 = load float, float* %2357, align 4
  %2468 = getelementptr inbounds float, float* %1, i64 2
  %2469 = load float, float* %2468, align 4
  %2470 = fmul float %2467, %2469
  %2471 = load float, float* %2466, align 4
  %2472 = fadd float %2471, %2470
  %2473 = getelementptr inbounds i8, i8* %2356, i64 4
  %2474 = bitcast i8* %2473 to float*
  %2475 = load float, float* %2474, align 4
  %2476 = getelementptr inbounds float, float* %1, i64 6
  %2477 = load float, float* %2476, align 4
  %2478 = fmul float %2475, %2477
  %2479 = load float, float* %2466, align 4
  %2480 = fadd float %2479, %2478
  %2481 = getelementptr inbounds i8, i8* %2356, i64 8
  %2482 = bitcast i8* %2481 to float*
  %2483 = load float, float* %2482, align 4
  %2484 = getelementptr inbounds float, float* %1, i64 10
  %2485 = load float, float* %2484, align 4
  %2486 = fmul float %2483, %2485
  %2487 = load float, float* %2466, align 4
  %2488 = fadd float %2487, %2486
  %2489 = getelementptr inbounds i8, i8* %2356, i64 12
  %2490 = bitcast i8* %2489 to float*
  %2491 = load float, float* %2490, align 4
  %2492 = getelementptr inbounds float, float* %1, i64 14
  %2493 = load float, float* %2492, align 4
  %2494 = fmul float %2491, %2493
  %2495 = load float, float* %2466, align 4
  %2496 = fadd float %2495, %2494
  %2497 = getelementptr inbounds i8, i8* %2399, i64 12
  %2498 = bitcast i8* %2497 to float*
  %2499 = getelementptr inbounds i8, i8* %2399, i64 12
  %2500 = bitcast i8* %2499 to float*
  %2501 = load float, float* %2357, align 4
  %2502 = getelementptr inbounds float, float* %1, i64 3
  %2503 = load float, float* %2502, align 4
  %2504 = fmul float %2501, %2503
  %2505 = load float, float* %2500, align 4
  %2506 = fadd float %2505, %2504
  %2507 = getelementptr inbounds i8, i8* %2356, i64 4
  %2508 = bitcast i8* %2507 to float*
  %2509 = load float, float* %2508, align 4
  %2510 = getelementptr inbounds float, float* %1, i64 7
  %2511 = load float, float* %2510, align 4
  %2512 = fmul float %2509, %2511
  %2513 = load float, float* %2500, align 4
  %2514 = fadd float %2513, %2512
  %2515 = getelementptr inbounds i8, i8* %2356, i64 8
  %2516 = bitcast i8* %2515 to float*
  %2517 = load float, float* %2516, align 4
  %2518 = getelementptr inbounds float, float* %1, i64 11
  %2519 = load float, float* %2518, align 4
  %2520 = fmul float %2517, %2519
  %2521 = load float, float* %2500, align 4
  %2522 = fadd float %2521, %2520
  %2523 = getelementptr inbounds i8, i8* %2356, i64 12
  %2524 = bitcast i8* %2523 to float*
  %2525 = load float, float* %2524, align 4
  %2526 = getelementptr inbounds float, float* %1, i64 15
  %2527 = load float, float* %2526, align 4
  %2528 = fmul float %2525, %2527
  %2529 = load float, float* %2500, align 4
  %2530 = fadd float %2529, %2528
  %2531 = getelementptr inbounds i8, i8* %2356, i64 16
  %2532 = bitcast i8* %2531 to float*
  %2533 = getelementptr inbounds i8, i8* %2399, i64 16
  %2534 = bitcast i8* %2533 to float*
  %2535 = getelementptr inbounds i8, i8* %2399, i64 16
  %2536 = bitcast i8* %2535 to float*
  %2537 = load float, float* %2532, align 4
  %2538 = load float, float* %1, align 4
  %2539 = fmul float %2537, %2538
  %2540 = fadd float %2539, 0.000000e+00
  %2541 = getelementptr inbounds i8, i8* %2356, i64 20
  %2542 = bitcast i8* %2541 to float*
  %2543 = load float, float* %2542, align 4
  %2544 = getelementptr inbounds float, float* %1, i64 4
  %2545 = load float, float* %2544, align 4
  %2546 = fmul float %2543, %2545
  %2547 = load float, float* %2536, align 4
  %2548 = fadd float %2547, %2546
  %2549 = getelementptr inbounds i8, i8* %2356, i64 24
  %2550 = bitcast i8* %2549 to float*
  %2551 = load float, float* %2550, align 4
  %2552 = getelementptr inbounds float, float* %1, i64 8
  %2553 = load float, float* %2552, align 4
  %2554 = fmul float %2551, %2553
  %2555 = load float, float* %2536, align 4
  %2556 = fadd float %2555, %2554
  %2557 = getelementptr inbounds i8, i8* %2356, i64 28
  %2558 = bitcast i8* %2557 to float*
  %2559 = load float, float* %2558, align 4
  %2560 = getelementptr inbounds float, float* %1, i64 12
  %2561 = load float, float* %2560, align 4
  %2562 = fmul float %2559, %2561
  %2563 = load float, float* %2536, align 4
  %2564 = fadd float %2563, %2562
  %2565 = getelementptr inbounds i8, i8* %2399, i64 20
  %2566 = bitcast i8* %2565 to float*
  %2567 = getelementptr inbounds i8, i8* %2399, i64 20
  %2568 = bitcast i8* %2567 to float*
  %2569 = load float, float* %2532, align 4
  %2570 = getelementptr inbounds float, float* %1, i64 1
  %2571 = load float, float* %2570, align 4
  %2572 = fmul float %2569, %2571
  %2573 = load float, float* %2568, align 4
  %2574 = fadd float %2573, %2572
  %2575 = getelementptr inbounds i8, i8* %2356, i64 20
  %2576 = bitcast i8* %2575 to float*
  %2577 = load float, float* %2576, align 4
  %2578 = getelementptr inbounds float, float* %1, i64 5
  %2579 = load float, float* %2578, align 4
  %2580 = fmul float %2577, %2579
  %2581 = load float, float* %2568, align 4
  %2582 = fadd float %2581, %2580
  %2583 = getelementptr inbounds i8, i8* %2356, i64 24
  %2584 = bitcast i8* %2583 to float*
  %2585 = load float, float* %2584, align 4
  %2586 = getelementptr inbounds float, float* %1, i64 9
  %2587 = load float, float* %2586, align 4
  %2588 = fmul float %2585, %2587
  %2589 = load float, float* %2568, align 4
  %2590 = fadd float %2589, %2588
  %2591 = getelementptr inbounds i8, i8* %2356, i64 28
  %2592 = bitcast i8* %2591 to float*
  %2593 = load float, float* %2592, align 4
  %2594 = getelementptr inbounds float, float* %1, i64 13
  %2595 = load float, float* %2594, align 4
  %2596 = fmul float %2593, %2595
  %2597 = load float, float* %2568, align 4
  %2598 = fadd float %2597, %2596
  %2599 = getelementptr inbounds i8, i8* %2399, i64 24
  %2600 = bitcast i8* %2599 to float*
  %2601 = getelementptr inbounds i8, i8* %2399, i64 24
  %2602 = bitcast i8* %2601 to float*
  %2603 = load float, float* %2532, align 4
  %2604 = getelementptr inbounds float, float* %1, i64 2
  %2605 = load float, float* %2604, align 4
  %2606 = fmul float %2603, %2605
  %2607 = load float, float* %2602, align 4
  %2608 = fadd float %2607, %2606
  %2609 = getelementptr inbounds i8, i8* %2356, i64 20
  %2610 = bitcast i8* %2609 to float*
  %2611 = load float, float* %2610, align 4
  %2612 = getelementptr inbounds float, float* %1, i64 6
  %2613 = load float, float* %2612, align 4
  %2614 = fmul float %2611, %2613
  %2615 = load float, float* %2602, align 4
  %2616 = fadd float %2615, %2614
  %2617 = getelementptr inbounds i8, i8* %2356, i64 24
  %2618 = bitcast i8* %2617 to float*
  %2619 = load float, float* %2618, align 4
  %2620 = getelementptr inbounds float, float* %1, i64 10
  %2621 = load float, float* %2620, align 4
  %2622 = fmul float %2619, %2621
  %2623 = load float, float* %2602, align 4
  %2624 = fadd float %2623, %2622
  %2625 = getelementptr inbounds i8, i8* %2356, i64 28
  %2626 = bitcast i8* %2625 to float*
  %2627 = load float, float* %2626, align 4
  %2628 = getelementptr inbounds float, float* %1, i64 14
  %2629 = load float, float* %2628, align 4
  %2630 = fmul float %2627, %2629
  %2631 = load float, float* %2602, align 4
  %2632 = fadd float %2631, %2630
  %2633 = getelementptr inbounds i8, i8* %2399, i64 28
  %2634 = bitcast i8* %2633 to float*
  %2635 = getelementptr inbounds i8, i8* %2399, i64 28
  %2636 = bitcast i8* %2635 to float*
  %2637 = load float, float* %2532, align 4
  %2638 = getelementptr inbounds float, float* %1, i64 3
  %2639 = load float, float* %2638, align 4
  %2640 = fmul float %2637, %2639
  %2641 = load float, float* %2636, align 4
  %2642 = fadd float %2641, %2640
  %2643 = getelementptr inbounds i8, i8* %2356, i64 20
  %2644 = bitcast i8* %2643 to float*
  %2645 = load float, float* %2644, align 4
  %2646 = getelementptr inbounds float, float* %1, i64 7
  %2647 = load float, float* %2646, align 4
  %2648 = fmul float %2645, %2647
  %2649 = load float, float* %2636, align 4
  %2650 = fadd float %2649, %2648
  %2651 = getelementptr inbounds i8, i8* %2356, i64 24
  %2652 = bitcast i8* %2651 to float*
  %2653 = load float, float* %2652, align 4
  %2654 = getelementptr inbounds float, float* %1, i64 11
  %2655 = load float, float* %2654, align 4
  %2656 = fmul float %2653, %2655
  %2657 = load float, float* %2636, align 4
  %2658 = fadd float %2657, %2656
  %2659 = getelementptr inbounds i8, i8* %2356, i64 28
  %2660 = bitcast i8* %2659 to float*
  %2661 = load float, float* %2660, align 4
  %2662 = getelementptr inbounds float, float* %1, i64 15
  %2663 = load float, float* %2662, align 4
  %2664 = fmul float %2661, %2663
  %2665 = load float, float* %2636, align 4
  %2666 = fadd float %2665, %2664
  %2667 = getelementptr inbounds i8, i8* %2356, i64 32
  %2668 = bitcast i8* %2667 to float*
  %2669 = getelementptr inbounds i8, i8* %2399, i64 32
  %2670 = bitcast i8* %2669 to float*
  %2671 = getelementptr inbounds i8, i8* %2399, i64 32
  %2672 = bitcast i8* %2671 to float*
  %2673 = load float, float* %2668, align 4
  %2674 = load float, float* %1, align 4
  %2675 = fmul float %2673, %2674
  %2676 = fadd float %2675, 0.000000e+00
  %2677 = getelementptr inbounds i8, i8* %2356, i64 36
  %2678 = bitcast i8* %2677 to float*
  %2679 = load float, float* %2678, align 4
  %2680 = getelementptr inbounds float, float* %1, i64 4
  %2681 = load float, float* %2680, align 4
  %2682 = fmul float %2679, %2681
  %2683 = load float, float* %2672, align 4
  %2684 = fadd float %2683, %2682
  %2685 = getelementptr inbounds i8, i8* %2356, i64 40
  %2686 = bitcast i8* %2685 to float*
  %2687 = load float, float* %2686, align 4
  %2688 = getelementptr inbounds float, float* %1, i64 8
  %2689 = load float, float* %2688, align 4
  %2690 = fmul float %2687, %2689
  %2691 = load float, float* %2672, align 4
  %2692 = fadd float %2691, %2690
  %2693 = getelementptr inbounds i8, i8* %2356, i64 44
  %2694 = bitcast i8* %2693 to float*
  %2695 = load float, float* %2694, align 4
  %2696 = getelementptr inbounds float, float* %1, i64 12
  %2697 = load float, float* %2696, align 4
  %2698 = fmul float %2695, %2697
  %2699 = load float, float* %2672, align 4
  %2700 = fadd float %2699, %2698
  %2701 = getelementptr inbounds i8, i8* %2399, i64 36
  %2702 = bitcast i8* %2701 to float*
  %2703 = getelementptr inbounds i8, i8* %2399, i64 36
  %2704 = bitcast i8* %2703 to float*
  %2705 = load float, float* %2668, align 4
  %2706 = getelementptr inbounds float, float* %1, i64 1
  %2707 = load float, float* %2706, align 4
  %2708 = fmul float %2705, %2707
  %2709 = load float, float* %2704, align 4
  %2710 = fadd float %2709, %2708
  %2711 = getelementptr inbounds i8, i8* %2356, i64 36
  %2712 = bitcast i8* %2711 to float*
  %2713 = load float, float* %2712, align 4
  %2714 = getelementptr inbounds float, float* %1, i64 5
  %2715 = load float, float* %2714, align 4
  %2716 = fmul float %2713, %2715
  %2717 = load float, float* %2704, align 4
  %2718 = fadd float %2717, %2716
  %2719 = getelementptr inbounds i8, i8* %2356, i64 40
  %2720 = bitcast i8* %2719 to float*
  %2721 = load float, float* %2720, align 4
  %2722 = getelementptr inbounds float, float* %1, i64 9
  %2723 = load float, float* %2722, align 4
  %2724 = fmul float %2721, %2723
  %2725 = load float, float* %2704, align 4
  %2726 = fadd float %2725, %2724
  %2727 = getelementptr inbounds i8, i8* %2356, i64 44
  %2728 = bitcast i8* %2727 to float*
  %2729 = load float, float* %2728, align 4
  %2730 = getelementptr inbounds float, float* %1, i64 13
  %2731 = load float, float* %2730, align 4
  %2732 = fmul float %2729, %2731
  %2733 = load float, float* %2704, align 4
  %2734 = fadd float %2733, %2732
  %2735 = getelementptr inbounds i8, i8* %2399, i64 40
  %2736 = bitcast i8* %2735 to float*
  %2737 = getelementptr inbounds i8, i8* %2399, i64 40
  %2738 = bitcast i8* %2737 to float*
  %2739 = load float, float* %2668, align 4
  %2740 = getelementptr inbounds float, float* %1, i64 2
  %2741 = load float, float* %2740, align 4
  %2742 = fmul float %2739, %2741
  %2743 = load float, float* %2738, align 4
  %2744 = fadd float %2743, %2742
  %2745 = getelementptr inbounds i8, i8* %2356, i64 36
  %2746 = bitcast i8* %2745 to float*
  %2747 = load float, float* %2746, align 4
  %2748 = getelementptr inbounds float, float* %1, i64 6
  %2749 = load float, float* %2748, align 4
  %2750 = fmul float %2747, %2749
  %2751 = load float, float* %2738, align 4
  %2752 = fadd float %2751, %2750
  %2753 = getelementptr inbounds i8, i8* %2356, i64 40
  %2754 = bitcast i8* %2753 to float*
  %2755 = load float, float* %2754, align 4
  %2756 = getelementptr inbounds float, float* %1, i64 10
  %2757 = load float, float* %2756, align 4
  %2758 = fmul float %2755, %2757
  %2759 = load float, float* %2738, align 4
  %2760 = fadd float %2759, %2758
  %2761 = getelementptr inbounds i8, i8* %2356, i64 44
  %2762 = bitcast i8* %2761 to float*
  %2763 = load float, float* %2762, align 4
  %2764 = getelementptr inbounds float, float* %1, i64 14
  %2765 = load float, float* %2764, align 4
  %2766 = fmul float %2763, %2765
  %2767 = load float, float* %2738, align 4
  %2768 = fadd float %2767, %2766
  %2769 = getelementptr inbounds i8, i8* %2399, i64 44
  %2770 = bitcast i8* %2769 to float*
  %2771 = getelementptr inbounds i8, i8* %2399, i64 44
  %2772 = bitcast i8* %2771 to float*
  %2773 = load float, float* %2668, align 4
  %2774 = getelementptr inbounds float, float* %1, i64 3
  %2775 = load float, float* %2774, align 4
  %2776 = fmul float %2773, %2775
  %2777 = load float, float* %2772, align 4
  %2778 = fadd float %2777, %2776
  %2779 = getelementptr inbounds i8, i8* %2356, i64 36
  %2780 = bitcast i8* %2779 to float*
  %2781 = load float, float* %2780, align 4
  %2782 = getelementptr inbounds float, float* %1, i64 7
  %2783 = load float, float* %2782, align 4
  %2784 = fmul float %2781, %2783
  %2785 = load float, float* %2772, align 4
  %2786 = fadd float %2785, %2784
  %2787 = getelementptr inbounds i8, i8* %2356, i64 40
  %2788 = bitcast i8* %2787 to float*
  %2789 = load float, float* %2788, align 4
  %2790 = getelementptr inbounds float, float* %1, i64 11
  %2791 = load float, float* %2790, align 4
  %2792 = fmul float %2789, %2791
  %2793 = load float, float* %2772, align 4
  %2794 = fadd float %2793, %2792
  %2795 = getelementptr inbounds i8, i8* %2356, i64 44
  %2796 = bitcast i8* %2795 to float*
  %2797 = load float, float* %2796, align 4
  %2798 = getelementptr inbounds float, float* %1, i64 15
  %2799 = load float, float* %2798, align 4
  %2800 = fmul float %2797, %2799
  %2801 = load float, float* %2772, align 4
  %2802 = fadd float %2801, %2800
  %2803 = getelementptr inbounds i8, i8* %2356, i64 48
  %2804 = bitcast i8* %2803 to float*
  %2805 = getelementptr inbounds i8, i8* %2399, i64 48
  %2806 = bitcast i8* %2805 to float*
  %2807 = getelementptr inbounds i8, i8* %2399, i64 48
  %2808 = bitcast i8* %2807 to float*
  %2809 = load float, float* %2804, align 4
  %2810 = load float, float* %1, align 4
  %2811 = fmul float %2809, %2810
  %2812 = fadd float %2811, 0.000000e+00
  %2813 = getelementptr inbounds i8, i8* %2356, i64 52
  %2814 = bitcast i8* %2813 to float*
  %2815 = load float, float* %2814, align 4
  %2816 = getelementptr inbounds float, float* %1, i64 4
  %2817 = load float, float* %2816, align 4
  %2818 = fmul float %2815, %2817
  %2819 = load float, float* %2808, align 4
  %2820 = fadd float %2819, %2818
  %2821 = getelementptr inbounds i8, i8* %2356, i64 56
  %2822 = bitcast i8* %2821 to float*
  %2823 = load float, float* %2822, align 4
  %2824 = getelementptr inbounds float, float* %1, i64 8
  %2825 = load float, float* %2824, align 4
  %2826 = fmul float %2823, %2825
  %2827 = load float, float* %2808, align 4
  %2828 = fadd float %2827, %2826
  %2829 = getelementptr inbounds i8, i8* %2356, i64 60
  %2830 = bitcast i8* %2829 to float*
  %2831 = load float, float* %2830, align 4
  %2832 = getelementptr inbounds float, float* %1, i64 12
  %2833 = load float, float* %2832, align 4
  %2834 = fmul float %2831, %2833
  %2835 = load float, float* %2808, align 4
  %2836 = fadd float %2835, %2834
  %2837 = getelementptr inbounds i8, i8* %2399, i64 52
  %2838 = bitcast i8* %2837 to float*
  %2839 = getelementptr inbounds i8, i8* %2399, i64 52
  %2840 = bitcast i8* %2839 to float*
  %2841 = load float, float* %2804, align 4
  %2842 = getelementptr inbounds float, float* %1, i64 1
  %2843 = load float, float* %2842, align 4
  %2844 = fmul float %2841, %2843
  %2845 = load float, float* %2840, align 4
  %2846 = fadd float %2845, %2844
  %2847 = getelementptr inbounds i8, i8* %2356, i64 52
  %2848 = bitcast i8* %2847 to float*
  %2849 = load float, float* %2848, align 4
  %2850 = getelementptr inbounds float, float* %1, i64 5
  %2851 = load float, float* %2850, align 4
  %2852 = fmul float %2849, %2851
  %2853 = load float, float* %2840, align 4
  %2854 = fadd float %2853, %2852
  %2855 = getelementptr inbounds i8, i8* %2356, i64 56
  %2856 = bitcast i8* %2855 to float*
  %2857 = load float, float* %2856, align 4
  %2858 = getelementptr inbounds float, float* %1, i64 9
  %2859 = load float, float* %2858, align 4
  %2860 = fmul float %2857, %2859
  %2861 = load float, float* %2840, align 4
  %2862 = fadd float %2861, %2860
  %2863 = getelementptr inbounds i8, i8* %2356, i64 60
  %2864 = bitcast i8* %2863 to float*
  %2865 = load float, float* %2864, align 4
  %2866 = getelementptr inbounds float, float* %1, i64 13
  %2867 = load float, float* %2866, align 4
  %2868 = fmul float %2865, %2867
  %2869 = load float, float* %2840, align 4
  %2870 = fadd float %2869, %2868
  %2871 = getelementptr inbounds i8, i8* %2399, i64 56
  %2872 = bitcast i8* %2871 to float*
  %2873 = getelementptr inbounds i8, i8* %2399, i64 56
  %2874 = bitcast i8* %2873 to float*
  %2875 = load float, float* %2804, align 4
  %2876 = getelementptr inbounds float, float* %1, i64 2
  %2877 = load float, float* %2876, align 4
  %2878 = fmul float %2875, %2877
  %2879 = load float, float* %2874, align 4
  %2880 = fadd float %2879, %2878
  %2881 = getelementptr inbounds i8, i8* %2356, i64 52
  %2882 = bitcast i8* %2881 to float*
  %2883 = load float, float* %2882, align 4
  %2884 = getelementptr inbounds float, float* %1, i64 6
  %2885 = load float, float* %2884, align 4
  %2886 = fmul float %2883, %2885
  %2887 = load float, float* %2874, align 4
  %2888 = fadd float %2887, %2886
  %2889 = getelementptr inbounds i8, i8* %2356, i64 56
  %2890 = bitcast i8* %2889 to float*
  %2891 = load float, float* %2890, align 4
  %2892 = getelementptr inbounds float, float* %1, i64 10
  %2893 = load float, float* %2892, align 4
  %2894 = fmul float %2891, %2893
  %2895 = load float, float* %2874, align 4
  %2896 = fadd float %2895, %2894
  %2897 = getelementptr inbounds i8, i8* %2356, i64 60
  %2898 = bitcast i8* %2897 to float*
  %2899 = load float, float* %2898, align 4
  %2900 = getelementptr inbounds float, float* %1, i64 14
  %2901 = load float, float* %2900, align 4
  %2902 = fmul float %2899, %2901
  %2903 = load float, float* %2874, align 4
  %2904 = fadd float %2903, %2902
  %2905 = getelementptr inbounds i8, i8* %2399, i64 60
  %2906 = bitcast i8* %2905 to float*
  %2907 = getelementptr inbounds i8, i8* %2399, i64 60
  %2908 = bitcast i8* %2907 to float*
  %2909 = load float, float* %2804, align 4
  %2910 = getelementptr inbounds float, float* %1, i64 3
  %2911 = load float, float* %2910, align 4
  %2912 = fmul float %2909, %2911
  %2913 = load float, float* %2908, align 4
  %2914 = fadd float %2913, %2912
  %2915 = getelementptr inbounds i8, i8* %2356, i64 52
  %2916 = bitcast i8* %2915 to float*
  %2917 = load float, float* %2916, align 4
  %2918 = getelementptr inbounds float, float* %1, i64 7
  %2919 = load float, float* %2918, align 4
  %2920 = fmul float %2917, %2919
  %2921 = load float, float* %2908, align 4
  %2922 = fadd float %2921, %2920
  %2923 = getelementptr inbounds i8, i8* %2356, i64 56
  %2924 = bitcast i8* %2923 to float*
  %2925 = load float, float* %2924, align 4
  %2926 = getelementptr inbounds float, float* %1, i64 11
  %2927 = load float, float* %2926, align 4
  %2928 = fmul float %2925, %2927
  %2929 = load float, float* %2908, align 4
  %2930 = fadd float %2929, %2928
  %2931 = getelementptr inbounds i8, i8* %2356, i64 60
  %2932 = bitcast i8* %2931 to float*
  %2933 = load float, float* %2932, align 4
  %2934 = getelementptr inbounds float, float* %1, i64 15
  %2935 = load float, float* %2934, align 4
  %2936 = fmul float %2933, %2935
  %2937 = load float, float* %2908, align 4
  %2938 = fadd float %2937, %2936
  %2939 = call i8* @__memcpy_chk(i8* nonnull %40, i8* %2399, i64 64, i64 %42) #9
  %2940 = load float, float* %2357, align 4
  %2941 = load float, float* %2, align 4
  %2942 = fmul float %2940, %2941
  %2943 = fadd float %2942, 0.000000e+00
  %2944 = getelementptr inbounds i8, i8* %2356, i64 4
  %2945 = bitcast i8* %2944 to float*
  %2946 = load float, float* %2945, align 4
  %2947 = getelementptr inbounds float, float* %2, i64 4
  %2948 = load float, float* %2947, align 4
  %2949 = fmul float %2946, %2948
  %2950 = load float, float* %2400, align 4
  %2951 = fadd float %2950, %2949
  %2952 = getelementptr inbounds i8, i8* %2356, i64 8
  %2953 = bitcast i8* %2952 to float*
  %2954 = load float, float* %2953, align 4
  %2955 = getelementptr inbounds float, float* %2, i64 8
  %2956 = load float, float* %2955, align 4
  %2957 = fmul float %2954, %2956
  %2958 = load float, float* %2400, align 4
  %2959 = fadd float %2958, %2957
  %2960 = getelementptr inbounds i8, i8* %2356, i64 12
  %2961 = bitcast i8* %2960 to float*
  %2962 = load float, float* %2961, align 4
  %2963 = getelementptr inbounds float, float* %2, i64 12
  %2964 = load float, float* %2963, align 4
  %2965 = fmul float %2962, %2964
  %2966 = load float, float* %2400, align 4
  %2967 = fadd float %2966, %2965
  %2968 = getelementptr inbounds i8, i8* %2399, i64 4
  %2969 = bitcast i8* %2968 to float*
  %2970 = getelementptr inbounds i8, i8* %2399, i64 4
  %2971 = bitcast i8* %2970 to float*
  %2972 = load float, float* %2357, align 4
  %2973 = getelementptr inbounds float, float* %2, i64 1
  %2974 = load float, float* %2973, align 4
  %2975 = fmul float %2972, %2974
  %2976 = load float, float* %2971, align 4
  %2977 = fadd float %2976, %2975
  %2978 = getelementptr inbounds i8, i8* %2356, i64 4
  %2979 = bitcast i8* %2978 to float*
  %2980 = load float, float* %2979, align 4
  %2981 = getelementptr inbounds float, float* %2, i64 5
  %2982 = load float, float* %2981, align 4
  %2983 = fmul float %2980, %2982
  %2984 = load float, float* %2971, align 4
  %2985 = fadd float %2984, %2983
  %2986 = getelementptr inbounds i8, i8* %2356, i64 8
  %2987 = bitcast i8* %2986 to float*
  %2988 = load float, float* %2987, align 4
  %2989 = getelementptr inbounds float, float* %2, i64 9
  %2990 = load float, float* %2989, align 4
  %2991 = fmul float %2988, %2990
  %2992 = load float, float* %2971, align 4
  %2993 = fadd float %2992, %2991
  %2994 = getelementptr inbounds i8, i8* %2356, i64 12
  %2995 = bitcast i8* %2994 to float*
  %2996 = load float, float* %2995, align 4
  %2997 = getelementptr inbounds float, float* %2, i64 13
  %2998 = load float, float* %2997, align 4
  %2999 = fmul float %2996, %2998
  %3000 = load float, float* %2971, align 4
  %3001 = fadd float %3000, %2999
  %3002 = getelementptr inbounds i8, i8* %2399, i64 8
  %3003 = bitcast i8* %3002 to float*
  %3004 = getelementptr inbounds i8, i8* %2399, i64 8
  %3005 = bitcast i8* %3004 to float*
  %3006 = load float, float* %2357, align 4
  %3007 = getelementptr inbounds float, float* %2, i64 2
  %3008 = load float, float* %3007, align 4
  %3009 = fmul float %3006, %3008
  %3010 = load float, float* %3005, align 4
  %3011 = fadd float %3010, %3009
  %3012 = getelementptr inbounds i8, i8* %2356, i64 4
  %3013 = bitcast i8* %3012 to float*
  %3014 = load float, float* %3013, align 4
  %3015 = getelementptr inbounds float, float* %2, i64 6
  %3016 = load float, float* %3015, align 4
  %3017 = fmul float %3014, %3016
  %3018 = load float, float* %3005, align 4
  %3019 = fadd float %3018, %3017
  %3020 = getelementptr inbounds i8, i8* %2356, i64 8
  %3021 = bitcast i8* %3020 to float*
  %3022 = load float, float* %3021, align 4
  %3023 = getelementptr inbounds float, float* %2, i64 10
  %3024 = load float, float* %3023, align 4
  %3025 = fmul float %3022, %3024
  %3026 = load float, float* %3005, align 4
  %3027 = fadd float %3026, %3025
  %3028 = getelementptr inbounds i8, i8* %2356, i64 12
  %3029 = bitcast i8* %3028 to float*
  %3030 = load float, float* %3029, align 4
  %3031 = getelementptr inbounds float, float* %2, i64 14
  %3032 = load float, float* %3031, align 4
  %3033 = fmul float %3030, %3032
  %3034 = load float, float* %3005, align 4
  %3035 = fadd float %3034, %3033
  %3036 = getelementptr inbounds i8, i8* %2399, i64 12
  %3037 = bitcast i8* %3036 to float*
  %3038 = getelementptr inbounds i8, i8* %2399, i64 12
  %3039 = bitcast i8* %3038 to float*
  %3040 = load float, float* %2357, align 4
  %3041 = getelementptr inbounds float, float* %2, i64 3
  %3042 = load float, float* %3041, align 4
  %3043 = fmul float %3040, %3042
  %3044 = load float, float* %3039, align 4
  %3045 = fadd float %3044, %3043
  %3046 = getelementptr inbounds i8, i8* %2356, i64 4
  %3047 = bitcast i8* %3046 to float*
  %3048 = load float, float* %3047, align 4
  %3049 = getelementptr inbounds float, float* %2, i64 7
  %3050 = load float, float* %3049, align 4
  %3051 = fmul float %3048, %3050
  %3052 = load float, float* %3039, align 4
  %3053 = fadd float %3052, %3051
  %3054 = getelementptr inbounds i8, i8* %2356, i64 8
  %3055 = bitcast i8* %3054 to float*
  %3056 = load float, float* %3055, align 4
  %3057 = getelementptr inbounds float, float* %2, i64 11
  %3058 = load float, float* %3057, align 4
  %3059 = fmul float %3056, %3058
  %3060 = load float, float* %3039, align 4
  %3061 = fadd float %3060, %3059
  %3062 = getelementptr inbounds i8, i8* %2356, i64 12
  %3063 = bitcast i8* %3062 to float*
  %3064 = load float, float* %3063, align 4
  %3065 = getelementptr inbounds float, float* %2, i64 15
  %3066 = load float, float* %3065, align 4
  %3067 = fmul float %3064, %3066
  %3068 = load float, float* %3039, align 4
  %3069 = fadd float %3068, %3067
  %3070 = getelementptr inbounds i8, i8* %2356, i64 16
  %3071 = bitcast i8* %3070 to float*
  %3072 = getelementptr inbounds i8, i8* %2399, i64 16
  %3073 = bitcast i8* %3072 to float*
  %3074 = getelementptr inbounds i8, i8* %2399, i64 16
  %3075 = bitcast i8* %3074 to float*
  %3076 = load float, float* %3071, align 4
  %3077 = load float, float* %2, align 4
  %3078 = fmul float %3076, %3077
  %3079 = fadd float %3078, 0.000000e+00
  %3080 = getelementptr inbounds i8, i8* %2356, i64 20
  %3081 = bitcast i8* %3080 to float*
  %3082 = load float, float* %3081, align 4
  %3083 = getelementptr inbounds float, float* %2, i64 4
  %3084 = load float, float* %3083, align 4
  %3085 = fmul float %3082, %3084
  %3086 = load float, float* %3075, align 4
  %3087 = fadd float %3086, %3085
  %3088 = getelementptr inbounds i8, i8* %2356, i64 24
  %3089 = bitcast i8* %3088 to float*
  %3090 = load float, float* %3089, align 4
  %3091 = getelementptr inbounds float, float* %2, i64 8
  %3092 = load float, float* %3091, align 4
  %3093 = fmul float %3090, %3092
  %3094 = load float, float* %3075, align 4
  %3095 = fadd float %3094, %3093
  %3096 = getelementptr inbounds i8, i8* %2356, i64 28
  %3097 = bitcast i8* %3096 to float*
  %3098 = load float, float* %3097, align 4
  %3099 = getelementptr inbounds float, float* %2, i64 12
  %3100 = load float, float* %3099, align 4
  %3101 = fmul float %3098, %3100
  %3102 = load float, float* %3075, align 4
  %3103 = fadd float %3102, %3101
  %3104 = getelementptr inbounds i8, i8* %2399, i64 20
  %3105 = bitcast i8* %3104 to float*
  %3106 = getelementptr inbounds i8, i8* %2399, i64 20
  %3107 = bitcast i8* %3106 to float*
  %3108 = load float, float* %3071, align 4
  %3109 = getelementptr inbounds float, float* %2, i64 1
  %3110 = load float, float* %3109, align 4
  %3111 = fmul float %3108, %3110
  %3112 = load float, float* %3107, align 4
  %3113 = fadd float %3112, %3111
  %3114 = getelementptr inbounds i8, i8* %2356, i64 20
  %3115 = bitcast i8* %3114 to float*
  %3116 = load float, float* %3115, align 4
  %3117 = getelementptr inbounds float, float* %2, i64 5
  %3118 = load float, float* %3117, align 4
  %3119 = fmul float %3116, %3118
  %3120 = load float, float* %3107, align 4
  %3121 = fadd float %3120, %3119
  %3122 = getelementptr inbounds i8, i8* %2356, i64 24
  %3123 = bitcast i8* %3122 to float*
  %3124 = load float, float* %3123, align 4
  %3125 = getelementptr inbounds float, float* %2, i64 9
  %3126 = load float, float* %3125, align 4
  %3127 = fmul float %3124, %3126
  %3128 = load float, float* %3107, align 4
  %3129 = fadd float %3128, %3127
  %3130 = getelementptr inbounds i8, i8* %2356, i64 28
  %3131 = bitcast i8* %3130 to float*
  %3132 = load float, float* %3131, align 4
  %3133 = getelementptr inbounds float, float* %2, i64 13
  %3134 = load float, float* %3133, align 4
  %3135 = fmul float %3132, %3134
  %3136 = load float, float* %3107, align 4
  %3137 = fadd float %3136, %3135
  %3138 = getelementptr inbounds i8, i8* %2399, i64 24
  %3139 = bitcast i8* %3138 to float*
  %3140 = getelementptr inbounds i8, i8* %2399, i64 24
  %3141 = bitcast i8* %3140 to float*
  %3142 = load float, float* %3071, align 4
  %3143 = getelementptr inbounds float, float* %2, i64 2
  %3144 = load float, float* %3143, align 4
  %3145 = fmul float %3142, %3144
  %3146 = load float, float* %3141, align 4
  %3147 = fadd float %3146, %3145
  %3148 = getelementptr inbounds i8, i8* %2356, i64 20
  %3149 = bitcast i8* %3148 to float*
  %3150 = load float, float* %3149, align 4
  %3151 = getelementptr inbounds float, float* %2, i64 6
  %3152 = load float, float* %3151, align 4
  %3153 = fmul float %3150, %3152
  %3154 = load float, float* %3141, align 4
  %3155 = fadd float %3154, %3153
  %3156 = getelementptr inbounds i8, i8* %2356, i64 24
  %3157 = bitcast i8* %3156 to float*
  %3158 = load float, float* %3157, align 4
  %3159 = getelementptr inbounds float, float* %2, i64 10
  %3160 = load float, float* %3159, align 4
  %3161 = fmul float %3158, %3160
  %3162 = load float, float* %3141, align 4
  %3163 = fadd float %3162, %3161
  %3164 = getelementptr inbounds i8, i8* %2356, i64 28
  %3165 = bitcast i8* %3164 to float*
  %3166 = load float, float* %3165, align 4
  %3167 = getelementptr inbounds float, float* %2, i64 14
  %3168 = load float, float* %3167, align 4
  %3169 = fmul float %3166, %3168
  %3170 = load float, float* %3141, align 4
  %3171 = fadd float %3170, %3169
  %3172 = getelementptr inbounds i8, i8* %2399, i64 28
  %3173 = bitcast i8* %3172 to float*
  %3174 = getelementptr inbounds i8, i8* %2399, i64 28
  %3175 = bitcast i8* %3174 to float*
  %3176 = load float, float* %3071, align 4
  %3177 = getelementptr inbounds float, float* %2, i64 3
  %3178 = load float, float* %3177, align 4
  %3179 = fmul float %3176, %3178
  %3180 = load float, float* %3175, align 4
  %3181 = fadd float %3180, %3179
  %3182 = getelementptr inbounds i8, i8* %2356, i64 20
  %3183 = bitcast i8* %3182 to float*
  %3184 = load float, float* %3183, align 4
  %3185 = getelementptr inbounds float, float* %2, i64 7
  %3186 = load float, float* %3185, align 4
  %3187 = fmul float %3184, %3186
  %3188 = load float, float* %3175, align 4
  %3189 = fadd float %3188, %3187
  %3190 = getelementptr inbounds i8, i8* %2356, i64 24
  %3191 = bitcast i8* %3190 to float*
  %3192 = load float, float* %3191, align 4
  %3193 = getelementptr inbounds float, float* %2, i64 11
  %3194 = load float, float* %3193, align 4
  %3195 = fmul float %3192, %3194
  %3196 = load float, float* %3175, align 4
  %3197 = fadd float %3196, %3195
  %3198 = getelementptr inbounds i8, i8* %2356, i64 28
  %3199 = bitcast i8* %3198 to float*
  %3200 = load float, float* %3199, align 4
  %3201 = getelementptr inbounds float, float* %2, i64 15
  %3202 = load float, float* %3201, align 4
  %3203 = fmul float %3200, %3202
  %3204 = load float, float* %3175, align 4
  %3205 = fadd float %3204, %3203
  %3206 = getelementptr inbounds i8, i8* %2356, i64 32
  %3207 = bitcast i8* %3206 to float*
  %3208 = getelementptr inbounds i8, i8* %2399, i64 32
  %3209 = bitcast i8* %3208 to float*
  %3210 = getelementptr inbounds i8, i8* %2399, i64 32
  %3211 = bitcast i8* %3210 to float*
  %3212 = load float, float* %3207, align 4
  %3213 = load float, float* %2, align 4
  %3214 = fmul float %3212, %3213
  %3215 = fadd float %3214, 0.000000e+00
  %3216 = getelementptr inbounds i8, i8* %2356, i64 36
  %3217 = bitcast i8* %3216 to float*
  %3218 = load float, float* %3217, align 4
  %3219 = getelementptr inbounds float, float* %2, i64 4
  %3220 = load float, float* %3219, align 4
  %3221 = fmul float %3218, %3220
  %3222 = load float, float* %3211, align 4
  %3223 = fadd float %3222, %3221
  %3224 = getelementptr inbounds i8, i8* %2356, i64 40
  %3225 = bitcast i8* %3224 to float*
  %3226 = load float, float* %3225, align 4
  %3227 = getelementptr inbounds float, float* %2, i64 8
  %3228 = load float, float* %3227, align 4
  %3229 = fmul float %3226, %3228
  %3230 = load float, float* %3211, align 4
  %3231 = fadd float %3230, %3229
  %3232 = getelementptr inbounds i8, i8* %2356, i64 44
  %3233 = bitcast i8* %3232 to float*
  %3234 = load float, float* %3233, align 4
  %3235 = getelementptr inbounds float, float* %2, i64 12
  %3236 = load float, float* %3235, align 4
  %3237 = fmul float %3234, %3236
  %3238 = load float, float* %3211, align 4
  %3239 = fadd float %3238, %3237
  %3240 = getelementptr inbounds i8, i8* %2399, i64 36
  %3241 = bitcast i8* %3240 to float*
  %3242 = getelementptr inbounds i8, i8* %2399, i64 36
  %3243 = bitcast i8* %3242 to float*
  %3244 = load float, float* %3207, align 4
  %3245 = getelementptr inbounds float, float* %2, i64 1
  %3246 = load float, float* %3245, align 4
  %3247 = fmul float %3244, %3246
  %3248 = load float, float* %3243, align 4
  %3249 = fadd float %3248, %3247
  %3250 = getelementptr inbounds i8, i8* %2356, i64 36
  %3251 = bitcast i8* %3250 to float*
  %3252 = load float, float* %3251, align 4
  %3253 = getelementptr inbounds float, float* %2, i64 5
  %3254 = load float, float* %3253, align 4
  %3255 = fmul float %3252, %3254
  %3256 = load float, float* %3243, align 4
  %3257 = fadd float %3256, %3255
  %3258 = getelementptr inbounds i8, i8* %2356, i64 40
  %3259 = bitcast i8* %3258 to float*
  %3260 = load float, float* %3259, align 4
  %3261 = getelementptr inbounds float, float* %2, i64 9
  %3262 = load float, float* %3261, align 4
  %3263 = fmul float %3260, %3262
  %3264 = load float, float* %3243, align 4
  %3265 = fadd float %3264, %3263
  %3266 = getelementptr inbounds i8, i8* %2356, i64 44
  %3267 = bitcast i8* %3266 to float*
  %3268 = load float, float* %3267, align 4
  %3269 = getelementptr inbounds float, float* %2, i64 13
  %3270 = load float, float* %3269, align 4
  %3271 = fmul float %3268, %3270
  %3272 = load float, float* %3243, align 4
  %3273 = fadd float %3272, %3271
  %3274 = getelementptr inbounds i8, i8* %2399, i64 40
  %3275 = bitcast i8* %3274 to float*
  %3276 = getelementptr inbounds i8, i8* %2399, i64 40
  %3277 = bitcast i8* %3276 to float*
  %3278 = load float, float* %3207, align 4
  %3279 = getelementptr inbounds float, float* %2, i64 2
  %3280 = load float, float* %3279, align 4
  %3281 = fmul float %3278, %3280
  %3282 = load float, float* %3277, align 4
  %3283 = fadd float %3282, %3281
  %3284 = getelementptr inbounds i8, i8* %2356, i64 36
  %3285 = bitcast i8* %3284 to float*
  %3286 = load float, float* %3285, align 4
  %3287 = getelementptr inbounds float, float* %2, i64 6
  %3288 = load float, float* %3287, align 4
  %3289 = fmul float %3286, %3288
  %3290 = load float, float* %3277, align 4
  %3291 = fadd float %3290, %3289
  %3292 = getelementptr inbounds i8, i8* %2356, i64 40
  %3293 = bitcast i8* %3292 to float*
  %3294 = load float, float* %3293, align 4
  %3295 = getelementptr inbounds float, float* %2, i64 10
  %3296 = load float, float* %3295, align 4
  %3297 = fmul float %3294, %3296
  %3298 = load float, float* %3277, align 4
  %3299 = fadd float %3298, %3297
  %3300 = getelementptr inbounds i8, i8* %2356, i64 44
  %3301 = bitcast i8* %3300 to float*
  %3302 = load float, float* %3301, align 4
  %3303 = getelementptr inbounds float, float* %2, i64 14
  %3304 = load float, float* %3303, align 4
  %3305 = fmul float %3302, %3304
  %3306 = load float, float* %3277, align 4
  %3307 = fadd float %3306, %3305
  %3308 = getelementptr inbounds i8, i8* %2399, i64 44
  %3309 = bitcast i8* %3308 to float*
  %3310 = getelementptr inbounds i8, i8* %2399, i64 44
  %3311 = bitcast i8* %3310 to float*
  %3312 = load float, float* %3207, align 4
  %3313 = getelementptr inbounds float, float* %2, i64 3
  %3314 = load float, float* %3313, align 4
  %3315 = fmul float %3312, %3314
  %3316 = load float, float* %3311, align 4
  %3317 = fadd float %3316, %3315
  %3318 = getelementptr inbounds i8, i8* %2356, i64 36
  %3319 = bitcast i8* %3318 to float*
  %3320 = load float, float* %3319, align 4
  %3321 = getelementptr inbounds float, float* %2, i64 7
  %3322 = load float, float* %3321, align 4
  %3323 = fmul float %3320, %3322
  %3324 = load float, float* %3311, align 4
  %3325 = fadd float %3324, %3323
  %3326 = getelementptr inbounds i8, i8* %2356, i64 40
  %3327 = bitcast i8* %3326 to float*
  %3328 = load float, float* %3327, align 4
  %3329 = getelementptr inbounds float, float* %2, i64 11
  %3330 = load float, float* %3329, align 4
  %3331 = fmul float %3328, %3330
  %3332 = load float, float* %3311, align 4
  %3333 = fadd float %3332, %3331
  %3334 = getelementptr inbounds i8, i8* %2356, i64 44
  %3335 = bitcast i8* %3334 to float*
  %3336 = load float, float* %3335, align 4
  %3337 = getelementptr inbounds float, float* %2, i64 15
  %3338 = load float, float* %3337, align 4
  %3339 = fmul float %3336, %3338
  %3340 = load float, float* %3311, align 4
  %3341 = fadd float %3340, %3339
  %3342 = getelementptr inbounds i8, i8* %2356, i64 48
  %3343 = bitcast i8* %3342 to float*
  %3344 = getelementptr inbounds i8, i8* %2399, i64 48
  %3345 = bitcast i8* %3344 to float*
  %3346 = getelementptr inbounds i8, i8* %2399, i64 48
  %3347 = bitcast i8* %3346 to float*
  %3348 = load float, float* %3343, align 4
  %3349 = load float, float* %2, align 4
  %3350 = fmul float %3348, %3349
  %3351 = fadd float %3350, 0.000000e+00
  %3352 = getelementptr inbounds i8, i8* %2356, i64 52
  %3353 = bitcast i8* %3352 to float*
  %3354 = load float, float* %3353, align 4
  %3355 = getelementptr inbounds float, float* %2, i64 4
  %3356 = load float, float* %3355, align 4
  %3357 = fmul float %3354, %3356
  %3358 = load float, float* %3347, align 4
  %3359 = fadd float %3358, %3357
  %3360 = getelementptr inbounds i8, i8* %2356, i64 56
  %3361 = bitcast i8* %3360 to float*
  %3362 = load float, float* %3361, align 4
  %3363 = getelementptr inbounds float, float* %2, i64 8
  %3364 = load float, float* %3363, align 4
  %3365 = fmul float %3362, %3364
  %3366 = load float, float* %3347, align 4
  %3367 = fadd float %3366, %3365
  %3368 = getelementptr inbounds i8, i8* %2356, i64 60
  %3369 = bitcast i8* %3368 to float*
  %3370 = load float, float* %3369, align 4
  %3371 = getelementptr inbounds float, float* %2, i64 12
  %3372 = load float, float* %3371, align 4
  %3373 = fmul float %3370, %3372
  %3374 = load float, float* %3347, align 4
  %3375 = fadd float %3374, %3373
  %3376 = getelementptr inbounds i8, i8* %2399, i64 52
  %3377 = bitcast i8* %3376 to float*
  %3378 = getelementptr inbounds i8, i8* %2399, i64 52
  %3379 = bitcast i8* %3378 to float*
  %3380 = load float, float* %3343, align 4
  %3381 = getelementptr inbounds float, float* %2, i64 1
  %3382 = load float, float* %3381, align 4
  %3383 = fmul float %3380, %3382
  %3384 = load float, float* %3379, align 4
  %3385 = fadd float %3384, %3383
  %3386 = getelementptr inbounds i8, i8* %2356, i64 52
  %3387 = bitcast i8* %3386 to float*
  %3388 = load float, float* %3387, align 4
  %3389 = getelementptr inbounds float, float* %2, i64 5
  %3390 = load float, float* %3389, align 4
  %3391 = fmul float %3388, %3390
  %3392 = load float, float* %3379, align 4
  %3393 = fadd float %3392, %3391
  %3394 = getelementptr inbounds i8, i8* %2356, i64 56
  %3395 = bitcast i8* %3394 to float*
  %3396 = load float, float* %3395, align 4
  %3397 = getelementptr inbounds float, float* %2, i64 9
  %3398 = load float, float* %3397, align 4
  %3399 = fmul float %3396, %3398
  %3400 = load float, float* %3379, align 4
  %3401 = fadd float %3400, %3399
  %3402 = getelementptr inbounds i8, i8* %2356, i64 60
  %3403 = bitcast i8* %3402 to float*
  %3404 = load float, float* %3403, align 4
  %3405 = getelementptr inbounds float, float* %2, i64 13
  %3406 = load float, float* %3405, align 4
  %3407 = fmul float %3404, %3406
  %3408 = load float, float* %3379, align 4
  %3409 = fadd float %3408, %3407
  %3410 = getelementptr inbounds i8, i8* %2399, i64 56
  %3411 = bitcast i8* %3410 to float*
  %3412 = getelementptr inbounds i8, i8* %2399, i64 56
  %3413 = bitcast i8* %3412 to float*
  %3414 = load float, float* %3343, align 4
  %3415 = getelementptr inbounds float, float* %2, i64 2
  %3416 = load float, float* %3415, align 4
  %3417 = fmul float %3414, %3416
  %3418 = load float, float* %3413, align 4
  %3419 = fadd float %3418, %3417
  %3420 = getelementptr inbounds i8, i8* %2356, i64 52
  %3421 = bitcast i8* %3420 to float*
  %3422 = load float, float* %3421, align 4
  %3423 = getelementptr inbounds float, float* %2, i64 6
  %3424 = load float, float* %3423, align 4
  %3425 = fmul float %3422, %3424
  %3426 = load float, float* %3413, align 4
  %3427 = fadd float %3426, %3425
  %3428 = getelementptr inbounds i8, i8* %2356, i64 56
  %3429 = bitcast i8* %3428 to float*
  %3430 = load float, float* %3429, align 4
  %3431 = getelementptr inbounds float, float* %2, i64 10
  %3432 = load float, float* %3431, align 4
  %3433 = fmul float %3430, %3432
  %3434 = load float, float* %3413, align 4
  %3435 = fadd float %3434, %3433
  %3436 = getelementptr inbounds i8, i8* %2356, i64 60
  %3437 = bitcast i8* %3436 to float*
  %3438 = load float, float* %3437, align 4
  %3439 = getelementptr inbounds float, float* %2, i64 14
  %3440 = load float, float* %3439, align 4
  %3441 = fmul float %3438, %3440
  %3442 = load float, float* %3413, align 4
  %3443 = fadd float %3442, %3441
  %3444 = getelementptr inbounds i8, i8* %2399, i64 60
  %3445 = bitcast i8* %3444 to float*
  %3446 = getelementptr inbounds i8, i8* %2399, i64 60
  %3447 = bitcast i8* %3446 to float*
  %3448 = load float, float* %3343, align 4
  %3449 = getelementptr inbounds float, float* %2, i64 3
  %3450 = load float, float* %3449, align 4
  %3451 = fmul float %3448, %3450
  %3452 = load float, float* %3447, align 4
  %3453 = fadd float %3452, %3451
  %3454 = getelementptr inbounds i8, i8* %2356, i64 52
  %3455 = bitcast i8* %3454 to float*
  %3456 = load float, float* %3455, align 4
  %3457 = getelementptr inbounds float, float* %2, i64 7
  %3458 = load float, float* %3457, align 4
  %3459 = fmul float %3456, %3458
  %3460 = load float, float* %3447, align 4
  %3461 = fadd float %3460, %3459
  %3462 = getelementptr inbounds i8, i8* %2356, i64 56
  %3463 = bitcast i8* %3462 to float*
  %3464 = load float, float* %3463, align 4
  %3465 = getelementptr inbounds float, float* %2, i64 11
  %3466 = load float, float* %3465, align 4
  %3467 = fmul float %3464, %3466
  %3468 = load float, float* %3447, align 4
  %3469 = fadd float %3468, %3467
  %3470 = getelementptr inbounds i8, i8* %2356, i64 60
  %3471 = bitcast i8* %3470 to float*
  %3472 = load float, float* %3471, align 4
  %3473 = getelementptr inbounds float, float* %2, i64 15
  %3474 = load float, float* %3473, align 4
  %3475 = fmul float %3472, %3474
  %3476 = load float, float* %3447, align 4
  %3477 = fadd float %3476, %3475
  %3478 = call i8* @__memcpy_chk(i8* nonnull %43, i8* %2399, i64 64, i64 %45) #9
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
  %3487 = getelementptr inbounds float, float* %1, i64 4
  %3488 = bitcast float* %3487 to i32*
  %3489 = bitcast float* %2 to i32*
  %3490 = load i32, i32* %3489, align 4
  %3491 = sitofp i32 %3490 to float
  %3492 = insertelement <4 x float> zeroinitializer, float %3491, i32 0
  %3493 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3494 = bitcast i8* %3493 to i32*
  %3495 = load i32, i32* %3494, align 4
  %3496 = sitofp i32 %3495 to float
  %3497 = insertelement <4 x float> %3492, float %3496, i32 1
  %3498 = getelementptr inbounds float, float* %2, i64 4
  %3499 = bitcast float* %3498 to i32*
  %3500 = load i32, i32* %3499, align 4
  %3501 = sitofp i32 %3500 to float
  %3502 = insertelement <4 x float> %3497, float %3501, i32 2
  %3503 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3504 = getelementptr inbounds i8, i8* %3503, i64 16
  %3505 = bitcast i8* %3504 to i32*
  %3506 = load i32, i32* %3505, align 4
  %3507 = sitofp i32 %3506 to float
  %3508 = insertelement <4 x float> %3502, float %3507, i32 3
  %3509 = getelementptr inbounds float, float* %2, i64 8
  %3510 = bitcast float* %3509 to i32*
  %3511 = load i32, i32* %3510, align 4
  %3512 = sitofp i32 %3511 to float
  %3513 = insertelement <4 x float> zeroinitializer, float %3512, i32 0
  %3514 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3515 = getelementptr inbounds i8, i8* %3514, i64 32
  %3516 = bitcast i8* %3515 to i32*
  %3517 = load i32, i32* %3516, align 4
  %3518 = sitofp i32 %3517 to float
  %3519 = insertelement <4 x float> %3513, float %3518, i32 1
  %3520 = getelementptr inbounds float, float* %2, i64 12
  %3521 = bitcast float* %3520 to i32*
  %3522 = load i32, i32* %3521, align 4
  %3523 = sitofp i32 %3522 to float
  %3524 = insertelement <4 x float> %3519, float %3523, i32 2
  %3525 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3526 = getelementptr inbounds i8, i8* %3525, i64 48
  %3527 = bitcast i8* %3526 to i32*
  %3528 = load i32, i32* %3527, align 4
  %3529 = sitofp i32 %3528 to float
  %3530 = insertelement <4 x float> %3524, float %3529, i32 3
  %3531 = shufflevector <4 x float> %3508, <4 x float> %3530, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %3532 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3533 = bitcast i8* %3532 to float*
  %3534 = load float, float* %3533, align 4
  %3535 = insertelement <4 x float> zeroinitializer, float %3534, i32 0
  %3536 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3537 = getelementptr inbounds i8, i8* %3536, i64 4
  %3538 = bitcast i8* %3537 to float*
  %3539 = load float, float* %3538, align 4
  %3540 = insertelement <4 x float> %3535, float %3539, i32 1
  %3541 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3542 = getelementptr inbounds i8, i8* %3541, i64 8
  %3543 = bitcast i8* %3542 to float*
  %3544 = load float, float* %3543, align 4
  %3545 = insertelement <4 x float> %3540, float %3544, i32 2
  %3546 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3547 = getelementptr inbounds i8, i8* %3546, i64 12
  %3548 = bitcast i8* %3547 to float*
  %3549 = load float, float* %3548, align 4
  %3550 = insertelement <4 x float> %3545, float %3549, i32 3
  %3551 = insertelement <4 x float> zeroinitializer, float %121, i32 0
  %3552 = insertelement <4 x float> %3551, float %121, i32 1
  %3553 = insertelement <4 x float> %3552, float %121, i32 2
  %3554 = insertelement <4 x float> %3553, float %121, i32 3
  %3555 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3556 = bitcast i8* %3555 to float*
  %3557 = load float, float* %3556, align 4
  %3558 = fcmp olt float %3557, 0.000000e+00
  %3559 = sext i1 %3558 to i32
  %3560 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3561 = bitcast i8* %3560 to float*
  %3562 = load float, float* %3561, align 4
  %3563 = fcmp ogt float %3562, 0.000000e+00
  %3564 = zext i1 %3563 to i32
  %3565 = add nsw i32 %3559, %3564
  %3566 = sitofp i32 %3565 to float
  %3567 = insertelement <4 x float> zeroinitializer, float %3566, i32 0
  %3568 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3569 = bitcast i8* %3568 to float*
  %3570 = load float, float* %3569, align 4
  %3571 = fcmp olt float %3570, 0.000000e+00
  %3572 = sext i1 %3571 to i32
  %3573 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3574 = bitcast i8* %3573 to float*
  %3575 = load float, float* %3574, align 4
  %3576 = fcmp ogt float %3575, 0.000000e+00
  %3577 = zext i1 %3576 to i32
  %3578 = add nsw i32 %3572, %3577
  %3579 = sitofp i32 %3578 to float
  %3580 = insertelement <4 x float> %3567, float %3579, i32 1
  %3581 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3582 = bitcast i8* %3581 to float*
  %3583 = load float, float* %3582, align 4
  %3584 = fcmp olt float %3583, 0.000000e+00
  %3585 = sext i1 %3584 to i32
  %3586 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3587 = bitcast i8* %3586 to float*
  %3588 = load float, float* %3587, align 4
  %3589 = fcmp ogt float %3588, 0.000000e+00
  %3590 = zext i1 %3589 to i32
  %3591 = add nsw i32 %3585, %3590
  %3592 = sitofp i32 %3591 to float
  %3593 = insertelement <4 x float> %3580, float %3592, i32 2
  %3594 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3595 = bitcast i8* %3594 to float*
  %3596 = load float, float* %3595, align 4
  %3597 = fcmp olt float %3596, 0.000000e+00
  %3598 = sext i1 %3597 to i32
  %3599 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3600 = bitcast i8* %3599 to float*
  %3601 = load float, float* %3600, align 4
  %3602 = fcmp ogt float %3601, 0.000000e+00
  %3603 = zext i1 %3602 to i32
  %3604 = add nsw i32 %3598, %3603
  %3605 = sitofp i32 %3604 to float
  %3606 = insertelement <4 x float> %3593, float %3605, i32 3
  %3607 = fneg <4 x float> %3606
  %3608 = fmul <4 x float> %3554, %3607
  %3609 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3610 = bitcast i8* %3609 to float*
  %3611 = load float, float* %3610, align 4
  %3612 = insertelement <4 x float> zeroinitializer, float %3611, i32 0
  %3613 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3614 = getelementptr inbounds i8, i8* %3613, i64 4
  %3615 = bitcast i8* %3614 to float*
  %3616 = load float, float* %3615, align 4
  %3617 = insertelement <4 x float> %3612, float %3616, i32 1
  %3618 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3619 = getelementptr inbounds i8, i8* %3618, i64 8
  %3620 = bitcast i8* %3619 to float*
  %3621 = load float, float* %3620, align 4
  %3622 = insertelement <4 x float> %3617, float %3621, i32 2
  %3623 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3624 = getelementptr inbounds i8, i8* %3623, i64 12
  %3625 = bitcast i8* %3624 to float*
  %3626 = load float, float* %3625, align 4
  %3627 = insertelement <4 x float> %3622, float %3626, i32 3
  %3628 = call <4 x float> @llvm.fma.f32.72(<4 x float> %3608, <4 x float> %3627, <4 x float> %3550)
  %3629 = shufflevector <4 x float> %3628, <4 x float> zeroinitializer, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %3630 = shufflevector <8 x float> %3531, <8 x float> %3629, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %3631 = shufflevector <16 x float> <float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 1.000000e+00>, <16 x float> %3630, <32 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31>
  %3632 = extractelement <32 x float> %3631, i32 0
  %3633 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3634 = bitcast i8* %3633 to float*
  store float %3632, float* %3634, align 4
  %3635 = extractelement <32 x float> %3631, i32 1
  %3636 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3637 = getelementptr inbounds i8, i8* %3636, i64 4
  %3638 = bitcast i8* %3637 to float*
  store float %3635, float* %3638, align 4
  %3639 = extractelement <32 x float> %3631, i32 2
  %3640 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3641 = getelementptr inbounds i8, i8* %3640, i64 8
  %3642 = bitcast i8* %3641 to float*
  store float %3639, float* %3642, align 4
  %3643 = extractelement <32 x float> %3631, i32 3
  %3644 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3645 = getelementptr inbounds i8, i8* %3644, i64 12
  %3646 = bitcast i8* %3645 to float*
  store float %3643, float* %3646, align 4
  %3647 = extractelement <32 x float> %3631, i32 4
  %3648 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3649 = getelementptr inbounds i8, i8* %3648, i64 16
  %3650 = bitcast i8* %3649 to float*
  store float %3647, float* %3650, align 4
  %3651 = extractelement <32 x float> %3631, i32 5
  %3652 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3653 = getelementptr inbounds i8, i8* %3652, i64 20
  %3654 = bitcast i8* %3653 to float*
  store float %3651, float* %3654, align 4
  %3655 = extractelement <32 x float> %3631, i32 6
  %3656 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3657 = getelementptr inbounds i8, i8* %3656, i64 24
  %3658 = bitcast i8* %3657 to float*
  store float %3655, float* %3658, align 4
  %3659 = extractelement <32 x float> %3631, i32 7
  %3660 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3661 = getelementptr inbounds i8, i8* %3660, i64 28
  %3662 = bitcast i8* %3661 to float*
  store float %3659, float* %3662, align 4
  %3663 = extractelement <32 x float> %3631, i32 8
  %3664 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3665 = getelementptr inbounds i8, i8* %3664, i64 32
  %3666 = bitcast i8* %3665 to float*
  store float %3663, float* %3666, align 4
  %3667 = extractelement <32 x float> %3631, i32 9
  %3668 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3669 = getelementptr inbounds i8, i8* %3668, i64 36
  %3670 = bitcast i8* %3669 to float*
  store float %3667, float* %3670, align 4
  %3671 = extractelement <32 x float> %3631, i32 10
  %3672 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3673 = getelementptr inbounds i8, i8* %3672, i64 40
  %3674 = bitcast i8* %3673 to float*
  store float %3671, float* %3674, align 4
  %3675 = extractelement <32 x float> %3631, i32 11
  %3676 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3677 = getelementptr inbounds i8, i8* %3676, i64 44
  %3678 = bitcast i8* %3677 to float*
  store float %3675, float* %3678, align 4
  %3679 = extractelement <32 x float> %3631, i32 12
  %3680 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3681 = getelementptr inbounds i8, i8* %3680, i64 48
  %3682 = bitcast i8* %3681 to float*
  store float %3679, float* %3682, align 4
  %3683 = extractelement <32 x float> %3631, i32 13
  %3684 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3685 = getelementptr inbounds i8, i8* %3684, i64 52
  %3686 = bitcast i8* %3685 to float*
  store float %3683, float* %3686, align 4
  %3687 = extractelement <32 x float> %3631, i32 14
  %3688 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3689 = getelementptr inbounds i8, i8* %3688, i64 56
  %3690 = bitcast i8* %3689 to float*
  store float %3687, float* %3690, align 4
  %3691 = extractelement <32 x float> %3631, i32 15
  %3692 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3693 = getelementptr inbounds i8, i8* %3692, i64 60
  %3694 = bitcast i8* %3693 to float*
  store float %3691, float* %3694, align 4
  %3695 = extractelement <32 x float> %3631, i32 16
  %3696 = fptosi float %3695 to i32
  %3697 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3698 = bitcast i8* %3697 to i32*
  store i32 %3696, i32* %3698, align 4
  %3699 = extractelement <32 x float> %3631, i32 17
  %3700 = fptosi float %3699 to i32
  %3701 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3702 = bitcast i8* %3701 to i32*
  store i32 %3700, i32* %3702, align 4
  %3703 = extractelement <32 x float> %3631, i32 18
  %3704 = fptosi float %3703 to i32
  %3705 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3706 = getelementptr inbounds i8, i8* %3705, i64 4
  %3707 = bitcast i8* %3706 to i32*
  store i32 %3704, i32* %3707, align 4
  %3708 = extractelement <32 x float> %3631, i32 19
  %3709 = fptosi float %3708 to i32
  %3710 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3711 = getelementptr inbounds i8, i8* %3710, i64 4
  %3712 = bitcast i8* %3711 to i32*
  store i32 %3709, i32* %3712, align 4
  %3713 = extractelement <32 x float> %3631, i32 20
  %3714 = fptosi float %3713 to i32
  %3715 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3716 = getelementptr inbounds i8, i8* %3715, i64 8
  %3717 = bitcast i8* %3716 to i32*
  store i32 %3714, i32* %3717, align 4
  %3718 = extractelement <32 x float> %3631, i32 21
  %3719 = fptosi float %3718 to i32
  %3720 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3721 = getelementptr inbounds i8, i8* %3720, i64 8
  %3722 = bitcast i8* %3721 to i32*
  store i32 %3719, i32* %3722, align 4
  %3723 = extractelement <32 x float> %3631, i32 22
  %3724 = fptosi float %3723 to i32
  %3725 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3726 = getelementptr inbounds i8, i8* %3725, i64 12
  %3727 = bitcast i8* %3726 to i32*
  store i32 %3724, i32* %3727, align 4
  %3728 = extractelement <32 x float> %3631, i32 23
  %3729 = fptosi float %3728 to i32
  %3730 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3731 = getelementptr inbounds i8, i8* %3730, i64 12
  %3732 = bitcast i8* %3731 to i32*
  store i32 %3729, i32* %3732, align 4
  %3733 = extractelement <32 x float> %3631, i32 24
  %3734 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3735 = bitcast i8* %3734 to float*
  store float %3733, float* %3735, align 4
  %3736 = extractelement <32 x float> %3631, i32 25
  %3737 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3738 = getelementptr inbounds i8, i8* %3737, i64 4
  %3739 = bitcast i8* %3738 to float*
  store float %3736, float* %3739, align 4
  %3740 = extractelement <32 x float> %3631, i32 26
  %3741 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3742 = getelementptr inbounds i8, i8* %3741, i64 8
  %3743 = bitcast i8* %3742 to float*
  store float %3740, float* %3743, align 4
  %3744 = extractelement <32 x float> %3631, i32 27
  %3745 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3746 = getelementptr inbounds i8, i8* %3745, i64 12
  %3747 = bitcast i8* %3746 to float*
  store float %3744, float* %3747, align 4
  %3748 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3749 = bitcast i8* %3748 to float*
  %3750 = load float, float* %3749, align 4
  %3751 = insertelement <4 x float> zeroinitializer, float %3750, i32 0
  %3752 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3753 = getelementptr inbounds i8, i8* %3752, i64 4
  %3754 = bitcast i8* %3753 to float*
  %3755 = load float, float* %3754, align 4
  %3756 = insertelement <4 x float> %3751, float %3755, i32 1
  %3757 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3758 = getelementptr inbounds i8, i8* %3757, i64 8
  %3759 = bitcast i8* %3758 to float*
  %3760 = load float, float* %3759, align 4
  %3761 = insertelement <4 x float> %3756, float %3760, i32 2
  %3762 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3763 = getelementptr inbounds i8, i8* %3762, i64 12
  %3764 = bitcast i8* %3763 to float*
  %3765 = load float, float* %3764, align 4
  %3766 = insertelement <4 x float> %3761, float %3765, i32 3
  %3767 = insertelement <4 x float> zeroinitializer, float %186, i32 0
  %3768 = insertelement <4 x float> %3767, float %186, i32 1
  %3769 = insertelement <4 x float> %3768, float %186, i32 2
  %3770 = insertelement <4 x float> %3769, float %186, i32 3
  %3771 = fdiv <4 x float> %3766, %3770
  %3772 = extractelement <4 x float> %3771, i32 0
  %3773 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3774 = bitcast i8* %3773 to float*
  store float %3772, float* %3774, align 4
  %3775 = extractelement <4 x float> %3771, i32 1
  %3776 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3777 = getelementptr inbounds i8, i8* %3776, i64 4
  %3778 = bitcast i8* %3777 to float*
  store float %3775, float* %3778, align 4
  %3779 = extractelement <4 x float> %3771, i32 2
  %3780 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3781 = getelementptr inbounds i8, i8* %3780, i64 8
  %3782 = bitcast i8* %3781 to float*
  store float %3779, float* %3782, align 4
  %3783 = extractelement <4 x float> %3771, i32 3
  %3784 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3785 = getelementptr inbounds i8, i8* %3784, i64 12
  %3786 = bitcast i8* %3785 to float*
  store float %3783, float* %3786, align 4
  %3787 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3788 = bitcast i8* %3787 to float*
  %3789 = load float, float* %3788, align 4
  %3790 = insertelement <4 x float> zeroinitializer, float %3789, i32 0
  %3791 = insertelement <4 x float> %3790, float 1.000000e+00, i32 1
  %3792 = insertelement <4 x float> %3791, float 1.000000e+00, i32 2
  %3793 = insertelement <4 x float> %3792, float 1.000000e+00, i32 3
  %3794 = fmul <4 x float> %3793, <float 2.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00>
  %3795 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3796 = bitcast i8* %3795 to float*
  %3797 = load float, float* %3796, align 4
  %3798 = insertelement <4 x float> zeroinitializer, float %3797, i32 0
  %3799 = insertelement <4 x float> %3798, float 0.000000e+00, i32 1
  %3800 = insertelement <4 x float> %3799, float 0.000000e+00, i32 2
  %3801 = insertelement <4 x float> %3800, float 0.000000e+00, i32 3
  %3802 = fmul <4 x float> %3794, %3801
  %3803 = fsub <4 x float> <float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, %3802
  %3804 = extractelement <4 x float> %3803, i32 0
  %3805 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3806 = bitcast i8* %3805 to float*
  store float %3804, float* %3806, align 4
  %3807 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3808 = bitcast i8* %3807 to float*
  %3809 = load float, float* %3808, align 4
  %3810 = insertelement <4 x float> zeroinitializer, float %3809, i32 0
  %3811 = insertelement <4 x float> %3810, float 1.000000e+00, i32 1
  %3812 = insertelement <4 x float> %3811, float 1.000000e+00, i32 2
  %3813 = insertelement <4 x float> %3812, float 1.000000e+00, i32 3
  %3814 = fmul <4 x float> %3813, <float 2.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00>
  %3815 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3816 = getelementptr inbounds i8, i8* %3815, i64 4
  %3817 = bitcast i8* %3816 to float*
  %3818 = load float, float* %3817, align 4
  %3819 = insertelement <4 x float> zeroinitializer, float %3818, i32 0
  %3820 = insertelement <4 x float> %3819, float 0.000000e+00, i32 1
  %3821 = insertelement <4 x float> %3820, float 0.000000e+00, i32 2
  %3822 = insertelement <4 x float> %3821, float 0.000000e+00, i32 3
  %3823 = fmul <4 x float> %3814, %3822
  %3824 = fsub <4 x float> zeroinitializer, %3823
  %3825 = extractelement <4 x float> %3824, i32 0
  %3826 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3827 = getelementptr inbounds i8, i8* %3826, i64 4
  %3828 = bitcast i8* %3827 to float*
  store float %3825, float* %3828, align 4
  %3829 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3830 = bitcast i8* %3829 to float*
  %3831 = load float, float* %3830, align 4
  %3832 = insertelement <4 x float> zeroinitializer, float %3831, i32 0
  %3833 = insertelement <4 x float> %3832, float 1.000000e+00, i32 1
  %3834 = insertelement <4 x float> %3833, float 1.000000e+00, i32 2
  %3835 = insertelement <4 x float> %3834, float 1.000000e+00, i32 3
  %3836 = fmul <4 x float> %3835, <float 2.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00>
  %3837 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3838 = getelementptr inbounds i8, i8* %3837, i64 8
  %3839 = bitcast i8* %3838 to float*
  %3840 = load float, float* %3839, align 4
  %3841 = insertelement <4 x float> zeroinitializer, float %3840, i32 0
  %3842 = insertelement <4 x float> %3841, float 0.000000e+00, i32 1
  %3843 = insertelement <4 x float> %3842, float 0.000000e+00, i32 2
  %3844 = insertelement <4 x float> %3843, float 0.000000e+00, i32 3
  %3845 = fmul <4 x float> %3836, %3844
  %3846 = fsub <4 x float> zeroinitializer, %3845
  %3847 = extractelement <4 x float> %3846, i32 0
  %3848 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3849 = getelementptr inbounds i8, i8* %3848, i64 8
  %3850 = bitcast i8* %3849 to float*
  store float %3847, float* %3850, align 4
  %3851 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3852 = bitcast i8* %3851 to float*
  %3853 = load float, float* %3852, align 4
  %3854 = insertelement <4 x float> zeroinitializer, float %3853, i32 0
  %3855 = insertelement <4 x float> %3854, float 1.000000e+00, i32 1
  %3856 = insertelement <4 x float> %3855, float 1.000000e+00, i32 2
  %3857 = insertelement <4 x float> %3856, float 1.000000e+00, i32 3
  %3858 = fmul <4 x float> %3857, <float 2.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00>
  %3859 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3860 = getelementptr inbounds i8, i8* %3859, i64 12
  %3861 = bitcast i8* %3860 to float*
  %3862 = load float, float* %3861, align 4
  %3863 = insertelement <4 x float> zeroinitializer, float %3862, i32 0
  %3864 = insertelement <4 x float> %3863, float 0.000000e+00, i32 1
  %3865 = insertelement <4 x float> %3864, float 0.000000e+00, i32 2
  %3866 = insertelement <4 x float> %3865, float 0.000000e+00, i32 3
  %3867 = fmul <4 x float> %3858, %3866
  %3868 = fsub <4 x float> zeroinitializer, %3867
  %3869 = extractelement <4 x float> %3868, i32 0
  %3870 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3871 = getelementptr inbounds i8, i8* %3870, i64 12
  %3872 = bitcast i8* %3871 to float*
  store float %3869, float* %3872, align 4
  %3873 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3874 = getelementptr inbounds i8, i8* %3873, i64 4
  %3875 = bitcast i8* %3874 to float*
  %3876 = load float, float* %3875, align 4
  %3877 = insertelement <4 x float> zeroinitializer, float %3876, i32 0
  %3878 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3879 = getelementptr inbounds i8, i8* %3878, i64 4
  %3880 = bitcast i8* %3879 to float*
  %3881 = load float, float* %3880, align 4
  %3882 = insertelement <4 x float> %3877, float %3881, i32 1
  %3883 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3884 = getelementptr inbounds i8, i8* %3883, i64 4
  %3885 = bitcast i8* %3884 to float*
  %3886 = load float, float* %3885, align 4
  %3887 = insertelement <4 x float> %3882, float %3886, i32 2
  %3888 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3889 = getelementptr inbounds i8, i8* %3888, i64 4
  %3890 = bitcast i8* %3889 to float*
  %3891 = load float, float* %3890, align 4
  %3892 = insertelement <4 x float> %3887, float %3891, i32 3
  %3893 = fmul <4 x float> %3892, <float 2.000000e+00, float 2.000000e+00, float 2.000000e+00, float 2.000000e+00>
  %3894 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3895 = bitcast i8* %3894 to float*
  %3896 = load float, float* %3895, align 4
  %3897 = insertelement <4 x float> zeroinitializer, float %3896, i32 0
  %3898 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3899 = getelementptr inbounds i8, i8* %3898, i64 4
  %3900 = bitcast i8* %3899 to float*
  %3901 = load float, float* %3900, align 4
  %3902 = insertelement <4 x float> %3897, float %3901, i32 1
  %3903 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3904 = getelementptr inbounds i8, i8* %3903, i64 8
  %3905 = bitcast i8* %3904 to float*
  %3906 = load float, float* %3905, align 4
  %3907 = insertelement <4 x float> %3902, float %3906, i32 2
  %3908 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3909 = getelementptr inbounds i8, i8* %3908, i64 12
  %3910 = bitcast i8* %3909 to float*
  %3911 = load float, float* %3910, align 4
  %3912 = insertelement <4 x float> %3907, float %3911, i32 3
  %3913 = fmul <4 x float> %3893, %3912
  %3914 = fsub <4 x float> <float 0.000000e+00, float 1.000000e+00, float 0.000000e+00, float 0.000000e+00>, %3913
  %3915 = extractelement <4 x float> %3914, i32 0
  %3916 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3917 = getelementptr inbounds i8, i8* %3916, i64 16
  %3918 = bitcast i8* %3917 to float*
  store float %3915, float* %3918, align 4
  %3919 = extractelement <4 x float> %3914, i32 1
  %3920 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3921 = getelementptr inbounds i8, i8* %3920, i64 20
  %3922 = bitcast i8* %3921 to float*
  store float %3919, float* %3922, align 4
  %3923 = extractelement <4 x float> %3914, i32 2
  %3924 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3925 = getelementptr inbounds i8, i8* %3924, i64 24
  %3926 = bitcast i8* %3925 to float*
  store float %3923, float* %3926, align 4
  %3927 = extractelement <4 x float> %3914, i32 3
  %3928 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3929 = getelementptr inbounds i8, i8* %3928, i64 28
  %3930 = bitcast i8* %3929 to float*
  store float %3927, float* %3930, align 4
  %3931 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3932 = getelementptr inbounds i8, i8* %3931, i64 8
  %3933 = bitcast i8* %3932 to float*
  %3934 = load float, float* %3933, align 4
  %3935 = insertelement <4 x float> zeroinitializer, float %3934, i32 0
  %3936 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3937 = getelementptr inbounds i8, i8* %3936, i64 8
  %3938 = bitcast i8* %3937 to float*
  %3939 = load float, float* %3938, align 4
  %3940 = insertelement <4 x float> %3935, float %3939, i32 1
  %3941 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3942 = getelementptr inbounds i8, i8* %3941, i64 8
  %3943 = bitcast i8* %3942 to float*
  %3944 = load float, float* %3943, align 4
  %3945 = insertelement <4 x float> %3940, float %3944, i32 2
  %3946 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3947 = getelementptr inbounds i8, i8* %3946, i64 8
  %3948 = bitcast i8* %3947 to float*
  %3949 = load float, float* %3948, align 4
  %3950 = insertelement <4 x float> %3945, float %3949, i32 3
  %3951 = fmul <4 x float> %3950, <float 2.000000e+00, float 2.000000e+00, float 2.000000e+00, float 2.000000e+00>
  %3952 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3953 = bitcast i8* %3952 to float*
  %3954 = load float, float* %3953, align 4
  %3955 = insertelement <4 x float> zeroinitializer, float %3954, i32 0
  %3956 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3957 = getelementptr inbounds i8, i8* %3956, i64 4
  %3958 = bitcast i8* %3957 to float*
  %3959 = load float, float* %3958, align 4
  %3960 = insertelement <4 x float> %3955, float %3959, i32 1
  %3961 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3962 = getelementptr inbounds i8, i8* %3961, i64 8
  %3963 = bitcast i8* %3962 to float*
  %3964 = load float, float* %3963, align 4
  %3965 = insertelement <4 x float> %3960, float %3964, i32 2
  %3966 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3967 = getelementptr inbounds i8, i8* %3966, i64 12
  %3968 = bitcast i8* %3967 to float*
  %3969 = load float, float* %3968, align 4
  %3970 = insertelement <4 x float> %3965, float %3969, i32 3
  %3971 = fmul <4 x float> %3951, %3970
  %3972 = fsub <4 x float> <float 0.000000e+00, float 0.000000e+00, float 1.000000e+00, float 0.000000e+00>, %3971
  %3973 = extractelement <4 x float> %3972, i32 0
  %3974 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3975 = getelementptr inbounds i8, i8* %3974, i64 32
  %3976 = bitcast i8* %3975 to float*
  store float %3973, float* %3976, align 4
  %3977 = extractelement <4 x float> %3972, i32 1
  %3978 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3979 = getelementptr inbounds i8, i8* %3978, i64 36
  %3980 = bitcast i8* %3979 to float*
  store float %3977, float* %3980, align 4
  %3981 = extractelement <4 x float> %3972, i32 2
  %3982 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3983 = getelementptr inbounds i8, i8* %3982, i64 40
  %3984 = bitcast i8* %3983 to float*
  store float %3981, float* %3984, align 4
  %3985 = extractelement <4 x float> %3972, i32 3
  %3986 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %3987 = getelementptr inbounds i8, i8* %3986, i64 44
  %3988 = bitcast i8* %3987 to float*
  store float %3985, float* %3988, align 4
  %3989 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3990 = getelementptr inbounds i8, i8* %3989, i64 12
  %3991 = bitcast i8* %3990 to float*
  %3992 = load float, float* %3991, align 4
  %3993 = insertelement <4 x float> zeroinitializer, float %3992, i32 0
  %3994 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %3995 = getelementptr inbounds i8, i8* %3994, i64 12
  %3996 = bitcast i8* %3995 to float*
  %3997 = load float, float* %3996, align 4
  %3998 = insertelement <4 x float> %3993, float %3997, i32 1
  %3999 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %4000 = getelementptr inbounds i8, i8* %3999, i64 12
  %4001 = bitcast i8* %4000 to float*
  %4002 = load float, float* %4001, align 4
  %4003 = insertelement <4 x float> %3998, float %4002, i32 2
  %4004 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %4005 = getelementptr inbounds i8, i8* %4004, i64 12
  %4006 = bitcast i8* %4005 to float*
  %4007 = load float, float* %4006, align 4
  %4008 = insertelement <4 x float> %4003, float %4007, i32 3
  %4009 = fmul <4 x float> %4008, <float 2.000000e+00, float 2.000000e+00, float 2.000000e+00, float 2.000000e+00>
  %4010 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %4011 = bitcast i8* %4010 to float*
  %4012 = load float, float* %4011, align 4
  %4013 = insertelement <4 x float> zeroinitializer, float %4012, i32 0
  %4014 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %4015 = getelementptr inbounds i8, i8* %4014, i64 4
  %4016 = bitcast i8* %4015 to float*
  %4017 = load float, float* %4016, align 4
  %4018 = insertelement <4 x float> %4013, float %4017, i32 1
  %4019 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %4020 = getelementptr inbounds i8, i8* %4019, i64 8
  %4021 = bitcast i8* %4020 to float*
  %4022 = load float, float* %4021, align 4
  %4023 = insertelement <4 x float> %4018, float %4022, i32 2
  %4024 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %4025 = getelementptr inbounds i8, i8* %4024, i64 12
  %4026 = bitcast i8* %4025 to float*
  %4027 = load float, float* %4026, align 4
  %4028 = insertelement <4 x float> %4023, float %4027, i32 3
  %4029 = fmul <4 x float> %4009, %4028
  %4030 = fsub <4 x float> <float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 1.000000e+00>, %4029
  %4031 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4032 = bitcast i8* %4031 to i32*
  %4033 = load i32, i32* %4032, align 4
  %4034 = sitofp i32 %4033 to float
  %4035 = insertelement <4 x float> zeroinitializer, float %4034, i32 0
  %4036 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4037 = getelementptr inbounds i8, i8* %4036, i64 4
  %4038 = bitcast i8* %4037 to i32*
  %4039 = load i32, i32* %4038, align 4
  %4040 = sitofp i32 %4039 to float
  %4041 = insertelement <4 x float> %4035, float %4040, i32 1
  %4042 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4043 = getelementptr inbounds i8, i8* %4042, i64 8
  %4044 = bitcast i8* %4043 to i32*
  %4045 = load i32, i32* %4044, align 4
  %4046 = sitofp i32 %4045 to float
  %4047 = insertelement <4 x float> %4041, float %4046, i32 2
  %4048 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4049 = getelementptr inbounds i8, i8* %4048, i64 12
  %4050 = bitcast i8* %4049 to i32*
  %4051 = load i32, i32* %4050, align 4
  %4052 = sitofp i32 %4051 to float
  %4053 = insertelement <4 x float> %4047, float %4052, i32 3
  %4054 = shufflevector <4 x float> %4030, <4 x float> %4053, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %4055 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4056 = getelementptr inbounds i8, i8* %4055, i64 16
  %4057 = bitcast i8* %4056 to i32*
  %4058 = load i32, i32* %4057, align 4
  %4059 = sitofp i32 %4058 to float
  %4060 = insertelement <4 x float> zeroinitializer, float %4059, i32 0
  %4061 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4062 = getelementptr inbounds i8, i8* %4061, i64 20
  %4063 = bitcast i8* %4062 to i32*
  %4064 = load i32, i32* %4063, align 4
  %4065 = sitofp i32 %4064 to float
  %4066 = insertelement <4 x float> %4060, float %4065, i32 1
  %4067 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4068 = getelementptr inbounds i8, i8* %4067, i64 24
  %4069 = bitcast i8* %4068 to i32*
  %4070 = load i32, i32* %4069, align 4
  %4071 = sitofp i32 %4070 to float
  %4072 = insertelement <4 x float> %4066, float %4071, i32 2
  %4073 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4074 = getelementptr inbounds i8, i8* %4073, i64 28
  %4075 = bitcast i8* %4074 to i32*
  %4076 = load i32, i32* %4075, align 4
  %4077 = sitofp i32 %4076 to float
  %4078 = insertelement <4 x float> %4072, float %4077, i32 3
  %4079 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4080 = getelementptr inbounds i8, i8* %4079, i64 32
  %4081 = bitcast i8* %4080 to i32*
  %4082 = load i32, i32* %4081, align 4
  %4083 = sitofp i32 %4082 to float
  %4084 = insertelement <4 x float> zeroinitializer, float %4083, i32 0
  %4085 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4086 = getelementptr inbounds i8, i8* %4085, i64 36
  %4087 = bitcast i8* %4086 to i32*
  %4088 = load i32, i32* %4087, align 4
  %4089 = sitofp i32 %4088 to float
  %4090 = insertelement <4 x float> %4084, float %4089, i32 1
  %4091 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4092 = getelementptr inbounds i8, i8* %4091, i64 40
  %4093 = bitcast i8* %4092 to i32*
  %4094 = load i32, i32* %4093, align 4
  %4095 = sitofp i32 %4094 to float
  %4096 = insertelement <4 x float> %4090, float %4095, i32 2
  %4097 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4098 = getelementptr inbounds i8, i8* %4097, i64 44
  %4099 = bitcast i8* %4098 to i32*
  %4100 = load i32, i32* %4099, align 4
  %4101 = sitofp i32 %4100 to float
  %4102 = insertelement <4 x float> %4096, float %4101, i32 3
  %4103 = shufflevector <4 x float> %4078, <4 x float> %4102, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %4104 = shufflevector <8 x float> %4054, <8 x float> %4103, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %4105 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4106 = getelementptr inbounds i8, i8* %4105, i64 48
  %4107 = bitcast i8* %4106 to i32*
  %4108 = load i32, i32* %4107, align 4
  %4109 = sitofp i32 %4108 to float
  %4110 = insertelement <4 x float> zeroinitializer, float %4109, i32 0
  %4111 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4112 = getelementptr inbounds i8, i8* %4111, i64 52
  %4113 = bitcast i8* %4112 to i32*
  %4114 = load i32, i32* %4113, align 4
  %4115 = sitofp i32 %4114 to float
  %4116 = insertelement <4 x float> %4110, float %4115, i32 1
  %4117 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4118 = getelementptr inbounds i8, i8* %4117, i64 56
  %4119 = bitcast i8* %4118 to i32*
  %4120 = load i32, i32* %4119, align 4
  %4121 = sitofp i32 %4120 to float
  %4122 = insertelement <4 x float> %4116, float %4121, i32 2
  %4123 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4124 = getelementptr inbounds i8, i8* %4123, i64 60
  %4125 = bitcast i8* %4124 to i32*
  %4126 = load i32, i32* %4125, align 4
  %4127 = sitofp i32 %4126 to float
  %4128 = insertelement <4 x float> %4122, float %4127, i32 3
  %4129 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4130 = bitcast i8* %4129 to float*
  %4131 = load float, float* %4130, align 4
  %4132 = insertelement <4 x float> zeroinitializer, float %4131, i32 1
  %4133 = insertelement <4 x float> %4132, float 0.000000e+00, i32 2
  %4134 = insertelement <4 x float> %4133, float 0.000000e+00, i32 3
  %4135 = load float, float* %0, align 4
  %4136 = insertelement <4 x float> zeroinitializer, float %4135, i32 1
  %4137 = insertelement <4 x float> %4136, float 0.000000e+00, i32 2
  %4138 = insertelement <4 x float> %4137, float 0.000000e+00, i32 3
  %4139 = call <4 x float> @llvm.fma.f32.73(<4 x float> %4134, <4 x float> %4138, <4 x float> zeroinitializer)
  %4140 = shufflevector <4 x float> %4128, <4 x float> %4139, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %4141 = shufflevector <8 x float> %4140, <8 x float> zeroinitializer, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %4142 = shufflevector <16 x float> %4104, <16 x float> %4141, <32 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31>
  %4143 = extractelement <32 x float> %4142, i32 0
  %4144 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4145 = getelementptr inbounds i8, i8* %4144, i64 48
  %4146 = bitcast i8* %4145 to float*
  store float %4143, float* %4146, align 4
  %4147 = extractelement <32 x float> %4142, i32 1
  %4148 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4149 = getelementptr inbounds i8, i8* %4148, i64 52
  %4150 = bitcast i8* %4149 to float*
  store float %4147, float* %4150, align 4
  %4151 = extractelement <32 x float> %4142, i32 2
  %4152 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4153 = getelementptr inbounds i8, i8* %4152, i64 56
  %4154 = bitcast i8* %4153 to float*
  store float %4151, float* %4154, align 4
  %4155 = extractelement <32 x float> %4142, i32 3
  %4156 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4157 = getelementptr inbounds i8, i8* %4156, i64 60
  %4158 = bitcast i8* %4157 to float*
  store float %4155, float* %4158, align 4
  %4159 = extractelement <32 x float> %4142, i32 4
  %4160 = fptosi float %4159 to i32
  %4161 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4162 = bitcast i8* %4161 to i32*
  store i32 %4160, i32* %4162, align 4
  %4163 = extractelement <32 x float> %4142, i32 5
  %4164 = fptosi float %4163 to i32
  %4165 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4166 = getelementptr inbounds i8, i8* %4165, i64 4
  %4167 = bitcast i8* %4166 to i32*
  store i32 %4164, i32* %4167, align 4
  %4168 = extractelement <32 x float> %4142, i32 6
  %4169 = fptosi float %4168 to i32
  %4170 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4171 = getelementptr inbounds i8, i8* %4170, i64 8
  %4172 = bitcast i8* %4171 to i32*
  store i32 %4169, i32* %4172, align 4
  %4173 = extractelement <32 x float> %4142, i32 7
  %4174 = fptosi float %4173 to i32
  %4175 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4176 = getelementptr inbounds i8, i8* %4175, i64 12
  %4177 = bitcast i8* %4176 to i32*
  store i32 %4174, i32* %4177, align 4
  %4178 = extractelement <32 x float> %4142, i32 8
  %4179 = fptosi float %4178 to i32
  %4180 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4181 = getelementptr inbounds i8, i8* %4180, i64 16
  %4182 = bitcast i8* %4181 to i32*
  store i32 %4179, i32* %4182, align 4
  %4183 = extractelement <32 x float> %4142, i32 9
  %4184 = fptosi float %4183 to i32
  %4185 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4186 = getelementptr inbounds i8, i8* %4185, i64 20
  %4187 = bitcast i8* %4186 to i32*
  store i32 %4184, i32* %4187, align 4
  %4188 = extractelement <32 x float> %4142, i32 10
  %4189 = fptosi float %4188 to i32
  %4190 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4191 = getelementptr inbounds i8, i8* %4190, i64 24
  %4192 = bitcast i8* %4191 to i32*
  store i32 %4189, i32* %4192, align 4
  %4193 = extractelement <32 x float> %4142, i32 11
  %4194 = fptosi float %4193 to i32
  %4195 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4196 = getelementptr inbounds i8, i8* %4195, i64 28
  %4197 = bitcast i8* %4196 to i32*
  store i32 %4194, i32* %4197, align 4
  %4198 = extractelement <32 x float> %4142, i32 12
  %4199 = fptosi float %4198 to i32
  %4200 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4201 = getelementptr inbounds i8, i8* %4200, i64 32
  %4202 = bitcast i8* %4201 to i32*
  store i32 %4199, i32* %4202, align 4
  %4203 = extractelement <32 x float> %4142, i32 13
  %4204 = fptosi float %4203 to i32
  %4205 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4206 = getelementptr inbounds i8, i8* %4205, i64 36
  %4207 = bitcast i8* %4206 to i32*
  store i32 %4204, i32* %4207, align 4
  %4208 = extractelement <32 x float> %4142, i32 14
  %4209 = fptosi float %4208 to i32
  %4210 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4211 = getelementptr inbounds i8, i8* %4210, i64 40
  %4212 = bitcast i8* %4211 to i32*
  store i32 %4209, i32* %4212, align 4
  %4213 = extractelement <32 x float> %4142, i32 15
  %4214 = fptosi float %4213 to i32
  %4215 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4216 = getelementptr inbounds i8, i8* %4215, i64 44
  %4217 = bitcast i8* %4216 to i32*
  store i32 %4214, i32* %4217, align 4
  %4218 = extractelement <32 x float> %4142, i32 16
  %4219 = fptosi float %4218 to i32
  %4220 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4221 = getelementptr inbounds i8, i8* %4220, i64 48
  %4222 = bitcast i8* %4221 to i32*
  store i32 %4219, i32* %4222, align 4
  %4223 = extractelement <32 x float> %4142, i32 17
  %4224 = fptosi float %4223 to i32
  %4225 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4226 = getelementptr inbounds i8, i8* %4225, i64 52
  %4227 = bitcast i8* %4226 to i32*
  store i32 %4224, i32* %4227, align 4
  %4228 = extractelement <32 x float> %4142, i32 18
  %4229 = fptosi float %4228 to i32
  %4230 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4231 = getelementptr inbounds i8, i8* %4230, i64 56
  %4232 = bitcast i8* %4231 to i32*
  store i32 %4229, i32* %4232, align 4
  %4233 = extractelement <32 x float> %4142, i32 19
  %4234 = fptosi float %4233 to i32
  %4235 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4236 = getelementptr inbounds i8, i8* %4235, i64 60
  %4237 = bitcast i8* %4236 to i32*
  store i32 %4234, i32* %4237, align 4
  %4238 = extractelement <32 x float> %4142, i32 20
  store float %4238, float* %2, align 4
  %4239 = extractelement <32 x float> %4142, i32 21
  store float %4239, float* %2, align 4
  %4240 = load float, float* %2, align 4
  %4241 = insertelement <4 x float> zeroinitializer, float %4240, i32 0
  %4242 = insertelement <4 x float> %4241, float 0.000000e+00, i32 1
  %4243 = insertelement <4 x float> %4242, float 0.000000e+00, i32 2
  %4244 = insertelement <4 x float> %4243, float 0.000000e+00, i32 3
  %4245 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4246 = getelementptr inbounds i8, i8* %4245, i64 4
  %4247 = bitcast i8* %4246 to float*
  %4248 = load float, float* %4247, align 4
  %4249 = insertelement <4 x float> zeroinitializer, float %4248, i32 0
  %4250 = insertelement <4 x float> %4249, float 0.000000e+00, i32 1
  %4251 = insertelement <4 x float> %4250, float 0.000000e+00, i32 2
  %4252 = insertelement <4 x float> %4251, float 0.000000e+00, i32 3
  %4253 = getelementptr inbounds float, float* %0, i64 4
  %4254 = load float, float* %4253, align 4
  %4255 = insertelement <4 x float> zeroinitializer, float %4254, i32 0
  %4256 = insertelement <4 x float> %4255, float 0.000000e+00, i32 1
  %4257 = insertelement <4 x float> %4256, float 0.000000e+00, i32 2
  %4258 = insertelement <4 x float> %4257, float 0.000000e+00, i32 3
  %4259 = call <4 x float> @llvm.fma.f32.74(<4 x float> %4252, <4 x float> %4258, <4 x float> %4244)
  %4260 = extractelement <4 x float> %4259, i32 0
  store float %4260, float* %2, align 4
  %4261 = load float, float* %2, align 4
  %4262 = insertelement <4 x float> zeroinitializer, float %4261, i32 0
  %4263 = insertelement <4 x float> %4262, float 0.000000e+00, i32 1
  %4264 = insertelement <4 x float> %4263, float 0.000000e+00, i32 2
  %4265 = insertelement <4 x float> %4264, float 0.000000e+00, i32 3
  %4266 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4267 = getelementptr inbounds i8, i8* %4266, i64 8
  %4268 = bitcast i8* %4267 to float*
  %4269 = load float, float* %4268, align 4
  %4270 = insertelement <4 x float> zeroinitializer, float %4269, i32 0
  %4271 = insertelement <4 x float> %4270, float 0.000000e+00, i32 1
  %4272 = insertelement <4 x float> %4271, float 0.000000e+00, i32 2
  %4273 = insertelement <4 x float> %4272, float 0.000000e+00, i32 3
  %4274 = getelementptr inbounds float, float* %0, i64 8
  %4275 = load float, float* %4274, align 4
  %4276 = insertelement <4 x float> zeroinitializer, float %4275, i32 0
  %4277 = insertelement <4 x float> %4276, float 0.000000e+00, i32 1
  %4278 = insertelement <4 x float> %4277, float 0.000000e+00, i32 2
  %4279 = insertelement <4 x float> %4278, float 0.000000e+00, i32 3
  %4280 = call <4 x float> @llvm.fma.f32.75(<4 x float> %4273, <4 x float> %4279, <4 x float> %4265)
  %4281 = extractelement <4 x float> %4280, i32 0
  store float %4281, float* %2, align 4
  %4282 = load float, float* %2, align 4
  %4283 = insertelement <4 x float> zeroinitializer, float %4282, i32 0
  %4284 = insertelement <4 x float> %4283, float 0.000000e+00, i32 1
  %4285 = insertelement <4 x float> %4284, float 0.000000e+00, i32 2
  %4286 = insertelement <4 x float> %4285, float 0.000000e+00, i32 3
  %4287 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4288 = getelementptr inbounds i8, i8* %4287, i64 12
  %4289 = bitcast i8* %4288 to float*
  %4290 = load float, float* %4289, align 4
  %4291 = insertelement <4 x float> zeroinitializer, float %4290, i32 0
  %4292 = insertelement <4 x float> %4291, float 0.000000e+00, i32 1
  %4293 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4294 = bitcast i8* %4293 to float*
  %4295 = load float, float* %4294, align 4
  %4296 = insertelement <4 x float> %4292, float %4295, i32 2
  %4297 = insertelement <4 x float> %4296, float 0.000000e+00, i32 3
  %4298 = getelementptr inbounds float, float* %0, i64 12
  %4299 = load float, float* %4298, align 4
  %4300 = insertelement <4 x float> zeroinitializer, float %4299, i32 0
  %4301 = insertelement <4 x float> %4300, float 0.000000e+00, i32 1
  %4302 = getelementptr inbounds float, float* %0, i64 1
  %4303 = load float, float* %4302, align 4
  %4304 = insertelement <4 x float> %4301, float %4303, i32 2
  %4305 = insertelement <4 x float> %4304, float 0.000000e+00, i32 3
  %4306 = call <4 x float> @llvm.fma.f32.76(<4 x float> %4297, <4 x float> %4305, <4 x float> %4286)
  %4307 = extractelement <4 x float> %4306, i32 0
  store float %4307, float* %2, align 4
  %4308 = extractelement <4 x float> %4306, i32 1
  %4309 = getelementptr inbounds float, float* %2, i64 1
  store float %4308, float* %4309, align 4
  %4310 = extractelement <4 x float> %4306, i32 2
  %4311 = getelementptr inbounds float, float* %2, i64 1
  store float %4310, float* %4311, align 4
  %4312 = getelementptr inbounds float, float* %2, i64 1
  %4313 = load float, float* %4312, align 4
  %4314 = insertelement <4 x float> zeroinitializer, float %4313, i32 0
  %4315 = insertelement <4 x float> %4314, float 0.000000e+00, i32 1
  %4316 = insertelement <4 x float> %4315, float 0.000000e+00, i32 2
  %4317 = insertelement <4 x float> %4316, float 0.000000e+00, i32 3
  %4318 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4319 = getelementptr inbounds i8, i8* %4318, i64 4
  %4320 = bitcast i8* %4319 to float*
  %4321 = load float, float* %4320, align 4
  %4322 = insertelement <4 x float> zeroinitializer, float %4321, i32 0
  %4323 = insertelement <4 x float> %4322, float 0.000000e+00, i32 1
  %4324 = insertelement <4 x float> %4323, float 0.000000e+00, i32 2
  %4325 = insertelement <4 x float> %4324, float 0.000000e+00, i32 3
  %4326 = getelementptr inbounds float, float* %0, i64 5
  %4327 = load float, float* %4326, align 4
  %4328 = insertelement <4 x float> zeroinitializer, float %4327, i32 0
  %4329 = insertelement <4 x float> %4328, float 0.000000e+00, i32 1
  %4330 = insertelement <4 x float> %4329, float 0.000000e+00, i32 2
  %4331 = insertelement <4 x float> %4330, float 0.000000e+00, i32 3
  %4332 = call <4 x float> @llvm.fma.f32.77(<4 x float> %4325, <4 x float> %4331, <4 x float> %4317)
  %4333 = extractelement <4 x float> %4332, i32 0
  %4334 = getelementptr inbounds float, float* %2, i64 1
  store float %4333, float* %4334, align 4
  %4335 = getelementptr inbounds float, float* %2, i64 1
  %4336 = load float, float* %4335, align 4
  %4337 = insertelement <4 x float> zeroinitializer, float %4336, i32 0
  %4338 = insertelement <4 x float> %4337, float 0.000000e+00, i32 1
  %4339 = insertelement <4 x float> %4338, float 0.000000e+00, i32 2
  %4340 = insertelement <4 x float> %4339, float 0.000000e+00, i32 3
  %4341 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4342 = getelementptr inbounds i8, i8* %4341, i64 8
  %4343 = bitcast i8* %4342 to float*
  %4344 = load float, float* %4343, align 4
  %4345 = insertelement <4 x float> zeroinitializer, float %4344, i32 0
  %4346 = insertelement <4 x float> %4345, float 0.000000e+00, i32 1
  %4347 = insertelement <4 x float> %4346, float 0.000000e+00, i32 2
  %4348 = insertelement <4 x float> %4347, float 0.000000e+00, i32 3
  %4349 = getelementptr inbounds float, float* %0, i64 9
  %4350 = load float, float* %4349, align 4
  %4351 = insertelement <4 x float> zeroinitializer, float %4350, i32 0
  %4352 = insertelement <4 x float> %4351, float 0.000000e+00, i32 1
  %4353 = insertelement <4 x float> %4352, float 0.000000e+00, i32 2
  %4354 = insertelement <4 x float> %4353, float 0.000000e+00, i32 3
  %4355 = call <4 x float> @llvm.fma.f32.78(<4 x float> %4348, <4 x float> %4354, <4 x float> %4340)
  %4356 = extractelement <4 x float> %4355, i32 0
  %4357 = getelementptr inbounds float, float* %2, i64 1
  store float %4356, float* %4357, align 4
  %4358 = getelementptr inbounds float, float* %2, i64 1
  %4359 = load float, float* %4358, align 4
  %4360 = insertelement <4 x float> zeroinitializer, float %4359, i32 0
  %4361 = insertelement <4 x float> %4360, float 0.000000e+00, i32 1
  %4362 = insertelement <4 x float> %4361, float 0.000000e+00, i32 2
  %4363 = insertelement <4 x float> %4362, float 0.000000e+00, i32 3
  %4364 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4365 = getelementptr inbounds i8, i8* %4364, i64 12
  %4366 = bitcast i8* %4365 to float*
  %4367 = load float, float* %4366, align 4
  %4368 = insertelement <4 x float> zeroinitializer, float %4367, i32 0
  %4369 = insertelement <4 x float> %4368, float 0.000000e+00, i32 1
  %4370 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4371 = bitcast i8* %4370 to float*
  %4372 = load float, float* %4371, align 4
  %4373 = insertelement <4 x float> %4369, float %4372, i32 2
  %4374 = insertelement <4 x float> %4373, float 0.000000e+00, i32 3
  %4375 = getelementptr inbounds float, float* %0, i64 13
  %4376 = load float, float* %4375, align 4
  %4377 = insertelement <4 x float> zeroinitializer, float %4376, i32 0
  %4378 = insertelement <4 x float> %4377, float 0.000000e+00, i32 1
  %4379 = getelementptr inbounds float, float* %0, i64 2
  %4380 = load float, float* %4379, align 4
  %4381 = insertelement <4 x float> %4378, float %4380, i32 2
  %4382 = insertelement <4 x float> %4381, float 0.000000e+00, i32 3
  %4383 = call <4 x float> @llvm.fma.f32.79(<4 x float> %4374, <4 x float> %4382, <4 x float> %4363)
  %4384 = extractelement <4 x float> %4383, i32 0
  %4385 = getelementptr inbounds float, float* %2, i64 1
  store float %4384, float* %4385, align 4
  %4386 = extractelement <4 x float> %4383, i32 1
  %4387 = getelementptr inbounds float, float* %2, i64 2
  store float %4386, float* %4387, align 4
  %4388 = extractelement <4 x float> %4383, i32 2
  %4389 = getelementptr inbounds float, float* %2, i64 2
  store float %4388, float* %4389, align 4
  %4390 = getelementptr inbounds float, float* %2, i64 2
  %4391 = load float, float* %4390, align 4
  %4392 = insertelement <4 x float> zeroinitializer, float %4391, i32 0
  %4393 = insertelement <4 x float> %4392, float 0.000000e+00, i32 1
  %4394 = insertelement <4 x float> %4393, float 0.000000e+00, i32 2
  %4395 = insertelement <4 x float> %4394, float 0.000000e+00, i32 3
  %4396 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4397 = getelementptr inbounds i8, i8* %4396, i64 4
  %4398 = bitcast i8* %4397 to float*
  %4399 = load float, float* %4398, align 4
  %4400 = insertelement <4 x float> zeroinitializer, float %4399, i32 0
  %4401 = insertelement <4 x float> %4400, float 0.000000e+00, i32 1
  %4402 = insertelement <4 x float> %4401, float 0.000000e+00, i32 2
  %4403 = insertelement <4 x float> %4402, float 0.000000e+00, i32 3
  %4404 = getelementptr inbounds float, float* %0, i64 6
  %4405 = load float, float* %4404, align 4
  %4406 = insertelement <4 x float> zeroinitializer, float %4405, i32 0
  %4407 = insertelement <4 x float> %4406, float 0.000000e+00, i32 1
  %4408 = insertelement <4 x float> %4407, float 0.000000e+00, i32 2
  %4409 = insertelement <4 x float> %4408, float 0.000000e+00, i32 3
  %4410 = call <4 x float> @llvm.fma.f32.80(<4 x float> %4403, <4 x float> %4409, <4 x float> %4395)
  %4411 = extractelement <4 x float> %4410, i32 0
  %4412 = getelementptr inbounds float, float* %2, i64 2
  store float %4411, float* %4412, align 4
  %4413 = getelementptr inbounds float, float* %2, i64 2
  %4414 = load float, float* %4413, align 4
  %4415 = insertelement <4 x float> zeroinitializer, float %4414, i32 0
  %4416 = insertelement <4 x float> %4415, float 0.000000e+00, i32 1
  %4417 = insertelement <4 x float> %4416, float 0.000000e+00, i32 2
  %4418 = insertelement <4 x float> %4417, float 0.000000e+00, i32 3
  %4419 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4420 = getelementptr inbounds i8, i8* %4419, i64 8
  %4421 = bitcast i8* %4420 to float*
  %4422 = load float, float* %4421, align 4
  %4423 = insertelement <4 x float> zeroinitializer, float %4422, i32 0
  %4424 = insertelement <4 x float> %4423, float 0.000000e+00, i32 1
  %4425 = insertelement <4 x float> %4424, float 0.000000e+00, i32 2
  %4426 = insertelement <4 x float> %4425, float 0.000000e+00, i32 3
  %4427 = getelementptr inbounds float, float* %0, i64 10
  %4428 = load float, float* %4427, align 4
  %4429 = insertelement <4 x float> zeroinitializer, float %4428, i32 0
  %4430 = insertelement <4 x float> %4429, float 0.000000e+00, i32 1
  %4431 = insertelement <4 x float> %4430, float 0.000000e+00, i32 2
  %4432 = insertelement <4 x float> %4431, float 0.000000e+00, i32 3
  %4433 = call <4 x float> @llvm.fma.f32.81(<4 x float> %4426, <4 x float> %4432, <4 x float> %4418)
  %4434 = extractelement <4 x float> %4433, i32 0
  %4435 = getelementptr inbounds float, float* %2, i64 2
  store float %4434, float* %4435, align 4
  %4436 = getelementptr inbounds float, float* %2, i64 2
  %4437 = load float, float* %4436, align 4
  %4438 = insertelement <4 x float> zeroinitializer, float %4437, i32 0
  %4439 = insertelement <4 x float> %4438, float 0.000000e+00, i32 1
  %4440 = insertelement <4 x float> %4439, float 0.000000e+00, i32 2
  %4441 = insertelement <4 x float> %4440, float 0.000000e+00, i32 3
  %4442 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4443 = getelementptr inbounds i8, i8* %4442, i64 12
  %4444 = bitcast i8* %4443 to float*
  %4445 = load float, float* %4444, align 4
  %4446 = insertelement <4 x float> zeroinitializer, float %4445, i32 0
  %4447 = insertelement <4 x float> %4446, float 0.000000e+00, i32 1
  %4448 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4449 = bitcast i8* %4448 to float*
  %4450 = load float, float* %4449, align 4
  %4451 = insertelement <4 x float> %4447, float %4450, i32 2
  %4452 = insertelement <4 x float> %4451, float 0.000000e+00, i32 3
  %4453 = getelementptr inbounds float, float* %0, i64 14
  %4454 = load float, float* %4453, align 4
  %4455 = insertelement <4 x float> zeroinitializer, float %4454, i32 0
  %4456 = insertelement <4 x float> %4455, float 0.000000e+00, i32 1
  %4457 = getelementptr inbounds float, float* %0, i64 3
  %4458 = load float, float* %4457, align 4
  %4459 = insertelement <4 x float> %4456, float %4458, i32 2
  %4460 = insertelement <4 x float> %4459, float 0.000000e+00, i32 3
  %4461 = call <4 x float> @llvm.fma.f32.82(<4 x float> %4452, <4 x float> %4460, <4 x float> %4441)
  %4462 = extractelement <4 x float> %4461, i32 0
  %4463 = getelementptr inbounds float, float* %2, i64 2
  store float %4462, float* %4463, align 4
  %4464 = extractelement <4 x float> %4461, i32 1
  %4465 = getelementptr inbounds float, float* %2, i64 3
  store float %4464, float* %4465, align 4
  %4466 = extractelement <4 x float> %4461, i32 2
  %4467 = getelementptr inbounds float, float* %2, i64 3
  store float %4466, float* %4467, align 4
  %4468 = getelementptr inbounds float, float* %2, i64 3
  %4469 = load float, float* %4468, align 4
  %4470 = insertelement <4 x float> zeroinitializer, float %4469, i32 0
  %4471 = insertelement <4 x float> %4470, float 0.000000e+00, i32 1
  %4472 = insertelement <4 x float> %4471, float 0.000000e+00, i32 2
  %4473 = insertelement <4 x float> %4472, float 0.000000e+00, i32 3
  %4474 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4475 = getelementptr inbounds i8, i8* %4474, i64 4
  %4476 = bitcast i8* %4475 to float*
  %4477 = load float, float* %4476, align 4
  %4478 = insertelement <4 x float> zeroinitializer, float %4477, i32 0
  %4479 = insertelement <4 x float> %4478, float 0.000000e+00, i32 1
  %4480 = insertelement <4 x float> %4479, float 0.000000e+00, i32 2
  %4481 = insertelement <4 x float> %4480, float 0.000000e+00, i32 3
  %4482 = getelementptr inbounds float, float* %0, i64 7
  %4483 = load float, float* %4482, align 4
  %4484 = insertelement <4 x float> zeroinitializer, float %4483, i32 0
  %4485 = insertelement <4 x float> %4484, float 0.000000e+00, i32 1
  %4486 = insertelement <4 x float> %4485, float 0.000000e+00, i32 2
  %4487 = insertelement <4 x float> %4486, float 0.000000e+00, i32 3
  %4488 = call <4 x float> @llvm.fma.f32.83(<4 x float> %4481, <4 x float> %4487, <4 x float> %4473)
  %4489 = extractelement <4 x float> %4488, i32 0
  %4490 = getelementptr inbounds float, float* %2, i64 3
  store float %4489, float* %4490, align 4
  %4491 = getelementptr inbounds float, float* %2, i64 3
  %4492 = load float, float* %4491, align 4
  %4493 = insertelement <4 x float> zeroinitializer, float %4492, i32 0
  %4494 = insertelement <4 x float> %4493, float 0.000000e+00, i32 1
  %4495 = insertelement <4 x float> %4494, float 0.000000e+00, i32 2
  %4496 = insertelement <4 x float> %4495, float 0.000000e+00, i32 3
  %4497 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4498 = getelementptr inbounds i8, i8* %4497, i64 8
  %4499 = bitcast i8* %4498 to float*
  %4500 = load float, float* %4499, align 4
  %4501 = insertelement <4 x float> zeroinitializer, float %4500, i32 0
  %4502 = insertelement <4 x float> %4501, float 0.000000e+00, i32 1
  %4503 = insertelement <4 x float> %4502, float 0.000000e+00, i32 2
  %4504 = insertelement <4 x float> %4503, float 0.000000e+00, i32 3
  %4505 = getelementptr inbounds float, float* %0, i64 11
  %4506 = load float, float* %4505, align 4
  %4507 = insertelement <4 x float> zeroinitializer, float %4506, i32 0
  %4508 = insertelement <4 x float> %4507, float 0.000000e+00, i32 1
  %4509 = insertelement <4 x float> %4508, float 0.000000e+00, i32 2
  %4510 = insertelement <4 x float> %4509, float 0.000000e+00, i32 3
  %4511 = call <4 x float> @llvm.fma.f32.84(<4 x float> %4504, <4 x float> %4510, <4 x float> %4496)
  %4512 = extractelement <4 x float> %4511, i32 0
  %4513 = getelementptr inbounds float, float* %2, i64 3
  store float %4512, float* %4513, align 4
  %4514 = getelementptr inbounds float, float* %2, i64 3
  %4515 = load float, float* %4514, align 4
  %4516 = insertelement <4 x float> zeroinitializer, float %4515, i32 0
  %4517 = insertelement <4 x float> %4516, float 0.000000e+00, i32 1
  %4518 = insertelement <4 x float> %4517, float 0.000000e+00, i32 2
  %4519 = insertelement <4 x float> %4518, float 0.000000e+00, i32 3
  %4520 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4521 = getelementptr inbounds i8, i8* %4520, i64 12
  %4522 = bitcast i8* %4521 to float*
  %4523 = load float, float* %4522, align 4
  %4524 = insertelement <4 x float> zeroinitializer, float %4523, i32 0
  %4525 = insertelement <4 x float> %4524, float 0.000000e+00, i32 1
  %4526 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4527 = getelementptr inbounds i8, i8* %4526, i64 16
  %4528 = bitcast i8* %4527 to float*
  %4529 = load float, float* %4528, align 4
  %4530 = insertelement <4 x float> %4525, float %4529, i32 2
  %4531 = insertelement <4 x float> %4530, float 0.000000e+00, i32 3
  %4532 = getelementptr inbounds float, float* %0, i64 15
  %4533 = load float, float* %4532, align 4
  %4534 = insertelement <4 x float> zeroinitializer, float %4533, i32 0
  %4535 = insertelement <4 x float> %4534, float 0.000000e+00, i32 1
  %4536 = load float, float* %0, align 4
  %4537 = insertelement <4 x float> %4535, float %4536, i32 2
  %4538 = insertelement <4 x float> %4537, float 0.000000e+00, i32 3
  %4539 = call <4 x float> @llvm.fma.f32.85(<4 x float> %4531, <4 x float> %4538, <4 x float> %4519)
  %4540 = extractelement <4 x float> %4539, i32 0
  %4541 = getelementptr inbounds float, float* %2, i64 3
  store float %4540, float* %4541, align 4
  %4542 = extractelement <4 x float> %4539, i32 1
  %4543 = getelementptr inbounds float, float* %2, i64 4
  store float %4542, float* %4543, align 4
  %4544 = extractelement <4 x float> %4539, i32 2
  %4545 = getelementptr inbounds float, float* %2, i64 4
  store float %4544, float* %4545, align 4
  %4546 = getelementptr inbounds float, float* %2, i64 4
  %4547 = load float, float* %4546, align 4
  %4548 = insertelement <4 x float> zeroinitializer, float %4547, i32 0
  %4549 = insertelement <4 x float> %4548, float 0.000000e+00, i32 1
  %4550 = insertelement <4 x float> %4549, float 0.000000e+00, i32 2
  %4551 = insertelement <4 x float> %4550, float 0.000000e+00, i32 3
  %4552 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4553 = getelementptr inbounds i8, i8* %4552, i64 20
  %4554 = bitcast i8* %4553 to float*
  %4555 = load float, float* %4554, align 4
  %4556 = insertelement <4 x float> zeroinitializer, float %4555, i32 0
  %4557 = insertelement <4 x float> %4556, float 0.000000e+00, i32 1
  %4558 = insertelement <4 x float> %4557, float 0.000000e+00, i32 2
  %4559 = insertelement <4 x float> %4558, float 0.000000e+00, i32 3
  %4560 = getelementptr inbounds float, float* %0, i64 4
  %4561 = load float, float* %4560, align 4
  %4562 = insertelement <4 x float> zeroinitializer, float %4561, i32 0
  %4563 = insertelement <4 x float> %4562, float 0.000000e+00, i32 1
  %4564 = insertelement <4 x float> %4563, float 0.000000e+00, i32 2
  %4565 = insertelement <4 x float> %4564, float 0.000000e+00, i32 3
  %4566 = call <4 x float> @llvm.fma.f32.86(<4 x float> %4559, <4 x float> %4565, <4 x float> %4551)
  %4567 = extractelement <4 x float> %4566, i32 0
  %4568 = getelementptr inbounds float, float* %2, i64 4
  store float %4567, float* %4568, align 4
  %4569 = getelementptr inbounds float, float* %2, i64 4
  %4570 = load float, float* %4569, align 4
  %4571 = insertelement <4 x float> zeroinitializer, float %4570, i32 0
  %4572 = insertelement <4 x float> %4571, float 0.000000e+00, i32 1
  %4573 = insertelement <4 x float> %4572, float 0.000000e+00, i32 2
  %4574 = insertelement <4 x float> %4573, float 0.000000e+00, i32 3
  %4575 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4576 = getelementptr inbounds i8, i8* %4575, i64 24
  %4577 = bitcast i8* %4576 to float*
  %4578 = load float, float* %4577, align 4
  %4579 = insertelement <4 x float> zeroinitializer, float %4578, i32 0
  %4580 = insertelement <4 x float> %4579, float 0.000000e+00, i32 1
  %4581 = insertelement <4 x float> %4580, float 0.000000e+00, i32 2
  %4582 = insertelement <4 x float> %4581, float 0.000000e+00, i32 3
  %4583 = getelementptr inbounds float, float* %0, i64 8
  %4584 = load float, float* %4583, align 4
  %4585 = insertelement <4 x float> zeroinitializer, float %4584, i32 0
  %4586 = insertelement <4 x float> %4585, float 0.000000e+00, i32 1
  %4587 = insertelement <4 x float> %4586, float 0.000000e+00, i32 2
  %4588 = insertelement <4 x float> %4587, float 0.000000e+00, i32 3
  %4589 = call <4 x float> @llvm.fma.f32.87(<4 x float> %4582, <4 x float> %4588, <4 x float> %4574)
  %4590 = extractelement <4 x float> %4589, i32 0
  %4591 = getelementptr inbounds float, float* %2, i64 4
  store float %4590, float* %4591, align 4
  %4592 = getelementptr inbounds float, float* %2, i64 4
  %4593 = load float, float* %4592, align 4
  %4594 = insertelement <4 x float> zeroinitializer, float %4593, i32 0
  %4595 = insertelement <4 x float> %4594, float 0.000000e+00, i32 1
  %4596 = insertelement <4 x float> %4595, float 0.000000e+00, i32 2
  %4597 = insertelement <4 x float> %4596, float 0.000000e+00, i32 3
  %4598 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4599 = getelementptr inbounds i8, i8* %4598, i64 28
  %4600 = bitcast i8* %4599 to float*
  %4601 = load float, float* %4600, align 4
  %4602 = insertelement <4 x float> zeroinitializer, float %4601, i32 0
  %4603 = insertelement <4 x float> %4602, float 0.000000e+00, i32 1
  %4604 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4605 = getelementptr inbounds i8, i8* %4604, i64 16
  %4606 = bitcast i8* %4605 to float*
  %4607 = load float, float* %4606, align 4
  %4608 = insertelement <4 x float> %4603, float %4607, i32 2
  %4609 = insertelement <4 x float> %4608, float 0.000000e+00, i32 3
  %4610 = getelementptr inbounds float, float* %0, i64 12
  %4611 = load float, float* %4610, align 4
  %4612 = insertelement <4 x float> zeroinitializer, float %4611, i32 0
  %4613 = insertelement <4 x float> %4612, float 0.000000e+00, i32 1
  %4614 = getelementptr inbounds float, float* %0, i64 1
  %4615 = load float, float* %4614, align 4
  %4616 = insertelement <4 x float> %4613, float %4615, i32 2
  %4617 = insertelement <4 x float> %4616, float 0.000000e+00, i32 3
  %4618 = call <4 x float> @llvm.fma.f32.88(<4 x float> %4609, <4 x float> %4617, <4 x float> %4597)
  %4619 = extractelement <4 x float> %4618, i32 0
  %4620 = getelementptr inbounds float, float* %2, i64 4
  store float %4619, float* %4620, align 4
  %4621 = extractelement <4 x float> %4618, i32 1
  %4622 = getelementptr inbounds float, float* %2, i64 5
  store float %4621, float* %4622, align 4
  %4623 = extractelement <4 x float> %4618, i32 2
  %4624 = getelementptr inbounds float, float* %2, i64 5
  store float %4623, float* %4624, align 4
  %4625 = getelementptr inbounds float, float* %2, i64 5
  %4626 = load float, float* %4625, align 4
  %4627 = insertelement <4 x float> zeroinitializer, float %4626, i32 0
  %4628 = insertelement <4 x float> %4627, float 0.000000e+00, i32 1
  %4629 = insertelement <4 x float> %4628, float 0.000000e+00, i32 2
  %4630 = insertelement <4 x float> %4629, float 0.000000e+00, i32 3
  %4631 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4632 = getelementptr inbounds i8, i8* %4631, i64 20
  %4633 = bitcast i8* %4632 to float*
  %4634 = load float, float* %4633, align 4
  %4635 = insertelement <4 x float> zeroinitializer, float %4634, i32 0
  %4636 = insertelement <4 x float> %4635, float 0.000000e+00, i32 1
  %4637 = insertelement <4 x float> %4636, float 0.000000e+00, i32 2
  %4638 = insertelement <4 x float> %4637, float 0.000000e+00, i32 3
  %4639 = getelementptr inbounds float, float* %0, i64 5
  %4640 = load float, float* %4639, align 4
  %4641 = insertelement <4 x float> zeroinitializer, float %4640, i32 0
  %4642 = insertelement <4 x float> %4641, float 0.000000e+00, i32 1
  %4643 = insertelement <4 x float> %4642, float 0.000000e+00, i32 2
  %4644 = insertelement <4 x float> %4643, float 0.000000e+00, i32 3
  %4645 = call <4 x float> @llvm.fma.f32.89(<4 x float> %4638, <4 x float> %4644, <4 x float> %4630)
  %4646 = extractelement <4 x float> %4645, i32 0
  %4647 = getelementptr inbounds float, float* %2, i64 5
  store float %4646, float* %4647, align 4
  %4648 = getelementptr inbounds float, float* %2, i64 5
  %4649 = load float, float* %4648, align 4
  %4650 = insertelement <4 x float> zeroinitializer, float %4649, i32 0
  %4651 = insertelement <4 x float> %4650, float 0.000000e+00, i32 1
  %4652 = insertelement <4 x float> %4651, float 0.000000e+00, i32 2
  %4653 = insertelement <4 x float> %4652, float 0.000000e+00, i32 3
  %4654 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4655 = getelementptr inbounds i8, i8* %4654, i64 24
  %4656 = bitcast i8* %4655 to float*
  %4657 = load float, float* %4656, align 4
  %4658 = insertelement <4 x float> zeroinitializer, float %4657, i32 0
  %4659 = insertelement <4 x float> %4658, float 0.000000e+00, i32 1
  %4660 = insertelement <4 x float> %4659, float 0.000000e+00, i32 2
  %4661 = insertelement <4 x float> %4660, float 0.000000e+00, i32 3
  %4662 = getelementptr inbounds float, float* %0, i64 9
  %4663 = load float, float* %4662, align 4
  %4664 = insertelement <4 x float> zeroinitializer, float %4663, i32 0
  %4665 = insertelement <4 x float> %4664, float 0.000000e+00, i32 1
  %4666 = insertelement <4 x float> %4665, float 0.000000e+00, i32 2
  %4667 = insertelement <4 x float> %4666, float 0.000000e+00, i32 3
  %4668 = call <4 x float> @llvm.fma.f32.90(<4 x float> %4661, <4 x float> %4667, <4 x float> %4653)
  %4669 = extractelement <4 x float> %4668, i32 0
  %4670 = getelementptr inbounds float, float* %2, i64 5
  store float %4669, float* %4670, align 4
  %4671 = getelementptr inbounds float, float* %2, i64 5
  %4672 = load float, float* %4671, align 4
  %4673 = insertelement <4 x float> zeroinitializer, float %4672, i32 0
  %4674 = insertelement <4 x float> %4673, float 0.000000e+00, i32 1
  %4675 = insertelement <4 x float> %4674, float 0.000000e+00, i32 2
  %4676 = insertelement <4 x float> %4675, float 0.000000e+00, i32 3
  %4677 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4678 = getelementptr inbounds i8, i8* %4677, i64 28
  %4679 = bitcast i8* %4678 to float*
  %4680 = load float, float* %4679, align 4
  %4681 = insertelement <4 x float> zeroinitializer, float %4680, i32 0
  %4682 = insertelement <4 x float> %4681, float 0.000000e+00, i32 1
  %4683 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4684 = getelementptr inbounds i8, i8* %4683, i64 16
  %4685 = bitcast i8* %4684 to float*
  %4686 = load float, float* %4685, align 4
  %4687 = insertelement <4 x float> %4682, float %4686, i32 2
  %4688 = insertelement <4 x float> %4687, float 0.000000e+00, i32 3
  %4689 = getelementptr inbounds float, float* %0, i64 13
  %4690 = load float, float* %4689, align 4
  %4691 = insertelement <4 x float> zeroinitializer, float %4690, i32 0
  %4692 = insertelement <4 x float> %4691, float 0.000000e+00, i32 1
  %4693 = getelementptr inbounds float, float* %0, i64 2
  %4694 = load float, float* %4693, align 4
  %4695 = insertelement <4 x float> %4692, float %4694, i32 2
  %4696 = insertelement <4 x float> %4695, float 0.000000e+00, i32 3
  %4697 = call <4 x float> @llvm.fma.f32.91(<4 x float> %4688, <4 x float> %4696, <4 x float> %4676)
  %4698 = extractelement <4 x float> %4697, i32 0
  %4699 = getelementptr inbounds float, float* %2, i64 5
  store float %4698, float* %4699, align 4
  %4700 = extractelement <4 x float> %4697, i32 1
  %4701 = getelementptr inbounds float, float* %2, i64 6
  store float %4700, float* %4701, align 4
  %4702 = extractelement <4 x float> %4697, i32 2
  %4703 = getelementptr inbounds float, float* %2, i64 6
  store float %4702, float* %4703, align 4
  %4704 = getelementptr inbounds float, float* %2, i64 6
  %4705 = load float, float* %4704, align 4
  %4706 = insertelement <4 x float> zeroinitializer, float %4705, i32 0
  %4707 = insertelement <4 x float> %4706, float 0.000000e+00, i32 1
  %4708 = insertelement <4 x float> %4707, float 0.000000e+00, i32 2
  %4709 = insertelement <4 x float> %4708, float 0.000000e+00, i32 3
  %4710 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4711 = getelementptr inbounds i8, i8* %4710, i64 20
  %4712 = bitcast i8* %4711 to float*
  %4713 = load float, float* %4712, align 4
  %4714 = insertelement <4 x float> zeroinitializer, float %4713, i32 0
  %4715 = insertelement <4 x float> %4714, float 0.000000e+00, i32 1
  %4716 = insertelement <4 x float> %4715, float 0.000000e+00, i32 2
  %4717 = insertelement <4 x float> %4716, float 0.000000e+00, i32 3
  %4718 = getelementptr inbounds float, float* %0, i64 6
  %4719 = load float, float* %4718, align 4
  %4720 = insertelement <4 x float> zeroinitializer, float %4719, i32 0
  %4721 = insertelement <4 x float> %4720, float 0.000000e+00, i32 1
  %4722 = insertelement <4 x float> %4721, float 0.000000e+00, i32 2
  %4723 = insertelement <4 x float> %4722, float 0.000000e+00, i32 3
  %4724 = call <4 x float> @llvm.fma.f32.92(<4 x float> %4717, <4 x float> %4723, <4 x float> %4709)
  %4725 = extractelement <4 x float> %4724, i32 0
  %4726 = getelementptr inbounds float, float* %2, i64 6
  store float %4725, float* %4726, align 4
  %4727 = getelementptr inbounds float, float* %2, i64 6
  %4728 = load float, float* %4727, align 4
  %4729 = insertelement <4 x float> zeroinitializer, float %4728, i32 0
  %4730 = insertelement <4 x float> %4729, float 0.000000e+00, i32 1
  %4731 = insertelement <4 x float> %4730, float 0.000000e+00, i32 2
  %4732 = insertelement <4 x float> %4731, float 0.000000e+00, i32 3
  %4733 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4734 = getelementptr inbounds i8, i8* %4733, i64 24
  %4735 = bitcast i8* %4734 to float*
  %4736 = load float, float* %4735, align 4
  %4737 = insertelement <4 x float> zeroinitializer, float %4736, i32 0
  %4738 = insertelement <4 x float> %4737, float 0.000000e+00, i32 1
  %4739 = insertelement <4 x float> %4738, float 0.000000e+00, i32 2
  %4740 = insertelement <4 x float> %4739, float 0.000000e+00, i32 3
  %4741 = getelementptr inbounds float, float* %0, i64 10
  %4742 = load float, float* %4741, align 4
  %4743 = insertelement <4 x float> zeroinitializer, float %4742, i32 0
  %4744 = insertelement <4 x float> %4743, float 0.000000e+00, i32 1
  %4745 = insertelement <4 x float> %4744, float 0.000000e+00, i32 2
  %4746 = insertelement <4 x float> %4745, float 0.000000e+00, i32 3
  %4747 = call <4 x float> @llvm.fma.f32.93(<4 x float> %4740, <4 x float> %4746, <4 x float> %4732)
  %4748 = extractelement <4 x float> %4747, i32 0
  %4749 = getelementptr inbounds float, float* %2, i64 6
  store float %4748, float* %4749, align 4
  %4750 = getelementptr inbounds float, float* %2, i64 6
  %4751 = load float, float* %4750, align 4
  %4752 = insertelement <4 x float> zeroinitializer, float %4751, i32 0
  %4753 = insertelement <4 x float> %4752, float 0.000000e+00, i32 1
  %4754 = insertelement <4 x float> %4753, float 0.000000e+00, i32 2
  %4755 = insertelement <4 x float> %4754, float 0.000000e+00, i32 3
  %4756 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4757 = getelementptr inbounds i8, i8* %4756, i64 28
  %4758 = bitcast i8* %4757 to float*
  %4759 = load float, float* %4758, align 4
  %4760 = insertelement <4 x float> zeroinitializer, float %4759, i32 0
  %4761 = insertelement <4 x float> %4760, float 0.000000e+00, i32 1
  %4762 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4763 = getelementptr inbounds i8, i8* %4762, i64 16
  %4764 = bitcast i8* %4763 to float*
  %4765 = load float, float* %4764, align 4
  %4766 = insertelement <4 x float> %4761, float %4765, i32 2
  %4767 = insertelement <4 x float> %4766, float 0.000000e+00, i32 3
  %4768 = getelementptr inbounds float, float* %0, i64 14
  %4769 = load float, float* %4768, align 4
  %4770 = insertelement <4 x float> zeroinitializer, float %4769, i32 0
  %4771 = insertelement <4 x float> %4770, float 0.000000e+00, i32 1
  %4772 = getelementptr inbounds float, float* %0, i64 3
  %4773 = load float, float* %4772, align 4
  %4774 = insertelement <4 x float> %4771, float %4773, i32 2
  %4775 = insertelement <4 x float> %4774, float 0.000000e+00, i32 3
  %4776 = call <4 x float> @llvm.fma.f32.94(<4 x float> %4767, <4 x float> %4775, <4 x float> %4755)
  %4777 = extractelement <4 x float> %4776, i32 0
  %4778 = getelementptr inbounds float, float* %2, i64 6
  store float %4777, float* %4778, align 4
  %4779 = extractelement <4 x float> %4776, i32 1
  %4780 = getelementptr inbounds float, float* %2, i64 7
  store float %4779, float* %4780, align 4
  %4781 = extractelement <4 x float> %4776, i32 2
  %4782 = getelementptr inbounds float, float* %2, i64 7
  store float %4781, float* %4782, align 4
  %4783 = getelementptr inbounds float, float* %2, i64 7
  %4784 = load float, float* %4783, align 4
  %4785 = insertelement <4 x float> zeroinitializer, float %4784, i32 0
  %4786 = insertelement <4 x float> %4785, float 0.000000e+00, i32 1
  %4787 = insertelement <4 x float> %4786, float 0.000000e+00, i32 2
  %4788 = insertelement <4 x float> %4787, float 0.000000e+00, i32 3
  %4789 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4790 = getelementptr inbounds i8, i8* %4789, i64 20
  %4791 = bitcast i8* %4790 to float*
  %4792 = load float, float* %4791, align 4
  %4793 = insertelement <4 x float> zeroinitializer, float %4792, i32 0
  %4794 = insertelement <4 x float> %4793, float 0.000000e+00, i32 1
  %4795 = insertelement <4 x float> %4794, float 0.000000e+00, i32 2
  %4796 = insertelement <4 x float> %4795, float 0.000000e+00, i32 3
  %4797 = getelementptr inbounds float, float* %0, i64 7
  %4798 = load float, float* %4797, align 4
  %4799 = insertelement <4 x float> zeroinitializer, float %4798, i32 0
  %4800 = insertelement <4 x float> %4799, float 0.000000e+00, i32 1
  %4801 = insertelement <4 x float> %4800, float 0.000000e+00, i32 2
  %4802 = insertelement <4 x float> %4801, float 0.000000e+00, i32 3
  %4803 = call <4 x float> @llvm.fma.f32.95(<4 x float> %4796, <4 x float> %4802, <4 x float> %4788)
  %4804 = extractelement <4 x float> %4803, i32 0
  %4805 = getelementptr inbounds float, float* %2, i64 7
  store float %4804, float* %4805, align 4
  %4806 = getelementptr inbounds float, float* %2, i64 7
  %4807 = load float, float* %4806, align 4
  %4808 = insertelement <4 x float> zeroinitializer, float %4807, i32 0
  %4809 = insertelement <4 x float> %4808, float 0.000000e+00, i32 1
  %4810 = insertelement <4 x float> %4809, float 0.000000e+00, i32 2
  %4811 = insertelement <4 x float> %4810, float 0.000000e+00, i32 3
  %4812 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4813 = getelementptr inbounds i8, i8* %4812, i64 24
  %4814 = bitcast i8* %4813 to float*
  %4815 = load float, float* %4814, align 4
  %4816 = insertelement <4 x float> zeroinitializer, float %4815, i32 0
  %4817 = insertelement <4 x float> %4816, float 0.000000e+00, i32 1
  %4818 = insertelement <4 x float> %4817, float 0.000000e+00, i32 2
  %4819 = insertelement <4 x float> %4818, float 0.000000e+00, i32 3
  %4820 = getelementptr inbounds float, float* %0, i64 11
  %4821 = load float, float* %4820, align 4
  %4822 = insertelement <4 x float> zeroinitializer, float %4821, i32 0
  %4823 = insertelement <4 x float> %4822, float 0.000000e+00, i32 1
  %4824 = insertelement <4 x float> %4823, float 0.000000e+00, i32 2
  %4825 = insertelement <4 x float> %4824, float 0.000000e+00, i32 3
  %4826 = call <4 x float> @llvm.fma.f32.96(<4 x float> %4819, <4 x float> %4825, <4 x float> %4811)
  %4827 = extractelement <4 x float> %4826, i32 0
  %4828 = getelementptr inbounds float, float* %2, i64 7
  store float %4827, float* %4828, align 4
  %4829 = getelementptr inbounds float, float* %2, i64 7
  %4830 = load float, float* %4829, align 4
  %4831 = insertelement <4 x float> zeroinitializer, float %4830, i32 0
  %4832 = insertelement <4 x float> %4831, float 0.000000e+00, i32 1
  %4833 = insertelement <4 x float> %4832, float 0.000000e+00, i32 2
  %4834 = insertelement <4 x float> %4833, float 0.000000e+00, i32 3
  %4835 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4836 = getelementptr inbounds i8, i8* %4835, i64 28
  %4837 = bitcast i8* %4836 to float*
  %4838 = load float, float* %4837, align 4
  %4839 = insertelement <4 x float> zeroinitializer, float %4838, i32 0
  %4840 = insertelement <4 x float> %4839, float 0.000000e+00, i32 1
  %4841 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4842 = getelementptr inbounds i8, i8* %4841, i64 32
  %4843 = bitcast i8* %4842 to float*
  %4844 = load float, float* %4843, align 4
  %4845 = insertelement <4 x float> %4840, float %4844, i32 2
  %4846 = insertelement <4 x float> %4845, float 0.000000e+00, i32 3
  %4847 = getelementptr inbounds float, float* %0, i64 15
  %4848 = load float, float* %4847, align 4
  %4849 = insertelement <4 x float> zeroinitializer, float %4848, i32 0
  %4850 = insertelement <4 x float> %4849, float 0.000000e+00, i32 1
  %4851 = load float, float* %0, align 4
  %4852 = insertelement <4 x float> %4850, float %4851, i32 2
  %4853 = insertelement <4 x float> %4852, float 0.000000e+00, i32 3
  %4854 = call <4 x float> @llvm.fma.f32.97(<4 x float> %4846, <4 x float> %4853, <4 x float> %4834)
  %4855 = extractelement <4 x float> %4854, i32 0
  %4856 = getelementptr inbounds float, float* %2, i64 7
  store float %4855, float* %4856, align 4
  %4857 = extractelement <4 x float> %4854, i32 1
  %4858 = getelementptr inbounds float, float* %2, i64 8
  store float %4857, float* %4858, align 4
  %4859 = extractelement <4 x float> %4854, i32 2
  %4860 = getelementptr inbounds float, float* %2, i64 8
  store float %4859, float* %4860, align 4
  %4861 = getelementptr inbounds float, float* %2, i64 8
  %4862 = load float, float* %4861, align 4
  %4863 = insertelement <4 x float> zeroinitializer, float %4862, i32 0
  %4864 = insertelement <4 x float> %4863, float 0.000000e+00, i32 1
  %4865 = insertelement <4 x float> %4864, float 0.000000e+00, i32 2
  %4866 = insertelement <4 x float> %4865, float 0.000000e+00, i32 3
  %4867 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4868 = getelementptr inbounds i8, i8* %4867, i64 36
  %4869 = bitcast i8* %4868 to float*
  %4870 = load float, float* %4869, align 4
  %4871 = insertelement <4 x float> zeroinitializer, float %4870, i32 0
  %4872 = insertelement <4 x float> %4871, float 0.000000e+00, i32 1
  %4873 = insertelement <4 x float> %4872, float 0.000000e+00, i32 2
  %4874 = insertelement <4 x float> %4873, float 0.000000e+00, i32 3
  %4875 = getelementptr inbounds float, float* %0, i64 4
  %4876 = load float, float* %4875, align 4
  %4877 = insertelement <4 x float> zeroinitializer, float %4876, i32 0
  %4878 = insertelement <4 x float> %4877, float 0.000000e+00, i32 1
  %4879 = insertelement <4 x float> %4878, float 0.000000e+00, i32 2
  %4880 = insertelement <4 x float> %4879, float 0.000000e+00, i32 3
  %4881 = call <4 x float> @llvm.fma.f32.98(<4 x float> %4874, <4 x float> %4880, <4 x float> %4866)
  %4882 = extractelement <4 x float> %4881, i32 0
  %4883 = getelementptr inbounds float, float* %2, i64 8
  store float %4882, float* %4883, align 4
  %4884 = getelementptr inbounds float, float* %2, i64 8
  %4885 = load float, float* %4884, align 4
  %4886 = insertelement <4 x float> zeroinitializer, float %4885, i32 0
  %4887 = insertelement <4 x float> %4886, float 0.000000e+00, i32 1
  %4888 = insertelement <4 x float> %4887, float 0.000000e+00, i32 2
  %4889 = insertelement <4 x float> %4888, float 0.000000e+00, i32 3
  %4890 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4891 = getelementptr inbounds i8, i8* %4890, i64 40
  %4892 = bitcast i8* %4891 to float*
  %4893 = load float, float* %4892, align 4
  %4894 = insertelement <4 x float> zeroinitializer, float %4893, i32 0
  %4895 = insertelement <4 x float> %4894, float 0.000000e+00, i32 1
  %4896 = insertelement <4 x float> %4895, float 0.000000e+00, i32 2
  %4897 = insertelement <4 x float> %4896, float 0.000000e+00, i32 3
  %4898 = getelementptr inbounds float, float* %0, i64 8
  %4899 = load float, float* %4898, align 4
  %4900 = insertelement <4 x float> zeroinitializer, float %4899, i32 0
  %4901 = insertelement <4 x float> %4900, float 0.000000e+00, i32 1
  %4902 = insertelement <4 x float> %4901, float 0.000000e+00, i32 2
  %4903 = insertelement <4 x float> %4902, float 0.000000e+00, i32 3
  %4904 = call <4 x float> @llvm.fma.f32.99(<4 x float> %4897, <4 x float> %4903, <4 x float> %4889)
  %4905 = extractelement <4 x float> %4904, i32 0
  %4906 = getelementptr inbounds float, float* %2, i64 8
  store float %4905, float* %4906, align 4
  %4907 = getelementptr inbounds float, float* %2, i64 8
  %4908 = load float, float* %4907, align 4
  %4909 = insertelement <4 x float> zeroinitializer, float %4908, i32 0
  %4910 = insertelement <4 x float> %4909, float 0.000000e+00, i32 1
  %4911 = insertelement <4 x float> %4910, float 0.000000e+00, i32 2
  %4912 = insertelement <4 x float> %4911, float 0.000000e+00, i32 3
  %4913 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4914 = getelementptr inbounds i8, i8* %4913, i64 44
  %4915 = bitcast i8* %4914 to float*
  %4916 = load float, float* %4915, align 4
  %4917 = insertelement <4 x float> zeroinitializer, float %4916, i32 0
  %4918 = insertelement <4 x float> %4917, float 0.000000e+00, i32 1
  %4919 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4920 = getelementptr inbounds i8, i8* %4919, i64 32
  %4921 = bitcast i8* %4920 to float*
  %4922 = load float, float* %4921, align 4
  %4923 = insertelement <4 x float> %4918, float %4922, i32 2
  %4924 = insertelement <4 x float> %4923, float 0.000000e+00, i32 3
  %4925 = getelementptr inbounds float, float* %0, i64 12
  %4926 = load float, float* %4925, align 4
  %4927 = insertelement <4 x float> zeroinitializer, float %4926, i32 0
  %4928 = insertelement <4 x float> %4927, float 0.000000e+00, i32 1
  %4929 = getelementptr inbounds float, float* %0, i64 1
  %4930 = load float, float* %4929, align 4
  %4931 = insertelement <4 x float> %4928, float %4930, i32 2
  %4932 = insertelement <4 x float> %4931, float 0.000000e+00, i32 3
  %4933 = call <4 x float> @llvm.fma.f32.100(<4 x float> %4924, <4 x float> %4932, <4 x float> %4912)
  %4934 = extractelement <4 x float> %4933, i32 0
  %4935 = getelementptr inbounds float, float* %2, i64 8
  store float %4934, float* %4935, align 4
  %4936 = extractelement <4 x float> %4933, i32 1
  %4937 = getelementptr inbounds float, float* %2, i64 9
  store float %4936, float* %4937, align 4
  %4938 = extractelement <4 x float> %4933, i32 2
  %4939 = getelementptr inbounds float, float* %2, i64 9
  store float %4938, float* %4939, align 4
  %4940 = getelementptr inbounds float, float* %2, i64 9
  %4941 = load float, float* %4940, align 4
  %4942 = insertelement <4 x float> zeroinitializer, float %4941, i32 0
  %4943 = insertelement <4 x float> %4942, float 0.000000e+00, i32 1
  %4944 = insertelement <4 x float> %4943, float 0.000000e+00, i32 2
  %4945 = insertelement <4 x float> %4944, float 0.000000e+00, i32 3
  %4946 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4947 = getelementptr inbounds i8, i8* %4946, i64 36
  %4948 = bitcast i8* %4947 to float*
  %4949 = load float, float* %4948, align 4
  %4950 = insertelement <4 x float> zeroinitializer, float %4949, i32 0
  %4951 = insertelement <4 x float> %4950, float 0.000000e+00, i32 1
  %4952 = insertelement <4 x float> %4951, float 0.000000e+00, i32 2
  %4953 = insertelement <4 x float> %4952, float 0.000000e+00, i32 3
  %4954 = getelementptr inbounds float, float* %0, i64 5
  %4955 = load float, float* %4954, align 4
  %4956 = insertelement <4 x float> zeroinitializer, float %4955, i32 0
  %4957 = insertelement <4 x float> %4956, float 0.000000e+00, i32 1
  %4958 = insertelement <4 x float> %4957, float 0.000000e+00, i32 2
  %4959 = insertelement <4 x float> %4958, float 0.000000e+00, i32 3
  %4960 = call <4 x float> @llvm.fma.f32.101(<4 x float> %4953, <4 x float> %4959, <4 x float> %4945)
  %4961 = extractelement <4 x float> %4960, i32 0
  %4962 = getelementptr inbounds float, float* %2, i64 9
  store float %4961, float* %4962, align 4
  %4963 = getelementptr inbounds float, float* %2, i64 9
  %4964 = load float, float* %4963, align 4
  %4965 = insertelement <4 x float> zeroinitializer, float %4964, i32 0
  %4966 = insertelement <4 x float> %4965, float 0.000000e+00, i32 1
  %4967 = insertelement <4 x float> %4966, float 0.000000e+00, i32 2
  %4968 = insertelement <4 x float> %4967, float 0.000000e+00, i32 3
  %4969 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4970 = getelementptr inbounds i8, i8* %4969, i64 40
  %4971 = bitcast i8* %4970 to float*
  %4972 = load float, float* %4971, align 4
  %4973 = insertelement <4 x float> zeroinitializer, float %4972, i32 0
  %4974 = insertelement <4 x float> %4973, float 0.000000e+00, i32 1
  %4975 = insertelement <4 x float> %4974, float 0.000000e+00, i32 2
  %4976 = insertelement <4 x float> %4975, float 0.000000e+00, i32 3
  %4977 = getelementptr inbounds float, float* %0, i64 9
  %4978 = load float, float* %4977, align 4
  %4979 = insertelement <4 x float> zeroinitializer, float %4978, i32 0
  %4980 = insertelement <4 x float> %4979, float 0.000000e+00, i32 1
  %4981 = insertelement <4 x float> %4980, float 0.000000e+00, i32 2
  %4982 = insertelement <4 x float> %4981, float 0.000000e+00, i32 3
  %4983 = call <4 x float> @llvm.fma.f32.102(<4 x float> %4976, <4 x float> %4982, <4 x float> %4968)
  %4984 = extractelement <4 x float> %4983, i32 0
  %4985 = getelementptr inbounds float, float* %2, i64 9
  store float %4984, float* %4985, align 4
  %4986 = getelementptr inbounds float, float* %2, i64 9
  %4987 = load float, float* %4986, align 4
  %4988 = insertelement <4 x float> zeroinitializer, float %4987, i32 0
  %4989 = insertelement <4 x float> %4988, float 0.000000e+00, i32 1
  %4990 = insertelement <4 x float> %4989, float 0.000000e+00, i32 2
  %4991 = insertelement <4 x float> %4990, float 0.000000e+00, i32 3
  %4992 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4993 = getelementptr inbounds i8, i8* %4992, i64 44
  %4994 = bitcast i8* %4993 to float*
  %4995 = load float, float* %4994, align 4
  %4996 = insertelement <4 x float> zeroinitializer, float %4995, i32 0
  %4997 = insertelement <4 x float> %4996, float 0.000000e+00, i32 1
  %4998 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %4999 = getelementptr inbounds i8, i8* %4998, i64 32
  %5000 = bitcast i8* %4999 to float*
  %5001 = load float, float* %5000, align 4
  %5002 = insertelement <4 x float> %4997, float %5001, i32 2
  %5003 = insertelement <4 x float> %5002, float 0.000000e+00, i32 3
  %5004 = getelementptr inbounds float, float* %0, i64 13
  %5005 = load float, float* %5004, align 4
  %5006 = insertelement <4 x float> zeroinitializer, float %5005, i32 0
  %5007 = insertelement <4 x float> %5006, float 0.000000e+00, i32 1
  %5008 = getelementptr inbounds float, float* %0, i64 2
  %5009 = load float, float* %5008, align 4
  %5010 = insertelement <4 x float> %5007, float %5009, i32 2
  %5011 = insertelement <4 x float> %5010, float 0.000000e+00, i32 3
  %5012 = call <4 x float> @llvm.fma.f32.103(<4 x float> %5003, <4 x float> %5011, <4 x float> %4991)
  %5013 = extractelement <4 x float> %5012, i32 0
  %5014 = getelementptr inbounds float, float* %2, i64 9
  store float %5013, float* %5014, align 4
  %5015 = extractelement <4 x float> %5012, i32 1
  %5016 = getelementptr inbounds float, float* %2, i64 10
  store float %5015, float* %5016, align 4
  %5017 = extractelement <4 x float> %5012, i32 2
  %5018 = getelementptr inbounds float, float* %2, i64 10
  store float %5017, float* %5018, align 4
  %5019 = getelementptr inbounds float, float* %2, i64 10
  %5020 = load float, float* %5019, align 4
  %5021 = insertelement <4 x float> zeroinitializer, float %5020, i32 0
  %5022 = insertelement <4 x float> %5021, float 0.000000e+00, i32 1
  %5023 = insertelement <4 x float> %5022, float 0.000000e+00, i32 2
  %5024 = insertelement <4 x float> %5023, float 0.000000e+00, i32 3
  %5025 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5026 = getelementptr inbounds i8, i8* %5025, i64 36
  %5027 = bitcast i8* %5026 to float*
  %5028 = load float, float* %5027, align 4
  %5029 = insertelement <4 x float> zeroinitializer, float %5028, i32 0
  %5030 = insertelement <4 x float> %5029, float 0.000000e+00, i32 1
  %5031 = insertelement <4 x float> %5030, float 0.000000e+00, i32 2
  %5032 = insertelement <4 x float> %5031, float 0.000000e+00, i32 3
  %5033 = getelementptr inbounds float, float* %0, i64 6
  %5034 = load float, float* %5033, align 4
  %5035 = insertelement <4 x float> zeroinitializer, float %5034, i32 0
  %5036 = insertelement <4 x float> %5035, float 0.000000e+00, i32 1
  %5037 = insertelement <4 x float> %5036, float 0.000000e+00, i32 2
  %5038 = insertelement <4 x float> %5037, float 0.000000e+00, i32 3
  %5039 = call <4 x float> @llvm.fma.f32.104(<4 x float> %5032, <4 x float> %5038, <4 x float> %5024)
  %5040 = extractelement <4 x float> %5039, i32 0
  %5041 = getelementptr inbounds float, float* %2, i64 10
  store float %5040, float* %5041, align 4
  %5042 = getelementptr inbounds float, float* %2, i64 10
  %5043 = load float, float* %5042, align 4
  %5044 = insertelement <4 x float> zeroinitializer, float %5043, i32 0
  %5045 = insertelement <4 x float> %5044, float 0.000000e+00, i32 1
  %5046 = insertelement <4 x float> %5045, float 0.000000e+00, i32 2
  %5047 = insertelement <4 x float> %5046, float 0.000000e+00, i32 3
  %5048 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5049 = getelementptr inbounds i8, i8* %5048, i64 40
  %5050 = bitcast i8* %5049 to float*
  %5051 = load float, float* %5050, align 4
  %5052 = insertelement <4 x float> zeroinitializer, float %5051, i32 0
  %5053 = insertelement <4 x float> %5052, float 0.000000e+00, i32 1
  %5054 = insertelement <4 x float> %5053, float 0.000000e+00, i32 2
  %5055 = insertelement <4 x float> %5054, float 0.000000e+00, i32 3
  %5056 = getelementptr inbounds float, float* %0, i64 10
  %5057 = load float, float* %5056, align 4
  %5058 = insertelement <4 x float> zeroinitializer, float %5057, i32 0
  %5059 = insertelement <4 x float> %5058, float 0.000000e+00, i32 1
  %5060 = insertelement <4 x float> %5059, float 0.000000e+00, i32 2
  %5061 = insertelement <4 x float> %5060, float 0.000000e+00, i32 3
  %5062 = call <4 x float> @llvm.fma.f32.105(<4 x float> %5055, <4 x float> %5061, <4 x float> %5047)
  %5063 = extractelement <4 x float> %5062, i32 0
  %5064 = getelementptr inbounds float, float* %2, i64 10
  store float %5063, float* %5064, align 4
  %5065 = getelementptr inbounds float, float* %2, i64 10
  %5066 = load float, float* %5065, align 4
  %5067 = insertelement <4 x float> zeroinitializer, float %5066, i32 0
  %5068 = insertelement <4 x float> %5067, float 0.000000e+00, i32 1
  %5069 = insertelement <4 x float> %5068, float 0.000000e+00, i32 2
  %5070 = insertelement <4 x float> %5069, float 0.000000e+00, i32 3
  %5071 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5072 = getelementptr inbounds i8, i8* %5071, i64 44
  %5073 = bitcast i8* %5072 to float*
  %5074 = load float, float* %5073, align 4
  %5075 = insertelement <4 x float> zeroinitializer, float %5074, i32 0
  %5076 = insertelement <4 x float> %5075, float 0.000000e+00, i32 1
  %5077 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5078 = getelementptr inbounds i8, i8* %5077, i64 32
  %5079 = bitcast i8* %5078 to float*
  %5080 = load float, float* %5079, align 4
  %5081 = insertelement <4 x float> %5076, float %5080, i32 2
  %5082 = insertelement <4 x float> %5081, float 0.000000e+00, i32 3
  %5083 = getelementptr inbounds float, float* %0, i64 14
  %5084 = load float, float* %5083, align 4
  %5085 = insertelement <4 x float> zeroinitializer, float %5084, i32 0
  %5086 = insertelement <4 x float> %5085, float 0.000000e+00, i32 1
  %5087 = getelementptr inbounds float, float* %0, i64 3
  %5088 = load float, float* %5087, align 4
  %5089 = insertelement <4 x float> %5086, float %5088, i32 2
  %5090 = insertelement <4 x float> %5089, float 0.000000e+00, i32 3
  %5091 = call <4 x float> @llvm.fma.f32.106(<4 x float> %5082, <4 x float> %5090, <4 x float> %5070)
  %5092 = extractelement <4 x float> %5091, i32 0
  %5093 = getelementptr inbounds float, float* %2, i64 10
  store float %5092, float* %5093, align 4
  %5094 = extractelement <4 x float> %5091, i32 1
  %5095 = getelementptr inbounds float, float* %2, i64 11
  store float %5094, float* %5095, align 4
  %5096 = extractelement <4 x float> %5091, i32 2
  %5097 = getelementptr inbounds float, float* %2, i64 11
  store float %5096, float* %5097, align 4
  %5098 = getelementptr inbounds float, float* %2, i64 11
  %5099 = load float, float* %5098, align 4
  %5100 = insertelement <4 x float> zeroinitializer, float %5099, i32 0
  %5101 = insertelement <4 x float> %5100, float 0.000000e+00, i32 1
  %5102 = insertelement <4 x float> %5101, float 0.000000e+00, i32 2
  %5103 = insertelement <4 x float> %5102, float 0.000000e+00, i32 3
  %5104 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5105 = getelementptr inbounds i8, i8* %5104, i64 36
  %5106 = bitcast i8* %5105 to float*
  %5107 = load float, float* %5106, align 4
  %5108 = insertelement <4 x float> zeroinitializer, float %5107, i32 0
  %5109 = insertelement <4 x float> %5108, float 0.000000e+00, i32 1
  %5110 = insertelement <4 x float> %5109, float 0.000000e+00, i32 2
  %5111 = insertelement <4 x float> %5110, float 0.000000e+00, i32 3
  %5112 = getelementptr inbounds float, float* %0, i64 7
  %5113 = load float, float* %5112, align 4
  %5114 = insertelement <4 x float> zeroinitializer, float %5113, i32 0
  %5115 = insertelement <4 x float> %5114, float 0.000000e+00, i32 1
  %5116 = insertelement <4 x float> %5115, float 0.000000e+00, i32 2
  %5117 = insertelement <4 x float> %5116, float 0.000000e+00, i32 3
  %5118 = call <4 x float> @llvm.fma.f32.107(<4 x float> %5111, <4 x float> %5117, <4 x float> %5103)
  %5119 = extractelement <4 x float> %5118, i32 0
  %5120 = getelementptr inbounds float, float* %2, i64 11
  store float %5119, float* %5120, align 4
  %5121 = getelementptr inbounds float, float* %2, i64 11
  %5122 = load float, float* %5121, align 4
  %5123 = insertelement <4 x float> zeroinitializer, float %5122, i32 0
  %5124 = insertelement <4 x float> %5123, float 0.000000e+00, i32 1
  %5125 = insertelement <4 x float> %5124, float 0.000000e+00, i32 2
  %5126 = insertelement <4 x float> %5125, float 0.000000e+00, i32 3
  %5127 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5128 = getelementptr inbounds i8, i8* %5127, i64 40
  %5129 = bitcast i8* %5128 to float*
  %5130 = load float, float* %5129, align 4
  %5131 = insertelement <4 x float> zeroinitializer, float %5130, i32 0
  %5132 = insertelement <4 x float> %5131, float 0.000000e+00, i32 1
  %5133 = insertelement <4 x float> %5132, float 0.000000e+00, i32 2
  %5134 = insertelement <4 x float> %5133, float 0.000000e+00, i32 3
  %5135 = getelementptr inbounds float, float* %0, i64 11
  %5136 = load float, float* %5135, align 4
  %5137 = insertelement <4 x float> zeroinitializer, float %5136, i32 0
  %5138 = insertelement <4 x float> %5137, float 0.000000e+00, i32 1
  %5139 = insertelement <4 x float> %5138, float 0.000000e+00, i32 2
  %5140 = insertelement <4 x float> %5139, float 0.000000e+00, i32 3
  %5141 = call <4 x float> @llvm.fma.f32.108(<4 x float> %5134, <4 x float> %5140, <4 x float> %5126)
  %5142 = extractelement <4 x float> %5141, i32 0
  %5143 = getelementptr inbounds float, float* %2, i64 11
  store float %5142, float* %5143, align 4
  %5144 = getelementptr inbounds float, float* %2, i64 11
  %5145 = load float, float* %5144, align 4
  %5146 = insertelement <4 x float> zeroinitializer, float %5145, i32 0
  %5147 = insertelement <4 x float> %5146, float 0.000000e+00, i32 1
  %5148 = insertelement <4 x float> %5147, float 0.000000e+00, i32 2
  %5149 = insertelement <4 x float> %5148, float 0.000000e+00, i32 3
  %5150 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5151 = getelementptr inbounds i8, i8* %5150, i64 44
  %5152 = bitcast i8* %5151 to float*
  %5153 = load float, float* %5152, align 4
  %5154 = insertelement <4 x float> zeroinitializer, float %5153, i32 0
  %5155 = insertelement <4 x float> %5154, float 0.000000e+00, i32 1
  %5156 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5157 = getelementptr inbounds i8, i8* %5156, i64 48
  %5158 = bitcast i8* %5157 to float*
  %5159 = load float, float* %5158, align 4
  %5160 = insertelement <4 x float> %5155, float %5159, i32 2
  %5161 = insertelement <4 x float> %5160, float 0.000000e+00, i32 3
  %5162 = getelementptr inbounds float, float* %0, i64 15
  %5163 = load float, float* %5162, align 4
  %5164 = insertelement <4 x float> zeroinitializer, float %5163, i32 0
  %5165 = insertelement <4 x float> %5164, float 0.000000e+00, i32 1
  %5166 = load float, float* %0, align 4
  %5167 = insertelement <4 x float> %5165, float %5166, i32 2
  %5168 = insertelement <4 x float> %5167, float 0.000000e+00, i32 3
  %5169 = call <4 x float> @llvm.fma.f32.109(<4 x float> %5161, <4 x float> %5168, <4 x float> %5149)
  %5170 = extractelement <4 x float> %5169, i32 0
  %5171 = getelementptr inbounds float, float* %2, i64 11
  store float %5170, float* %5171, align 4
  %5172 = extractelement <4 x float> %5169, i32 1
  %5173 = getelementptr inbounds float, float* %2, i64 12
  store float %5172, float* %5173, align 4
  %5174 = extractelement <4 x float> %5169, i32 2
  %5175 = getelementptr inbounds float, float* %2, i64 12
  store float %5174, float* %5175, align 4
  %5176 = getelementptr inbounds float, float* %2, i64 12
  %5177 = load float, float* %5176, align 4
  %5178 = insertelement <4 x float> zeroinitializer, float %5177, i32 0
  %5179 = insertelement <4 x float> %5178, float 0.000000e+00, i32 1
  %5180 = insertelement <4 x float> %5179, float 0.000000e+00, i32 2
  %5181 = insertelement <4 x float> %5180, float 0.000000e+00, i32 3
  %5182 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5183 = getelementptr inbounds i8, i8* %5182, i64 52
  %5184 = bitcast i8* %5183 to float*
  %5185 = load float, float* %5184, align 4
  %5186 = insertelement <4 x float> zeroinitializer, float %5185, i32 0
  %5187 = insertelement <4 x float> %5186, float 0.000000e+00, i32 1
  %5188 = insertelement <4 x float> %5187, float 0.000000e+00, i32 2
  %5189 = insertelement <4 x float> %5188, float 0.000000e+00, i32 3
  %5190 = getelementptr inbounds float, float* %0, i64 4
  %5191 = load float, float* %5190, align 4
  %5192 = insertelement <4 x float> zeroinitializer, float %5191, i32 0
  %5193 = insertelement <4 x float> %5192, float 0.000000e+00, i32 1
  %5194 = insertelement <4 x float> %5193, float 0.000000e+00, i32 2
  %5195 = insertelement <4 x float> %5194, float 0.000000e+00, i32 3
  %5196 = call <4 x float> @llvm.fma.f32.110(<4 x float> %5189, <4 x float> %5195, <4 x float> %5181)
  %5197 = extractelement <4 x float> %5196, i32 0
  %5198 = getelementptr inbounds float, float* %2, i64 12
  store float %5197, float* %5198, align 4
  %5199 = getelementptr inbounds float, float* %2, i64 12
  %5200 = load float, float* %5199, align 4
  %5201 = insertelement <4 x float> zeroinitializer, float %5200, i32 0
  %5202 = insertelement <4 x float> %5201, float 0.000000e+00, i32 1
  %5203 = insertelement <4 x float> %5202, float 0.000000e+00, i32 2
  %5204 = insertelement <4 x float> %5203, float 0.000000e+00, i32 3
  %5205 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5206 = getelementptr inbounds i8, i8* %5205, i64 56
  %5207 = bitcast i8* %5206 to float*
  %5208 = load float, float* %5207, align 4
  %5209 = insertelement <4 x float> zeroinitializer, float %5208, i32 0
  %5210 = insertelement <4 x float> %5209, float 0.000000e+00, i32 1
  %5211 = insertelement <4 x float> %5210, float 0.000000e+00, i32 2
  %5212 = insertelement <4 x float> %5211, float 0.000000e+00, i32 3
  %5213 = getelementptr inbounds float, float* %0, i64 8
  %5214 = load float, float* %5213, align 4
  %5215 = insertelement <4 x float> zeroinitializer, float %5214, i32 0
  %5216 = insertelement <4 x float> %5215, float 0.000000e+00, i32 1
  %5217 = insertelement <4 x float> %5216, float 0.000000e+00, i32 2
  %5218 = insertelement <4 x float> %5217, float 0.000000e+00, i32 3
  %5219 = call <4 x float> @llvm.fma.f32.111(<4 x float> %5212, <4 x float> %5218, <4 x float> %5204)
  %5220 = extractelement <4 x float> %5219, i32 0
  %5221 = getelementptr inbounds float, float* %2, i64 12
  store float %5220, float* %5221, align 4
  %5222 = getelementptr inbounds float, float* %2, i64 12
  %5223 = load float, float* %5222, align 4
  %5224 = insertelement <4 x float> zeroinitializer, float %5223, i32 0
  %5225 = insertelement <4 x float> %5224, float 0.000000e+00, i32 1
  %5226 = insertelement <4 x float> %5225, float 0.000000e+00, i32 2
  %5227 = insertelement <4 x float> %5226, float 0.000000e+00, i32 3
  %5228 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5229 = getelementptr inbounds i8, i8* %5228, i64 60
  %5230 = bitcast i8* %5229 to float*
  %5231 = load float, float* %5230, align 4
  %5232 = insertelement <4 x float> zeroinitializer, float %5231, i32 0
  %5233 = insertelement <4 x float> %5232, float 0.000000e+00, i32 1
  %5234 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5235 = getelementptr inbounds i8, i8* %5234, i64 48
  %5236 = bitcast i8* %5235 to float*
  %5237 = load float, float* %5236, align 4
  %5238 = insertelement <4 x float> %5233, float %5237, i32 2
  %5239 = insertelement <4 x float> %5238, float 0.000000e+00, i32 3
  %5240 = getelementptr inbounds float, float* %0, i64 12
  %5241 = load float, float* %5240, align 4
  %5242 = insertelement <4 x float> zeroinitializer, float %5241, i32 0
  %5243 = insertelement <4 x float> %5242, float 0.000000e+00, i32 1
  %5244 = getelementptr inbounds float, float* %0, i64 1
  %5245 = load float, float* %5244, align 4
  %5246 = insertelement <4 x float> %5243, float %5245, i32 2
  %5247 = insertelement <4 x float> %5246, float 0.000000e+00, i32 3
  %5248 = call <4 x float> @llvm.fma.f32.112(<4 x float> %5239, <4 x float> %5247, <4 x float> %5227)
  %5249 = extractelement <4 x float> %5248, i32 0
  %5250 = getelementptr inbounds float, float* %2, i64 12
  store float %5249, float* %5250, align 4
  %5251 = extractelement <4 x float> %5248, i32 1
  %5252 = getelementptr inbounds float, float* %2, i64 13
  store float %5251, float* %5252, align 4
  %5253 = extractelement <4 x float> %5248, i32 2
  %5254 = getelementptr inbounds float, float* %2, i64 13
  store float %5253, float* %5254, align 4
  %5255 = getelementptr inbounds float, float* %2, i64 13
  %5256 = load float, float* %5255, align 4
  %5257 = insertelement <4 x float> zeroinitializer, float %5256, i32 0
  %5258 = insertelement <4 x float> %5257, float 0.000000e+00, i32 1
  %5259 = insertelement <4 x float> %5258, float 0.000000e+00, i32 2
  %5260 = insertelement <4 x float> %5259, float 0.000000e+00, i32 3
  %5261 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5262 = getelementptr inbounds i8, i8* %5261, i64 52
  %5263 = bitcast i8* %5262 to float*
  %5264 = load float, float* %5263, align 4
  %5265 = insertelement <4 x float> zeroinitializer, float %5264, i32 0
  %5266 = insertelement <4 x float> %5265, float 0.000000e+00, i32 1
  %5267 = insertelement <4 x float> %5266, float 0.000000e+00, i32 2
  %5268 = insertelement <4 x float> %5267, float 0.000000e+00, i32 3
  %5269 = getelementptr inbounds float, float* %0, i64 5
  %5270 = load float, float* %5269, align 4
  %5271 = insertelement <4 x float> zeroinitializer, float %5270, i32 0
  %5272 = insertelement <4 x float> %5271, float 0.000000e+00, i32 1
  %5273 = insertelement <4 x float> %5272, float 0.000000e+00, i32 2
  %5274 = insertelement <4 x float> %5273, float 0.000000e+00, i32 3
  %5275 = call <4 x float> @llvm.fma.f32.113(<4 x float> %5268, <4 x float> %5274, <4 x float> %5260)
  %5276 = extractelement <4 x float> %5275, i32 0
  %5277 = getelementptr inbounds float, float* %2, i64 13
  store float %5276, float* %5277, align 4
  %5278 = getelementptr inbounds float, float* %2, i64 13
  %5279 = load float, float* %5278, align 4
  %5280 = insertelement <4 x float> zeroinitializer, float %5279, i32 0
  %5281 = insertelement <4 x float> %5280, float 0.000000e+00, i32 1
  %5282 = insertelement <4 x float> %5281, float 0.000000e+00, i32 2
  %5283 = insertelement <4 x float> %5282, float 0.000000e+00, i32 3
  %5284 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5285 = getelementptr inbounds i8, i8* %5284, i64 56
  %5286 = bitcast i8* %5285 to float*
  %5287 = load float, float* %5286, align 4
  %5288 = insertelement <4 x float> zeroinitializer, float %5287, i32 0
  %5289 = insertelement <4 x float> %5288, float 0.000000e+00, i32 1
  %5290 = insertelement <4 x float> %5289, float 0.000000e+00, i32 2
  %5291 = insertelement <4 x float> %5290, float 0.000000e+00, i32 3
  %5292 = getelementptr inbounds float, float* %0, i64 9
  %5293 = load float, float* %5292, align 4
  %5294 = insertelement <4 x float> zeroinitializer, float %5293, i32 0
  %5295 = insertelement <4 x float> %5294, float 0.000000e+00, i32 1
  %5296 = insertelement <4 x float> %5295, float 0.000000e+00, i32 2
  %5297 = insertelement <4 x float> %5296, float 0.000000e+00, i32 3
  %5298 = call <4 x float> @llvm.fma.f32.114(<4 x float> %5291, <4 x float> %5297, <4 x float> %5283)
  %5299 = extractelement <4 x float> %5298, i32 0
  %5300 = getelementptr inbounds float, float* %2, i64 13
  store float %5299, float* %5300, align 4
  %5301 = getelementptr inbounds float, float* %2, i64 13
  %5302 = load float, float* %5301, align 4
  %5303 = insertelement <4 x float> zeroinitializer, float %5302, i32 0
  %5304 = insertelement <4 x float> %5303, float 0.000000e+00, i32 1
  %5305 = insertelement <4 x float> %5304, float 0.000000e+00, i32 2
  %5306 = insertelement <4 x float> %5305, float 0.000000e+00, i32 3
  %5307 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5308 = getelementptr inbounds i8, i8* %5307, i64 60
  %5309 = bitcast i8* %5308 to float*
  %5310 = load float, float* %5309, align 4
  %5311 = insertelement <4 x float> zeroinitializer, float %5310, i32 0
  %5312 = insertelement <4 x float> %5311, float 0.000000e+00, i32 1
  %5313 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5314 = getelementptr inbounds i8, i8* %5313, i64 48
  %5315 = bitcast i8* %5314 to float*
  %5316 = load float, float* %5315, align 4
  %5317 = insertelement <4 x float> %5312, float %5316, i32 2
  %5318 = insertelement <4 x float> %5317, float 0.000000e+00, i32 3
  %5319 = getelementptr inbounds float, float* %0, i64 13
  %5320 = load float, float* %5319, align 4
  %5321 = insertelement <4 x float> zeroinitializer, float %5320, i32 0
  %5322 = insertelement <4 x float> %5321, float 0.000000e+00, i32 1
  %5323 = getelementptr inbounds float, float* %0, i64 2
  %5324 = load float, float* %5323, align 4
  %5325 = insertelement <4 x float> %5322, float %5324, i32 2
  %5326 = insertelement <4 x float> %5325, float 0.000000e+00, i32 3
  %5327 = call <4 x float> @llvm.fma.f32.115(<4 x float> %5318, <4 x float> %5326, <4 x float> %5306)
  %5328 = extractelement <4 x float> %5327, i32 0
  %5329 = getelementptr inbounds float, float* %2, i64 13
  store float %5328, float* %5329, align 4
  %5330 = extractelement <4 x float> %5327, i32 1
  %5331 = getelementptr inbounds float, float* %2, i64 14
  store float %5330, float* %5331, align 4
  %5332 = extractelement <4 x float> %5327, i32 2
  %5333 = getelementptr inbounds float, float* %2, i64 14
  store float %5332, float* %5333, align 4
  %5334 = getelementptr inbounds float, float* %2, i64 14
  %5335 = load float, float* %5334, align 4
  %5336 = insertelement <4 x float> zeroinitializer, float %5335, i32 0
  %5337 = insertelement <4 x float> %5336, float 0.000000e+00, i32 1
  %5338 = insertelement <4 x float> %5337, float 0.000000e+00, i32 2
  %5339 = insertelement <4 x float> %5338, float 0.000000e+00, i32 3
  %5340 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5341 = getelementptr inbounds i8, i8* %5340, i64 52
  %5342 = bitcast i8* %5341 to float*
  %5343 = load float, float* %5342, align 4
  %5344 = insertelement <4 x float> zeroinitializer, float %5343, i32 0
  %5345 = insertelement <4 x float> %5344, float 0.000000e+00, i32 1
  %5346 = insertelement <4 x float> %5345, float 0.000000e+00, i32 2
  %5347 = insertelement <4 x float> %5346, float 0.000000e+00, i32 3
  %5348 = getelementptr inbounds float, float* %0, i64 6
  %5349 = load float, float* %5348, align 4
  %5350 = insertelement <4 x float> zeroinitializer, float %5349, i32 0
  %5351 = insertelement <4 x float> %5350, float 0.000000e+00, i32 1
  %5352 = insertelement <4 x float> %5351, float 0.000000e+00, i32 2
  %5353 = insertelement <4 x float> %5352, float 0.000000e+00, i32 3
  %5354 = call <4 x float> @llvm.fma.f32.116(<4 x float> %5347, <4 x float> %5353, <4 x float> %5339)
  %5355 = extractelement <4 x float> %5354, i32 0
  %5356 = getelementptr inbounds float, float* %2, i64 14
  store float %5355, float* %5356, align 4
  %5357 = getelementptr inbounds float, float* %2, i64 14
  %5358 = load float, float* %5357, align 4
  %5359 = insertelement <4 x float> zeroinitializer, float %5358, i32 0
  %5360 = insertelement <4 x float> %5359, float 0.000000e+00, i32 1
  %5361 = insertelement <4 x float> %5360, float 0.000000e+00, i32 2
  %5362 = insertelement <4 x float> %5361, float 0.000000e+00, i32 3
  %5363 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5364 = getelementptr inbounds i8, i8* %5363, i64 56
  %5365 = bitcast i8* %5364 to float*
  %5366 = load float, float* %5365, align 4
  %5367 = insertelement <4 x float> zeroinitializer, float %5366, i32 0
  %5368 = insertelement <4 x float> %5367, float 0.000000e+00, i32 1
  %5369 = insertelement <4 x float> %5368, float 0.000000e+00, i32 2
  %5370 = insertelement <4 x float> %5369, float 0.000000e+00, i32 3
  %5371 = getelementptr inbounds float, float* %0, i64 10
  %5372 = load float, float* %5371, align 4
  %5373 = insertelement <4 x float> zeroinitializer, float %5372, i32 0
  %5374 = insertelement <4 x float> %5373, float 0.000000e+00, i32 1
  %5375 = insertelement <4 x float> %5374, float 0.000000e+00, i32 2
  %5376 = insertelement <4 x float> %5375, float 0.000000e+00, i32 3
  %5377 = call <4 x float> @llvm.fma.f32.117(<4 x float> %5370, <4 x float> %5376, <4 x float> %5362)
  %5378 = extractelement <4 x float> %5377, i32 0
  %5379 = getelementptr inbounds float, float* %2, i64 14
  store float %5378, float* %5379, align 4
  %5380 = getelementptr inbounds float, float* %2, i64 14
  %5381 = load float, float* %5380, align 4
  %5382 = insertelement <4 x float> zeroinitializer, float %5381, i32 0
  %5383 = insertelement <4 x float> %5382, float 0.000000e+00, i32 1
  %5384 = insertelement <4 x float> %5383, float 0.000000e+00, i32 2
  %5385 = insertelement <4 x float> %5384, float 0.000000e+00, i32 3
  %5386 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5387 = getelementptr inbounds i8, i8* %5386, i64 60
  %5388 = bitcast i8* %5387 to float*
  %5389 = load float, float* %5388, align 4
  %5390 = insertelement <4 x float> zeroinitializer, float %5389, i32 0
  %5391 = insertelement <4 x float> %5390, float 0.000000e+00, i32 1
  %5392 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5393 = getelementptr inbounds i8, i8* %5392, i64 48
  %5394 = bitcast i8* %5393 to float*
  %5395 = load float, float* %5394, align 4
  %5396 = insertelement <4 x float> %5391, float %5395, i32 2
  %5397 = insertelement <4 x float> %5396, float 0.000000e+00, i32 3
  %5398 = getelementptr inbounds float, float* %0, i64 14
  %5399 = load float, float* %5398, align 4
  %5400 = insertelement <4 x float> zeroinitializer, float %5399, i32 0
  %5401 = insertelement <4 x float> %5400, float 0.000000e+00, i32 1
  %5402 = getelementptr inbounds float, float* %0, i64 3
  %5403 = load float, float* %5402, align 4
  %5404 = insertelement <4 x float> %5401, float %5403, i32 2
  %5405 = insertelement <4 x float> %5404, float 0.000000e+00, i32 3
  %5406 = call <4 x float> @llvm.fma.f32.118(<4 x float> %5397, <4 x float> %5405, <4 x float> %5385)
  %5407 = extractelement <4 x float> %5406, i32 0
  %5408 = getelementptr inbounds float, float* %2, i64 14
  store float %5407, float* %5408, align 4
  %5409 = extractelement <4 x float> %5406, i32 1
  %5410 = getelementptr inbounds float, float* %2, i64 15
  store float %5409, float* %5410, align 4
  %5411 = extractelement <4 x float> %5406, i32 2
  %5412 = getelementptr inbounds float, float* %2, i64 15
  store float %5411, float* %5412, align 4
  %5413 = getelementptr inbounds float, float* %2, i64 15
  %5414 = load float, float* %5413, align 4
  %5415 = insertelement <4 x float> zeroinitializer, float %5414, i32 0
  %5416 = insertelement <4 x float> %5415, float 0.000000e+00, i32 1
  %5417 = insertelement <4 x float> %5416, float 0.000000e+00, i32 2
  %5418 = insertelement <4 x float> %5417, float 0.000000e+00, i32 3
  %5419 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5420 = getelementptr inbounds i8, i8* %5419, i64 52
  %5421 = bitcast i8* %5420 to float*
  %5422 = load float, float* %5421, align 4
  %5423 = insertelement <4 x float> zeroinitializer, float %5422, i32 0
  %5424 = insertelement <4 x float> %5423, float 0.000000e+00, i32 1
  %5425 = insertelement <4 x float> %5424, float 0.000000e+00, i32 2
  %5426 = insertelement <4 x float> %5425, float 0.000000e+00, i32 3
  %5427 = getelementptr inbounds float, float* %0, i64 7
  %5428 = load float, float* %5427, align 4
  %5429 = insertelement <4 x float> zeroinitializer, float %5428, i32 0
  %5430 = insertelement <4 x float> %5429, float 0.000000e+00, i32 1
  %5431 = insertelement <4 x float> %5430, float 0.000000e+00, i32 2
  %5432 = insertelement <4 x float> %5431, float 0.000000e+00, i32 3
  %5433 = call <4 x float> @llvm.fma.f32.119(<4 x float> %5426, <4 x float> %5432, <4 x float> %5418)
  %5434 = extractelement <4 x float> %5433, i32 0
  %5435 = getelementptr inbounds float, float* %2, i64 15
  store float %5434, float* %5435, align 4
  %5436 = getelementptr inbounds float, float* %2, i64 15
  %5437 = load float, float* %5436, align 4
  %5438 = insertelement <4 x float> zeroinitializer, float %5437, i32 0
  %5439 = insertelement <4 x float> %5438, float 0.000000e+00, i32 1
  %5440 = insertelement <4 x float> %5439, float 0.000000e+00, i32 2
  %5441 = insertelement <4 x float> %5440, float 0.000000e+00, i32 3
  %5442 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5443 = getelementptr inbounds i8, i8* %5442, i64 56
  %5444 = bitcast i8* %5443 to float*
  %5445 = load float, float* %5444, align 4
  %5446 = insertelement <4 x float> zeroinitializer, float %5445, i32 0
  %5447 = insertelement <4 x float> %5446, float 0.000000e+00, i32 1
  %5448 = insertelement <4 x float> %5447, float 0.000000e+00, i32 2
  %5449 = insertelement <4 x float> %5448, float 0.000000e+00, i32 3
  %5450 = getelementptr inbounds float, float* %0, i64 11
  %5451 = load float, float* %5450, align 4
  %5452 = insertelement <4 x float> zeroinitializer, float %5451, i32 0
  %5453 = insertelement <4 x float> %5452, float 0.000000e+00, i32 1
  %5454 = insertelement <4 x float> %5453, float 0.000000e+00, i32 2
  %5455 = insertelement <4 x float> %5454, float 0.000000e+00, i32 3
  %5456 = call <4 x float> @llvm.fma.f32.120(<4 x float> %5449, <4 x float> %5455, <4 x float> %5441)
  %5457 = extractelement <4 x float> %5456, i32 0
  %5458 = getelementptr inbounds float, float* %2, i64 15
  store float %5457, float* %5458, align 4
  %5459 = getelementptr inbounds float, float* %2, i64 15
  %5460 = load float, float* %5459, align 4
  %5461 = insertelement <4 x float> zeroinitializer, float %5460, i32 0
  %5462 = insertelement <4 x float> %5461, float 0.000000e+00, i32 1
  %5463 = insertelement <4 x float> %5462, float 0.000000e+00, i32 2
  %5464 = insertelement <4 x float> %5463, float 0.000000e+00, i32 3
  %5465 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5466 = getelementptr inbounds i8, i8* %5465, i64 60
  %5467 = bitcast i8* %5466 to float*
  %5468 = load float, float* %5467, align 4
  %5469 = insertelement <4 x float> zeroinitializer, float %5468, i32 0
  %5470 = insertelement <4 x float> %5469, float 1.000000e+00, i32 1
  %5471 = insertelement <4 x float> %5470, float 1.000000e+00, i32 2
  %5472 = insertelement <4 x float> %5471, float 1.000000e+00, i32 3
  %5473 = getelementptr inbounds float, float* %0, i64 15
  %5474 = load float, float* %5473, align 4
  %5475 = insertelement <4 x float> zeroinitializer, float %5474, i32 0
  %5476 = getelementptr inbounds float, float* %2, i64 5
  %5477 = bitcast float* %5476 to i32*
  %5478 = load i32, i32* %5477, align 4
  %5479 = sitofp i32 %5478 to float
  %5480 = insertelement <4 x float> %5475, float %5479, i32 1
  %5481 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5482 = getelementptr inbounds i8, i8* %5481, i64 20
  %5483 = bitcast i8* %5482 to i32*
  %5484 = load i32, i32* %5483, align 4
  %5485 = sitofp i32 %5484 to float
  %5486 = insertelement <4 x float> %5480, float %5485, i32 2
  %5487 = getelementptr inbounds float, float* %2, i64 9
  %5488 = bitcast float* %5487 to i32*
  %5489 = load i32, i32* %5488, align 4
  %5490 = sitofp i32 %5489 to float
  %5491 = insertelement <4 x float> %5486, float %5490, i32 3
  %5492 = call <4 x float> @llvm.fma.f32.121(<4 x float> %5472, <4 x float> %5491, <4 x float> %5464)
  %5493 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5494 = bitcast i8* %5493 to float*
  %5495 = load float, float* %5494, align 4
  %5496 = insertelement <4 x float> zeroinitializer, float %5495, i32 3
  %5497 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5498 = bitcast i8* %5497 to float*
  %5499 = load float, float* %5498, align 4
  %5500 = fcmp olt float %5499, 0.000000e+00
  %5501 = sext i1 %5500 to i32
  %5502 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5503 = bitcast i8* %5502 to float*
  %5504 = load float, float* %5503, align 4
  %5505 = fcmp ogt float %5504, 0.000000e+00
  %5506 = zext i1 %5505 to i32
  %5507 = add nsw i32 %5501, %5506
  %5508 = sitofp i32 %5507 to float
  %5509 = fneg float %5508
  %5510 = fmul float %973, %5509
  %5511 = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 0.000000e+00>, float %5510, i32 3
  %5512 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5513 = getelementptr inbounds i8, i8* %5512, i64 36
  %5514 = bitcast i8* %5513 to i32*
  %5515 = load i32, i32* %5514, align 4
  %5516 = sitofp i32 %5515 to float
  %5517 = insertelement <4 x float> zeroinitializer, float %5516, i32 0
  %5518 = getelementptr inbounds float, float* %2, i64 13
  %5519 = bitcast float* %5518 to i32*
  %5520 = load i32, i32* %5519, align 4
  %5521 = sitofp i32 %5520 to float
  %5522 = insertelement <4 x float> %5517, float %5521, i32 1
  %5523 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5524 = getelementptr inbounds i8, i8* %5523, i64 52
  %5525 = bitcast i8* %5524 to i32*
  %5526 = load i32, i32* %5525, align 4
  %5527 = sitofp i32 %5526 to float
  %5528 = insertelement <4 x float> %5522, float %5527, i32 2
  %5529 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5530 = bitcast i8* %5529 to float*
  %5531 = load float, float* %5530, align 4
  %5532 = insertelement <4 x float> %5528, float %5531, i32 3
  %5533 = call <4 x float> @llvm.fma.f32.122(<4 x float> %5511, <4 x float> %5532, <4 x float> %5496)
  %5534 = shufflevector <4 x float> %5492, <4 x float> %5533, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %5535 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5536 = getelementptr inbounds i8, i8* %5535, i64 4
  %5537 = bitcast i8* %5536 to float*
  %5538 = load float, float* %5537, align 4
  %5539 = insertelement <4 x float> zeroinitializer, float %5538, i32 0
  %5540 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5541 = getelementptr inbounds i8, i8* %5540, i64 8
  %5542 = bitcast i8* %5541 to float*
  %5543 = load float, float* %5542, align 4
  %5544 = insertelement <4 x float> %5539, float %5543, i32 1
  %5545 = insertelement <4 x float> %5544, float 0.000000e+00, i32 2
  %5546 = insertelement <4 x float> %5545, float 0.000000e+00, i32 3
  %5547 = insertelement <4 x float> zeroinitializer, float %973, i32 0
  %5548 = insertelement <4 x float> %5547, float %973, i32 1
  %5549 = insertelement <4 x float> %5548, float 1.000000e+00, i32 2
  %5550 = insertelement <4 x float> %5549, float 1.000000e+00, i32 3
  %5551 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5552 = bitcast i8* %5551 to float*
  %5553 = load float, float* %5552, align 4
  %5554 = fcmp olt float %5553, 0.000000e+00
  %5555 = sext i1 %5554 to i32
  %5556 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5557 = bitcast i8* %5556 to float*
  %5558 = load float, float* %5557, align 4
  %5559 = fcmp ogt float %5558, 0.000000e+00
  %5560 = zext i1 %5559 to i32
  %5561 = add nsw i32 %5555, %5560
  %5562 = sitofp i32 %5561 to float
  %5563 = insertelement <4 x float> zeroinitializer, float %5562, i32 0
  %5564 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5565 = bitcast i8* %5564 to float*
  %5566 = load float, float* %5565, align 4
  %5567 = fcmp olt float %5566, 0.000000e+00
  %5568 = sext i1 %5567 to i32
  %5569 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5570 = bitcast i8* %5569 to float*
  %5571 = load float, float* %5570, align 4
  %5572 = fcmp ogt float %5571, 0.000000e+00
  %5573 = zext i1 %5572 to i32
  %5574 = add nsw i32 %5568, %5573
  %5575 = sitofp i32 %5574 to float
  %5576 = insertelement <4 x float> %5563, float %5575, i32 1
  %5577 = insertelement <4 x float> %5576, float 0.000000e+00, i32 2
  %5578 = insertelement <4 x float> %5577, float 0.000000e+00, i32 3
  %5579 = fneg <4 x float> %5578
  %5580 = fmul <4 x float> %5550, %5579
  %5581 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5582 = getelementptr inbounds i8, i8* %5581, i64 4
  %5583 = bitcast i8* %5582 to float*
  %5584 = load float, float* %5583, align 4
  %5585 = insertelement <4 x float> zeroinitializer, float %5584, i32 0
  %5586 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5587 = getelementptr inbounds i8, i8* %5586, i64 8
  %5588 = bitcast i8* %5587 to float*
  %5589 = load float, float* %5588, align 4
  %5590 = insertelement <4 x float> %5585, float %5589, i32 1
  %5591 = insertelement <4 x float> %5590, float 0.000000e+00, i32 2
  %5592 = insertelement <4 x float> %5591, float 0.000000e+00, i32 3
  %5593 = call <4 x float> @llvm.fma.f32.123(<4 x float> %5580, <4 x float> %5592, <4 x float> %5546)
  %5594 = shufflevector <4 x float> %5593, <4 x float> zeroinitializer, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %5595 = shufflevector <8 x float> %5534, <8 x float> %5594, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %5596 = extractelement <16 x float> %5595, i32 0
  %5597 = getelementptr inbounds float, float* %2, i64 15
  store float %5596, float* %5597, align 4
  %5598 = extractelement <16 x float> %5595, i32 1
  %5599 = fptosi float %5598 to i32
  %5600 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5601 = bitcast i8* %5600 to i32*
  store i32 %5599, i32* %5601, align 4
  %5602 = extractelement <16 x float> %5595, i32 2
  %5603 = fptosi float %5602 to i32
  %5604 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5605 = bitcast i8* %5604 to i32*
  store i32 %5603, i32* %5605, align 4
  %5606 = extractelement <16 x float> %5595, i32 3
  %5607 = fptosi float %5606 to i32
  %5608 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5609 = getelementptr inbounds i8, i8* %5608, i64 4
  %5610 = bitcast i8* %5609 to i32*
  store i32 %5607, i32* %5610, align 4
  %5611 = extractelement <16 x float> %5595, i32 4
  %5612 = fptosi float %5611 to i32
  %5613 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5614 = getelementptr inbounds i8, i8* %5613, i64 4
  %5615 = bitcast i8* %5614 to i32*
  store i32 %5612, i32* %5615, align 4
  %5616 = extractelement <16 x float> %5595, i32 5
  %5617 = fptosi float %5616 to i32
  %5618 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5619 = getelementptr inbounds i8, i8* %5618, i64 8
  %5620 = bitcast i8* %5619 to i32*
  store i32 %5617, i32* %5620, align 4
  %5621 = extractelement <16 x float> %5595, i32 6
  %5622 = fptosi float %5621 to i32
  %5623 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5624 = getelementptr inbounds i8, i8* %5623, i64 8
  %5625 = bitcast i8* %5624 to i32*
  store i32 %5622, i32* %5625, align 4
  %5626 = extractelement <16 x float> %5595, i32 7
  %5627 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5628 = bitcast i8* %5627 to float*
  store float %5626, float* %5628, align 4
  %5629 = extractelement <16 x float> %5595, i32 8
  %5630 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5631 = getelementptr inbounds i8, i8* %5630, i64 4
  %5632 = bitcast i8* %5631 to float*
  store float %5629, float* %5632, align 4
  %5633 = extractelement <16 x float> %5595, i32 9
  %5634 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5635 = getelementptr inbounds i8, i8* %5634, i64 8
  %5636 = bitcast i8* %5635 to float*
  store float %5633, float* %5636, align 4
  %5637 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5638 = bitcast i8* %5637 to float*
  %5639 = load float, float* %5638, align 4
  %5640 = insertelement <4 x float> zeroinitializer, float %5639, i32 0
  %5641 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5642 = getelementptr inbounds i8, i8* %5641, i64 4
  %5643 = bitcast i8* %5642 to float*
  %5644 = load float, float* %5643, align 4
  %5645 = insertelement <4 x float> %5640, float %5644, i32 1
  %5646 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5647 = getelementptr inbounds i8, i8* %5646, i64 8
  %5648 = bitcast i8* %5647 to float*
  %5649 = load float, float* %5648, align 4
  %5650 = insertelement <4 x float> %5645, float %5649, i32 2
  %5651 = insertelement <4 x float> %5650, float 0.000000e+00, i32 3
  %5652 = insertelement <4 x float> zeroinitializer, float %1021, i32 0
  %5653 = insertelement <4 x float> %5652, float %1021, i32 1
  %5654 = insertelement <4 x float> %5653, float %1021, i32 2
  %5655 = insertelement <4 x float> %5654, float 1.000000e+00, i32 3
  %5656 = fdiv <4 x float> %5651, %5655
  %5657 = extractelement <4 x float> %5656, i32 0
  %5658 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5659 = bitcast i8* %5658 to float*
  store float %5657, float* %5659, align 4
  %5660 = extractelement <4 x float> %5656, i32 1
  %5661 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5662 = getelementptr inbounds i8, i8* %5661, i64 4
  %5663 = bitcast i8* %5662 to float*
  store float %5660, float* %5663, align 4
  %5664 = extractelement <4 x float> %5656, i32 2
  %5665 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5666 = getelementptr inbounds i8, i8* %5665, i64 8
  %5667 = bitcast i8* %5666 to float*
  store float %5664, float* %5667, align 4
  %5668 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5669 = bitcast i8* %5668 to float*
  %5670 = load float, float* %5669, align 4
  %5671 = insertelement <4 x float> zeroinitializer, float %5670, i32 0
  %5672 = insertelement <4 x float> %5671, float 1.000000e+00, i32 1
  %5673 = insertelement <4 x float> %5672, float 1.000000e+00, i32 2
  %5674 = insertelement <4 x float> %5673, float 1.000000e+00, i32 3
  %5675 = fmul <4 x float> %5674, <float 2.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00>
  %5676 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5677 = bitcast i8* %5676 to float*
  %5678 = load float, float* %5677, align 4
  %5679 = insertelement <4 x float> zeroinitializer, float %5678, i32 0
  %5680 = insertelement <4 x float> %5679, float 0.000000e+00, i32 1
  %5681 = insertelement <4 x float> %5680, float 0.000000e+00, i32 2
  %5682 = insertelement <4 x float> %5681, float 0.000000e+00, i32 3
  %5683 = fmul <4 x float> %5675, %5682
  %5684 = fsub <4 x float> <float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, %5683
  %5685 = extractelement <4 x float> %5684, i32 0
  %5686 = call dereferenceable_or_null(36) i8* @calloc(i64 4, i64 9) #10
  %5687 = bitcast i8* %5686 to float*
  store float %5685, float* %5687, align 4
  %5688 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5689 = bitcast i8* %5688 to float*
  %5690 = load float, float* %5689, align 4
  %5691 = insertelement <4 x float> zeroinitializer, float %5690, i32 0
  %5692 = insertelement <4 x float> %5691, float 1.000000e+00, i32 1
  %5693 = insertelement <4 x float> %5692, float 1.000000e+00, i32 2
  %5694 = insertelement <4 x float> %5693, float 1.000000e+00, i32 3
  %5695 = fmul <4 x float> %5694, <float 2.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00>
  %5696 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5697 = getelementptr inbounds i8, i8* %5696, i64 4
  %5698 = bitcast i8* %5697 to float*
  %5699 = load float, float* %5698, align 4
  %5700 = insertelement <4 x float> zeroinitializer, float %5699, i32 0
  %5701 = insertelement <4 x float> %5700, float 0.000000e+00, i32 1
  %5702 = insertelement <4 x float> %5701, float 0.000000e+00, i32 2
  %5703 = insertelement <4 x float> %5702, float 0.000000e+00, i32 3
  %5704 = fmul <4 x float> %5695, %5703
  %5705 = fsub <4 x float> zeroinitializer, %5704
  %5706 = extractelement <4 x float> %5705, i32 0
  %5707 = call dereferenceable_or_null(36) i8* @calloc(i64 4, i64 9) #10
  %5708 = getelementptr inbounds i8, i8* %5707, i64 4
  %5709 = bitcast i8* %5708 to float*
  store float %5706, float* %5709, align 4
  %5710 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5711 = bitcast i8* %5710 to float*
  %5712 = load float, float* %5711, align 4
  %5713 = insertelement <4 x float> zeroinitializer, float %5712, i32 0
  %5714 = insertelement <4 x float> %5713, float 1.000000e+00, i32 1
  %5715 = insertelement <4 x float> %5714, float 1.000000e+00, i32 2
  %5716 = insertelement <4 x float> %5715, float 1.000000e+00, i32 3
  %5717 = fmul <4 x float> %5716, <float 2.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00>
  %5718 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5719 = getelementptr inbounds i8, i8* %5718, i64 8
  %5720 = bitcast i8* %5719 to float*
  %5721 = load float, float* %5720, align 4
  %5722 = insertelement <4 x float> zeroinitializer, float %5721, i32 0
  %5723 = insertelement <4 x float> %5722, float 0.000000e+00, i32 1
  %5724 = insertelement <4 x float> %5723, float 0.000000e+00, i32 2
  %5725 = insertelement <4 x float> %5724, float 0.000000e+00, i32 3
  %5726 = fmul <4 x float> %5717, %5725
  %5727 = fsub <4 x float> zeroinitializer, %5726
  %5728 = extractelement <4 x float> %5727, i32 0
  %5729 = call dereferenceable_or_null(36) i8* @calloc(i64 4, i64 9) #10
  %5730 = getelementptr inbounds i8, i8* %5729, i64 8
  %5731 = bitcast i8* %5730 to float*
  store float %5728, float* %5731, align 4
  %5732 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5733 = getelementptr inbounds i8, i8* %5732, i64 4
  %5734 = bitcast i8* %5733 to float*
  %5735 = load float, float* %5734, align 4
  %5736 = insertelement <4 x float> zeroinitializer, float %5735, i32 0
  %5737 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5738 = getelementptr inbounds i8, i8* %5737, i64 4
  %5739 = bitcast i8* %5738 to float*
  %5740 = load float, float* %5739, align 4
  %5741 = insertelement <4 x float> %5736, float %5740, i32 1
  %5742 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5743 = getelementptr inbounds i8, i8* %5742, i64 4
  %5744 = bitcast i8* %5743 to float*
  %5745 = load float, float* %5744, align 4
  %5746 = insertelement <4 x float> %5741, float %5745, i32 2
  %5747 = insertelement <4 x float> %5746, float 1.000000e+00, i32 3
  %5748 = fmul <4 x float> %5747, <float 2.000000e+00, float 2.000000e+00, float 2.000000e+00, float 1.000000e+00>
  %5749 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5750 = bitcast i8* %5749 to float*
  %5751 = load float, float* %5750, align 4
  %5752 = insertelement <4 x float> zeroinitializer, float %5751, i32 0
  %5753 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5754 = getelementptr inbounds i8, i8* %5753, i64 4
  %5755 = bitcast i8* %5754 to float*
  %5756 = load float, float* %5755, align 4
  %5757 = insertelement <4 x float> %5752, float %5756, i32 1
  %5758 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5759 = getelementptr inbounds i8, i8* %5758, i64 8
  %5760 = bitcast i8* %5759 to float*
  %5761 = load float, float* %5760, align 4
  %5762 = insertelement <4 x float> %5757, float %5761, i32 2
  %5763 = insertelement <4 x float> %5762, float 0.000000e+00, i32 3
  %5764 = fmul <4 x float> %5748, %5763
  %5765 = fsub <4 x float> <float 0.000000e+00, float 1.000000e+00, float 0.000000e+00, float 0.000000e+00>, %5764
  %5766 = extractelement <4 x float> %5765, i32 0
  %5767 = call dereferenceable_or_null(36) i8* @calloc(i64 4, i64 9) #10
  %5768 = getelementptr inbounds i8, i8* %5767, i64 12
  %5769 = bitcast i8* %5768 to float*
  store float %5766, float* %5769, align 4
  %5770 = extractelement <4 x float> %5765, i32 1
  %5771 = call dereferenceable_or_null(36) i8* @calloc(i64 4, i64 9) #10
  %5772 = getelementptr inbounds i8, i8* %5771, i64 16
  %5773 = bitcast i8* %5772 to float*
  store float %5770, float* %5773, align 4
  %5774 = extractelement <4 x float> %5765, i32 2
  %5775 = call dereferenceable_or_null(36) i8* @calloc(i64 4, i64 9) #10
  %5776 = getelementptr inbounds i8, i8* %5775, i64 20
  %5777 = bitcast i8* %5776 to float*
  store float %5774, float* %5777, align 4
  %5778 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5779 = getelementptr inbounds i8, i8* %5778, i64 8
  %5780 = bitcast i8* %5779 to float*
  %5781 = load float, float* %5780, align 4
  %5782 = fmul float %5781, 2.000000e+00
  %5783 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5784 = bitcast i8* %5783 to float*
  %5785 = load float, float* %5784, align 4
  %5786 = fmul float %5782, %5785
  %5787 = fsub float 0.000000e+00, %5786
  %5788 = insertelement <4 x float> zeroinitializer, float %5787, i32 0
  %5789 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5790 = getelementptr inbounds i8, i8* %5789, i64 8
  %5791 = bitcast i8* %5790 to float*
  %5792 = load float, float* %5791, align 4
  %5793 = fmul float %5792, 2.000000e+00
  %5794 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5795 = getelementptr inbounds i8, i8* %5794, i64 4
  %5796 = bitcast i8* %5795 to float*
  %5797 = load float, float* %5796, align 4
  %5798 = fmul float %5793, %5797
  %5799 = fsub float 0.000000e+00, %5798
  %5800 = insertelement <4 x float> %5788, float %5799, i32 1
  %5801 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5802 = getelementptr inbounds i8, i8* %5801, i64 8
  %5803 = bitcast i8* %5802 to float*
  %5804 = load float, float* %5803, align 4
  %5805 = fmul float %5804, 2.000000e+00
  %5806 = call dereferenceable_or_null(12) i8* @calloc(i64 4, i64 3) #10
  %5807 = getelementptr inbounds i8, i8* %5806, i64 8
  %5808 = bitcast i8* %5807 to float*
  %5809 = load float, float* %5808, align 4
  %5810 = fmul float %5805, %5809
  %5811 = fsub float 1.000000e+00, %5810
  %5812 = insertelement <4 x float> %5800, float %5811, i32 2
  %5813 = insertelement <4 x float> %5812, float 1.000000e+00, i32 3
  %5814 = shufflevector <4 x float> %5813, <4 x float> zeroinitializer, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %5815 = call dereferenceable_or_null(36) i8* @calloc(i64 4, i64 9) #10
  %5816 = bitcast i8* %5815 to i32*
  %5817 = load i32, i32* %5816, align 4
  %5818 = sitofp i32 %5817 to float
  %5819 = insertelement <4 x float> zeroinitializer, float %5818, i32 0
  %5820 = call dereferenceable_or_null(36) i8* @calloc(i64 4, i64 9) #10
  %5821 = getelementptr inbounds i8, i8* %5820, i64 4
  %5822 = bitcast i8* %5821 to i32*
  %5823 = load i32, i32* %5822, align 4
  %5824 = sitofp i32 %5823 to float
  %5825 = insertelement <4 x float> %5819, float %5824, i32 1
  %5826 = call dereferenceable_or_null(36) i8* @calloc(i64 4, i64 9) #10
  %5827 = getelementptr inbounds i8, i8* %5826, i64 8
  %5828 = bitcast i8* %5827 to i32*
  %5829 = load i32, i32* %5828, align 4
  %5830 = sitofp i32 %5829 to float
  %5831 = insertelement <4 x float> %5825, float %5830, i32 2
  %5832 = insertelement <4 x float> %5831, float 0.000000e+00, i32 3
  %5833 = call dereferenceable_or_null(36) i8* @calloc(i64 4, i64 9) #10
  %5834 = getelementptr inbounds i8, i8* %5833, i64 12
  %5835 = bitcast i8* %5834 to i32*
  %5836 = load i32, i32* %5835, align 4
  %5837 = sitofp i32 %5836 to float
  %5838 = insertelement <4 x float> zeroinitializer, float %5837, i32 0
  %5839 = call dereferenceable_or_null(36) i8* @calloc(i64 4, i64 9) #10
  %5840 = getelementptr inbounds i8, i8* %5839, i64 16
  %5841 = bitcast i8* %5840 to i32*
  %5842 = load i32, i32* %5841, align 4
  %5843 = sitofp i32 %5842 to float
  %5844 = insertelement <4 x float> %5838, float %5843, i32 1
  %5845 = call dereferenceable_or_null(36) i8* @calloc(i64 4, i64 9) #10
  %5846 = getelementptr inbounds i8, i8* %5845, i64 20
  %5847 = bitcast i8* %5846 to i32*
  %5848 = load i32, i32* %5847, align 4
  %5849 = sitofp i32 %5848 to float
  %5850 = insertelement <4 x float> %5844, float %5849, i32 2
  %5851 = insertelement <4 x float> %5850, float 0.000000e+00, i32 3
  %5852 = shufflevector <4 x float> %5832, <4 x float> %5851, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %5853 = shufflevector <8 x float> %5814, <8 x float> %5852, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %5854 = call dereferenceable_or_null(36) i8* @calloc(i64 4, i64 9) #10
  %5855 = getelementptr inbounds i8, i8* %5854, i64 24
  %5856 = bitcast i8* %5855 to i32*
  %5857 = load i32, i32* %5856, align 4
  %5858 = sitofp i32 %5857 to float
  %5859 = insertelement <4 x float> zeroinitializer, float %5858, i32 0
  %5860 = call dereferenceable_or_null(36) i8* @calloc(i64 4, i64 9) #10
  %5861 = getelementptr inbounds i8, i8* %5860, i64 28
  %5862 = bitcast i8* %5861 to i32*
  %5863 = load i32, i32* %5862, align 4
  %5864 = sitofp i32 %5863 to float
  %5865 = insertelement <4 x float> %5859, float %5864, i32 1
  %5866 = call dereferenceable_or_null(36) i8* @calloc(i64 4, i64 9) #10
  %5867 = getelementptr inbounds i8, i8* %5866, i64 32
  %5868 = bitcast i8* %5867 to i32*
  %5869 = load i32, i32* %5868, align 4
  %5870 = sitofp i32 %5869 to float
  %5871 = insertelement <4 x float> %5865, float %5870, i32 2
  %5872 = insertelement <4 x float> %5871, float 0.000000e+00, i32 3
  %5873 = shufflevector <4 x float> %5872, <4 x float> zeroinitializer, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %5874 = shufflevector <8 x float> %5873, <8 x float> zeroinitializer, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %5875 = shufflevector <16 x float> %5853, <16 x float> %5874, <32 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31>
  %5876 = extractelement <32 x float> %5875, i32 0
  %5877 = call dereferenceable_or_null(36) i8* @calloc(i64 4, i64 9) #10
  %5878 = getelementptr inbounds i8, i8* %5877, i64 24
  %5879 = bitcast i8* %5878 to float*
  store float %5876, float* %5879, align 4
  %5880 = extractelement <32 x float> %5875, i32 1
  %5881 = call dereferenceable_or_null(36) i8* @calloc(i64 4, i64 9) #10
  %5882 = getelementptr inbounds i8, i8* %5881, i64 28
  %5883 = bitcast i8* %5882 to float*
  store float %5880, float* %5883, align 4
  %5884 = extractelement <32 x float> %5875, i32 2
  %5885 = call dereferenceable_or_null(36) i8* @calloc(i64 4, i64 9) #10
  %5886 = getelementptr inbounds i8, i8* %5885, i64 32
  %5887 = bitcast i8* %5886 to float*
  store float %5884, float* %5887, align 4
  %5888 = extractelement <32 x float> %5875, i32 3
  %5889 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5890 = bitcast i8* %5889 to float*
  store float %5888, float* %5890, align 4
  %5891 = extractelement <32 x float> %5875, i32 4
  %5892 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5893 = getelementptr inbounds i8, i8* %5892, i64 4
  %5894 = bitcast i8* %5893 to float*
  store float %5891, float* %5894, align 4
  %5895 = extractelement <32 x float> %5875, i32 5
  %5896 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5897 = getelementptr inbounds i8, i8* %5896, i64 8
  %5898 = bitcast i8* %5897 to float*
  store float %5895, float* %5898, align 4
  %5899 = extractelement <32 x float> %5875, i32 6
  %5900 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5901 = getelementptr inbounds i8, i8* %5900, i64 12
  %5902 = bitcast i8* %5901 to float*
  store float %5899, float* %5902, align 4
  %5903 = extractelement <32 x float> %5875, i32 7
  %5904 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5905 = getelementptr inbounds i8, i8* %5904, i64 16
  %5906 = bitcast i8* %5905 to float*
  store float %5903, float* %5906, align 4
  %5907 = extractelement <32 x float> %5875, i32 8
  %5908 = fptosi float %5907 to i32
  %5909 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5910 = getelementptr inbounds i8, i8* %5909, i64 20
  %5911 = bitcast i8* %5910 to i32*
  store i32 %5908, i32* %5911, align 4
  %5912 = extractelement <32 x float> %5875, i32 9
  %5913 = fptosi float %5912 to i32
  %5914 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5915 = getelementptr inbounds i8, i8* %5914, i64 24
  %5916 = bitcast i8* %5915 to i32*
  store i32 %5913, i32* %5916, align 4
  %5917 = extractelement <32 x float> %5875, i32 10
  %5918 = fptosi float %5917 to i32
  %5919 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5920 = getelementptr inbounds i8, i8* %5919, i64 28
  %5921 = bitcast i8* %5920 to i32*
  store i32 %5918, i32* %5921, align 4
  %5922 = extractelement <32 x float> %5875, i32 11
  %5923 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5924 = getelementptr inbounds i8, i8* %5923, i64 32
  %5925 = bitcast i8* %5924 to float*
  store float %5922, float* %5925, align 4
  %5926 = extractelement <32 x float> %5875, i32 12
  %5927 = fptosi float %5926 to i32
  %5928 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5929 = getelementptr inbounds i8, i8* %5928, i64 36
  %5930 = bitcast i8* %5929 to i32*
  store i32 %5927, i32* %5930, align 4
  %5931 = extractelement <32 x float> %5875, i32 13
  %5932 = fptosi float %5931 to i32
  %5933 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5934 = getelementptr inbounds i8, i8* %5933, i64 40
  %5935 = bitcast i8* %5934 to i32*
  store i32 %5932, i32* %5935, align 4
  %5936 = extractelement <32 x float> %5875, i32 14
  %5937 = fptosi float %5936 to i32
  %5938 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5939 = getelementptr inbounds i8, i8* %5938, i64 44
  %5940 = bitcast i8* %5939 to i32*
  store i32 %5937, i32* %5940, align 4
  %5941 = extractelement <32 x float> %5875, i32 15
  %5942 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5943 = getelementptr inbounds i8, i8* %5942, i64 48
  %5944 = bitcast i8* %5943 to float*
  store float %5941, float* %5944, align 4
  %5945 = extractelement <32 x float> %5875, i32 16
  %5946 = fptosi float %5945 to i32
  %5947 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5948 = getelementptr inbounds i8, i8* %5947, i64 52
  %5949 = bitcast i8* %5948 to i32*
  store i32 %5946, i32* %5949, align 4
  %5950 = extractelement <32 x float> %5875, i32 17
  %5951 = fptosi float %5950 to i32
  %5952 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5953 = getelementptr inbounds i8, i8* %5952, i64 56
  %5954 = bitcast i8* %5953 to i32*
  store i32 %5951, i32* %5954, align 4
  %5955 = extractelement <32 x float> %5875, i32 18
  %5956 = fptosi float %5955 to i32
  %5957 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5958 = getelementptr inbounds i8, i8* %5957, i64 60
  %5959 = bitcast i8* %5958 to i32*
  store i32 %5956, i32* %5959, align 4
  %5960 = extractelement <32 x float> %5875, i32 19
  %5961 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5962 = bitcast i8* %5961 to float*
  store float %5960, float* %5962, align 4
  %5963 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5964 = bitcast i8* %5963 to float*
  %5965 = load float, float* %5964, align 4
  %5966 = insertelement <4 x float> zeroinitializer, float %5965, i32 0
  %5967 = insertelement <4 x float> %5966, float 0.000000e+00, i32 1
  %5968 = insertelement <4 x float> %5967, float 0.000000e+00, i32 2
  %5969 = insertelement <4 x float> %5968, float 0.000000e+00, i32 3
  %5970 = load float, float* %1, align 4
  %5971 = insertelement <4 x float> zeroinitializer, float %5970, i32 0
  %5972 = insertelement <4 x float> %5971, float 0.000000e+00, i32 1
  %5973 = insertelement <4 x float> %5972, float 0.000000e+00, i32 2
  %5974 = insertelement <4 x float> %5973, float 0.000000e+00, i32 3
  %5975 = call <4 x float> @llvm.fma.f32.124(<4 x float> %5969, <4 x float> %5974, <4 x float> zeroinitializer)
  %5976 = extractelement <4 x float> %5975, i32 0
  %5977 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5978 = bitcast i8* %5977 to float*
  store float %5976, float* %5978, align 4
  %5979 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5980 = bitcast i8* %5979 to float*
  %5981 = load float, float* %5980, align 4
  %5982 = insertelement <4 x float> zeroinitializer, float %5981, i32 0
  %5983 = insertelement <4 x float> %5982, float 0.000000e+00, i32 1
  %5984 = insertelement <4 x float> %5983, float 0.000000e+00, i32 2
  %5985 = insertelement <4 x float> %5984, float 0.000000e+00, i32 3
  %5986 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %5987 = getelementptr inbounds i8, i8* %5986, i64 4
  %5988 = bitcast i8* %5987 to float*
  %5989 = load float, float* %5988, align 4
  %5990 = insertelement <4 x float> zeroinitializer, float %5989, i32 0
  %5991 = insertelement <4 x float> %5990, float 0.000000e+00, i32 1
  %5992 = insertelement <4 x float> %5991, float 0.000000e+00, i32 2
  %5993 = insertelement <4 x float> %5992, float 0.000000e+00, i32 3
  %5994 = getelementptr inbounds float, float* %1, i64 4
  %5995 = load float, float* %5994, align 4
  %5996 = insertelement <4 x float> zeroinitializer, float %5995, i32 0
  %5997 = insertelement <4 x float> %5996, float 0.000000e+00, i32 1
  %5998 = insertelement <4 x float> %5997, float 0.000000e+00, i32 2
  %5999 = insertelement <4 x float> %5998, float 0.000000e+00, i32 3
  %6000 = call <4 x float> @llvm.fma.f32.125(<4 x float> %5993, <4 x float> %5999, <4 x float> %5985)
  %6001 = extractelement <4 x float> %6000, i32 0
  %6002 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6003 = bitcast i8* %6002 to float*
  store float %6001, float* %6003, align 4
  %6004 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6005 = bitcast i8* %6004 to float*
  %6006 = load float, float* %6005, align 4
  %6007 = insertelement <4 x float> zeroinitializer, float %6006, i32 0
  %6008 = insertelement <4 x float> %6007, float 0.000000e+00, i32 1
  %6009 = insertelement <4 x float> %6008, float 0.000000e+00, i32 2
  %6010 = insertelement <4 x float> %6009, float 0.000000e+00, i32 3
  %6011 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6012 = getelementptr inbounds i8, i8* %6011, i64 8
  %6013 = bitcast i8* %6012 to float*
  %6014 = load float, float* %6013, align 4
  %6015 = insertelement <4 x float> zeroinitializer, float %6014, i32 0
  %6016 = insertelement <4 x float> %6015, float 0.000000e+00, i32 1
  %6017 = insertelement <4 x float> %6016, float 0.000000e+00, i32 2
  %6018 = insertelement <4 x float> %6017, float 0.000000e+00, i32 3
  %6019 = getelementptr inbounds float, float* %1, i64 8
  %6020 = load float, float* %6019, align 4
  %6021 = insertelement <4 x float> zeroinitializer, float %6020, i32 0
  %6022 = insertelement <4 x float> %6021, float 0.000000e+00, i32 1
  %6023 = insertelement <4 x float> %6022, float 0.000000e+00, i32 2
  %6024 = insertelement <4 x float> %6023, float 0.000000e+00, i32 3
  %6025 = call <4 x float> @llvm.fma.f32.126(<4 x float> %6018, <4 x float> %6024, <4 x float> %6010)
  %6026 = extractelement <4 x float> %6025, i32 0
  %6027 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6028 = bitcast i8* %6027 to float*
  store float %6026, float* %6028, align 4
  %6029 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6030 = bitcast i8* %6029 to float*
  %6031 = load float, float* %6030, align 4
  %6032 = insertelement <4 x float> zeroinitializer, float %6031, i32 0
  %6033 = insertelement <4 x float> %6032, float 0.000000e+00, i32 1
  %6034 = insertelement <4 x float> %6033, float 0.000000e+00, i32 2
  %6035 = insertelement <4 x float> %6034, float 0.000000e+00, i32 3
  %6036 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6037 = getelementptr inbounds i8, i8* %6036, i64 12
  %6038 = bitcast i8* %6037 to float*
  %6039 = load float, float* %6038, align 4
  %6040 = insertelement <4 x float> zeroinitializer, float %6039, i32 0
  %6041 = insertelement <4 x float> %6040, float 0.000000e+00, i32 1
  %6042 = insertelement <4 x float> %6041, float 0.000000e+00, i32 2
  %6043 = insertelement <4 x float> %6042, float 0.000000e+00, i32 3
  %6044 = getelementptr inbounds float, float* %1, i64 12
  %6045 = load float, float* %6044, align 4
  %6046 = insertelement <4 x float> zeroinitializer, float %6045, i32 0
  %6047 = insertelement <4 x float> %6046, float 0.000000e+00, i32 1
  %6048 = insertelement <4 x float> %6047, float 0.000000e+00, i32 2
  %6049 = insertelement <4 x float> %6048, float 0.000000e+00, i32 3
  %6050 = call <4 x float> @llvm.fma.f32.127(<4 x float> %6043, <4 x float> %6049, <4 x float> %6035)
  %6051 = extractelement <4 x float> %6050, i32 0
  %6052 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6053 = bitcast i8* %6052 to float*
  store float %6051, float* %6053, align 4
  %6054 = extractelement <4 x float> %6050, i32 1
  %6055 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6056 = getelementptr inbounds i8, i8* %6055, i64 4
  %6057 = bitcast i8* %6056 to float*
  store float %6054, float* %6057, align 4
  %6058 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6059 = getelementptr inbounds i8, i8* %6058, i64 4
  %6060 = bitcast i8* %6059 to float*
  %6061 = load float, float* %6060, align 4
  %6062 = insertelement <4 x float> zeroinitializer, float %6061, i32 0
  %6063 = insertelement <4 x float> %6062, float 0.000000e+00, i32 1
  %6064 = insertelement <4 x float> %6063, float 0.000000e+00, i32 2
  %6065 = insertelement <4 x float> %6064, float 0.000000e+00, i32 3
  %6066 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6067 = bitcast i8* %6066 to float*
  %6068 = load float, float* %6067, align 4
  %6069 = insertelement <4 x float> zeroinitializer, float %6068, i32 0
  %6070 = insertelement <4 x float> %6069, float 0.000000e+00, i32 1
  %6071 = insertelement <4 x float> %6070, float 0.000000e+00, i32 2
  %6072 = insertelement <4 x float> %6071, float 0.000000e+00, i32 3
  %6073 = getelementptr inbounds float, float* %1, i64 1
  %6074 = load float, float* %6073, align 4
  %6075 = insertelement <4 x float> zeroinitializer, float %6074, i32 0
  %6076 = insertelement <4 x float> %6075, float 0.000000e+00, i32 1
  %6077 = insertelement <4 x float> %6076, float 0.000000e+00, i32 2
  %6078 = insertelement <4 x float> %6077, float 0.000000e+00, i32 3
  %6079 = call <4 x float> @llvm.fma.f32.128(<4 x float> %6072, <4 x float> %6078, <4 x float> %6065)
  %6080 = extractelement <4 x float> %6079, i32 0
  %6081 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6082 = getelementptr inbounds i8, i8* %6081, i64 4
  %6083 = bitcast i8* %6082 to float*
  store float %6080, float* %6083, align 4
  %6084 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6085 = getelementptr inbounds i8, i8* %6084, i64 4
  %6086 = bitcast i8* %6085 to float*
  %6087 = load float, float* %6086, align 4
  %6088 = insertelement <4 x float> zeroinitializer, float %6087, i32 0
  %6089 = insertelement <4 x float> %6088, float 0.000000e+00, i32 1
  %6090 = insertelement <4 x float> %6089, float 0.000000e+00, i32 2
  %6091 = insertelement <4 x float> %6090, float 0.000000e+00, i32 3
  %6092 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6093 = getelementptr inbounds i8, i8* %6092, i64 4
  %6094 = bitcast i8* %6093 to float*
  %6095 = load float, float* %6094, align 4
  %6096 = insertelement <4 x float> zeroinitializer, float %6095, i32 0
  %6097 = insertelement <4 x float> %6096, float 0.000000e+00, i32 1
  %6098 = insertelement <4 x float> %6097, float 0.000000e+00, i32 2
  %6099 = insertelement <4 x float> %6098, float 0.000000e+00, i32 3
  %6100 = getelementptr inbounds float, float* %1, i64 5
  %6101 = load float, float* %6100, align 4
  %6102 = insertelement <4 x float> zeroinitializer, float %6101, i32 0
  %6103 = insertelement <4 x float> %6102, float 0.000000e+00, i32 1
  %6104 = insertelement <4 x float> %6103, float 0.000000e+00, i32 2
  %6105 = insertelement <4 x float> %6104, float 0.000000e+00, i32 3
  %6106 = call <4 x float> @llvm.fma.f32.129(<4 x float> %6099, <4 x float> %6105, <4 x float> %6091)
  %6107 = extractelement <4 x float> %6106, i32 0
  %6108 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6109 = getelementptr inbounds i8, i8* %6108, i64 4
  %6110 = bitcast i8* %6109 to float*
  store float %6107, float* %6110, align 4
  %6111 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6112 = getelementptr inbounds i8, i8* %6111, i64 4
  %6113 = bitcast i8* %6112 to float*
  %6114 = load float, float* %6113, align 4
  %6115 = insertelement <4 x float> zeroinitializer, float %6114, i32 0
  %6116 = insertelement <4 x float> %6115, float 0.000000e+00, i32 1
  %6117 = insertelement <4 x float> %6116, float 0.000000e+00, i32 2
  %6118 = insertelement <4 x float> %6117, float 0.000000e+00, i32 3
  %6119 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6120 = getelementptr inbounds i8, i8* %6119, i64 8
  %6121 = bitcast i8* %6120 to float*
  %6122 = load float, float* %6121, align 4
  %6123 = insertelement <4 x float> zeroinitializer, float %6122, i32 0
  %6124 = insertelement <4 x float> %6123, float 0.000000e+00, i32 1
  %6125 = insertelement <4 x float> %6124, float 0.000000e+00, i32 2
  %6126 = insertelement <4 x float> %6125, float 0.000000e+00, i32 3
  %6127 = getelementptr inbounds float, float* %1, i64 9
  %6128 = load float, float* %6127, align 4
  %6129 = insertelement <4 x float> zeroinitializer, float %6128, i32 0
  %6130 = insertelement <4 x float> %6129, float 0.000000e+00, i32 1
  %6131 = insertelement <4 x float> %6130, float 0.000000e+00, i32 2
  %6132 = insertelement <4 x float> %6131, float 0.000000e+00, i32 3
  %6133 = call <4 x float> @llvm.fma.f32.130(<4 x float> %6126, <4 x float> %6132, <4 x float> %6118)
  %6134 = extractelement <4 x float> %6133, i32 0
  %6135 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6136 = getelementptr inbounds i8, i8* %6135, i64 4
  %6137 = bitcast i8* %6136 to float*
  store float %6134, float* %6137, align 4
  %6138 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6139 = getelementptr inbounds i8, i8* %6138, i64 4
  %6140 = bitcast i8* %6139 to float*
  %6141 = load float, float* %6140, align 4
  %6142 = insertelement <4 x float> zeroinitializer, float %6141, i32 0
  %6143 = insertelement <4 x float> %6142, float 0.000000e+00, i32 1
  %6144 = insertelement <4 x float> %6143, float 0.000000e+00, i32 2
  %6145 = insertelement <4 x float> %6144, float 0.000000e+00, i32 3
  %6146 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6147 = getelementptr inbounds i8, i8* %6146, i64 12
  %6148 = bitcast i8* %6147 to float*
  %6149 = load float, float* %6148, align 4
  %6150 = insertelement <4 x float> zeroinitializer, float %6149, i32 0
  %6151 = insertelement <4 x float> %6150, float 0.000000e+00, i32 1
  %6152 = insertelement <4 x float> %6151, float 0.000000e+00, i32 2
  %6153 = insertelement <4 x float> %6152, float 0.000000e+00, i32 3
  %6154 = getelementptr inbounds float, float* %1, i64 13
  %6155 = load float, float* %6154, align 4
  %6156 = insertelement <4 x float> zeroinitializer, float %6155, i32 0
  %6157 = insertelement <4 x float> %6156, float 0.000000e+00, i32 1
  %6158 = insertelement <4 x float> %6157, float 0.000000e+00, i32 2
  %6159 = insertelement <4 x float> %6158, float 0.000000e+00, i32 3
  %6160 = call <4 x float> @llvm.fma.f32.131(<4 x float> %6153, <4 x float> %6159, <4 x float> %6145)
  %6161 = extractelement <4 x float> %6160, i32 0
  %6162 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6163 = getelementptr inbounds i8, i8* %6162, i64 4
  %6164 = bitcast i8* %6163 to float*
  store float %6161, float* %6164, align 4
  %6165 = extractelement <4 x float> %6160, i32 1
  %6166 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6167 = getelementptr inbounds i8, i8* %6166, i64 8
  %6168 = bitcast i8* %6167 to float*
  store float %6165, float* %6168, align 4
  %6169 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6170 = getelementptr inbounds i8, i8* %6169, i64 8
  %6171 = bitcast i8* %6170 to float*
  %6172 = load float, float* %6171, align 4
  %6173 = insertelement <4 x float> zeroinitializer, float %6172, i32 0
  %6174 = insertelement <4 x float> %6173, float 0.000000e+00, i32 1
  %6175 = insertelement <4 x float> %6174, float 0.000000e+00, i32 2
  %6176 = insertelement <4 x float> %6175, float 0.000000e+00, i32 3
  %6177 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6178 = bitcast i8* %6177 to float*
  %6179 = load float, float* %6178, align 4
  %6180 = insertelement <4 x float> zeroinitializer, float %6179, i32 0
  %6181 = insertelement <4 x float> %6180, float 0.000000e+00, i32 1
  %6182 = insertelement <4 x float> %6181, float 0.000000e+00, i32 2
  %6183 = insertelement <4 x float> %6182, float 0.000000e+00, i32 3
  %6184 = getelementptr inbounds float, float* %1, i64 2
  %6185 = load float, float* %6184, align 4
  %6186 = insertelement <4 x float> zeroinitializer, float %6185, i32 0
  %6187 = insertelement <4 x float> %6186, float 0.000000e+00, i32 1
  %6188 = insertelement <4 x float> %6187, float 0.000000e+00, i32 2
  %6189 = insertelement <4 x float> %6188, float 0.000000e+00, i32 3
  %6190 = call <4 x float> @llvm.fma.f32.132(<4 x float> %6183, <4 x float> %6189, <4 x float> %6176)
  %6191 = extractelement <4 x float> %6190, i32 0
  %6192 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6193 = getelementptr inbounds i8, i8* %6192, i64 8
  %6194 = bitcast i8* %6193 to float*
  store float %6191, float* %6194, align 4
  %6195 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6196 = getelementptr inbounds i8, i8* %6195, i64 8
  %6197 = bitcast i8* %6196 to float*
  %6198 = load float, float* %6197, align 4
  %6199 = insertelement <4 x float> zeroinitializer, float %6198, i32 0
  %6200 = insertelement <4 x float> %6199, float 0.000000e+00, i32 1
  %6201 = insertelement <4 x float> %6200, float 0.000000e+00, i32 2
  %6202 = insertelement <4 x float> %6201, float 0.000000e+00, i32 3
  %6203 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6204 = getelementptr inbounds i8, i8* %6203, i64 4
  %6205 = bitcast i8* %6204 to float*
  %6206 = load float, float* %6205, align 4
  %6207 = insertelement <4 x float> zeroinitializer, float %6206, i32 0
  %6208 = insertelement <4 x float> %6207, float 0.000000e+00, i32 1
  %6209 = insertelement <4 x float> %6208, float 0.000000e+00, i32 2
  %6210 = insertelement <4 x float> %6209, float 0.000000e+00, i32 3
  %6211 = getelementptr inbounds float, float* %1, i64 6
  %6212 = load float, float* %6211, align 4
  %6213 = insertelement <4 x float> zeroinitializer, float %6212, i32 0
  %6214 = insertelement <4 x float> %6213, float 0.000000e+00, i32 1
  %6215 = insertelement <4 x float> %6214, float 0.000000e+00, i32 2
  %6216 = insertelement <4 x float> %6215, float 0.000000e+00, i32 3
  %6217 = call <4 x float> @llvm.fma.f32.133(<4 x float> %6210, <4 x float> %6216, <4 x float> %6202)
  %6218 = extractelement <4 x float> %6217, i32 0
  %6219 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6220 = getelementptr inbounds i8, i8* %6219, i64 8
  %6221 = bitcast i8* %6220 to float*
  store float %6218, float* %6221, align 4
  %6222 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6223 = getelementptr inbounds i8, i8* %6222, i64 8
  %6224 = bitcast i8* %6223 to float*
  %6225 = load float, float* %6224, align 4
  %6226 = insertelement <4 x float> zeroinitializer, float %6225, i32 0
  %6227 = insertelement <4 x float> %6226, float 0.000000e+00, i32 1
  %6228 = insertelement <4 x float> %6227, float 0.000000e+00, i32 2
  %6229 = insertelement <4 x float> %6228, float 0.000000e+00, i32 3
  %6230 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6231 = getelementptr inbounds i8, i8* %6230, i64 8
  %6232 = bitcast i8* %6231 to float*
  %6233 = load float, float* %6232, align 4
  %6234 = insertelement <4 x float> zeroinitializer, float %6233, i32 0
  %6235 = insertelement <4 x float> %6234, float 0.000000e+00, i32 1
  %6236 = insertelement <4 x float> %6235, float 0.000000e+00, i32 2
  %6237 = insertelement <4 x float> %6236, float 0.000000e+00, i32 3
  %6238 = getelementptr inbounds float, float* %1, i64 10
  %6239 = load float, float* %6238, align 4
  %6240 = insertelement <4 x float> zeroinitializer, float %6239, i32 0
  %6241 = insertelement <4 x float> %6240, float 0.000000e+00, i32 1
  %6242 = insertelement <4 x float> %6241, float 0.000000e+00, i32 2
  %6243 = insertelement <4 x float> %6242, float 0.000000e+00, i32 3
  %6244 = call <4 x float> @llvm.fma.f32.134(<4 x float> %6237, <4 x float> %6243, <4 x float> %6229)
  %6245 = extractelement <4 x float> %6244, i32 0
  %6246 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6247 = getelementptr inbounds i8, i8* %6246, i64 8
  %6248 = bitcast i8* %6247 to float*
  store float %6245, float* %6248, align 4
  %6249 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6250 = getelementptr inbounds i8, i8* %6249, i64 8
  %6251 = bitcast i8* %6250 to float*
  %6252 = load float, float* %6251, align 4
  %6253 = insertelement <4 x float> zeroinitializer, float %6252, i32 0
  %6254 = insertelement <4 x float> %6253, float 0.000000e+00, i32 1
  %6255 = insertelement <4 x float> %6254, float 0.000000e+00, i32 2
  %6256 = insertelement <4 x float> %6255, float 0.000000e+00, i32 3
  %6257 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6258 = getelementptr inbounds i8, i8* %6257, i64 12
  %6259 = bitcast i8* %6258 to float*
  %6260 = load float, float* %6259, align 4
  %6261 = insertelement <4 x float> zeroinitializer, float %6260, i32 0
  %6262 = insertelement <4 x float> %6261, float 0.000000e+00, i32 1
  %6263 = insertelement <4 x float> %6262, float 0.000000e+00, i32 2
  %6264 = insertelement <4 x float> %6263, float 0.000000e+00, i32 3
  %6265 = getelementptr inbounds float, float* %1, i64 14
  %6266 = load float, float* %6265, align 4
  %6267 = insertelement <4 x float> zeroinitializer, float %6266, i32 0
  %6268 = insertelement <4 x float> %6267, float 0.000000e+00, i32 1
  %6269 = insertelement <4 x float> %6268, float 0.000000e+00, i32 2
  %6270 = insertelement <4 x float> %6269, float 0.000000e+00, i32 3
  %6271 = call <4 x float> @llvm.fma.f32.135(<4 x float> %6264, <4 x float> %6270, <4 x float> %6256)
  %6272 = extractelement <4 x float> %6271, i32 0
  %6273 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6274 = getelementptr inbounds i8, i8* %6273, i64 8
  %6275 = bitcast i8* %6274 to float*
  store float %6272, float* %6275, align 4
  %6276 = extractelement <4 x float> %6271, i32 1
  %6277 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6278 = getelementptr inbounds i8, i8* %6277, i64 12
  %6279 = bitcast i8* %6278 to float*
  store float %6276, float* %6279, align 4
  %6280 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6281 = getelementptr inbounds i8, i8* %6280, i64 12
  %6282 = bitcast i8* %6281 to float*
  %6283 = load float, float* %6282, align 4
  %6284 = insertelement <4 x float> zeroinitializer, float %6283, i32 0
  %6285 = insertelement <4 x float> %6284, float 0.000000e+00, i32 1
  %6286 = insertelement <4 x float> %6285, float 0.000000e+00, i32 2
  %6287 = insertelement <4 x float> %6286, float 0.000000e+00, i32 3
  %6288 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6289 = bitcast i8* %6288 to float*
  %6290 = load float, float* %6289, align 4
  %6291 = insertelement <4 x float> zeroinitializer, float %6290, i32 0
  %6292 = insertelement <4 x float> %6291, float 0.000000e+00, i32 1
  %6293 = insertelement <4 x float> %6292, float 0.000000e+00, i32 2
  %6294 = insertelement <4 x float> %6293, float 0.000000e+00, i32 3
  %6295 = getelementptr inbounds float, float* %1, i64 3
  %6296 = load float, float* %6295, align 4
  %6297 = insertelement <4 x float> zeroinitializer, float %6296, i32 0
  %6298 = insertelement <4 x float> %6297, float 0.000000e+00, i32 1
  %6299 = insertelement <4 x float> %6298, float 0.000000e+00, i32 2
  %6300 = insertelement <4 x float> %6299, float 0.000000e+00, i32 3
  %6301 = call <4 x float> @llvm.fma.f32.136(<4 x float> %6294, <4 x float> %6300, <4 x float> %6287)
  %6302 = extractelement <4 x float> %6301, i32 0
  %6303 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6304 = getelementptr inbounds i8, i8* %6303, i64 12
  %6305 = bitcast i8* %6304 to float*
  store float %6302, float* %6305, align 4
  %6306 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6307 = getelementptr inbounds i8, i8* %6306, i64 12
  %6308 = bitcast i8* %6307 to float*
  %6309 = load float, float* %6308, align 4
  %6310 = insertelement <4 x float> zeroinitializer, float %6309, i32 0
  %6311 = insertelement <4 x float> %6310, float 0.000000e+00, i32 1
  %6312 = insertelement <4 x float> %6311, float 0.000000e+00, i32 2
  %6313 = insertelement <4 x float> %6312, float 0.000000e+00, i32 3
  %6314 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6315 = getelementptr inbounds i8, i8* %6314, i64 4
  %6316 = bitcast i8* %6315 to float*
  %6317 = load float, float* %6316, align 4
  %6318 = insertelement <4 x float> zeroinitializer, float %6317, i32 0
  %6319 = insertelement <4 x float> %6318, float 0.000000e+00, i32 1
  %6320 = insertelement <4 x float> %6319, float 0.000000e+00, i32 2
  %6321 = insertelement <4 x float> %6320, float 0.000000e+00, i32 3
  %6322 = getelementptr inbounds float, float* %1, i64 7
  %6323 = load float, float* %6322, align 4
  %6324 = insertelement <4 x float> zeroinitializer, float %6323, i32 0
  %6325 = insertelement <4 x float> %6324, float 0.000000e+00, i32 1
  %6326 = insertelement <4 x float> %6325, float 0.000000e+00, i32 2
  %6327 = insertelement <4 x float> %6326, float 0.000000e+00, i32 3
  %6328 = call <4 x float> @llvm.fma.f32.137(<4 x float> %6321, <4 x float> %6327, <4 x float> %6313)
  %6329 = extractelement <4 x float> %6328, i32 0
  %6330 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6331 = getelementptr inbounds i8, i8* %6330, i64 12
  %6332 = bitcast i8* %6331 to float*
  store float %6329, float* %6332, align 4
  %6333 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6334 = getelementptr inbounds i8, i8* %6333, i64 12
  %6335 = bitcast i8* %6334 to float*
  %6336 = load float, float* %6335, align 4
  %6337 = insertelement <4 x float> zeroinitializer, float %6336, i32 0
  %6338 = insertelement <4 x float> %6337, float 0.000000e+00, i32 1
  %6339 = insertelement <4 x float> %6338, float 0.000000e+00, i32 2
  %6340 = insertelement <4 x float> %6339, float 0.000000e+00, i32 3
  %6341 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6342 = getelementptr inbounds i8, i8* %6341, i64 8
  %6343 = bitcast i8* %6342 to float*
  %6344 = load float, float* %6343, align 4
  %6345 = insertelement <4 x float> zeroinitializer, float %6344, i32 0
  %6346 = insertelement <4 x float> %6345, float 0.000000e+00, i32 1
  %6347 = insertelement <4 x float> %6346, float 0.000000e+00, i32 2
  %6348 = insertelement <4 x float> %6347, float 0.000000e+00, i32 3
  %6349 = getelementptr inbounds float, float* %1, i64 11
  %6350 = load float, float* %6349, align 4
  %6351 = insertelement <4 x float> zeroinitializer, float %6350, i32 0
  %6352 = insertelement <4 x float> %6351, float 0.000000e+00, i32 1
  %6353 = insertelement <4 x float> %6352, float 0.000000e+00, i32 2
  %6354 = insertelement <4 x float> %6353, float 0.000000e+00, i32 3
  %6355 = call <4 x float> @llvm.fma.f32.138(<4 x float> %6348, <4 x float> %6354, <4 x float> %6340)
  %6356 = extractelement <4 x float> %6355, i32 0
  %6357 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6358 = getelementptr inbounds i8, i8* %6357, i64 12
  %6359 = bitcast i8* %6358 to float*
  store float %6356, float* %6359, align 4
  %6360 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6361 = getelementptr inbounds i8, i8* %6360, i64 12
  %6362 = bitcast i8* %6361 to float*
  %6363 = load float, float* %6362, align 4
  %6364 = insertelement <4 x float> zeroinitializer, float %6363, i32 0
  %6365 = insertelement <4 x float> %6364, float 0.000000e+00, i32 1
  %6366 = insertelement <4 x float> %6365, float 0.000000e+00, i32 2
  %6367 = insertelement <4 x float> %6366, float 0.000000e+00, i32 3
  %6368 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6369 = getelementptr inbounds i8, i8* %6368, i64 12
  %6370 = bitcast i8* %6369 to float*
  %6371 = load float, float* %6370, align 4
  %6372 = insertelement <4 x float> zeroinitializer, float %6371, i32 0
  %6373 = insertelement <4 x float> %6372, float 0.000000e+00, i32 1
  %6374 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6375 = getelementptr inbounds i8, i8* %6374, i64 16
  %6376 = bitcast i8* %6375 to float*
  %6377 = load float, float* %6376, align 4
  %6378 = insertelement <4 x float> %6373, float %6377, i32 2
  %6379 = insertelement <4 x float> %6378, float 0.000000e+00, i32 3
  %6380 = getelementptr inbounds float, float* %1, i64 15
  %6381 = load float, float* %6380, align 4
  %6382 = insertelement <4 x float> zeroinitializer, float %6381, i32 0
  %6383 = insertelement <4 x float> %6382, float 0.000000e+00, i32 1
  %6384 = load float, float* %1, align 4
  %6385 = insertelement <4 x float> %6383, float %6384, i32 2
  %6386 = insertelement <4 x float> %6385, float 0.000000e+00, i32 3
  %6387 = call <4 x float> @llvm.fma.f32.139(<4 x float> %6379, <4 x float> %6386, <4 x float> %6367)
  %6388 = extractelement <4 x float> %6387, i32 0
  %6389 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6390 = getelementptr inbounds i8, i8* %6389, i64 12
  %6391 = bitcast i8* %6390 to float*
  store float %6388, float* %6391, align 4
  %6392 = extractelement <4 x float> %6387, i32 1
  %6393 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6394 = getelementptr inbounds i8, i8* %6393, i64 16
  %6395 = bitcast i8* %6394 to float*
  store float %6392, float* %6395, align 4
  %6396 = extractelement <4 x float> %6387, i32 2
  %6397 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6398 = getelementptr inbounds i8, i8* %6397, i64 16
  %6399 = bitcast i8* %6398 to float*
  store float %6396, float* %6399, align 4
  %6400 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6401 = getelementptr inbounds i8, i8* %6400, i64 16
  %6402 = bitcast i8* %6401 to float*
  %6403 = load float, float* %6402, align 4
  %6404 = insertelement <4 x float> zeroinitializer, float %6403, i32 0
  %6405 = insertelement <4 x float> %6404, float 0.000000e+00, i32 1
  %6406 = insertelement <4 x float> %6405, float 0.000000e+00, i32 2
  %6407 = insertelement <4 x float> %6406, float 0.000000e+00, i32 3
  %6408 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6409 = getelementptr inbounds i8, i8* %6408, i64 20
  %6410 = bitcast i8* %6409 to float*
  %6411 = load float, float* %6410, align 4
  %6412 = insertelement <4 x float> zeroinitializer, float %6411, i32 0
  %6413 = insertelement <4 x float> %6412, float 0.000000e+00, i32 1
  %6414 = insertelement <4 x float> %6413, float 0.000000e+00, i32 2
  %6415 = insertelement <4 x float> %6414, float 0.000000e+00, i32 3
  %6416 = getelementptr inbounds float, float* %1, i64 4
  %6417 = load float, float* %6416, align 4
  %6418 = insertelement <4 x float> zeroinitializer, float %6417, i32 0
  %6419 = insertelement <4 x float> %6418, float 0.000000e+00, i32 1
  %6420 = insertelement <4 x float> %6419, float 0.000000e+00, i32 2
  %6421 = insertelement <4 x float> %6420, float 0.000000e+00, i32 3
  %6422 = call <4 x float> @llvm.fma.f32.140(<4 x float> %6415, <4 x float> %6421, <4 x float> %6407)
  %6423 = extractelement <4 x float> %6422, i32 0
  %6424 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6425 = getelementptr inbounds i8, i8* %6424, i64 16
  %6426 = bitcast i8* %6425 to float*
  store float %6423, float* %6426, align 4
  %6427 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6428 = getelementptr inbounds i8, i8* %6427, i64 16
  %6429 = bitcast i8* %6428 to float*
  %6430 = load float, float* %6429, align 4
  %6431 = insertelement <4 x float> zeroinitializer, float %6430, i32 0
  %6432 = insertelement <4 x float> %6431, float 0.000000e+00, i32 1
  %6433 = insertelement <4 x float> %6432, float 0.000000e+00, i32 2
  %6434 = insertelement <4 x float> %6433, float 0.000000e+00, i32 3
  %6435 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6436 = getelementptr inbounds i8, i8* %6435, i64 24
  %6437 = bitcast i8* %6436 to float*
  %6438 = load float, float* %6437, align 4
  %6439 = insertelement <4 x float> zeroinitializer, float %6438, i32 0
  %6440 = insertelement <4 x float> %6439, float 0.000000e+00, i32 1
  %6441 = insertelement <4 x float> %6440, float 0.000000e+00, i32 2
  %6442 = insertelement <4 x float> %6441, float 0.000000e+00, i32 3
  %6443 = getelementptr inbounds float, float* %1, i64 8
  %6444 = load float, float* %6443, align 4
  %6445 = insertelement <4 x float> zeroinitializer, float %6444, i32 0
  %6446 = insertelement <4 x float> %6445, float 0.000000e+00, i32 1
  %6447 = insertelement <4 x float> %6446, float 0.000000e+00, i32 2
  %6448 = insertelement <4 x float> %6447, float 0.000000e+00, i32 3
  %6449 = call <4 x float> @llvm.fma.f32.141(<4 x float> %6442, <4 x float> %6448, <4 x float> %6434)
  %6450 = extractelement <4 x float> %6449, i32 0
  %6451 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6452 = getelementptr inbounds i8, i8* %6451, i64 16
  %6453 = bitcast i8* %6452 to float*
  store float %6450, float* %6453, align 4
  %6454 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6455 = getelementptr inbounds i8, i8* %6454, i64 16
  %6456 = bitcast i8* %6455 to float*
  %6457 = load float, float* %6456, align 4
  %6458 = insertelement <4 x float> zeroinitializer, float %6457, i32 0
  %6459 = insertelement <4 x float> %6458, float 0.000000e+00, i32 1
  %6460 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6461 = getelementptr inbounds i8, i8* %6460, i64 20
  %6462 = bitcast i8* %6461 to float*
  %6463 = load float, float* %6462, align 4
  %6464 = insertelement <4 x float> %6459, float %6463, i32 2
  %6465 = insertelement <4 x float> %6464, float 0.000000e+00, i32 3
  %6466 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6467 = getelementptr inbounds i8, i8* %6466, i64 28
  %6468 = bitcast i8* %6467 to float*
  %6469 = load float, float* %6468, align 4
  %6470 = insertelement <4 x float> zeroinitializer, float %6469, i32 0
  %6471 = insertelement <4 x float> %6470, float 0.000000e+00, i32 1
  %6472 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6473 = getelementptr inbounds i8, i8* %6472, i64 16
  %6474 = bitcast i8* %6473 to float*
  %6475 = load float, float* %6474, align 4
  %6476 = insertelement <4 x float> %6471, float %6475, i32 2
  %6477 = insertelement <4 x float> %6476, float 0.000000e+00, i32 3
  %6478 = getelementptr inbounds float, float* %1, i64 12
  %6479 = load float, float* %6478, align 4
  %6480 = insertelement <4 x float> zeroinitializer, float %6479, i32 0
  %6481 = insertelement <4 x float> %6480, float 0.000000e+00, i32 1
  %6482 = getelementptr inbounds float, float* %1, i64 1
  %6483 = load float, float* %6482, align 4
  %6484 = insertelement <4 x float> %6481, float %6483, i32 2
  %6485 = insertelement <4 x float> %6484, float 0.000000e+00, i32 3
  %6486 = call <4 x float> @llvm.fma.f32.142(<4 x float> %6477, <4 x float> %6485, <4 x float> %6465)
  %6487 = extractelement <4 x float> %6486, i32 0
  %6488 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6489 = getelementptr inbounds i8, i8* %6488, i64 16
  %6490 = bitcast i8* %6489 to float*
  store float %6487, float* %6490, align 4
  %6491 = extractelement <4 x float> %6486, i32 1
  %6492 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6493 = getelementptr inbounds i8, i8* %6492, i64 20
  %6494 = bitcast i8* %6493 to float*
  store float %6491, float* %6494, align 4
  %6495 = extractelement <4 x float> %6486, i32 2
  %6496 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6497 = getelementptr inbounds i8, i8* %6496, i64 20
  %6498 = bitcast i8* %6497 to float*
  store float %6495, float* %6498, align 4
  %6499 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6500 = getelementptr inbounds i8, i8* %6499, i64 20
  %6501 = bitcast i8* %6500 to float*
  %6502 = load float, float* %6501, align 4
  %6503 = insertelement <4 x float> zeroinitializer, float %6502, i32 0
  %6504 = insertelement <4 x float> %6503, float 0.000000e+00, i32 1
  %6505 = insertelement <4 x float> %6504, float 0.000000e+00, i32 2
  %6506 = insertelement <4 x float> %6505, float 0.000000e+00, i32 3
  %6507 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6508 = getelementptr inbounds i8, i8* %6507, i64 20
  %6509 = bitcast i8* %6508 to float*
  %6510 = load float, float* %6509, align 4
  %6511 = insertelement <4 x float> zeroinitializer, float %6510, i32 0
  %6512 = insertelement <4 x float> %6511, float 0.000000e+00, i32 1
  %6513 = insertelement <4 x float> %6512, float 0.000000e+00, i32 2
  %6514 = insertelement <4 x float> %6513, float 0.000000e+00, i32 3
  %6515 = getelementptr inbounds float, float* %1, i64 5
  %6516 = load float, float* %6515, align 4
  %6517 = insertelement <4 x float> zeroinitializer, float %6516, i32 0
  %6518 = insertelement <4 x float> %6517, float 0.000000e+00, i32 1
  %6519 = insertelement <4 x float> %6518, float 0.000000e+00, i32 2
  %6520 = insertelement <4 x float> %6519, float 0.000000e+00, i32 3
  %6521 = call <4 x float> @llvm.fma.f32.143(<4 x float> %6514, <4 x float> %6520, <4 x float> %6506)
  %6522 = extractelement <4 x float> %6521, i32 0
  %6523 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6524 = getelementptr inbounds i8, i8* %6523, i64 20
  %6525 = bitcast i8* %6524 to float*
  store float %6522, float* %6525, align 4
  %6526 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6527 = getelementptr inbounds i8, i8* %6526, i64 20
  %6528 = bitcast i8* %6527 to float*
  %6529 = load float, float* %6528, align 4
  %6530 = insertelement <4 x float> zeroinitializer, float %6529, i32 0
  %6531 = insertelement <4 x float> %6530, float 0.000000e+00, i32 1
  %6532 = insertelement <4 x float> %6531, float 0.000000e+00, i32 2
  %6533 = insertelement <4 x float> %6532, float 0.000000e+00, i32 3
  %6534 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6535 = getelementptr inbounds i8, i8* %6534, i64 24
  %6536 = bitcast i8* %6535 to float*
  %6537 = load float, float* %6536, align 4
  %6538 = insertelement <4 x float> zeroinitializer, float %6537, i32 0
  %6539 = insertelement <4 x float> %6538, float 0.000000e+00, i32 1
  %6540 = insertelement <4 x float> %6539, float 0.000000e+00, i32 2
  %6541 = insertelement <4 x float> %6540, float 0.000000e+00, i32 3
  %6542 = getelementptr inbounds float, float* %1, i64 9
  %6543 = load float, float* %6542, align 4
  %6544 = insertelement <4 x float> zeroinitializer, float %6543, i32 0
  %6545 = insertelement <4 x float> %6544, float 0.000000e+00, i32 1
  %6546 = insertelement <4 x float> %6545, float 0.000000e+00, i32 2
  %6547 = insertelement <4 x float> %6546, float 0.000000e+00, i32 3
  %6548 = call <4 x float> @llvm.fma.f32.144(<4 x float> %6541, <4 x float> %6547, <4 x float> %6533)
  %6549 = extractelement <4 x float> %6548, i32 0
  %6550 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6551 = getelementptr inbounds i8, i8* %6550, i64 20
  %6552 = bitcast i8* %6551 to float*
  store float %6549, float* %6552, align 4
  %6553 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6554 = getelementptr inbounds i8, i8* %6553, i64 20
  %6555 = bitcast i8* %6554 to float*
  %6556 = load float, float* %6555, align 4
  %6557 = insertelement <4 x float> zeroinitializer, float %6556, i32 0
  %6558 = insertelement <4 x float> %6557, float 0.000000e+00, i32 1
  %6559 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6560 = getelementptr inbounds i8, i8* %6559, i64 24
  %6561 = bitcast i8* %6560 to float*
  %6562 = load float, float* %6561, align 4
  %6563 = insertelement <4 x float> %6558, float %6562, i32 2
  %6564 = insertelement <4 x float> %6563, float 0.000000e+00, i32 3
  %6565 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6566 = getelementptr inbounds i8, i8* %6565, i64 28
  %6567 = bitcast i8* %6566 to float*
  %6568 = load float, float* %6567, align 4
  %6569 = insertelement <4 x float> zeroinitializer, float %6568, i32 0
  %6570 = insertelement <4 x float> %6569, float 0.000000e+00, i32 1
  %6571 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6572 = getelementptr inbounds i8, i8* %6571, i64 16
  %6573 = bitcast i8* %6572 to float*
  %6574 = load float, float* %6573, align 4
  %6575 = insertelement <4 x float> %6570, float %6574, i32 2
  %6576 = insertelement <4 x float> %6575, float 0.000000e+00, i32 3
  %6577 = getelementptr inbounds float, float* %1, i64 13
  %6578 = load float, float* %6577, align 4
  %6579 = insertelement <4 x float> zeroinitializer, float %6578, i32 0
  %6580 = insertelement <4 x float> %6579, float 0.000000e+00, i32 1
  %6581 = getelementptr inbounds float, float* %1, i64 2
  %6582 = load float, float* %6581, align 4
  %6583 = insertelement <4 x float> %6580, float %6582, i32 2
  %6584 = insertelement <4 x float> %6583, float 0.000000e+00, i32 3
  %6585 = call <4 x float> @llvm.fma.f32.145(<4 x float> %6576, <4 x float> %6584, <4 x float> %6564)
  %6586 = extractelement <4 x float> %6585, i32 0
  %6587 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6588 = getelementptr inbounds i8, i8* %6587, i64 20
  %6589 = bitcast i8* %6588 to float*
  store float %6586, float* %6589, align 4
  %6590 = extractelement <4 x float> %6585, i32 1
  %6591 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6592 = getelementptr inbounds i8, i8* %6591, i64 24
  %6593 = bitcast i8* %6592 to float*
  store float %6590, float* %6593, align 4
  %6594 = extractelement <4 x float> %6585, i32 2
  %6595 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6596 = getelementptr inbounds i8, i8* %6595, i64 24
  %6597 = bitcast i8* %6596 to float*
  store float %6594, float* %6597, align 4
  %6598 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6599 = getelementptr inbounds i8, i8* %6598, i64 24
  %6600 = bitcast i8* %6599 to float*
  %6601 = load float, float* %6600, align 4
  %6602 = insertelement <4 x float> zeroinitializer, float %6601, i32 0
  %6603 = insertelement <4 x float> %6602, float 0.000000e+00, i32 1
  %6604 = insertelement <4 x float> %6603, float 0.000000e+00, i32 2
  %6605 = insertelement <4 x float> %6604, float 0.000000e+00, i32 3
  %6606 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6607 = getelementptr inbounds i8, i8* %6606, i64 20
  %6608 = bitcast i8* %6607 to float*
  %6609 = load float, float* %6608, align 4
  %6610 = insertelement <4 x float> zeroinitializer, float %6609, i32 0
  %6611 = insertelement <4 x float> %6610, float 0.000000e+00, i32 1
  %6612 = insertelement <4 x float> %6611, float 0.000000e+00, i32 2
  %6613 = insertelement <4 x float> %6612, float 0.000000e+00, i32 3
  %6614 = getelementptr inbounds float, float* %1, i64 6
  %6615 = load float, float* %6614, align 4
  %6616 = insertelement <4 x float> zeroinitializer, float %6615, i32 0
  %6617 = insertelement <4 x float> %6616, float 0.000000e+00, i32 1
  %6618 = insertelement <4 x float> %6617, float 0.000000e+00, i32 2
  %6619 = insertelement <4 x float> %6618, float 0.000000e+00, i32 3
  %6620 = call <4 x float> @llvm.fma.f32.146(<4 x float> %6613, <4 x float> %6619, <4 x float> %6605)
  %6621 = extractelement <4 x float> %6620, i32 0
  %6622 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6623 = getelementptr inbounds i8, i8* %6622, i64 24
  %6624 = bitcast i8* %6623 to float*
  store float %6621, float* %6624, align 4
  %6625 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6626 = getelementptr inbounds i8, i8* %6625, i64 24
  %6627 = bitcast i8* %6626 to float*
  %6628 = load float, float* %6627, align 4
  %6629 = insertelement <4 x float> zeroinitializer, float %6628, i32 0
  %6630 = insertelement <4 x float> %6629, float 0.000000e+00, i32 1
  %6631 = insertelement <4 x float> %6630, float 0.000000e+00, i32 2
  %6632 = insertelement <4 x float> %6631, float 0.000000e+00, i32 3
  %6633 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6634 = getelementptr inbounds i8, i8* %6633, i64 24
  %6635 = bitcast i8* %6634 to float*
  %6636 = load float, float* %6635, align 4
  %6637 = insertelement <4 x float> zeroinitializer, float %6636, i32 0
  %6638 = insertelement <4 x float> %6637, float 0.000000e+00, i32 1
  %6639 = insertelement <4 x float> %6638, float 0.000000e+00, i32 2
  %6640 = insertelement <4 x float> %6639, float 0.000000e+00, i32 3
  %6641 = getelementptr inbounds float, float* %1, i64 10
  %6642 = load float, float* %6641, align 4
  %6643 = insertelement <4 x float> zeroinitializer, float %6642, i32 0
  %6644 = insertelement <4 x float> %6643, float 0.000000e+00, i32 1
  %6645 = insertelement <4 x float> %6644, float 0.000000e+00, i32 2
  %6646 = insertelement <4 x float> %6645, float 0.000000e+00, i32 3
  %6647 = call <4 x float> @llvm.fma.f32.147(<4 x float> %6640, <4 x float> %6646, <4 x float> %6632)
  %6648 = extractelement <4 x float> %6647, i32 0
  %6649 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6650 = getelementptr inbounds i8, i8* %6649, i64 24
  %6651 = bitcast i8* %6650 to float*
  store float %6648, float* %6651, align 4
  %6652 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6653 = getelementptr inbounds i8, i8* %6652, i64 24
  %6654 = bitcast i8* %6653 to float*
  %6655 = load float, float* %6654, align 4
  %6656 = insertelement <4 x float> zeroinitializer, float %6655, i32 0
  %6657 = insertelement <4 x float> %6656, float 0.000000e+00, i32 1
  %6658 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6659 = getelementptr inbounds i8, i8* %6658, i64 28
  %6660 = bitcast i8* %6659 to float*
  %6661 = load float, float* %6660, align 4
  %6662 = insertelement <4 x float> %6657, float %6661, i32 2
  %6663 = insertelement <4 x float> %6662, float 0.000000e+00, i32 3
  %6664 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6665 = getelementptr inbounds i8, i8* %6664, i64 28
  %6666 = bitcast i8* %6665 to float*
  %6667 = load float, float* %6666, align 4
  %6668 = insertelement <4 x float> zeroinitializer, float %6667, i32 0
  %6669 = insertelement <4 x float> %6668, float 0.000000e+00, i32 1
  %6670 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6671 = getelementptr inbounds i8, i8* %6670, i64 16
  %6672 = bitcast i8* %6671 to float*
  %6673 = load float, float* %6672, align 4
  %6674 = insertelement <4 x float> %6669, float %6673, i32 2
  %6675 = insertelement <4 x float> %6674, float 0.000000e+00, i32 3
  %6676 = getelementptr inbounds float, float* %1, i64 14
  %6677 = load float, float* %6676, align 4
  %6678 = insertelement <4 x float> zeroinitializer, float %6677, i32 0
  %6679 = insertelement <4 x float> %6678, float 0.000000e+00, i32 1
  %6680 = getelementptr inbounds float, float* %1, i64 3
  %6681 = load float, float* %6680, align 4
  %6682 = insertelement <4 x float> %6679, float %6681, i32 2
  %6683 = insertelement <4 x float> %6682, float 0.000000e+00, i32 3
  %6684 = call <4 x float> @llvm.fma.f32.148(<4 x float> %6675, <4 x float> %6683, <4 x float> %6663)
  %6685 = extractelement <4 x float> %6684, i32 0
  %6686 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6687 = getelementptr inbounds i8, i8* %6686, i64 24
  %6688 = bitcast i8* %6687 to float*
  store float %6685, float* %6688, align 4
  %6689 = extractelement <4 x float> %6684, i32 1
  %6690 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6691 = getelementptr inbounds i8, i8* %6690, i64 28
  %6692 = bitcast i8* %6691 to float*
  store float %6689, float* %6692, align 4
  %6693 = extractelement <4 x float> %6684, i32 2
  %6694 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6695 = getelementptr inbounds i8, i8* %6694, i64 28
  %6696 = bitcast i8* %6695 to float*
  store float %6693, float* %6696, align 4
  %6697 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6698 = getelementptr inbounds i8, i8* %6697, i64 28
  %6699 = bitcast i8* %6698 to float*
  %6700 = load float, float* %6699, align 4
  %6701 = insertelement <4 x float> zeroinitializer, float %6700, i32 0
  %6702 = insertelement <4 x float> %6701, float 0.000000e+00, i32 1
  %6703 = insertelement <4 x float> %6702, float 0.000000e+00, i32 2
  %6704 = insertelement <4 x float> %6703, float 0.000000e+00, i32 3
  %6705 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6706 = getelementptr inbounds i8, i8* %6705, i64 20
  %6707 = bitcast i8* %6706 to float*
  %6708 = load float, float* %6707, align 4
  %6709 = insertelement <4 x float> zeroinitializer, float %6708, i32 0
  %6710 = insertelement <4 x float> %6709, float 0.000000e+00, i32 1
  %6711 = insertelement <4 x float> %6710, float 0.000000e+00, i32 2
  %6712 = insertelement <4 x float> %6711, float 0.000000e+00, i32 3
  %6713 = getelementptr inbounds float, float* %1, i64 7
  %6714 = load float, float* %6713, align 4
  %6715 = insertelement <4 x float> zeroinitializer, float %6714, i32 0
  %6716 = insertelement <4 x float> %6715, float 0.000000e+00, i32 1
  %6717 = insertelement <4 x float> %6716, float 0.000000e+00, i32 2
  %6718 = insertelement <4 x float> %6717, float 0.000000e+00, i32 3
  %6719 = call <4 x float> @llvm.fma.f32.149(<4 x float> %6712, <4 x float> %6718, <4 x float> %6704)
  %6720 = extractelement <4 x float> %6719, i32 0
  %6721 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6722 = getelementptr inbounds i8, i8* %6721, i64 28
  %6723 = bitcast i8* %6722 to float*
  store float %6720, float* %6723, align 4
  %6724 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6725 = getelementptr inbounds i8, i8* %6724, i64 28
  %6726 = bitcast i8* %6725 to float*
  %6727 = load float, float* %6726, align 4
  %6728 = insertelement <4 x float> zeroinitializer, float %6727, i32 0
  %6729 = insertelement <4 x float> %6728, float 0.000000e+00, i32 1
  %6730 = insertelement <4 x float> %6729, float 0.000000e+00, i32 2
  %6731 = insertelement <4 x float> %6730, float 0.000000e+00, i32 3
  %6732 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6733 = getelementptr inbounds i8, i8* %6732, i64 24
  %6734 = bitcast i8* %6733 to float*
  %6735 = load float, float* %6734, align 4
  %6736 = insertelement <4 x float> zeroinitializer, float %6735, i32 0
  %6737 = insertelement <4 x float> %6736, float 0.000000e+00, i32 1
  %6738 = insertelement <4 x float> %6737, float 0.000000e+00, i32 2
  %6739 = insertelement <4 x float> %6738, float 0.000000e+00, i32 3
  %6740 = getelementptr inbounds float, float* %1, i64 11
  %6741 = load float, float* %6740, align 4
  %6742 = insertelement <4 x float> zeroinitializer, float %6741, i32 0
  %6743 = insertelement <4 x float> %6742, float 0.000000e+00, i32 1
  %6744 = insertelement <4 x float> %6743, float 0.000000e+00, i32 2
  %6745 = insertelement <4 x float> %6744, float 0.000000e+00, i32 3
  %6746 = call <4 x float> @llvm.fma.f32.150(<4 x float> %6739, <4 x float> %6745, <4 x float> %6731)
  %6747 = extractelement <4 x float> %6746, i32 0
  %6748 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6749 = getelementptr inbounds i8, i8* %6748, i64 28
  %6750 = bitcast i8* %6749 to float*
  store float %6747, float* %6750, align 4
  %6751 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6752 = getelementptr inbounds i8, i8* %6751, i64 28
  %6753 = bitcast i8* %6752 to float*
  %6754 = load float, float* %6753, align 4
  %6755 = insertelement <4 x float> zeroinitializer, float %6754, i32 0
  %6756 = insertelement <4 x float> %6755, float 0.000000e+00, i32 1
  %6757 = insertelement <4 x float> %6756, float 0.000000e+00, i32 2
  %6758 = insertelement <4 x float> %6757, float 0.000000e+00, i32 3
  %6759 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6760 = getelementptr inbounds i8, i8* %6759, i64 28
  %6761 = bitcast i8* %6760 to float*
  %6762 = load float, float* %6761, align 4
  %6763 = insertelement <4 x float> zeroinitializer, float %6762, i32 0
  %6764 = insertelement <4 x float> %6763, float 0.000000e+00, i32 1
  %6765 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6766 = getelementptr inbounds i8, i8* %6765, i64 32
  %6767 = bitcast i8* %6766 to float*
  %6768 = load float, float* %6767, align 4
  %6769 = insertelement <4 x float> %6764, float %6768, i32 2
  %6770 = insertelement <4 x float> %6769, float 0.000000e+00, i32 3
  %6771 = getelementptr inbounds float, float* %1, i64 15
  %6772 = load float, float* %6771, align 4
  %6773 = insertelement <4 x float> zeroinitializer, float %6772, i32 0
  %6774 = insertelement <4 x float> %6773, float 0.000000e+00, i32 1
  %6775 = load float, float* %1, align 4
  %6776 = insertelement <4 x float> %6774, float %6775, i32 2
  %6777 = insertelement <4 x float> %6776, float 0.000000e+00, i32 3
  %6778 = call <4 x float> @llvm.fma.f32.151(<4 x float> %6770, <4 x float> %6777, <4 x float> %6758)
  %6779 = extractelement <4 x float> %6778, i32 0
  %6780 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6781 = getelementptr inbounds i8, i8* %6780, i64 28
  %6782 = bitcast i8* %6781 to float*
  store float %6779, float* %6782, align 4
  %6783 = extractelement <4 x float> %6778, i32 1
  %6784 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6785 = getelementptr inbounds i8, i8* %6784, i64 32
  %6786 = bitcast i8* %6785 to float*
  store float %6783, float* %6786, align 4
  %6787 = extractelement <4 x float> %6778, i32 2
  %6788 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6789 = getelementptr inbounds i8, i8* %6788, i64 32
  %6790 = bitcast i8* %6789 to float*
  store float %6787, float* %6790, align 4
  %6791 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6792 = getelementptr inbounds i8, i8* %6791, i64 32
  %6793 = bitcast i8* %6792 to float*
  %6794 = load float, float* %6793, align 4
  %6795 = insertelement <4 x float> zeroinitializer, float %6794, i32 0
  %6796 = insertelement <4 x float> %6795, float 0.000000e+00, i32 1
  %6797 = insertelement <4 x float> %6796, float 0.000000e+00, i32 2
  %6798 = insertelement <4 x float> %6797, float 0.000000e+00, i32 3
  %6799 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6800 = getelementptr inbounds i8, i8* %6799, i64 36
  %6801 = bitcast i8* %6800 to float*
  %6802 = load float, float* %6801, align 4
  %6803 = insertelement <4 x float> zeroinitializer, float %6802, i32 0
  %6804 = insertelement <4 x float> %6803, float 0.000000e+00, i32 1
  %6805 = insertelement <4 x float> %6804, float 0.000000e+00, i32 2
  %6806 = insertelement <4 x float> %6805, float 0.000000e+00, i32 3
  %6807 = getelementptr inbounds float, float* %1, i64 4
  %6808 = load float, float* %6807, align 4
  %6809 = insertelement <4 x float> zeroinitializer, float %6808, i32 0
  %6810 = insertelement <4 x float> %6809, float 0.000000e+00, i32 1
  %6811 = insertelement <4 x float> %6810, float 0.000000e+00, i32 2
  %6812 = insertelement <4 x float> %6811, float 0.000000e+00, i32 3
  %6813 = call <4 x float> @llvm.fma.f32.152(<4 x float> %6806, <4 x float> %6812, <4 x float> %6798)
  %6814 = extractelement <4 x float> %6813, i32 0
  %6815 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6816 = getelementptr inbounds i8, i8* %6815, i64 32
  %6817 = bitcast i8* %6816 to float*
  store float %6814, float* %6817, align 4
  %6818 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6819 = getelementptr inbounds i8, i8* %6818, i64 32
  %6820 = bitcast i8* %6819 to float*
  %6821 = load float, float* %6820, align 4
  %6822 = insertelement <4 x float> zeroinitializer, float %6821, i32 0
  %6823 = insertelement <4 x float> %6822, float 0.000000e+00, i32 1
  %6824 = insertelement <4 x float> %6823, float 0.000000e+00, i32 2
  %6825 = insertelement <4 x float> %6824, float 0.000000e+00, i32 3
  %6826 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6827 = getelementptr inbounds i8, i8* %6826, i64 40
  %6828 = bitcast i8* %6827 to float*
  %6829 = load float, float* %6828, align 4
  %6830 = insertelement <4 x float> zeroinitializer, float %6829, i32 0
  %6831 = insertelement <4 x float> %6830, float 0.000000e+00, i32 1
  %6832 = insertelement <4 x float> %6831, float 0.000000e+00, i32 2
  %6833 = insertelement <4 x float> %6832, float 0.000000e+00, i32 3
  %6834 = getelementptr inbounds float, float* %1, i64 8
  %6835 = load float, float* %6834, align 4
  %6836 = insertelement <4 x float> zeroinitializer, float %6835, i32 0
  %6837 = insertelement <4 x float> %6836, float 0.000000e+00, i32 1
  %6838 = insertelement <4 x float> %6837, float 0.000000e+00, i32 2
  %6839 = insertelement <4 x float> %6838, float 0.000000e+00, i32 3
  %6840 = call <4 x float> @llvm.fma.f32.153(<4 x float> %6833, <4 x float> %6839, <4 x float> %6825)
  %6841 = extractelement <4 x float> %6840, i32 0
  %6842 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6843 = getelementptr inbounds i8, i8* %6842, i64 32
  %6844 = bitcast i8* %6843 to float*
  store float %6841, float* %6844, align 4
  %6845 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6846 = getelementptr inbounds i8, i8* %6845, i64 32
  %6847 = bitcast i8* %6846 to float*
  %6848 = load float, float* %6847, align 4
  %6849 = insertelement <4 x float> zeroinitializer, float %6848, i32 0
  %6850 = insertelement <4 x float> %6849, float 0.000000e+00, i32 1
  %6851 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6852 = getelementptr inbounds i8, i8* %6851, i64 36
  %6853 = bitcast i8* %6852 to float*
  %6854 = load float, float* %6853, align 4
  %6855 = insertelement <4 x float> %6850, float %6854, i32 2
  %6856 = insertelement <4 x float> %6855, float 0.000000e+00, i32 3
  %6857 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6858 = getelementptr inbounds i8, i8* %6857, i64 44
  %6859 = bitcast i8* %6858 to float*
  %6860 = load float, float* %6859, align 4
  %6861 = insertelement <4 x float> zeroinitializer, float %6860, i32 0
  %6862 = insertelement <4 x float> %6861, float 0.000000e+00, i32 1
  %6863 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6864 = getelementptr inbounds i8, i8* %6863, i64 32
  %6865 = bitcast i8* %6864 to float*
  %6866 = load float, float* %6865, align 4
  %6867 = insertelement <4 x float> %6862, float %6866, i32 2
  %6868 = insertelement <4 x float> %6867, float 0.000000e+00, i32 3
  %6869 = getelementptr inbounds float, float* %1, i64 12
  %6870 = load float, float* %6869, align 4
  %6871 = insertelement <4 x float> zeroinitializer, float %6870, i32 0
  %6872 = insertelement <4 x float> %6871, float 0.000000e+00, i32 1
  %6873 = getelementptr inbounds float, float* %1, i64 1
  %6874 = load float, float* %6873, align 4
  %6875 = insertelement <4 x float> %6872, float %6874, i32 2
  %6876 = insertelement <4 x float> %6875, float 0.000000e+00, i32 3
  %6877 = call <4 x float> @llvm.fma.f32.154(<4 x float> %6868, <4 x float> %6876, <4 x float> %6856)
  %6878 = extractelement <4 x float> %6877, i32 0
  %6879 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6880 = getelementptr inbounds i8, i8* %6879, i64 32
  %6881 = bitcast i8* %6880 to float*
  store float %6878, float* %6881, align 4
  %6882 = extractelement <4 x float> %6877, i32 1
  %6883 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6884 = getelementptr inbounds i8, i8* %6883, i64 36
  %6885 = bitcast i8* %6884 to float*
  store float %6882, float* %6885, align 4
  %6886 = extractelement <4 x float> %6877, i32 2
  %6887 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6888 = getelementptr inbounds i8, i8* %6887, i64 36
  %6889 = bitcast i8* %6888 to float*
  store float %6886, float* %6889, align 4
  %6890 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6891 = getelementptr inbounds i8, i8* %6890, i64 36
  %6892 = bitcast i8* %6891 to float*
  %6893 = load float, float* %6892, align 4
  %6894 = insertelement <4 x float> zeroinitializer, float %6893, i32 0
  %6895 = insertelement <4 x float> %6894, float 0.000000e+00, i32 1
  %6896 = insertelement <4 x float> %6895, float 0.000000e+00, i32 2
  %6897 = insertelement <4 x float> %6896, float 0.000000e+00, i32 3
  %6898 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6899 = getelementptr inbounds i8, i8* %6898, i64 36
  %6900 = bitcast i8* %6899 to float*
  %6901 = load float, float* %6900, align 4
  %6902 = insertelement <4 x float> zeroinitializer, float %6901, i32 0
  %6903 = insertelement <4 x float> %6902, float 0.000000e+00, i32 1
  %6904 = insertelement <4 x float> %6903, float 0.000000e+00, i32 2
  %6905 = insertelement <4 x float> %6904, float 0.000000e+00, i32 3
  %6906 = getelementptr inbounds float, float* %1, i64 5
  %6907 = load float, float* %6906, align 4
  %6908 = insertelement <4 x float> zeroinitializer, float %6907, i32 0
  %6909 = insertelement <4 x float> %6908, float 0.000000e+00, i32 1
  %6910 = insertelement <4 x float> %6909, float 0.000000e+00, i32 2
  %6911 = insertelement <4 x float> %6910, float 0.000000e+00, i32 3
  %6912 = call <4 x float> @llvm.fma.f32.155(<4 x float> %6905, <4 x float> %6911, <4 x float> %6897)
  %6913 = extractelement <4 x float> %6912, i32 0
  %6914 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6915 = getelementptr inbounds i8, i8* %6914, i64 36
  %6916 = bitcast i8* %6915 to float*
  store float %6913, float* %6916, align 4
  %6917 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6918 = getelementptr inbounds i8, i8* %6917, i64 36
  %6919 = bitcast i8* %6918 to float*
  %6920 = load float, float* %6919, align 4
  %6921 = insertelement <4 x float> zeroinitializer, float %6920, i32 0
  %6922 = insertelement <4 x float> %6921, float 0.000000e+00, i32 1
  %6923 = insertelement <4 x float> %6922, float 0.000000e+00, i32 2
  %6924 = insertelement <4 x float> %6923, float 0.000000e+00, i32 3
  %6925 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6926 = getelementptr inbounds i8, i8* %6925, i64 40
  %6927 = bitcast i8* %6926 to float*
  %6928 = load float, float* %6927, align 4
  %6929 = insertelement <4 x float> zeroinitializer, float %6928, i32 0
  %6930 = insertelement <4 x float> %6929, float 0.000000e+00, i32 1
  %6931 = insertelement <4 x float> %6930, float 0.000000e+00, i32 2
  %6932 = insertelement <4 x float> %6931, float 0.000000e+00, i32 3
  %6933 = getelementptr inbounds float, float* %1, i64 9
  %6934 = load float, float* %6933, align 4
  %6935 = insertelement <4 x float> zeroinitializer, float %6934, i32 0
  %6936 = insertelement <4 x float> %6935, float 0.000000e+00, i32 1
  %6937 = insertelement <4 x float> %6936, float 0.000000e+00, i32 2
  %6938 = insertelement <4 x float> %6937, float 0.000000e+00, i32 3
  %6939 = call <4 x float> @llvm.fma.f32.156(<4 x float> %6932, <4 x float> %6938, <4 x float> %6924)
  %6940 = extractelement <4 x float> %6939, i32 0
  %6941 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6942 = getelementptr inbounds i8, i8* %6941, i64 36
  %6943 = bitcast i8* %6942 to float*
  store float %6940, float* %6943, align 4
  %6944 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6945 = getelementptr inbounds i8, i8* %6944, i64 36
  %6946 = bitcast i8* %6945 to float*
  %6947 = load float, float* %6946, align 4
  %6948 = insertelement <4 x float> zeroinitializer, float %6947, i32 0
  %6949 = insertelement <4 x float> %6948, float 0.000000e+00, i32 1
  %6950 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6951 = getelementptr inbounds i8, i8* %6950, i64 40
  %6952 = bitcast i8* %6951 to float*
  %6953 = load float, float* %6952, align 4
  %6954 = insertelement <4 x float> %6949, float %6953, i32 2
  %6955 = insertelement <4 x float> %6954, float 0.000000e+00, i32 3
  %6956 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6957 = getelementptr inbounds i8, i8* %6956, i64 44
  %6958 = bitcast i8* %6957 to float*
  %6959 = load float, float* %6958, align 4
  %6960 = insertelement <4 x float> zeroinitializer, float %6959, i32 0
  %6961 = insertelement <4 x float> %6960, float 0.000000e+00, i32 1
  %6962 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6963 = getelementptr inbounds i8, i8* %6962, i64 32
  %6964 = bitcast i8* %6963 to float*
  %6965 = load float, float* %6964, align 4
  %6966 = insertelement <4 x float> %6961, float %6965, i32 2
  %6967 = insertelement <4 x float> %6966, float 0.000000e+00, i32 3
  %6968 = getelementptr inbounds float, float* %1, i64 13
  %6969 = load float, float* %6968, align 4
  %6970 = insertelement <4 x float> zeroinitializer, float %6969, i32 0
  %6971 = insertelement <4 x float> %6970, float 0.000000e+00, i32 1
  %6972 = getelementptr inbounds float, float* %1, i64 2
  %6973 = load float, float* %6972, align 4
  %6974 = insertelement <4 x float> %6971, float %6973, i32 2
  %6975 = insertelement <4 x float> %6974, float 0.000000e+00, i32 3
  %6976 = call <4 x float> @llvm.fma.f32.157(<4 x float> %6967, <4 x float> %6975, <4 x float> %6955)
  %6977 = extractelement <4 x float> %6976, i32 0
  %6978 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6979 = getelementptr inbounds i8, i8* %6978, i64 36
  %6980 = bitcast i8* %6979 to float*
  store float %6977, float* %6980, align 4
  %6981 = extractelement <4 x float> %6976, i32 1
  %6982 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6983 = getelementptr inbounds i8, i8* %6982, i64 40
  %6984 = bitcast i8* %6983 to float*
  store float %6981, float* %6984, align 4
  %6985 = extractelement <4 x float> %6976, i32 2
  %6986 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6987 = getelementptr inbounds i8, i8* %6986, i64 40
  %6988 = bitcast i8* %6987 to float*
  store float %6985, float* %6988, align 4
  %6989 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6990 = getelementptr inbounds i8, i8* %6989, i64 40
  %6991 = bitcast i8* %6990 to float*
  %6992 = load float, float* %6991, align 4
  %6993 = insertelement <4 x float> zeroinitializer, float %6992, i32 0
  %6994 = insertelement <4 x float> %6993, float 0.000000e+00, i32 1
  %6995 = insertelement <4 x float> %6994, float 0.000000e+00, i32 2
  %6996 = insertelement <4 x float> %6995, float 0.000000e+00, i32 3
  %6997 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %6998 = getelementptr inbounds i8, i8* %6997, i64 36
  %6999 = bitcast i8* %6998 to float*
  %7000 = load float, float* %6999, align 4
  %7001 = insertelement <4 x float> zeroinitializer, float %7000, i32 0
  %7002 = insertelement <4 x float> %7001, float 0.000000e+00, i32 1
  %7003 = insertelement <4 x float> %7002, float 0.000000e+00, i32 2
  %7004 = insertelement <4 x float> %7003, float 0.000000e+00, i32 3
  %7005 = getelementptr inbounds float, float* %1, i64 6
  %7006 = load float, float* %7005, align 4
  %7007 = insertelement <4 x float> zeroinitializer, float %7006, i32 0
  %7008 = insertelement <4 x float> %7007, float 0.000000e+00, i32 1
  %7009 = insertelement <4 x float> %7008, float 0.000000e+00, i32 2
  %7010 = insertelement <4 x float> %7009, float 0.000000e+00, i32 3
  %7011 = call <4 x float> @llvm.fma.f32.158(<4 x float> %7004, <4 x float> %7010, <4 x float> %6996)
  %7012 = extractelement <4 x float> %7011, i32 0
  %7013 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7014 = getelementptr inbounds i8, i8* %7013, i64 40
  %7015 = bitcast i8* %7014 to float*
  store float %7012, float* %7015, align 4
  %7016 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7017 = getelementptr inbounds i8, i8* %7016, i64 40
  %7018 = bitcast i8* %7017 to float*
  %7019 = load float, float* %7018, align 4
  %7020 = insertelement <4 x float> zeroinitializer, float %7019, i32 0
  %7021 = insertelement <4 x float> %7020, float 0.000000e+00, i32 1
  %7022 = insertelement <4 x float> %7021, float 0.000000e+00, i32 2
  %7023 = insertelement <4 x float> %7022, float 0.000000e+00, i32 3
  %7024 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7025 = getelementptr inbounds i8, i8* %7024, i64 40
  %7026 = bitcast i8* %7025 to float*
  %7027 = load float, float* %7026, align 4
  %7028 = insertelement <4 x float> zeroinitializer, float %7027, i32 0
  %7029 = insertelement <4 x float> %7028, float 0.000000e+00, i32 1
  %7030 = insertelement <4 x float> %7029, float 0.000000e+00, i32 2
  %7031 = insertelement <4 x float> %7030, float 0.000000e+00, i32 3
  %7032 = getelementptr inbounds float, float* %1, i64 10
  %7033 = load float, float* %7032, align 4
  %7034 = insertelement <4 x float> zeroinitializer, float %7033, i32 0
  %7035 = insertelement <4 x float> %7034, float 0.000000e+00, i32 1
  %7036 = insertelement <4 x float> %7035, float 0.000000e+00, i32 2
  %7037 = insertelement <4 x float> %7036, float 0.000000e+00, i32 3
  %7038 = call <4 x float> @llvm.fma.f32.159(<4 x float> %7031, <4 x float> %7037, <4 x float> %7023)
  %7039 = extractelement <4 x float> %7038, i32 0
  %7040 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7041 = getelementptr inbounds i8, i8* %7040, i64 40
  %7042 = bitcast i8* %7041 to float*
  store float %7039, float* %7042, align 4
  %7043 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7044 = getelementptr inbounds i8, i8* %7043, i64 40
  %7045 = bitcast i8* %7044 to float*
  %7046 = load float, float* %7045, align 4
  %7047 = insertelement <4 x float> zeroinitializer, float %7046, i32 0
  %7048 = insertelement <4 x float> %7047, float 0.000000e+00, i32 1
  %7049 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7050 = getelementptr inbounds i8, i8* %7049, i64 44
  %7051 = bitcast i8* %7050 to float*
  %7052 = load float, float* %7051, align 4
  %7053 = insertelement <4 x float> %7048, float %7052, i32 2
  %7054 = insertelement <4 x float> %7053, float 0.000000e+00, i32 3
  %7055 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7056 = getelementptr inbounds i8, i8* %7055, i64 44
  %7057 = bitcast i8* %7056 to float*
  %7058 = load float, float* %7057, align 4
  %7059 = insertelement <4 x float> zeroinitializer, float %7058, i32 0
  %7060 = insertelement <4 x float> %7059, float 0.000000e+00, i32 1
  %7061 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7062 = getelementptr inbounds i8, i8* %7061, i64 32
  %7063 = bitcast i8* %7062 to float*
  %7064 = load float, float* %7063, align 4
  %7065 = insertelement <4 x float> %7060, float %7064, i32 2
  %7066 = insertelement <4 x float> %7065, float 0.000000e+00, i32 3
  %7067 = getelementptr inbounds float, float* %1, i64 14
  %7068 = load float, float* %7067, align 4
  %7069 = insertelement <4 x float> zeroinitializer, float %7068, i32 0
  %7070 = insertelement <4 x float> %7069, float 0.000000e+00, i32 1
  %7071 = getelementptr inbounds float, float* %1, i64 3
  %7072 = load float, float* %7071, align 4
  %7073 = insertelement <4 x float> %7070, float %7072, i32 2
  %7074 = insertelement <4 x float> %7073, float 0.000000e+00, i32 3
  %7075 = call <4 x float> @llvm.fma.f32.160(<4 x float> %7066, <4 x float> %7074, <4 x float> %7054)
  %7076 = extractelement <4 x float> %7075, i32 0
  %7077 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7078 = getelementptr inbounds i8, i8* %7077, i64 40
  %7079 = bitcast i8* %7078 to float*
  store float %7076, float* %7079, align 4
  %7080 = extractelement <4 x float> %7075, i32 1
  %7081 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7082 = getelementptr inbounds i8, i8* %7081, i64 44
  %7083 = bitcast i8* %7082 to float*
  store float %7080, float* %7083, align 4
  %7084 = extractelement <4 x float> %7075, i32 2
  %7085 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7086 = getelementptr inbounds i8, i8* %7085, i64 44
  %7087 = bitcast i8* %7086 to float*
  store float %7084, float* %7087, align 4
  %7088 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7089 = getelementptr inbounds i8, i8* %7088, i64 44
  %7090 = bitcast i8* %7089 to float*
  %7091 = load float, float* %7090, align 4
  %7092 = insertelement <4 x float> zeroinitializer, float %7091, i32 0
  %7093 = insertelement <4 x float> %7092, float 0.000000e+00, i32 1
  %7094 = insertelement <4 x float> %7093, float 0.000000e+00, i32 2
  %7095 = insertelement <4 x float> %7094, float 0.000000e+00, i32 3
  %7096 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7097 = getelementptr inbounds i8, i8* %7096, i64 36
  %7098 = bitcast i8* %7097 to float*
  %7099 = load float, float* %7098, align 4
  %7100 = insertelement <4 x float> zeroinitializer, float %7099, i32 0
  %7101 = insertelement <4 x float> %7100, float 0.000000e+00, i32 1
  %7102 = insertelement <4 x float> %7101, float 0.000000e+00, i32 2
  %7103 = insertelement <4 x float> %7102, float 0.000000e+00, i32 3
  %7104 = getelementptr inbounds float, float* %1, i64 7
  %7105 = load float, float* %7104, align 4
  %7106 = insertelement <4 x float> zeroinitializer, float %7105, i32 0
  %7107 = insertelement <4 x float> %7106, float 0.000000e+00, i32 1
  %7108 = insertelement <4 x float> %7107, float 0.000000e+00, i32 2
  %7109 = insertelement <4 x float> %7108, float 0.000000e+00, i32 3
  %7110 = call <4 x float> @llvm.fma.f32.161(<4 x float> %7103, <4 x float> %7109, <4 x float> %7095)
  %7111 = extractelement <4 x float> %7110, i32 0
  %7112 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7113 = getelementptr inbounds i8, i8* %7112, i64 44
  %7114 = bitcast i8* %7113 to float*
  store float %7111, float* %7114, align 4
  %7115 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7116 = getelementptr inbounds i8, i8* %7115, i64 44
  %7117 = bitcast i8* %7116 to float*
  %7118 = load float, float* %7117, align 4
  %7119 = insertelement <4 x float> zeroinitializer, float %7118, i32 0
  %7120 = insertelement <4 x float> %7119, float 0.000000e+00, i32 1
  %7121 = insertelement <4 x float> %7120, float 0.000000e+00, i32 2
  %7122 = insertelement <4 x float> %7121, float 0.000000e+00, i32 3
  %7123 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7124 = getelementptr inbounds i8, i8* %7123, i64 40
  %7125 = bitcast i8* %7124 to float*
  %7126 = load float, float* %7125, align 4
  %7127 = insertelement <4 x float> zeroinitializer, float %7126, i32 0
  %7128 = insertelement <4 x float> %7127, float 0.000000e+00, i32 1
  %7129 = insertelement <4 x float> %7128, float 0.000000e+00, i32 2
  %7130 = insertelement <4 x float> %7129, float 0.000000e+00, i32 3
  %7131 = getelementptr inbounds float, float* %1, i64 11
  %7132 = load float, float* %7131, align 4
  %7133 = insertelement <4 x float> zeroinitializer, float %7132, i32 0
  %7134 = insertelement <4 x float> %7133, float 0.000000e+00, i32 1
  %7135 = insertelement <4 x float> %7134, float 0.000000e+00, i32 2
  %7136 = insertelement <4 x float> %7135, float 0.000000e+00, i32 3
  %7137 = call <4 x float> @llvm.fma.f32.162(<4 x float> %7130, <4 x float> %7136, <4 x float> %7122)
  %7138 = extractelement <4 x float> %7137, i32 0
  %7139 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7140 = getelementptr inbounds i8, i8* %7139, i64 44
  %7141 = bitcast i8* %7140 to float*
  store float %7138, float* %7141, align 4
  %7142 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7143 = getelementptr inbounds i8, i8* %7142, i64 44
  %7144 = bitcast i8* %7143 to float*
  %7145 = load float, float* %7144, align 4
  %7146 = insertelement <4 x float> zeroinitializer, float %7145, i32 0
  %7147 = insertelement <4 x float> %7146, float 0.000000e+00, i32 1
  %7148 = insertelement <4 x float> %7147, float 0.000000e+00, i32 2
  %7149 = insertelement <4 x float> %7148, float 0.000000e+00, i32 3
  %7150 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7151 = getelementptr inbounds i8, i8* %7150, i64 44
  %7152 = bitcast i8* %7151 to float*
  %7153 = load float, float* %7152, align 4
  %7154 = insertelement <4 x float> zeroinitializer, float %7153, i32 0
  %7155 = insertelement <4 x float> %7154, float 0.000000e+00, i32 1
  %7156 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7157 = getelementptr inbounds i8, i8* %7156, i64 48
  %7158 = bitcast i8* %7157 to float*
  %7159 = load float, float* %7158, align 4
  %7160 = insertelement <4 x float> %7155, float %7159, i32 2
  %7161 = insertelement <4 x float> %7160, float 0.000000e+00, i32 3
  %7162 = getelementptr inbounds float, float* %1, i64 15
  %7163 = load float, float* %7162, align 4
  %7164 = insertelement <4 x float> zeroinitializer, float %7163, i32 0
  %7165 = insertelement <4 x float> %7164, float 0.000000e+00, i32 1
  %7166 = load float, float* %1, align 4
  %7167 = insertelement <4 x float> %7165, float %7166, i32 2
  %7168 = insertelement <4 x float> %7167, float 0.000000e+00, i32 3
  %7169 = call <4 x float> @llvm.fma.f32.163(<4 x float> %7161, <4 x float> %7168, <4 x float> %7149)
  %7170 = extractelement <4 x float> %7169, i32 0
  %7171 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7172 = getelementptr inbounds i8, i8* %7171, i64 44
  %7173 = bitcast i8* %7172 to float*
  store float %7170, float* %7173, align 4
  %7174 = extractelement <4 x float> %7169, i32 1
  %7175 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7176 = getelementptr inbounds i8, i8* %7175, i64 48
  %7177 = bitcast i8* %7176 to float*
  store float %7174, float* %7177, align 4
  %7178 = extractelement <4 x float> %7169, i32 2
  %7179 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7180 = getelementptr inbounds i8, i8* %7179, i64 48
  %7181 = bitcast i8* %7180 to float*
  store float %7178, float* %7181, align 4
  %7182 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7183 = getelementptr inbounds i8, i8* %7182, i64 48
  %7184 = bitcast i8* %7183 to float*
  %7185 = load float, float* %7184, align 4
  %7186 = insertelement <4 x float> zeroinitializer, float %7185, i32 0
  %7187 = insertelement <4 x float> %7186, float 0.000000e+00, i32 1
  %7188 = insertelement <4 x float> %7187, float 0.000000e+00, i32 2
  %7189 = insertelement <4 x float> %7188, float 0.000000e+00, i32 3
  %7190 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7191 = getelementptr inbounds i8, i8* %7190, i64 52
  %7192 = bitcast i8* %7191 to float*
  %7193 = load float, float* %7192, align 4
  %7194 = insertelement <4 x float> zeroinitializer, float %7193, i32 0
  %7195 = insertelement <4 x float> %7194, float 0.000000e+00, i32 1
  %7196 = insertelement <4 x float> %7195, float 0.000000e+00, i32 2
  %7197 = insertelement <4 x float> %7196, float 0.000000e+00, i32 3
  %7198 = getelementptr inbounds float, float* %1, i64 4
  %7199 = load float, float* %7198, align 4
  %7200 = insertelement <4 x float> zeroinitializer, float %7199, i32 0
  %7201 = insertelement <4 x float> %7200, float 0.000000e+00, i32 1
  %7202 = insertelement <4 x float> %7201, float 0.000000e+00, i32 2
  %7203 = insertelement <4 x float> %7202, float 0.000000e+00, i32 3
  %7204 = call <4 x float> @llvm.fma.f32.164(<4 x float> %7197, <4 x float> %7203, <4 x float> %7189)
  %7205 = extractelement <4 x float> %7204, i32 0
  %7206 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7207 = getelementptr inbounds i8, i8* %7206, i64 48
  %7208 = bitcast i8* %7207 to float*
  store float %7205, float* %7208, align 4
  %7209 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7210 = getelementptr inbounds i8, i8* %7209, i64 48
  %7211 = bitcast i8* %7210 to float*
  %7212 = load float, float* %7211, align 4
  %7213 = insertelement <4 x float> zeroinitializer, float %7212, i32 0
  %7214 = insertelement <4 x float> %7213, float 0.000000e+00, i32 1
  %7215 = insertelement <4 x float> %7214, float 0.000000e+00, i32 2
  %7216 = insertelement <4 x float> %7215, float 0.000000e+00, i32 3
  %7217 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7218 = getelementptr inbounds i8, i8* %7217, i64 56
  %7219 = bitcast i8* %7218 to float*
  %7220 = load float, float* %7219, align 4
  %7221 = insertelement <4 x float> zeroinitializer, float %7220, i32 0
  %7222 = insertelement <4 x float> %7221, float 0.000000e+00, i32 1
  %7223 = insertelement <4 x float> %7222, float 0.000000e+00, i32 2
  %7224 = insertelement <4 x float> %7223, float 0.000000e+00, i32 3
  %7225 = getelementptr inbounds float, float* %1, i64 8
  %7226 = load float, float* %7225, align 4
  %7227 = insertelement <4 x float> zeroinitializer, float %7226, i32 0
  %7228 = insertelement <4 x float> %7227, float 0.000000e+00, i32 1
  %7229 = insertelement <4 x float> %7228, float 0.000000e+00, i32 2
  %7230 = insertelement <4 x float> %7229, float 0.000000e+00, i32 3
  %7231 = call <4 x float> @llvm.fma.f32.165(<4 x float> %7224, <4 x float> %7230, <4 x float> %7216)
  %7232 = extractelement <4 x float> %7231, i32 0
  %7233 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7234 = getelementptr inbounds i8, i8* %7233, i64 48
  %7235 = bitcast i8* %7234 to float*
  store float %7232, float* %7235, align 4
  %7236 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7237 = getelementptr inbounds i8, i8* %7236, i64 48
  %7238 = bitcast i8* %7237 to float*
  %7239 = load float, float* %7238, align 4
  %7240 = insertelement <4 x float> zeroinitializer, float %7239, i32 0
  %7241 = insertelement <4 x float> %7240, float 0.000000e+00, i32 1
  %7242 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7243 = getelementptr inbounds i8, i8* %7242, i64 52
  %7244 = bitcast i8* %7243 to float*
  %7245 = load float, float* %7244, align 4
  %7246 = insertelement <4 x float> %7241, float %7245, i32 2
  %7247 = insertelement <4 x float> %7246, float 0.000000e+00, i32 3
  %7248 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7249 = getelementptr inbounds i8, i8* %7248, i64 60
  %7250 = bitcast i8* %7249 to float*
  %7251 = load float, float* %7250, align 4
  %7252 = insertelement <4 x float> zeroinitializer, float %7251, i32 0
  %7253 = insertelement <4 x float> %7252, float 0.000000e+00, i32 1
  %7254 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7255 = getelementptr inbounds i8, i8* %7254, i64 48
  %7256 = bitcast i8* %7255 to float*
  %7257 = load float, float* %7256, align 4
  %7258 = insertelement <4 x float> %7253, float %7257, i32 2
  %7259 = insertelement <4 x float> %7258, float 0.000000e+00, i32 3
  %7260 = getelementptr inbounds float, float* %1, i64 12
  %7261 = load float, float* %7260, align 4
  %7262 = insertelement <4 x float> zeroinitializer, float %7261, i32 0
  %7263 = insertelement <4 x float> %7262, float 0.000000e+00, i32 1
  %7264 = getelementptr inbounds float, float* %1, i64 1
  %7265 = load float, float* %7264, align 4
  %7266 = insertelement <4 x float> %7263, float %7265, i32 2
  %7267 = insertelement <4 x float> %7266, float 0.000000e+00, i32 3
  %7268 = call <4 x float> @llvm.fma.f32.166(<4 x float> %7259, <4 x float> %7267, <4 x float> %7247)
  %7269 = extractelement <4 x float> %7268, i32 0
  %7270 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7271 = getelementptr inbounds i8, i8* %7270, i64 48
  %7272 = bitcast i8* %7271 to float*
  store float %7269, float* %7272, align 4
  %7273 = extractelement <4 x float> %7268, i32 1
  %7274 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7275 = getelementptr inbounds i8, i8* %7274, i64 52
  %7276 = bitcast i8* %7275 to float*
  store float %7273, float* %7276, align 4
  %7277 = extractelement <4 x float> %7268, i32 2
  %7278 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7279 = getelementptr inbounds i8, i8* %7278, i64 52
  %7280 = bitcast i8* %7279 to float*
  store float %7277, float* %7280, align 4
  %7281 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7282 = getelementptr inbounds i8, i8* %7281, i64 52
  %7283 = bitcast i8* %7282 to float*
  %7284 = load float, float* %7283, align 4
  %7285 = insertelement <4 x float> zeroinitializer, float %7284, i32 0
  %7286 = insertelement <4 x float> %7285, float 0.000000e+00, i32 1
  %7287 = insertelement <4 x float> %7286, float 0.000000e+00, i32 2
  %7288 = insertelement <4 x float> %7287, float 0.000000e+00, i32 3
  %7289 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7290 = getelementptr inbounds i8, i8* %7289, i64 52
  %7291 = bitcast i8* %7290 to float*
  %7292 = load float, float* %7291, align 4
  %7293 = insertelement <4 x float> zeroinitializer, float %7292, i32 0
  %7294 = insertelement <4 x float> %7293, float 0.000000e+00, i32 1
  %7295 = insertelement <4 x float> %7294, float 0.000000e+00, i32 2
  %7296 = insertelement <4 x float> %7295, float 0.000000e+00, i32 3
  %7297 = getelementptr inbounds float, float* %1, i64 5
  %7298 = load float, float* %7297, align 4
  %7299 = insertelement <4 x float> zeroinitializer, float %7298, i32 0
  %7300 = insertelement <4 x float> %7299, float 0.000000e+00, i32 1
  %7301 = insertelement <4 x float> %7300, float 0.000000e+00, i32 2
  %7302 = insertelement <4 x float> %7301, float 0.000000e+00, i32 3
  %7303 = call <4 x float> @llvm.fma.f32.167(<4 x float> %7296, <4 x float> %7302, <4 x float> %7288)
  %7304 = extractelement <4 x float> %7303, i32 0
  %7305 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7306 = getelementptr inbounds i8, i8* %7305, i64 52
  %7307 = bitcast i8* %7306 to float*
  store float %7304, float* %7307, align 4
  %7308 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7309 = getelementptr inbounds i8, i8* %7308, i64 52
  %7310 = bitcast i8* %7309 to float*
  %7311 = load float, float* %7310, align 4
  %7312 = insertelement <4 x float> zeroinitializer, float %7311, i32 0
  %7313 = insertelement <4 x float> %7312, float 0.000000e+00, i32 1
  %7314 = insertelement <4 x float> %7313, float 0.000000e+00, i32 2
  %7315 = insertelement <4 x float> %7314, float 0.000000e+00, i32 3
  %7316 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7317 = getelementptr inbounds i8, i8* %7316, i64 56
  %7318 = bitcast i8* %7317 to float*
  %7319 = load float, float* %7318, align 4
  %7320 = insertelement <4 x float> zeroinitializer, float %7319, i32 0
  %7321 = insertelement <4 x float> %7320, float 0.000000e+00, i32 1
  %7322 = insertelement <4 x float> %7321, float 0.000000e+00, i32 2
  %7323 = insertelement <4 x float> %7322, float 0.000000e+00, i32 3
  %7324 = getelementptr inbounds float, float* %1, i64 9
  %7325 = load float, float* %7324, align 4
  %7326 = insertelement <4 x float> zeroinitializer, float %7325, i32 0
  %7327 = insertelement <4 x float> %7326, float 0.000000e+00, i32 1
  %7328 = insertelement <4 x float> %7327, float 0.000000e+00, i32 2
  %7329 = insertelement <4 x float> %7328, float 0.000000e+00, i32 3
  %7330 = call <4 x float> @llvm.fma.f32.168(<4 x float> %7323, <4 x float> %7329, <4 x float> %7315)
  %7331 = extractelement <4 x float> %7330, i32 0
  %7332 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7333 = getelementptr inbounds i8, i8* %7332, i64 52
  %7334 = bitcast i8* %7333 to float*
  store float %7331, float* %7334, align 4
  %7335 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7336 = getelementptr inbounds i8, i8* %7335, i64 52
  %7337 = bitcast i8* %7336 to float*
  %7338 = load float, float* %7337, align 4
  %7339 = insertelement <4 x float> zeroinitializer, float %7338, i32 0
  %7340 = insertelement <4 x float> %7339, float 0.000000e+00, i32 1
  %7341 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7342 = getelementptr inbounds i8, i8* %7341, i64 56
  %7343 = bitcast i8* %7342 to float*
  %7344 = load float, float* %7343, align 4
  %7345 = insertelement <4 x float> %7340, float %7344, i32 2
  %7346 = insertelement <4 x float> %7345, float 0.000000e+00, i32 3
  %7347 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7348 = getelementptr inbounds i8, i8* %7347, i64 60
  %7349 = bitcast i8* %7348 to float*
  %7350 = load float, float* %7349, align 4
  %7351 = insertelement <4 x float> zeroinitializer, float %7350, i32 0
  %7352 = insertelement <4 x float> %7351, float 0.000000e+00, i32 1
  %7353 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7354 = getelementptr inbounds i8, i8* %7353, i64 48
  %7355 = bitcast i8* %7354 to float*
  %7356 = load float, float* %7355, align 4
  %7357 = insertelement <4 x float> %7352, float %7356, i32 2
  %7358 = insertelement <4 x float> %7357, float 0.000000e+00, i32 3
  %7359 = getelementptr inbounds float, float* %1, i64 13
  %7360 = load float, float* %7359, align 4
  %7361 = insertelement <4 x float> zeroinitializer, float %7360, i32 0
  %7362 = insertelement <4 x float> %7361, float 0.000000e+00, i32 1
  %7363 = getelementptr inbounds float, float* %1, i64 2
  %7364 = load float, float* %7363, align 4
  %7365 = insertelement <4 x float> %7362, float %7364, i32 2
  %7366 = insertelement <4 x float> %7365, float 0.000000e+00, i32 3
  %7367 = call <4 x float> @llvm.fma.f32.169(<4 x float> %7358, <4 x float> %7366, <4 x float> %7346)
  %7368 = extractelement <4 x float> %7367, i32 0
  %7369 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7370 = getelementptr inbounds i8, i8* %7369, i64 52
  %7371 = bitcast i8* %7370 to float*
  store float %7368, float* %7371, align 4
  %7372 = extractelement <4 x float> %7367, i32 1
  %7373 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7374 = getelementptr inbounds i8, i8* %7373, i64 56
  %7375 = bitcast i8* %7374 to float*
  store float %7372, float* %7375, align 4
  %7376 = extractelement <4 x float> %7367, i32 2
  %7377 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7378 = getelementptr inbounds i8, i8* %7377, i64 56
  %7379 = bitcast i8* %7378 to float*
  store float %7376, float* %7379, align 4
  %7380 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7381 = getelementptr inbounds i8, i8* %7380, i64 56
  %7382 = bitcast i8* %7381 to float*
  %7383 = load float, float* %7382, align 4
  %7384 = insertelement <4 x float> zeroinitializer, float %7383, i32 0
  %7385 = insertelement <4 x float> %7384, float 0.000000e+00, i32 1
  %7386 = insertelement <4 x float> %7385, float 0.000000e+00, i32 2
  %7387 = insertelement <4 x float> %7386, float 0.000000e+00, i32 3
  %7388 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7389 = getelementptr inbounds i8, i8* %7388, i64 52
  %7390 = bitcast i8* %7389 to float*
  %7391 = load float, float* %7390, align 4
  %7392 = insertelement <4 x float> zeroinitializer, float %7391, i32 0
  %7393 = insertelement <4 x float> %7392, float 0.000000e+00, i32 1
  %7394 = insertelement <4 x float> %7393, float 0.000000e+00, i32 2
  %7395 = insertelement <4 x float> %7394, float 0.000000e+00, i32 3
  %7396 = getelementptr inbounds float, float* %1, i64 6
  %7397 = load float, float* %7396, align 4
  %7398 = insertelement <4 x float> zeroinitializer, float %7397, i32 0
  %7399 = insertelement <4 x float> %7398, float 0.000000e+00, i32 1
  %7400 = insertelement <4 x float> %7399, float 0.000000e+00, i32 2
  %7401 = insertelement <4 x float> %7400, float 0.000000e+00, i32 3
  %7402 = call <4 x float> @llvm.fma.f32.170(<4 x float> %7395, <4 x float> %7401, <4 x float> %7387)
  %7403 = extractelement <4 x float> %7402, i32 0
  %7404 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7405 = getelementptr inbounds i8, i8* %7404, i64 56
  %7406 = bitcast i8* %7405 to float*
  store float %7403, float* %7406, align 4
  %7407 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7408 = getelementptr inbounds i8, i8* %7407, i64 56
  %7409 = bitcast i8* %7408 to float*
  %7410 = load float, float* %7409, align 4
  %7411 = insertelement <4 x float> zeroinitializer, float %7410, i32 0
  %7412 = insertelement <4 x float> %7411, float 0.000000e+00, i32 1
  %7413 = insertelement <4 x float> %7412, float 0.000000e+00, i32 2
  %7414 = insertelement <4 x float> %7413, float 0.000000e+00, i32 3
  %7415 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7416 = getelementptr inbounds i8, i8* %7415, i64 56
  %7417 = bitcast i8* %7416 to float*
  %7418 = load float, float* %7417, align 4
  %7419 = insertelement <4 x float> zeroinitializer, float %7418, i32 0
  %7420 = insertelement <4 x float> %7419, float 0.000000e+00, i32 1
  %7421 = insertelement <4 x float> %7420, float 0.000000e+00, i32 2
  %7422 = insertelement <4 x float> %7421, float 0.000000e+00, i32 3
  %7423 = getelementptr inbounds float, float* %1, i64 10
  %7424 = load float, float* %7423, align 4
  %7425 = insertelement <4 x float> zeroinitializer, float %7424, i32 0
  %7426 = insertelement <4 x float> %7425, float 0.000000e+00, i32 1
  %7427 = insertelement <4 x float> %7426, float 0.000000e+00, i32 2
  %7428 = insertelement <4 x float> %7427, float 0.000000e+00, i32 3
  %7429 = call <4 x float> @llvm.fma.f32.171(<4 x float> %7422, <4 x float> %7428, <4 x float> %7414)
  %7430 = extractelement <4 x float> %7429, i32 0
  %7431 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7432 = getelementptr inbounds i8, i8* %7431, i64 56
  %7433 = bitcast i8* %7432 to float*
  store float %7430, float* %7433, align 4
  %7434 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7435 = getelementptr inbounds i8, i8* %7434, i64 56
  %7436 = bitcast i8* %7435 to float*
  %7437 = load float, float* %7436, align 4
  %7438 = insertelement <4 x float> zeroinitializer, float %7437, i32 0
  %7439 = insertelement <4 x float> %7438, float 0.000000e+00, i32 1
  %7440 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7441 = getelementptr inbounds i8, i8* %7440, i64 60
  %7442 = bitcast i8* %7441 to float*
  %7443 = load float, float* %7442, align 4
  %7444 = insertelement <4 x float> %7439, float %7443, i32 2
  %7445 = insertelement <4 x float> %7444, float 0.000000e+00, i32 3
  %7446 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7447 = getelementptr inbounds i8, i8* %7446, i64 60
  %7448 = bitcast i8* %7447 to float*
  %7449 = load float, float* %7448, align 4
  %7450 = insertelement <4 x float> zeroinitializer, float %7449, i32 0
  %7451 = insertelement <4 x float> %7450, float 0.000000e+00, i32 1
  %7452 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7453 = getelementptr inbounds i8, i8* %7452, i64 48
  %7454 = bitcast i8* %7453 to float*
  %7455 = load float, float* %7454, align 4
  %7456 = insertelement <4 x float> %7451, float %7455, i32 2
  %7457 = insertelement <4 x float> %7456, float 0.000000e+00, i32 3
  %7458 = getelementptr inbounds float, float* %1, i64 14
  %7459 = load float, float* %7458, align 4
  %7460 = insertelement <4 x float> zeroinitializer, float %7459, i32 0
  %7461 = insertelement <4 x float> %7460, float 0.000000e+00, i32 1
  %7462 = getelementptr inbounds float, float* %1, i64 3
  %7463 = load float, float* %7462, align 4
  %7464 = insertelement <4 x float> %7461, float %7463, i32 2
  %7465 = insertelement <4 x float> %7464, float 0.000000e+00, i32 3
  %7466 = call <4 x float> @llvm.fma.f32.172(<4 x float> %7457, <4 x float> %7465, <4 x float> %7445)
  %7467 = extractelement <4 x float> %7466, i32 0
  %7468 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7469 = getelementptr inbounds i8, i8* %7468, i64 56
  %7470 = bitcast i8* %7469 to float*
  store float %7467, float* %7470, align 4
  %7471 = extractelement <4 x float> %7466, i32 1
  %7472 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7473 = getelementptr inbounds i8, i8* %7472, i64 60
  %7474 = bitcast i8* %7473 to float*
  store float %7471, float* %7474, align 4
  %7475 = extractelement <4 x float> %7466, i32 2
  %7476 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7477 = getelementptr inbounds i8, i8* %7476, i64 60
  %7478 = bitcast i8* %7477 to float*
  store float %7475, float* %7478, align 4
  %7479 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7480 = getelementptr inbounds i8, i8* %7479, i64 60
  %7481 = bitcast i8* %7480 to float*
  %7482 = load float, float* %7481, align 4
  %7483 = insertelement <4 x float> zeroinitializer, float %7482, i32 0
  %7484 = insertelement <4 x float> %7483, float 0.000000e+00, i32 1
  %7485 = insertelement <4 x float> %7484, float 0.000000e+00, i32 2
  %7486 = insertelement <4 x float> %7485, float 0.000000e+00, i32 3
  %7487 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7488 = getelementptr inbounds i8, i8* %7487, i64 52
  %7489 = bitcast i8* %7488 to float*
  %7490 = load float, float* %7489, align 4
  %7491 = insertelement <4 x float> zeroinitializer, float %7490, i32 0
  %7492 = insertelement <4 x float> %7491, float 0.000000e+00, i32 1
  %7493 = insertelement <4 x float> %7492, float 0.000000e+00, i32 2
  %7494 = insertelement <4 x float> %7493, float 0.000000e+00, i32 3
  %7495 = getelementptr inbounds float, float* %1, i64 7
  %7496 = load float, float* %7495, align 4
  %7497 = insertelement <4 x float> zeroinitializer, float %7496, i32 0
  %7498 = insertelement <4 x float> %7497, float 0.000000e+00, i32 1
  %7499 = insertelement <4 x float> %7498, float 0.000000e+00, i32 2
  %7500 = insertelement <4 x float> %7499, float 0.000000e+00, i32 3
  %7501 = call <4 x float> @llvm.fma.f32.173(<4 x float> %7494, <4 x float> %7500, <4 x float> %7486)
  %7502 = extractelement <4 x float> %7501, i32 0
  %7503 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7504 = getelementptr inbounds i8, i8* %7503, i64 60
  %7505 = bitcast i8* %7504 to float*
  store float %7502, float* %7505, align 4
  %7506 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7507 = getelementptr inbounds i8, i8* %7506, i64 60
  %7508 = bitcast i8* %7507 to float*
  %7509 = load float, float* %7508, align 4
  %7510 = insertelement <4 x float> zeroinitializer, float %7509, i32 0
  %7511 = insertelement <4 x float> %7510, float 0.000000e+00, i32 1
  %7512 = insertelement <4 x float> %7511, float 0.000000e+00, i32 2
  %7513 = insertelement <4 x float> %7512, float 0.000000e+00, i32 3
  %7514 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7515 = getelementptr inbounds i8, i8* %7514, i64 56
  %7516 = bitcast i8* %7515 to float*
  %7517 = load float, float* %7516, align 4
  %7518 = insertelement <4 x float> zeroinitializer, float %7517, i32 0
  %7519 = insertelement <4 x float> %7518, float 0.000000e+00, i32 1
  %7520 = insertelement <4 x float> %7519, float 0.000000e+00, i32 2
  %7521 = insertelement <4 x float> %7520, float 0.000000e+00, i32 3
  %7522 = getelementptr inbounds float, float* %1, i64 11
  %7523 = load float, float* %7522, align 4
  %7524 = insertelement <4 x float> zeroinitializer, float %7523, i32 0
  %7525 = insertelement <4 x float> %7524, float 0.000000e+00, i32 1
  %7526 = insertelement <4 x float> %7525, float 0.000000e+00, i32 2
  %7527 = insertelement <4 x float> %7526, float 0.000000e+00, i32 3
  %7528 = call <4 x float> @llvm.fma.f32.174(<4 x float> %7521, <4 x float> %7527, <4 x float> %7513)
  %7529 = extractelement <4 x float> %7528, i32 0
  %7530 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7531 = getelementptr inbounds i8, i8* %7530, i64 60
  %7532 = bitcast i8* %7531 to float*
  store float %7529, float* %7532, align 4
  %7533 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7534 = getelementptr inbounds i8, i8* %7533, i64 60
  %7535 = bitcast i8* %7534 to float*
  %7536 = load float, float* %7535, align 4
  %7537 = insertelement <4 x float> zeroinitializer, float %7536, i32 0
  %7538 = insertelement <4 x float> %7537, float 0.000000e+00, i32 1
  %7539 = insertelement <4 x float> %7538, float 0.000000e+00, i32 2
  %7540 = insertelement <4 x float> %7539, float 0.000000e+00, i32 3
  %7541 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7542 = getelementptr inbounds i8, i8* %7541, i64 60
  %7543 = bitcast i8* %7542 to float*
  %7544 = load float, float* %7543, align 4
  %7545 = insertelement <4 x float> zeroinitializer, float %7544, i32 0
  %7546 = insertelement <4 x float> %7545, float 0.000000e+00, i32 1
  %7547 = insertelement <4 x float> %7546, float 0.000000e+00, i32 2
  %7548 = insertelement <4 x float> %7547, float 0.000000e+00, i32 3
  %7549 = getelementptr inbounds float, float* %1, i64 15
  %7550 = load float, float* %7549, align 4
  %7551 = insertelement <4 x float> zeroinitializer, float %7550, i32 0
  %7552 = insertelement <4 x float> %7551, float 0.000000e+00, i32 1
  %7553 = insertelement <4 x float> %7552, float 0.000000e+00, i32 2
  %7554 = insertelement <4 x float> %7553, float 0.000000e+00, i32 3
  %7555 = call <4 x float> @llvm.fma.f32.175(<4 x float> %7548, <4 x float> %7554, <4 x float> %7540)
  %7556 = extractelement <4 x float> %7555, i32 0
  %7557 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7558 = getelementptr inbounds i8, i8* %7557, i64 60
  %7559 = bitcast i8* %7558 to float*
  store float %7556, float* %7559, align 4
  %7560 = extractelement <4 x float> %7555, i32 1
  %7561 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7562 = bitcast i8* %7561 to float*
  store float %7560, float* %7562, align 4
  %7563 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7564 = bitcast i8* %7563 to float*
  %7565 = load float, float* %7564, align 4
  %7566 = insertelement <4 x float> zeroinitializer, float %7565, i32 0
  %7567 = insertelement <4 x float> %7566, float 0.000000e+00, i32 1
  %7568 = insertelement <4 x float> %7567, float 0.000000e+00, i32 2
  %7569 = insertelement <4 x float> %7568, float 0.000000e+00, i32 3
  %7570 = load float, float* %2, align 4
  %7571 = insertelement <4 x float> zeroinitializer, float %7570, i32 0
  %7572 = insertelement <4 x float> %7571, float 0.000000e+00, i32 1
  %7573 = insertelement <4 x float> %7572, float 0.000000e+00, i32 2
  %7574 = insertelement <4 x float> %7573, float 0.000000e+00, i32 3
  %7575 = call <4 x float> @llvm.fma.f32.176(<4 x float> %7569, <4 x float> %7574, <4 x float> zeroinitializer)
  %7576 = extractelement <4 x float> %7575, i32 0
  %7577 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7578 = bitcast i8* %7577 to float*
  store float %7576, float* %7578, align 4
  %7579 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7580 = bitcast i8* %7579 to float*
  %7581 = load float, float* %7580, align 4
  %7582 = insertelement <4 x float> zeroinitializer, float %7581, i32 0
  %7583 = insertelement <4 x float> %7582, float 0.000000e+00, i32 1
  %7584 = insertelement <4 x float> %7583, float 0.000000e+00, i32 2
  %7585 = insertelement <4 x float> %7584, float 0.000000e+00, i32 3
  %7586 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7587 = getelementptr inbounds i8, i8* %7586, i64 4
  %7588 = bitcast i8* %7587 to float*
  %7589 = load float, float* %7588, align 4
  %7590 = insertelement <4 x float> zeroinitializer, float %7589, i32 0
  %7591 = insertelement <4 x float> %7590, float 0.000000e+00, i32 1
  %7592 = insertelement <4 x float> %7591, float 0.000000e+00, i32 2
  %7593 = insertelement <4 x float> %7592, float 0.000000e+00, i32 3
  %7594 = getelementptr inbounds float, float* %2, i64 4
  %7595 = load float, float* %7594, align 4
  %7596 = insertelement <4 x float> zeroinitializer, float %7595, i32 0
  %7597 = insertelement <4 x float> %7596, float 0.000000e+00, i32 1
  %7598 = insertelement <4 x float> %7597, float 0.000000e+00, i32 2
  %7599 = insertelement <4 x float> %7598, float 0.000000e+00, i32 3
  %7600 = call <4 x float> @llvm.fma.f32.177(<4 x float> %7593, <4 x float> %7599, <4 x float> %7585)
  %7601 = extractelement <4 x float> %7600, i32 0
  %7602 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7603 = bitcast i8* %7602 to float*
  store float %7601, float* %7603, align 4
  %7604 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7605 = bitcast i8* %7604 to float*
  %7606 = load float, float* %7605, align 4
  %7607 = insertelement <4 x float> zeroinitializer, float %7606, i32 0
  %7608 = insertelement <4 x float> %7607, float 0.000000e+00, i32 1
  %7609 = insertelement <4 x float> %7608, float 0.000000e+00, i32 2
  %7610 = insertelement <4 x float> %7609, float 0.000000e+00, i32 3
  %7611 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7612 = getelementptr inbounds i8, i8* %7611, i64 8
  %7613 = bitcast i8* %7612 to float*
  %7614 = load float, float* %7613, align 4
  %7615 = insertelement <4 x float> zeroinitializer, float %7614, i32 0
  %7616 = insertelement <4 x float> %7615, float 0.000000e+00, i32 1
  %7617 = insertelement <4 x float> %7616, float 0.000000e+00, i32 2
  %7618 = insertelement <4 x float> %7617, float 0.000000e+00, i32 3
  %7619 = getelementptr inbounds float, float* %2, i64 8
  %7620 = load float, float* %7619, align 4
  %7621 = insertelement <4 x float> zeroinitializer, float %7620, i32 0
  %7622 = insertelement <4 x float> %7621, float 0.000000e+00, i32 1
  %7623 = insertelement <4 x float> %7622, float 0.000000e+00, i32 2
  %7624 = insertelement <4 x float> %7623, float 0.000000e+00, i32 3
  %7625 = call <4 x float> @llvm.fma.f32.178(<4 x float> %7618, <4 x float> %7624, <4 x float> %7610)
  %7626 = extractelement <4 x float> %7625, i32 0
  %7627 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7628 = bitcast i8* %7627 to float*
  store float %7626, float* %7628, align 4
  %7629 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7630 = bitcast i8* %7629 to float*
  %7631 = load float, float* %7630, align 4
  %7632 = insertelement <4 x float> zeroinitializer, float %7631, i32 0
  %7633 = insertelement <4 x float> %7632, float 0.000000e+00, i32 1
  %7634 = insertelement <4 x float> %7633, float 0.000000e+00, i32 2
  %7635 = insertelement <4 x float> %7634, float 0.000000e+00, i32 3
  %7636 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7637 = getelementptr inbounds i8, i8* %7636, i64 12
  %7638 = bitcast i8* %7637 to float*
  %7639 = load float, float* %7638, align 4
  %7640 = insertelement <4 x float> zeroinitializer, float %7639, i32 0
  %7641 = insertelement <4 x float> %7640, float 0.000000e+00, i32 1
  %7642 = insertelement <4 x float> %7641, float 0.000000e+00, i32 2
  %7643 = insertelement <4 x float> %7642, float 0.000000e+00, i32 3
  %7644 = getelementptr inbounds float, float* %2, i64 12
  %7645 = load float, float* %7644, align 4
  %7646 = insertelement <4 x float> zeroinitializer, float %7645, i32 0
  %7647 = insertelement <4 x float> %7646, float 0.000000e+00, i32 1
  %7648 = insertelement <4 x float> %7647, float 0.000000e+00, i32 2
  %7649 = insertelement <4 x float> %7648, float 0.000000e+00, i32 3
  %7650 = call <4 x float> @llvm.fma.f32.179(<4 x float> %7643, <4 x float> %7649, <4 x float> %7635)
  %7651 = extractelement <4 x float> %7650, i32 0
  %7652 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7653 = bitcast i8* %7652 to float*
  store float %7651, float* %7653, align 4
  %7654 = extractelement <4 x float> %7650, i32 1
  %7655 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7656 = getelementptr inbounds i8, i8* %7655, i64 4
  %7657 = bitcast i8* %7656 to float*
  store float %7654, float* %7657, align 4
  %7658 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7659 = getelementptr inbounds i8, i8* %7658, i64 4
  %7660 = bitcast i8* %7659 to float*
  %7661 = load float, float* %7660, align 4
  %7662 = insertelement <4 x float> zeroinitializer, float %7661, i32 0
  %7663 = insertelement <4 x float> %7662, float 0.000000e+00, i32 1
  %7664 = insertelement <4 x float> %7663, float 0.000000e+00, i32 2
  %7665 = insertelement <4 x float> %7664, float 0.000000e+00, i32 3
  %7666 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7667 = bitcast i8* %7666 to float*
  %7668 = load float, float* %7667, align 4
  %7669 = insertelement <4 x float> zeroinitializer, float %7668, i32 0
  %7670 = insertelement <4 x float> %7669, float 0.000000e+00, i32 1
  %7671 = insertelement <4 x float> %7670, float 0.000000e+00, i32 2
  %7672 = insertelement <4 x float> %7671, float 0.000000e+00, i32 3
  %7673 = getelementptr inbounds float, float* %2, i64 1
  %7674 = load float, float* %7673, align 4
  %7675 = insertelement <4 x float> zeroinitializer, float %7674, i32 0
  %7676 = insertelement <4 x float> %7675, float 0.000000e+00, i32 1
  %7677 = insertelement <4 x float> %7676, float 0.000000e+00, i32 2
  %7678 = insertelement <4 x float> %7677, float 0.000000e+00, i32 3
  %7679 = call <4 x float> @llvm.fma.f32.180(<4 x float> %7672, <4 x float> %7678, <4 x float> %7665)
  %7680 = extractelement <4 x float> %7679, i32 0
  %7681 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7682 = getelementptr inbounds i8, i8* %7681, i64 4
  %7683 = bitcast i8* %7682 to float*
  store float %7680, float* %7683, align 4
  %7684 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7685 = getelementptr inbounds i8, i8* %7684, i64 4
  %7686 = bitcast i8* %7685 to float*
  %7687 = load float, float* %7686, align 4
  %7688 = insertelement <4 x float> zeroinitializer, float %7687, i32 0
  %7689 = insertelement <4 x float> %7688, float 0.000000e+00, i32 1
  %7690 = insertelement <4 x float> %7689, float 0.000000e+00, i32 2
  %7691 = insertelement <4 x float> %7690, float 0.000000e+00, i32 3
  %7692 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7693 = getelementptr inbounds i8, i8* %7692, i64 4
  %7694 = bitcast i8* %7693 to float*
  %7695 = load float, float* %7694, align 4
  %7696 = insertelement <4 x float> zeroinitializer, float %7695, i32 0
  %7697 = insertelement <4 x float> %7696, float 0.000000e+00, i32 1
  %7698 = insertelement <4 x float> %7697, float 0.000000e+00, i32 2
  %7699 = insertelement <4 x float> %7698, float 0.000000e+00, i32 3
  %7700 = getelementptr inbounds float, float* %2, i64 5
  %7701 = load float, float* %7700, align 4
  %7702 = insertelement <4 x float> zeroinitializer, float %7701, i32 0
  %7703 = insertelement <4 x float> %7702, float 0.000000e+00, i32 1
  %7704 = insertelement <4 x float> %7703, float 0.000000e+00, i32 2
  %7705 = insertelement <4 x float> %7704, float 0.000000e+00, i32 3
  %7706 = call <4 x float> @llvm.fma.f32.181(<4 x float> %7699, <4 x float> %7705, <4 x float> %7691)
  %7707 = extractelement <4 x float> %7706, i32 0
  %7708 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7709 = getelementptr inbounds i8, i8* %7708, i64 4
  %7710 = bitcast i8* %7709 to float*
  store float %7707, float* %7710, align 4
  %7711 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7712 = getelementptr inbounds i8, i8* %7711, i64 4
  %7713 = bitcast i8* %7712 to float*
  %7714 = load float, float* %7713, align 4
  %7715 = insertelement <4 x float> zeroinitializer, float %7714, i32 0
  %7716 = insertelement <4 x float> %7715, float 0.000000e+00, i32 1
  %7717 = insertelement <4 x float> %7716, float 0.000000e+00, i32 2
  %7718 = insertelement <4 x float> %7717, float 0.000000e+00, i32 3
  %7719 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7720 = getelementptr inbounds i8, i8* %7719, i64 8
  %7721 = bitcast i8* %7720 to float*
  %7722 = load float, float* %7721, align 4
  %7723 = insertelement <4 x float> zeroinitializer, float %7722, i32 0
  %7724 = insertelement <4 x float> %7723, float 0.000000e+00, i32 1
  %7725 = insertelement <4 x float> %7724, float 0.000000e+00, i32 2
  %7726 = insertelement <4 x float> %7725, float 0.000000e+00, i32 3
  %7727 = getelementptr inbounds float, float* %2, i64 9
  %7728 = load float, float* %7727, align 4
  %7729 = insertelement <4 x float> zeroinitializer, float %7728, i32 0
  %7730 = insertelement <4 x float> %7729, float 0.000000e+00, i32 1
  %7731 = insertelement <4 x float> %7730, float 0.000000e+00, i32 2
  %7732 = insertelement <4 x float> %7731, float 0.000000e+00, i32 3
  %7733 = call <4 x float> @llvm.fma.f32.182(<4 x float> %7726, <4 x float> %7732, <4 x float> %7718)
  %7734 = extractelement <4 x float> %7733, i32 0
  %7735 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7736 = getelementptr inbounds i8, i8* %7735, i64 4
  %7737 = bitcast i8* %7736 to float*
  store float %7734, float* %7737, align 4
  %7738 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7739 = getelementptr inbounds i8, i8* %7738, i64 4
  %7740 = bitcast i8* %7739 to float*
  %7741 = load float, float* %7740, align 4
  %7742 = insertelement <4 x float> zeroinitializer, float %7741, i32 0
  %7743 = insertelement <4 x float> %7742, float 0.000000e+00, i32 1
  %7744 = insertelement <4 x float> %7743, float 0.000000e+00, i32 2
  %7745 = insertelement <4 x float> %7744, float 0.000000e+00, i32 3
  %7746 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7747 = getelementptr inbounds i8, i8* %7746, i64 12
  %7748 = bitcast i8* %7747 to float*
  %7749 = load float, float* %7748, align 4
  %7750 = insertelement <4 x float> zeroinitializer, float %7749, i32 0
  %7751 = insertelement <4 x float> %7750, float 0.000000e+00, i32 1
  %7752 = insertelement <4 x float> %7751, float 0.000000e+00, i32 2
  %7753 = insertelement <4 x float> %7752, float 0.000000e+00, i32 3
  %7754 = getelementptr inbounds float, float* %2, i64 13
  %7755 = load float, float* %7754, align 4
  %7756 = insertelement <4 x float> zeroinitializer, float %7755, i32 0
  %7757 = insertelement <4 x float> %7756, float 0.000000e+00, i32 1
  %7758 = insertelement <4 x float> %7757, float 0.000000e+00, i32 2
  %7759 = insertelement <4 x float> %7758, float 0.000000e+00, i32 3
  %7760 = call <4 x float> @llvm.fma.f32.183(<4 x float> %7753, <4 x float> %7759, <4 x float> %7745)
  %7761 = extractelement <4 x float> %7760, i32 0
  %7762 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7763 = getelementptr inbounds i8, i8* %7762, i64 4
  %7764 = bitcast i8* %7763 to float*
  store float %7761, float* %7764, align 4
  %7765 = extractelement <4 x float> %7760, i32 1
  %7766 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7767 = getelementptr inbounds i8, i8* %7766, i64 8
  %7768 = bitcast i8* %7767 to float*
  store float %7765, float* %7768, align 4
  %7769 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7770 = getelementptr inbounds i8, i8* %7769, i64 8
  %7771 = bitcast i8* %7770 to float*
  %7772 = load float, float* %7771, align 4
  %7773 = insertelement <4 x float> zeroinitializer, float %7772, i32 0
  %7774 = insertelement <4 x float> %7773, float 0.000000e+00, i32 1
  %7775 = insertelement <4 x float> %7774, float 0.000000e+00, i32 2
  %7776 = insertelement <4 x float> %7775, float 0.000000e+00, i32 3
  %7777 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7778 = bitcast i8* %7777 to float*
  %7779 = load float, float* %7778, align 4
  %7780 = insertelement <4 x float> zeroinitializer, float %7779, i32 0
  %7781 = insertelement <4 x float> %7780, float 0.000000e+00, i32 1
  %7782 = insertelement <4 x float> %7781, float 0.000000e+00, i32 2
  %7783 = insertelement <4 x float> %7782, float 0.000000e+00, i32 3
  %7784 = getelementptr inbounds float, float* %2, i64 2
  %7785 = load float, float* %7784, align 4
  %7786 = insertelement <4 x float> zeroinitializer, float %7785, i32 0
  %7787 = insertelement <4 x float> %7786, float 0.000000e+00, i32 1
  %7788 = insertelement <4 x float> %7787, float 0.000000e+00, i32 2
  %7789 = insertelement <4 x float> %7788, float 0.000000e+00, i32 3
  %7790 = call <4 x float> @llvm.fma.f32.184(<4 x float> %7783, <4 x float> %7789, <4 x float> %7776)
  %7791 = extractelement <4 x float> %7790, i32 0
  %7792 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7793 = getelementptr inbounds i8, i8* %7792, i64 8
  %7794 = bitcast i8* %7793 to float*
  store float %7791, float* %7794, align 4
  %7795 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7796 = getelementptr inbounds i8, i8* %7795, i64 8
  %7797 = bitcast i8* %7796 to float*
  %7798 = load float, float* %7797, align 4
  %7799 = insertelement <4 x float> zeroinitializer, float %7798, i32 0
  %7800 = insertelement <4 x float> %7799, float 0.000000e+00, i32 1
  %7801 = insertelement <4 x float> %7800, float 0.000000e+00, i32 2
  %7802 = insertelement <4 x float> %7801, float 0.000000e+00, i32 3
  %7803 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7804 = getelementptr inbounds i8, i8* %7803, i64 4
  %7805 = bitcast i8* %7804 to float*
  %7806 = load float, float* %7805, align 4
  %7807 = insertelement <4 x float> zeroinitializer, float %7806, i32 0
  %7808 = insertelement <4 x float> %7807, float 0.000000e+00, i32 1
  %7809 = insertelement <4 x float> %7808, float 0.000000e+00, i32 2
  %7810 = insertelement <4 x float> %7809, float 0.000000e+00, i32 3
  %7811 = getelementptr inbounds float, float* %2, i64 6
  %7812 = load float, float* %7811, align 4
  %7813 = insertelement <4 x float> zeroinitializer, float %7812, i32 0
  %7814 = insertelement <4 x float> %7813, float 0.000000e+00, i32 1
  %7815 = insertelement <4 x float> %7814, float 0.000000e+00, i32 2
  %7816 = insertelement <4 x float> %7815, float 0.000000e+00, i32 3
  %7817 = call <4 x float> @llvm.fma.f32.185(<4 x float> %7810, <4 x float> %7816, <4 x float> %7802)
  %7818 = extractelement <4 x float> %7817, i32 0
  %7819 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7820 = getelementptr inbounds i8, i8* %7819, i64 8
  %7821 = bitcast i8* %7820 to float*
  store float %7818, float* %7821, align 4
  %7822 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7823 = getelementptr inbounds i8, i8* %7822, i64 8
  %7824 = bitcast i8* %7823 to float*
  %7825 = load float, float* %7824, align 4
  %7826 = insertelement <4 x float> zeroinitializer, float %7825, i32 0
  %7827 = insertelement <4 x float> %7826, float 0.000000e+00, i32 1
  %7828 = insertelement <4 x float> %7827, float 0.000000e+00, i32 2
  %7829 = insertelement <4 x float> %7828, float 0.000000e+00, i32 3
  %7830 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7831 = getelementptr inbounds i8, i8* %7830, i64 8
  %7832 = bitcast i8* %7831 to float*
  %7833 = load float, float* %7832, align 4
  %7834 = insertelement <4 x float> zeroinitializer, float %7833, i32 0
  %7835 = insertelement <4 x float> %7834, float 0.000000e+00, i32 1
  %7836 = insertelement <4 x float> %7835, float 0.000000e+00, i32 2
  %7837 = insertelement <4 x float> %7836, float 0.000000e+00, i32 3
  %7838 = getelementptr inbounds float, float* %2, i64 10
  %7839 = load float, float* %7838, align 4
  %7840 = insertelement <4 x float> zeroinitializer, float %7839, i32 0
  %7841 = insertelement <4 x float> %7840, float 0.000000e+00, i32 1
  %7842 = insertelement <4 x float> %7841, float 0.000000e+00, i32 2
  %7843 = insertelement <4 x float> %7842, float 0.000000e+00, i32 3
  %7844 = call <4 x float> @llvm.fma.f32.186(<4 x float> %7837, <4 x float> %7843, <4 x float> %7829)
  %7845 = extractelement <4 x float> %7844, i32 0
  %7846 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7847 = getelementptr inbounds i8, i8* %7846, i64 8
  %7848 = bitcast i8* %7847 to float*
  store float %7845, float* %7848, align 4
  %7849 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7850 = getelementptr inbounds i8, i8* %7849, i64 8
  %7851 = bitcast i8* %7850 to float*
  %7852 = load float, float* %7851, align 4
  %7853 = insertelement <4 x float> zeroinitializer, float %7852, i32 0
  %7854 = insertelement <4 x float> %7853, float 0.000000e+00, i32 1
  %7855 = insertelement <4 x float> %7854, float 0.000000e+00, i32 2
  %7856 = insertelement <4 x float> %7855, float 0.000000e+00, i32 3
  %7857 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7858 = getelementptr inbounds i8, i8* %7857, i64 12
  %7859 = bitcast i8* %7858 to float*
  %7860 = load float, float* %7859, align 4
  %7861 = insertelement <4 x float> zeroinitializer, float %7860, i32 0
  %7862 = insertelement <4 x float> %7861, float 0.000000e+00, i32 1
  %7863 = insertelement <4 x float> %7862, float 0.000000e+00, i32 2
  %7864 = insertelement <4 x float> %7863, float 0.000000e+00, i32 3
  %7865 = getelementptr inbounds float, float* %2, i64 14
  %7866 = load float, float* %7865, align 4
  %7867 = insertelement <4 x float> zeroinitializer, float %7866, i32 0
  %7868 = insertelement <4 x float> %7867, float 0.000000e+00, i32 1
  %7869 = insertelement <4 x float> %7868, float 0.000000e+00, i32 2
  %7870 = insertelement <4 x float> %7869, float 0.000000e+00, i32 3
  %7871 = call <4 x float> @llvm.fma.f32.187(<4 x float> %7864, <4 x float> %7870, <4 x float> %7856)
  %7872 = extractelement <4 x float> %7871, i32 0
  %7873 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7874 = getelementptr inbounds i8, i8* %7873, i64 8
  %7875 = bitcast i8* %7874 to float*
  store float %7872, float* %7875, align 4
  %7876 = extractelement <4 x float> %7871, i32 1
  %7877 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7878 = getelementptr inbounds i8, i8* %7877, i64 12
  %7879 = bitcast i8* %7878 to float*
  store float %7876, float* %7879, align 4
  %7880 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7881 = getelementptr inbounds i8, i8* %7880, i64 12
  %7882 = bitcast i8* %7881 to float*
  %7883 = load float, float* %7882, align 4
  %7884 = insertelement <4 x float> zeroinitializer, float %7883, i32 0
  %7885 = insertelement <4 x float> %7884, float 0.000000e+00, i32 1
  %7886 = insertelement <4 x float> %7885, float 0.000000e+00, i32 2
  %7887 = insertelement <4 x float> %7886, float 0.000000e+00, i32 3
  %7888 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7889 = bitcast i8* %7888 to float*
  %7890 = load float, float* %7889, align 4
  %7891 = insertelement <4 x float> zeroinitializer, float %7890, i32 0
  %7892 = insertelement <4 x float> %7891, float 0.000000e+00, i32 1
  %7893 = insertelement <4 x float> %7892, float 0.000000e+00, i32 2
  %7894 = insertelement <4 x float> %7893, float 0.000000e+00, i32 3
  %7895 = getelementptr inbounds float, float* %2, i64 3
  %7896 = load float, float* %7895, align 4
  %7897 = insertelement <4 x float> zeroinitializer, float %7896, i32 0
  %7898 = insertelement <4 x float> %7897, float 0.000000e+00, i32 1
  %7899 = insertelement <4 x float> %7898, float 0.000000e+00, i32 2
  %7900 = insertelement <4 x float> %7899, float 0.000000e+00, i32 3
  %7901 = call <4 x float> @llvm.fma.f32.188(<4 x float> %7894, <4 x float> %7900, <4 x float> %7887)
  %7902 = extractelement <4 x float> %7901, i32 0
  %7903 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7904 = getelementptr inbounds i8, i8* %7903, i64 12
  %7905 = bitcast i8* %7904 to float*
  store float %7902, float* %7905, align 4
  %7906 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7907 = getelementptr inbounds i8, i8* %7906, i64 12
  %7908 = bitcast i8* %7907 to float*
  %7909 = load float, float* %7908, align 4
  %7910 = insertelement <4 x float> zeroinitializer, float %7909, i32 0
  %7911 = insertelement <4 x float> %7910, float 0.000000e+00, i32 1
  %7912 = insertelement <4 x float> %7911, float 0.000000e+00, i32 2
  %7913 = insertelement <4 x float> %7912, float 0.000000e+00, i32 3
  %7914 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7915 = getelementptr inbounds i8, i8* %7914, i64 4
  %7916 = bitcast i8* %7915 to float*
  %7917 = load float, float* %7916, align 4
  %7918 = insertelement <4 x float> zeroinitializer, float %7917, i32 0
  %7919 = insertelement <4 x float> %7918, float 0.000000e+00, i32 1
  %7920 = insertelement <4 x float> %7919, float 0.000000e+00, i32 2
  %7921 = insertelement <4 x float> %7920, float 0.000000e+00, i32 3
  %7922 = getelementptr inbounds float, float* %2, i64 7
  %7923 = load float, float* %7922, align 4
  %7924 = insertelement <4 x float> zeroinitializer, float %7923, i32 0
  %7925 = insertelement <4 x float> %7924, float 0.000000e+00, i32 1
  %7926 = insertelement <4 x float> %7925, float 0.000000e+00, i32 2
  %7927 = insertelement <4 x float> %7926, float 0.000000e+00, i32 3
  %7928 = call <4 x float> @llvm.fma.f32.189(<4 x float> %7921, <4 x float> %7927, <4 x float> %7913)
  %7929 = extractelement <4 x float> %7928, i32 0
  %7930 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7931 = getelementptr inbounds i8, i8* %7930, i64 12
  %7932 = bitcast i8* %7931 to float*
  store float %7929, float* %7932, align 4
  %7933 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7934 = getelementptr inbounds i8, i8* %7933, i64 12
  %7935 = bitcast i8* %7934 to float*
  %7936 = load float, float* %7935, align 4
  %7937 = insertelement <4 x float> zeroinitializer, float %7936, i32 0
  %7938 = insertelement <4 x float> %7937, float 0.000000e+00, i32 1
  %7939 = insertelement <4 x float> %7938, float 0.000000e+00, i32 2
  %7940 = insertelement <4 x float> %7939, float 0.000000e+00, i32 3
  %7941 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7942 = getelementptr inbounds i8, i8* %7941, i64 8
  %7943 = bitcast i8* %7942 to float*
  %7944 = load float, float* %7943, align 4
  %7945 = insertelement <4 x float> zeroinitializer, float %7944, i32 0
  %7946 = insertelement <4 x float> %7945, float 0.000000e+00, i32 1
  %7947 = insertelement <4 x float> %7946, float 0.000000e+00, i32 2
  %7948 = insertelement <4 x float> %7947, float 0.000000e+00, i32 3
  %7949 = getelementptr inbounds float, float* %2, i64 11
  %7950 = load float, float* %7949, align 4
  %7951 = insertelement <4 x float> zeroinitializer, float %7950, i32 0
  %7952 = insertelement <4 x float> %7951, float 0.000000e+00, i32 1
  %7953 = insertelement <4 x float> %7952, float 0.000000e+00, i32 2
  %7954 = insertelement <4 x float> %7953, float 0.000000e+00, i32 3
  %7955 = call <4 x float> @llvm.fma.f32.190(<4 x float> %7948, <4 x float> %7954, <4 x float> %7940)
  %7956 = extractelement <4 x float> %7955, i32 0
  %7957 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7958 = getelementptr inbounds i8, i8* %7957, i64 12
  %7959 = bitcast i8* %7958 to float*
  store float %7956, float* %7959, align 4
  %7960 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7961 = getelementptr inbounds i8, i8* %7960, i64 12
  %7962 = bitcast i8* %7961 to float*
  %7963 = load float, float* %7962, align 4
  %7964 = insertelement <4 x float> zeroinitializer, float %7963, i32 0
  %7965 = insertelement <4 x float> %7964, float 0.000000e+00, i32 1
  %7966 = insertelement <4 x float> %7965, float 0.000000e+00, i32 2
  %7967 = insertelement <4 x float> %7966, float 0.000000e+00, i32 3
  %7968 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7969 = getelementptr inbounds i8, i8* %7968, i64 12
  %7970 = bitcast i8* %7969 to float*
  %7971 = load float, float* %7970, align 4
  %7972 = insertelement <4 x float> zeroinitializer, float %7971, i32 0
  %7973 = insertelement <4 x float> %7972, float 0.000000e+00, i32 1
  %7974 = insertelement <4 x float> %7973, float 0.000000e+00, i32 2
  %7975 = insertelement <4 x float> %7974, float 0.000000e+00, i32 3
  %7976 = getelementptr inbounds float, float* %2, i64 15
  %7977 = load float, float* %7976, align 4
  %7978 = insertelement <4 x float> zeroinitializer, float %7977, i32 0
  %7979 = insertelement <4 x float> %7978, float 0.000000e+00, i32 1
  %7980 = insertelement <4 x float> %7979, float 0.000000e+00, i32 2
  %7981 = insertelement <4 x float> %7980, float 0.000000e+00, i32 3
  %7982 = call <4 x float> @llvm.fma.f32.191(<4 x float> %7975, <4 x float> %7981, <4 x float> %7967)
  %7983 = extractelement <4 x float> %7982, i32 0
  %7984 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7985 = getelementptr inbounds i8, i8* %7984, i64 12
  %7986 = bitcast i8* %7985 to float*
  store float %7983, float* %7986, align 4
  %7987 = extractelement <4 x float> %7982, i32 1
  %7988 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7989 = getelementptr inbounds i8, i8* %7988, i64 16
  %7990 = bitcast i8* %7989 to float*
  store float %7987, float* %7990, align 4
  %7991 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %7992 = getelementptr inbounds i8, i8* %7991, i64 16
  %7993 = bitcast i8* %7992 to float*
  %7994 = load float, float* %7993, align 4
  %7995 = insertelement <4 x float> zeroinitializer, float %7994, i32 0
  %7996 = insertelement <4 x float> %7995, float 0.000000e+00, i32 1
  %7997 = insertelement <4 x float> %7996, float 0.000000e+00, i32 2
  %7998 = insertelement <4 x float> %7997, float 0.000000e+00, i32 3
  %7999 = load float, float* %2, align 4
  %8000 = insertelement <4 x float> zeroinitializer, float %7999, i32 0
  %8001 = insertelement <4 x float> %8000, float 0.000000e+00, i32 1
  %8002 = insertelement <4 x float> %8001, float 0.000000e+00, i32 2
  %8003 = insertelement <4 x float> %8002, float 0.000000e+00, i32 3
  %8004 = call <4 x float> @llvm.fma.f32.192(<4 x float> %7998, <4 x float> %8003, <4 x float> zeroinitializer)
  %8005 = extractelement <4 x float> %8004, i32 0
  %8006 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8007 = getelementptr inbounds i8, i8* %8006, i64 16
  %8008 = bitcast i8* %8007 to float*
  store float %8005, float* %8008, align 4
  %8009 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8010 = getelementptr inbounds i8, i8* %8009, i64 16
  %8011 = bitcast i8* %8010 to float*
  %8012 = load float, float* %8011, align 4
  %8013 = insertelement <4 x float> zeroinitializer, float %8012, i32 0
  %8014 = insertelement <4 x float> %8013, float 0.000000e+00, i32 1
  %8015 = insertelement <4 x float> %8014, float 0.000000e+00, i32 2
  %8016 = insertelement <4 x float> %8015, float 0.000000e+00, i32 3
  %8017 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8018 = getelementptr inbounds i8, i8* %8017, i64 20
  %8019 = bitcast i8* %8018 to float*
  %8020 = load float, float* %8019, align 4
  %8021 = insertelement <4 x float> zeroinitializer, float %8020, i32 0
  %8022 = insertelement <4 x float> %8021, float 0.000000e+00, i32 1
  %8023 = insertelement <4 x float> %8022, float 0.000000e+00, i32 2
  %8024 = insertelement <4 x float> %8023, float 0.000000e+00, i32 3
  %8025 = getelementptr inbounds float, float* %2, i64 4
  %8026 = load float, float* %8025, align 4
  %8027 = insertelement <4 x float> zeroinitializer, float %8026, i32 0
  %8028 = insertelement <4 x float> %8027, float 0.000000e+00, i32 1
  %8029 = insertelement <4 x float> %8028, float 0.000000e+00, i32 2
  %8030 = insertelement <4 x float> %8029, float 0.000000e+00, i32 3
  %8031 = call <4 x float> @llvm.fma.f32.193(<4 x float> %8024, <4 x float> %8030, <4 x float> %8016)
  %8032 = extractelement <4 x float> %8031, i32 0
  %8033 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8034 = getelementptr inbounds i8, i8* %8033, i64 16
  %8035 = bitcast i8* %8034 to float*
  store float %8032, float* %8035, align 4
  %8036 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8037 = getelementptr inbounds i8, i8* %8036, i64 16
  %8038 = bitcast i8* %8037 to float*
  %8039 = load float, float* %8038, align 4
  %8040 = insertelement <4 x float> zeroinitializer, float %8039, i32 0
  %8041 = insertelement <4 x float> %8040, float 0.000000e+00, i32 1
  %8042 = insertelement <4 x float> %8041, float 0.000000e+00, i32 2
  %8043 = insertelement <4 x float> %8042, float 0.000000e+00, i32 3
  %8044 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8045 = getelementptr inbounds i8, i8* %8044, i64 24
  %8046 = bitcast i8* %8045 to float*
  %8047 = load float, float* %8046, align 4
  %8048 = insertelement <4 x float> zeroinitializer, float %8047, i32 0
  %8049 = insertelement <4 x float> %8048, float 0.000000e+00, i32 1
  %8050 = insertelement <4 x float> %8049, float 0.000000e+00, i32 2
  %8051 = insertelement <4 x float> %8050, float 0.000000e+00, i32 3
  %8052 = getelementptr inbounds float, float* %2, i64 8
  %8053 = load float, float* %8052, align 4
  %8054 = insertelement <4 x float> zeroinitializer, float %8053, i32 0
  %8055 = insertelement <4 x float> %8054, float 0.000000e+00, i32 1
  %8056 = insertelement <4 x float> %8055, float 0.000000e+00, i32 2
  %8057 = insertelement <4 x float> %8056, float 0.000000e+00, i32 3
  %8058 = call <4 x float> @llvm.fma.f32.194(<4 x float> %8051, <4 x float> %8057, <4 x float> %8043)
  %8059 = extractelement <4 x float> %8058, i32 0
  %8060 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8061 = getelementptr inbounds i8, i8* %8060, i64 16
  %8062 = bitcast i8* %8061 to float*
  store float %8059, float* %8062, align 4
  %8063 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8064 = getelementptr inbounds i8, i8* %8063, i64 16
  %8065 = bitcast i8* %8064 to float*
  %8066 = load float, float* %8065, align 4
  %8067 = insertelement <4 x float> zeroinitializer, float %8066, i32 0
  %8068 = insertelement <4 x float> %8067, float 0.000000e+00, i32 1
  %8069 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8070 = getelementptr inbounds i8, i8* %8069, i64 20
  %8071 = bitcast i8* %8070 to float*
  %8072 = load float, float* %8071, align 4
  %8073 = insertelement <4 x float> %8068, float %8072, i32 2
  %8074 = insertelement <4 x float> %8073, float 0.000000e+00, i32 3
  %8075 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8076 = getelementptr inbounds i8, i8* %8075, i64 28
  %8077 = bitcast i8* %8076 to float*
  %8078 = load float, float* %8077, align 4
  %8079 = insertelement <4 x float> zeroinitializer, float %8078, i32 0
  %8080 = insertelement <4 x float> %8079, float 0.000000e+00, i32 1
  %8081 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8082 = getelementptr inbounds i8, i8* %8081, i64 16
  %8083 = bitcast i8* %8082 to float*
  %8084 = load float, float* %8083, align 4
  %8085 = insertelement <4 x float> %8080, float %8084, i32 2
  %8086 = insertelement <4 x float> %8085, float 0.000000e+00, i32 3
  %8087 = getelementptr inbounds float, float* %2, i64 12
  %8088 = load float, float* %8087, align 4
  %8089 = insertelement <4 x float> zeroinitializer, float %8088, i32 0
  %8090 = insertelement <4 x float> %8089, float 0.000000e+00, i32 1
  %8091 = getelementptr inbounds float, float* %2, i64 1
  %8092 = load float, float* %8091, align 4
  %8093 = insertelement <4 x float> %8090, float %8092, i32 2
  %8094 = insertelement <4 x float> %8093, float 0.000000e+00, i32 3
  %8095 = call <4 x float> @llvm.fma.f32.195(<4 x float> %8086, <4 x float> %8094, <4 x float> %8074)
  %8096 = extractelement <4 x float> %8095, i32 0
  %8097 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8098 = getelementptr inbounds i8, i8* %8097, i64 16
  %8099 = bitcast i8* %8098 to float*
  store float %8096, float* %8099, align 4
  %8100 = extractelement <4 x float> %8095, i32 1
  %8101 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8102 = getelementptr inbounds i8, i8* %8101, i64 20
  %8103 = bitcast i8* %8102 to float*
  store float %8100, float* %8103, align 4
  %8104 = extractelement <4 x float> %8095, i32 2
  %8105 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8106 = getelementptr inbounds i8, i8* %8105, i64 20
  %8107 = bitcast i8* %8106 to float*
  store float %8104, float* %8107, align 4
  %8108 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8109 = getelementptr inbounds i8, i8* %8108, i64 20
  %8110 = bitcast i8* %8109 to float*
  %8111 = load float, float* %8110, align 4
  %8112 = insertelement <4 x float> zeroinitializer, float %8111, i32 0
  %8113 = insertelement <4 x float> %8112, float 0.000000e+00, i32 1
  %8114 = insertelement <4 x float> %8113, float 0.000000e+00, i32 2
  %8115 = insertelement <4 x float> %8114, float 0.000000e+00, i32 3
  %8116 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8117 = getelementptr inbounds i8, i8* %8116, i64 20
  %8118 = bitcast i8* %8117 to float*
  %8119 = load float, float* %8118, align 4
  %8120 = insertelement <4 x float> zeroinitializer, float %8119, i32 0
  %8121 = insertelement <4 x float> %8120, float 0.000000e+00, i32 1
  %8122 = insertelement <4 x float> %8121, float 0.000000e+00, i32 2
  %8123 = insertelement <4 x float> %8122, float 0.000000e+00, i32 3
  %8124 = getelementptr inbounds float, float* %2, i64 5
  %8125 = load float, float* %8124, align 4
  %8126 = insertelement <4 x float> zeroinitializer, float %8125, i32 0
  %8127 = insertelement <4 x float> %8126, float 0.000000e+00, i32 1
  %8128 = insertelement <4 x float> %8127, float 0.000000e+00, i32 2
  %8129 = insertelement <4 x float> %8128, float 0.000000e+00, i32 3
  %8130 = call <4 x float> @llvm.fma.f32.196(<4 x float> %8123, <4 x float> %8129, <4 x float> %8115)
  %8131 = extractelement <4 x float> %8130, i32 0
  %8132 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8133 = getelementptr inbounds i8, i8* %8132, i64 20
  %8134 = bitcast i8* %8133 to float*
  store float %8131, float* %8134, align 4
  %8135 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8136 = getelementptr inbounds i8, i8* %8135, i64 20
  %8137 = bitcast i8* %8136 to float*
  %8138 = load float, float* %8137, align 4
  %8139 = insertelement <4 x float> zeroinitializer, float %8138, i32 0
  %8140 = insertelement <4 x float> %8139, float 0.000000e+00, i32 1
  %8141 = insertelement <4 x float> %8140, float 0.000000e+00, i32 2
  %8142 = insertelement <4 x float> %8141, float 0.000000e+00, i32 3
  %8143 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8144 = getelementptr inbounds i8, i8* %8143, i64 24
  %8145 = bitcast i8* %8144 to float*
  %8146 = load float, float* %8145, align 4
  %8147 = insertelement <4 x float> zeroinitializer, float %8146, i32 0
  %8148 = insertelement <4 x float> %8147, float 0.000000e+00, i32 1
  %8149 = insertelement <4 x float> %8148, float 0.000000e+00, i32 2
  %8150 = insertelement <4 x float> %8149, float 0.000000e+00, i32 3
  %8151 = getelementptr inbounds float, float* %2, i64 9
  %8152 = load float, float* %8151, align 4
  %8153 = insertelement <4 x float> zeroinitializer, float %8152, i32 0
  %8154 = insertelement <4 x float> %8153, float 0.000000e+00, i32 1
  %8155 = insertelement <4 x float> %8154, float 0.000000e+00, i32 2
  %8156 = insertelement <4 x float> %8155, float 0.000000e+00, i32 3
  %8157 = call <4 x float> @llvm.fma.f32.197(<4 x float> %8150, <4 x float> %8156, <4 x float> %8142)
  %8158 = extractelement <4 x float> %8157, i32 0
  %8159 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8160 = getelementptr inbounds i8, i8* %8159, i64 20
  %8161 = bitcast i8* %8160 to float*
  store float %8158, float* %8161, align 4
  %8162 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8163 = getelementptr inbounds i8, i8* %8162, i64 20
  %8164 = bitcast i8* %8163 to float*
  %8165 = load float, float* %8164, align 4
  %8166 = insertelement <4 x float> zeroinitializer, float %8165, i32 0
  %8167 = insertelement <4 x float> %8166, float 0.000000e+00, i32 1
  %8168 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8169 = getelementptr inbounds i8, i8* %8168, i64 24
  %8170 = bitcast i8* %8169 to float*
  %8171 = load float, float* %8170, align 4
  %8172 = insertelement <4 x float> %8167, float %8171, i32 2
  %8173 = insertelement <4 x float> %8172, float 0.000000e+00, i32 3
  %8174 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8175 = getelementptr inbounds i8, i8* %8174, i64 28
  %8176 = bitcast i8* %8175 to float*
  %8177 = load float, float* %8176, align 4
  %8178 = insertelement <4 x float> zeroinitializer, float %8177, i32 0
  %8179 = insertelement <4 x float> %8178, float 0.000000e+00, i32 1
  %8180 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8181 = getelementptr inbounds i8, i8* %8180, i64 16
  %8182 = bitcast i8* %8181 to float*
  %8183 = load float, float* %8182, align 4
  %8184 = insertelement <4 x float> %8179, float %8183, i32 2
  %8185 = insertelement <4 x float> %8184, float 0.000000e+00, i32 3
  %8186 = getelementptr inbounds float, float* %2, i64 13
  %8187 = load float, float* %8186, align 4
  %8188 = insertelement <4 x float> zeroinitializer, float %8187, i32 0
  %8189 = insertelement <4 x float> %8188, float 0.000000e+00, i32 1
  %8190 = getelementptr inbounds float, float* %2, i64 2
  %8191 = load float, float* %8190, align 4
  %8192 = insertelement <4 x float> %8189, float %8191, i32 2
  %8193 = insertelement <4 x float> %8192, float 0.000000e+00, i32 3
  %8194 = call <4 x float> @llvm.fma.f32.198(<4 x float> %8185, <4 x float> %8193, <4 x float> %8173)
  %8195 = extractelement <4 x float> %8194, i32 0
  %8196 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8197 = getelementptr inbounds i8, i8* %8196, i64 20
  %8198 = bitcast i8* %8197 to float*
  store float %8195, float* %8198, align 4
  %8199 = extractelement <4 x float> %8194, i32 1
  %8200 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8201 = getelementptr inbounds i8, i8* %8200, i64 24
  %8202 = bitcast i8* %8201 to float*
  store float %8199, float* %8202, align 4
  %8203 = extractelement <4 x float> %8194, i32 2
  %8204 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8205 = getelementptr inbounds i8, i8* %8204, i64 24
  %8206 = bitcast i8* %8205 to float*
  store float %8203, float* %8206, align 4
  %8207 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8208 = getelementptr inbounds i8, i8* %8207, i64 24
  %8209 = bitcast i8* %8208 to float*
  %8210 = load float, float* %8209, align 4
  %8211 = insertelement <4 x float> zeroinitializer, float %8210, i32 0
  %8212 = insertelement <4 x float> %8211, float 0.000000e+00, i32 1
  %8213 = insertelement <4 x float> %8212, float 0.000000e+00, i32 2
  %8214 = insertelement <4 x float> %8213, float 0.000000e+00, i32 3
  %8215 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8216 = getelementptr inbounds i8, i8* %8215, i64 20
  %8217 = bitcast i8* %8216 to float*
  %8218 = load float, float* %8217, align 4
  %8219 = insertelement <4 x float> zeroinitializer, float %8218, i32 0
  %8220 = insertelement <4 x float> %8219, float 0.000000e+00, i32 1
  %8221 = insertelement <4 x float> %8220, float 0.000000e+00, i32 2
  %8222 = insertelement <4 x float> %8221, float 0.000000e+00, i32 3
  %8223 = getelementptr inbounds float, float* %2, i64 6
  %8224 = load float, float* %8223, align 4
  %8225 = insertelement <4 x float> zeroinitializer, float %8224, i32 0
  %8226 = insertelement <4 x float> %8225, float 0.000000e+00, i32 1
  %8227 = insertelement <4 x float> %8226, float 0.000000e+00, i32 2
  %8228 = insertelement <4 x float> %8227, float 0.000000e+00, i32 3
  %8229 = call <4 x float> @llvm.fma.f32.199(<4 x float> %8222, <4 x float> %8228, <4 x float> %8214)
  %8230 = extractelement <4 x float> %8229, i32 0
  %8231 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8232 = getelementptr inbounds i8, i8* %8231, i64 24
  %8233 = bitcast i8* %8232 to float*
  store float %8230, float* %8233, align 4
  %8234 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8235 = getelementptr inbounds i8, i8* %8234, i64 24
  %8236 = bitcast i8* %8235 to float*
  %8237 = load float, float* %8236, align 4
  %8238 = insertelement <4 x float> zeroinitializer, float %8237, i32 0
  %8239 = insertelement <4 x float> %8238, float 0.000000e+00, i32 1
  %8240 = insertelement <4 x float> %8239, float 0.000000e+00, i32 2
  %8241 = insertelement <4 x float> %8240, float 0.000000e+00, i32 3
  %8242 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8243 = getelementptr inbounds i8, i8* %8242, i64 24
  %8244 = bitcast i8* %8243 to float*
  %8245 = load float, float* %8244, align 4
  %8246 = insertelement <4 x float> zeroinitializer, float %8245, i32 0
  %8247 = insertelement <4 x float> %8246, float 0.000000e+00, i32 1
  %8248 = insertelement <4 x float> %8247, float 0.000000e+00, i32 2
  %8249 = insertelement <4 x float> %8248, float 0.000000e+00, i32 3
  %8250 = getelementptr inbounds float, float* %2, i64 10
  %8251 = load float, float* %8250, align 4
  %8252 = insertelement <4 x float> zeroinitializer, float %8251, i32 0
  %8253 = insertelement <4 x float> %8252, float 0.000000e+00, i32 1
  %8254 = insertelement <4 x float> %8253, float 0.000000e+00, i32 2
  %8255 = insertelement <4 x float> %8254, float 0.000000e+00, i32 3
  %8256 = call <4 x float> @llvm.fma.f32.200(<4 x float> %8249, <4 x float> %8255, <4 x float> %8241)
  %8257 = extractelement <4 x float> %8256, i32 0
  %8258 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8259 = getelementptr inbounds i8, i8* %8258, i64 24
  %8260 = bitcast i8* %8259 to float*
  store float %8257, float* %8260, align 4
  %8261 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8262 = getelementptr inbounds i8, i8* %8261, i64 24
  %8263 = bitcast i8* %8262 to float*
  %8264 = load float, float* %8263, align 4
  %8265 = insertelement <4 x float> zeroinitializer, float %8264, i32 0
  %8266 = insertelement <4 x float> %8265, float 0.000000e+00, i32 1
  %8267 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8268 = getelementptr inbounds i8, i8* %8267, i64 28
  %8269 = bitcast i8* %8268 to float*
  %8270 = load float, float* %8269, align 4
  %8271 = insertelement <4 x float> %8266, float %8270, i32 2
  %8272 = insertelement <4 x float> %8271, float 0.000000e+00, i32 3
  %8273 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8274 = getelementptr inbounds i8, i8* %8273, i64 28
  %8275 = bitcast i8* %8274 to float*
  %8276 = load float, float* %8275, align 4
  %8277 = insertelement <4 x float> zeroinitializer, float %8276, i32 0
  %8278 = insertelement <4 x float> %8277, float 0.000000e+00, i32 1
  %8279 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8280 = getelementptr inbounds i8, i8* %8279, i64 16
  %8281 = bitcast i8* %8280 to float*
  %8282 = load float, float* %8281, align 4
  %8283 = insertelement <4 x float> %8278, float %8282, i32 2
  %8284 = insertelement <4 x float> %8283, float 0.000000e+00, i32 3
  %8285 = getelementptr inbounds float, float* %2, i64 14
  %8286 = load float, float* %8285, align 4
  %8287 = insertelement <4 x float> zeroinitializer, float %8286, i32 0
  %8288 = insertelement <4 x float> %8287, float 0.000000e+00, i32 1
  %8289 = getelementptr inbounds float, float* %2, i64 3
  %8290 = load float, float* %8289, align 4
  %8291 = insertelement <4 x float> %8288, float %8290, i32 2
  %8292 = insertelement <4 x float> %8291, float 0.000000e+00, i32 3
  %8293 = call <4 x float> @llvm.fma.f32.201(<4 x float> %8284, <4 x float> %8292, <4 x float> %8272)
  %8294 = extractelement <4 x float> %8293, i32 0
  %8295 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8296 = getelementptr inbounds i8, i8* %8295, i64 24
  %8297 = bitcast i8* %8296 to float*
  store float %8294, float* %8297, align 4
  %8298 = extractelement <4 x float> %8293, i32 1
  %8299 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8300 = getelementptr inbounds i8, i8* %8299, i64 28
  %8301 = bitcast i8* %8300 to float*
  store float %8298, float* %8301, align 4
  %8302 = extractelement <4 x float> %8293, i32 2
  %8303 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8304 = getelementptr inbounds i8, i8* %8303, i64 28
  %8305 = bitcast i8* %8304 to float*
  store float %8302, float* %8305, align 4
  %8306 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8307 = getelementptr inbounds i8, i8* %8306, i64 28
  %8308 = bitcast i8* %8307 to float*
  %8309 = load float, float* %8308, align 4
  %8310 = insertelement <4 x float> zeroinitializer, float %8309, i32 0
  %8311 = insertelement <4 x float> %8310, float 0.000000e+00, i32 1
  %8312 = insertelement <4 x float> %8311, float 0.000000e+00, i32 2
  %8313 = insertelement <4 x float> %8312, float 0.000000e+00, i32 3
  %8314 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8315 = getelementptr inbounds i8, i8* %8314, i64 20
  %8316 = bitcast i8* %8315 to float*
  %8317 = load float, float* %8316, align 4
  %8318 = insertelement <4 x float> zeroinitializer, float %8317, i32 0
  %8319 = insertelement <4 x float> %8318, float 0.000000e+00, i32 1
  %8320 = insertelement <4 x float> %8319, float 0.000000e+00, i32 2
  %8321 = insertelement <4 x float> %8320, float 0.000000e+00, i32 3
  %8322 = getelementptr inbounds float, float* %2, i64 7
  %8323 = load float, float* %8322, align 4
  %8324 = insertelement <4 x float> zeroinitializer, float %8323, i32 0
  %8325 = insertelement <4 x float> %8324, float 0.000000e+00, i32 1
  %8326 = insertelement <4 x float> %8325, float 0.000000e+00, i32 2
  %8327 = insertelement <4 x float> %8326, float 0.000000e+00, i32 3
  %8328 = call <4 x float> @llvm.fma.f32.202(<4 x float> %8321, <4 x float> %8327, <4 x float> %8313)
  %8329 = extractelement <4 x float> %8328, i32 0
  %8330 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8331 = getelementptr inbounds i8, i8* %8330, i64 28
  %8332 = bitcast i8* %8331 to float*
  store float %8329, float* %8332, align 4
  %8333 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8334 = getelementptr inbounds i8, i8* %8333, i64 28
  %8335 = bitcast i8* %8334 to float*
  %8336 = load float, float* %8335, align 4
  %8337 = insertelement <4 x float> zeroinitializer, float %8336, i32 0
  %8338 = insertelement <4 x float> %8337, float 0.000000e+00, i32 1
  %8339 = insertelement <4 x float> %8338, float 0.000000e+00, i32 2
  %8340 = insertelement <4 x float> %8339, float 0.000000e+00, i32 3
  %8341 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8342 = getelementptr inbounds i8, i8* %8341, i64 24
  %8343 = bitcast i8* %8342 to float*
  %8344 = load float, float* %8343, align 4
  %8345 = insertelement <4 x float> zeroinitializer, float %8344, i32 0
  %8346 = insertelement <4 x float> %8345, float 0.000000e+00, i32 1
  %8347 = insertelement <4 x float> %8346, float 0.000000e+00, i32 2
  %8348 = insertelement <4 x float> %8347, float 0.000000e+00, i32 3
  %8349 = getelementptr inbounds float, float* %2, i64 11
  %8350 = load float, float* %8349, align 4
  %8351 = insertelement <4 x float> zeroinitializer, float %8350, i32 0
  %8352 = insertelement <4 x float> %8351, float 0.000000e+00, i32 1
  %8353 = insertelement <4 x float> %8352, float 0.000000e+00, i32 2
  %8354 = insertelement <4 x float> %8353, float 0.000000e+00, i32 3
  %8355 = call <4 x float> @llvm.fma.f32.203(<4 x float> %8348, <4 x float> %8354, <4 x float> %8340)
  %8356 = extractelement <4 x float> %8355, i32 0
  %8357 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8358 = getelementptr inbounds i8, i8* %8357, i64 28
  %8359 = bitcast i8* %8358 to float*
  store float %8356, float* %8359, align 4
  %8360 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8361 = getelementptr inbounds i8, i8* %8360, i64 28
  %8362 = bitcast i8* %8361 to float*
  %8363 = load float, float* %8362, align 4
  %8364 = insertelement <4 x float> zeroinitializer, float %8363, i32 0
  %8365 = insertelement <4 x float> %8364, float 0.000000e+00, i32 1
  %8366 = insertelement <4 x float> %8365, float 0.000000e+00, i32 2
  %8367 = insertelement <4 x float> %8366, float 0.000000e+00, i32 3
  %8368 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8369 = getelementptr inbounds i8, i8* %8368, i64 28
  %8370 = bitcast i8* %8369 to float*
  %8371 = load float, float* %8370, align 4
  %8372 = insertelement <4 x float> zeroinitializer, float %8371, i32 0
  %8373 = insertelement <4 x float> %8372, float 0.000000e+00, i32 1
  %8374 = insertelement <4 x float> %8373, float 0.000000e+00, i32 2
  %8375 = insertelement <4 x float> %8374, float 0.000000e+00, i32 3
  %8376 = getelementptr inbounds float, float* %2, i64 15
  %8377 = load float, float* %8376, align 4
  %8378 = insertelement <4 x float> zeroinitializer, float %8377, i32 0
  %8379 = insertelement <4 x float> %8378, float 0.000000e+00, i32 1
  %8380 = insertelement <4 x float> %8379, float 0.000000e+00, i32 2
  %8381 = insertelement <4 x float> %8380, float 0.000000e+00, i32 3
  %8382 = call <4 x float> @llvm.fma.f32.204(<4 x float> %8375, <4 x float> %8381, <4 x float> %8367)
  %8383 = extractelement <4 x float> %8382, i32 0
  %8384 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8385 = getelementptr inbounds i8, i8* %8384, i64 28
  %8386 = bitcast i8* %8385 to float*
  store float %8383, float* %8386, align 4
  %8387 = extractelement <4 x float> %8382, i32 1
  %8388 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8389 = getelementptr inbounds i8, i8* %8388, i64 32
  %8390 = bitcast i8* %8389 to float*
  store float %8387, float* %8390, align 4
  %8391 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8392 = getelementptr inbounds i8, i8* %8391, i64 32
  %8393 = bitcast i8* %8392 to float*
  %8394 = load float, float* %8393, align 4
  %8395 = insertelement <4 x float> zeroinitializer, float %8394, i32 0
  %8396 = insertelement <4 x float> %8395, float 0.000000e+00, i32 1
  %8397 = insertelement <4 x float> %8396, float 0.000000e+00, i32 2
  %8398 = insertelement <4 x float> %8397, float 0.000000e+00, i32 3
  %8399 = load float, float* %2, align 4
  %8400 = insertelement <4 x float> zeroinitializer, float %8399, i32 0
  %8401 = insertelement <4 x float> %8400, float 0.000000e+00, i32 1
  %8402 = insertelement <4 x float> %8401, float 0.000000e+00, i32 2
  %8403 = insertelement <4 x float> %8402, float 0.000000e+00, i32 3
  %8404 = call <4 x float> @llvm.fma.f32.205(<4 x float> %8398, <4 x float> %8403, <4 x float> zeroinitializer)
  %8405 = extractelement <4 x float> %8404, i32 0
  %8406 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8407 = getelementptr inbounds i8, i8* %8406, i64 32
  %8408 = bitcast i8* %8407 to float*
  store float %8405, float* %8408, align 4
  %8409 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8410 = getelementptr inbounds i8, i8* %8409, i64 32
  %8411 = bitcast i8* %8410 to float*
  %8412 = load float, float* %8411, align 4
  %8413 = insertelement <4 x float> zeroinitializer, float %8412, i32 0
  %8414 = insertelement <4 x float> %8413, float 0.000000e+00, i32 1
  %8415 = insertelement <4 x float> %8414, float 0.000000e+00, i32 2
  %8416 = insertelement <4 x float> %8415, float 0.000000e+00, i32 3
  %8417 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8418 = getelementptr inbounds i8, i8* %8417, i64 36
  %8419 = bitcast i8* %8418 to float*
  %8420 = load float, float* %8419, align 4
  %8421 = insertelement <4 x float> zeroinitializer, float %8420, i32 0
  %8422 = insertelement <4 x float> %8421, float 0.000000e+00, i32 1
  %8423 = insertelement <4 x float> %8422, float 0.000000e+00, i32 2
  %8424 = insertelement <4 x float> %8423, float 0.000000e+00, i32 3
  %8425 = getelementptr inbounds float, float* %2, i64 4
  %8426 = load float, float* %8425, align 4
  %8427 = insertelement <4 x float> zeroinitializer, float %8426, i32 0
  %8428 = insertelement <4 x float> %8427, float 0.000000e+00, i32 1
  %8429 = insertelement <4 x float> %8428, float 0.000000e+00, i32 2
  %8430 = insertelement <4 x float> %8429, float 0.000000e+00, i32 3
  %8431 = call <4 x float> @llvm.fma.f32.206(<4 x float> %8424, <4 x float> %8430, <4 x float> %8416)
  %8432 = extractelement <4 x float> %8431, i32 0
  %8433 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8434 = getelementptr inbounds i8, i8* %8433, i64 32
  %8435 = bitcast i8* %8434 to float*
  store float %8432, float* %8435, align 4
  %8436 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8437 = getelementptr inbounds i8, i8* %8436, i64 32
  %8438 = bitcast i8* %8437 to float*
  %8439 = load float, float* %8438, align 4
  %8440 = insertelement <4 x float> zeroinitializer, float %8439, i32 0
  %8441 = insertelement <4 x float> %8440, float 0.000000e+00, i32 1
  %8442 = insertelement <4 x float> %8441, float 0.000000e+00, i32 2
  %8443 = insertelement <4 x float> %8442, float 0.000000e+00, i32 3
  %8444 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8445 = getelementptr inbounds i8, i8* %8444, i64 40
  %8446 = bitcast i8* %8445 to float*
  %8447 = load float, float* %8446, align 4
  %8448 = insertelement <4 x float> zeroinitializer, float %8447, i32 0
  %8449 = insertelement <4 x float> %8448, float 0.000000e+00, i32 1
  %8450 = insertelement <4 x float> %8449, float 0.000000e+00, i32 2
  %8451 = insertelement <4 x float> %8450, float 0.000000e+00, i32 3
  %8452 = getelementptr inbounds float, float* %2, i64 8
  %8453 = load float, float* %8452, align 4
  %8454 = insertelement <4 x float> zeroinitializer, float %8453, i32 0
  %8455 = insertelement <4 x float> %8454, float 0.000000e+00, i32 1
  %8456 = insertelement <4 x float> %8455, float 0.000000e+00, i32 2
  %8457 = insertelement <4 x float> %8456, float 0.000000e+00, i32 3
  %8458 = call <4 x float> @llvm.fma.f32.207(<4 x float> %8451, <4 x float> %8457, <4 x float> %8443)
  %8459 = extractelement <4 x float> %8458, i32 0
  %8460 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8461 = getelementptr inbounds i8, i8* %8460, i64 32
  %8462 = bitcast i8* %8461 to float*
  store float %8459, float* %8462, align 4
  %8463 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8464 = getelementptr inbounds i8, i8* %8463, i64 32
  %8465 = bitcast i8* %8464 to float*
  %8466 = load float, float* %8465, align 4
  %8467 = insertelement <4 x float> zeroinitializer, float %8466, i32 0
  %8468 = insertelement <4 x float> %8467, float 0.000000e+00, i32 1
  %8469 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8470 = getelementptr inbounds i8, i8* %8469, i64 36
  %8471 = bitcast i8* %8470 to float*
  %8472 = load float, float* %8471, align 4
  %8473 = insertelement <4 x float> %8468, float %8472, i32 2
  %8474 = insertelement <4 x float> %8473, float 0.000000e+00, i32 3
  %8475 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8476 = getelementptr inbounds i8, i8* %8475, i64 44
  %8477 = bitcast i8* %8476 to float*
  %8478 = load float, float* %8477, align 4
  %8479 = insertelement <4 x float> zeroinitializer, float %8478, i32 0
  %8480 = insertelement <4 x float> %8479, float 0.000000e+00, i32 1
  %8481 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8482 = getelementptr inbounds i8, i8* %8481, i64 32
  %8483 = bitcast i8* %8482 to float*
  %8484 = load float, float* %8483, align 4
  %8485 = insertelement <4 x float> %8480, float %8484, i32 2
  %8486 = insertelement <4 x float> %8485, float 0.000000e+00, i32 3
  %8487 = getelementptr inbounds float, float* %2, i64 12
  %8488 = load float, float* %8487, align 4
  %8489 = insertelement <4 x float> zeroinitializer, float %8488, i32 0
  %8490 = insertelement <4 x float> %8489, float 0.000000e+00, i32 1
  %8491 = getelementptr inbounds float, float* %2, i64 1
  %8492 = load float, float* %8491, align 4
  %8493 = insertelement <4 x float> %8490, float %8492, i32 2
  %8494 = insertelement <4 x float> %8493, float 0.000000e+00, i32 3
  %8495 = call <4 x float> @llvm.fma.f32.208(<4 x float> %8486, <4 x float> %8494, <4 x float> %8474)
  %8496 = extractelement <4 x float> %8495, i32 0
  %8497 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8498 = getelementptr inbounds i8, i8* %8497, i64 32
  %8499 = bitcast i8* %8498 to float*
  store float %8496, float* %8499, align 4
  %8500 = extractelement <4 x float> %8495, i32 1
  %8501 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8502 = getelementptr inbounds i8, i8* %8501, i64 36
  %8503 = bitcast i8* %8502 to float*
  store float %8500, float* %8503, align 4
  %8504 = extractelement <4 x float> %8495, i32 2
  %8505 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8506 = getelementptr inbounds i8, i8* %8505, i64 36
  %8507 = bitcast i8* %8506 to float*
  store float %8504, float* %8507, align 4
  %8508 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8509 = getelementptr inbounds i8, i8* %8508, i64 36
  %8510 = bitcast i8* %8509 to float*
  %8511 = load float, float* %8510, align 4
  %8512 = insertelement <4 x float> zeroinitializer, float %8511, i32 0
  %8513 = insertelement <4 x float> %8512, float 0.000000e+00, i32 1
  %8514 = insertelement <4 x float> %8513, float 0.000000e+00, i32 2
  %8515 = insertelement <4 x float> %8514, float 0.000000e+00, i32 3
  %8516 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8517 = getelementptr inbounds i8, i8* %8516, i64 36
  %8518 = bitcast i8* %8517 to float*
  %8519 = load float, float* %8518, align 4
  %8520 = insertelement <4 x float> zeroinitializer, float %8519, i32 0
  %8521 = insertelement <4 x float> %8520, float 0.000000e+00, i32 1
  %8522 = insertelement <4 x float> %8521, float 0.000000e+00, i32 2
  %8523 = insertelement <4 x float> %8522, float 0.000000e+00, i32 3
  %8524 = getelementptr inbounds float, float* %2, i64 5
  %8525 = load float, float* %8524, align 4
  %8526 = insertelement <4 x float> zeroinitializer, float %8525, i32 0
  %8527 = insertelement <4 x float> %8526, float 0.000000e+00, i32 1
  %8528 = insertelement <4 x float> %8527, float 0.000000e+00, i32 2
  %8529 = insertelement <4 x float> %8528, float 0.000000e+00, i32 3
  %8530 = call <4 x float> @llvm.fma.f32.209(<4 x float> %8523, <4 x float> %8529, <4 x float> %8515)
  %8531 = extractelement <4 x float> %8530, i32 0
  %8532 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8533 = getelementptr inbounds i8, i8* %8532, i64 36
  %8534 = bitcast i8* %8533 to float*
  store float %8531, float* %8534, align 4
  %8535 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8536 = getelementptr inbounds i8, i8* %8535, i64 36
  %8537 = bitcast i8* %8536 to float*
  %8538 = load float, float* %8537, align 4
  %8539 = insertelement <4 x float> zeroinitializer, float %8538, i32 0
  %8540 = insertelement <4 x float> %8539, float 0.000000e+00, i32 1
  %8541 = insertelement <4 x float> %8540, float 0.000000e+00, i32 2
  %8542 = insertelement <4 x float> %8541, float 0.000000e+00, i32 3
  %8543 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8544 = getelementptr inbounds i8, i8* %8543, i64 40
  %8545 = bitcast i8* %8544 to float*
  %8546 = load float, float* %8545, align 4
  %8547 = insertelement <4 x float> zeroinitializer, float %8546, i32 0
  %8548 = insertelement <4 x float> %8547, float 0.000000e+00, i32 1
  %8549 = insertelement <4 x float> %8548, float 0.000000e+00, i32 2
  %8550 = insertelement <4 x float> %8549, float 0.000000e+00, i32 3
  %8551 = getelementptr inbounds float, float* %2, i64 9
  %8552 = load float, float* %8551, align 4
  %8553 = insertelement <4 x float> zeroinitializer, float %8552, i32 0
  %8554 = insertelement <4 x float> %8553, float 0.000000e+00, i32 1
  %8555 = insertelement <4 x float> %8554, float 0.000000e+00, i32 2
  %8556 = insertelement <4 x float> %8555, float 0.000000e+00, i32 3
  %8557 = call <4 x float> @llvm.fma.f32.210(<4 x float> %8550, <4 x float> %8556, <4 x float> %8542)
  %8558 = extractelement <4 x float> %8557, i32 0
  %8559 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8560 = getelementptr inbounds i8, i8* %8559, i64 36
  %8561 = bitcast i8* %8560 to float*
  store float %8558, float* %8561, align 4
  %8562 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8563 = getelementptr inbounds i8, i8* %8562, i64 36
  %8564 = bitcast i8* %8563 to float*
  %8565 = load float, float* %8564, align 4
  %8566 = insertelement <4 x float> zeroinitializer, float %8565, i32 0
  %8567 = insertelement <4 x float> %8566, float 0.000000e+00, i32 1
  %8568 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8569 = getelementptr inbounds i8, i8* %8568, i64 40
  %8570 = bitcast i8* %8569 to float*
  %8571 = load float, float* %8570, align 4
  %8572 = insertelement <4 x float> %8567, float %8571, i32 2
  %8573 = insertelement <4 x float> %8572, float 0.000000e+00, i32 3
  %8574 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8575 = getelementptr inbounds i8, i8* %8574, i64 44
  %8576 = bitcast i8* %8575 to float*
  %8577 = load float, float* %8576, align 4
  %8578 = insertelement <4 x float> zeroinitializer, float %8577, i32 0
  %8579 = insertelement <4 x float> %8578, float 0.000000e+00, i32 1
  %8580 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8581 = getelementptr inbounds i8, i8* %8580, i64 32
  %8582 = bitcast i8* %8581 to float*
  %8583 = load float, float* %8582, align 4
  %8584 = insertelement <4 x float> %8579, float %8583, i32 2
  %8585 = insertelement <4 x float> %8584, float 0.000000e+00, i32 3
  %8586 = getelementptr inbounds float, float* %2, i64 13
  %8587 = load float, float* %8586, align 4
  %8588 = insertelement <4 x float> zeroinitializer, float %8587, i32 0
  %8589 = insertelement <4 x float> %8588, float 0.000000e+00, i32 1
  %8590 = getelementptr inbounds float, float* %2, i64 2
  %8591 = load float, float* %8590, align 4
  %8592 = insertelement <4 x float> %8589, float %8591, i32 2
  %8593 = insertelement <4 x float> %8592, float 0.000000e+00, i32 3
  %8594 = call <4 x float> @llvm.fma.f32.211(<4 x float> %8585, <4 x float> %8593, <4 x float> %8573)
  %8595 = extractelement <4 x float> %8594, i32 0
  %8596 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8597 = getelementptr inbounds i8, i8* %8596, i64 36
  %8598 = bitcast i8* %8597 to float*
  store float %8595, float* %8598, align 4
  %8599 = extractelement <4 x float> %8594, i32 1
  %8600 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8601 = getelementptr inbounds i8, i8* %8600, i64 40
  %8602 = bitcast i8* %8601 to float*
  store float %8599, float* %8602, align 4
  %8603 = extractelement <4 x float> %8594, i32 2
  %8604 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8605 = getelementptr inbounds i8, i8* %8604, i64 40
  %8606 = bitcast i8* %8605 to float*
  store float %8603, float* %8606, align 4
  %8607 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8608 = getelementptr inbounds i8, i8* %8607, i64 40
  %8609 = bitcast i8* %8608 to float*
  %8610 = load float, float* %8609, align 4
  %8611 = insertelement <4 x float> zeroinitializer, float %8610, i32 0
  %8612 = insertelement <4 x float> %8611, float 0.000000e+00, i32 1
  %8613 = insertelement <4 x float> %8612, float 0.000000e+00, i32 2
  %8614 = insertelement <4 x float> %8613, float 0.000000e+00, i32 3
  %8615 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8616 = getelementptr inbounds i8, i8* %8615, i64 36
  %8617 = bitcast i8* %8616 to float*
  %8618 = load float, float* %8617, align 4
  %8619 = insertelement <4 x float> zeroinitializer, float %8618, i32 0
  %8620 = insertelement <4 x float> %8619, float 0.000000e+00, i32 1
  %8621 = insertelement <4 x float> %8620, float 0.000000e+00, i32 2
  %8622 = insertelement <4 x float> %8621, float 0.000000e+00, i32 3
  %8623 = getelementptr inbounds float, float* %2, i64 6
  %8624 = load float, float* %8623, align 4
  %8625 = insertelement <4 x float> zeroinitializer, float %8624, i32 0
  %8626 = insertelement <4 x float> %8625, float 0.000000e+00, i32 1
  %8627 = insertelement <4 x float> %8626, float 0.000000e+00, i32 2
  %8628 = insertelement <4 x float> %8627, float 0.000000e+00, i32 3
  %8629 = call <4 x float> @llvm.fma.f32.212(<4 x float> %8622, <4 x float> %8628, <4 x float> %8614)
  %8630 = extractelement <4 x float> %8629, i32 0
  %8631 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8632 = getelementptr inbounds i8, i8* %8631, i64 40
  %8633 = bitcast i8* %8632 to float*
  store float %8630, float* %8633, align 4
  %8634 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8635 = getelementptr inbounds i8, i8* %8634, i64 40
  %8636 = bitcast i8* %8635 to float*
  %8637 = load float, float* %8636, align 4
  %8638 = insertelement <4 x float> zeroinitializer, float %8637, i32 0
  %8639 = insertelement <4 x float> %8638, float 0.000000e+00, i32 1
  %8640 = insertelement <4 x float> %8639, float 0.000000e+00, i32 2
  %8641 = insertelement <4 x float> %8640, float 0.000000e+00, i32 3
  %8642 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8643 = getelementptr inbounds i8, i8* %8642, i64 40
  %8644 = bitcast i8* %8643 to float*
  %8645 = load float, float* %8644, align 4
  %8646 = insertelement <4 x float> zeroinitializer, float %8645, i32 0
  %8647 = insertelement <4 x float> %8646, float 0.000000e+00, i32 1
  %8648 = insertelement <4 x float> %8647, float 0.000000e+00, i32 2
  %8649 = insertelement <4 x float> %8648, float 0.000000e+00, i32 3
  %8650 = getelementptr inbounds float, float* %2, i64 10
  %8651 = load float, float* %8650, align 4
  %8652 = insertelement <4 x float> zeroinitializer, float %8651, i32 0
  %8653 = insertelement <4 x float> %8652, float 0.000000e+00, i32 1
  %8654 = insertelement <4 x float> %8653, float 0.000000e+00, i32 2
  %8655 = insertelement <4 x float> %8654, float 0.000000e+00, i32 3
  %8656 = call <4 x float> @llvm.fma.f32.213(<4 x float> %8649, <4 x float> %8655, <4 x float> %8641)
  %8657 = extractelement <4 x float> %8656, i32 0
  %8658 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8659 = getelementptr inbounds i8, i8* %8658, i64 40
  %8660 = bitcast i8* %8659 to float*
  store float %8657, float* %8660, align 4
  %8661 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8662 = getelementptr inbounds i8, i8* %8661, i64 40
  %8663 = bitcast i8* %8662 to float*
  %8664 = load float, float* %8663, align 4
  %8665 = insertelement <4 x float> zeroinitializer, float %8664, i32 0
  %8666 = insertelement <4 x float> %8665, float 0.000000e+00, i32 1
  %8667 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8668 = getelementptr inbounds i8, i8* %8667, i64 44
  %8669 = bitcast i8* %8668 to float*
  %8670 = load float, float* %8669, align 4
  %8671 = insertelement <4 x float> %8666, float %8670, i32 2
  %8672 = insertelement <4 x float> %8671, float 0.000000e+00, i32 3
  %8673 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8674 = getelementptr inbounds i8, i8* %8673, i64 44
  %8675 = bitcast i8* %8674 to float*
  %8676 = load float, float* %8675, align 4
  %8677 = insertelement <4 x float> zeroinitializer, float %8676, i32 0
  %8678 = insertelement <4 x float> %8677, float 0.000000e+00, i32 1
  %8679 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8680 = getelementptr inbounds i8, i8* %8679, i64 32
  %8681 = bitcast i8* %8680 to float*
  %8682 = load float, float* %8681, align 4
  %8683 = insertelement <4 x float> %8678, float %8682, i32 2
  %8684 = insertelement <4 x float> %8683, float 0.000000e+00, i32 3
  %8685 = getelementptr inbounds float, float* %2, i64 14
  %8686 = load float, float* %8685, align 4
  %8687 = insertelement <4 x float> zeroinitializer, float %8686, i32 0
  %8688 = insertelement <4 x float> %8687, float 0.000000e+00, i32 1
  %8689 = getelementptr inbounds float, float* %2, i64 3
  %8690 = load float, float* %8689, align 4
  %8691 = insertelement <4 x float> %8688, float %8690, i32 2
  %8692 = insertelement <4 x float> %8691, float 0.000000e+00, i32 3
  %8693 = call <4 x float> @llvm.fma.f32.214(<4 x float> %8684, <4 x float> %8692, <4 x float> %8672)
  %8694 = extractelement <4 x float> %8693, i32 0
  %8695 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8696 = getelementptr inbounds i8, i8* %8695, i64 40
  %8697 = bitcast i8* %8696 to float*
  store float %8694, float* %8697, align 4
  %8698 = extractelement <4 x float> %8693, i32 1
  %8699 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8700 = getelementptr inbounds i8, i8* %8699, i64 44
  %8701 = bitcast i8* %8700 to float*
  store float %8698, float* %8701, align 4
  %8702 = extractelement <4 x float> %8693, i32 2
  %8703 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8704 = getelementptr inbounds i8, i8* %8703, i64 44
  %8705 = bitcast i8* %8704 to float*
  store float %8702, float* %8705, align 4
  %8706 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8707 = getelementptr inbounds i8, i8* %8706, i64 44
  %8708 = bitcast i8* %8707 to float*
  %8709 = load float, float* %8708, align 4
  %8710 = insertelement <4 x float> zeroinitializer, float %8709, i32 0
  %8711 = insertelement <4 x float> %8710, float 0.000000e+00, i32 1
  %8712 = insertelement <4 x float> %8711, float 0.000000e+00, i32 2
  %8713 = insertelement <4 x float> %8712, float 0.000000e+00, i32 3
  %8714 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8715 = getelementptr inbounds i8, i8* %8714, i64 36
  %8716 = bitcast i8* %8715 to float*
  %8717 = load float, float* %8716, align 4
  %8718 = insertelement <4 x float> zeroinitializer, float %8717, i32 0
  %8719 = insertelement <4 x float> %8718, float 0.000000e+00, i32 1
  %8720 = insertelement <4 x float> %8719, float 0.000000e+00, i32 2
  %8721 = insertelement <4 x float> %8720, float 0.000000e+00, i32 3
  %8722 = getelementptr inbounds float, float* %2, i64 7
  %8723 = load float, float* %8722, align 4
  %8724 = insertelement <4 x float> zeroinitializer, float %8723, i32 0
  %8725 = insertelement <4 x float> %8724, float 0.000000e+00, i32 1
  %8726 = insertelement <4 x float> %8725, float 0.000000e+00, i32 2
  %8727 = insertelement <4 x float> %8726, float 0.000000e+00, i32 3
  %8728 = call <4 x float> @llvm.fma.f32.215(<4 x float> %8721, <4 x float> %8727, <4 x float> %8713)
  %8729 = extractelement <4 x float> %8728, i32 0
  %8730 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8731 = getelementptr inbounds i8, i8* %8730, i64 44
  %8732 = bitcast i8* %8731 to float*
  store float %8729, float* %8732, align 4
  %8733 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8734 = getelementptr inbounds i8, i8* %8733, i64 44
  %8735 = bitcast i8* %8734 to float*
  %8736 = load float, float* %8735, align 4
  %8737 = insertelement <4 x float> zeroinitializer, float %8736, i32 0
  %8738 = insertelement <4 x float> %8737, float 0.000000e+00, i32 1
  %8739 = insertelement <4 x float> %8738, float 0.000000e+00, i32 2
  %8740 = insertelement <4 x float> %8739, float 0.000000e+00, i32 3
  %8741 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8742 = getelementptr inbounds i8, i8* %8741, i64 40
  %8743 = bitcast i8* %8742 to float*
  %8744 = load float, float* %8743, align 4
  %8745 = insertelement <4 x float> zeroinitializer, float %8744, i32 0
  %8746 = insertelement <4 x float> %8745, float 0.000000e+00, i32 1
  %8747 = insertelement <4 x float> %8746, float 0.000000e+00, i32 2
  %8748 = insertelement <4 x float> %8747, float 0.000000e+00, i32 3
  %8749 = getelementptr inbounds float, float* %2, i64 11
  %8750 = load float, float* %8749, align 4
  %8751 = insertelement <4 x float> zeroinitializer, float %8750, i32 0
  %8752 = insertelement <4 x float> %8751, float 0.000000e+00, i32 1
  %8753 = insertelement <4 x float> %8752, float 0.000000e+00, i32 2
  %8754 = insertelement <4 x float> %8753, float 0.000000e+00, i32 3
  %8755 = call <4 x float> @llvm.fma.f32.216(<4 x float> %8748, <4 x float> %8754, <4 x float> %8740)
  %8756 = extractelement <4 x float> %8755, i32 0
  %8757 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8758 = getelementptr inbounds i8, i8* %8757, i64 44
  %8759 = bitcast i8* %8758 to float*
  store float %8756, float* %8759, align 4
  %8760 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8761 = getelementptr inbounds i8, i8* %8760, i64 44
  %8762 = bitcast i8* %8761 to float*
  %8763 = load float, float* %8762, align 4
  %8764 = insertelement <4 x float> zeroinitializer, float %8763, i32 0
  %8765 = insertelement <4 x float> %8764, float 0.000000e+00, i32 1
  %8766 = insertelement <4 x float> %8765, float 0.000000e+00, i32 2
  %8767 = insertelement <4 x float> %8766, float 0.000000e+00, i32 3
  %8768 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8769 = getelementptr inbounds i8, i8* %8768, i64 44
  %8770 = bitcast i8* %8769 to float*
  %8771 = load float, float* %8770, align 4
  %8772 = insertelement <4 x float> zeroinitializer, float %8771, i32 0
  %8773 = insertelement <4 x float> %8772, float 0.000000e+00, i32 1
  %8774 = insertelement <4 x float> %8773, float 0.000000e+00, i32 2
  %8775 = insertelement <4 x float> %8774, float 0.000000e+00, i32 3
  %8776 = getelementptr inbounds float, float* %2, i64 15
  %8777 = load float, float* %8776, align 4
  %8778 = insertelement <4 x float> zeroinitializer, float %8777, i32 0
  %8779 = insertelement <4 x float> %8778, float 0.000000e+00, i32 1
  %8780 = insertelement <4 x float> %8779, float 0.000000e+00, i32 2
  %8781 = insertelement <4 x float> %8780, float 0.000000e+00, i32 3
  %8782 = call <4 x float> @llvm.fma.f32.217(<4 x float> %8775, <4 x float> %8781, <4 x float> %8767)
  %8783 = extractelement <4 x float> %8782, i32 0
  %8784 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8785 = getelementptr inbounds i8, i8* %8784, i64 44
  %8786 = bitcast i8* %8785 to float*
  store float %8783, float* %8786, align 4
  %8787 = extractelement <4 x float> %8782, i32 1
  %8788 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8789 = getelementptr inbounds i8, i8* %8788, i64 48
  %8790 = bitcast i8* %8789 to float*
  store float %8787, float* %8790, align 4
  %8791 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8792 = getelementptr inbounds i8, i8* %8791, i64 48
  %8793 = bitcast i8* %8792 to float*
  %8794 = load float, float* %8793, align 4
  %8795 = insertelement <4 x float> zeroinitializer, float %8794, i32 0
  %8796 = insertelement <4 x float> %8795, float 0.000000e+00, i32 1
  %8797 = insertelement <4 x float> %8796, float 0.000000e+00, i32 2
  %8798 = insertelement <4 x float> %8797, float 0.000000e+00, i32 3
  %8799 = load float, float* %2, align 4
  %8800 = insertelement <4 x float> zeroinitializer, float %8799, i32 0
  %8801 = insertelement <4 x float> %8800, float 0.000000e+00, i32 1
  %8802 = insertelement <4 x float> %8801, float 0.000000e+00, i32 2
  %8803 = insertelement <4 x float> %8802, float 0.000000e+00, i32 3
  %8804 = call <4 x float> @llvm.fma.f32.218(<4 x float> %8798, <4 x float> %8803, <4 x float> zeroinitializer)
  %8805 = extractelement <4 x float> %8804, i32 0
  %8806 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8807 = getelementptr inbounds i8, i8* %8806, i64 48
  %8808 = bitcast i8* %8807 to float*
  store float %8805, float* %8808, align 4
  %8809 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8810 = getelementptr inbounds i8, i8* %8809, i64 48
  %8811 = bitcast i8* %8810 to float*
  %8812 = load float, float* %8811, align 4
  %8813 = insertelement <4 x float> zeroinitializer, float %8812, i32 0
  %8814 = insertelement <4 x float> %8813, float 0.000000e+00, i32 1
  %8815 = insertelement <4 x float> %8814, float 0.000000e+00, i32 2
  %8816 = insertelement <4 x float> %8815, float 0.000000e+00, i32 3
  %8817 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8818 = getelementptr inbounds i8, i8* %8817, i64 52
  %8819 = bitcast i8* %8818 to float*
  %8820 = load float, float* %8819, align 4
  %8821 = insertelement <4 x float> zeroinitializer, float %8820, i32 0
  %8822 = insertelement <4 x float> %8821, float 0.000000e+00, i32 1
  %8823 = insertelement <4 x float> %8822, float 0.000000e+00, i32 2
  %8824 = insertelement <4 x float> %8823, float 0.000000e+00, i32 3
  %8825 = getelementptr inbounds float, float* %2, i64 4
  %8826 = load float, float* %8825, align 4
  %8827 = insertelement <4 x float> zeroinitializer, float %8826, i32 0
  %8828 = insertelement <4 x float> %8827, float 0.000000e+00, i32 1
  %8829 = insertelement <4 x float> %8828, float 0.000000e+00, i32 2
  %8830 = insertelement <4 x float> %8829, float 0.000000e+00, i32 3
  %8831 = call <4 x float> @llvm.fma.f32.219(<4 x float> %8824, <4 x float> %8830, <4 x float> %8816)
  %8832 = extractelement <4 x float> %8831, i32 0
  %8833 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8834 = getelementptr inbounds i8, i8* %8833, i64 48
  %8835 = bitcast i8* %8834 to float*
  store float %8832, float* %8835, align 4
  %8836 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8837 = getelementptr inbounds i8, i8* %8836, i64 48
  %8838 = bitcast i8* %8837 to float*
  %8839 = load float, float* %8838, align 4
  %8840 = insertelement <4 x float> zeroinitializer, float %8839, i32 0
  %8841 = insertelement <4 x float> %8840, float 0.000000e+00, i32 1
  %8842 = insertelement <4 x float> %8841, float 0.000000e+00, i32 2
  %8843 = insertelement <4 x float> %8842, float 0.000000e+00, i32 3
  %8844 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8845 = getelementptr inbounds i8, i8* %8844, i64 56
  %8846 = bitcast i8* %8845 to float*
  %8847 = load float, float* %8846, align 4
  %8848 = insertelement <4 x float> zeroinitializer, float %8847, i32 0
  %8849 = insertelement <4 x float> %8848, float 0.000000e+00, i32 1
  %8850 = insertelement <4 x float> %8849, float 0.000000e+00, i32 2
  %8851 = insertelement <4 x float> %8850, float 0.000000e+00, i32 3
  %8852 = getelementptr inbounds float, float* %2, i64 8
  %8853 = load float, float* %8852, align 4
  %8854 = insertelement <4 x float> zeroinitializer, float %8853, i32 0
  %8855 = insertelement <4 x float> %8854, float 0.000000e+00, i32 1
  %8856 = insertelement <4 x float> %8855, float 0.000000e+00, i32 2
  %8857 = insertelement <4 x float> %8856, float 0.000000e+00, i32 3
  %8858 = call <4 x float> @llvm.fma.f32.220(<4 x float> %8851, <4 x float> %8857, <4 x float> %8843)
  %8859 = extractelement <4 x float> %8858, i32 0
  %8860 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8861 = getelementptr inbounds i8, i8* %8860, i64 48
  %8862 = bitcast i8* %8861 to float*
  store float %8859, float* %8862, align 4
  %8863 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8864 = getelementptr inbounds i8, i8* %8863, i64 48
  %8865 = bitcast i8* %8864 to float*
  %8866 = load float, float* %8865, align 4
  %8867 = insertelement <4 x float> zeroinitializer, float %8866, i32 0
  %8868 = insertelement <4 x float> %8867, float 0.000000e+00, i32 1
  %8869 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8870 = getelementptr inbounds i8, i8* %8869, i64 52
  %8871 = bitcast i8* %8870 to float*
  %8872 = load float, float* %8871, align 4
  %8873 = insertelement <4 x float> %8868, float %8872, i32 2
  %8874 = insertelement <4 x float> %8873, float 0.000000e+00, i32 3
  %8875 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8876 = getelementptr inbounds i8, i8* %8875, i64 60
  %8877 = bitcast i8* %8876 to float*
  %8878 = load float, float* %8877, align 4
  %8879 = insertelement <4 x float> zeroinitializer, float %8878, i32 0
  %8880 = insertelement <4 x float> %8879, float 0.000000e+00, i32 1
  %8881 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8882 = getelementptr inbounds i8, i8* %8881, i64 48
  %8883 = bitcast i8* %8882 to float*
  %8884 = load float, float* %8883, align 4
  %8885 = insertelement <4 x float> %8880, float %8884, i32 2
  %8886 = insertelement <4 x float> %8885, float 0.000000e+00, i32 3
  %8887 = getelementptr inbounds float, float* %2, i64 12
  %8888 = load float, float* %8887, align 4
  %8889 = insertelement <4 x float> zeroinitializer, float %8888, i32 0
  %8890 = insertelement <4 x float> %8889, float 0.000000e+00, i32 1
  %8891 = getelementptr inbounds float, float* %2, i64 1
  %8892 = load float, float* %8891, align 4
  %8893 = insertelement <4 x float> %8890, float %8892, i32 2
  %8894 = insertelement <4 x float> %8893, float 0.000000e+00, i32 3
  %8895 = call <4 x float> @llvm.fma.f32.221(<4 x float> %8886, <4 x float> %8894, <4 x float> %8874)
  %8896 = extractelement <4 x float> %8895, i32 0
  %8897 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8898 = getelementptr inbounds i8, i8* %8897, i64 48
  %8899 = bitcast i8* %8898 to float*
  store float %8896, float* %8899, align 4
  %8900 = extractelement <4 x float> %8895, i32 1
  %8901 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8902 = getelementptr inbounds i8, i8* %8901, i64 52
  %8903 = bitcast i8* %8902 to float*
  store float %8900, float* %8903, align 4
  %8904 = extractelement <4 x float> %8895, i32 2
  %8905 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8906 = getelementptr inbounds i8, i8* %8905, i64 52
  %8907 = bitcast i8* %8906 to float*
  store float %8904, float* %8907, align 4
  %8908 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8909 = getelementptr inbounds i8, i8* %8908, i64 52
  %8910 = bitcast i8* %8909 to float*
  %8911 = load float, float* %8910, align 4
  %8912 = insertelement <4 x float> zeroinitializer, float %8911, i32 0
  %8913 = insertelement <4 x float> %8912, float 0.000000e+00, i32 1
  %8914 = insertelement <4 x float> %8913, float 0.000000e+00, i32 2
  %8915 = insertelement <4 x float> %8914, float 0.000000e+00, i32 3
  %8916 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8917 = getelementptr inbounds i8, i8* %8916, i64 52
  %8918 = bitcast i8* %8917 to float*
  %8919 = load float, float* %8918, align 4
  %8920 = insertelement <4 x float> zeroinitializer, float %8919, i32 0
  %8921 = insertelement <4 x float> %8920, float 0.000000e+00, i32 1
  %8922 = insertelement <4 x float> %8921, float 0.000000e+00, i32 2
  %8923 = insertelement <4 x float> %8922, float 0.000000e+00, i32 3
  %8924 = getelementptr inbounds float, float* %2, i64 5
  %8925 = load float, float* %8924, align 4
  %8926 = insertelement <4 x float> zeroinitializer, float %8925, i32 0
  %8927 = insertelement <4 x float> %8926, float 0.000000e+00, i32 1
  %8928 = insertelement <4 x float> %8927, float 0.000000e+00, i32 2
  %8929 = insertelement <4 x float> %8928, float 0.000000e+00, i32 3
  %8930 = call <4 x float> @llvm.fma.f32.222(<4 x float> %8923, <4 x float> %8929, <4 x float> %8915)
  %8931 = extractelement <4 x float> %8930, i32 0
  %8932 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8933 = getelementptr inbounds i8, i8* %8932, i64 52
  %8934 = bitcast i8* %8933 to float*
  store float %8931, float* %8934, align 4
  %8935 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8936 = getelementptr inbounds i8, i8* %8935, i64 52
  %8937 = bitcast i8* %8936 to float*
  %8938 = load float, float* %8937, align 4
  %8939 = insertelement <4 x float> zeroinitializer, float %8938, i32 0
  %8940 = insertelement <4 x float> %8939, float 0.000000e+00, i32 1
  %8941 = insertelement <4 x float> %8940, float 0.000000e+00, i32 2
  %8942 = insertelement <4 x float> %8941, float 0.000000e+00, i32 3
  %8943 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8944 = getelementptr inbounds i8, i8* %8943, i64 56
  %8945 = bitcast i8* %8944 to float*
  %8946 = load float, float* %8945, align 4
  %8947 = insertelement <4 x float> zeroinitializer, float %8946, i32 0
  %8948 = insertelement <4 x float> %8947, float 0.000000e+00, i32 1
  %8949 = insertelement <4 x float> %8948, float 0.000000e+00, i32 2
  %8950 = insertelement <4 x float> %8949, float 0.000000e+00, i32 3
  %8951 = getelementptr inbounds float, float* %2, i64 9
  %8952 = load float, float* %8951, align 4
  %8953 = insertelement <4 x float> zeroinitializer, float %8952, i32 0
  %8954 = insertelement <4 x float> %8953, float 0.000000e+00, i32 1
  %8955 = insertelement <4 x float> %8954, float 0.000000e+00, i32 2
  %8956 = insertelement <4 x float> %8955, float 0.000000e+00, i32 3
  %8957 = call <4 x float> @llvm.fma.f32.223(<4 x float> %8950, <4 x float> %8956, <4 x float> %8942)
  %8958 = extractelement <4 x float> %8957, i32 0
  %8959 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8960 = getelementptr inbounds i8, i8* %8959, i64 52
  %8961 = bitcast i8* %8960 to float*
  store float %8958, float* %8961, align 4
  %8962 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8963 = getelementptr inbounds i8, i8* %8962, i64 52
  %8964 = bitcast i8* %8963 to float*
  %8965 = load float, float* %8964, align 4
  %8966 = insertelement <4 x float> zeroinitializer, float %8965, i32 0
  %8967 = insertelement <4 x float> %8966, float 0.000000e+00, i32 1
  %8968 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8969 = getelementptr inbounds i8, i8* %8968, i64 56
  %8970 = bitcast i8* %8969 to float*
  %8971 = load float, float* %8970, align 4
  %8972 = insertelement <4 x float> %8967, float %8971, i32 2
  %8973 = insertelement <4 x float> %8972, float 0.000000e+00, i32 3
  %8974 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8975 = getelementptr inbounds i8, i8* %8974, i64 60
  %8976 = bitcast i8* %8975 to float*
  %8977 = load float, float* %8976, align 4
  %8978 = insertelement <4 x float> zeroinitializer, float %8977, i32 0
  %8979 = insertelement <4 x float> %8978, float 0.000000e+00, i32 1
  %8980 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8981 = getelementptr inbounds i8, i8* %8980, i64 48
  %8982 = bitcast i8* %8981 to float*
  %8983 = load float, float* %8982, align 4
  %8984 = insertelement <4 x float> %8979, float %8983, i32 2
  %8985 = insertelement <4 x float> %8984, float 0.000000e+00, i32 3
  %8986 = getelementptr inbounds float, float* %2, i64 13
  %8987 = load float, float* %8986, align 4
  %8988 = insertelement <4 x float> zeroinitializer, float %8987, i32 0
  %8989 = insertelement <4 x float> %8988, float 0.000000e+00, i32 1
  %8990 = getelementptr inbounds float, float* %2, i64 2
  %8991 = load float, float* %8990, align 4
  %8992 = insertelement <4 x float> %8989, float %8991, i32 2
  %8993 = insertelement <4 x float> %8992, float 0.000000e+00, i32 3
  %8994 = call <4 x float> @llvm.fma.f32.224(<4 x float> %8985, <4 x float> %8993, <4 x float> %8973)
  %8995 = extractelement <4 x float> %8994, i32 0
  %8996 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %8997 = getelementptr inbounds i8, i8* %8996, i64 52
  %8998 = bitcast i8* %8997 to float*
  store float %8995, float* %8998, align 4
  %8999 = extractelement <4 x float> %8994, i32 1
  %9000 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9001 = getelementptr inbounds i8, i8* %9000, i64 56
  %9002 = bitcast i8* %9001 to float*
  store float %8999, float* %9002, align 4
  %9003 = extractelement <4 x float> %8994, i32 2
  %9004 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9005 = getelementptr inbounds i8, i8* %9004, i64 56
  %9006 = bitcast i8* %9005 to float*
  store float %9003, float* %9006, align 4
  %9007 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9008 = getelementptr inbounds i8, i8* %9007, i64 56
  %9009 = bitcast i8* %9008 to float*
  %9010 = load float, float* %9009, align 4
  %9011 = insertelement <4 x float> zeroinitializer, float %9010, i32 0
  %9012 = insertelement <4 x float> %9011, float 0.000000e+00, i32 1
  %9013 = insertelement <4 x float> %9012, float 0.000000e+00, i32 2
  %9014 = insertelement <4 x float> %9013, float 0.000000e+00, i32 3
  %9015 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9016 = getelementptr inbounds i8, i8* %9015, i64 52
  %9017 = bitcast i8* %9016 to float*
  %9018 = load float, float* %9017, align 4
  %9019 = insertelement <4 x float> zeroinitializer, float %9018, i32 0
  %9020 = insertelement <4 x float> %9019, float 0.000000e+00, i32 1
  %9021 = insertelement <4 x float> %9020, float 0.000000e+00, i32 2
  %9022 = insertelement <4 x float> %9021, float 0.000000e+00, i32 3
  %9023 = getelementptr inbounds float, float* %2, i64 6
  %9024 = load float, float* %9023, align 4
  %9025 = insertelement <4 x float> zeroinitializer, float %9024, i32 0
  %9026 = insertelement <4 x float> %9025, float 0.000000e+00, i32 1
  %9027 = insertelement <4 x float> %9026, float 0.000000e+00, i32 2
  %9028 = insertelement <4 x float> %9027, float 0.000000e+00, i32 3
  %9029 = call <4 x float> @llvm.fma.f32.225(<4 x float> %9022, <4 x float> %9028, <4 x float> %9014)
  %9030 = extractelement <4 x float> %9029, i32 0
  %9031 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9032 = getelementptr inbounds i8, i8* %9031, i64 56
  %9033 = bitcast i8* %9032 to float*
  store float %9030, float* %9033, align 4
  %9034 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9035 = getelementptr inbounds i8, i8* %9034, i64 56
  %9036 = bitcast i8* %9035 to float*
  %9037 = load float, float* %9036, align 4
  %9038 = insertelement <4 x float> zeroinitializer, float %9037, i32 0
  %9039 = insertelement <4 x float> %9038, float 0.000000e+00, i32 1
  %9040 = insertelement <4 x float> %9039, float 0.000000e+00, i32 2
  %9041 = insertelement <4 x float> %9040, float 0.000000e+00, i32 3
  %9042 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9043 = getelementptr inbounds i8, i8* %9042, i64 56
  %9044 = bitcast i8* %9043 to float*
  %9045 = load float, float* %9044, align 4
  %9046 = insertelement <4 x float> zeroinitializer, float %9045, i32 0
  %9047 = insertelement <4 x float> %9046, float 0.000000e+00, i32 1
  %9048 = insertelement <4 x float> %9047, float 0.000000e+00, i32 2
  %9049 = insertelement <4 x float> %9048, float 0.000000e+00, i32 3
  %9050 = getelementptr inbounds float, float* %2, i64 10
  %9051 = load float, float* %9050, align 4
  %9052 = insertelement <4 x float> zeroinitializer, float %9051, i32 0
  %9053 = insertelement <4 x float> %9052, float 0.000000e+00, i32 1
  %9054 = insertelement <4 x float> %9053, float 0.000000e+00, i32 2
  %9055 = insertelement <4 x float> %9054, float 0.000000e+00, i32 3
  %9056 = call <4 x float> @llvm.fma.f32.226(<4 x float> %9049, <4 x float> %9055, <4 x float> %9041)
  %9057 = extractelement <4 x float> %9056, i32 0
  %9058 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9059 = getelementptr inbounds i8, i8* %9058, i64 56
  %9060 = bitcast i8* %9059 to float*
  store float %9057, float* %9060, align 4
  %9061 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9062 = getelementptr inbounds i8, i8* %9061, i64 56
  %9063 = bitcast i8* %9062 to float*
  %9064 = load float, float* %9063, align 4
  %9065 = insertelement <4 x float> zeroinitializer, float %9064, i32 0
  %9066 = insertelement <4 x float> %9065, float 0.000000e+00, i32 1
  %9067 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9068 = getelementptr inbounds i8, i8* %9067, i64 60
  %9069 = bitcast i8* %9068 to float*
  %9070 = load float, float* %9069, align 4
  %9071 = insertelement <4 x float> %9066, float %9070, i32 2
  %9072 = insertelement <4 x float> %9071, float 0.000000e+00, i32 3
  %9073 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9074 = getelementptr inbounds i8, i8* %9073, i64 60
  %9075 = bitcast i8* %9074 to float*
  %9076 = load float, float* %9075, align 4
  %9077 = insertelement <4 x float> zeroinitializer, float %9076, i32 0
  %9078 = insertelement <4 x float> %9077, float 0.000000e+00, i32 1
  %9079 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9080 = getelementptr inbounds i8, i8* %9079, i64 48
  %9081 = bitcast i8* %9080 to float*
  %9082 = load float, float* %9081, align 4
  %9083 = insertelement <4 x float> %9078, float %9082, i32 2
  %9084 = insertelement <4 x float> %9083, float 0.000000e+00, i32 3
  %9085 = getelementptr inbounds float, float* %2, i64 14
  %9086 = load float, float* %9085, align 4
  %9087 = insertelement <4 x float> zeroinitializer, float %9086, i32 0
  %9088 = insertelement <4 x float> %9087, float 0.000000e+00, i32 1
  %9089 = getelementptr inbounds float, float* %2, i64 3
  %9090 = load float, float* %9089, align 4
  %9091 = insertelement <4 x float> %9088, float %9090, i32 2
  %9092 = insertelement <4 x float> %9091, float 0.000000e+00, i32 3
  %9093 = call <4 x float> @llvm.fma.f32.227(<4 x float> %9084, <4 x float> %9092, <4 x float> %9072)
  %9094 = extractelement <4 x float> %9093, i32 0
  %9095 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9096 = getelementptr inbounds i8, i8* %9095, i64 56
  %9097 = bitcast i8* %9096 to float*
  store float %9094, float* %9097, align 4
  %9098 = extractelement <4 x float> %9093, i32 1
  %9099 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9100 = getelementptr inbounds i8, i8* %9099, i64 60
  %9101 = bitcast i8* %9100 to float*
  store float %9098, float* %9101, align 4
  %9102 = extractelement <4 x float> %9093, i32 2
  %9103 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9104 = getelementptr inbounds i8, i8* %9103, i64 60
  %9105 = bitcast i8* %9104 to float*
  store float %9102, float* %9105, align 4
  %9106 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9107 = getelementptr inbounds i8, i8* %9106, i64 60
  %9108 = bitcast i8* %9107 to float*
  %9109 = load float, float* %9108, align 4
  %9110 = insertelement <4 x float> zeroinitializer, float %9109, i32 0
  %9111 = insertelement <4 x float> %9110, float 0.000000e+00, i32 1
  %9112 = insertelement <4 x float> %9111, float 0.000000e+00, i32 2
  %9113 = insertelement <4 x float> %9112, float 0.000000e+00, i32 3
  %9114 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9115 = getelementptr inbounds i8, i8* %9114, i64 52
  %9116 = bitcast i8* %9115 to float*
  %9117 = load float, float* %9116, align 4
  %9118 = insertelement <4 x float> zeroinitializer, float %9117, i32 0
  %9119 = insertelement <4 x float> %9118, float 0.000000e+00, i32 1
  %9120 = insertelement <4 x float> %9119, float 0.000000e+00, i32 2
  %9121 = insertelement <4 x float> %9120, float 0.000000e+00, i32 3
  %9122 = getelementptr inbounds float, float* %2, i64 7
  %9123 = load float, float* %9122, align 4
  %9124 = insertelement <4 x float> zeroinitializer, float %9123, i32 0
  %9125 = insertelement <4 x float> %9124, float 0.000000e+00, i32 1
  %9126 = insertelement <4 x float> %9125, float 0.000000e+00, i32 2
  %9127 = insertelement <4 x float> %9126, float 0.000000e+00, i32 3
  %9128 = call <4 x float> @llvm.fma.f32.228(<4 x float> %9121, <4 x float> %9127, <4 x float> %9113)
  %9129 = extractelement <4 x float> %9128, i32 0
  %9130 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9131 = getelementptr inbounds i8, i8* %9130, i64 60
  %9132 = bitcast i8* %9131 to float*
  store float %9129, float* %9132, align 4
  %9133 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9134 = getelementptr inbounds i8, i8* %9133, i64 60
  %9135 = bitcast i8* %9134 to float*
  %9136 = load float, float* %9135, align 4
  %9137 = insertelement <4 x float> zeroinitializer, float %9136, i32 0
  %9138 = insertelement <4 x float> %9137, float 0.000000e+00, i32 1
  %9139 = insertelement <4 x float> %9138, float 0.000000e+00, i32 2
  %9140 = insertelement <4 x float> %9139, float 0.000000e+00, i32 3
  %9141 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9142 = getelementptr inbounds i8, i8* %9141, i64 56
  %9143 = bitcast i8* %9142 to float*
  %9144 = load float, float* %9143, align 4
  %9145 = insertelement <4 x float> zeroinitializer, float %9144, i32 0
  %9146 = insertelement <4 x float> %9145, float 0.000000e+00, i32 1
  %9147 = insertelement <4 x float> %9146, float 0.000000e+00, i32 2
  %9148 = insertelement <4 x float> %9147, float 0.000000e+00, i32 3
  %9149 = getelementptr inbounds float, float* %2, i64 11
  %9150 = load float, float* %9149, align 4
  %9151 = insertelement <4 x float> zeroinitializer, float %9150, i32 0
  %9152 = insertelement <4 x float> %9151, float 0.000000e+00, i32 1
  %9153 = insertelement <4 x float> %9152, float 0.000000e+00, i32 2
  %9154 = insertelement <4 x float> %9153, float 0.000000e+00, i32 3
  %9155 = call <4 x float> @llvm.fma.f32.229(<4 x float> %9148, <4 x float> %9154, <4 x float> %9140)
  %9156 = extractelement <4 x float> %9155, i32 0
  %9157 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9158 = getelementptr inbounds i8, i8* %9157, i64 60
  %9159 = bitcast i8* %9158 to float*
  store float %9156, float* %9159, align 4
  %9160 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9161 = getelementptr inbounds i8, i8* %9160, i64 60
  %9162 = bitcast i8* %9161 to float*
  %9163 = load float, float* %9162, align 4
  %9164 = insertelement <4 x float> zeroinitializer, float %9163, i32 0
  %9165 = insertelement <4 x float> %9164, float 0.000000e+00, i32 1
  %9166 = insertelement <4 x float> %9165, float 0.000000e+00, i32 2
  %9167 = insertelement <4 x float> %9166, float 0.000000e+00, i32 3
  %9168 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9169 = getelementptr inbounds i8, i8* %9168, i64 60
  %9170 = bitcast i8* %9169 to float*
  %9171 = load float, float* %9170, align 4
  %9172 = insertelement <4 x float> zeroinitializer, float %9171, i32 0
  %9173 = insertelement <4 x float> %9172, float 1.000000e+00, i32 1
  %9174 = insertelement <4 x float> %9173, float 1.000000e+00, i32 2
  %9175 = insertelement <4 x float> %9174, float 1.000000e+00, i32 3
  %9176 = getelementptr inbounds float, float* %2, i64 15
  %9177 = load float, float* %9176, align 4
  %9178 = insertelement <4 x float> zeroinitializer, float %9177, i32 0
  %9179 = getelementptr inbounds float, float* %2, i64 10
  %9180 = bitcast float* %9179 to i32*
  %9181 = load i32, i32* %9180, align 4
  %9182 = sitofp i32 %9181 to float
  %9183 = insertelement <4 x float> %9178, float %9182, i32 1
  %9184 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9185 = getelementptr inbounds i8, i8* %9184, i64 40
  %9186 = bitcast i8* %9185 to i32*
  %9187 = load i32, i32* %9186, align 4
  %9188 = sitofp i32 %9187 to float
  %9189 = insertelement <4 x float> %9183, float %9188, i32 2
  %9190 = getelementptr inbounds float, float* %2, i64 14
  %9191 = bitcast float* %9190 to i32*
  %9192 = load i32, i32* %9191, align 4
  %9193 = sitofp i32 %9192 to float
  %9194 = insertelement <4 x float> %9189, float %9193, i32 3
  %9195 = call <4 x float> @llvm.fma.f32.230(<4 x float> %9175, <4 x float> %9194, <4 x float> %9167)
  %9196 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %9197 = bitcast i8* %9196 to float*
  %9198 = load float, float* %9197, align 4
  %9199 = insertelement <4 x float> zeroinitializer, float %9198, i32 1
  %9200 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %9201 = getelementptr inbounds i8, i8* %9200, i64 4
  %9202 = bitcast i8* %9201 to float*
  %9203 = load float, float* %9202, align 4
  %9204 = insertelement <4 x float> %9199, float %9203, i32 2
  %9205 = insertelement <4 x float> %9204, float 0.000000e+00, i32 3
  %9206 = insertelement <4 x float> <float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %2286, i32 1
  %9207 = insertelement <4 x float> %9206, float %2286, i32 2
  %9208 = insertelement <4 x float> %9207, float 1.000000e+00, i32 3
  %9209 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %9210 = bitcast i8* %9209 to float*
  %9211 = load float, float* %9210, align 4
  %9212 = fcmp olt float %9211, 0.000000e+00
  %9213 = sext i1 %9212 to i32
  %9214 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %9215 = bitcast i8* %9214 to float*
  %9216 = load float, float* %9215, align 4
  %9217 = fcmp ogt float %9216, 0.000000e+00
  %9218 = zext i1 %9217 to i32
  %9219 = add nsw i32 %9213, %9218
  %9220 = sitofp i32 %9219 to float
  %9221 = fneg float %9220
  %9222 = insertelement <4 x float> <float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %9221, i32 1
  %9223 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %9224 = bitcast i8* %9223 to float*
  %9225 = load float, float* %9224, align 4
  %9226 = fcmp olt float %9225, 0.000000e+00
  %9227 = sext i1 %9226 to i32
  %9228 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %9229 = bitcast i8* %9228 to float*
  %9230 = load float, float* %9229, align 4
  %9231 = fcmp ogt float %9230, 0.000000e+00
  %9232 = zext i1 %9231 to i32
  %9233 = add nsw i32 %9227, %9232
  %9234 = sitofp i32 %9233 to float
  %9235 = fneg float %9234
  %9236 = insertelement <4 x float> %9222, float %9235, i32 2
  %9237 = insertelement <4 x float> %9236, float 1.000000e+00, i32 3
  %9238 = fmul <4 x float> %9208, %9237
  %9239 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9240 = getelementptr inbounds i8, i8* %9239, i64 56
  %9241 = bitcast i8* %9240 to i32*
  %9242 = load i32, i32* %9241, align 4
  %9243 = sitofp i32 %9242 to float
  %9244 = insertelement <4 x float> zeroinitializer, float %9243, i32 0
  %9245 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %9246 = bitcast i8* %9245 to float*
  %9247 = load float, float* %9246, align 4
  %9248 = insertelement <4 x float> %9244, float %9247, i32 1
  %9249 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %9250 = getelementptr inbounds i8, i8* %9249, i64 4
  %9251 = bitcast i8* %9250 to float*
  %9252 = load float, float* %9251, align 4
  %9253 = insertelement <4 x float> %9248, float %9252, i32 2
  %9254 = insertelement <4 x float> %9253, float 0.000000e+00, i32 3
  %9255 = call <4 x float> @llvm.fma.f32.231(<4 x float> %9238, <4 x float> %9254, <4 x float> %9205)
  %9256 = shufflevector <4 x float> %9195, <4 x float> %9255, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %9257 = extractelement <8 x float> %9256, i32 0
  %9258 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9259 = getelementptr inbounds i8, i8* %9258, i64 60
  %9260 = bitcast i8* %9259 to float*
  store float %9257, float* %9260, align 4
  %9261 = extractelement <8 x float> %9256, i32 1
  %9262 = fptosi float %9261 to i32
  %9263 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %9264 = bitcast i8* %9263 to i32*
  store i32 %9262, i32* %9264, align 4
  %9265 = extractelement <8 x float> %9256, i32 2
  %9266 = fptosi float %9265 to i32
  %9267 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %9268 = bitcast i8* %9267 to i32*
  store i32 %9266, i32* %9268, align 4
  %9269 = extractelement <8 x float> %9256, i32 3
  %9270 = fptosi float %9269 to i32
  %9271 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %9272 = getelementptr inbounds i8, i8* %9271, i64 4
  %9273 = bitcast i8* %9272 to i32*
  store i32 %9270, i32* %9273, align 4
  %9274 = extractelement <8 x float> %9256, i32 4
  %9275 = fptosi float %9274 to i32
  %9276 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %9277 = getelementptr inbounds i8, i8* %9276, i64 4
  %9278 = bitcast i8* %9277 to i32*
  store i32 %9275, i32* %9278, align 4
  %9279 = extractelement <8 x float> %9256, i32 5
  %9280 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %9281 = bitcast i8* %9280 to float*
  store float %9279, float* %9281, align 4
  %9282 = extractelement <8 x float> %9256, i32 6
  %9283 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %9284 = getelementptr inbounds i8, i8* %9283, i64 4
  %9285 = bitcast i8* %9284 to float*
  store float %9282, float* %9285, align 4
  %9286 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %9287 = bitcast i8* %9286 to float*
  %9288 = load float, float* %9287, align 4
  %9289 = insertelement <4 x float> zeroinitializer, float %9288, i32 0
  %9290 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %9291 = getelementptr inbounds i8, i8* %9290, i64 4
  %9292 = bitcast i8* %9291 to float*
  %9293 = load float, float* %9292, align 4
  %9294 = insertelement <4 x float> %9289, float %9293, i32 1
  %9295 = insertelement <4 x float> %9294, float 0.000000e+00, i32 2
  %9296 = insertelement <4 x float> %9295, float 0.000000e+00, i32 3
  %9297 = insertelement <4 x float> zeroinitializer, float %2317, i32 0
  %9298 = insertelement <4 x float> %9297, float %2317, i32 1
  %9299 = insertelement <4 x float> %9298, float 1.000000e+00, i32 2
  %9300 = insertelement <4 x float> %9299, float 1.000000e+00, i32 3
  %9301 = fdiv <4 x float> %9296, %9300
  %9302 = extractelement <4 x float> %9301, i32 0
  %9303 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %9304 = bitcast i8* %9303 to float*
  store float %9302, float* %9304, align 4
  %9305 = extractelement <4 x float> %9301, i32 1
  %9306 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %9307 = getelementptr inbounds i8, i8* %9306, i64 4
  %9308 = bitcast i8* %9307 to float*
  store float %9305, float* %9308, align 4
  %9309 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %9310 = bitcast i8* %9309 to float*
  %9311 = load float, float* %9310, align 4
  %9312 = insertelement <4 x float> zeroinitializer, float %9311, i32 0
  %9313 = insertelement <4 x float> %9312, float 1.000000e+00, i32 1
  %9314 = insertelement <4 x float> %9313, float 1.000000e+00, i32 2
  %9315 = insertelement <4 x float> %9314, float 1.000000e+00, i32 3
  %9316 = fmul <4 x float> %9315, <float 2.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00>
  %9317 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %9318 = bitcast i8* %9317 to float*
  %9319 = load float, float* %9318, align 4
  %9320 = insertelement <4 x float> zeroinitializer, float %9319, i32 0
  %9321 = insertelement <4 x float> %9320, float 0.000000e+00, i32 1
  %9322 = insertelement <4 x float> %9321, float 0.000000e+00, i32 2
  %9323 = insertelement <4 x float> %9322, float 0.000000e+00, i32 3
  %9324 = fmul <4 x float> %9316, %9323
  %9325 = fsub <4 x float> <float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, %9324
  %9326 = extractelement <4 x float> %9325, i32 0
  %9327 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %9328 = bitcast i8* %9327 to float*
  store float %9326, float* %9328, align 4
  %9329 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %9330 = bitcast i8* %9329 to float*
  %9331 = load float, float* %9330, align 4
  %9332 = insertelement <4 x float> zeroinitializer, float %9331, i32 0
  %9333 = insertelement <4 x float> %9332, float 1.000000e+00, i32 1
  %9334 = insertelement <4 x float> %9333, float 1.000000e+00, i32 2
  %9335 = insertelement <4 x float> %9334, float 1.000000e+00, i32 3
  %9336 = fmul <4 x float> %9335, <float 2.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00>
  %9337 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %9338 = getelementptr inbounds i8, i8* %9337, i64 4
  %9339 = bitcast i8* %9338 to float*
  %9340 = load float, float* %9339, align 4
  %9341 = insertelement <4 x float> zeroinitializer, float %9340, i32 0
  %9342 = insertelement <4 x float> %9341, float 0.000000e+00, i32 1
  %9343 = insertelement <4 x float> %9342, float 0.000000e+00, i32 2
  %9344 = insertelement <4 x float> %9343, float 0.000000e+00, i32 3
  %9345 = fmul <4 x float> %9336, %9344
  %9346 = fsub <4 x float> zeroinitializer, %9345
  %9347 = extractelement <4 x float> %9346, i32 0
  %9348 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %9349 = getelementptr inbounds i8, i8* %9348, i64 4
  %9350 = bitcast i8* %9349 to float*
  store float %9347, float* %9350, align 4
  %9351 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %9352 = getelementptr inbounds i8, i8* %9351, i64 4
  %9353 = bitcast i8* %9352 to float*
  %9354 = load float, float* %9353, align 4
  %9355 = fmul float %9354, 2.000000e+00
  %9356 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %9357 = bitcast i8* %9356 to float*
  %9358 = load float, float* %9357, align 4
  %9359 = fmul float %9355, %9358
  %9360 = fsub float 0.000000e+00, %9359
  %9361 = insertelement <4 x float> zeroinitializer, float %9360, i32 0
  %9362 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %9363 = getelementptr inbounds i8, i8* %9362, i64 4
  %9364 = bitcast i8* %9363 to float*
  %9365 = load float, float* %9364, align 4
  %9366 = fmul float %9365, 2.000000e+00
  %9367 = call dereferenceable_or_null(8) i8* @calloc(i64 4, i64 2) #10
  %9368 = getelementptr inbounds i8, i8* %9367, i64 4
  %9369 = bitcast i8* %9368 to float*
  %9370 = load float, float* %9369, align 4
  %9371 = fmul float %9366, %9370
  %9372 = fsub float 1.000000e+00, %9371
  %9373 = insertelement <4 x float> %9361, float %9372, i32 1
  %9374 = insertelement <4 x float> %9373, float 1.000000e+00, i32 2
  %9375 = insertelement <4 x float> %9374, float 0.000000e+00, i32 3
  %9376 = shufflevector <4 x float> %9375, <4 x float> <float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 1.000000e+00>, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %9377 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %9378 = bitcast i8* %9377 to i32*
  %9379 = load i32, i32* %9378, align 4
  %9380 = sitofp i32 %9379 to float
  %9381 = insertelement <4 x float> zeroinitializer, float %9380, i32 0
  %9382 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %9383 = getelementptr inbounds i8, i8* %9382, i64 4
  %9384 = bitcast i8* %9383 to i32*
  %9385 = load i32, i32* %9384, align 4
  %9386 = sitofp i32 %9385 to float
  %9387 = insertelement <4 x float> %9381, float %9386, i32 1
  %9388 = insertelement <4 x float> %9387, float 0.000000e+00, i32 2
  %9389 = insertelement <4 x float> %9388, float 0.000000e+00, i32 3
  %9390 = shufflevector <4 x float> zeroinitializer, <4 x float> %9389, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %9391 = shufflevector <8 x float> %9376, <8 x float> %9390, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %9392 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %9393 = getelementptr inbounds i8, i8* %9392, i64 8
  %9394 = bitcast i8* %9393 to i32*
  %9395 = load i32, i32* %9394, align 4
  %9396 = sitofp i32 %9395 to float
  %9397 = insertelement <4 x float> zeroinitializer, float %9396, i32 0
  %9398 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %9399 = getelementptr inbounds i8, i8* %9398, i64 12
  %9400 = bitcast i8* %9399 to i32*
  %9401 = load i32, i32* %9400, align 4
  %9402 = sitofp i32 %9401 to float
  %9403 = insertelement <4 x float> %9397, float %9402, i32 1
  %9404 = insertelement <4 x float> %9403, float 0.000000e+00, i32 2
  %9405 = insertelement <4 x float> %9404, float 0.000000e+00, i32 3
  %9406 = shufflevector <4 x float> %9405, <4 x float> zeroinitializer, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %9407 = shufflevector <8 x float> %9406, <8 x float> zeroinitializer, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %9408 = shufflevector <16 x float> %9391, <16 x float> %9407, <32 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31>
  %9409 = extractelement <32 x float> %9408, i32 0
  %9410 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %9411 = getelementptr inbounds i8, i8* %9410, i64 8
  %9412 = bitcast i8* %9411 to float*
  store float %9409, float* %9412, align 4
  %9413 = extractelement <32 x float> %9408, i32 1
  %9414 = call dereferenceable_or_null(16) i8* @calloc(i64 4, i64 4) #10
  %9415 = getelementptr inbounds i8, i8* %9414, i64 12
  %9416 = bitcast i8* %9415 to float*
  store float %9413, float* %9416, align 4
  %9417 = extractelement <32 x float> %9408, i32 2
  %9418 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9419 = bitcast i8* %9418 to float*
  store float %9417, float* %9419, align 4
  %9420 = extractelement <32 x float> %9408, i32 3
  %9421 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9422 = getelementptr inbounds i8, i8* %9421, i64 4
  %9423 = bitcast i8* %9422 to float*
  store float %9420, float* %9423, align 4
  %9424 = extractelement <32 x float> %9408, i32 4
  %9425 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9426 = getelementptr inbounds i8, i8* %9425, i64 8
  %9427 = bitcast i8* %9426 to float*
  store float %9424, float* %9427, align 4
  %9428 = extractelement <32 x float> %9408, i32 5
  %9429 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9430 = getelementptr inbounds i8, i8* %9429, i64 12
  %9431 = bitcast i8* %9430 to float*
  store float %9428, float* %9431, align 4
  %9432 = extractelement <32 x float> %9408, i32 6
  %9433 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9434 = getelementptr inbounds i8, i8* %9433, i64 16
  %9435 = bitcast i8* %9434 to float*
  store float %9432, float* %9435, align 4
  %9436 = extractelement <32 x float> %9408, i32 7
  %9437 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9438 = getelementptr inbounds i8, i8* %9437, i64 20
  %9439 = bitcast i8* %9438 to float*
  store float %9436, float* %9439, align 4
  %9440 = extractelement <32 x float> %9408, i32 8
  %9441 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9442 = getelementptr inbounds i8, i8* %9441, i64 24
  %9443 = bitcast i8* %9442 to float*
  store float %9440, float* %9443, align 4
  %9444 = extractelement <32 x float> %9408, i32 9
  %9445 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9446 = getelementptr inbounds i8, i8* %9445, i64 28
  %9447 = bitcast i8* %9446 to float*
  store float %9444, float* %9447, align 4
  %9448 = extractelement <32 x float> %9408, i32 10
  %9449 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9450 = getelementptr inbounds i8, i8* %9449, i64 32
  %9451 = bitcast i8* %9450 to float*
  store float %9448, float* %9451, align 4
  %9452 = extractelement <32 x float> %9408, i32 11
  %9453 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9454 = getelementptr inbounds i8, i8* %9453, i64 36
  %9455 = bitcast i8* %9454 to float*
  store float %9452, float* %9455, align 4
  %9456 = extractelement <32 x float> %9408, i32 12
  %9457 = fptosi float %9456 to i32
  %9458 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9459 = getelementptr inbounds i8, i8* %9458, i64 40
  %9460 = bitcast i8* %9459 to i32*
  store i32 %9457, i32* %9460, align 4
  %9461 = extractelement <32 x float> %9408, i32 13
  %9462 = fptosi float %9461 to i32
  %9463 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9464 = getelementptr inbounds i8, i8* %9463, i64 44
  %9465 = bitcast i8* %9464 to i32*
  store i32 %9462, i32* %9465, align 4
  %9466 = extractelement <32 x float> %9408, i32 14
  %9467 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9468 = getelementptr inbounds i8, i8* %9467, i64 48
  %9469 = bitcast i8* %9468 to float*
  store float %9466, float* %9469, align 4
  %9470 = extractelement <32 x float> %9408, i32 15
  %9471 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9472 = getelementptr inbounds i8, i8* %9471, i64 52
  %9473 = bitcast i8* %9472 to float*
  store float %9470, float* %9473, align 4
  %9474 = extractelement <32 x float> %9408, i32 16
  %9475 = fptosi float %9474 to i32
  %9476 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9477 = getelementptr inbounds i8, i8* %9476, i64 56
  %9478 = bitcast i8* %9477 to i32*
  store i32 %9475, i32* %9478, align 4
  %9479 = extractelement <32 x float> %9408, i32 17
  %9480 = fptosi float %9479 to i32
  %9481 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9482 = getelementptr inbounds i8, i8* %9481, i64 60
  %9483 = bitcast i8* %9482 to i32*
  store i32 %9480, i32* %9483, align 4
  %9484 = extractelement <32 x float> %9408, i32 18
  %9485 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9486 = bitcast i8* %9485 to float*
  store float %9484, float* %9486, align 4
  %9487 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9488 = bitcast i8* %9487 to float*
  %9489 = load float, float* %9488, align 4
  %9490 = insertelement <4 x float> zeroinitializer, float %9489, i32 0
  %9491 = insertelement <4 x float> %9490, float 0.000000e+00, i32 1
  %9492 = insertelement <4 x float> %9491, float 0.000000e+00, i32 2
  %9493 = insertelement <4 x float> %9492, float 0.000000e+00, i32 3
  %9494 = load float, float* %1, align 4
  %9495 = insertelement <4 x float> zeroinitializer, float %9494, i32 0
  %9496 = insertelement <4 x float> %9495, float 0.000000e+00, i32 1
  %9497 = insertelement <4 x float> %9496, float 0.000000e+00, i32 2
  %9498 = insertelement <4 x float> %9497, float 0.000000e+00, i32 3
  %9499 = call <4 x float> @llvm.fma.f32.232(<4 x float> %9493, <4 x float> %9498, <4 x float> zeroinitializer)
  %9500 = extractelement <4 x float> %9499, i32 0
  %9501 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9502 = bitcast i8* %9501 to float*
  store float %9500, float* %9502, align 4
  %9503 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9504 = bitcast i8* %9503 to float*
  %9505 = load float, float* %9504, align 4
  %9506 = insertelement <4 x float> zeroinitializer, float %9505, i32 0
  %9507 = insertelement <4 x float> %9506, float 0.000000e+00, i32 1
  %9508 = insertelement <4 x float> %9507, float 0.000000e+00, i32 2
  %9509 = insertelement <4 x float> %9508, float 0.000000e+00, i32 3
  %9510 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9511 = getelementptr inbounds i8, i8* %9510, i64 4
  %9512 = bitcast i8* %9511 to float*
  %9513 = load float, float* %9512, align 4
  %9514 = insertelement <4 x float> zeroinitializer, float %9513, i32 0
  %9515 = insertelement <4 x float> %9514, float 0.000000e+00, i32 1
  %9516 = insertelement <4 x float> %9515, float 0.000000e+00, i32 2
  %9517 = insertelement <4 x float> %9516, float 0.000000e+00, i32 3
  %9518 = getelementptr inbounds float, float* %1, i64 4
  %9519 = load float, float* %9518, align 4
  %9520 = insertelement <4 x float> zeroinitializer, float %9519, i32 0
  %9521 = insertelement <4 x float> %9520, float 0.000000e+00, i32 1
  %9522 = insertelement <4 x float> %9521, float 0.000000e+00, i32 2
  %9523 = insertelement <4 x float> %9522, float 0.000000e+00, i32 3
  %9524 = call <4 x float> @llvm.fma.f32.233(<4 x float> %9517, <4 x float> %9523, <4 x float> %9509)
  %9525 = extractelement <4 x float> %9524, i32 0
  %9526 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9527 = bitcast i8* %9526 to float*
  store float %9525, float* %9527, align 4
  %9528 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9529 = bitcast i8* %9528 to float*
  %9530 = load float, float* %9529, align 4
  %9531 = insertelement <4 x float> zeroinitializer, float %9530, i32 0
  %9532 = insertelement <4 x float> %9531, float 0.000000e+00, i32 1
  %9533 = insertelement <4 x float> %9532, float 0.000000e+00, i32 2
  %9534 = insertelement <4 x float> %9533, float 0.000000e+00, i32 3
  %9535 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9536 = getelementptr inbounds i8, i8* %9535, i64 8
  %9537 = bitcast i8* %9536 to float*
  %9538 = load float, float* %9537, align 4
  %9539 = insertelement <4 x float> zeroinitializer, float %9538, i32 0
  %9540 = insertelement <4 x float> %9539, float 0.000000e+00, i32 1
  %9541 = insertelement <4 x float> %9540, float 0.000000e+00, i32 2
  %9542 = insertelement <4 x float> %9541, float 0.000000e+00, i32 3
  %9543 = getelementptr inbounds float, float* %1, i64 8
  %9544 = load float, float* %9543, align 4
  %9545 = insertelement <4 x float> zeroinitializer, float %9544, i32 0
  %9546 = insertelement <4 x float> %9545, float 0.000000e+00, i32 1
  %9547 = insertelement <4 x float> %9546, float 0.000000e+00, i32 2
  %9548 = insertelement <4 x float> %9547, float 0.000000e+00, i32 3
  %9549 = call <4 x float> @llvm.fma.f32.234(<4 x float> %9542, <4 x float> %9548, <4 x float> %9534)
  %9550 = extractelement <4 x float> %9549, i32 0
  %9551 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9552 = bitcast i8* %9551 to float*
  store float %9550, float* %9552, align 4
  %9553 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9554 = bitcast i8* %9553 to float*
  %9555 = load float, float* %9554, align 4
  %9556 = insertelement <4 x float> zeroinitializer, float %9555, i32 0
  %9557 = insertelement <4 x float> %9556, float 0.000000e+00, i32 1
  %9558 = insertelement <4 x float> %9557, float 0.000000e+00, i32 2
  %9559 = insertelement <4 x float> %9558, float 0.000000e+00, i32 3
  %9560 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9561 = getelementptr inbounds i8, i8* %9560, i64 12
  %9562 = bitcast i8* %9561 to float*
  %9563 = load float, float* %9562, align 4
  %9564 = insertelement <4 x float> zeroinitializer, float %9563, i32 0
  %9565 = insertelement <4 x float> %9564, float 0.000000e+00, i32 1
  %9566 = insertelement <4 x float> %9565, float 0.000000e+00, i32 2
  %9567 = insertelement <4 x float> %9566, float 0.000000e+00, i32 3
  %9568 = getelementptr inbounds float, float* %1, i64 12
  %9569 = load float, float* %9568, align 4
  %9570 = insertelement <4 x float> zeroinitializer, float %9569, i32 0
  %9571 = insertelement <4 x float> %9570, float 0.000000e+00, i32 1
  %9572 = insertelement <4 x float> %9571, float 0.000000e+00, i32 2
  %9573 = insertelement <4 x float> %9572, float 0.000000e+00, i32 3
  %9574 = call <4 x float> @llvm.fma.f32.235(<4 x float> %9567, <4 x float> %9573, <4 x float> %9559)
  %9575 = extractelement <4 x float> %9574, i32 0
  %9576 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9577 = bitcast i8* %9576 to float*
  store float %9575, float* %9577, align 4
  %9578 = extractelement <4 x float> %9574, i32 1
  %9579 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9580 = getelementptr inbounds i8, i8* %9579, i64 4
  %9581 = bitcast i8* %9580 to float*
  store float %9578, float* %9581, align 4
  %9582 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9583 = getelementptr inbounds i8, i8* %9582, i64 4
  %9584 = bitcast i8* %9583 to float*
  %9585 = load float, float* %9584, align 4
  %9586 = insertelement <4 x float> zeroinitializer, float %9585, i32 0
  %9587 = insertelement <4 x float> %9586, float 0.000000e+00, i32 1
  %9588 = insertelement <4 x float> %9587, float 0.000000e+00, i32 2
  %9589 = insertelement <4 x float> %9588, float 0.000000e+00, i32 3
  %9590 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9591 = bitcast i8* %9590 to float*
  %9592 = load float, float* %9591, align 4
  %9593 = insertelement <4 x float> zeroinitializer, float %9592, i32 0
  %9594 = insertelement <4 x float> %9593, float 0.000000e+00, i32 1
  %9595 = insertelement <4 x float> %9594, float 0.000000e+00, i32 2
  %9596 = insertelement <4 x float> %9595, float 0.000000e+00, i32 3
  %9597 = getelementptr inbounds float, float* %1, i64 1
  %9598 = load float, float* %9597, align 4
  %9599 = insertelement <4 x float> zeroinitializer, float %9598, i32 0
  %9600 = insertelement <4 x float> %9599, float 0.000000e+00, i32 1
  %9601 = insertelement <4 x float> %9600, float 0.000000e+00, i32 2
  %9602 = insertelement <4 x float> %9601, float 0.000000e+00, i32 3
  %9603 = call <4 x float> @llvm.fma.f32.236(<4 x float> %9596, <4 x float> %9602, <4 x float> %9589)
  %9604 = extractelement <4 x float> %9603, i32 0
  %9605 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9606 = getelementptr inbounds i8, i8* %9605, i64 4
  %9607 = bitcast i8* %9606 to float*
  store float %9604, float* %9607, align 4
  %9608 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9609 = getelementptr inbounds i8, i8* %9608, i64 4
  %9610 = bitcast i8* %9609 to float*
  %9611 = load float, float* %9610, align 4
  %9612 = insertelement <4 x float> zeroinitializer, float %9611, i32 0
  %9613 = insertelement <4 x float> %9612, float 0.000000e+00, i32 1
  %9614 = insertelement <4 x float> %9613, float 0.000000e+00, i32 2
  %9615 = insertelement <4 x float> %9614, float 0.000000e+00, i32 3
  %9616 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9617 = getelementptr inbounds i8, i8* %9616, i64 4
  %9618 = bitcast i8* %9617 to float*
  %9619 = load float, float* %9618, align 4
  %9620 = insertelement <4 x float> zeroinitializer, float %9619, i32 0
  %9621 = insertelement <4 x float> %9620, float 0.000000e+00, i32 1
  %9622 = insertelement <4 x float> %9621, float 0.000000e+00, i32 2
  %9623 = insertelement <4 x float> %9622, float 0.000000e+00, i32 3
  %9624 = getelementptr inbounds float, float* %1, i64 5
  %9625 = load float, float* %9624, align 4
  %9626 = insertelement <4 x float> zeroinitializer, float %9625, i32 0
  %9627 = insertelement <4 x float> %9626, float 0.000000e+00, i32 1
  %9628 = insertelement <4 x float> %9627, float 0.000000e+00, i32 2
  %9629 = insertelement <4 x float> %9628, float 0.000000e+00, i32 3
  %9630 = call <4 x float> @llvm.fma.f32.237(<4 x float> %9623, <4 x float> %9629, <4 x float> %9615)
  %9631 = extractelement <4 x float> %9630, i32 0
  %9632 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9633 = getelementptr inbounds i8, i8* %9632, i64 4
  %9634 = bitcast i8* %9633 to float*
  store float %9631, float* %9634, align 4
  %9635 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9636 = getelementptr inbounds i8, i8* %9635, i64 4
  %9637 = bitcast i8* %9636 to float*
  %9638 = load float, float* %9637, align 4
  %9639 = insertelement <4 x float> zeroinitializer, float %9638, i32 0
  %9640 = insertelement <4 x float> %9639, float 0.000000e+00, i32 1
  %9641 = insertelement <4 x float> %9640, float 0.000000e+00, i32 2
  %9642 = insertelement <4 x float> %9641, float 0.000000e+00, i32 3
  %9643 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9644 = getelementptr inbounds i8, i8* %9643, i64 8
  %9645 = bitcast i8* %9644 to float*
  %9646 = load float, float* %9645, align 4
  %9647 = insertelement <4 x float> zeroinitializer, float %9646, i32 0
  %9648 = insertelement <4 x float> %9647, float 0.000000e+00, i32 1
  %9649 = insertelement <4 x float> %9648, float 0.000000e+00, i32 2
  %9650 = insertelement <4 x float> %9649, float 0.000000e+00, i32 3
  %9651 = getelementptr inbounds float, float* %1, i64 9
  %9652 = load float, float* %9651, align 4
  %9653 = insertelement <4 x float> zeroinitializer, float %9652, i32 0
  %9654 = insertelement <4 x float> %9653, float 0.000000e+00, i32 1
  %9655 = insertelement <4 x float> %9654, float 0.000000e+00, i32 2
  %9656 = insertelement <4 x float> %9655, float 0.000000e+00, i32 3
  %9657 = call <4 x float> @llvm.fma.f32.238(<4 x float> %9650, <4 x float> %9656, <4 x float> %9642)
  %9658 = extractelement <4 x float> %9657, i32 0
  %9659 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9660 = getelementptr inbounds i8, i8* %9659, i64 4
  %9661 = bitcast i8* %9660 to float*
  store float %9658, float* %9661, align 4
  %9662 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9663 = getelementptr inbounds i8, i8* %9662, i64 4
  %9664 = bitcast i8* %9663 to float*
  %9665 = load float, float* %9664, align 4
  %9666 = insertelement <4 x float> zeroinitializer, float %9665, i32 0
  %9667 = insertelement <4 x float> %9666, float 0.000000e+00, i32 1
  %9668 = insertelement <4 x float> %9667, float 0.000000e+00, i32 2
  %9669 = insertelement <4 x float> %9668, float 0.000000e+00, i32 3
  %9670 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9671 = getelementptr inbounds i8, i8* %9670, i64 12
  %9672 = bitcast i8* %9671 to float*
  %9673 = load float, float* %9672, align 4
  %9674 = insertelement <4 x float> zeroinitializer, float %9673, i32 0
  %9675 = insertelement <4 x float> %9674, float 0.000000e+00, i32 1
  %9676 = insertelement <4 x float> %9675, float 0.000000e+00, i32 2
  %9677 = insertelement <4 x float> %9676, float 0.000000e+00, i32 3
  %9678 = getelementptr inbounds float, float* %1, i64 13
  %9679 = load float, float* %9678, align 4
  %9680 = insertelement <4 x float> zeroinitializer, float %9679, i32 0
  %9681 = insertelement <4 x float> %9680, float 0.000000e+00, i32 1
  %9682 = insertelement <4 x float> %9681, float 0.000000e+00, i32 2
  %9683 = insertelement <4 x float> %9682, float 0.000000e+00, i32 3
  %9684 = call <4 x float> @llvm.fma.f32.239(<4 x float> %9677, <4 x float> %9683, <4 x float> %9669)
  %9685 = extractelement <4 x float> %9684, i32 0
  %9686 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9687 = getelementptr inbounds i8, i8* %9686, i64 4
  %9688 = bitcast i8* %9687 to float*
  store float %9685, float* %9688, align 4
  %9689 = extractelement <4 x float> %9684, i32 1
  %9690 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9691 = getelementptr inbounds i8, i8* %9690, i64 8
  %9692 = bitcast i8* %9691 to float*
  store float %9689, float* %9692, align 4
  %9693 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9694 = getelementptr inbounds i8, i8* %9693, i64 8
  %9695 = bitcast i8* %9694 to float*
  %9696 = load float, float* %9695, align 4
  %9697 = insertelement <4 x float> zeroinitializer, float %9696, i32 0
  %9698 = insertelement <4 x float> %9697, float 0.000000e+00, i32 1
  %9699 = insertelement <4 x float> %9698, float 0.000000e+00, i32 2
  %9700 = insertelement <4 x float> %9699, float 0.000000e+00, i32 3
  %9701 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9702 = bitcast i8* %9701 to float*
  %9703 = load float, float* %9702, align 4
  %9704 = insertelement <4 x float> zeroinitializer, float %9703, i32 0
  %9705 = insertelement <4 x float> %9704, float 0.000000e+00, i32 1
  %9706 = insertelement <4 x float> %9705, float 0.000000e+00, i32 2
  %9707 = insertelement <4 x float> %9706, float 0.000000e+00, i32 3
  %9708 = getelementptr inbounds float, float* %1, i64 2
  %9709 = load float, float* %9708, align 4
  %9710 = insertelement <4 x float> zeroinitializer, float %9709, i32 0
  %9711 = insertelement <4 x float> %9710, float 0.000000e+00, i32 1
  %9712 = insertelement <4 x float> %9711, float 0.000000e+00, i32 2
  %9713 = insertelement <4 x float> %9712, float 0.000000e+00, i32 3
  %9714 = call <4 x float> @llvm.fma.f32.240(<4 x float> %9707, <4 x float> %9713, <4 x float> %9700)
  %9715 = extractelement <4 x float> %9714, i32 0
  %9716 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9717 = getelementptr inbounds i8, i8* %9716, i64 8
  %9718 = bitcast i8* %9717 to float*
  store float %9715, float* %9718, align 4
  %9719 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9720 = getelementptr inbounds i8, i8* %9719, i64 8
  %9721 = bitcast i8* %9720 to float*
  %9722 = load float, float* %9721, align 4
  %9723 = insertelement <4 x float> zeroinitializer, float %9722, i32 0
  %9724 = insertelement <4 x float> %9723, float 0.000000e+00, i32 1
  %9725 = insertelement <4 x float> %9724, float 0.000000e+00, i32 2
  %9726 = insertelement <4 x float> %9725, float 0.000000e+00, i32 3
  %9727 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9728 = getelementptr inbounds i8, i8* %9727, i64 4
  %9729 = bitcast i8* %9728 to float*
  %9730 = load float, float* %9729, align 4
  %9731 = insertelement <4 x float> zeroinitializer, float %9730, i32 0
  %9732 = insertelement <4 x float> %9731, float 0.000000e+00, i32 1
  %9733 = insertelement <4 x float> %9732, float 0.000000e+00, i32 2
  %9734 = insertelement <4 x float> %9733, float 0.000000e+00, i32 3
  %9735 = getelementptr inbounds float, float* %1, i64 6
  %9736 = load float, float* %9735, align 4
  %9737 = insertelement <4 x float> zeroinitializer, float %9736, i32 0
  %9738 = insertelement <4 x float> %9737, float 0.000000e+00, i32 1
  %9739 = insertelement <4 x float> %9738, float 0.000000e+00, i32 2
  %9740 = insertelement <4 x float> %9739, float 0.000000e+00, i32 3
  %9741 = call <4 x float> @llvm.fma.f32.241(<4 x float> %9734, <4 x float> %9740, <4 x float> %9726)
  %9742 = extractelement <4 x float> %9741, i32 0
  %9743 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9744 = getelementptr inbounds i8, i8* %9743, i64 8
  %9745 = bitcast i8* %9744 to float*
  store float %9742, float* %9745, align 4
  %9746 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9747 = getelementptr inbounds i8, i8* %9746, i64 8
  %9748 = bitcast i8* %9747 to float*
  %9749 = load float, float* %9748, align 4
  %9750 = insertelement <4 x float> zeroinitializer, float %9749, i32 0
  %9751 = insertelement <4 x float> %9750, float 0.000000e+00, i32 1
  %9752 = insertelement <4 x float> %9751, float 0.000000e+00, i32 2
  %9753 = insertelement <4 x float> %9752, float 0.000000e+00, i32 3
  %9754 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9755 = getelementptr inbounds i8, i8* %9754, i64 8
  %9756 = bitcast i8* %9755 to float*
  %9757 = load float, float* %9756, align 4
  %9758 = insertelement <4 x float> zeroinitializer, float %9757, i32 0
  %9759 = insertelement <4 x float> %9758, float 0.000000e+00, i32 1
  %9760 = insertelement <4 x float> %9759, float 0.000000e+00, i32 2
  %9761 = insertelement <4 x float> %9760, float 0.000000e+00, i32 3
  %9762 = getelementptr inbounds float, float* %1, i64 10
  %9763 = load float, float* %9762, align 4
  %9764 = insertelement <4 x float> zeroinitializer, float %9763, i32 0
  %9765 = insertelement <4 x float> %9764, float 0.000000e+00, i32 1
  %9766 = insertelement <4 x float> %9765, float 0.000000e+00, i32 2
  %9767 = insertelement <4 x float> %9766, float 0.000000e+00, i32 3
  %9768 = call <4 x float> @llvm.fma.f32.242(<4 x float> %9761, <4 x float> %9767, <4 x float> %9753)
  %9769 = extractelement <4 x float> %9768, i32 0
  %9770 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9771 = getelementptr inbounds i8, i8* %9770, i64 8
  %9772 = bitcast i8* %9771 to float*
  store float %9769, float* %9772, align 4
  %9773 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9774 = getelementptr inbounds i8, i8* %9773, i64 8
  %9775 = bitcast i8* %9774 to float*
  %9776 = load float, float* %9775, align 4
  %9777 = insertelement <4 x float> zeroinitializer, float %9776, i32 0
  %9778 = insertelement <4 x float> %9777, float 0.000000e+00, i32 1
  %9779 = insertelement <4 x float> %9778, float 0.000000e+00, i32 2
  %9780 = insertelement <4 x float> %9779, float 0.000000e+00, i32 3
  %9781 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9782 = getelementptr inbounds i8, i8* %9781, i64 12
  %9783 = bitcast i8* %9782 to float*
  %9784 = load float, float* %9783, align 4
  %9785 = insertelement <4 x float> zeroinitializer, float %9784, i32 0
  %9786 = insertelement <4 x float> %9785, float 0.000000e+00, i32 1
  %9787 = insertelement <4 x float> %9786, float 0.000000e+00, i32 2
  %9788 = insertelement <4 x float> %9787, float 0.000000e+00, i32 3
  %9789 = getelementptr inbounds float, float* %1, i64 14
  %9790 = load float, float* %9789, align 4
  %9791 = insertelement <4 x float> zeroinitializer, float %9790, i32 0
  %9792 = insertelement <4 x float> %9791, float 0.000000e+00, i32 1
  %9793 = insertelement <4 x float> %9792, float 0.000000e+00, i32 2
  %9794 = insertelement <4 x float> %9793, float 0.000000e+00, i32 3
  %9795 = call <4 x float> @llvm.fma.f32.243(<4 x float> %9788, <4 x float> %9794, <4 x float> %9780)
  %9796 = extractelement <4 x float> %9795, i32 0
  %9797 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9798 = getelementptr inbounds i8, i8* %9797, i64 8
  %9799 = bitcast i8* %9798 to float*
  store float %9796, float* %9799, align 4
  %9800 = extractelement <4 x float> %9795, i32 1
  %9801 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9802 = getelementptr inbounds i8, i8* %9801, i64 12
  %9803 = bitcast i8* %9802 to float*
  store float %9800, float* %9803, align 4
  %9804 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9805 = getelementptr inbounds i8, i8* %9804, i64 12
  %9806 = bitcast i8* %9805 to float*
  %9807 = load float, float* %9806, align 4
  %9808 = insertelement <4 x float> zeroinitializer, float %9807, i32 0
  %9809 = insertelement <4 x float> %9808, float 0.000000e+00, i32 1
  %9810 = insertelement <4 x float> %9809, float 0.000000e+00, i32 2
  %9811 = insertelement <4 x float> %9810, float 0.000000e+00, i32 3
  %9812 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9813 = bitcast i8* %9812 to float*
  %9814 = load float, float* %9813, align 4
  %9815 = insertelement <4 x float> zeroinitializer, float %9814, i32 0
  %9816 = insertelement <4 x float> %9815, float 0.000000e+00, i32 1
  %9817 = insertelement <4 x float> %9816, float 0.000000e+00, i32 2
  %9818 = insertelement <4 x float> %9817, float 0.000000e+00, i32 3
  %9819 = getelementptr inbounds float, float* %1, i64 3
  %9820 = load float, float* %9819, align 4
  %9821 = insertelement <4 x float> zeroinitializer, float %9820, i32 0
  %9822 = insertelement <4 x float> %9821, float 0.000000e+00, i32 1
  %9823 = insertelement <4 x float> %9822, float 0.000000e+00, i32 2
  %9824 = insertelement <4 x float> %9823, float 0.000000e+00, i32 3
  %9825 = call <4 x float> @llvm.fma.f32.244(<4 x float> %9818, <4 x float> %9824, <4 x float> %9811)
  %9826 = extractelement <4 x float> %9825, i32 0
  %9827 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9828 = getelementptr inbounds i8, i8* %9827, i64 12
  %9829 = bitcast i8* %9828 to float*
  store float %9826, float* %9829, align 4
  %9830 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9831 = getelementptr inbounds i8, i8* %9830, i64 12
  %9832 = bitcast i8* %9831 to float*
  %9833 = load float, float* %9832, align 4
  %9834 = insertelement <4 x float> zeroinitializer, float %9833, i32 0
  %9835 = insertelement <4 x float> %9834, float 0.000000e+00, i32 1
  %9836 = insertelement <4 x float> %9835, float 0.000000e+00, i32 2
  %9837 = insertelement <4 x float> %9836, float 0.000000e+00, i32 3
  %9838 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9839 = getelementptr inbounds i8, i8* %9838, i64 4
  %9840 = bitcast i8* %9839 to float*
  %9841 = load float, float* %9840, align 4
  %9842 = insertelement <4 x float> zeroinitializer, float %9841, i32 0
  %9843 = insertelement <4 x float> %9842, float 0.000000e+00, i32 1
  %9844 = insertelement <4 x float> %9843, float 0.000000e+00, i32 2
  %9845 = insertelement <4 x float> %9844, float 0.000000e+00, i32 3
  %9846 = getelementptr inbounds float, float* %1, i64 7
  %9847 = load float, float* %9846, align 4
  %9848 = insertelement <4 x float> zeroinitializer, float %9847, i32 0
  %9849 = insertelement <4 x float> %9848, float 0.000000e+00, i32 1
  %9850 = insertelement <4 x float> %9849, float 0.000000e+00, i32 2
  %9851 = insertelement <4 x float> %9850, float 0.000000e+00, i32 3
  %9852 = call <4 x float> @llvm.fma.f32.245(<4 x float> %9845, <4 x float> %9851, <4 x float> %9837)
  %9853 = extractelement <4 x float> %9852, i32 0
  %9854 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9855 = getelementptr inbounds i8, i8* %9854, i64 12
  %9856 = bitcast i8* %9855 to float*
  store float %9853, float* %9856, align 4
  %9857 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9858 = getelementptr inbounds i8, i8* %9857, i64 12
  %9859 = bitcast i8* %9858 to float*
  %9860 = load float, float* %9859, align 4
  %9861 = insertelement <4 x float> zeroinitializer, float %9860, i32 0
  %9862 = insertelement <4 x float> %9861, float 0.000000e+00, i32 1
  %9863 = insertelement <4 x float> %9862, float 0.000000e+00, i32 2
  %9864 = insertelement <4 x float> %9863, float 0.000000e+00, i32 3
  %9865 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9866 = getelementptr inbounds i8, i8* %9865, i64 8
  %9867 = bitcast i8* %9866 to float*
  %9868 = load float, float* %9867, align 4
  %9869 = insertelement <4 x float> zeroinitializer, float %9868, i32 0
  %9870 = insertelement <4 x float> %9869, float 0.000000e+00, i32 1
  %9871 = insertelement <4 x float> %9870, float 0.000000e+00, i32 2
  %9872 = insertelement <4 x float> %9871, float 0.000000e+00, i32 3
  %9873 = getelementptr inbounds float, float* %1, i64 11
  %9874 = load float, float* %9873, align 4
  %9875 = insertelement <4 x float> zeroinitializer, float %9874, i32 0
  %9876 = insertelement <4 x float> %9875, float 0.000000e+00, i32 1
  %9877 = insertelement <4 x float> %9876, float 0.000000e+00, i32 2
  %9878 = insertelement <4 x float> %9877, float 0.000000e+00, i32 3
  %9879 = call <4 x float> @llvm.fma.f32.246(<4 x float> %9872, <4 x float> %9878, <4 x float> %9864)
  %9880 = extractelement <4 x float> %9879, i32 0
  %9881 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9882 = getelementptr inbounds i8, i8* %9881, i64 12
  %9883 = bitcast i8* %9882 to float*
  store float %9880, float* %9883, align 4
  %9884 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9885 = getelementptr inbounds i8, i8* %9884, i64 12
  %9886 = bitcast i8* %9885 to float*
  %9887 = load float, float* %9886, align 4
  %9888 = insertelement <4 x float> zeroinitializer, float %9887, i32 0
  %9889 = insertelement <4 x float> %9888, float 0.000000e+00, i32 1
  %9890 = insertelement <4 x float> %9889, float 0.000000e+00, i32 2
  %9891 = insertelement <4 x float> %9890, float 0.000000e+00, i32 3
  %9892 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9893 = getelementptr inbounds i8, i8* %9892, i64 12
  %9894 = bitcast i8* %9893 to float*
  %9895 = load float, float* %9894, align 4
  %9896 = insertelement <4 x float> zeroinitializer, float %9895, i32 0
  %9897 = insertelement <4 x float> %9896, float 0.000000e+00, i32 1
  %9898 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9899 = getelementptr inbounds i8, i8* %9898, i64 16
  %9900 = bitcast i8* %9899 to float*
  %9901 = load float, float* %9900, align 4
  %9902 = insertelement <4 x float> %9897, float %9901, i32 2
  %9903 = insertelement <4 x float> %9902, float 0.000000e+00, i32 3
  %9904 = getelementptr inbounds float, float* %1, i64 15
  %9905 = load float, float* %9904, align 4
  %9906 = insertelement <4 x float> zeroinitializer, float %9905, i32 0
  %9907 = insertelement <4 x float> %9906, float 0.000000e+00, i32 1
  %9908 = load float, float* %1, align 4
  %9909 = insertelement <4 x float> %9907, float %9908, i32 2
  %9910 = insertelement <4 x float> %9909, float 0.000000e+00, i32 3
  %9911 = call <4 x float> @llvm.fma.f32.247(<4 x float> %9903, <4 x float> %9910, <4 x float> %9891)
  %9912 = extractelement <4 x float> %9911, i32 0
  %9913 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9914 = getelementptr inbounds i8, i8* %9913, i64 12
  %9915 = bitcast i8* %9914 to float*
  store float %9912, float* %9915, align 4
  %9916 = extractelement <4 x float> %9911, i32 1
  %9917 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9918 = getelementptr inbounds i8, i8* %9917, i64 16
  %9919 = bitcast i8* %9918 to float*
  store float %9916, float* %9919, align 4
  %9920 = extractelement <4 x float> %9911, i32 2
  %9921 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9922 = getelementptr inbounds i8, i8* %9921, i64 16
  %9923 = bitcast i8* %9922 to float*
  store float %9920, float* %9923, align 4
  %9924 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9925 = getelementptr inbounds i8, i8* %9924, i64 16
  %9926 = bitcast i8* %9925 to float*
  %9927 = load float, float* %9926, align 4
  %9928 = insertelement <4 x float> zeroinitializer, float %9927, i32 0
  %9929 = insertelement <4 x float> %9928, float 0.000000e+00, i32 1
  %9930 = insertelement <4 x float> %9929, float 0.000000e+00, i32 2
  %9931 = insertelement <4 x float> %9930, float 0.000000e+00, i32 3
  %9932 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9933 = getelementptr inbounds i8, i8* %9932, i64 20
  %9934 = bitcast i8* %9933 to float*
  %9935 = load float, float* %9934, align 4
  %9936 = insertelement <4 x float> zeroinitializer, float %9935, i32 0
  %9937 = insertelement <4 x float> %9936, float 0.000000e+00, i32 1
  %9938 = insertelement <4 x float> %9937, float 0.000000e+00, i32 2
  %9939 = insertelement <4 x float> %9938, float 0.000000e+00, i32 3
  %9940 = getelementptr inbounds float, float* %1, i64 4
  %9941 = load float, float* %9940, align 4
  %9942 = insertelement <4 x float> zeroinitializer, float %9941, i32 0
  %9943 = insertelement <4 x float> %9942, float 0.000000e+00, i32 1
  %9944 = insertelement <4 x float> %9943, float 0.000000e+00, i32 2
  %9945 = insertelement <4 x float> %9944, float 0.000000e+00, i32 3
  %9946 = call <4 x float> @llvm.fma.f32.248(<4 x float> %9939, <4 x float> %9945, <4 x float> %9931)
  %9947 = extractelement <4 x float> %9946, i32 0
  %9948 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9949 = getelementptr inbounds i8, i8* %9948, i64 16
  %9950 = bitcast i8* %9949 to float*
  store float %9947, float* %9950, align 4
  %9951 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9952 = getelementptr inbounds i8, i8* %9951, i64 16
  %9953 = bitcast i8* %9952 to float*
  %9954 = load float, float* %9953, align 4
  %9955 = insertelement <4 x float> zeroinitializer, float %9954, i32 0
  %9956 = insertelement <4 x float> %9955, float 0.000000e+00, i32 1
  %9957 = insertelement <4 x float> %9956, float 0.000000e+00, i32 2
  %9958 = insertelement <4 x float> %9957, float 0.000000e+00, i32 3
  %9959 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9960 = getelementptr inbounds i8, i8* %9959, i64 24
  %9961 = bitcast i8* %9960 to float*
  %9962 = load float, float* %9961, align 4
  %9963 = insertelement <4 x float> zeroinitializer, float %9962, i32 0
  %9964 = insertelement <4 x float> %9963, float 0.000000e+00, i32 1
  %9965 = insertelement <4 x float> %9964, float 0.000000e+00, i32 2
  %9966 = insertelement <4 x float> %9965, float 0.000000e+00, i32 3
  %9967 = getelementptr inbounds float, float* %1, i64 8
  %9968 = load float, float* %9967, align 4
  %9969 = insertelement <4 x float> zeroinitializer, float %9968, i32 0
  %9970 = insertelement <4 x float> %9969, float 0.000000e+00, i32 1
  %9971 = insertelement <4 x float> %9970, float 0.000000e+00, i32 2
  %9972 = insertelement <4 x float> %9971, float 0.000000e+00, i32 3
  %9973 = call <4 x float> @llvm.fma.f32.249(<4 x float> %9966, <4 x float> %9972, <4 x float> %9958)
  %9974 = extractelement <4 x float> %9973, i32 0
  %9975 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9976 = getelementptr inbounds i8, i8* %9975, i64 16
  %9977 = bitcast i8* %9976 to float*
  store float %9974, float* %9977, align 4
  %9978 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9979 = getelementptr inbounds i8, i8* %9978, i64 16
  %9980 = bitcast i8* %9979 to float*
  %9981 = load float, float* %9980, align 4
  %9982 = insertelement <4 x float> zeroinitializer, float %9981, i32 0
  %9983 = insertelement <4 x float> %9982, float 0.000000e+00, i32 1
  %9984 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9985 = getelementptr inbounds i8, i8* %9984, i64 20
  %9986 = bitcast i8* %9985 to float*
  %9987 = load float, float* %9986, align 4
  %9988 = insertelement <4 x float> %9983, float %9987, i32 2
  %9989 = insertelement <4 x float> %9988, float 0.000000e+00, i32 3
  %9990 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9991 = getelementptr inbounds i8, i8* %9990, i64 28
  %9992 = bitcast i8* %9991 to float*
  %9993 = load float, float* %9992, align 4
  %9994 = insertelement <4 x float> zeroinitializer, float %9993, i32 0
  %9995 = insertelement <4 x float> %9994, float 0.000000e+00, i32 1
  %9996 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %9997 = getelementptr inbounds i8, i8* %9996, i64 16
  %9998 = bitcast i8* %9997 to float*
  %9999 = load float, float* %9998, align 4
  %10000 = insertelement <4 x float> %9995, float %9999, i32 2
  %10001 = insertelement <4 x float> %10000, float 0.000000e+00, i32 3
  %10002 = getelementptr inbounds float, float* %1, i64 12
  %10003 = load float, float* %10002, align 4
  %10004 = insertelement <4 x float> zeroinitializer, float %10003, i32 0
  %10005 = insertelement <4 x float> %10004, float 0.000000e+00, i32 1
  %10006 = getelementptr inbounds float, float* %1, i64 1
  %10007 = load float, float* %10006, align 4
  %10008 = insertelement <4 x float> %10005, float %10007, i32 2
  %10009 = insertelement <4 x float> %10008, float 0.000000e+00, i32 3
  %10010 = call <4 x float> @llvm.fma.f32.250(<4 x float> %10001, <4 x float> %10009, <4 x float> %9989)
  %10011 = extractelement <4 x float> %10010, i32 0
  %10012 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10013 = getelementptr inbounds i8, i8* %10012, i64 16
  %10014 = bitcast i8* %10013 to float*
  store float %10011, float* %10014, align 4
  %10015 = extractelement <4 x float> %10010, i32 1
  %10016 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10017 = getelementptr inbounds i8, i8* %10016, i64 20
  %10018 = bitcast i8* %10017 to float*
  store float %10015, float* %10018, align 4
  %10019 = extractelement <4 x float> %10010, i32 2
  %10020 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10021 = getelementptr inbounds i8, i8* %10020, i64 20
  %10022 = bitcast i8* %10021 to float*
  store float %10019, float* %10022, align 4
  %10023 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10024 = getelementptr inbounds i8, i8* %10023, i64 20
  %10025 = bitcast i8* %10024 to float*
  %10026 = load float, float* %10025, align 4
  %10027 = insertelement <4 x float> zeroinitializer, float %10026, i32 0
  %10028 = insertelement <4 x float> %10027, float 0.000000e+00, i32 1
  %10029 = insertelement <4 x float> %10028, float 0.000000e+00, i32 2
  %10030 = insertelement <4 x float> %10029, float 0.000000e+00, i32 3
  %10031 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10032 = getelementptr inbounds i8, i8* %10031, i64 20
  %10033 = bitcast i8* %10032 to float*
  %10034 = load float, float* %10033, align 4
  %10035 = insertelement <4 x float> zeroinitializer, float %10034, i32 0
  %10036 = insertelement <4 x float> %10035, float 0.000000e+00, i32 1
  %10037 = insertelement <4 x float> %10036, float 0.000000e+00, i32 2
  %10038 = insertelement <4 x float> %10037, float 0.000000e+00, i32 3
  %10039 = getelementptr inbounds float, float* %1, i64 5
  %10040 = load float, float* %10039, align 4
  %10041 = insertelement <4 x float> zeroinitializer, float %10040, i32 0
  %10042 = insertelement <4 x float> %10041, float 0.000000e+00, i32 1
  %10043 = insertelement <4 x float> %10042, float 0.000000e+00, i32 2
  %10044 = insertelement <4 x float> %10043, float 0.000000e+00, i32 3
  %10045 = call <4 x float> @llvm.fma.f32.251(<4 x float> %10038, <4 x float> %10044, <4 x float> %10030)
  %10046 = extractelement <4 x float> %10045, i32 0
  %10047 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10048 = getelementptr inbounds i8, i8* %10047, i64 20
  %10049 = bitcast i8* %10048 to float*
  store float %10046, float* %10049, align 4
  %10050 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10051 = getelementptr inbounds i8, i8* %10050, i64 20
  %10052 = bitcast i8* %10051 to float*
  %10053 = load float, float* %10052, align 4
  %10054 = insertelement <4 x float> zeroinitializer, float %10053, i32 0
  %10055 = insertelement <4 x float> %10054, float 0.000000e+00, i32 1
  %10056 = insertelement <4 x float> %10055, float 0.000000e+00, i32 2
  %10057 = insertelement <4 x float> %10056, float 0.000000e+00, i32 3
  %10058 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10059 = getelementptr inbounds i8, i8* %10058, i64 24
  %10060 = bitcast i8* %10059 to float*
  %10061 = load float, float* %10060, align 4
  %10062 = insertelement <4 x float> zeroinitializer, float %10061, i32 0
  %10063 = insertelement <4 x float> %10062, float 0.000000e+00, i32 1
  %10064 = insertelement <4 x float> %10063, float 0.000000e+00, i32 2
  %10065 = insertelement <4 x float> %10064, float 0.000000e+00, i32 3
  %10066 = getelementptr inbounds float, float* %1, i64 9
  %10067 = load float, float* %10066, align 4
  %10068 = insertelement <4 x float> zeroinitializer, float %10067, i32 0
  %10069 = insertelement <4 x float> %10068, float 0.000000e+00, i32 1
  %10070 = insertelement <4 x float> %10069, float 0.000000e+00, i32 2
  %10071 = insertelement <4 x float> %10070, float 0.000000e+00, i32 3
  %10072 = call <4 x float> @llvm.fma.f32.252(<4 x float> %10065, <4 x float> %10071, <4 x float> %10057)
  %10073 = extractelement <4 x float> %10072, i32 0
  %10074 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10075 = getelementptr inbounds i8, i8* %10074, i64 20
  %10076 = bitcast i8* %10075 to float*
  store float %10073, float* %10076, align 4
  %10077 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10078 = getelementptr inbounds i8, i8* %10077, i64 20
  %10079 = bitcast i8* %10078 to float*
  %10080 = load float, float* %10079, align 4
  %10081 = insertelement <4 x float> zeroinitializer, float %10080, i32 0
  %10082 = insertelement <4 x float> %10081, float 0.000000e+00, i32 1
  %10083 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10084 = getelementptr inbounds i8, i8* %10083, i64 24
  %10085 = bitcast i8* %10084 to float*
  %10086 = load float, float* %10085, align 4
  %10087 = insertelement <4 x float> %10082, float %10086, i32 2
  %10088 = insertelement <4 x float> %10087, float 0.000000e+00, i32 3
  %10089 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10090 = getelementptr inbounds i8, i8* %10089, i64 28
  %10091 = bitcast i8* %10090 to float*
  %10092 = load float, float* %10091, align 4
  %10093 = insertelement <4 x float> zeroinitializer, float %10092, i32 0
  %10094 = insertelement <4 x float> %10093, float 0.000000e+00, i32 1
  %10095 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10096 = getelementptr inbounds i8, i8* %10095, i64 16
  %10097 = bitcast i8* %10096 to float*
  %10098 = load float, float* %10097, align 4
  %10099 = insertelement <4 x float> %10094, float %10098, i32 2
  %10100 = insertelement <4 x float> %10099, float 0.000000e+00, i32 3
  %10101 = getelementptr inbounds float, float* %1, i64 13
  %10102 = load float, float* %10101, align 4
  %10103 = insertelement <4 x float> zeroinitializer, float %10102, i32 0
  %10104 = insertelement <4 x float> %10103, float 0.000000e+00, i32 1
  %10105 = getelementptr inbounds float, float* %1, i64 2
  %10106 = load float, float* %10105, align 4
  %10107 = insertelement <4 x float> %10104, float %10106, i32 2
  %10108 = insertelement <4 x float> %10107, float 0.000000e+00, i32 3
  %10109 = call <4 x float> @llvm.fma.f32.253(<4 x float> %10100, <4 x float> %10108, <4 x float> %10088)
  %10110 = extractelement <4 x float> %10109, i32 0
  %10111 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10112 = getelementptr inbounds i8, i8* %10111, i64 20
  %10113 = bitcast i8* %10112 to float*
  store float %10110, float* %10113, align 4
  %10114 = extractelement <4 x float> %10109, i32 1
  %10115 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10116 = getelementptr inbounds i8, i8* %10115, i64 24
  %10117 = bitcast i8* %10116 to float*
  store float %10114, float* %10117, align 4
  %10118 = extractelement <4 x float> %10109, i32 2
  %10119 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10120 = getelementptr inbounds i8, i8* %10119, i64 24
  %10121 = bitcast i8* %10120 to float*
  store float %10118, float* %10121, align 4
  %10122 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10123 = getelementptr inbounds i8, i8* %10122, i64 24
  %10124 = bitcast i8* %10123 to float*
  %10125 = load float, float* %10124, align 4
  %10126 = insertelement <4 x float> zeroinitializer, float %10125, i32 0
  %10127 = insertelement <4 x float> %10126, float 0.000000e+00, i32 1
  %10128 = insertelement <4 x float> %10127, float 0.000000e+00, i32 2
  %10129 = insertelement <4 x float> %10128, float 0.000000e+00, i32 3
  %10130 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10131 = getelementptr inbounds i8, i8* %10130, i64 20
  %10132 = bitcast i8* %10131 to float*
  %10133 = load float, float* %10132, align 4
  %10134 = insertelement <4 x float> zeroinitializer, float %10133, i32 0
  %10135 = insertelement <4 x float> %10134, float 0.000000e+00, i32 1
  %10136 = insertelement <4 x float> %10135, float 0.000000e+00, i32 2
  %10137 = insertelement <4 x float> %10136, float 0.000000e+00, i32 3
  %10138 = getelementptr inbounds float, float* %1, i64 6
  %10139 = load float, float* %10138, align 4
  %10140 = insertelement <4 x float> zeroinitializer, float %10139, i32 0
  %10141 = insertelement <4 x float> %10140, float 0.000000e+00, i32 1
  %10142 = insertelement <4 x float> %10141, float 0.000000e+00, i32 2
  %10143 = insertelement <4 x float> %10142, float 0.000000e+00, i32 3
  %10144 = call <4 x float> @llvm.fma.f32.254(<4 x float> %10137, <4 x float> %10143, <4 x float> %10129)
  %10145 = extractelement <4 x float> %10144, i32 0
  %10146 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10147 = getelementptr inbounds i8, i8* %10146, i64 24
  %10148 = bitcast i8* %10147 to float*
  store float %10145, float* %10148, align 4
  %10149 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10150 = getelementptr inbounds i8, i8* %10149, i64 24
  %10151 = bitcast i8* %10150 to float*
  %10152 = load float, float* %10151, align 4
  %10153 = insertelement <4 x float> zeroinitializer, float %10152, i32 0
  %10154 = insertelement <4 x float> %10153, float 0.000000e+00, i32 1
  %10155 = insertelement <4 x float> %10154, float 0.000000e+00, i32 2
  %10156 = insertelement <4 x float> %10155, float 0.000000e+00, i32 3
  %10157 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10158 = getelementptr inbounds i8, i8* %10157, i64 24
  %10159 = bitcast i8* %10158 to float*
  %10160 = load float, float* %10159, align 4
  %10161 = insertelement <4 x float> zeroinitializer, float %10160, i32 0
  %10162 = insertelement <4 x float> %10161, float 0.000000e+00, i32 1
  %10163 = insertelement <4 x float> %10162, float 0.000000e+00, i32 2
  %10164 = insertelement <4 x float> %10163, float 0.000000e+00, i32 3
  %10165 = getelementptr inbounds float, float* %1, i64 10
  %10166 = load float, float* %10165, align 4
  %10167 = insertelement <4 x float> zeroinitializer, float %10166, i32 0
  %10168 = insertelement <4 x float> %10167, float 0.000000e+00, i32 1
  %10169 = insertelement <4 x float> %10168, float 0.000000e+00, i32 2
  %10170 = insertelement <4 x float> %10169, float 0.000000e+00, i32 3
  %10171 = call <4 x float> @llvm.fma.f32.255(<4 x float> %10164, <4 x float> %10170, <4 x float> %10156)
  %10172 = extractelement <4 x float> %10171, i32 0
  %10173 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10174 = getelementptr inbounds i8, i8* %10173, i64 24
  %10175 = bitcast i8* %10174 to float*
  store float %10172, float* %10175, align 4
  %10176 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10177 = getelementptr inbounds i8, i8* %10176, i64 24
  %10178 = bitcast i8* %10177 to float*
  %10179 = load float, float* %10178, align 4
  %10180 = insertelement <4 x float> zeroinitializer, float %10179, i32 0
  %10181 = insertelement <4 x float> %10180, float 0.000000e+00, i32 1
  %10182 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10183 = getelementptr inbounds i8, i8* %10182, i64 28
  %10184 = bitcast i8* %10183 to float*
  %10185 = load float, float* %10184, align 4
  %10186 = insertelement <4 x float> %10181, float %10185, i32 2
  %10187 = insertelement <4 x float> %10186, float 0.000000e+00, i32 3
  %10188 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10189 = getelementptr inbounds i8, i8* %10188, i64 28
  %10190 = bitcast i8* %10189 to float*
  %10191 = load float, float* %10190, align 4
  %10192 = insertelement <4 x float> zeroinitializer, float %10191, i32 0
  %10193 = insertelement <4 x float> %10192, float 0.000000e+00, i32 1
  %10194 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10195 = getelementptr inbounds i8, i8* %10194, i64 16
  %10196 = bitcast i8* %10195 to float*
  %10197 = load float, float* %10196, align 4
  %10198 = insertelement <4 x float> %10193, float %10197, i32 2
  %10199 = insertelement <4 x float> %10198, float 0.000000e+00, i32 3
  %10200 = getelementptr inbounds float, float* %1, i64 14
  %10201 = load float, float* %10200, align 4
  %10202 = insertelement <4 x float> zeroinitializer, float %10201, i32 0
  %10203 = insertelement <4 x float> %10202, float 0.000000e+00, i32 1
  %10204 = getelementptr inbounds float, float* %1, i64 3
  %10205 = load float, float* %10204, align 4
  %10206 = insertelement <4 x float> %10203, float %10205, i32 2
  %10207 = insertelement <4 x float> %10206, float 0.000000e+00, i32 3
  %10208 = call <4 x float> @llvm.fma.f32.256(<4 x float> %10199, <4 x float> %10207, <4 x float> %10187)
  %10209 = extractelement <4 x float> %10208, i32 0
  %10210 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10211 = getelementptr inbounds i8, i8* %10210, i64 24
  %10212 = bitcast i8* %10211 to float*
  store float %10209, float* %10212, align 4
  %10213 = extractelement <4 x float> %10208, i32 1
  %10214 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10215 = getelementptr inbounds i8, i8* %10214, i64 28
  %10216 = bitcast i8* %10215 to float*
  store float %10213, float* %10216, align 4
  %10217 = extractelement <4 x float> %10208, i32 2
  %10218 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10219 = getelementptr inbounds i8, i8* %10218, i64 28
  %10220 = bitcast i8* %10219 to float*
  store float %10217, float* %10220, align 4
  %10221 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10222 = getelementptr inbounds i8, i8* %10221, i64 28
  %10223 = bitcast i8* %10222 to float*
  %10224 = load float, float* %10223, align 4
  %10225 = insertelement <4 x float> zeroinitializer, float %10224, i32 0
  %10226 = insertelement <4 x float> %10225, float 0.000000e+00, i32 1
  %10227 = insertelement <4 x float> %10226, float 0.000000e+00, i32 2
  %10228 = insertelement <4 x float> %10227, float 0.000000e+00, i32 3
  %10229 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10230 = getelementptr inbounds i8, i8* %10229, i64 20
  %10231 = bitcast i8* %10230 to float*
  %10232 = load float, float* %10231, align 4
  %10233 = insertelement <4 x float> zeroinitializer, float %10232, i32 0
  %10234 = insertelement <4 x float> %10233, float 0.000000e+00, i32 1
  %10235 = insertelement <4 x float> %10234, float 0.000000e+00, i32 2
  %10236 = insertelement <4 x float> %10235, float 0.000000e+00, i32 3
  %10237 = getelementptr inbounds float, float* %1, i64 7
  %10238 = load float, float* %10237, align 4
  %10239 = insertelement <4 x float> zeroinitializer, float %10238, i32 0
  %10240 = insertelement <4 x float> %10239, float 0.000000e+00, i32 1
  %10241 = insertelement <4 x float> %10240, float 0.000000e+00, i32 2
  %10242 = insertelement <4 x float> %10241, float 0.000000e+00, i32 3
  %10243 = call <4 x float> @llvm.fma.f32.257(<4 x float> %10236, <4 x float> %10242, <4 x float> %10228)
  %10244 = extractelement <4 x float> %10243, i32 0
  %10245 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10246 = getelementptr inbounds i8, i8* %10245, i64 28
  %10247 = bitcast i8* %10246 to float*
  store float %10244, float* %10247, align 4
  %10248 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10249 = getelementptr inbounds i8, i8* %10248, i64 28
  %10250 = bitcast i8* %10249 to float*
  %10251 = load float, float* %10250, align 4
  %10252 = insertelement <4 x float> zeroinitializer, float %10251, i32 0
  %10253 = insertelement <4 x float> %10252, float 0.000000e+00, i32 1
  %10254 = insertelement <4 x float> %10253, float 0.000000e+00, i32 2
  %10255 = insertelement <4 x float> %10254, float 0.000000e+00, i32 3
  %10256 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10257 = getelementptr inbounds i8, i8* %10256, i64 24
  %10258 = bitcast i8* %10257 to float*
  %10259 = load float, float* %10258, align 4
  %10260 = insertelement <4 x float> zeroinitializer, float %10259, i32 0
  %10261 = insertelement <4 x float> %10260, float 0.000000e+00, i32 1
  %10262 = insertelement <4 x float> %10261, float 0.000000e+00, i32 2
  %10263 = insertelement <4 x float> %10262, float 0.000000e+00, i32 3
  %10264 = getelementptr inbounds float, float* %1, i64 11
  %10265 = load float, float* %10264, align 4
  %10266 = insertelement <4 x float> zeroinitializer, float %10265, i32 0
  %10267 = insertelement <4 x float> %10266, float 0.000000e+00, i32 1
  %10268 = insertelement <4 x float> %10267, float 0.000000e+00, i32 2
  %10269 = insertelement <4 x float> %10268, float 0.000000e+00, i32 3
  %10270 = call <4 x float> @llvm.fma.f32.258(<4 x float> %10263, <4 x float> %10269, <4 x float> %10255)
  %10271 = extractelement <4 x float> %10270, i32 0
  %10272 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10273 = getelementptr inbounds i8, i8* %10272, i64 28
  %10274 = bitcast i8* %10273 to float*
  store float %10271, float* %10274, align 4
  %10275 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10276 = getelementptr inbounds i8, i8* %10275, i64 28
  %10277 = bitcast i8* %10276 to float*
  %10278 = load float, float* %10277, align 4
  %10279 = insertelement <4 x float> zeroinitializer, float %10278, i32 0
  %10280 = insertelement <4 x float> %10279, float 0.000000e+00, i32 1
  %10281 = insertelement <4 x float> %10280, float 0.000000e+00, i32 2
  %10282 = insertelement <4 x float> %10281, float 0.000000e+00, i32 3
  %10283 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10284 = getelementptr inbounds i8, i8* %10283, i64 28
  %10285 = bitcast i8* %10284 to float*
  %10286 = load float, float* %10285, align 4
  %10287 = insertelement <4 x float> zeroinitializer, float %10286, i32 0
  %10288 = insertelement <4 x float> %10287, float 0.000000e+00, i32 1
  %10289 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10290 = getelementptr inbounds i8, i8* %10289, i64 32
  %10291 = bitcast i8* %10290 to float*
  %10292 = load float, float* %10291, align 4
  %10293 = insertelement <4 x float> %10288, float %10292, i32 2
  %10294 = insertelement <4 x float> %10293, float 0.000000e+00, i32 3
  %10295 = getelementptr inbounds float, float* %1, i64 15
  %10296 = load float, float* %10295, align 4
  %10297 = insertelement <4 x float> zeroinitializer, float %10296, i32 0
  %10298 = insertelement <4 x float> %10297, float 0.000000e+00, i32 1
  %10299 = load float, float* %1, align 4
  %10300 = insertelement <4 x float> %10298, float %10299, i32 2
  %10301 = insertelement <4 x float> %10300, float 0.000000e+00, i32 3
  %10302 = call <4 x float> @llvm.fma.f32.259(<4 x float> %10294, <4 x float> %10301, <4 x float> %10282)
  %10303 = extractelement <4 x float> %10302, i32 0
  %10304 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10305 = getelementptr inbounds i8, i8* %10304, i64 28
  %10306 = bitcast i8* %10305 to float*
  store float %10303, float* %10306, align 4
  %10307 = extractelement <4 x float> %10302, i32 1
  %10308 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10309 = getelementptr inbounds i8, i8* %10308, i64 32
  %10310 = bitcast i8* %10309 to float*
  store float %10307, float* %10310, align 4
  %10311 = extractelement <4 x float> %10302, i32 2
  %10312 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10313 = getelementptr inbounds i8, i8* %10312, i64 32
  %10314 = bitcast i8* %10313 to float*
  store float %10311, float* %10314, align 4
  %10315 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10316 = getelementptr inbounds i8, i8* %10315, i64 32
  %10317 = bitcast i8* %10316 to float*
  %10318 = load float, float* %10317, align 4
  %10319 = insertelement <4 x float> zeroinitializer, float %10318, i32 0
  %10320 = insertelement <4 x float> %10319, float 0.000000e+00, i32 1
  %10321 = insertelement <4 x float> %10320, float 0.000000e+00, i32 2
  %10322 = insertelement <4 x float> %10321, float 0.000000e+00, i32 3
  %10323 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10324 = getelementptr inbounds i8, i8* %10323, i64 36
  %10325 = bitcast i8* %10324 to float*
  %10326 = load float, float* %10325, align 4
  %10327 = insertelement <4 x float> zeroinitializer, float %10326, i32 0
  %10328 = insertelement <4 x float> %10327, float 0.000000e+00, i32 1
  %10329 = insertelement <4 x float> %10328, float 0.000000e+00, i32 2
  %10330 = insertelement <4 x float> %10329, float 0.000000e+00, i32 3
  %10331 = getelementptr inbounds float, float* %1, i64 4
  %10332 = load float, float* %10331, align 4
  %10333 = insertelement <4 x float> zeroinitializer, float %10332, i32 0
  %10334 = insertelement <4 x float> %10333, float 0.000000e+00, i32 1
  %10335 = insertelement <4 x float> %10334, float 0.000000e+00, i32 2
  %10336 = insertelement <4 x float> %10335, float 0.000000e+00, i32 3
  %10337 = call <4 x float> @llvm.fma.f32.260(<4 x float> %10330, <4 x float> %10336, <4 x float> %10322)
  %10338 = extractelement <4 x float> %10337, i32 0
  %10339 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10340 = getelementptr inbounds i8, i8* %10339, i64 32
  %10341 = bitcast i8* %10340 to float*
  store float %10338, float* %10341, align 4
  %10342 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10343 = getelementptr inbounds i8, i8* %10342, i64 32
  %10344 = bitcast i8* %10343 to float*
  %10345 = load float, float* %10344, align 4
  %10346 = insertelement <4 x float> zeroinitializer, float %10345, i32 0
  %10347 = insertelement <4 x float> %10346, float 0.000000e+00, i32 1
  %10348 = insertelement <4 x float> %10347, float 0.000000e+00, i32 2
  %10349 = insertelement <4 x float> %10348, float 0.000000e+00, i32 3
  %10350 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10351 = getelementptr inbounds i8, i8* %10350, i64 40
  %10352 = bitcast i8* %10351 to float*
  %10353 = load float, float* %10352, align 4
  %10354 = insertelement <4 x float> zeroinitializer, float %10353, i32 0
  %10355 = insertelement <4 x float> %10354, float 0.000000e+00, i32 1
  %10356 = insertelement <4 x float> %10355, float 0.000000e+00, i32 2
  %10357 = insertelement <4 x float> %10356, float 0.000000e+00, i32 3
  %10358 = getelementptr inbounds float, float* %1, i64 8
  %10359 = load float, float* %10358, align 4
  %10360 = insertelement <4 x float> zeroinitializer, float %10359, i32 0
  %10361 = insertelement <4 x float> %10360, float 0.000000e+00, i32 1
  %10362 = insertelement <4 x float> %10361, float 0.000000e+00, i32 2
  %10363 = insertelement <4 x float> %10362, float 0.000000e+00, i32 3
  %10364 = call <4 x float> @llvm.fma.f32.261(<4 x float> %10357, <4 x float> %10363, <4 x float> %10349)
  %10365 = extractelement <4 x float> %10364, i32 0
  %10366 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10367 = getelementptr inbounds i8, i8* %10366, i64 32
  %10368 = bitcast i8* %10367 to float*
  store float %10365, float* %10368, align 4
  %10369 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10370 = getelementptr inbounds i8, i8* %10369, i64 32
  %10371 = bitcast i8* %10370 to float*
  %10372 = load float, float* %10371, align 4
  %10373 = insertelement <4 x float> zeroinitializer, float %10372, i32 0
  %10374 = insertelement <4 x float> %10373, float 0.000000e+00, i32 1
  %10375 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10376 = getelementptr inbounds i8, i8* %10375, i64 36
  %10377 = bitcast i8* %10376 to float*
  %10378 = load float, float* %10377, align 4
  %10379 = insertelement <4 x float> %10374, float %10378, i32 2
  %10380 = insertelement <4 x float> %10379, float 0.000000e+00, i32 3
  %10381 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10382 = getelementptr inbounds i8, i8* %10381, i64 44
  %10383 = bitcast i8* %10382 to float*
  %10384 = load float, float* %10383, align 4
  %10385 = insertelement <4 x float> zeroinitializer, float %10384, i32 0
  %10386 = insertelement <4 x float> %10385, float 0.000000e+00, i32 1
  %10387 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10388 = getelementptr inbounds i8, i8* %10387, i64 32
  %10389 = bitcast i8* %10388 to float*
  %10390 = load float, float* %10389, align 4
  %10391 = insertelement <4 x float> %10386, float %10390, i32 2
  %10392 = insertelement <4 x float> %10391, float 0.000000e+00, i32 3
  %10393 = getelementptr inbounds float, float* %1, i64 12
  %10394 = load float, float* %10393, align 4
  %10395 = insertelement <4 x float> zeroinitializer, float %10394, i32 0
  %10396 = insertelement <4 x float> %10395, float 0.000000e+00, i32 1
  %10397 = getelementptr inbounds float, float* %1, i64 1
  %10398 = load float, float* %10397, align 4
  %10399 = insertelement <4 x float> %10396, float %10398, i32 2
  %10400 = insertelement <4 x float> %10399, float 0.000000e+00, i32 3
  %10401 = call <4 x float> @llvm.fma.f32.262(<4 x float> %10392, <4 x float> %10400, <4 x float> %10380)
  %10402 = extractelement <4 x float> %10401, i32 0
  %10403 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10404 = getelementptr inbounds i8, i8* %10403, i64 32
  %10405 = bitcast i8* %10404 to float*
  store float %10402, float* %10405, align 4
  %10406 = extractelement <4 x float> %10401, i32 1
  %10407 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10408 = getelementptr inbounds i8, i8* %10407, i64 36
  %10409 = bitcast i8* %10408 to float*
  store float %10406, float* %10409, align 4
  %10410 = extractelement <4 x float> %10401, i32 2
  %10411 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10412 = getelementptr inbounds i8, i8* %10411, i64 36
  %10413 = bitcast i8* %10412 to float*
  store float %10410, float* %10413, align 4
  %10414 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10415 = getelementptr inbounds i8, i8* %10414, i64 36
  %10416 = bitcast i8* %10415 to float*
  %10417 = load float, float* %10416, align 4
  %10418 = insertelement <4 x float> zeroinitializer, float %10417, i32 0
  %10419 = insertelement <4 x float> %10418, float 0.000000e+00, i32 1
  %10420 = insertelement <4 x float> %10419, float 0.000000e+00, i32 2
  %10421 = insertelement <4 x float> %10420, float 0.000000e+00, i32 3
  %10422 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10423 = getelementptr inbounds i8, i8* %10422, i64 36
  %10424 = bitcast i8* %10423 to float*
  %10425 = load float, float* %10424, align 4
  %10426 = insertelement <4 x float> zeroinitializer, float %10425, i32 0
  %10427 = insertelement <4 x float> %10426, float 0.000000e+00, i32 1
  %10428 = insertelement <4 x float> %10427, float 0.000000e+00, i32 2
  %10429 = insertelement <4 x float> %10428, float 0.000000e+00, i32 3
  %10430 = getelementptr inbounds float, float* %1, i64 5
  %10431 = load float, float* %10430, align 4
  %10432 = insertelement <4 x float> zeroinitializer, float %10431, i32 0
  %10433 = insertelement <4 x float> %10432, float 0.000000e+00, i32 1
  %10434 = insertelement <4 x float> %10433, float 0.000000e+00, i32 2
  %10435 = insertelement <4 x float> %10434, float 0.000000e+00, i32 3
  %10436 = call <4 x float> @llvm.fma.f32.263(<4 x float> %10429, <4 x float> %10435, <4 x float> %10421)
  %10437 = extractelement <4 x float> %10436, i32 0
  %10438 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10439 = getelementptr inbounds i8, i8* %10438, i64 36
  %10440 = bitcast i8* %10439 to float*
  store float %10437, float* %10440, align 4
  %10441 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10442 = getelementptr inbounds i8, i8* %10441, i64 36
  %10443 = bitcast i8* %10442 to float*
  %10444 = load float, float* %10443, align 4
  %10445 = insertelement <4 x float> zeroinitializer, float %10444, i32 0
  %10446 = insertelement <4 x float> %10445, float 0.000000e+00, i32 1
  %10447 = insertelement <4 x float> %10446, float 0.000000e+00, i32 2
  %10448 = insertelement <4 x float> %10447, float 0.000000e+00, i32 3
  %10449 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10450 = getelementptr inbounds i8, i8* %10449, i64 40
  %10451 = bitcast i8* %10450 to float*
  %10452 = load float, float* %10451, align 4
  %10453 = insertelement <4 x float> zeroinitializer, float %10452, i32 0
  %10454 = insertelement <4 x float> %10453, float 0.000000e+00, i32 1
  %10455 = insertelement <4 x float> %10454, float 0.000000e+00, i32 2
  %10456 = insertelement <4 x float> %10455, float 0.000000e+00, i32 3
  %10457 = getelementptr inbounds float, float* %1, i64 9
  %10458 = load float, float* %10457, align 4
  %10459 = insertelement <4 x float> zeroinitializer, float %10458, i32 0
  %10460 = insertelement <4 x float> %10459, float 0.000000e+00, i32 1
  %10461 = insertelement <4 x float> %10460, float 0.000000e+00, i32 2
  %10462 = insertelement <4 x float> %10461, float 0.000000e+00, i32 3
  %10463 = call <4 x float> @llvm.fma.f32.264(<4 x float> %10456, <4 x float> %10462, <4 x float> %10448)
  %10464 = extractelement <4 x float> %10463, i32 0
  %10465 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10466 = getelementptr inbounds i8, i8* %10465, i64 36
  %10467 = bitcast i8* %10466 to float*
  store float %10464, float* %10467, align 4
  %10468 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10469 = getelementptr inbounds i8, i8* %10468, i64 36
  %10470 = bitcast i8* %10469 to float*
  %10471 = load float, float* %10470, align 4
  %10472 = insertelement <4 x float> zeroinitializer, float %10471, i32 0
  %10473 = insertelement <4 x float> %10472, float 0.000000e+00, i32 1
  %10474 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10475 = getelementptr inbounds i8, i8* %10474, i64 40
  %10476 = bitcast i8* %10475 to float*
  %10477 = load float, float* %10476, align 4
  %10478 = insertelement <4 x float> %10473, float %10477, i32 2
  %10479 = insertelement <4 x float> %10478, float 0.000000e+00, i32 3
  %10480 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10481 = getelementptr inbounds i8, i8* %10480, i64 44
  %10482 = bitcast i8* %10481 to float*
  %10483 = load float, float* %10482, align 4
  %10484 = insertelement <4 x float> zeroinitializer, float %10483, i32 0
  %10485 = insertelement <4 x float> %10484, float 0.000000e+00, i32 1
  %10486 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10487 = getelementptr inbounds i8, i8* %10486, i64 32
  %10488 = bitcast i8* %10487 to float*
  %10489 = load float, float* %10488, align 4
  %10490 = insertelement <4 x float> %10485, float %10489, i32 2
  %10491 = insertelement <4 x float> %10490, float 0.000000e+00, i32 3
  %10492 = getelementptr inbounds float, float* %1, i64 13
  %10493 = load float, float* %10492, align 4
  %10494 = insertelement <4 x float> zeroinitializer, float %10493, i32 0
  %10495 = insertelement <4 x float> %10494, float 0.000000e+00, i32 1
  %10496 = getelementptr inbounds float, float* %1, i64 2
  %10497 = load float, float* %10496, align 4
  %10498 = insertelement <4 x float> %10495, float %10497, i32 2
  %10499 = insertelement <4 x float> %10498, float 0.000000e+00, i32 3
  %10500 = call <4 x float> @llvm.fma.f32.265(<4 x float> %10491, <4 x float> %10499, <4 x float> %10479)
  %10501 = extractelement <4 x float> %10500, i32 0
  %10502 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10503 = getelementptr inbounds i8, i8* %10502, i64 36
  %10504 = bitcast i8* %10503 to float*
  store float %10501, float* %10504, align 4
  %10505 = extractelement <4 x float> %10500, i32 1
  %10506 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10507 = getelementptr inbounds i8, i8* %10506, i64 40
  %10508 = bitcast i8* %10507 to float*
  store float %10505, float* %10508, align 4
  %10509 = extractelement <4 x float> %10500, i32 2
  %10510 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10511 = getelementptr inbounds i8, i8* %10510, i64 40
  %10512 = bitcast i8* %10511 to float*
  store float %10509, float* %10512, align 4
  %10513 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10514 = getelementptr inbounds i8, i8* %10513, i64 40
  %10515 = bitcast i8* %10514 to float*
  %10516 = load float, float* %10515, align 4
  %10517 = insertelement <4 x float> zeroinitializer, float %10516, i32 0
  %10518 = insertelement <4 x float> %10517, float 0.000000e+00, i32 1
  %10519 = insertelement <4 x float> %10518, float 0.000000e+00, i32 2
  %10520 = insertelement <4 x float> %10519, float 0.000000e+00, i32 3
  %10521 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10522 = getelementptr inbounds i8, i8* %10521, i64 36
  %10523 = bitcast i8* %10522 to float*
  %10524 = load float, float* %10523, align 4
  %10525 = insertelement <4 x float> zeroinitializer, float %10524, i32 0
  %10526 = insertelement <4 x float> %10525, float 0.000000e+00, i32 1
  %10527 = insertelement <4 x float> %10526, float 0.000000e+00, i32 2
  %10528 = insertelement <4 x float> %10527, float 0.000000e+00, i32 3
  %10529 = getelementptr inbounds float, float* %1, i64 6
  %10530 = load float, float* %10529, align 4
  %10531 = insertelement <4 x float> zeroinitializer, float %10530, i32 0
  %10532 = insertelement <4 x float> %10531, float 0.000000e+00, i32 1
  %10533 = insertelement <4 x float> %10532, float 0.000000e+00, i32 2
  %10534 = insertelement <4 x float> %10533, float 0.000000e+00, i32 3
  %10535 = call <4 x float> @llvm.fma.f32.266(<4 x float> %10528, <4 x float> %10534, <4 x float> %10520)
  %10536 = extractelement <4 x float> %10535, i32 0
  %10537 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10538 = getelementptr inbounds i8, i8* %10537, i64 40
  %10539 = bitcast i8* %10538 to float*
  store float %10536, float* %10539, align 4
  %10540 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10541 = getelementptr inbounds i8, i8* %10540, i64 40
  %10542 = bitcast i8* %10541 to float*
  %10543 = load float, float* %10542, align 4
  %10544 = insertelement <4 x float> zeroinitializer, float %10543, i32 0
  %10545 = insertelement <4 x float> %10544, float 0.000000e+00, i32 1
  %10546 = insertelement <4 x float> %10545, float 0.000000e+00, i32 2
  %10547 = insertelement <4 x float> %10546, float 0.000000e+00, i32 3
  %10548 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10549 = getelementptr inbounds i8, i8* %10548, i64 40
  %10550 = bitcast i8* %10549 to float*
  %10551 = load float, float* %10550, align 4
  %10552 = insertelement <4 x float> zeroinitializer, float %10551, i32 0
  %10553 = insertelement <4 x float> %10552, float 0.000000e+00, i32 1
  %10554 = insertelement <4 x float> %10553, float 0.000000e+00, i32 2
  %10555 = insertelement <4 x float> %10554, float 0.000000e+00, i32 3
  %10556 = getelementptr inbounds float, float* %1, i64 10
  %10557 = load float, float* %10556, align 4
  %10558 = insertelement <4 x float> zeroinitializer, float %10557, i32 0
  %10559 = insertelement <4 x float> %10558, float 0.000000e+00, i32 1
  %10560 = insertelement <4 x float> %10559, float 0.000000e+00, i32 2
  %10561 = insertelement <4 x float> %10560, float 0.000000e+00, i32 3
  %10562 = call <4 x float> @llvm.fma.f32.267(<4 x float> %10555, <4 x float> %10561, <4 x float> %10547)
  %10563 = extractelement <4 x float> %10562, i32 0
  %10564 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10565 = getelementptr inbounds i8, i8* %10564, i64 40
  %10566 = bitcast i8* %10565 to float*
  store float %10563, float* %10566, align 4
  %10567 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10568 = getelementptr inbounds i8, i8* %10567, i64 40
  %10569 = bitcast i8* %10568 to float*
  %10570 = load float, float* %10569, align 4
  %10571 = insertelement <4 x float> zeroinitializer, float %10570, i32 0
  %10572 = insertelement <4 x float> %10571, float 0.000000e+00, i32 1
  %10573 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10574 = getelementptr inbounds i8, i8* %10573, i64 44
  %10575 = bitcast i8* %10574 to float*
  %10576 = load float, float* %10575, align 4
  %10577 = insertelement <4 x float> %10572, float %10576, i32 2
  %10578 = insertelement <4 x float> %10577, float 0.000000e+00, i32 3
  %10579 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10580 = getelementptr inbounds i8, i8* %10579, i64 44
  %10581 = bitcast i8* %10580 to float*
  %10582 = load float, float* %10581, align 4
  %10583 = insertelement <4 x float> zeroinitializer, float %10582, i32 0
  %10584 = insertelement <4 x float> %10583, float 0.000000e+00, i32 1
  %10585 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10586 = getelementptr inbounds i8, i8* %10585, i64 32
  %10587 = bitcast i8* %10586 to float*
  %10588 = load float, float* %10587, align 4
  %10589 = insertelement <4 x float> %10584, float %10588, i32 2
  %10590 = insertelement <4 x float> %10589, float 0.000000e+00, i32 3
  %10591 = getelementptr inbounds float, float* %1, i64 14
  %10592 = load float, float* %10591, align 4
  %10593 = insertelement <4 x float> zeroinitializer, float %10592, i32 0
  %10594 = insertelement <4 x float> %10593, float 0.000000e+00, i32 1
  %10595 = getelementptr inbounds float, float* %1, i64 3
  %10596 = load float, float* %10595, align 4
  %10597 = insertelement <4 x float> %10594, float %10596, i32 2
  %10598 = insertelement <4 x float> %10597, float 0.000000e+00, i32 3
  %10599 = call <4 x float> @llvm.fma.f32.268(<4 x float> %10590, <4 x float> %10598, <4 x float> %10578)
  %10600 = extractelement <4 x float> %10599, i32 0
  %10601 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10602 = getelementptr inbounds i8, i8* %10601, i64 40
  %10603 = bitcast i8* %10602 to float*
  store float %10600, float* %10603, align 4
  %10604 = extractelement <4 x float> %10599, i32 1
  %10605 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10606 = getelementptr inbounds i8, i8* %10605, i64 44
  %10607 = bitcast i8* %10606 to float*
  store float %10604, float* %10607, align 4
  %10608 = extractelement <4 x float> %10599, i32 2
  %10609 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10610 = getelementptr inbounds i8, i8* %10609, i64 44
  %10611 = bitcast i8* %10610 to float*
  store float %10608, float* %10611, align 4
  %10612 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10613 = getelementptr inbounds i8, i8* %10612, i64 44
  %10614 = bitcast i8* %10613 to float*
  %10615 = load float, float* %10614, align 4
  %10616 = insertelement <4 x float> zeroinitializer, float %10615, i32 0
  %10617 = insertelement <4 x float> %10616, float 0.000000e+00, i32 1
  %10618 = insertelement <4 x float> %10617, float 0.000000e+00, i32 2
  %10619 = insertelement <4 x float> %10618, float 0.000000e+00, i32 3
  %10620 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10621 = getelementptr inbounds i8, i8* %10620, i64 36
  %10622 = bitcast i8* %10621 to float*
  %10623 = load float, float* %10622, align 4
  %10624 = insertelement <4 x float> zeroinitializer, float %10623, i32 0
  %10625 = insertelement <4 x float> %10624, float 0.000000e+00, i32 1
  %10626 = insertelement <4 x float> %10625, float 0.000000e+00, i32 2
  %10627 = insertelement <4 x float> %10626, float 0.000000e+00, i32 3
  %10628 = getelementptr inbounds float, float* %1, i64 7
  %10629 = load float, float* %10628, align 4
  %10630 = insertelement <4 x float> zeroinitializer, float %10629, i32 0
  %10631 = insertelement <4 x float> %10630, float 0.000000e+00, i32 1
  %10632 = insertelement <4 x float> %10631, float 0.000000e+00, i32 2
  %10633 = insertelement <4 x float> %10632, float 0.000000e+00, i32 3
  %10634 = call <4 x float> @llvm.fma.f32.269(<4 x float> %10627, <4 x float> %10633, <4 x float> %10619)
  %10635 = extractelement <4 x float> %10634, i32 0
  %10636 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10637 = getelementptr inbounds i8, i8* %10636, i64 44
  %10638 = bitcast i8* %10637 to float*
  store float %10635, float* %10638, align 4
  %10639 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10640 = getelementptr inbounds i8, i8* %10639, i64 44
  %10641 = bitcast i8* %10640 to float*
  %10642 = load float, float* %10641, align 4
  %10643 = insertelement <4 x float> zeroinitializer, float %10642, i32 0
  %10644 = insertelement <4 x float> %10643, float 0.000000e+00, i32 1
  %10645 = insertelement <4 x float> %10644, float 0.000000e+00, i32 2
  %10646 = insertelement <4 x float> %10645, float 0.000000e+00, i32 3
  %10647 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10648 = getelementptr inbounds i8, i8* %10647, i64 40
  %10649 = bitcast i8* %10648 to float*
  %10650 = load float, float* %10649, align 4
  %10651 = insertelement <4 x float> zeroinitializer, float %10650, i32 0
  %10652 = insertelement <4 x float> %10651, float 0.000000e+00, i32 1
  %10653 = insertelement <4 x float> %10652, float 0.000000e+00, i32 2
  %10654 = insertelement <4 x float> %10653, float 0.000000e+00, i32 3
  %10655 = getelementptr inbounds float, float* %1, i64 11
  %10656 = load float, float* %10655, align 4
  %10657 = insertelement <4 x float> zeroinitializer, float %10656, i32 0
  %10658 = insertelement <4 x float> %10657, float 0.000000e+00, i32 1
  %10659 = insertelement <4 x float> %10658, float 0.000000e+00, i32 2
  %10660 = insertelement <4 x float> %10659, float 0.000000e+00, i32 3
  %10661 = call <4 x float> @llvm.fma.f32.270(<4 x float> %10654, <4 x float> %10660, <4 x float> %10646)
  %10662 = extractelement <4 x float> %10661, i32 0
  %10663 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10664 = getelementptr inbounds i8, i8* %10663, i64 44
  %10665 = bitcast i8* %10664 to float*
  store float %10662, float* %10665, align 4
  %10666 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10667 = getelementptr inbounds i8, i8* %10666, i64 44
  %10668 = bitcast i8* %10667 to float*
  %10669 = load float, float* %10668, align 4
  %10670 = insertelement <4 x float> zeroinitializer, float %10669, i32 0
  %10671 = insertelement <4 x float> %10670, float 0.000000e+00, i32 1
  %10672 = insertelement <4 x float> %10671, float 0.000000e+00, i32 2
  %10673 = insertelement <4 x float> %10672, float 0.000000e+00, i32 3
  %10674 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10675 = getelementptr inbounds i8, i8* %10674, i64 44
  %10676 = bitcast i8* %10675 to float*
  %10677 = load float, float* %10676, align 4
  %10678 = insertelement <4 x float> zeroinitializer, float %10677, i32 0
  %10679 = insertelement <4 x float> %10678, float 0.000000e+00, i32 1
  %10680 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10681 = getelementptr inbounds i8, i8* %10680, i64 48
  %10682 = bitcast i8* %10681 to float*
  %10683 = load float, float* %10682, align 4
  %10684 = insertelement <4 x float> %10679, float %10683, i32 2
  %10685 = insertelement <4 x float> %10684, float 0.000000e+00, i32 3
  %10686 = getelementptr inbounds float, float* %1, i64 15
  %10687 = load float, float* %10686, align 4
  %10688 = insertelement <4 x float> zeroinitializer, float %10687, i32 0
  %10689 = insertelement <4 x float> %10688, float 0.000000e+00, i32 1
  %10690 = load float, float* %1, align 4
  %10691 = insertelement <4 x float> %10689, float %10690, i32 2
  %10692 = insertelement <4 x float> %10691, float 0.000000e+00, i32 3
  %10693 = call <4 x float> @llvm.fma.f32.271(<4 x float> %10685, <4 x float> %10692, <4 x float> %10673)
  %10694 = extractelement <4 x float> %10693, i32 0
  %10695 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10696 = getelementptr inbounds i8, i8* %10695, i64 44
  %10697 = bitcast i8* %10696 to float*
  store float %10694, float* %10697, align 4
  %10698 = extractelement <4 x float> %10693, i32 1
  %10699 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10700 = getelementptr inbounds i8, i8* %10699, i64 48
  %10701 = bitcast i8* %10700 to float*
  store float %10698, float* %10701, align 4
  %10702 = extractelement <4 x float> %10693, i32 2
  %10703 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10704 = getelementptr inbounds i8, i8* %10703, i64 48
  %10705 = bitcast i8* %10704 to float*
  store float %10702, float* %10705, align 4
  %10706 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10707 = getelementptr inbounds i8, i8* %10706, i64 48
  %10708 = bitcast i8* %10707 to float*
  %10709 = load float, float* %10708, align 4
  %10710 = insertelement <4 x float> zeroinitializer, float %10709, i32 0
  %10711 = insertelement <4 x float> %10710, float 0.000000e+00, i32 1
  %10712 = insertelement <4 x float> %10711, float 0.000000e+00, i32 2
  %10713 = insertelement <4 x float> %10712, float 0.000000e+00, i32 3
  %10714 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10715 = getelementptr inbounds i8, i8* %10714, i64 52
  %10716 = bitcast i8* %10715 to float*
  %10717 = load float, float* %10716, align 4
  %10718 = insertelement <4 x float> zeroinitializer, float %10717, i32 0
  %10719 = insertelement <4 x float> %10718, float 0.000000e+00, i32 1
  %10720 = insertelement <4 x float> %10719, float 0.000000e+00, i32 2
  %10721 = insertelement <4 x float> %10720, float 0.000000e+00, i32 3
  %10722 = getelementptr inbounds float, float* %1, i64 4
  %10723 = load float, float* %10722, align 4
  %10724 = insertelement <4 x float> zeroinitializer, float %10723, i32 0
  %10725 = insertelement <4 x float> %10724, float 0.000000e+00, i32 1
  %10726 = insertelement <4 x float> %10725, float 0.000000e+00, i32 2
  %10727 = insertelement <4 x float> %10726, float 0.000000e+00, i32 3
  %10728 = call <4 x float> @llvm.fma.f32.272(<4 x float> %10721, <4 x float> %10727, <4 x float> %10713)
  %10729 = extractelement <4 x float> %10728, i32 0
  %10730 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10731 = getelementptr inbounds i8, i8* %10730, i64 48
  %10732 = bitcast i8* %10731 to float*
  store float %10729, float* %10732, align 4
  %10733 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10734 = getelementptr inbounds i8, i8* %10733, i64 48
  %10735 = bitcast i8* %10734 to float*
  %10736 = load float, float* %10735, align 4
  %10737 = insertelement <4 x float> zeroinitializer, float %10736, i32 0
  %10738 = insertelement <4 x float> %10737, float 0.000000e+00, i32 1
  %10739 = insertelement <4 x float> %10738, float 0.000000e+00, i32 2
  %10740 = insertelement <4 x float> %10739, float 0.000000e+00, i32 3
  %10741 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10742 = getelementptr inbounds i8, i8* %10741, i64 56
  %10743 = bitcast i8* %10742 to float*
  %10744 = load float, float* %10743, align 4
  %10745 = insertelement <4 x float> zeroinitializer, float %10744, i32 0
  %10746 = insertelement <4 x float> %10745, float 0.000000e+00, i32 1
  %10747 = insertelement <4 x float> %10746, float 0.000000e+00, i32 2
  %10748 = insertelement <4 x float> %10747, float 0.000000e+00, i32 3
  %10749 = getelementptr inbounds float, float* %1, i64 8
  %10750 = load float, float* %10749, align 4
  %10751 = insertelement <4 x float> zeroinitializer, float %10750, i32 0
  %10752 = insertelement <4 x float> %10751, float 0.000000e+00, i32 1
  %10753 = insertelement <4 x float> %10752, float 0.000000e+00, i32 2
  %10754 = insertelement <4 x float> %10753, float 0.000000e+00, i32 3
  %10755 = call <4 x float> @llvm.fma.f32.273(<4 x float> %10748, <4 x float> %10754, <4 x float> %10740)
  %10756 = extractelement <4 x float> %10755, i32 0
  %10757 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10758 = getelementptr inbounds i8, i8* %10757, i64 48
  %10759 = bitcast i8* %10758 to float*
  store float %10756, float* %10759, align 4
  %10760 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10761 = getelementptr inbounds i8, i8* %10760, i64 48
  %10762 = bitcast i8* %10761 to float*
  %10763 = load float, float* %10762, align 4
  %10764 = insertelement <4 x float> zeroinitializer, float %10763, i32 0
  %10765 = insertelement <4 x float> %10764, float 0.000000e+00, i32 1
  %10766 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10767 = getelementptr inbounds i8, i8* %10766, i64 52
  %10768 = bitcast i8* %10767 to float*
  %10769 = load float, float* %10768, align 4
  %10770 = insertelement <4 x float> %10765, float %10769, i32 2
  %10771 = insertelement <4 x float> %10770, float 0.000000e+00, i32 3
  %10772 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10773 = getelementptr inbounds i8, i8* %10772, i64 60
  %10774 = bitcast i8* %10773 to float*
  %10775 = load float, float* %10774, align 4
  %10776 = insertelement <4 x float> zeroinitializer, float %10775, i32 0
  %10777 = insertelement <4 x float> %10776, float 0.000000e+00, i32 1
  %10778 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10779 = getelementptr inbounds i8, i8* %10778, i64 48
  %10780 = bitcast i8* %10779 to float*
  %10781 = load float, float* %10780, align 4
  %10782 = insertelement <4 x float> %10777, float %10781, i32 2
  %10783 = insertelement <4 x float> %10782, float 0.000000e+00, i32 3
  %10784 = getelementptr inbounds float, float* %1, i64 12
  %10785 = load float, float* %10784, align 4
  %10786 = insertelement <4 x float> zeroinitializer, float %10785, i32 0
  %10787 = insertelement <4 x float> %10786, float 0.000000e+00, i32 1
  %10788 = getelementptr inbounds float, float* %1, i64 1
  %10789 = load float, float* %10788, align 4
  %10790 = insertelement <4 x float> %10787, float %10789, i32 2
  %10791 = insertelement <4 x float> %10790, float 0.000000e+00, i32 3
  %10792 = call <4 x float> @llvm.fma.f32.274(<4 x float> %10783, <4 x float> %10791, <4 x float> %10771)
  %10793 = extractelement <4 x float> %10792, i32 0
  %10794 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10795 = getelementptr inbounds i8, i8* %10794, i64 48
  %10796 = bitcast i8* %10795 to float*
  store float %10793, float* %10796, align 4
  %10797 = extractelement <4 x float> %10792, i32 1
  %10798 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10799 = getelementptr inbounds i8, i8* %10798, i64 52
  %10800 = bitcast i8* %10799 to float*
  store float %10797, float* %10800, align 4
  %10801 = extractelement <4 x float> %10792, i32 2
  %10802 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10803 = getelementptr inbounds i8, i8* %10802, i64 52
  %10804 = bitcast i8* %10803 to float*
  store float %10801, float* %10804, align 4
  %10805 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10806 = getelementptr inbounds i8, i8* %10805, i64 52
  %10807 = bitcast i8* %10806 to float*
  %10808 = load float, float* %10807, align 4
  %10809 = insertelement <4 x float> zeroinitializer, float %10808, i32 0
  %10810 = insertelement <4 x float> %10809, float 0.000000e+00, i32 1
  %10811 = insertelement <4 x float> %10810, float 0.000000e+00, i32 2
  %10812 = insertelement <4 x float> %10811, float 0.000000e+00, i32 3
  %10813 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10814 = getelementptr inbounds i8, i8* %10813, i64 52
  %10815 = bitcast i8* %10814 to float*
  %10816 = load float, float* %10815, align 4
  %10817 = insertelement <4 x float> zeroinitializer, float %10816, i32 0
  %10818 = insertelement <4 x float> %10817, float 0.000000e+00, i32 1
  %10819 = insertelement <4 x float> %10818, float 0.000000e+00, i32 2
  %10820 = insertelement <4 x float> %10819, float 0.000000e+00, i32 3
  %10821 = getelementptr inbounds float, float* %1, i64 5
  %10822 = load float, float* %10821, align 4
  %10823 = insertelement <4 x float> zeroinitializer, float %10822, i32 0
  %10824 = insertelement <4 x float> %10823, float 0.000000e+00, i32 1
  %10825 = insertelement <4 x float> %10824, float 0.000000e+00, i32 2
  %10826 = insertelement <4 x float> %10825, float 0.000000e+00, i32 3
  %10827 = call <4 x float> @llvm.fma.f32.275(<4 x float> %10820, <4 x float> %10826, <4 x float> %10812)
  %10828 = extractelement <4 x float> %10827, i32 0
  %10829 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10830 = getelementptr inbounds i8, i8* %10829, i64 52
  %10831 = bitcast i8* %10830 to float*
  store float %10828, float* %10831, align 4
  %10832 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10833 = getelementptr inbounds i8, i8* %10832, i64 52
  %10834 = bitcast i8* %10833 to float*
  %10835 = load float, float* %10834, align 4
  %10836 = insertelement <4 x float> zeroinitializer, float %10835, i32 0
  %10837 = insertelement <4 x float> %10836, float 0.000000e+00, i32 1
  %10838 = insertelement <4 x float> %10837, float 0.000000e+00, i32 2
  %10839 = insertelement <4 x float> %10838, float 0.000000e+00, i32 3
  %10840 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10841 = getelementptr inbounds i8, i8* %10840, i64 56
  %10842 = bitcast i8* %10841 to float*
  %10843 = load float, float* %10842, align 4
  %10844 = insertelement <4 x float> zeroinitializer, float %10843, i32 0
  %10845 = insertelement <4 x float> %10844, float 0.000000e+00, i32 1
  %10846 = insertelement <4 x float> %10845, float 0.000000e+00, i32 2
  %10847 = insertelement <4 x float> %10846, float 0.000000e+00, i32 3
  %10848 = getelementptr inbounds float, float* %1, i64 9
  %10849 = load float, float* %10848, align 4
  %10850 = insertelement <4 x float> zeroinitializer, float %10849, i32 0
  %10851 = insertelement <4 x float> %10850, float 0.000000e+00, i32 1
  %10852 = insertelement <4 x float> %10851, float 0.000000e+00, i32 2
  %10853 = insertelement <4 x float> %10852, float 0.000000e+00, i32 3
  %10854 = call <4 x float> @llvm.fma.f32.276(<4 x float> %10847, <4 x float> %10853, <4 x float> %10839)
  %10855 = extractelement <4 x float> %10854, i32 0
  %10856 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10857 = getelementptr inbounds i8, i8* %10856, i64 52
  %10858 = bitcast i8* %10857 to float*
  store float %10855, float* %10858, align 4
  %10859 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10860 = getelementptr inbounds i8, i8* %10859, i64 52
  %10861 = bitcast i8* %10860 to float*
  %10862 = load float, float* %10861, align 4
  %10863 = insertelement <4 x float> zeroinitializer, float %10862, i32 0
  %10864 = insertelement <4 x float> %10863, float 0.000000e+00, i32 1
  %10865 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10866 = getelementptr inbounds i8, i8* %10865, i64 56
  %10867 = bitcast i8* %10866 to float*
  %10868 = load float, float* %10867, align 4
  %10869 = insertelement <4 x float> %10864, float %10868, i32 2
  %10870 = insertelement <4 x float> %10869, float 0.000000e+00, i32 3
  %10871 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10872 = getelementptr inbounds i8, i8* %10871, i64 60
  %10873 = bitcast i8* %10872 to float*
  %10874 = load float, float* %10873, align 4
  %10875 = insertelement <4 x float> zeroinitializer, float %10874, i32 0
  %10876 = insertelement <4 x float> %10875, float 0.000000e+00, i32 1
  %10877 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10878 = getelementptr inbounds i8, i8* %10877, i64 48
  %10879 = bitcast i8* %10878 to float*
  %10880 = load float, float* %10879, align 4
  %10881 = insertelement <4 x float> %10876, float %10880, i32 2
  %10882 = insertelement <4 x float> %10881, float 0.000000e+00, i32 3
  %10883 = getelementptr inbounds float, float* %1, i64 13
  %10884 = load float, float* %10883, align 4
  %10885 = insertelement <4 x float> zeroinitializer, float %10884, i32 0
  %10886 = insertelement <4 x float> %10885, float 0.000000e+00, i32 1
  %10887 = getelementptr inbounds float, float* %1, i64 2
  %10888 = load float, float* %10887, align 4
  %10889 = insertelement <4 x float> %10886, float %10888, i32 2
  %10890 = insertelement <4 x float> %10889, float 0.000000e+00, i32 3
  %10891 = call <4 x float> @llvm.fma.f32.277(<4 x float> %10882, <4 x float> %10890, <4 x float> %10870)
  %10892 = extractelement <4 x float> %10891, i32 0
  %10893 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10894 = getelementptr inbounds i8, i8* %10893, i64 52
  %10895 = bitcast i8* %10894 to float*
  store float %10892, float* %10895, align 4
  %10896 = extractelement <4 x float> %10891, i32 1
  %10897 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10898 = getelementptr inbounds i8, i8* %10897, i64 56
  %10899 = bitcast i8* %10898 to float*
  store float %10896, float* %10899, align 4
  %10900 = extractelement <4 x float> %10891, i32 2
  %10901 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10902 = getelementptr inbounds i8, i8* %10901, i64 56
  %10903 = bitcast i8* %10902 to float*
  store float %10900, float* %10903, align 4
  %10904 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10905 = getelementptr inbounds i8, i8* %10904, i64 56
  %10906 = bitcast i8* %10905 to float*
  %10907 = load float, float* %10906, align 4
  %10908 = insertelement <4 x float> zeroinitializer, float %10907, i32 0
  %10909 = insertelement <4 x float> %10908, float 0.000000e+00, i32 1
  %10910 = insertelement <4 x float> %10909, float 0.000000e+00, i32 2
  %10911 = insertelement <4 x float> %10910, float 0.000000e+00, i32 3
  %10912 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10913 = getelementptr inbounds i8, i8* %10912, i64 52
  %10914 = bitcast i8* %10913 to float*
  %10915 = load float, float* %10914, align 4
  %10916 = insertelement <4 x float> zeroinitializer, float %10915, i32 0
  %10917 = insertelement <4 x float> %10916, float 0.000000e+00, i32 1
  %10918 = insertelement <4 x float> %10917, float 0.000000e+00, i32 2
  %10919 = insertelement <4 x float> %10918, float 0.000000e+00, i32 3
  %10920 = getelementptr inbounds float, float* %1, i64 6
  %10921 = load float, float* %10920, align 4
  %10922 = insertelement <4 x float> zeroinitializer, float %10921, i32 0
  %10923 = insertelement <4 x float> %10922, float 0.000000e+00, i32 1
  %10924 = insertelement <4 x float> %10923, float 0.000000e+00, i32 2
  %10925 = insertelement <4 x float> %10924, float 0.000000e+00, i32 3
  %10926 = call <4 x float> @llvm.fma.f32.278(<4 x float> %10919, <4 x float> %10925, <4 x float> %10911)
  %10927 = extractelement <4 x float> %10926, i32 0
  %10928 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10929 = getelementptr inbounds i8, i8* %10928, i64 56
  %10930 = bitcast i8* %10929 to float*
  store float %10927, float* %10930, align 4
  %10931 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10932 = getelementptr inbounds i8, i8* %10931, i64 56
  %10933 = bitcast i8* %10932 to float*
  %10934 = load float, float* %10933, align 4
  %10935 = insertelement <4 x float> zeroinitializer, float %10934, i32 0
  %10936 = insertelement <4 x float> %10935, float 0.000000e+00, i32 1
  %10937 = insertelement <4 x float> %10936, float 0.000000e+00, i32 2
  %10938 = insertelement <4 x float> %10937, float 0.000000e+00, i32 3
  %10939 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10940 = getelementptr inbounds i8, i8* %10939, i64 56
  %10941 = bitcast i8* %10940 to float*
  %10942 = load float, float* %10941, align 4
  %10943 = insertelement <4 x float> zeroinitializer, float %10942, i32 0
  %10944 = insertelement <4 x float> %10943, float 0.000000e+00, i32 1
  %10945 = insertelement <4 x float> %10944, float 0.000000e+00, i32 2
  %10946 = insertelement <4 x float> %10945, float 0.000000e+00, i32 3
  %10947 = getelementptr inbounds float, float* %1, i64 10
  %10948 = load float, float* %10947, align 4
  %10949 = insertelement <4 x float> zeroinitializer, float %10948, i32 0
  %10950 = insertelement <4 x float> %10949, float 0.000000e+00, i32 1
  %10951 = insertelement <4 x float> %10950, float 0.000000e+00, i32 2
  %10952 = insertelement <4 x float> %10951, float 0.000000e+00, i32 3
  %10953 = call <4 x float> @llvm.fma.f32.279(<4 x float> %10946, <4 x float> %10952, <4 x float> %10938)
  %10954 = extractelement <4 x float> %10953, i32 0
  %10955 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10956 = getelementptr inbounds i8, i8* %10955, i64 56
  %10957 = bitcast i8* %10956 to float*
  store float %10954, float* %10957, align 4
  %10958 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10959 = getelementptr inbounds i8, i8* %10958, i64 56
  %10960 = bitcast i8* %10959 to float*
  %10961 = load float, float* %10960, align 4
  %10962 = insertelement <4 x float> zeroinitializer, float %10961, i32 0
  %10963 = insertelement <4 x float> %10962, float 0.000000e+00, i32 1
  %10964 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10965 = getelementptr inbounds i8, i8* %10964, i64 60
  %10966 = bitcast i8* %10965 to float*
  %10967 = load float, float* %10966, align 4
  %10968 = insertelement <4 x float> %10963, float %10967, i32 2
  %10969 = insertelement <4 x float> %10968, float 0.000000e+00, i32 3
  %10970 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10971 = getelementptr inbounds i8, i8* %10970, i64 60
  %10972 = bitcast i8* %10971 to float*
  %10973 = load float, float* %10972, align 4
  %10974 = insertelement <4 x float> zeroinitializer, float %10973, i32 0
  %10975 = insertelement <4 x float> %10974, float 0.000000e+00, i32 1
  %10976 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10977 = getelementptr inbounds i8, i8* %10976, i64 48
  %10978 = bitcast i8* %10977 to float*
  %10979 = load float, float* %10978, align 4
  %10980 = insertelement <4 x float> %10975, float %10979, i32 2
  %10981 = insertelement <4 x float> %10980, float 0.000000e+00, i32 3
  %10982 = getelementptr inbounds float, float* %1, i64 14
  %10983 = load float, float* %10982, align 4
  %10984 = insertelement <4 x float> zeroinitializer, float %10983, i32 0
  %10985 = insertelement <4 x float> %10984, float 0.000000e+00, i32 1
  %10986 = getelementptr inbounds float, float* %1, i64 3
  %10987 = load float, float* %10986, align 4
  %10988 = insertelement <4 x float> %10985, float %10987, i32 2
  %10989 = insertelement <4 x float> %10988, float 0.000000e+00, i32 3
  %10990 = call <4 x float> @llvm.fma.f32.280(<4 x float> %10981, <4 x float> %10989, <4 x float> %10969)
  %10991 = extractelement <4 x float> %10990, i32 0
  %10992 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10993 = getelementptr inbounds i8, i8* %10992, i64 56
  %10994 = bitcast i8* %10993 to float*
  store float %10991, float* %10994, align 4
  %10995 = extractelement <4 x float> %10990, i32 1
  %10996 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %10997 = getelementptr inbounds i8, i8* %10996, i64 60
  %10998 = bitcast i8* %10997 to float*
  store float %10995, float* %10998, align 4
  %10999 = extractelement <4 x float> %10990, i32 2
  %11000 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11001 = getelementptr inbounds i8, i8* %11000, i64 60
  %11002 = bitcast i8* %11001 to float*
  store float %10999, float* %11002, align 4
  %11003 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11004 = getelementptr inbounds i8, i8* %11003, i64 60
  %11005 = bitcast i8* %11004 to float*
  %11006 = load float, float* %11005, align 4
  %11007 = insertelement <4 x float> zeroinitializer, float %11006, i32 0
  %11008 = insertelement <4 x float> %11007, float 0.000000e+00, i32 1
  %11009 = insertelement <4 x float> %11008, float 0.000000e+00, i32 2
  %11010 = insertelement <4 x float> %11009, float 0.000000e+00, i32 3
  %11011 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11012 = getelementptr inbounds i8, i8* %11011, i64 52
  %11013 = bitcast i8* %11012 to float*
  %11014 = load float, float* %11013, align 4
  %11015 = insertelement <4 x float> zeroinitializer, float %11014, i32 0
  %11016 = insertelement <4 x float> %11015, float 0.000000e+00, i32 1
  %11017 = insertelement <4 x float> %11016, float 0.000000e+00, i32 2
  %11018 = insertelement <4 x float> %11017, float 0.000000e+00, i32 3
  %11019 = getelementptr inbounds float, float* %1, i64 7
  %11020 = load float, float* %11019, align 4
  %11021 = insertelement <4 x float> zeroinitializer, float %11020, i32 0
  %11022 = insertelement <4 x float> %11021, float 0.000000e+00, i32 1
  %11023 = insertelement <4 x float> %11022, float 0.000000e+00, i32 2
  %11024 = insertelement <4 x float> %11023, float 0.000000e+00, i32 3
  %11025 = call <4 x float> @llvm.fma.f32.281(<4 x float> %11018, <4 x float> %11024, <4 x float> %11010)
  %11026 = extractelement <4 x float> %11025, i32 0
  %11027 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11028 = getelementptr inbounds i8, i8* %11027, i64 60
  %11029 = bitcast i8* %11028 to float*
  store float %11026, float* %11029, align 4
  %11030 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11031 = getelementptr inbounds i8, i8* %11030, i64 60
  %11032 = bitcast i8* %11031 to float*
  %11033 = load float, float* %11032, align 4
  %11034 = insertelement <4 x float> zeroinitializer, float %11033, i32 0
  %11035 = insertelement <4 x float> %11034, float 0.000000e+00, i32 1
  %11036 = insertelement <4 x float> %11035, float 0.000000e+00, i32 2
  %11037 = insertelement <4 x float> %11036, float 0.000000e+00, i32 3
  %11038 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11039 = getelementptr inbounds i8, i8* %11038, i64 56
  %11040 = bitcast i8* %11039 to float*
  %11041 = load float, float* %11040, align 4
  %11042 = insertelement <4 x float> zeroinitializer, float %11041, i32 0
  %11043 = insertelement <4 x float> %11042, float 0.000000e+00, i32 1
  %11044 = insertelement <4 x float> %11043, float 0.000000e+00, i32 2
  %11045 = insertelement <4 x float> %11044, float 0.000000e+00, i32 3
  %11046 = getelementptr inbounds float, float* %1, i64 11
  %11047 = load float, float* %11046, align 4
  %11048 = insertelement <4 x float> zeroinitializer, float %11047, i32 0
  %11049 = insertelement <4 x float> %11048, float 0.000000e+00, i32 1
  %11050 = insertelement <4 x float> %11049, float 0.000000e+00, i32 2
  %11051 = insertelement <4 x float> %11050, float 0.000000e+00, i32 3
  %11052 = call <4 x float> @llvm.fma.f32.282(<4 x float> %11045, <4 x float> %11051, <4 x float> %11037)
  %11053 = extractelement <4 x float> %11052, i32 0
  %11054 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11055 = getelementptr inbounds i8, i8* %11054, i64 60
  %11056 = bitcast i8* %11055 to float*
  store float %11053, float* %11056, align 4
  %11057 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11058 = getelementptr inbounds i8, i8* %11057, i64 60
  %11059 = bitcast i8* %11058 to float*
  %11060 = load float, float* %11059, align 4
  %11061 = insertelement <4 x float> zeroinitializer, float %11060, i32 0
  %11062 = insertelement <4 x float> %11061, float 0.000000e+00, i32 1
  %11063 = insertelement <4 x float> %11062, float 0.000000e+00, i32 2
  %11064 = insertelement <4 x float> %11063, float 0.000000e+00, i32 3
  %11065 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11066 = getelementptr inbounds i8, i8* %11065, i64 60
  %11067 = bitcast i8* %11066 to float*
  %11068 = load float, float* %11067, align 4
  %11069 = insertelement <4 x float> zeroinitializer, float %11068, i32 0
  %11070 = insertelement <4 x float> %11069, float 0.000000e+00, i32 1
  %11071 = insertelement <4 x float> %11070, float 0.000000e+00, i32 2
  %11072 = insertelement <4 x float> %11071, float 0.000000e+00, i32 3
  %11073 = getelementptr inbounds float, float* %1, i64 15
  %11074 = load float, float* %11073, align 4
  %11075 = insertelement <4 x float> zeroinitializer, float %11074, i32 0
  %11076 = insertelement <4 x float> %11075, float 0.000000e+00, i32 1
  %11077 = insertelement <4 x float> %11076, float 0.000000e+00, i32 2
  %11078 = insertelement <4 x float> %11077, float 0.000000e+00, i32 3
  %11079 = call <4 x float> @llvm.fma.f32.283(<4 x float> %11072, <4 x float> %11078, <4 x float> %11064)
  %11080 = extractelement <4 x float> %11079, i32 0
  %11081 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11082 = getelementptr inbounds i8, i8* %11081, i64 60
  %11083 = bitcast i8* %11082 to float*
  store float %11080, float* %11083, align 4
  %11084 = extractelement <4 x float> %11079, i32 1
  %11085 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11086 = bitcast i8* %11085 to float*
  store float %11084, float* %11086, align 4
  %11087 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11088 = bitcast i8* %11087 to float*
  %11089 = load float, float* %11088, align 4
  %11090 = insertelement <4 x float> zeroinitializer, float %11089, i32 0
  %11091 = insertelement <4 x float> %11090, float 0.000000e+00, i32 1
  %11092 = insertelement <4 x float> %11091, float 0.000000e+00, i32 2
  %11093 = insertelement <4 x float> %11092, float 0.000000e+00, i32 3
  %11094 = load float, float* %2, align 4
  %11095 = insertelement <4 x float> zeroinitializer, float %11094, i32 0
  %11096 = insertelement <4 x float> %11095, float 0.000000e+00, i32 1
  %11097 = insertelement <4 x float> %11096, float 0.000000e+00, i32 2
  %11098 = insertelement <4 x float> %11097, float 0.000000e+00, i32 3
  %11099 = call <4 x float> @llvm.fma.f32.284(<4 x float> %11093, <4 x float> %11098, <4 x float> zeroinitializer)
  %11100 = extractelement <4 x float> %11099, i32 0
  %11101 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11102 = bitcast i8* %11101 to float*
  store float %11100, float* %11102, align 4
  %11103 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11104 = bitcast i8* %11103 to float*
  %11105 = load float, float* %11104, align 4
  %11106 = insertelement <4 x float> zeroinitializer, float %11105, i32 0
  %11107 = insertelement <4 x float> %11106, float 0.000000e+00, i32 1
  %11108 = insertelement <4 x float> %11107, float 0.000000e+00, i32 2
  %11109 = insertelement <4 x float> %11108, float 0.000000e+00, i32 3
  %11110 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11111 = getelementptr inbounds i8, i8* %11110, i64 4
  %11112 = bitcast i8* %11111 to float*
  %11113 = load float, float* %11112, align 4
  %11114 = insertelement <4 x float> zeroinitializer, float %11113, i32 0
  %11115 = insertelement <4 x float> %11114, float 0.000000e+00, i32 1
  %11116 = insertelement <4 x float> %11115, float 0.000000e+00, i32 2
  %11117 = insertelement <4 x float> %11116, float 0.000000e+00, i32 3
  %11118 = getelementptr inbounds float, float* %2, i64 4
  %11119 = load float, float* %11118, align 4
  %11120 = insertelement <4 x float> zeroinitializer, float %11119, i32 0
  %11121 = insertelement <4 x float> %11120, float 0.000000e+00, i32 1
  %11122 = insertelement <4 x float> %11121, float 0.000000e+00, i32 2
  %11123 = insertelement <4 x float> %11122, float 0.000000e+00, i32 3
  %11124 = call <4 x float> @llvm.fma.f32.285(<4 x float> %11117, <4 x float> %11123, <4 x float> %11109)
  %11125 = extractelement <4 x float> %11124, i32 0
  %11126 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11127 = bitcast i8* %11126 to float*
  store float %11125, float* %11127, align 4
  %11128 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11129 = bitcast i8* %11128 to float*
  %11130 = load float, float* %11129, align 4
  %11131 = insertelement <4 x float> zeroinitializer, float %11130, i32 0
  %11132 = insertelement <4 x float> %11131, float 0.000000e+00, i32 1
  %11133 = insertelement <4 x float> %11132, float 0.000000e+00, i32 2
  %11134 = insertelement <4 x float> %11133, float 0.000000e+00, i32 3
  %11135 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11136 = getelementptr inbounds i8, i8* %11135, i64 8
  %11137 = bitcast i8* %11136 to float*
  %11138 = load float, float* %11137, align 4
  %11139 = insertelement <4 x float> zeroinitializer, float %11138, i32 0
  %11140 = insertelement <4 x float> %11139, float 0.000000e+00, i32 1
  %11141 = insertelement <4 x float> %11140, float 0.000000e+00, i32 2
  %11142 = insertelement <4 x float> %11141, float 0.000000e+00, i32 3
  %11143 = getelementptr inbounds float, float* %2, i64 8
  %11144 = load float, float* %11143, align 4
  %11145 = insertelement <4 x float> zeroinitializer, float %11144, i32 0
  %11146 = insertelement <4 x float> %11145, float 0.000000e+00, i32 1
  %11147 = insertelement <4 x float> %11146, float 0.000000e+00, i32 2
  %11148 = insertelement <4 x float> %11147, float 0.000000e+00, i32 3
  %11149 = call <4 x float> @llvm.fma.f32.286(<4 x float> %11142, <4 x float> %11148, <4 x float> %11134)
  %11150 = extractelement <4 x float> %11149, i32 0
  %11151 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11152 = bitcast i8* %11151 to float*
  store float %11150, float* %11152, align 4
  %11153 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11154 = bitcast i8* %11153 to float*
  %11155 = load float, float* %11154, align 4
  %11156 = insertelement <4 x float> zeroinitializer, float %11155, i32 0
  %11157 = insertelement <4 x float> %11156, float 0.000000e+00, i32 1
  %11158 = insertelement <4 x float> %11157, float 0.000000e+00, i32 2
  %11159 = insertelement <4 x float> %11158, float 0.000000e+00, i32 3
  %11160 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11161 = getelementptr inbounds i8, i8* %11160, i64 12
  %11162 = bitcast i8* %11161 to float*
  %11163 = load float, float* %11162, align 4
  %11164 = insertelement <4 x float> zeroinitializer, float %11163, i32 0
  %11165 = insertelement <4 x float> %11164, float 0.000000e+00, i32 1
  %11166 = insertelement <4 x float> %11165, float 0.000000e+00, i32 2
  %11167 = insertelement <4 x float> %11166, float 0.000000e+00, i32 3
  %11168 = getelementptr inbounds float, float* %2, i64 12
  %11169 = load float, float* %11168, align 4
  %11170 = insertelement <4 x float> zeroinitializer, float %11169, i32 0
  %11171 = insertelement <4 x float> %11170, float 0.000000e+00, i32 1
  %11172 = insertelement <4 x float> %11171, float 0.000000e+00, i32 2
  %11173 = insertelement <4 x float> %11172, float 0.000000e+00, i32 3
  %11174 = call <4 x float> @llvm.fma.f32.287(<4 x float> %11167, <4 x float> %11173, <4 x float> %11159)
  %11175 = extractelement <4 x float> %11174, i32 0
  %11176 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11177 = bitcast i8* %11176 to float*
  store float %11175, float* %11177, align 4
  %11178 = extractelement <4 x float> %11174, i32 1
  %11179 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11180 = getelementptr inbounds i8, i8* %11179, i64 4
  %11181 = bitcast i8* %11180 to float*
  store float %11178, float* %11181, align 4
  %11182 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11183 = getelementptr inbounds i8, i8* %11182, i64 4
  %11184 = bitcast i8* %11183 to float*
  %11185 = load float, float* %11184, align 4
  %11186 = insertelement <4 x float> zeroinitializer, float %11185, i32 0
  %11187 = insertelement <4 x float> %11186, float 0.000000e+00, i32 1
  %11188 = insertelement <4 x float> %11187, float 0.000000e+00, i32 2
  %11189 = insertelement <4 x float> %11188, float 0.000000e+00, i32 3
  %11190 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11191 = bitcast i8* %11190 to float*
  %11192 = load float, float* %11191, align 4
  %11193 = insertelement <4 x float> zeroinitializer, float %11192, i32 0
  %11194 = insertelement <4 x float> %11193, float 0.000000e+00, i32 1
  %11195 = insertelement <4 x float> %11194, float 0.000000e+00, i32 2
  %11196 = insertelement <4 x float> %11195, float 0.000000e+00, i32 3
  %11197 = getelementptr inbounds float, float* %2, i64 1
  %11198 = load float, float* %11197, align 4
  %11199 = insertelement <4 x float> zeroinitializer, float %11198, i32 0
  %11200 = insertelement <4 x float> %11199, float 0.000000e+00, i32 1
  %11201 = insertelement <4 x float> %11200, float 0.000000e+00, i32 2
  %11202 = insertelement <4 x float> %11201, float 0.000000e+00, i32 3
  %11203 = call <4 x float> @llvm.fma.f32.288(<4 x float> %11196, <4 x float> %11202, <4 x float> %11189)
  %11204 = extractelement <4 x float> %11203, i32 0
  %11205 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11206 = getelementptr inbounds i8, i8* %11205, i64 4
  %11207 = bitcast i8* %11206 to float*
  store float %11204, float* %11207, align 4
  %11208 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11209 = getelementptr inbounds i8, i8* %11208, i64 4
  %11210 = bitcast i8* %11209 to float*
  %11211 = load float, float* %11210, align 4
  %11212 = insertelement <4 x float> zeroinitializer, float %11211, i32 0
  %11213 = insertelement <4 x float> %11212, float 0.000000e+00, i32 1
  %11214 = insertelement <4 x float> %11213, float 0.000000e+00, i32 2
  %11215 = insertelement <4 x float> %11214, float 0.000000e+00, i32 3
  %11216 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11217 = getelementptr inbounds i8, i8* %11216, i64 4
  %11218 = bitcast i8* %11217 to float*
  %11219 = load float, float* %11218, align 4
  %11220 = insertelement <4 x float> zeroinitializer, float %11219, i32 0
  %11221 = insertelement <4 x float> %11220, float 0.000000e+00, i32 1
  %11222 = insertelement <4 x float> %11221, float 0.000000e+00, i32 2
  %11223 = insertelement <4 x float> %11222, float 0.000000e+00, i32 3
  %11224 = getelementptr inbounds float, float* %2, i64 5
  %11225 = load float, float* %11224, align 4
  %11226 = insertelement <4 x float> zeroinitializer, float %11225, i32 0
  %11227 = insertelement <4 x float> %11226, float 0.000000e+00, i32 1
  %11228 = insertelement <4 x float> %11227, float 0.000000e+00, i32 2
  %11229 = insertelement <4 x float> %11228, float 0.000000e+00, i32 3
  %11230 = call <4 x float> @llvm.fma.f32.289(<4 x float> %11223, <4 x float> %11229, <4 x float> %11215)
  %11231 = extractelement <4 x float> %11230, i32 0
  %11232 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11233 = getelementptr inbounds i8, i8* %11232, i64 4
  %11234 = bitcast i8* %11233 to float*
  store float %11231, float* %11234, align 4
  %11235 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11236 = getelementptr inbounds i8, i8* %11235, i64 4
  %11237 = bitcast i8* %11236 to float*
  %11238 = load float, float* %11237, align 4
  %11239 = insertelement <4 x float> zeroinitializer, float %11238, i32 0
  %11240 = insertelement <4 x float> %11239, float 0.000000e+00, i32 1
  %11241 = insertelement <4 x float> %11240, float 0.000000e+00, i32 2
  %11242 = insertelement <4 x float> %11241, float 0.000000e+00, i32 3
  %11243 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11244 = getelementptr inbounds i8, i8* %11243, i64 8
  %11245 = bitcast i8* %11244 to float*
  %11246 = load float, float* %11245, align 4
  %11247 = insertelement <4 x float> zeroinitializer, float %11246, i32 0
  %11248 = insertelement <4 x float> %11247, float 0.000000e+00, i32 1
  %11249 = insertelement <4 x float> %11248, float 0.000000e+00, i32 2
  %11250 = insertelement <4 x float> %11249, float 0.000000e+00, i32 3
  %11251 = getelementptr inbounds float, float* %2, i64 9
  %11252 = load float, float* %11251, align 4
  %11253 = insertelement <4 x float> zeroinitializer, float %11252, i32 0
  %11254 = insertelement <4 x float> %11253, float 0.000000e+00, i32 1
  %11255 = insertelement <4 x float> %11254, float 0.000000e+00, i32 2
  %11256 = insertelement <4 x float> %11255, float 0.000000e+00, i32 3
  %11257 = call <4 x float> @llvm.fma.f32.290(<4 x float> %11250, <4 x float> %11256, <4 x float> %11242)
  %11258 = extractelement <4 x float> %11257, i32 0
  %11259 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11260 = getelementptr inbounds i8, i8* %11259, i64 4
  %11261 = bitcast i8* %11260 to float*
  store float %11258, float* %11261, align 4
  %11262 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11263 = getelementptr inbounds i8, i8* %11262, i64 4
  %11264 = bitcast i8* %11263 to float*
  %11265 = load float, float* %11264, align 4
  %11266 = insertelement <4 x float> zeroinitializer, float %11265, i32 0
  %11267 = insertelement <4 x float> %11266, float 0.000000e+00, i32 1
  %11268 = insertelement <4 x float> %11267, float 0.000000e+00, i32 2
  %11269 = insertelement <4 x float> %11268, float 0.000000e+00, i32 3
  %11270 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11271 = getelementptr inbounds i8, i8* %11270, i64 12
  %11272 = bitcast i8* %11271 to float*
  %11273 = load float, float* %11272, align 4
  %11274 = insertelement <4 x float> zeroinitializer, float %11273, i32 0
  %11275 = insertelement <4 x float> %11274, float 0.000000e+00, i32 1
  %11276 = insertelement <4 x float> %11275, float 0.000000e+00, i32 2
  %11277 = insertelement <4 x float> %11276, float 0.000000e+00, i32 3
  %11278 = getelementptr inbounds float, float* %2, i64 13
  %11279 = load float, float* %11278, align 4
  %11280 = insertelement <4 x float> zeroinitializer, float %11279, i32 0
  %11281 = insertelement <4 x float> %11280, float 0.000000e+00, i32 1
  %11282 = insertelement <4 x float> %11281, float 0.000000e+00, i32 2
  %11283 = insertelement <4 x float> %11282, float 0.000000e+00, i32 3
  %11284 = call <4 x float> @llvm.fma.f32.291(<4 x float> %11277, <4 x float> %11283, <4 x float> %11269)
  %11285 = extractelement <4 x float> %11284, i32 0
  %11286 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11287 = getelementptr inbounds i8, i8* %11286, i64 4
  %11288 = bitcast i8* %11287 to float*
  store float %11285, float* %11288, align 4
  %11289 = extractelement <4 x float> %11284, i32 1
  %11290 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11291 = getelementptr inbounds i8, i8* %11290, i64 8
  %11292 = bitcast i8* %11291 to float*
  store float %11289, float* %11292, align 4
  %11293 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11294 = getelementptr inbounds i8, i8* %11293, i64 8
  %11295 = bitcast i8* %11294 to float*
  %11296 = load float, float* %11295, align 4
  %11297 = insertelement <4 x float> zeroinitializer, float %11296, i32 0
  %11298 = insertelement <4 x float> %11297, float 0.000000e+00, i32 1
  %11299 = insertelement <4 x float> %11298, float 0.000000e+00, i32 2
  %11300 = insertelement <4 x float> %11299, float 0.000000e+00, i32 3
  %11301 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11302 = bitcast i8* %11301 to float*
  %11303 = load float, float* %11302, align 4
  %11304 = insertelement <4 x float> zeroinitializer, float %11303, i32 0
  %11305 = insertelement <4 x float> %11304, float 0.000000e+00, i32 1
  %11306 = insertelement <4 x float> %11305, float 0.000000e+00, i32 2
  %11307 = insertelement <4 x float> %11306, float 0.000000e+00, i32 3
  %11308 = getelementptr inbounds float, float* %2, i64 2
  %11309 = load float, float* %11308, align 4
  %11310 = insertelement <4 x float> zeroinitializer, float %11309, i32 0
  %11311 = insertelement <4 x float> %11310, float 0.000000e+00, i32 1
  %11312 = insertelement <4 x float> %11311, float 0.000000e+00, i32 2
  %11313 = insertelement <4 x float> %11312, float 0.000000e+00, i32 3
  %11314 = call <4 x float> @llvm.fma.f32.292(<4 x float> %11307, <4 x float> %11313, <4 x float> %11300)
  %11315 = extractelement <4 x float> %11314, i32 0
  %11316 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11317 = getelementptr inbounds i8, i8* %11316, i64 8
  %11318 = bitcast i8* %11317 to float*
  store float %11315, float* %11318, align 4
  %11319 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11320 = getelementptr inbounds i8, i8* %11319, i64 8
  %11321 = bitcast i8* %11320 to float*
  %11322 = load float, float* %11321, align 4
  %11323 = insertelement <4 x float> zeroinitializer, float %11322, i32 0
  %11324 = insertelement <4 x float> %11323, float 0.000000e+00, i32 1
  %11325 = insertelement <4 x float> %11324, float 0.000000e+00, i32 2
  %11326 = insertelement <4 x float> %11325, float 0.000000e+00, i32 3
  %11327 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11328 = getelementptr inbounds i8, i8* %11327, i64 4
  %11329 = bitcast i8* %11328 to float*
  %11330 = load float, float* %11329, align 4
  %11331 = insertelement <4 x float> zeroinitializer, float %11330, i32 0
  %11332 = insertelement <4 x float> %11331, float 0.000000e+00, i32 1
  %11333 = insertelement <4 x float> %11332, float 0.000000e+00, i32 2
  %11334 = insertelement <4 x float> %11333, float 0.000000e+00, i32 3
  %11335 = getelementptr inbounds float, float* %2, i64 6
  %11336 = load float, float* %11335, align 4
  %11337 = insertelement <4 x float> zeroinitializer, float %11336, i32 0
  %11338 = insertelement <4 x float> %11337, float 0.000000e+00, i32 1
  %11339 = insertelement <4 x float> %11338, float 0.000000e+00, i32 2
  %11340 = insertelement <4 x float> %11339, float 0.000000e+00, i32 3
  %11341 = call <4 x float> @llvm.fma.f32.293(<4 x float> %11334, <4 x float> %11340, <4 x float> %11326)
  %11342 = extractelement <4 x float> %11341, i32 0
  %11343 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11344 = getelementptr inbounds i8, i8* %11343, i64 8
  %11345 = bitcast i8* %11344 to float*
  store float %11342, float* %11345, align 4
  %11346 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11347 = getelementptr inbounds i8, i8* %11346, i64 8
  %11348 = bitcast i8* %11347 to float*
  %11349 = load float, float* %11348, align 4
  %11350 = insertelement <4 x float> zeroinitializer, float %11349, i32 0
  %11351 = insertelement <4 x float> %11350, float 0.000000e+00, i32 1
  %11352 = insertelement <4 x float> %11351, float 0.000000e+00, i32 2
  %11353 = insertelement <4 x float> %11352, float 0.000000e+00, i32 3
  %11354 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11355 = getelementptr inbounds i8, i8* %11354, i64 8
  %11356 = bitcast i8* %11355 to float*
  %11357 = load float, float* %11356, align 4
  %11358 = insertelement <4 x float> zeroinitializer, float %11357, i32 0
  %11359 = insertelement <4 x float> %11358, float 0.000000e+00, i32 1
  %11360 = insertelement <4 x float> %11359, float 0.000000e+00, i32 2
  %11361 = insertelement <4 x float> %11360, float 0.000000e+00, i32 3
  %11362 = getelementptr inbounds float, float* %2, i64 10
  %11363 = load float, float* %11362, align 4
  %11364 = insertelement <4 x float> zeroinitializer, float %11363, i32 0
  %11365 = insertelement <4 x float> %11364, float 0.000000e+00, i32 1
  %11366 = insertelement <4 x float> %11365, float 0.000000e+00, i32 2
  %11367 = insertelement <4 x float> %11366, float 0.000000e+00, i32 3
  %11368 = call <4 x float> @llvm.fma.f32.294(<4 x float> %11361, <4 x float> %11367, <4 x float> %11353)
  %11369 = extractelement <4 x float> %11368, i32 0
  %11370 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11371 = getelementptr inbounds i8, i8* %11370, i64 8
  %11372 = bitcast i8* %11371 to float*
  store float %11369, float* %11372, align 4
  %11373 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11374 = getelementptr inbounds i8, i8* %11373, i64 8
  %11375 = bitcast i8* %11374 to float*
  %11376 = load float, float* %11375, align 4
  %11377 = insertelement <4 x float> zeroinitializer, float %11376, i32 0
  %11378 = insertelement <4 x float> %11377, float 0.000000e+00, i32 1
  %11379 = insertelement <4 x float> %11378, float 0.000000e+00, i32 2
  %11380 = insertelement <4 x float> %11379, float 0.000000e+00, i32 3
  %11381 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11382 = getelementptr inbounds i8, i8* %11381, i64 12
  %11383 = bitcast i8* %11382 to float*
  %11384 = load float, float* %11383, align 4
  %11385 = insertelement <4 x float> zeroinitializer, float %11384, i32 0
  %11386 = insertelement <4 x float> %11385, float 0.000000e+00, i32 1
  %11387 = insertelement <4 x float> %11386, float 0.000000e+00, i32 2
  %11388 = insertelement <4 x float> %11387, float 0.000000e+00, i32 3
  %11389 = getelementptr inbounds float, float* %2, i64 14
  %11390 = load float, float* %11389, align 4
  %11391 = insertelement <4 x float> zeroinitializer, float %11390, i32 0
  %11392 = insertelement <4 x float> %11391, float 0.000000e+00, i32 1
  %11393 = insertelement <4 x float> %11392, float 0.000000e+00, i32 2
  %11394 = insertelement <4 x float> %11393, float 0.000000e+00, i32 3
  %11395 = call <4 x float> @llvm.fma.f32.295(<4 x float> %11388, <4 x float> %11394, <4 x float> %11380)
  %11396 = extractelement <4 x float> %11395, i32 0
  %11397 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11398 = getelementptr inbounds i8, i8* %11397, i64 8
  %11399 = bitcast i8* %11398 to float*
  store float %11396, float* %11399, align 4
  %11400 = extractelement <4 x float> %11395, i32 1
  %11401 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11402 = getelementptr inbounds i8, i8* %11401, i64 12
  %11403 = bitcast i8* %11402 to float*
  store float %11400, float* %11403, align 4
  %11404 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11405 = getelementptr inbounds i8, i8* %11404, i64 12
  %11406 = bitcast i8* %11405 to float*
  %11407 = load float, float* %11406, align 4
  %11408 = insertelement <4 x float> zeroinitializer, float %11407, i32 0
  %11409 = insertelement <4 x float> %11408, float 0.000000e+00, i32 1
  %11410 = insertelement <4 x float> %11409, float 0.000000e+00, i32 2
  %11411 = insertelement <4 x float> %11410, float 0.000000e+00, i32 3
  %11412 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11413 = bitcast i8* %11412 to float*
  %11414 = load float, float* %11413, align 4
  %11415 = insertelement <4 x float> zeroinitializer, float %11414, i32 0
  %11416 = insertelement <4 x float> %11415, float 0.000000e+00, i32 1
  %11417 = insertelement <4 x float> %11416, float 0.000000e+00, i32 2
  %11418 = insertelement <4 x float> %11417, float 0.000000e+00, i32 3
  %11419 = getelementptr inbounds float, float* %2, i64 3
  %11420 = load float, float* %11419, align 4
  %11421 = insertelement <4 x float> zeroinitializer, float %11420, i32 0
  %11422 = insertelement <4 x float> %11421, float 0.000000e+00, i32 1
  %11423 = insertelement <4 x float> %11422, float 0.000000e+00, i32 2
  %11424 = insertelement <4 x float> %11423, float 0.000000e+00, i32 3
  %11425 = call <4 x float> @llvm.fma.f32.296(<4 x float> %11418, <4 x float> %11424, <4 x float> %11411)
  %11426 = extractelement <4 x float> %11425, i32 0
  %11427 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11428 = getelementptr inbounds i8, i8* %11427, i64 12
  %11429 = bitcast i8* %11428 to float*
  store float %11426, float* %11429, align 4
  %11430 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11431 = getelementptr inbounds i8, i8* %11430, i64 12
  %11432 = bitcast i8* %11431 to float*
  %11433 = load float, float* %11432, align 4
  %11434 = insertelement <4 x float> zeroinitializer, float %11433, i32 0
  %11435 = insertelement <4 x float> %11434, float 0.000000e+00, i32 1
  %11436 = insertelement <4 x float> %11435, float 0.000000e+00, i32 2
  %11437 = insertelement <4 x float> %11436, float 0.000000e+00, i32 3
  %11438 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11439 = getelementptr inbounds i8, i8* %11438, i64 4
  %11440 = bitcast i8* %11439 to float*
  %11441 = load float, float* %11440, align 4
  %11442 = insertelement <4 x float> zeroinitializer, float %11441, i32 0
  %11443 = insertelement <4 x float> %11442, float 0.000000e+00, i32 1
  %11444 = insertelement <4 x float> %11443, float 0.000000e+00, i32 2
  %11445 = insertelement <4 x float> %11444, float 0.000000e+00, i32 3
  %11446 = getelementptr inbounds float, float* %2, i64 7
  %11447 = load float, float* %11446, align 4
  %11448 = insertelement <4 x float> zeroinitializer, float %11447, i32 0
  %11449 = insertelement <4 x float> %11448, float 0.000000e+00, i32 1
  %11450 = insertelement <4 x float> %11449, float 0.000000e+00, i32 2
  %11451 = insertelement <4 x float> %11450, float 0.000000e+00, i32 3
  %11452 = call <4 x float> @llvm.fma.f32.297(<4 x float> %11445, <4 x float> %11451, <4 x float> %11437)
  %11453 = extractelement <4 x float> %11452, i32 0
  %11454 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11455 = getelementptr inbounds i8, i8* %11454, i64 12
  %11456 = bitcast i8* %11455 to float*
  store float %11453, float* %11456, align 4
  %11457 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11458 = getelementptr inbounds i8, i8* %11457, i64 12
  %11459 = bitcast i8* %11458 to float*
  %11460 = load float, float* %11459, align 4
  %11461 = insertelement <4 x float> zeroinitializer, float %11460, i32 0
  %11462 = insertelement <4 x float> %11461, float 0.000000e+00, i32 1
  %11463 = insertelement <4 x float> %11462, float 0.000000e+00, i32 2
  %11464 = insertelement <4 x float> %11463, float 0.000000e+00, i32 3
  %11465 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11466 = getelementptr inbounds i8, i8* %11465, i64 8
  %11467 = bitcast i8* %11466 to float*
  %11468 = load float, float* %11467, align 4
  %11469 = insertelement <4 x float> zeroinitializer, float %11468, i32 0
  %11470 = insertelement <4 x float> %11469, float 0.000000e+00, i32 1
  %11471 = insertelement <4 x float> %11470, float 0.000000e+00, i32 2
  %11472 = insertelement <4 x float> %11471, float 0.000000e+00, i32 3
  %11473 = getelementptr inbounds float, float* %2, i64 11
  %11474 = load float, float* %11473, align 4
  %11475 = insertelement <4 x float> zeroinitializer, float %11474, i32 0
  %11476 = insertelement <4 x float> %11475, float 0.000000e+00, i32 1
  %11477 = insertelement <4 x float> %11476, float 0.000000e+00, i32 2
  %11478 = insertelement <4 x float> %11477, float 0.000000e+00, i32 3
  %11479 = call <4 x float> @llvm.fma.f32.298(<4 x float> %11472, <4 x float> %11478, <4 x float> %11464)
  %11480 = extractelement <4 x float> %11479, i32 0
  %11481 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11482 = getelementptr inbounds i8, i8* %11481, i64 12
  %11483 = bitcast i8* %11482 to float*
  store float %11480, float* %11483, align 4
  %11484 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11485 = getelementptr inbounds i8, i8* %11484, i64 12
  %11486 = bitcast i8* %11485 to float*
  %11487 = load float, float* %11486, align 4
  %11488 = insertelement <4 x float> zeroinitializer, float %11487, i32 0
  %11489 = insertelement <4 x float> %11488, float 0.000000e+00, i32 1
  %11490 = insertelement <4 x float> %11489, float 0.000000e+00, i32 2
  %11491 = insertelement <4 x float> %11490, float 0.000000e+00, i32 3
  %11492 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11493 = getelementptr inbounds i8, i8* %11492, i64 12
  %11494 = bitcast i8* %11493 to float*
  %11495 = load float, float* %11494, align 4
  %11496 = insertelement <4 x float> zeroinitializer, float %11495, i32 0
  %11497 = insertelement <4 x float> %11496, float 0.000000e+00, i32 1
  %11498 = insertelement <4 x float> %11497, float 0.000000e+00, i32 2
  %11499 = insertelement <4 x float> %11498, float 0.000000e+00, i32 3
  %11500 = getelementptr inbounds float, float* %2, i64 15
  %11501 = load float, float* %11500, align 4
  %11502 = insertelement <4 x float> zeroinitializer, float %11501, i32 0
  %11503 = insertelement <4 x float> %11502, float 0.000000e+00, i32 1
  %11504 = insertelement <4 x float> %11503, float 0.000000e+00, i32 2
  %11505 = insertelement <4 x float> %11504, float 0.000000e+00, i32 3
  %11506 = call <4 x float> @llvm.fma.f32.299(<4 x float> %11499, <4 x float> %11505, <4 x float> %11491)
  %11507 = extractelement <4 x float> %11506, i32 0
  %11508 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11509 = getelementptr inbounds i8, i8* %11508, i64 12
  %11510 = bitcast i8* %11509 to float*
  store float %11507, float* %11510, align 4
  %11511 = extractelement <4 x float> %11506, i32 1
  %11512 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11513 = getelementptr inbounds i8, i8* %11512, i64 16
  %11514 = bitcast i8* %11513 to float*
  store float %11511, float* %11514, align 4
  %11515 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11516 = getelementptr inbounds i8, i8* %11515, i64 16
  %11517 = bitcast i8* %11516 to float*
  %11518 = load float, float* %11517, align 4
  %11519 = insertelement <4 x float> zeroinitializer, float %11518, i32 0
  %11520 = insertelement <4 x float> %11519, float 0.000000e+00, i32 1
  %11521 = insertelement <4 x float> %11520, float 0.000000e+00, i32 2
  %11522 = insertelement <4 x float> %11521, float 0.000000e+00, i32 3
  %11523 = load float, float* %2, align 4
  %11524 = insertelement <4 x float> zeroinitializer, float %11523, i32 0
  %11525 = insertelement <4 x float> %11524, float 0.000000e+00, i32 1
  %11526 = insertelement <4 x float> %11525, float 0.000000e+00, i32 2
  %11527 = insertelement <4 x float> %11526, float 0.000000e+00, i32 3
  %11528 = call <4 x float> @llvm.fma.f32.300(<4 x float> %11522, <4 x float> %11527, <4 x float> zeroinitializer)
  %11529 = extractelement <4 x float> %11528, i32 0
  %11530 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11531 = getelementptr inbounds i8, i8* %11530, i64 16
  %11532 = bitcast i8* %11531 to float*
  store float %11529, float* %11532, align 4
  %11533 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11534 = getelementptr inbounds i8, i8* %11533, i64 16
  %11535 = bitcast i8* %11534 to float*
  %11536 = load float, float* %11535, align 4
  %11537 = insertelement <4 x float> zeroinitializer, float %11536, i32 0
  %11538 = insertelement <4 x float> %11537, float 0.000000e+00, i32 1
  %11539 = insertelement <4 x float> %11538, float 0.000000e+00, i32 2
  %11540 = insertelement <4 x float> %11539, float 0.000000e+00, i32 3
  %11541 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11542 = getelementptr inbounds i8, i8* %11541, i64 20
  %11543 = bitcast i8* %11542 to float*
  %11544 = load float, float* %11543, align 4
  %11545 = insertelement <4 x float> zeroinitializer, float %11544, i32 0
  %11546 = insertelement <4 x float> %11545, float 0.000000e+00, i32 1
  %11547 = insertelement <4 x float> %11546, float 0.000000e+00, i32 2
  %11548 = insertelement <4 x float> %11547, float 0.000000e+00, i32 3
  %11549 = getelementptr inbounds float, float* %2, i64 4
  %11550 = load float, float* %11549, align 4
  %11551 = insertelement <4 x float> zeroinitializer, float %11550, i32 0
  %11552 = insertelement <4 x float> %11551, float 0.000000e+00, i32 1
  %11553 = insertelement <4 x float> %11552, float 0.000000e+00, i32 2
  %11554 = insertelement <4 x float> %11553, float 0.000000e+00, i32 3
  %11555 = call <4 x float> @llvm.fma.f32.301(<4 x float> %11548, <4 x float> %11554, <4 x float> %11540)
  %11556 = extractelement <4 x float> %11555, i32 0
  %11557 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11558 = getelementptr inbounds i8, i8* %11557, i64 16
  %11559 = bitcast i8* %11558 to float*
  store float %11556, float* %11559, align 4
  %11560 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11561 = getelementptr inbounds i8, i8* %11560, i64 16
  %11562 = bitcast i8* %11561 to float*
  %11563 = load float, float* %11562, align 4
  %11564 = insertelement <4 x float> zeroinitializer, float %11563, i32 0
  %11565 = insertelement <4 x float> %11564, float 0.000000e+00, i32 1
  %11566 = insertelement <4 x float> %11565, float 0.000000e+00, i32 2
  %11567 = insertelement <4 x float> %11566, float 0.000000e+00, i32 3
  %11568 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11569 = getelementptr inbounds i8, i8* %11568, i64 24
  %11570 = bitcast i8* %11569 to float*
  %11571 = load float, float* %11570, align 4
  %11572 = insertelement <4 x float> zeroinitializer, float %11571, i32 0
  %11573 = insertelement <4 x float> %11572, float 0.000000e+00, i32 1
  %11574 = insertelement <4 x float> %11573, float 0.000000e+00, i32 2
  %11575 = insertelement <4 x float> %11574, float 0.000000e+00, i32 3
  %11576 = getelementptr inbounds float, float* %2, i64 8
  %11577 = load float, float* %11576, align 4
  %11578 = insertelement <4 x float> zeroinitializer, float %11577, i32 0
  %11579 = insertelement <4 x float> %11578, float 0.000000e+00, i32 1
  %11580 = insertelement <4 x float> %11579, float 0.000000e+00, i32 2
  %11581 = insertelement <4 x float> %11580, float 0.000000e+00, i32 3
  %11582 = call <4 x float> @llvm.fma.f32.302(<4 x float> %11575, <4 x float> %11581, <4 x float> %11567)
  %11583 = extractelement <4 x float> %11582, i32 0
  %11584 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11585 = getelementptr inbounds i8, i8* %11584, i64 16
  %11586 = bitcast i8* %11585 to float*
  store float %11583, float* %11586, align 4
  %11587 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11588 = getelementptr inbounds i8, i8* %11587, i64 16
  %11589 = bitcast i8* %11588 to float*
  %11590 = load float, float* %11589, align 4
  %11591 = insertelement <4 x float> zeroinitializer, float %11590, i32 0
  %11592 = insertelement <4 x float> %11591, float 0.000000e+00, i32 1
  %11593 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11594 = getelementptr inbounds i8, i8* %11593, i64 20
  %11595 = bitcast i8* %11594 to float*
  %11596 = load float, float* %11595, align 4
  %11597 = insertelement <4 x float> %11592, float %11596, i32 2
  %11598 = insertelement <4 x float> %11597, float 0.000000e+00, i32 3
  %11599 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11600 = getelementptr inbounds i8, i8* %11599, i64 28
  %11601 = bitcast i8* %11600 to float*
  %11602 = load float, float* %11601, align 4
  %11603 = insertelement <4 x float> zeroinitializer, float %11602, i32 0
  %11604 = insertelement <4 x float> %11603, float 0.000000e+00, i32 1
  %11605 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11606 = getelementptr inbounds i8, i8* %11605, i64 16
  %11607 = bitcast i8* %11606 to float*
  %11608 = load float, float* %11607, align 4
  %11609 = insertelement <4 x float> %11604, float %11608, i32 2
  %11610 = insertelement <4 x float> %11609, float 0.000000e+00, i32 3
  %11611 = getelementptr inbounds float, float* %2, i64 12
  %11612 = load float, float* %11611, align 4
  %11613 = insertelement <4 x float> zeroinitializer, float %11612, i32 0
  %11614 = insertelement <4 x float> %11613, float 0.000000e+00, i32 1
  %11615 = getelementptr inbounds float, float* %2, i64 1
  %11616 = load float, float* %11615, align 4
  %11617 = insertelement <4 x float> %11614, float %11616, i32 2
  %11618 = insertelement <4 x float> %11617, float 0.000000e+00, i32 3
  %11619 = call <4 x float> @llvm.fma.f32.303(<4 x float> %11610, <4 x float> %11618, <4 x float> %11598)
  %11620 = extractelement <4 x float> %11619, i32 0
  %11621 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11622 = getelementptr inbounds i8, i8* %11621, i64 16
  %11623 = bitcast i8* %11622 to float*
  store float %11620, float* %11623, align 4
  %11624 = extractelement <4 x float> %11619, i32 1
  %11625 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11626 = getelementptr inbounds i8, i8* %11625, i64 20
  %11627 = bitcast i8* %11626 to float*
  store float %11624, float* %11627, align 4
  %11628 = extractelement <4 x float> %11619, i32 2
  %11629 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11630 = getelementptr inbounds i8, i8* %11629, i64 20
  %11631 = bitcast i8* %11630 to float*
  store float %11628, float* %11631, align 4
  %11632 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11633 = getelementptr inbounds i8, i8* %11632, i64 20
  %11634 = bitcast i8* %11633 to float*
  %11635 = load float, float* %11634, align 4
  %11636 = insertelement <4 x float> zeroinitializer, float %11635, i32 0
  %11637 = insertelement <4 x float> %11636, float 0.000000e+00, i32 1
  %11638 = insertelement <4 x float> %11637, float 0.000000e+00, i32 2
  %11639 = insertelement <4 x float> %11638, float 0.000000e+00, i32 3
  %11640 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11641 = getelementptr inbounds i8, i8* %11640, i64 20
  %11642 = bitcast i8* %11641 to float*
  %11643 = load float, float* %11642, align 4
  %11644 = insertelement <4 x float> zeroinitializer, float %11643, i32 0
  %11645 = insertelement <4 x float> %11644, float 0.000000e+00, i32 1
  %11646 = insertelement <4 x float> %11645, float 0.000000e+00, i32 2
  %11647 = insertelement <4 x float> %11646, float 0.000000e+00, i32 3
  %11648 = getelementptr inbounds float, float* %2, i64 5
  %11649 = load float, float* %11648, align 4
  %11650 = insertelement <4 x float> zeroinitializer, float %11649, i32 0
  %11651 = insertelement <4 x float> %11650, float 0.000000e+00, i32 1
  %11652 = insertelement <4 x float> %11651, float 0.000000e+00, i32 2
  %11653 = insertelement <4 x float> %11652, float 0.000000e+00, i32 3
  %11654 = call <4 x float> @llvm.fma.f32.304(<4 x float> %11647, <4 x float> %11653, <4 x float> %11639)
  %11655 = extractelement <4 x float> %11654, i32 0
  %11656 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11657 = getelementptr inbounds i8, i8* %11656, i64 20
  %11658 = bitcast i8* %11657 to float*
  store float %11655, float* %11658, align 4
  %11659 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11660 = getelementptr inbounds i8, i8* %11659, i64 20
  %11661 = bitcast i8* %11660 to float*
  %11662 = load float, float* %11661, align 4
  %11663 = insertelement <4 x float> zeroinitializer, float %11662, i32 0
  %11664 = insertelement <4 x float> %11663, float 0.000000e+00, i32 1
  %11665 = insertelement <4 x float> %11664, float 0.000000e+00, i32 2
  %11666 = insertelement <4 x float> %11665, float 0.000000e+00, i32 3
  %11667 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11668 = getelementptr inbounds i8, i8* %11667, i64 24
  %11669 = bitcast i8* %11668 to float*
  %11670 = load float, float* %11669, align 4
  %11671 = insertelement <4 x float> zeroinitializer, float %11670, i32 0
  %11672 = insertelement <4 x float> %11671, float 0.000000e+00, i32 1
  %11673 = insertelement <4 x float> %11672, float 0.000000e+00, i32 2
  %11674 = insertelement <4 x float> %11673, float 0.000000e+00, i32 3
  %11675 = getelementptr inbounds float, float* %2, i64 9
  %11676 = load float, float* %11675, align 4
  %11677 = insertelement <4 x float> zeroinitializer, float %11676, i32 0
  %11678 = insertelement <4 x float> %11677, float 0.000000e+00, i32 1
  %11679 = insertelement <4 x float> %11678, float 0.000000e+00, i32 2
  %11680 = insertelement <4 x float> %11679, float 0.000000e+00, i32 3
  %11681 = call <4 x float> @llvm.fma.f32.305(<4 x float> %11674, <4 x float> %11680, <4 x float> %11666)
  %11682 = extractelement <4 x float> %11681, i32 0
  %11683 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11684 = getelementptr inbounds i8, i8* %11683, i64 20
  %11685 = bitcast i8* %11684 to float*
  store float %11682, float* %11685, align 4
  %11686 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11687 = getelementptr inbounds i8, i8* %11686, i64 20
  %11688 = bitcast i8* %11687 to float*
  %11689 = load float, float* %11688, align 4
  %11690 = insertelement <4 x float> zeroinitializer, float %11689, i32 0
  %11691 = insertelement <4 x float> %11690, float 0.000000e+00, i32 1
  %11692 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11693 = getelementptr inbounds i8, i8* %11692, i64 24
  %11694 = bitcast i8* %11693 to float*
  %11695 = load float, float* %11694, align 4
  %11696 = insertelement <4 x float> %11691, float %11695, i32 2
  %11697 = insertelement <4 x float> %11696, float 0.000000e+00, i32 3
  %11698 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11699 = getelementptr inbounds i8, i8* %11698, i64 28
  %11700 = bitcast i8* %11699 to float*
  %11701 = load float, float* %11700, align 4
  %11702 = insertelement <4 x float> zeroinitializer, float %11701, i32 0
  %11703 = insertelement <4 x float> %11702, float 0.000000e+00, i32 1
  %11704 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11705 = getelementptr inbounds i8, i8* %11704, i64 16
  %11706 = bitcast i8* %11705 to float*
  %11707 = load float, float* %11706, align 4
  %11708 = insertelement <4 x float> %11703, float %11707, i32 2
  %11709 = insertelement <4 x float> %11708, float 0.000000e+00, i32 3
  %11710 = getelementptr inbounds float, float* %2, i64 13
  %11711 = load float, float* %11710, align 4
  %11712 = insertelement <4 x float> zeroinitializer, float %11711, i32 0
  %11713 = insertelement <4 x float> %11712, float 0.000000e+00, i32 1
  %11714 = getelementptr inbounds float, float* %2, i64 2
  %11715 = load float, float* %11714, align 4
  %11716 = insertelement <4 x float> %11713, float %11715, i32 2
  %11717 = insertelement <4 x float> %11716, float 0.000000e+00, i32 3
  %11718 = call <4 x float> @llvm.fma.f32.306(<4 x float> %11709, <4 x float> %11717, <4 x float> %11697)
  %11719 = extractelement <4 x float> %11718, i32 0
  %11720 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11721 = getelementptr inbounds i8, i8* %11720, i64 20
  %11722 = bitcast i8* %11721 to float*
  store float %11719, float* %11722, align 4
  %11723 = extractelement <4 x float> %11718, i32 1
  %11724 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11725 = getelementptr inbounds i8, i8* %11724, i64 24
  %11726 = bitcast i8* %11725 to float*
  store float %11723, float* %11726, align 4
  %11727 = extractelement <4 x float> %11718, i32 2
  %11728 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11729 = getelementptr inbounds i8, i8* %11728, i64 24
  %11730 = bitcast i8* %11729 to float*
  store float %11727, float* %11730, align 4
  %11731 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11732 = getelementptr inbounds i8, i8* %11731, i64 24
  %11733 = bitcast i8* %11732 to float*
  %11734 = load float, float* %11733, align 4
  %11735 = insertelement <4 x float> zeroinitializer, float %11734, i32 0
  %11736 = insertelement <4 x float> %11735, float 0.000000e+00, i32 1
  %11737 = insertelement <4 x float> %11736, float 0.000000e+00, i32 2
  %11738 = insertelement <4 x float> %11737, float 0.000000e+00, i32 3
  %11739 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11740 = getelementptr inbounds i8, i8* %11739, i64 20
  %11741 = bitcast i8* %11740 to float*
  %11742 = load float, float* %11741, align 4
  %11743 = insertelement <4 x float> zeroinitializer, float %11742, i32 0
  %11744 = insertelement <4 x float> %11743, float 0.000000e+00, i32 1
  %11745 = insertelement <4 x float> %11744, float 0.000000e+00, i32 2
  %11746 = insertelement <4 x float> %11745, float 0.000000e+00, i32 3
  %11747 = getelementptr inbounds float, float* %2, i64 6
  %11748 = load float, float* %11747, align 4
  %11749 = insertelement <4 x float> zeroinitializer, float %11748, i32 0
  %11750 = insertelement <4 x float> %11749, float 0.000000e+00, i32 1
  %11751 = insertelement <4 x float> %11750, float 0.000000e+00, i32 2
  %11752 = insertelement <4 x float> %11751, float 0.000000e+00, i32 3
  %11753 = call <4 x float> @llvm.fma.f32.307(<4 x float> %11746, <4 x float> %11752, <4 x float> %11738)
  %11754 = extractelement <4 x float> %11753, i32 0
  %11755 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11756 = getelementptr inbounds i8, i8* %11755, i64 24
  %11757 = bitcast i8* %11756 to float*
  store float %11754, float* %11757, align 4
  %11758 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11759 = getelementptr inbounds i8, i8* %11758, i64 24
  %11760 = bitcast i8* %11759 to float*
  %11761 = load float, float* %11760, align 4
  %11762 = insertelement <4 x float> zeroinitializer, float %11761, i32 0
  %11763 = insertelement <4 x float> %11762, float 0.000000e+00, i32 1
  %11764 = insertelement <4 x float> %11763, float 0.000000e+00, i32 2
  %11765 = insertelement <4 x float> %11764, float 0.000000e+00, i32 3
  %11766 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11767 = getelementptr inbounds i8, i8* %11766, i64 24
  %11768 = bitcast i8* %11767 to float*
  %11769 = load float, float* %11768, align 4
  %11770 = insertelement <4 x float> zeroinitializer, float %11769, i32 0
  %11771 = insertelement <4 x float> %11770, float 0.000000e+00, i32 1
  %11772 = insertelement <4 x float> %11771, float 0.000000e+00, i32 2
  %11773 = insertelement <4 x float> %11772, float 0.000000e+00, i32 3
  %11774 = getelementptr inbounds float, float* %2, i64 10
  %11775 = load float, float* %11774, align 4
  %11776 = insertelement <4 x float> zeroinitializer, float %11775, i32 0
  %11777 = insertelement <4 x float> %11776, float 0.000000e+00, i32 1
  %11778 = insertelement <4 x float> %11777, float 0.000000e+00, i32 2
  %11779 = insertelement <4 x float> %11778, float 0.000000e+00, i32 3
  %11780 = call <4 x float> @llvm.fma.f32.308(<4 x float> %11773, <4 x float> %11779, <4 x float> %11765)
  %11781 = extractelement <4 x float> %11780, i32 0
  %11782 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11783 = getelementptr inbounds i8, i8* %11782, i64 24
  %11784 = bitcast i8* %11783 to float*
  store float %11781, float* %11784, align 4
  %11785 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11786 = getelementptr inbounds i8, i8* %11785, i64 24
  %11787 = bitcast i8* %11786 to float*
  %11788 = load float, float* %11787, align 4
  %11789 = insertelement <4 x float> zeroinitializer, float %11788, i32 0
  %11790 = insertelement <4 x float> %11789, float 0.000000e+00, i32 1
  %11791 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11792 = getelementptr inbounds i8, i8* %11791, i64 28
  %11793 = bitcast i8* %11792 to float*
  %11794 = load float, float* %11793, align 4
  %11795 = insertelement <4 x float> %11790, float %11794, i32 2
  %11796 = insertelement <4 x float> %11795, float 0.000000e+00, i32 3
  %11797 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11798 = getelementptr inbounds i8, i8* %11797, i64 28
  %11799 = bitcast i8* %11798 to float*
  %11800 = load float, float* %11799, align 4
  %11801 = insertelement <4 x float> zeroinitializer, float %11800, i32 0
  %11802 = insertelement <4 x float> %11801, float 0.000000e+00, i32 1
  %11803 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11804 = getelementptr inbounds i8, i8* %11803, i64 16
  %11805 = bitcast i8* %11804 to float*
  %11806 = load float, float* %11805, align 4
  %11807 = insertelement <4 x float> %11802, float %11806, i32 2
  %11808 = insertelement <4 x float> %11807, float 0.000000e+00, i32 3
  %11809 = getelementptr inbounds float, float* %2, i64 14
  %11810 = load float, float* %11809, align 4
  %11811 = insertelement <4 x float> zeroinitializer, float %11810, i32 0
  %11812 = insertelement <4 x float> %11811, float 0.000000e+00, i32 1
  %11813 = getelementptr inbounds float, float* %2, i64 3
  %11814 = load float, float* %11813, align 4
  %11815 = insertelement <4 x float> %11812, float %11814, i32 2
  %11816 = insertelement <4 x float> %11815, float 0.000000e+00, i32 3
  %11817 = call <4 x float> @llvm.fma.f32.309(<4 x float> %11808, <4 x float> %11816, <4 x float> %11796)
  %11818 = extractelement <4 x float> %11817, i32 0
  %11819 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11820 = getelementptr inbounds i8, i8* %11819, i64 24
  %11821 = bitcast i8* %11820 to float*
  store float %11818, float* %11821, align 4
  %11822 = extractelement <4 x float> %11817, i32 1
  %11823 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11824 = getelementptr inbounds i8, i8* %11823, i64 28
  %11825 = bitcast i8* %11824 to float*
  store float %11822, float* %11825, align 4
  %11826 = extractelement <4 x float> %11817, i32 2
  %11827 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11828 = getelementptr inbounds i8, i8* %11827, i64 28
  %11829 = bitcast i8* %11828 to float*
  store float %11826, float* %11829, align 4
  %11830 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11831 = getelementptr inbounds i8, i8* %11830, i64 28
  %11832 = bitcast i8* %11831 to float*
  %11833 = load float, float* %11832, align 4
  %11834 = insertelement <4 x float> zeroinitializer, float %11833, i32 0
  %11835 = insertelement <4 x float> %11834, float 0.000000e+00, i32 1
  %11836 = insertelement <4 x float> %11835, float 0.000000e+00, i32 2
  %11837 = insertelement <4 x float> %11836, float 0.000000e+00, i32 3
  %11838 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11839 = getelementptr inbounds i8, i8* %11838, i64 20
  %11840 = bitcast i8* %11839 to float*
  %11841 = load float, float* %11840, align 4
  %11842 = insertelement <4 x float> zeroinitializer, float %11841, i32 0
  %11843 = insertelement <4 x float> %11842, float 0.000000e+00, i32 1
  %11844 = insertelement <4 x float> %11843, float 0.000000e+00, i32 2
  %11845 = insertelement <4 x float> %11844, float 0.000000e+00, i32 3
  %11846 = getelementptr inbounds float, float* %2, i64 7
  %11847 = load float, float* %11846, align 4
  %11848 = insertelement <4 x float> zeroinitializer, float %11847, i32 0
  %11849 = insertelement <4 x float> %11848, float 0.000000e+00, i32 1
  %11850 = insertelement <4 x float> %11849, float 0.000000e+00, i32 2
  %11851 = insertelement <4 x float> %11850, float 0.000000e+00, i32 3
  %11852 = call <4 x float> @llvm.fma.f32.310(<4 x float> %11845, <4 x float> %11851, <4 x float> %11837)
  %11853 = extractelement <4 x float> %11852, i32 0
  %11854 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11855 = getelementptr inbounds i8, i8* %11854, i64 28
  %11856 = bitcast i8* %11855 to float*
  store float %11853, float* %11856, align 4
  %11857 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11858 = getelementptr inbounds i8, i8* %11857, i64 28
  %11859 = bitcast i8* %11858 to float*
  %11860 = load float, float* %11859, align 4
  %11861 = insertelement <4 x float> zeroinitializer, float %11860, i32 0
  %11862 = insertelement <4 x float> %11861, float 0.000000e+00, i32 1
  %11863 = insertelement <4 x float> %11862, float 0.000000e+00, i32 2
  %11864 = insertelement <4 x float> %11863, float 0.000000e+00, i32 3
  %11865 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11866 = getelementptr inbounds i8, i8* %11865, i64 24
  %11867 = bitcast i8* %11866 to float*
  %11868 = load float, float* %11867, align 4
  %11869 = insertelement <4 x float> zeroinitializer, float %11868, i32 0
  %11870 = insertelement <4 x float> %11869, float 0.000000e+00, i32 1
  %11871 = insertelement <4 x float> %11870, float 0.000000e+00, i32 2
  %11872 = insertelement <4 x float> %11871, float 0.000000e+00, i32 3
  %11873 = getelementptr inbounds float, float* %2, i64 11
  %11874 = load float, float* %11873, align 4
  %11875 = insertelement <4 x float> zeroinitializer, float %11874, i32 0
  %11876 = insertelement <4 x float> %11875, float 0.000000e+00, i32 1
  %11877 = insertelement <4 x float> %11876, float 0.000000e+00, i32 2
  %11878 = insertelement <4 x float> %11877, float 0.000000e+00, i32 3
  %11879 = call <4 x float> @llvm.fma.f32.311(<4 x float> %11872, <4 x float> %11878, <4 x float> %11864)
  %11880 = extractelement <4 x float> %11879, i32 0
  %11881 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11882 = getelementptr inbounds i8, i8* %11881, i64 28
  %11883 = bitcast i8* %11882 to float*
  store float %11880, float* %11883, align 4
  %11884 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11885 = getelementptr inbounds i8, i8* %11884, i64 28
  %11886 = bitcast i8* %11885 to float*
  %11887 = load float, float* %11886, align 4
  %11888 = insertelement <4 x float> zeroinitializer, float %11887, i32 0
  %11889 = insertelement <4 x float> %11888, float 0.000000e+00, i32 1
  %11890 = insertelement <4 x float> %11889, float 0.000000e+00, i32 2
  %11891 = insertelement <4 x float> %11890, float 0.000000e+00, i32 3
  %11892 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11893 = getelementptr inbounds i8, i8* %11892, i64 28
  %11894 = bitcast i8* %11893 to float*
  %11895 = load float, float* %11894, align 4
  %11896 = insertelement <4 x float> zeroinitializer, float %11895, i32 0
  %11897 = insertelement <4 x float> %11896, float 0.000000e+00, i32 1
  %11898 = insertelement <4 x float> %11897, float 0.000000e+00, i32 2
  %11899 = insertelement <4 x float> %11898, float 0.000000e+00, i32 3
  %11900 = getelementptr inbounds float, float* %2, i64 15
  %11901 = load float, float* %11900, align 4
  %11902 = insertelement <4 x float> zeroinitializer, float %11901, i32 0
  %11903 = insertelement <4 x float> %11902, float 0.000000e+00, i32 1
  %11904 = insertelement <4 x float> %11903, float 0.000000e+00, i32 2
  %11905 = insertelement <4 x float> %11904, float 0.000000e+00, i32 3
  %11906 = call <4 x float> @llvm.fma.f32.312(<4 x float> %11899, <4 x float> %11905, <4 x float> %11891)
  %11907 = extractelement <4 x float> %11906, i32 0
  %11908 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11909 = getelementptr inbounds i8, i8* %11908, i64 28
  %11910 = bitcast i8* %11909 to float*
  store float %11907, float* %11910, align 4
  %11911 = extractelement <4 x float> %11906, i32 1
  %11912 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11913 = getelementptr inbounds i8, i8* %11912, i64 32
  %11914 = bitcast i8* %11913 to float*
  store float %11911, float* %11914, align 4
  %11915 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11916 = getelementptr inbounds i8, i8* %11915, i64 32
  %11917 = bitcast i8* %11916 to float*
  %11918 = load float, float* %11917, align 4
  %11919 = insertelement <4 x float> zeroinitializer, float %11918, i32 0
  %11920 = insertelement <4 x float> %11919, float 0.000000e+00, i32 1
  %11921 = insertelement <4 x float> %11920, float 0.000000e+00, i32 2
  %11922 = insertelement <4 x float> %11921, float 0.000000e+00, i32 3
  %11923 = load float, float* %2, align 4
  %11924 = insertelement <4 x float> zeroinitializer, float %11923, i32 0
  %11925 = insertelement <4 x float> %11924, float 0.000000e+00, i32 1
  %11926 = insertelement <4 x float> %11925, float 0.000000e+00, i32 2
  %11927 = insertelement <4 x float> %11926, float 0.000000e+00, i32 3
  %11928 = call <4 x float> @llvm.fma.f32.313(<4 x float> %11922, <4 x float> %11927, <4 x float> zeroinitializer)
  %11929 = extractelement <4 x float> %11928, i32 0
  %11930 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11931 = getelementptr inbounds i8, i8* %11930, i64 32
  %11932 = bitcast i8* %11931 to float*
  store float %11929, float* %11932, align 4
  %11933 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11934 = getelementptr inbounds i8, i8* %11933, i64 32
  %11935 = bitcast i8* %11934 to float*
  %11936 = load float, float* %11935, align 4
  %11937 = insertelement <4 x float> zeroinitializer, float %11936, i32 0
  %11938 = insertelement <4 x float> %11937, float 0.000000e+00, i32 1
  %11939 = insertelement <4 x float> %11938, float 0.000000e+00, i32 2
  %11940 = insertelement <4 x float> %11939, float 0.000000e+00, i32 3
  %11941 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11942 = getelementptr inbounds i8, i8* %11941, i64 36
  %11943 = bitcast i8* %11942 to float*
  %11944 = load float, float* %11943, align 4
  %11945 = insertelement <4 x float> zeroinitializer, float %11944, i32 0
  %11946 = insertelement <4 x float> %11945, float 0.000000e+00, i32 1
  %11947 = insertelement <4 x float> %11946, float 0.000000e+00, i32 2
  %11948 = insertelement <4 x float> %11947, float 0.000000e+00, i32 3
  %11949 = getelementptr inbounds float, float* %2, i64 4
  %11950 = load float, float* %11949, align 4
  %11951 = insertelement <4 x float> zeroinitializer, float %11950, i32 0
  %11952 = insertelement <4 x float> %11951, float 0.000000e+00, i32 1
  %11953 = insertelement <4 x float> %11952, float 0.000000e+00, i32 2
  %11954 = insertelement <4 x float> %11953, float 0.000000e+00, i32 3
  %11955 = call <4 x float> @llvm.fma.f32.314(<4 x float> %11948, <4 x float> %11954, <4 x float> %11940)
  %11956 = extractelement <4 x float> %11955, i32 0
  %11957 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11958 = getelementptr inbounds i8, i8* %11957, i64 32
  %11959 = bitcast i8* %11958 to float*
  store float %11956, float* %11959, align 4
  %11960 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11961 = getelementptr inbounds i8, i8* %11960, i64 32
  %11962 = bitcast i8* %11961 to float*
  %11963 = load float, float* %11962, align 4
  %11964 = insertelement <4 x float> zeroinitializer, float %11963, i32 0
  %11965 = insertelement <4 x float> %11964, float 0.000000e+00, i32 1
  %11966 = insertelement <4 x float> %11965, float 0.000000e+00, i32 2
  %11967 = insertelement <4 x float> %11966, float 0.000000e+00, i32 3
  %11968 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11969 = getelementptr inbounds i8, i8* %11968, i64 40
  %11970 = bitcast i8* %11969 to float*
  %11971 = load float, float* %11970, align 4
  %11972 = insertelement <4 x float> zeroinitializer, float %11971, i32 0
  %11973 = insertelement <4 x float> %11972, float 0.000000e+00, i32 1
  %11974 = insertelement <4 x float> %11973, float 0.000000e+00, i32 2
  %11975 = insertelement <4 x float> %11974, float 0.000000e+00, i32 3
  %11976 = getelementptr inbounds float, float* %2, i64 8
  %11977 = load float, float* %11976, align 4
  %11978 = insertelement <4 x float> zeroinitializer, float %11977, i32 0
  %11979 = insertelement <4 x float> %11978, float 0.000000e+00, i32 1
  %11980 = insertelement <4 x float> %11979, float 0.000000e+00, i32 2
  %11981 = insertelement <4 x float> %11980, float 0.000000e+00, i32 3
  %11982 = call <4 x float> @llvm.fma.f32.315(<4 x float> %11975, <4 x float> %11981, <4 x float> %11967)
  %11983 = extractelement <4 x float> %11982, i32 0
  %11984 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11985 = getelementptr inbounds i8, i8* %11984, i64 32
  %11986 = bitcast i8* %11985 to float*
  store float %11983, float* %11986, align 4
  %11987 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11988 = getelementptr inbounds i8, i8* %11987, i64 32
  %11989 = bitcast i8* %11988 to float*
  %11990 = load float, float* %11989, align 4
  %11991 = insertelement <4 x float> zeroinitializer, float %11990, i32 0
  %11992 = insertelement <4 x float> %11991, float 0.000000e+00, i32 1
  %11993 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %11994 = getelementptr inbounds i8, i8* %11993, i64 36
  %11995 = bitcast i8* %11994 to float*
  %11996 = load float, float* %11995, align 4
  %11997 = insertelement <4 x float> %11992, float %11996, i32 2
  %11998 = insertelement <4 x float> %11997, float 0.000000e+00, i32 3
  %11999 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12000 = getelementptr inbounds i8, i8* %11999, i64 44
  %12001 = bitcast i8* %12000 to float*
  %12002 = load float, float* %12001, align 4
  %12003 = insertelement <4 x float> zeroinitializer, float %12002, i32 0
  %12004 = insertelement <4 x float> %12003, float 0.000000e+00, i32 1
  %12005 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12006 = getelementptr inbounds i8, i8* %12005, i64 32
  %12007 = bitcast i8* %12006 to float*
  %12008 = load float, float* %12007, align 4
  %12009 = insertelement <4 x float> %12004, float %12008, i32 2
  %12010 = insertelement <4 x float> %12009, float 0.000000e+00, i32 3
  %12011 = getelementptr inbounds float, float* %2, i64 12
  %12012 = load float, float* %12011, align 4
  %12013 = insertelement <4 x float> zeroinitializer, float %12012, i32 0
  %12014 = insertelement <4 x float> %12013, float 0.000000e+00, i32 1
  %12015 = getelementptr inbounds float, float* %2, i64 1
  %12016 = load float, float* %12015, align 4
  %12017 = insertelement <4 x float> %12014, float %12016, i32 2
  %12018 = insertelement <4 x float> %12017, float 0.000000e+00, i32 3
  %12019 = call <4 x float> @llvm.fma.f32.316(<4 x float> %12010, <4 x float> %12018, <4 x float> %11998)
  %12020 = extractelement <4 x float> %12019, i32 0
  %12021 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12022 = getelementptr inbounds i8, i8* %12021, i64 32
  %12023 = bitcast i8* %12022 to float*
  store float %12020, float* %12023, align 4
  %12024 = extractelement <4 x float> %12019, i32 1
  %12025 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12026 = getelementptr inbounds i8, i8* %12025, i64 36
  %12027 = bitcast i8* %12026 to float*
  store float %12024, float* %12027, align 4
  %12028 = extractelement <4 x float> %12019, i32 2
  %12029 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12030 = getelementptr inbounds i8, i8* %12029, i64 36
  %12031 = bitcast i8* %12030 to float*
  store float %12028, float* %12031, align 4
  %12032 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12033 = getelementptr inbounds i8, i8* %12032, i64 36
  %12034 = bitcast i8* %12033 to float*
  %12035 = load float, float* %12034, align 4
  %12036 = insertelement <4 x float> zeroinitializer, float %12035, i32 0
  %12037 = insertelement <4 x float> %12036, float 0.000000e+00, i32 1
  %12038 = insertelement <4 x float> %12037, float 0.000000e+00, i32 2
  %12039 = insertelement <4 x float> %12038, float 0.000000e+00, i32 3
  %12040 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12041 = getelementptr inbounds i8, i8* %12040, i64 36
  %12042 = bitcast i8* %12041 to float*
  %12043 = load float, float* %12042, align 4
  %12044 = insertelement <4 x float> zeroinitializer, float %12043, i32 0
  %12045 = insertelement <4 x float> %12044, float 0.000000e+00, i32 1
  %12046 = insertelement <4 x float> %12045, float 0.000000e+00, i32 2
  %12047 = insertelement <4 x float> %12046, float 0.000000e+00, i32 3
  %12048 = getelementptr inbounds float, float* %2, i64 5
  %12049 = load float, float* %12048, align 4
  %12050 = insertelement <4 x float> zeroinitializer, float %12049, i32 0
  %12051 = insertelement <4 x float> %12050, float 0.000000e+00, i32 1
  %12052 = insertelement <4 x float> %12051, float 0.000000e+00, i32 2
  %12053 = insertelement <4 x float> %12052, float 0.000000e+00, i32 3
  %12054 = call <4 x float> @llvm.fma.f32.317(<4 x float> %12047, <4 x float> %12053, <4 x float> %12039)
  %12055 = extractelement <4 x float> %12054, i32 0
  %12056 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12057 = getelementptr inbounds i8, i8* %12056, i64 36
  %12058 = bitcast i8* %12057 to float*
  store float %12055, float* %12058, align 4
  %12059 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12060 = getelementptr inbounds i8, i8* %12059, i64 36
  %12061 = bitcast i8* %12060 to float*
  %12062 = load float, float* %12061, align 4
  %12063 = insertelement <4 x float> zeroinitializer, float %12062, i32 0
  %12064 = insertelement <4 x float> %12063, float 0.000000e+00, i32 1
  %12065 = insertelement <4 x float> %12064, float 0.000000e+00, i32 2
  %12066 = insertelement <4 x float> %12065, float 0.000000e+00, i32 3
  %12067 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12068 = getelementptr inbounds i8, i8* %12067, i64 40
  %12069 = bitcast i8* %12068 to float*
  %12070 = load float, float* %12069, align 4
  %12071 = insertelement <4 x float> zeroinitializer, float %12070, i32 0
  %12072 = insertelement <4 x float> %12071, float 0.000000e+00, i32 1
  %12073 = insertelement <4 x float> %12072, float 0.000000e+00, i32 2
  %12074 = insertelement <4 x float> %12073, float 0.000000e+00, i32 3
  %12075 = getelementptr inbounds float, float* %2, i64 9
  %12076 = load float, float* %12075, align 4
  %12077 = insertelement <4 x float> zeroinitializer, float %12076, i32 0
  %12078 = insertelement <4 x float> %12077, float 0.000000e+00, i32 1
  %12079 = insertelement <4 x float> %12078, float 0.000000e+00, i32 2
  %12080 = insertelement <4 x float> %12079, float 0.000000e+00, i32 3
  %12081 = call <4 x float> @llvm.fma.f32.318(<4 x float> %12074, <4 x float> %12080, <4 x float> %12066)
  %12082 = extractelement <4 x float> %12081, i32 0
  %12083 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12084 = getelementptr inbounds i8, i8* %12083, i64 36
  %12085 = bitcast i8* %12084 to float*
  store float %12082, float* %12085, align 4
  %12086 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12087 = getelementptr inbounds i8, i8* %12086, i64 36
  %12088 = bitcast i8* %12087 to float*
  %12089 = load float, float* %12088, align 4
  %12090 = insertelement <4 x float> zeroinitializer, float %12089, i32 0
  %12091 = insertelement <4 x float> %12090, float 0.000000e+00, i32 1
  %12092 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12093 = getelementptr inbounds i8, i8* %12092, i64 40
  %12094 = bitcast i8* %12093 to float*
  %12095 = load float, float* %12094, align 4
  %12096 = insertelement <4 x float> %12091, float %12095, i32 2
  %12097 = insertelement <4 x float> %12096, float 0.000000e+00, i32 3
  %12098 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12099 = getelementptr inbounds i8, i8* %12098, i64 44
  %12100 = bitcast i8* %12099 to float*
  %12101 = load float, float* %12100, align 4
  %12102 = insertelement <4 x float> zeroinitializer, float %12101, i32 0
  %12103 = insertelement <4 x float> %12102, float 0.000000e+00, i32 1
  %12104 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12105 = getelementptr inbounds i8, i8* %12104, i64 32
  %12106 = bitcast i8* %12105 to float*
  %12107 = load float, float* %12106, align 4
  %12108 = insertelement <4 x float> %12103, float %12107, i32 2
  %12109 = insertelement <4 x float> %12108, float 0.000000e+00, i32 3
  %12110 = getelementptr inbounds float, float* %2, i64 13
  %12111 = load float, float* %12110, align 4
  %12112 = insertelement <4 x float> zeroinitializer, float %12111, i32 0
  %12113 = insertelement <4 x float> %12112, float 0.000000e+00, i32 1
  %12114 = getelementptr inbounds float, float* %2, i64 2
  %12115 = load float, float* %12114, align 4
  %12116 = insertelement <4 x float> %12113, float %12115, i32 2
  %12117 = insertelement <4 x float> %12116, float 0.000000e+00, i32 3
  %12118 = call <4 x float> @llvm.fma.f32.319(<4 x float> %12109, <4 x float> %12117, <4 x float> %12097)
  %12119 = extractelement <4 x float> %12118, i32 0
  %12120 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12121 = getelementptr inbounds i8, i8* %12120, i64 36
  %12122 = bitcast i8* %12121 to float*
  store float %12119, float* %12122, align 4
  %12123 = extractelement <4 x float> %12118, i32 1
  %12124 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12125 = getelementptr inbounds i8, i8* %12124, i64 40
  %12126 = bitcast i8* %12125 to float*
  store float %12123, float* %12126, align 4
  %12127 = extractelement <4 x float> %12118, i32 2
  %12128 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12129 = getelementptr inbounds i8, i8* %12128, i64 40
  %12130 = bitcast i8* %12129 to float*
  store float %12127, float* %12130, align 4
  %12131 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12132 = getelementptr inbounds i8, i8* %12131, i64 40
  %12133 = bitcast i8* %12132 to float*
  %12134 = load float, float* %12133, align 4
  %12135 = insertelement <4 x float> zeroinitializer, float %12134, i32 0
  %12136 = insertelement <4 x float> %12135, float 0.000000e+00, i32 1
  %12137 = insertelement <4 x float> %12136, float 0.000000e+00, i32 2
  %12138 = insertelement <4 x float> %12137, float 0.000000e+00, i32 3
  %12139 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12140 = getelementptr inbounds i8, i8* %12139, i64 36
  %12141 = bitcast i8* %12140 to float*
  %12142 = load float, float* %12141, align 4
  %12143 = insertelement <4 x float> zeroinitializer, float %12142, i32 0
  %12144 = insertelement <4 x float> %12143, float 0.000000e+00, i32 1
  %12145 = insertelement <4 x float> %12144, float 0.000000e+00, i32 2
  %12146 = insertelement <4 x float> %12145, float 0.000000e+00, i32 3
  %12147 = getelementptr inbounds float, float* %2, i64 6
  %12148 = load float, float* %12147, align 4
  %12149 = insertelement <4 x float> zeroinitializer, float %12148, i32 0
  %12150 = insertelement <4 x float> %12149, float 0.000000e+00, i32 1
  %12151 = insertelement <4 x float> %12150, float 0.000000e+00, i32 2
  %12152 = insertelement <4 x float> %12151, float 0.000000e+00, i32 3
  %12153 = call <4 x float> @llvm.fma.f32.320(<4 x float> %12146, <4 x float> %12152, <4 x float> %12138)
  %12154 = extractelement <4 x float> %12153, i32 0
  %12155 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12156 = getelementptr inbounds i8, i8* %12155, i64 40
  %12157 = bitcast i8* %12156 to float*
  store float %12154, float* %12157, align 4
  %12158 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12159 = getelementptr inbounds i8, i8* %12158, i64 40
  %12160 = bitcast i8* %12159 to float*
  %12161 = load float, float* %12160, align 4
  %12162 = insertelement <4 x float> zeroinitializer, float %12161, i32 0
  %12163 = insertelement <4 x float> %12162, float 0.000000e+00, i32 1
  %12164 = insertelement <4 x float> %12163, float 0.000000e+00, i32 2
  %12165 = insertelement <4 x float> %12164, float 0.000000e+00, i32 3
  %12166 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12167 = getelementptr inbounds i8, i8* %12166, i64 40
  %12168 = bitcast i8* %12167 to float*
  %12169 = load float, float* %12168, align 4
  %12170 = insertelement <4 x float> zeroinitializer, float %12169, i32 0
  %12171 = insertelement <4 x float> %12170, float 0.000000e+00, i32 1
  %12172 = insertelement <4 x float> %12171, float 0.000000e+00, i32 2
  %12173 = insertelement <4 x float> %12172, float 0.000000e+00, i32 3
  %12174 = getelementptr inbounds float, float* %2, i64 10
  %12175 = load float, float* %12174, align 4
  %12176 = insertelement <4 x float> zeroinitializer, float %12175, i32 0
  %12177 = insertelement <4 x float> %12176, float 0.000000e+00, i32 1
  %12178 = insertelement <4 x float> %12177, float 0.000000e+00, i32 2
  %12179 = insertelement <4 x float> %12178, float 0.000000e+00, i32 3
  %12180 = call <4 x float> @llvm.fma.f32.321(<4 x float> %12173, <4 x float> %12179, <4 x float> %12165)
  %12181 = extractelement <4 x float> %12180, i32 0
  %12182 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12183 = getelementptr inbounds i8, i8* %12182, i64 40
  %12184 = bitcast i8* %12183 to float*
  store float %12181, float* %12184, align 4
  %12185 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12186 = getelementptr inbounds i8, i8* %12185, i64 40
  %12187 = bitcast i8* %12186 to float*
  %12188 = load float, float* %12187, align 4
  %12189 = insertelement <4 x float> zeroinitializer, float %12188, i32 0
  %12190 = insertelement <4 x float> %12189, float 0.000000e+00, i32 1
  %12191 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12192 = getelementptr inbounds i8, i8* %12191, i64 44
  %12193 = bitcast i8* %12192 to float*
  %12194 = load float, float* %12193, align 4
  %12195 = insertelement <4 x float> %12190, float %12194, i32 2
  %12196 = insertelement <4 x float> %12195, float 0.000000e+00, i32 3
  %12197 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12198 = getelementptr inbounds i8, i8* %12197, i64 44
  %12199 = bitcast i8* %12198 to float*
  %12200 = load float, float* %12199, align 4
  %12201 = insertelement <4 x float> zeroinitializer, float %12200, i32 0
  %12202 = insertelement <4 x float> %12201, float 0.000000e+00, i32 1
  %12203 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12204 = getelementptr inbounds i8, i8* %12203, i64 32
  %12205 = bitcast i8* %12204 to float*
  %12206 = load float, float* %12205, align 4
  %12207 = insertelement <4 x float> %12202, float %12206, i32 2
  %12208 = insertelement <4 x float> %12207, float 0.000000e+00, i32 3
  %12209 = getelementptr inbounds float, float* %2, i64 14
  %12210 = load float, float* %12209, align 4
  %12211 = insertelement <4 x float> zeroinitializer, float %12210, i32 0
  %12212 = insertelement <4 x float> %12211, float 0.000000e+00, i32 1
  %12213 = getelementptr inbounds float, float* %2, i64 3
  %12214 = load float, float* %12213, align 4
  %12215 = insertelement <4 x float> %12212, float %12214, i32 2
  %12216 = insertelement <4 x float> %12215, float 0.000000e+00, i32 3
  %12217 = call <4 x float> @llvm.fma.f32.322(<4 x float> %12208, <4 x float> %12216, <4 x float> %12196)
  %12218 = extractelement <4 x float> %12217, i32 0
  %12219 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12220 = getelementptr inbounds i8, i8* %12219, i64 40
  %12221 = bitcast i8* %12220 to float*
  store float %12218, float* %12221, align 4
  %12222 = extractelement <4 x float> %12217, i32 1
  %12223 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12224 = getelementptr inbounds i8, i8* %12223, i64 44
  %12225 = bitcast i8* %12224 to float*
  store float %12222, float* %12225, align 4
  %12226 = extractelement <4 x float> %12217, i32 2
  %12227 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12228 = getelementptr inbounds i8, i8* %12227, i64 44
  %12229 = bitcast i8* %12228 to float*
  store float %12226, float* %12229, align 4
  %12230 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12231 = getelementptr inbounds i8, i8* %12230, i64 44
  %12232 = bitcast i8* %12231 to float*
  %12233 = load float, float* %12232, align 4
  %12234 = insertelement <4 x float> zeroinitializer, float %12233, i32 0
  %12235 = insertelement <4 x float> %12234, float 0.000000e+00, i32 1
  %12236 = insertelement <4 x float> %12235, float 0.000000e+00, i32 2
  %12237 = insertelement <4 x float> %12236, float 0.000000e+00, i32 3
  %12238 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12239 = getelementptr inbounds i8, i8* %12238, i64 36
  %12240 = bitcast i8* %12239 to float*
  %12241 = load float, float* %12240, align 4
  %12242 = insertelement <4 x float> zeroinitializer, float %12241, i32 0
  %12243 = insertelement <4 x float> %12242, float 0.000000e+00, i32 1
  %12244 = insertelement <4 x float> %12243, float 0.000000e+00, i32 2
  %12245 = insertelement <4 x float> %12244, float 0.000000e+00, i32 3
  %12246 = getelementptr inbounds float, float* %2, i64 7
  %12247 = load float, float* %12246, align 4
  %12248 = insertelement <4 x float> zeroinitializer, float %12247, i32 0
  %12249 = insertelement <4 x float> %12248, float 0.000000e+00, i32 1
  %12250 = insertelement <4 x float> %12249, float 0.000000e+00, i32 2
  %12251 = insertelement <4 x float> %12250, float 0.000000e+00, i32 3
  %12252 = call <4 x float> @llvm.fma.f32.323(<4 x float> %12245, <4 x float> %12251, <4 x float> %12237)
  %12253 = extractelement <4 x float> %12252, i32 0
  %12254 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12255 = getelementptr inbounds i8, i8* %12254, i64 44
  %12256 = bitcast i8* %12255 to float*
  store float %12253, float* %12256, align 4
  %12257 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12258 = getelementptr inbounds i8, i8* %12257, i64 44
  %12259 = bitcast i8* %12258 to float*
  %12260 = load float, float* %12259, align 4
  %12261 = insertelement <4 x float> zeroinitializer, float %12260, i32 0
  %12262 = insertelement <4 x float> %12261, float 0.000000e+00, i32 1
  %12263 = insertelement <4 x float> %12262, float 0.000000e+00, i32 2
  %12264 = insertelement <4 x float> %12263, float 0.000000e+00, i32 3
  %12265 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12266 = getelementptr inbounds i8, i8* %12265, i64 40
  %12267 = bitcast i8* %12266 to float*
  %12268 = load float, float* %12267, align 4
  %12269 = insertelement <4 x float> zeroinitializer, float %12268, i32 0
  %12270 = insertelement <4 x float> %12269, float 0.000000e+00, i32 1
  %12271 = insertelement <4 x float> %12270, float 0.000000e+00, i32 2
  %12272 = insertelement <4 x float> %12271, float 0.000000e+00, i32 3
  %12273 = getelementptr inbounds float, float* %2, i64 11
  %12274 = load float, float* %12273, align 4
  %12275 = insertelement <4 x float> zeroinitializer, float %12274, i32 0
  %12276 = insertelement <4 x float> %12275, float 0.000000e+00, i32 1
  %12277 = insertelement <4 x float> %12276, float 0.000000e+00, i32 2
  %12278 = insertelement <4 x float> %12277, float 0.000000e+00, i32 3
  %12279 = call <4 x float> @llvm.fma.f32.324(<4 x float> %12272, <4 x float> %12278, <4 x float> %12264)
  %12280 = extractelement <4 x float> %12279, i32 0
  %12281 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12282 = getelementptr inbounds i8, i8* %12281, i64 44
  %12283 = bitcast i8* %12282 to float*
  store float %12280, float* %12283, align 4
  %12284 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12285 = getelementptr inbounds i8, i8* %12284, i64 44
  %12286 = bitcast i8* %12285 to float*
  %12287 = load float, float* %12286, align 4
  %12288 = insertelement <4 x float> zeroinitializer, float %12287, i32 0
  %12289 = insertelement <4 x float> %12288, float 0.000000e+00, i32 1
  %12290 = insertelement <4 x float> %12289, float 0.000000e+00, i32 2
  %12291 = insertelement <4 x float> %12290, float 0.000000e+00, i32 3
  %12292 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12293 = getelementptr inbounds i8, i8* %12292, i64 44
  %12294 = bitcast i8* %12293 to float*
  %12295 = load float, float* %12294, align 4
  %12296 = insertelement <4 x float> zeroinitializer, float %12295, i32 0
  %12297 = insertelement <4 x float> %12296, float 0.000000e+00, i32 1
  %12298 = insertelement <4 x float> %12297, float 0.000000e+00, i32 2
  %12299 = insertelement <4 x float> %12298, float 0.000000e+00, i32 3
  %12300 = getelementptr inbounds float, float* %2, i64 15
  %12301 = load float, float* %12300, align 4
  %12302 = insertelement <4 x float> zeroinitializer, float %12301, i32 0
  %12303 = insertelement <4 x float> %12302, float 0.000000e+00, i32 1
  %12304 = insertelement <4 x float> %12303, float 0.000000e+00, i32 2
  %12305 = insertelement <4 x float> %12304, float 0.000000e+00, i32 3
  %12306 = call <4 x float> @llvm.fma.f32.325(<4 x float> %12299, <4 x float> %12305, <4 x float> %12291)
  %12307 = extractelement <4 x float> %12306, i32 0
  %12308 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12309 = getelementptr inbounds i8, i8* %12308, i64 44
  %12310 = bitcast i8* %12309 to float*
  store float %12307, float* %12310, align 4
  %12311 = extractelement <4 x float> %12306, i32 1
  %12312 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12313 = getelementptr inbounds i8, i8* %12312, i64 48
  %12314 = bitcast i8* %12313 to float*
  store float %12311, float* %12314, align 4
  %12315 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12316 = getelementptr inbounds i8, i8* %12315, i64 48
  %12317 = bitcast i8* %12316 to float*
  %12318 = load float, float* %12317, align 4
  %12319 = insertelement <4 x float> zeroinitializer, float %12318, i32 0
  %12320 = insertelement <4 x float> %12319, float 0.000000e+00, i32 1
  %12321 = insertelement <4 x float> %12320, float 0.000000e+00, i32 2
  %12322 = insertelement <4 x float> %12321, float 0.000000e+00, i32 3
  %12323 = load float, float* %2, align 4
  %12324 = insertelement <4 x float> zeroinitializer, float %12323, i32 0
  %12325 = insertelement <4 x float> %12324, float 0.000000e+00, i32 1
  %12326 = insertelement <4 x float> %12325, float 0.000000e+00, i32 2
  %12327 = insertelement <4 x float> %12326, float 0.000000e+00, i32 3
  %12328 = call <4 x float> @llvm.fma.f32.326(<4 x float> %12322, <4 x float> %12327, <4 x float> zeroinitializer)
  %12329 = extractelement <4 x float> %12328, i32 0
  %12330 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12331 = getelementptr inbounds i8, i8* %12330, i64 48
  %12332 = bitcast i8* %12331 to float*
  store float %12329, float* %12332, align 4
  %12333 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12334 = getelementptr inbounds i8, i8* %12333, i64 48
  %12335 = bitcast i8* %12334 to float*
  %12336 = load float, float* %12335, align 4
  %12337 = insertelement <4 x float> zeroinitializer, float %12336, i32 0
  %12338 = insertelement <4 x float> %12337, float 0.000000e+00, i32 1
  %12339 = insertelement <4 x float> %12338, float 0.000000e+00, i32 2
  %12340 = insertelement <4 x float> %12339, float 0.000000e+00, i32 3
  %12341 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12342 = getelementptr inbounds i8, i8* %12341, i64 52
  %12343 = bitcast i8* %12342 to float*
  %12344 = load float, float* %12343, align 4
  %12345 = insertelement <4 x float> zeroinitializer, float %12344, i32 0
  %12346 = insertelement <4 x float> %12345, float 0.000000e+00, i32 1
  %12347 = insertelement <4 x float> %12346, float 0.000000e+00, i32 2
  %12348 = insertelement <4 x float> %12347, float 0.000000e+00, i32 3
  %12349 = getelementptr inbounds float, float* %2, i64 4
  %12350 = load float, float* %12349, align 4
  %12351 = insertelement <4 x float> zeroinitializer, float %12350, i32 0
  %12352 = insertelement <4 x float> %12351, float 0.000000e+00, i32 1
  %12353 = insertelement <4 x float> %12352, float 0.000000e+00, i32 2
  %12354 = insertelement <4 x float> %12353, float 0.000000e+00, i32 3
  %12355 = call <4 x float> @llvm.fma.f32.327(<4 x float> %12348, <4 x float> %12354, <4 x float> %12340)
  %12356 = extractelement <4 x float> %12355, i32 0
  %12357 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12358 = getelementptr inbounds i8, i8* %12357, i64 48
  %12359 = bitcast i8* %12358 to float*
  store float %12356, float* %12359, align 4
  %12360 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12361 = getelementptr inbounds i8, i8* %12360, i64 48
  %12362 = bitcast i8* %12361 to float*
  %12363 = load float, float* %12362, align 4
  %12364 = insertelement <4 x float> zeroinitializer, float %12363, i32 0
  %12365 = insertelement <4 x float> %12364, float 0.000000e+00, i32 1
  %12366 = insertelement <4 x float> %12365, float 0.000000e+00, i32 2
  %12367 = insertelement <4 x float> %12366, float 0.000000e+00, i32 3
  %12368 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12369 = getelementptr inbounds i8, i8* %12368, i64 56
  %12370 = bitcast i8* %12369 to float*
  %12371 = load float, float* %12370, align 4
  %12372 = insertelement <4 x float> zeroinitializer, float %12371, i32 0
  %12373 = insertelement <4 x float> %12372, float 0.000000e+00, i32 1
  %12374 = insertelement <4 x float> %12373, float 0.000000e+00, i32 2
  %12375 = insertelement <4 x float> %12374, float 0.000000e+00, i32 3
  %12376 = getelementptr inbounds float, float* %2, i64 8
  %12377 = load float, float* %12376, align 4
  %12378 = insertelement <4 x float> zeroinitializer, float %12377, i32 0
  %12379 = insertelement <4 x float> %12378, float 0.000000e+00, i32 1
  %12380 = insertelement <4 x float> %12379, float 0.000000e+00, i32 2
  %12381 = insertelement <4 x float> %12380, float 0.000000e+00, i32 3
  %12382 = call <4 x float> @llvm.fma.f32.328(<4 x float> %12375, <4 x float> %12381, <4 x float> %12367)
  %12383 = extractelement <4 x float> %12382, i32 0
  %12384 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12385 = getelementptr inbounds i8, i8* %12384, i64 48
  %12386 = bitcast i8* %12385 to float*
  store float %12383, float* %12386, align 4
  %12387 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12388 = getelementptr inbounds i8, i8* %12387, i64 48
  %12389 = bitcast i8* %12388 to float*
  %12390 = load float, float* %12389, align 4
  %12391 = insertelement <4 x float> zeroinitializer, float %12390, i32 0
  %12392 = insertelement <4 x float> %12391, float 0.000000e+00, i32 1
  %12393 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12394 = getelementptr inbounds i8, i8* %12393, i64 52
  %12395 = bitcast i8* %12394 to float*
  %12396 = load float, float* %12395, align 4
  %12397 = insertelement <4 x float> %12392, float %12396, i32 2
  %12398 = insertelement <4 x float> %12397, float 0.000000e+00, i32 3
  %12399 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12400 = getelementptr inbounds i8, i8* %12399, i64 60
  %12401 = bitcast i8* %12400 to float*
  %12402 = load float, float* %12401, align 4
  %12403 = insertelement <4 x float> zeroinitializer, float %12402, i32 0
  %12404 = insertelement <4 x float> %12403, float 0.000000e+00, i32 1
  %12405 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12406 = getelementptr inbounds i8, i8* %12405, i64 48
  %12407 = bitcast i8* %12406 to float*
  %12408 = load float, float* %12407, align 4
  %12409 = insertelement <4 x float> %12404, float %12408, i32 2
  %12410 = insertelement <4 x float> %12409, float 0.000000e+00, i32 3
  %12411 = getelementptr inbounds float, float* %2, i64 12
  %12412 = load float, float* %12411, align 4
  %12413 = insertelement <4 x float> zeroinitializer, float %12412, i32 0
  %12414 = insertelement <4 x float> %12413, float 0.000000e+00, i32 1
  %12415 = getelementptr inbounds float, float* %2, i64 1
  %12416 = load float, float* %12415, align 4
  %12417 = insertelement <4 x float> %12414, float %12416, i32 2
  %12418 = insertelement <4 x float> %12417, float 0.000000e+00, i32 3
  %12419 = call <4 x float> @llvm.fma.f32.329(<4 x float> %12410, <4 x float> %12418, <4 x float> %12398)
  %12420 = extractelement <4 x float> %12419, i32 0
  %12421 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12422 = getelementptr inbounds i8, i8* %12421, i64 48
  %12423 = bitcast i8* %12422 to float*
  store float %12420, float* %12423, align 4
  %12424 = extractelement <4 x float> %12419, i32 1
  %12425 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12426 = getelementptr inbounds i8, i8* %12425, i64 52
  %12427 = bitcast i8* %12426 to float*
  store float %12424, float* %12427, align 4
  %12428 = extractelement <4 x float> %12419, i32 2
  %12429 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12430 = getelementptr inbounds i8, i8* %12429, i64 52
  %12431 = bitcast i8* %12430 to float*
  store float %12428, float* %12431, align 4
  %12432 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12433 = getelementptr inbounds i8, i8* %12432, i64 52
  %12434 = bitcast i8* %12433 to float*
  %12435 = load float, float* %12434, align 4
  %12436 = insertelement <4 x float> zeroinitializer, float %12435, i32 0
  %12437 = insertelement <4 x float> %12436, float 0.000000e+00, i32 1
  %12438 = insertelement <4 x float> %12437, float 0.000000e+00, i32 2
  %12439 = insertelement <4 x float> %12438, float 0.000000e+00, i32 3
  %12440 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12441 = getelementptr inbounds i8, i8* %12440, i64 52
  %12442 = bitcast i8* %12441 to float*
  %12443 = load float, float* %12442, align 4
  %12444 = insertelement <4 x float> zeroinitializer, float %12443, i32 0
  %12445 = insertelement <4 x float> %12444, float 0.000000e+00, i32 1
  %12446 = insertelement <4 x float> %12445, float 0.000000e+00, i32 2
  %12447 = insertelement <4 x float> %12446, float 0.000000e+00, i32 3
  %12448 = getelementptr inbounds float, float* %2, i64 5
  %12449 = load float, float* %12448, align 4
  %12450 = insertelement <4 x float> zeroinitializer, float %12449, i32 0
  %12451 = insertelement <4 x float> %12450, float 0.000000e+00, i32 1
  %12452 = insertelement <4 x float> %12451, float 0.000000e+00, i32 2
  %12453 = insertelement <4 x float> %12452, float 0.000000e+00, i32 3
  %12454 = call <4 x float> @llvm.fma.f32.330(<4 x float> %12447, <4 x float> %12453, <4 x float> %12439)
  %12455 = extractelement <4 x float> %12454, i32 0
  %12456 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12457 = getelementptr inbounds i8, i8* %12456, i64 52
  %12458 = bitcast i8* %12457 to float*
  store float %12455, float* %12458, align 4
  %12459 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12460 = getelementptr inbounds i8, i8* %12459, i64 52
  %12461 = bitcast i8* %12460 to float*
  %12462 = load float, float* %12461, align 4
  %12463 = insertelement <4 x float> zeroinitializer, float %12462, i32 0
  %12464 = insertelement <4 x float> %12463, float 0.000000e+00, i32 1
  %12465 = insertelement <4 x float> %12464, float 0.000000e+00, i32 2
  %12466 = insertelement <4 x float> %12465, float 0.000000e+00, i32 3
  %12467 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12468 = getelementptr inbounds i8, i8* %12467, i64 56
  %12469 = bitcast i8* %12468 to float*
  %12470 = load float, float* %12469, align 4
  %12471 = insertelement <4 x float> zeroinitializer, float %12470, i32 0
  %12472 = insertelement <4 x float> %12471, float 0.000000e+00, i32 1
  %12473 = insertelement <4 x float> %12472, float 0.000000e+00, i32 2
  %12474 = insertelement <4 x float> %12473, float 0.000000e+00, i32 3
  %12475 = getelementptr inbounds float, float* %2, i64 9
  %12476 = load float, float* %12475, align 4
  %12477 = insertelement <4 x float> zeroinitializer, float %12476, i32 0
  %12478 = insertelement <4 x float> %12477, float 0.000000e+00, i32 1
  %12479 = insertelement <4 x float> %12478, float 0.000000e+00, i32 2
  %12480 = insertelement <4 x float> %12479, float 0.000000e+00, i32 3
  %12481 = call <4 x float> @llvm.fma.f32.331(<4 x float> %12474, <4 x float> %12480, <4 x float> %12466)
  %12482 = extractelement <4 x float> %12481, i32 0
  %12483 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12484 = getelementptr inbounds i8, i8* %12483, i64 52
  %12485 = bitcast i8* %12484 to float*
  store float %12482, float* %12485, align 4
  %12486 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12487 = getelementptr inbounds i8, i8* %12486, i64 52
  %12488 = bitcast i8* %12487 to float*
  %12489 = load float, float* %12488, align 4
  %12490 = insertelement <4 x float> zeroinitializer, float %12489, i32 0
  %12491 = insertelement <4 x float> %12490, float 0.000000e+00, i32 1
  %12492 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12493 = getelementptr inbounds i8, i8* %12492, i64 56
  %12494 = bitcast i8* %12493 to float*
  %12495 = load float, float* %12494, align 4
  %12496 = insertelement <4 x float> %12491, float %12495, i32 2
  %12497 = insertelement <4 x float> %12496, float 0.000000e+00, i32 3
  %12498 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12499 = getelementptr inbounds i8, i8* %12498, i64 60
  %12500 = bitcast i8* %12499 to float*
  %12501 = load float, float* %12500, align 4
  %12502 = insertelement <4 x float> zeroinitializer, float %12501, i32 0
  %12503 = insertelement <4 x float> %12502, float 0.000000e+00, i32 1
  %12504 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12505 = getelementptr inbounds i8, i8* %12504, i64 48
  %12506 = bitcast i8* %12505 to float*
  %12507 = load float, float* %12506, align 4
  %12508 = insertelement <4 x float> %12503, float %12507, i32 2
  %12509 = insertelement <4 x float> %12508, float 0.000000e+00, i32 3
  %12510 = getelementptr inbounds float, float* %2, i64 13
  %12511 = load float, float* %12510, align 4
  %12512 = insertelement <4 x float> zeroinitializer, float %12511, i32 0
  %12513 = insertelement <4 x float> %12512, float 0.000000e+00, i32 1
  %12514 = getelementptr inbounds float, float* %2, i64 2
  %12515 = load float, float* %12514, align 4
  %12516 = insertelement <4 x float> %12513, float %12515, i32 2
  %12517 = insertelement <4 x float> %12516, float 0.000000e+00, i32 3
  %12518 = call <4 x float> @llvm.fma.f32.332(<4 x float> %12509, <4 x float> %12517, <4 x float> %12497)
  %12519 = extractelement <4 x float> %12518, i32 0
  %12520 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12521 = getelementptr inbounds i8, i8* %12520, i64 52
  %12522 = bitcast i8* %12521 to float*
  store float %12519, float* %12522, align 4
  %12523 = extractelement <4 x float> %12518, i32 1
  %12524 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12525 = getelementptr inbounds i8, i8* %12524, i64 56
  %12526 = bitcast i8* %12525 to float*
  store float %12523, float* %12526, align 4
  %12527 = extractelement <4 x float> %12518, i32 2
  %12528 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12529 = getelementptr inbounds i8, i8* %12528, i64 56
  %12530 = bitcast i8* %12529 to float*
  store float %12527, float* %12530, align 4
  %12531 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12532 = getelementptr inbounds i8, i8* %12531, i64 56
  %12533 = bitcast i8* %12532 to float*
  %12534 = load float, float* %12533, align 4
  %12535 = insertelement <4 x float> zeroinitializer, float %12534, i32 0
  %12536 = insertelement <4 x float> %12535, float 0.000000e+00, i32 1
  %12537 = insertelement <4 x float> %12536, float 0.000000e+00, i32 2
  %12538 = insertelement <4 x float> %12537, float 0.000000e+00, i32 3
  %12539 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12540 = getelementptr inbounds i8, i8* %12539, i64 52
  %12541 = bitcast i8* %12540 to float*
  %12542 = load float, float* %12541, align 4
  %12543 = insertelement <4 x float> zeroinitializer, float %12542, i32 0
  %12544 = insertelement <4 x float> %12543, float 0.000000e+00, i32 1
  %12545 = insertelement <4 x float> %12544, float 0.000000e+00, i32 2
  %12546 = insertelement <4 x float> %12545, float 0.000000e+00, i32 3
  %12547 = getelementptr inbounds float, float* %2, i64 6
  %12548 = load float, float* %12547, align 4
  %12549 = insertelement <4 x float> zeroinitializer, float %12548, i32 0
  %12550 = insertelement <4 x float> %12549, float 0.000000e+00, i32 1
  %12551 = insertelement <4 x float> %12550, float 0.000000e+00, i32 2
  %12552 = insertelement <4 x float> %12551, float 0.000000e+00, i32 3
  %12553 = call <4 x float> @llvm.fma.f32.333(<4 x float> %12546, <4 x float> %12552, <4 x float> %12538)
  %12554 = extractelement <4 x float> %12553, i32 0
  %12555 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12556 = getelementptr inbounds i8, i8* %12555, i64 56
  %12557 = bitcast i8* %12556 to float*
  store float %12554, float* %12557, align 4
  %12558 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12559 = getelementptr inbounds i8, i8* %12558, i64 56
  %12560 = bitcast i8* %12559 to float*
  %12561 = load float, float* %12560, align 4
  %12562 = insertelement <4 x float> zeroinitializer, float %12561, i32 0
  %12563 = insertelement <4 x float> %12562, float 0.000000e+00, i32 1
  %12564 = insertelement <4 x float> %12563, float 0.000000e+00, i32 2
  %12565 = insertelement <4 x float> %12564, float 0.000000e+00, i32 3
  %12566 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12567 = getelementptr inbounds i8, i8* %12566, i64 56
  %12568 = bitcast i8* %12567 to float*
  %12569 = load float, float* %12568, align 4
  %12570 = insertelement <4 x float> zeroinitializer, float %12569, i32 0
  %12571 = insertelement <4 x float> %12570, float 0.000000e+00, i32 1
  %12572 = insertelement <4 x float> %12571, float 0.000000e+00, i32 2
  %12573 = insertelement <4 x float> %12572, float 0.000000e+00, i32 3
  %12574 = getelementptr inbounds float, float* %2, i64 10
  %12575 = load float, float* %12574, align 4
  %12576 = insertelement <4 x float> zeroinitializer, float %12575, i32 0
  %12577 = insertelement <4 x float> %12576, float 0.000000e+00, i32 1
  %12578 = insertelement <4 x float> %12577, float 0.000000e+00, i32 2
  %12579 = insertelement <4 x float> %12578, float 0.000000e+00, i32 3
  %12580 = call <4 x float> @llvm.fma.f32.334(<4 x float> %12573, <4 x float> %12579, <4 x float> %12565)
  %12581 = extractelement <4 x float> %12580, i32 0
  %12582 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12583 = getelementptr inbounds i8, i8* %12582, i64 56
  %12584 = bitcast i8* %12583 to float*
  store float %12581, float* %12584, align 4
  %12585 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12586 = getelementptr inbounds i8, i8* %12585, i64 56
  %12587 = bitcast i8* %12586 to float*
  %12588 = load float, float* %12587, align 4
  %12589 = insertelement <4 x float> zeroinitializer, float %12588, i32 0
  %12590 = insertelement <4 x float> %12589, float 0.000000e+00, i32 1
  %12591 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12592 = getelementptr inbounds i8, i8* %12591, i64 60
  %12593 = bitcast i8* %12592 to float*
  %12594 = load float, float* %12593, align 4
  %12595 = insertelement <4 x float> %12590, float %12594, i32 2
  %12596 = insertelement <4 x float> %12595, float 0.000000e+00, i32 3
  %12597 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12598 = getelementptr inbounds i8, i8* %12597, i64 60
  %12599 = bitcast i8* %12598 to float*
  %12600 = load float, float* %12599, align 4
  %12601 = insertelement <4 x float> zeroinitializer, float %12600, i32 0
  %12602 = insertelement <4 x float> %12601, float 0.000000e+00, i32 1
  %12603 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12604 = getelementptr inbounds i8, i8* %12603, i64 48
  %12605 = bitcast i8* %12604 to float*
  %12606 = load float, float* %12605, align 4
  %12607 = insertelement <4 x float> %12602, float %12606, i32 2
  %12608 = insertelement <4 x float> %12607, float 0.000000e+00, i32 3
  %12609 = getelementptr inbounds float, float* %2, i64 14
  %12610 = load float, float* %12609, align 4
  %12611 = insertelement <4 x float> zeroinitializer, float %12610, i32 0
  %12612 = insertelement <4 x float> %12611, float 0.000000e+00, i32 1
  %12613 = getelementptr inbounds float, float* %2, i64 3
  %12614 = load float, float* %12613, align 4
  %12615 = insertelement <4 x float> %12612, float %12614, i32 2
  %12616 = insertelement <4 x float> %12615, float 0.000000e+00, i32 3
  %12617 = call <4 x float> @llvm.fma.f32.335(<4 x float> %12608, <4 x float> %12616, <4 x float> %12596)
  %12618 = extractelement <4 x float> %12617, i32 0
  %12619 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12620 = getelementptr inbounds i8, i8* %12619, i64 56
  %12621 = bitcast i8* %12620 to float*
  store float %12618, float* %12621, align 4
  %12622 = extractelement <4 x float> %12617, i32 1
  %12623 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12624 = getelementptr inbounds i8, i8* %12623, i64 60
  %12625 = bitcast i8* %12624 to float*
  store float %12622, float* %12625, align 4
  %12626 = extractelement <4 x float> %12617, i32 2
  %12627 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12628 = getelementptr inbounds i8, i8* %12627, i64 60
  %12629 = bitcast i8* %12628 to float*
  store float %12626, float* %12629, align 4
  %12630 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12631 = getelementptr inbounds i8, i8* %12630, i64 60
  %12632 = bitcast i8* %12631 to float*
  %12633 = load float, float* %12632, align 4
  %12634 = insertelement <4 x float> zeroinitializer, float %12633, i32 0
  %12635 = insertelement <4 x float> %12634, float 0.000000e+00, i32 1
  %12636 = insertelement <4 x float> %12635, float 0.000000e+00, i32 2
  %12637 = insertelement <4 x float> %12636, float 0.000000e+00, i32 3
  %12638 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12639 = getelementptr inbounds i8, i8* %12638, i64 52
  %12640 = bitcast i8* %12639 to float*
  %12641 = load float, float* %12640, align 4
  %12642 = insertelement <4 x float> zeroinitializer, float %12641, i32 0
  %12643 = insertelement <4 x float> %12642, float 0.000000e+00, i32 1
  %12644 = insertelement <4 x float> %12643, float 0.000000e+00, i32 2
  %12645 = insertelement <4 x float> %12644, float 0.000000e+00, i32 3
  %12646 = getelementptr inbounds float, float* %2, i64 7
  %12647 = load float, float* %12646, align 4
  %12648 = insertelement <4 x float> zeroinitializer, float %12647, i32 0
  %12649 = insertelement <4 x float> %12648, float 0.000000e+00, i32 1
  %12650 = insertelement <4 x float> %12649, float 0.000000e+00, i32 2
  %12651 = insertelement <4 x float> %12650, float 0.000000e+00, i32 3
  %12652 = call <4 x float> @llvm.fma.f32.336(<4 x float> %12645, <4 x float> %12651, <4 x float> %12637)
  %12653 = extractelement <4 x float> %12652, i32 0
  %12654 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12655 = getelementptr inbounds i8, i8* %12654, i64 60
  %12656 = bitcast i8* %12655 to float*
  store float %12653, float* %12656, align 4
  %12657 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12658 = getelementptr inbounds i8, i8* %12657, i64 60
  %12659 = bitcast i8* %12658 to float*
  %12660 = load float, float* %12659, align 4
  %12661 = insertelement <4 x float> zeroinitializer, float %12660, i32 0
  %12662 = insertelement <4 x float> %12661, float 0.000000e+00, i32 1
  %12663 = insertelement <4 x float> %12662, float 0.000000e+00, i32 2
  %12664 = insertelement <4 x float> %12663, float 0.000000e+00, i32 3
  %12665 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12666 = getelementptr inbounds i8, i8* %12665, i64 56
  %12667 = bitcast i8* %12666 to float*
  %12668 = load float, float* %12667, align 4
  %12669 = insertelement <4 x float> zeroinitializer, float %12668, i32 0
  %12670 = insertelement <4 x float> %12669, float 0.000000e+00, i32 1
  %12671 = insertelement <4 x float> %12670, float 0.000000e+00, i32 2
  %12672 = insertelement <4 x float> %12671, float 0.000000e+00, i32 3
  %12673 = getelementptr inbounds float, float* %2, i64 11
  %12674 = load float, float* %12673, align 4
  %12675 = insertelement <4 x float> zeroinitializer, float %12674, i32 0
  %12676 = insertelement <4 x float> %12675, float 0.000000e+00, i32 1
  %12677 = insertelement <4 x float> %12676, float 0.000000e+00, i32 2
  %12678 = insertelement <4 x float> %12677, float 0.000000e+00, i32 3
  %12679 = call <4 x float> @llvm.fma.f32.337(<4 x float> %12672, <4 x float> %12678, <4 x float> %12664)
  %12680 = extractelement <4 x float> %12679, i32 0
  %12681 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12682 = getelementptr inbounds i8, i8* %12681, i64 60
  %12683 = bitcast i8* %12682 to float*
  store float %12680, float* %12683, align 4
  %12684 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12685 = getelementptr inbounds i8, i8* %12684, i64 60
  %12686 = bitcast i8* %12685 to float*
  %12687 = load float, float* %12686, align 4
  %12688 = insertelement <4 x float> zeroinitializer, float %12687, i32 0
  %12689 = insertelement <4 x float> %12688, float 0.000000e+00, i32 1
  %12690 = insertelement <4 x float> %12689, float 0.000000e+00, i32 2
  %12691 = insertelement <4 x float> %12690, float 0.000000e+00, i32 3
  %12692 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12693 = getelementptr inbounds i8, i8* %12692, i64 60
  %12694 = bitcast i8* %12693 to float*
  %12695 = load float, float* %12694, align 4
  %12696 = insertelement <4 x float> zeroinitializer, float %12695, i32 0
  %12697 = insertelement <4 x float> %12696, float 1.000000e+00, i32 1
  %12698 = insertelement <4 x float> %12697, float 1.000000e+00, i32 2
  %12699 = insertelement <4 x float> %12698, float 1.000000e+00, i32 3
  %12700 = getelementptr inbounds float, float* %2, i64 15
  %12701 = load float, float* %12700, align 4
  %12702 = insertelement <4 x float> zeroinitializer, float %12701, i32 0
  %12703 = getelementptr inbounds float, float* %1, i64 4
  %12704 = bitcast float* %12703 to i32*
  %12705 = load i32, i32* %12704, align 4
  %12706 = sitofp i32 %12705 to float
  %12707 = insertelement <4 x float> %12702, float %12706, i32 1
  %12708 = getelementptr inbounds float, float* %1, i64 1
  %12709 = bitcast float* %12708 to i32*
  %12710 = load i32, i32* %12709, align 4
  %12711 = sitofp i32 %12710 to float
  %12712 = insertelement <4 x float> %12707, float %12711, i32 2
  %12713 = insertelement <4 x float> %12712, float 0.000000e+00, i32 3
  %12714 = call <4 x float> @llvm.fma.f32.338(<4 x float> %12699, <4 x float> %12713, <4 x float> %12691)
  %12715 = extractelement <4 x float> %12714, i32 0
  %12716 = call dereferenceable_or_null(64) i8* @calloc(i64 4, i64 16) #10
  %12717 = getelementptr inbounds i8, i8* %12716, i64 60
  %12718 = bitcast i8* %12717 to float*
  store float %12715, float* %12718, align 4
  %12719 = extractelement <4 x float> %12714, i32 1
  %12720 = fptosi float %12719 to i32
  %12721 = getelementptr inbounds float, float* %1, i64 1
  %12722 = bitcast float* %12721 to i32*
  store i32 %12720, i32* %12722, align 4
  %12723 = extractelement <4 x float> %12714, i32 2
  %12724 = fptosi float %12723 to i32
  %12725 = getelementptr inbounds float, float* %1, i64 4
  %12726 = bitcast float* %12725 to i32*
  store i32 %12724, i32* %12726, align 4
  br label %12727

12727:                                            ; preds = %.preheader33, %12727
  %indvars.iv3437 = phi i64 [ 2, %.preheader33 ], [ %indvars.iv.next35.1, %12727 ]
  %12728 = getelementptr inbounds float, float* %1, i64 %indvars.iv3437
  %12729 = bitcast float* %12728 to i32*
  %12730 = load i32, i32* %12729, align 4
  %12731 = shl nuw nsw i64 %indvars.iv3437, 2
  %12732 = getelementptr inbounds float, float* %1, i64 %12731
  %12733 = bitcast float* %12732 to i32*
  %12734 = load i32, i32* %12733, align 4
  %12735 = getelementptr inbounds float, float* %1, i64 %indvars.iv3437
  %12736 = bitcast float* %12735 to i32*
  store i32 %12734, i32* %12736, align 4
  %12737 = shl nuw nsw i64 %indvars.iv3437, 2
  %12738 = getelementptr inbounds float, float* %1, i64 %12737
  %12739 = bitcast float* %12738 to i32*
  store i32 %12730, i32* %12739, align 4
  %indvars.iv.next35 = or i64 %indvars.iv3437, 1
  %12740 = getelementptr inbounds float, float* %1, i64 %indvars.iv.next35
  %12741 = bitcast float* %12740 to i32*
  %12742 = load i32, i32* %12741, align 4
  %12743 = shl nuw nsw i64 %indvars.iv.next35, 2
  %12744 = getelementptr inbounds float, float* %1, i64 %12743
  %12745 = bitcast float* %12744 to i32*
  %12746 = load i32, i32* %12745, align 4
  %12747 = getelementptr inbounds float, float* %1, i64 %indvars.iv.next35
  %12748 = bitcast float* %12747 to i32*
  store i32 %12746, i32* %12748, align 4
  %12749 = shl nuw nsw i64 %indvars.iv.next35, 2
  %12750 = getelementptr inbounds float, float* %1, i64 %12749
  %12751 = bitcast float* %12750 to i32*
  store i32 %12742, i32* %12751, align 4
  %indvars.iv.next35.1 = add nuw nsw i64 %indvars.iv3437, 2
  %exitcond.1.not = icmp eq i64 %indvars.iv.next35.1, 4
  br i1 %exitcond.1.not, label %.lr.ph.new.1, label %12727

.lr.ph.new.1:                                     ; preds = %.lr.ph.new.1, %12727
  %indvars.iv3437.1 = phi i64 [ %indvars.iv.next35.1.1, %.lr.ph.new.1 ], [ 2, %12727 ]
  %12752 = add nuw nsw i64 %indvars.iv3437.1, 4
  %12753 = getelementptr inbounds float, float* %1, i64 %12752
  %12754 = bitcast float* %12753 to i32*
  %12755 = load i32, i32* %12754, align 4
  %12756 = shl nuw nsw i64 %indvars.iv3437.1, 2
  %12757 = or i64 %12756, 1
  %12758 = getelementptr inbounds float, float* %1, i64 %12757
  %12759 = bitcast float* %12758 to i32*
  %12760 = load i32, i32* %12759, align 4
  %12761 = add nuw nsw i64 %indvars.iv3437.1, 4
  %12762 = getelementptr inbounds float, float* %1, i64 %12761
  %12763 = bitcast float* %12762 to i32*
  store i32 %12760, i32* %12763, align 4
  %12764 = shl nuw nsw i64 %indvars.iv3437.1, 2
  %12765 = or i64 %12764, 1
  %12766 = getelementptr inbounds float, float* %1, i64 %12765
  %12767 = bitcast float* %12766 to i32*
  store i32 %12755, i32* %12767, align 4
  %indvars.iv.next35.1149 = or i64 %indvars.iv3437.1, 1
  %12768 = add nuw nsw i64 %indvars.iv3437.1, 5
  %12769 = getelementptr inbounds float, float* %1, i64 %12768
  %12770 = bitcast float* %12769 to i32*
  %12771 = load i32, i32* %12770, align 4
  %12772 = shl nuw nsw i64 %indvars.iv.next35.1149, 2
  %12773 = or i64 %12772, 1
  %12774 = getelementptr inbounds float, float* %1, i64 %12773
  %12775 = bitcast float* %12774 to i32*
  %12776 = load i32, i32* %12775, align 4
  %12777 = add nuw nsw i64 %indvars.iv3437.1, 5
  %12778 = getelementptr inbounds float, float* %1, i64 %12777
  %12779 = bitcast float* %12778 to i32*
  store i32 %12776, i32* %12779, align 4
  %12780 = shl nuw nsw i64 %indvars.iv.next35.1149, 2
  %12781 = or i64 %12780, 1
  %12782 = getelementptr inbounds float, float* %1, i64 %12781
  %12783 = bitcast float* %12782 to i32*
  store i32 %12771, i32* %12783, align 4
  %indvars.iv.next35.1.1 = add nuw nsw i64 %indvars.iv3437.1, 2
  %exitcond.1.1.not = icmp eq i64 %indvars.iv.next35.1.1, 4
  br i1 %exitcond.1.1.not, label %.prol.preheader.2, label %.lr.ph.new.1

.prol.preheader.2:                                ; preds = %.lr.ph.new.1
  %12784 = getelementptr inbounds float, float* %1, i64 11
  %12785 = bitcast float* %12784 to i32*
  %12786 = load i32, i32* %12785, align 4
  %12787 = getelementptr inbounds float, float* %1, i64 14
  %12788 = bitcast float* %12787 to i32*
  %12789 = load i32, i32* %12788, align 4
  %12790 = getelementptr inbounds float, float* %1, i64 11
  %12791 = bitcast float* %12790 to i32*
  store i32 %12789, i32* %12791, align 4
  %12792 = getelementptr inbounds float, float* %1, i64 14
  %12793 = bitcast float* %12792 to i32*
  store i32 %12786, i32* %12793, align 4
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

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.1(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.2(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.3(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.4(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.5(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.6(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.7(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.8(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.9(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.10(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.11(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.12(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.13(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.14(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.15(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.16(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.17(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.18(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.19(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.20(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.21(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.22(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.23(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.24(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.25(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.26(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.27(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.28(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.29(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.30(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.31(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.32(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.33(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.34(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.35(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.36(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.37(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.38(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.39(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.40(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.41(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.42(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.43(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.44(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.45(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.46(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.47(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.48(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.49(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.50(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.51(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.52(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.53(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.54(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.55(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.56(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.57(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.58(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.59(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.60(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.61(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.62(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.63(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.64(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.65(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.66(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.67(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.68(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.69(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.70(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.71(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.72(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.73(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.74(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.75(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.76(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.77(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.78(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.79(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.80(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.81(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.82(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.83(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.84(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.85(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.86(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.87(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.88(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.89(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.90(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.91(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.92(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.93(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.94(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.95(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.96(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.97(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.98(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.99(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.100(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.101(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.102(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.103(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.104(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.105(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.106(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.107(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.108(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.109(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.110(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.111(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.112(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.113(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.114(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.115(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.116(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.117(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.118(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.119(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.120(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.121(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.122(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.123(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.124(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.125(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.126(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.127(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.128(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.129(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.130(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.131(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.132(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.133(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.134(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.135(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.136(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.137(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.138(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.139(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.140(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.141(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.142(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.143(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.144(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.145(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.146(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.147(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.148(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.149(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.150(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.151(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.152(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.153(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.154(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.155(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.156(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.157(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.158(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.159(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.160(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.161(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.162(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.163(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.164(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.165(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.166(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.167(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.168(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.169(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.170(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.171(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.172(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.173(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.174(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.175(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.176(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.177(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.178(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.179(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.180(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.181(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.182(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.183(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.184(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.185(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.186(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.187(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.188(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.189(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.190(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.191(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.192(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.193(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.194(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.195(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.196(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.197(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.198(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.199(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.200(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.201(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.202(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.203(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.204(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.205(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.206(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.207(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.208(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.209(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.210(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.211(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.212(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.213(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.214(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.215(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.216(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.217(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.218(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.219(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.220(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.221(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.222(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.223(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.224(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.225(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.226(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.227(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.228(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.229(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.230(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.231(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.232(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.233(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.234(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.235(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.236(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.237(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.238(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.239(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.240(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.241(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.242(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.243(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.244(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.245(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.246(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.247(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.248(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.249(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.250(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.251(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.252(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.253(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.254(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.255(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.256(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.257(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.258(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.259(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.260(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.261(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.262(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.263(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.264(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.265(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.266(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.267(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.268(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.269(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.270(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.271(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.272(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.273(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.274(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.275(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.276(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.277(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.278(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.279(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.280(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.281(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.282(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.283(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.284(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.285(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.286(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.287(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.288(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.289(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.290(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.291(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.292(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.293(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.294(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.295(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.296(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.297(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.298(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.299(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.300(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.301(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.302(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.303(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.304(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.305(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.306(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.307(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.308(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.309(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.310(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.311(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.312(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.313(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.314(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.315(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.316(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.317(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.318(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.319(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.320(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.321(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.322(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.323(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.324(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.325(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.326(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.327(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.328(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.329(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.330(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.331(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.332(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.333(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.334(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.335(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.336(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.337(<4 x float>, <4 x float>, <4 x float>) #8

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32.338(<4 x float>, <4 x float>, <4 x float>) #8

attributes #0 = { alwaysinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable willreturn }
attributes #2 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { allocsize(0,1) "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { argmemonly nounwind willreturn }
attributes #7 = { argmemonly nounwind willreturn writeonly }
attributes #8 = { nounwind readnone speculatable willreturn }
attributes #9 = { nounwind }
attributes #10 = { nounwind allocsize(0,1) }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
