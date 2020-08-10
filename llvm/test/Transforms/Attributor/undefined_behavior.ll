; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --scrub-attributes --check-attributes
; RUN: opt -attributor -enable-new-pm=0 -attributor-manifest-internal  -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=5 -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_CGSCC_NPM,NOT_CGSCC_OPM,NOT_TUNIT_NPM,IS__TUNIT____,IS________OPM,IS__TUNIT_OPM
; RUN: opt -aa-pipeline=basic-aa -passes=attributor -attributor-manifest-internal  -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=5 -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_CGSCC_OPM,NOT_CGSCC_NPM,NOT_TUNIT_OPM,IS__TUNIT____,IS________NPM,IS__TUNIT_NPM
; RUN: opt -attributor-cgscc -enable-new-pm=0 -attributor-manifest-internal  -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_TUNIT_NPM,NOT_TUNIT_OPM,NOT_CGSCC_NPM,IS__CGSCC____,IS________OPM,IS__CGSCC_OPM
; RUN: opt -aa-pipeline=basic-aa -passes=attributor-cgscc -attributor-manifest-internal  -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_TUNIT_NPM,NOT_TUNIT_OPM,NOT_CGSCC_OPM,IS__CGSCC____,IS________NPM,IS__CGSCC_NPM

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

; Test cases specifically designed for the "undefined behavior" abstract function attribute.
; We want to verify that whenever undefined behavior is assumed, the code becomes unreachable.
; We use FIXME's to indicate problems and missing attributes.

; -- Load tests --

define void @load_wholly_unreachable() {
; IS__TUNIT____: Function Attrs: nofree nosync nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@load_wholly_unreachable()
; IS__TUNIT____-NEXT:    unreachable
;
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@load_wholly_unreachable()
; IS__CGSCC____-NEXT:    unreachable
;
  %a = load i32, i32* null
  ret void
}

define void @loads_wholly_unreachable() {
; IS__TUNIT____: Function Attrs: nofree nosync nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@loads_wholly_unreachable()
; IS__TUNIT____-NEXT:    unreachable
;
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@loads_wholly_unreachable()
; IS__CGSCC____-NEXT:    unreachable
;
  %a = load i32, i32* null
  %b = load i32, i32* null
  ret void
}


define void @load_single_bb_unreachable(i1 %cond) {
; IS__TUNIT____: Function Attrs: nofree nosync nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@load_single_bb_unreachable
; IS__TUNIT____-SAME: (i1 [[COND:%.*]])
; IS__TUNIT____-NEXT:    br i1 [[COND]], label [[T:%.*]], label [[E:%.*]]
; IS__TUNIT____:       t:
; IS__TUNIT____-NEXT:    unreachable
; IS__TUNIT____:       e:
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@load_single_bb_unreachable
; IS__CGSCC____-SAME: (i1 [[COND:%.*]])
; IS__CGSCC____-NEXT:    br i1 [[COND]], label [[T:%.*]], label [[E:%.*]]
; IS__CGSCC____:       t:
; IS__CGSCC____-NEXT:    unreachable
; IS__CGSCC____:       e:
; IS__CGSCC____-NEXT:    ret void
;
  br i1 %cond, label %t, label %e
t:
  %b = load i32, i32* null
  br label %e
e:
  ret void
}

; Note that while the load is removed (because it's unused), the block
; is not changed to unreachable
define void @load_null_pointer_is_defined() null_pointer_is_valid {
; IS__TUNIT____: Function Attrs: nofree nosync nounwind null_pointer_is_valid readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@load_null_pointer_is_defined()
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind null_pointer_is_valid readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@load_null_pointer_is_defined()
; IS__CGSCC____-NEXT:    ret void
;
  %a = load i32, i32* null
  ret void
}

define internal i32* @ret_null() {
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@ret_null()
; IS__CGSCC____-NEXT:    ret i32* null
;
  ret i32* null
}

define void @load_null_propagated() {
; IS__TUNIT____: Function Attrs: nofree nosync nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@load_null_propagated()
; IS__TUNIT____-NEXT:    unreachable
;
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@load_null_propagated()
; IS__CGSCC____-NEXT:    unreachable
;
  %ptr = call i32* @ret_null()
  %a = load i32, i32* %ptr
  ret void
}

; -- Store tests --

define void @store_wholly_unreachable() {
; IS__TUNIT____: Function Attrs: nofree nosync nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@store_wholly_unreachable()
; IS__TUNIT____-NEXT:    unreachable
;
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@store_wholly_unreachable()
; IS__CGSCC____-NEXT:    unreachable
;
  store i32 5, i32* null
  ret void
}

define void @store_single_bb_unreachable(i1 %cond) {
; IS__TUNIT____: Function Attrs: nofree nosync nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@store_single_bb_unreachable
; IS__TUNIT____-SAME: (i1 [[COND:%.*]])
; IS__TUNIT____-NEXT:    br i1 [[COND]], label [[T:%.*]], label [[E:%.*]]
; IS__TUNIT____:       t:
; IS__TUNIT____-NEXT:    unreachable
; IS__TUNIT____:       e:
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@store_single_bb_unreachable
; IS__CGSCC____-SAME: (i1 [[COND:%.*]])
; IS__CGSCC____-NEXT:    br i1 [[COND]], label [[T:%.*]], label [[E:%.*]]
; IS__CGSCC____:       t:
; IS__CGSCC____-NEXT:    unreachable
; IS__CGSCC____:       e:
; IS__CGSCC____-NEXT:    ret void
;
  br i1 %cond, label %t, label %e
t:
  store i32 5, i32* null
  br label %e
e:
  ret void
}

define void @store_null_pointer_is_defined() null_pointer_is_valid {
; IS__TUNIT____: Function Attrs: nofree nosync nounwind null_pointer_is_valid willreturn writeonly
; IS__TUNIT____-LABEL: define {{[^@]+}}@store_null_pointer_is_defined()
; IS__TUNIT____-NEXT:    store i32 5, i32* null, align 536870912
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind null_pointer_is_valid willreturn writeonly
; IS__CGSCC____-LABEL: define {{[^@]+}}@store_null_pointer_is_defined()
; IS__CGSCC____-NEXT:    store i32 5, i32* null, align 536870912
; IS__CGSCC____-NEXT:    ret void
;
  store i32 5, i32* null
  ret void
}

define void @store_null_propagated() {
; ATTRIBUTOR-LABEL: @store_null_propagated(
; ATTRIBUTOR-NEXT:    unreachable
;
; IS__TUNIT____: Function Attrs: nofree nosync nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@store_null_propagated()
; IS__TUNIT____-NEXT:    unreachable
;
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@store_null_propagated()
; IS__CGSCC____-NEXT:    unreachable
;
  %ptr = call i32* @ret_null()
  store i32 5, i32* %ptr
  ret void
}

; -- AtomicRMW tests --

define void @atomicrmw_wholly_unreachable() {
; IS__TUNIT____: Function Attrs: nofree nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@atomicrmw_wholly_unreachable()
; IS__TUNIT____-NEXT:    unreachable
;
; IS__CGSCC____: Function Attrs: nofree norecurse nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@atomicrmw_wholly_unreachable()
; IS__CGSCC____-NEXT:    unreachable
;
  %a = atomicrmw add i32* null, i32 1 acquire
  ret void
}

define void @atomicrmw_single_bb_unreachable(i1 %cond) {
; IS__TUNIT____: Function Attrs: nofree nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@atomicrmw_single_bb_unreachable
; IS__TUNIT____-SAME: (i1 [[COND:%.*]])
; IS__TUNIT____-NEXT:    br i1 [[COND]], label [[T:%.*]], label [[E:%.*]]
; IS__TUNIT____:       t:
; IS__TUNIT____-NEXT:    unreachable
; IS__TUNIT____:       e:
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____: Function Attrs: nofree norecurse nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@atomicrmw_single_bb_unreachable
; IS__CGSCC____-SAME: (i1 [[COND:%.*]])
; IS__CGSCC____-NEXT:    br i1 [[COND]], label [[T:%.*]], label [[E:%.*]]
; IS__CGSCC____:       t:
; IS__CGSCC____-NEXT:    unreachable
; IS__CGSCC____:       e:
; IS__CGSCC____-NEXT:    ret void
;
  br i1 %cond, label %t, label %e
t:
  %a = atomicrmw add i32* null, i32 1 acquire
  br label %e
e:
  ret void
}

define void @atomicrmw_null_pointer_is_defined() null_pointer_is_valid {
; IS__TUNIT____: Function Attrs: nofree nounwind null_pointer_is_valid willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@atomicrmw_null_pointer_is_defined()
; IS__TUNIT____-NEXT:    [[A:%.*]] = atomicrmw add i32* null, i32 1 acquire
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____: Function Attrs: nofree norecurse nounwind null_pointer_is_valid willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@atomicrmw_null_pointer_is_defined()
; IS__CGSCC____-NEXT:    [[A:%.*]] = atomicrmw add i32* null, i32 1 acquire
; IS__CGSCC____-NEXT:    ret void
;
  %a = atomicrmw add i32* null, i32 1 acquire
  ret void
}

define void @atomicrmw_null_propagated() {
; ATTRIBUTOR-LABEL: @atomicrmw_null_propagated(
; ATTRIBUTOR-NEXT:    unreachable
;
; IS__TUNIT____: Function Attrs: nofree nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@atomicrmw_null_propagated()
; IS__TUNIT____-NEXT:    unreachable
;
; IS__CGSCC____: Function Attrs: nofree norecurse nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@atomicrmw_null_propagated()
; IS__CGSCC____-NEXT:    unreachable
;
  %ptr = call i32* @ret_null()
  %a = atomicrmw add i32* %ptr, i32 1 acquire
  ret void
}

; -- AtomicCmpXchg tests --

define void @atomiccmpxchg_wholly_unreachable() {
; IS__TUNIT____: Function Attrs: nofree nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@atomiccmpxchg_wholly_unreachable()
; IS__TUNIT____-NEXT:    unreachable
;
; IS__CGSCC____: Function Attrs: nofree norecurse nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@atomiccmpxchg_wholly_unreachable()
; IS__CGSCC____-NEXT:    unreachable
;
  %a = cmpxchg i32* null, i32 2, i32 3 acq_rel monotonic
  ret void
}

define void @atomiccmpxchg_single_bb_unreachable(i1 %cond) {
; IS__TUNIT____: Function Attrs: nofree nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@atomiccmpxchg_single_bb_unreachable
; IS__TUNIT____-SAME: (i1 [[COND:%.*]])
; IS__TUNIT____-NEXT:    br i1 [[COND]], label [[T:%.*]], label [[E:%.*]]
; IS__TUNIT____:       t:
; IS__TUNIT____-NEXT:    unreachable
; IS__TUNIT____:       e:
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____: Function Attrs: nofree norecurse nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@atomiccmpxchg_single_bb_unreachable
; IS__CGSCC____-SAME: (i1 [[COND:%.*]])
; IS__CGSCC____-NEXT:    br i1 [[COND]], label [[T:%.*]], label [[E:%.*]]
; IS__CGSCC____:       t:
; IS__CGSCC____-NEXT:    unreachable
; IS__CGSCC____:       e:
; IS__CGSCC____-NEXT:    ret void
;
  br i1 %cond, label %t, label %e
t:
  %a = cmpxchg i32* null, i32 2, i32 3 acq_rel monotonic
  br label %e
e:
  ret void
}

define void @atomiccmpxchg_null_pointer_is_defined() null_pointer_is_valid {
; IS__TUNIT____: Function Attrs: nofree nounwind null_pointer_is_valid willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@atomiccmpxchg_null_pointer_is_defined()
; IS__TUNIT____-NEXT:    [[A:%.*]] = cmpxchg i32* null, i32 2, i32 3 acq_rel monotonic
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____: Function Attrs: nofree norecurse nounwind null_pointer_is_valid willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@atomiccmpxchg_null_pointer_is_defined()
; IS__CGSCC____-NEXT:    [[A:%.*]] = cmpxchg i32* null, i32 2, i32 3 acq_rel monotonic
; IS__CGSCC____-NEXT:    ret void
;
  %a = cmpxchg i32* null, i32 2, i32 3 acq_rel monotonic
  ret void
}

define void @atomiccmpxchg_null_propagated() {
; ATTRIBUTOR-LABEL: @atomiccmpxchg_null_propagated(
; ATTRIBUTOR-NEXT:    unreachable
;
; IS__TUNIT____: Function Attrs: nofree nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@atomiccmpxchg_null_propagated()
; IS__TUNIT____-NEXT:    unreachable
;
; IS__CGSCC____: Function Attrs: nofree norecurse nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@atomiccmpxchg_null_propagated()
; IS__CGSCC____-NEXT:    unreachable
;
  %ptr = call i32* @ret_null()
  %a = cmpxchg i32* %ptr, i32 2, i32 3 acq_rel monotonic
  ret void
}

; -- Conditional branching tests --

; Note: The unreachable on %t and %e is _not_ from AAUndefinedBehavior

define i32 @cond_br_on_undef() {
; IS__TUNIT____: Function Attrs: nofree noreturn nosync nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@cond_br_on_undef()
; IS__TUNIT____-NEXT:    unreachable
; IS__TUNIT____:       t:
; IS__TUNIT____-NEXT:    unreachable
; IS__TUNIT____:       e:
; IS__TUNIT____-NEXT:    unreachable
;
; IS__CGSCC____: Function Attrs: nofree norecurse noreturn nosync nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@cond_br_on_undef()
; IS__CGSCC____-NEXT:    unreachable
; IS__CGSCC____:       t:
; IS__CGSCC____-NEXT:    unreachable
; IS__CGSCC____:       e:
; IS__CGSCC____-NEXT:    unreachable
;
  br i1 undef, label %t, label %e
t:
  ret i32 1
e:
  ret i32 2
}

; More complicated branching
  ; Valid branch - verify that this is not converted
  ; to unreachable.
define void @cond_br_on_undef2(i1 %cond) {
; IS__TUNIT____: Function Attrs: nofree nosync nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@cond_br_on_undef2
; IS__TUNIT____-SAME: (i1 [[COND:%.*]])
; IS__TUNIT____-NEXT:    br i1 [[COND]], label [[T1:%.*]], label [[E1:%.*]]
; IS__TUNIT____:       t1:
; IS__TUNIT____-NEXT:    unreachable
; IS__TUNIT____:       t2:
; IS__TUNIT____-NEXT:    unreachable
; IS__TUNIT____:       e2:
; IS__TUNIT____-NEXT:    unreachable
; IS__TUNIT____:       e1:
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@cond_br_on_undef2
; IS__CGSCC____-SAME: (i1 [[COND:%.*]])
; IS__CGSCC____-NEXT:    br i1 [[COND]], label [[T1:%.*]], label [[E1:%.*]]
; IS__CGSCC____:       t1:
; IS__CGSCC____-NEXT:    unreachable
; IS__CGSCC____:       t2:
; IS__CGSCC____-NEXT:    unreachable
; IS__CGSCC____:       e2:
; IS__CGSCC____-NEXT:    unreachable
; IS__CGSCC____:       e1:
; IS__CGSCC____-NEXT:    ret void
;
  br i1 %cond, label %t1, label %e1
t1:
  br i1 undef, label %t2, label %e2
t2:
  ret void
e2:
  ret void
e1:
  ret void
}

define i1 @ret_undef() {
; IS__TUNIT____: Function Attrs: nofree nosync nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@ret_undef()
; IS__TUNIT____-NEXT:    ret i1 undef
;
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@ret_undef()
; IS__CGSCC____-NEXT:    ret i1 undef
;
  ret i1 undef
}

define void @cond_br_on_undef_interproc() {
; IS__TUNIT____: Function Attrs: nofree noreturn nosync nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@cond_br_on_undef_interproc()
; IS__TUNIT____-NEXT:    unreachable
; IS__TUNIT____:       t:
; IS__TUNIT____-NEXT:    unreachable
; IS__TUNIT____:       e:
; IS__TUNIT____-NEXT:    unreachable
;
; IS__CGSCC____: Function Attrs: nofree norecurse noreturn nosync nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@cond_br_on_undef_interproc()
; IS__CGSCC____-NEXT:    unreachable
; IS__CGSCC____:       t:
; IS__CGSCC____-NEXT:    unreachable
; IS__CGSCC____:       e:
; IS__CGSCC____-NEXT:    unreachable
;
  %cond = call i1 @ret_undef()
  br i1 %cond, label %t, label %e
t:
  ret void
e:
  ret void
}

define i1 @ret_undef2() {
; IS__TUNIT____: Function Attrs: nofree nosync nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@ret_undef2()
; IS__TUNIT____-NEXT:    br i1 true, label [[T:%.*]], label [[E:%.*]]
; IS__TUNIT____:       t:
; IS__TUNIT____-NEXT:    ret i1 undef
; IS__TUNIT____:       e:
; IS__TUNIT____-NEXT:    unreachable
;
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@ret_undef2()
; IS__CGSCC____-NEXT:    br i1 true, label [[T:%.*]], label [[E:%.*]]
; IS__CGSCC____:       t:
; IS__CGSCC____-NEXT:    ret i1 undef
; IS__CGSCC____:       e:
; IS__CGSCC____-NEXT:    unreachable
;
  br i1 true, label %t, label %e
t:
  ret i1 undef
e:
  ret i1 undef
}

; More complicated interproc deduction of undef
define void @cond_br_on_undef_interproc2() {
; IS__TUNIT____: Function Attrs: nofree noreturn nosync nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@cond_br_on_undef_interproc2()
; IS__TUNIT____-NEXT:    unreachable
; IS__TUNIT____:       t:
; IS__TUNIT____-NEXT:    unreachable
; IS__TUNIT____:       e:
; IS__TUNIT____-NEXT:    unreachable
;
; IS__CGSCC____: Function Attrs: nofree norecurse noreturn nosync nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@cond_br_on_undef_interproc2()
; IS__CGSCC____-NEXT:    unreachable
; IS__CGSCC____:       t:
; IS__CGSCC____-NEXT:    unreachable
; IS__CGSCC____:       e:
; IS__CGSCC____-NEXT:    unreachable
;
  %cond = call i1 @ret_undef2()
  br i1 %cond, label %t, label %e
t:
  ret void
e:
  ret void
}

; Branch on undef that depends on propagation of
; undef of a previous instruction.
define i32 @cond_br_on_undef3() {
; IS__TUNIT____: Function Attrs: nofree nosync nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@cond_br_on_undef3()
; IS__TUNIT____-NEXT:    br label [[T:%.*]]
; IS__TUNIT____:       t:
; IS__TUNIT____-NEXT:    ret i32 1
; IS__TUNIT____:       e:
; IS__TUNIT____-NEXT:    unreachable
;
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@cond_br_on_undef3()
; IS__CGSCC____-NEXT:    br label [[T:%.*]]
; IS__CGSCC____:       t:
; IS__CGSCC____-NEXT:    ret i32 1
; IS__CGSCC____:       e:
; IS__CGSCC____-NEXT:    unreachable
;
  %cond = icmp ne i32 1, undef
  br i1 %cond, label %t, label %e
t:
  ret i32 1
e:
  ret i32 2
}

; Branch on undef because of uninitialized value.
; FIXME: Currently it doesn't propagate the undef.
define i32 @cond_br_on_undef_uninit() {
; IS__TUNIT____: Function Attrs: nofree nosync nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@cond_br_on_undef_uninit()
; IS__TUNIT____-NEXT:    [[ALLOC:%.*]] = alloca i1, align 1
; IS__TUNIT____-NEXT:    [[COND:%.*]] = load i1, i1* [[ALLOC]], align 1
; IS__TUNIT____-NEXT:    br i1 [[COND]], label [[T:%.*]], label [[E:%.*]]
; IS__TUNIT____:       t:
; IS__TUNIT____-NEXT:    ret i32 1
; IS__TUNIT____:       e:
; IS__TUNIT____-NEXT:    ret i32 2
;
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@cond_br_on_undef_uninit()
; IS__CGSCC____-NEXT:    [[ALLOC:%.*]] = alloca i1, align 1
; IS__CGSCC____-NEXT:    [[COND:%.*]] = load i1, i1* [[ALLOC]], align 1
; IS__CGSCC____-NEXT:    br i1 [[COND]], label [[T:%.*]], label [[E:%.*]]
; IS__CGSCC____:       t:
; IS__CGSCC____-NEXT:    ret i32 1
; IS__CGSCC____:       e:
; IS__CGSCC____-NEXT:    ret i32 2
;
  %alloc = alloca i1
  %cond = load i1, i1* %alloc
  br i1 %cond, label %t, label %e
t:
  ret i32 1
e:
  ret i32 2
}

; Note that the `load` has UB (so it will be changed to unreachable)
; and the branch is a terminator that can be constant-folded.
; We want to test that doing both won't cause a segfault.
; MODULE-NOT: @callee(
define internal i32 @callee(i1 %C, i32* %A) {
;
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@callee()
; IS__CGSCC____-NEXT:  entry:
; IS__CGSCC____-NEXT:    unreachable
; IS__CGSCC____:       T:
; IS__CGSCC____-NEXT:    unreachable
; IS__CGSCC____:       F:
; IS__CGSCC____-NEXT:    ret i32 1
;
entry:
  %A.0 = load i32, i32* null
  br i1 %C, label %T, label %F

T:
  ret i32 %A.0

F:
  ret i32 1
}

define i32 @foo() {
; IS__TUNIT____: Function Attrs: nofree nosync nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@foo()
; IS__TUNIT____-NEXT:    ret i32 1
;
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@foo()
; IS__CGSCC____-NEXT:    ret i32 1
;
  %X = call i32 @callee(i1 false, i32* null)
  ret i32 %X
}

; Tests for nonnull attribute violation.

define void @arg_nonnull_1(i32* nonnull %a) {
; IS__TUNIT____: Function Attrs: argmemonly nofree nosync nounwind willreturn writeonly
; IS__TUNIT____-LABEL: define {{[^@]+}}@arg_nonnull_1
; IS__TUNIT____-SAME: (i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[A:%.*]])
; IS__TUNIT____-NEXT:    store i32 0, i32* [[A]], align 4
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____: Function Attrs: argmemonly nofree norecurse nosync nounwind willreturn writeonly
; IS__CGSCC____-LABEL: define {{[^@]+}}@arg_nonnull_1
; IS__CGSCC____-SAME: (i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[A:%.*]])
; IS__CGSCC____-NEXT:    store i32 0, i32* [[A]], align 4
; IS__CGSCC____-NEXT:    ret void
;
  store i32 0, i32* %a
  ret void
}

define void @arg_nonnull_1_noundef_1(i32* nonnull noundef %a) {
; IS__TUNIT____: Function Attrs: argmemonly nofree nosync nounwind willreturn writeonly
; IS__TUNIT____-LABEL: define {{[^@]+}}@arg_nonnull_1_noundef_1
; IS__TUNIT____-SAME: (i32* nocapture nofree noundef nonnull writeonly align 4 dereferenceable(4) [[A:%.*]])
; IS__TUNIT____-NEXT:    store i32 0, i32* [[A]], align 4
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____: Function Attrs: argmemonly nofree norecurse nosync nounwind willreturn writeonly
; IS__CGSCC____-LABEL: define {{[^@]+}}@arg_nonnull_1_noundef_1
; IS__CGSCC____-SAME: (i32* nocapture nofree noundef nonnull writeonly align 4 dereferenceable(4) [[A:%.*]])
; IS__CGSCC____-NEXT:    store i32 0, i32* [[A]], align 4
; IS__CGSCC____-NEXT:    ret void
;
  store i32 0, i32* %a
  ret void
}

define void @arg_nonnull_12(i32* nonnull %a, i32* nonnull %b, i32* %c) {
; IS__TUNIT____: Function Attrs: argmemonly nofree nosync nounwind willreturn writeonly
; IS__TUNIT____-LABEL: define {{[^@]+}}@arg_nonnull_12
; IS__TUNIT____-SAME: (i32* nocapture nofree nonnull writeonly [[A:%.*]], i32* nocapture nofree nonnull writeonly [[B:%.*]], i32* nofree writeonly [[C:%.*]])
; IS__TUNIT____-NEXT:    [[D:%.*]] = icmp eq i32* [[C]], null
; IS__TUNIT____-NEXT:    br i1 [[D]], label [[T:%.*]], label [[F:%.*]]
; IS__TUNIT____:       t:
; IS__TUNIT____-NEXT:    store i32 0, i32* [[A]], align 4
; IS__TUNIT____-NEXT:    br label [[RET:%.*]]
; IS__TUNIT____:       f:
; IS__TUNIT____-NEXT:    store i32 1, i32* [[B]], align 4
; IS__TUNIT____-NEXT:    br label [[RET]]
; IS__TUNIT____:       ret:
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____: Function Attrs: argmemonly nofree norecurse nosync nounwind willreturn writeonly
; IS__CGSCC____-LABEL: define {{[^@]+}}@arg_nonnull_12
; IS__CGSCC____-SAME: (i32* nocapture nofree nonnull writeonly [[A:%.*]], i32* nocapture nofree nonnull writeonly [[B:%.*]], i32* nofree writeonly [[C:%.*]])
; IS__CGSCC____-NEXT:    [[D:%.*]] = icmp eq i32* [[C]], null
; IS__CGSCC____-NEXT:    br i1 [[D]], label [[T:%.*]], label [[F:%.*]]
; IS__CGSCC____:       t:
; IS__CGSCC____-NEXT:    store i32 0, i32* [[A]], align 4
; IS__CGSCC____-NEXT:    br label [[RET:%.*]]
; IS__CGSCC____:       f:
; IS__CGSCC____-NEXT:    store i32 1, i32* [[B]], align 4
; IS__CGSCC____-NEXT:    br label [[RET]]
; IS__CGSCC____:       ret:
; IS__CGSCC____-NEXT:    ret void
;
  %d = icmp eq i32* %c, null
  br i1 %d, label %t, label %f
t:
  store i32 0, i32* %a
  br label %ret
f:
  store i32 1, i32* %b
  br label %ret
ret:
  ret void
}

define void @arg_nonnull_12_noundef_2(i32* nonnull %a, i32* noundef nonnull %b, i32* %c) {
; IS__TUNIT____: Function Attrs: argmemonly nofree nosync nounwind willreturn writeonly
; IS__TUNIT____-LABEL: define {{[^@]+}}@arg_nonnull_12_noundef_2
; IS__TUNIT____-SAME: (i32* nocapture nofree nonnull writeonly [[A:%.*]], i32* nocapture nofree noundef nonnull writeonly [[B:%.*]], i32* nofree writeonly [[C:%.*]])
; IS__TUNIT____-NEXT:    [[D:%.*]] = icmp eq i32* [[C]], null
; IS__TUNIT____-NEXT:    br i1 [[D]], label [[T:%.*]], label [[F:%.*]]
; IS__TUNIT____:       t:
; IS__TUNIT____-NEXT:    store i32 0, i32* [[A]], align 4
; IS__TUNIT____-NEXT:    br label [[RET:%.*]]
; IS__TUNIT____:       f:
; IS__TUNIT____-NEXT:    store i32 1, i32* [[B]], align 4
; IS__TUNIT____-NEXT:    br label [[RET]]
; IS__TUNIT____:       ret:
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____: Function Attrs: argmemonly nofree norecurse nosync nounwind willreturn writeonly
; IS__CGSCC____-LABEL: define {{[^@]+}}@arg_nonnull_12_noundef_2
; IS__CGSCC____-SAME: (i32* nocapture nofree nonnull writeonly [[A:%.*]], i32* nocapture nofree noundef nonnull writeonly [[B:%.*]], i32* nofree writeonly [[C:%.*]])
; IS__CGSCC____-NEXT:    [[D:%.*]] = icmp eq i32* [[C]], null
; IS__CGSCC____-NEXT:    br i1 [[D]], label [[T:%.*]], label [[F:%.*]]
; IS__CGSCC____:       t:
; IS__CGSCC____-NEXT:    store i32 0, i32* [[A]], align 4
; IS__CGSCC____-NEXT:    br label [[RET:%.*]]
; IS__CGSCC____:       f:
; IS__CGSCC____-NEXT:    store i32 1, i32* [[B]], align 4
; IS__CGSCC____-NEXT:    br label [[RET]]
; IS__CGSCC____:       ret:
; IS__CGSCC____-NEXT:    ret void
;
  %d = icmp eq i32* %c, null
  br i1 %d, label %t, label %f
t:
  store i32 0, i32* %a
  br label %ret
f:
  store i32 1, i32* %b
  br label %ret
ret:
  ret void
}

; Pass null directly to argument with nonnull attribute
define void @arg_nonnull_violation1_1() {
; IS__TUNIT____: Function Attrs: nofree nosync nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@arg_nonnull_violation1_1()
; IS__TUNIT____-NEXT:    call void @arg_nonnull_1(i32* noalias nocapture nofree nonnull writeonly align 536870912 null)
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@arg_nonnull_violation1_1()
; IS__CGSCC____-NEXT:    call void @arg_nonnull_1(i32* noalias nocapture nofree nonnull writeonly align 536870912 dereferenceable(4) null)
; IS__CGSCC____-NEXT:    ret void
;
  call void @arg_nonnull_1(i32* null)
  ret void
}

define void @arg_nonnull_violation1_2() {
; IS__TUNIT____: Function Attrs: nofree nosync nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@arg_nonnull_violation1_2()
; IS__TUNIT____-NEXT:    unreachable
;
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@arg_nonnull_violation1_2()
; IS__CGSCC____-NEXT:    unreachable
;
  call void @arg_nonnull_1_noundef_1(i32* null)
  ret void
}

; A case that depends on value simplification
define void @arg_nonnull_violation2_1(i1 %c) {
; IS__TUNIT____: Function Attrs: nofree nosync nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@arg_nonnull_violation2_1
; IS__TUNIT____-SAME: (i1 [[C:%.*]])
; IS__TUNIT____-NEXT:    call void @arg_nonnull_1(i32* nocapture nofree nonnull writeonly align 536870912 null)
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@arg_nonnull_violation2_1
; IS__CGSCC____-SAME: (i1 [[C:%.*]])
; IS__CGSCC____-NEXT:    call void @arg_nonnull_1(i32* nocapture nofree nonnull writeonly align 536870912 dereferenceable(4) null)
; IS__CGSCC____-NEXT:    ret void
;
  %null = getelementptr i32, i32* null, i32 0
  %mustnull = select i1 %c, i32* null, i32* %null
  call void @arg_nonnull_1(i32* %mustnull)
  ret void
}

define void @arg_nonnull_violation2_2(i1 %c) {
; IS__TUNIT____: Function Attrs: nofree nosync nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@arg_nonnull_violation2_2
; IS__TUNIT____-SAME: (i1 [[C:%.*]])
; IS__TUNIT____-NEXT:    unreachable
;
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@arg_nonnull_violation2_2
; IS__CGSCC____-SAME: (i1 [[C:%.*]])
; IS__CGSCC____-NEXT:    unreachable
;
  %null = getelementptr i32, i32* null, i32 0
  %mustnull = select i1 %c, i32* null, i32* %null
  call void @arg_nonnull_1_noundef_1(i32* %mustnull)
  ret void
}

; Cases for single and multiple violation at a callsite
define void @arg_nonnull_violation3_1(i1 %c) {
; IS__TUNIT____: Function Attrs: nofree nosync nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@arg_nonnull_violation3_1
; IS__TUNIT____-SAME: (i1 [[C:%.*]])
; IS__TUNIT____-NEXT:    [[PTR:%.*]] = alloca i32, align 4
; IS__TUNIT____-NEXT:    br i1 [[C]], label [[T:%.*]], label [[F:%.*]]
; IS__TUNIT____:       t:
; IS__TUNIT____-NEXT:    call void @arg_nonnull_12(i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]], i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]], i32* nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]])
; IS__TUNIT____-NEXT:    call void @arg_nonnull_12(i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]], i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]], i32* noalias nocapture nofree writeonly align 536870912 null)
; IS__TUNIT____-NEXT:    call void @arg_nonnull_12(i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]], i32* noalias nocapture nofree nonnull writeonly align 536870912 null, i32* nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]])
; IS__TUNIT____-NEXT:    call void @arg_nonnull_12(i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]], i32* noalias nocapture nofree nonnull writeonly align 536870912 null, i32* noalias nocapture nofree writeonly align 536870912 null)
; IS__TUNIT____-NEXT:    br label [[RET:%.*]]
; IS__TUNIT____:       f:
; IS__TUNIT____-NEXT:    call void @arg_nonnull_12(i32* noalias nocapture nofree nonnull writeonly align 536870912 null, i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]], i32* nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]])
; IS__TUNIT____-NEXT:    call void @arg_nonnull_12(i32* noalias nocapture nofree nonnull writeonly align 536870912 null, i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]], i32* noalias nocapture nofree writeonly align 536870912 null)
; IS__TUNIT____-NEXT:    call void @arg_nonnull_12(i32* noalias nocapture nofree nonnull writeonly align 536870912 null, i32* noalias nocapture nofree nonnull writeonly align 536870912 null, i32* nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]])
; IS__TUNIT____-NEXT:    call void @arg_nonnull_12(i32* noalias nocapture nofree nonnull writeonly align 536870912 null, i32* noalias nocapture nofree nonnull writeonly align 536870912 null, i32* noalias nocapture nofree writeonly align 536870912 null)
; IS__TUNIT____-NEXT:    br label [[RET]]
; IS__TUNIT____:       ret:
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@arg_nonnull_violation3_1
; IS__CGSCC____-SAME: (i1 [[C:%.*]])
; IS__CGSCC____-NEXT:    [[PTR:%.*]] = alloca i32, align 4
; IS__CGSCC____-NEXT:    br i1 [[C]], label [[T:%.*]], label [[F:%.*]]
; IS__CGSCC____:       t:
; IS__CGSCC____-NEXT:    call void @arg_nonnull_12(i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]], i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]], i32* nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]])
; IS__CGSCC____-NEXT:    call void @arg_nonnull_12(i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]], i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]], i32* noalias nocapture nofree writeonly align 536870912 null)
; IS__CGSCC____-NEXT:    call void @arg_nonnull_12(i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]], i32* noalias nocapture nofree nonnull writeonly align 536870912 null, i32* nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]])
; IS__CGSCC____-NEXT:    call void @arg_nonnull_12(i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]], i32* noalias nocapture nofree nonnull writeonly align 536870912 null, i32* noalias nocapture nofree writeonly align 536870912 null)
; IS__CGSCC____-NEXT:    br label [[RET:%.*]]
; IS__CGSCC____:       f:
; IS__CGSCC____-NEXT:    call void @arg_nonnull_12(i32* noalias nocapture nofree nonnull writeonly align 536870912 null, i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]], i32* nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]])
; IS__CGSCC____-NEXT:    call void @arg_nonnull_12(i32* noalias nocapture nofree nonnull writeonly align 536870912 null, i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]], i32* noalias nocapture nofree writeonly align 536870912 null)
; IS__CGSCC____-NEXT:    call void @arg_nonnull_12(i32* noalias nocapture nofree nonnull writeonly align 536870912 null, i32* noalias nocapture nofree nonnull writeonly align 536870912 null, i32* nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]])
; IS__CGSCC____-NEXT:    call void @arg_nonnull_12(i32* noalias nocapture nofree nonnull writeonly align 536870912 null, i32* noalias nocapture nofree nonnull writeonly align 536870912 null, i32* noalias nocapture nofree writeonly align 536870912 null)
; IS__CGSCC____-NEXT:    br label [[RET]]
; IS__CGSCC____:       ret:
; IS__CGSCC____-NEXT:    ret void
;
  %ptr = alloca i32
  br i1 %c, label %t, label %f
t:
  call void @arg_nonnull_12(i32* %ptr, i32* %ptr, i32* %ptr)
  call void @arg_nonnull_12(i32* %ptr, i32* %ptr, i32* null)
  call void @arg_nonnull_12(i32* %ptr, i32* null, i32* %ptr)
  call void @arg_nonnull_12(i32* %ptr, i32* null, i32* null)
  br label %ret
f:
  call void @arg_nonnull_12(i32* null, i32* %ptr, i32* %ptr)
  call void @arg_nonnull_12(i32* null, i32* %ptr, i32* null)
  call void @arg_nonnull_12(i32* null, i32* null, i32* %ptr)
  call void @arg_nonnull_12(i32* null, i32* null, i32* null)
  br label %ret
ret:
  ret void
}

define void @arg_nonnull_violation3_2(i1 %c) {
; IS__TUNIT____: Function Attrs: nofree nosync nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@arg_nonnull_violation3_2
; IS__TUNIT____-SAME: (i1 [[C:%.*]])
; IS__TUNIT____-NEXT:    [[PTR:%.*]] = alloca i32, align 4
; IS__TUNIT____-NEXT:    br i1 [[C]], label [[T:%.*]], label [[F:%.*]]
; IS__TUNIT____:       t:
; IS__TUNIT____-NEXT:    call void @arg_nonnull_12_noundef_2(i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]], i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]], i32* nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]])
; IS__TUNIT____-NEXT:    call void @arg_nonnull_12_noundef_2(i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]], i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]], i32* noalias nocapture nofree writeonly align 536870912 null)
; IS__TUNIT____-NEXT:    unreachable
; IS__TUNIT____:       f:
; IS__TUNIT____-NEXT:    call void @arg_nonnull_12_noundef_2(i32* noalias nocapture nofree nonnull writeonly align 536870912 null, i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]], i32* nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]])
; IS__TUNIT____-NEXT:    call void @arg_nonnull_12_noundef_2(i32* noalias nocapture nofree nonnull writeonly align 536870912 null, i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]], i32* noalias nocapture nofree writeonly align 536870912 null)
; IS__TUNIT____-NEXT:    unreachable
; IS__TUNIT____:       ret:
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@arg_nonnull_violation3_2
; IS__CGSCC____-SAME: (i1 [[C:%.*]])
; IS__CGSCC____-NEXT:    [[PTR:%.*]] = alloca i32, align 4
; IS__CGSCC____-NEXT:    br i1 [[C]], label [[T:%.*]], label [[F:%.*]]
; IS__CGSCC____:       t:
; IS__CGSCC____-NEXT:    call void @arg_nonnull_12_noundef_2(i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]], i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]], i32* nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]])
; IS__CGSCC____-NEXT:    call void @arg_nonnull_12_noundef_2(i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]], i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]], i32* noalias nocapture nofree writeonly align 536870912 null)
; IS__CGSCC____-NEXT:    unreachable
; IS__CGSCC____:       f:
; IS__CGSCC____-NEXT:    call void @arg_nonnull_12_noundef_2(i32* noalias nocapture nofree nonnull writeonly align 536870912 null, i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]], i32* nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]])
; IS__CGSCC____-NEXT:    call void @arg_nonnull_12_noundef_2(i32* noalias nocapture nofree nonnull writeonly align 536870912 null, i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[PTR]], i32* noalias nocapture nofree writeonly align 536870912 null)
; IS__CGSCC____-NEXT:    unreachable
; IS__CGSCC____:       ret:
; IS__CGSCC____-NEXT:    ret void
;
  %ptr = alloca i32
  br i1 %c, label %t, label %f
t:
  call void @arg_nonnull_12_noundef_2(i32* %ptr, i32* %ptr, i32* %ptr)
  call void @arg_nonnull_12_noundef_2(i32* %ptr, i32* %ptr, i32* null)
  call void @arg_nonnull_12_noundef_2(i32* %ptr, i32* null, i32* %ptr)
  call void @arg_nonnull_12_noundef_2(i32* %ptr, i32* null, i32* null)
  br label %ret
f:
  call void @arg_nonnull_12_noundef_2(i32* null, i32* %ptr, i32* %ptr)
  call void @arg_nonnull_12_noundef_2(i32* null, i32* %ptr, i32* null)
  call void @arg_nonnull_12_noundef_2(i32* null, i32* null, i32* %ptr)
  call void @arg_nonnull_12_noundef_2(i32* null, i32* null, i32* null)
  br label %ret
ret:
  ret void
}
