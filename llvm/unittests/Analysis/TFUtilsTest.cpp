//===- TFUtilsTest.cpp - test for TFUtils ---------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "llvm/Analysis/Utils/TFUtils.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Testing/Support/SupportHelpers.h"
#include "gtest/gtest.h"

using namespace llvm;

extern const char *TestMainArgv0;

static std::string getModelPath() {
  SmallString<128> InputsDir = unittest::getInputFileDirectory(TestMainArgv0);
  llvm::sys::path::append(InputsDir, "ir2native_x86_64_model");
  return std::string(InputsDir);
}

// Test observable behavior when no model is provided.
TEST(TFUtilsTest, NoModel) {
  TFModelEvaluator Evaluator("", {}, {});
  EXPECT_FALSE(Evaluator.isValid());
}

// Test we can correctly load a savedmodel and evaluate it.
TEST(TFUtilsTest, LoadAndExecuteTest) {
  // We use the ir2native model for test. We know it has one feature of
  // dimension (1, 214)
  const static int64_t KnownSize = 214;
  std::vector<TensorSpec> InputSpecs{TensorSpec::createSpec<int32_t>(
      "serving_default_input_1", {1, KnownSize})};
  std::vector<TensorSpec> OutputSpecs{
      TensorSpec::createSpec<float>("StatefulPartitionedCall", {1})};

  TFModelEvaluator Evaluator(getModelPath(), InputSpecs, OutputSpecs);
  EXPECT_TRUE(Evaluator.isValid());

  int32_t *V = Evaluator.getInput<int32_t>(0);
  // Fill it up with 1's, we know the output.
  for (auto I = 0; I < KnownSize; ++I) {
    V[I] = 1;
  }
  {
    auto ER = Evaluator.evaluate();
    EXPECT_TRUE(ER.hasValue());
    float Ret = *ER->getTensorValue<float>(0);
    EXPECT_EQ(static_cast<size_t>(Ret), 80);
  }
  // The input vector should be unchanged
  for (auto I = 0; I < KnownSize; ++I) {
    EXPECT_EQ(V[I], 1);
  }
  // Zero-out the unused position '0' of the instruction histogram, which is
  // after the first 9 calculated values. Should the the same result.
  V[9] = 0;
  {
    auto ER = Evaluator.evaluate();
    EXPECT_TRUE(ER.hasValue());
    float Ret = *ER->getTensorValue<float>(0);
    EXPECT_EQ(static_cast<size_t>(Ret), 80);
  }
}

// Test incorrect input setup
TEST(TFUtilsTest, EvalError) {
  // We use the ir2native model for test. We know it has one feature of
  // dimension (1, 214)
  const static int64_t KnownSize = 213;
  std::vector<TensorSpec> InputSpecs{TensorSpec::createSpec<int32_t>(
      "serving_default_input_1", {1, KnownSize})};
  std::vector<TensorSpec> OutputSpecs{
      TensorSpec::createSpec<float>("StatefulPartitionedCall", {1})};

  TFModelEvaluator Evaluator(getModelPath(), InputSpecs, OutputSpecs);
  EXPECT_TRUE(Evaluator.isValid());

  int32_t *V = Evaluator.getInput<int32_t>(0);
  // Fill it up with 1's, we know the output.
  for (auto I = 0; I < KnownSize; ++I) {
    V[I] = 1;
  }
  auto ER = Evaluator.evaluate();
  EXPECT_FALSE(ER.hasValue());
  EXPECT_FALSE(Evaluator.isValid());
}

TEST(TFUtilsTest, JSONParsing) {
  auto Value = json::parse(
      R"({"name": "tensor_name", 
        "port": 2, 
        "type": "int32", 
        "shape":[1,4]
        })");
  EXPECT_TRUE(!!Value);
  LLVMContext Ctx;
  Optional<TensorSpec> Spec = getTensorSpecFromJSON(Ctx, *Value);
  EXPECT_TRUE(Spec.hasValue());
  EXPECT_EQ(*Spec, TensorSpec::createSpec<int32_t>("tensor_name", {1, 4}, 2));
}

TEST(TFUtilsTest, JSONParsingInvalidTensorType) {
  auto Value = json::parse(
      R"(
        {"name": "tensor_name", 
        "port": 2, 
        "type": "no such type", 
        "shape":[1,4]
        }
      )");
  EXPECT_TRUE(!!Value);
  LLVMContext Ctx;
  auto Spec = getTensorSpecFromJSON(Ctx, *Value);
  EXPECT_FALSE(Spec.hasValue());
}

TEST(TFUtilsTest, TensorSpecSizesAndTypes) {
  auto Spec1D = TensorSpec::createSpec<int16_t>("Hi1", {1});
  auto Spec2D = TensorSpec::createSpec<int16_t>("Hi2", {1, 1});
  auto Spec1DLarge = TensorSpec::createSpec<float>("Hi3", {10});
  auto Spec3DLarge = TensorSpec::createSpec<float>("Hi3", {2, 4, 10});
  EXPECT_TRUE(Spec1D.isElementType<int16_t>());
  EXPECT_FALSE(Spec3DLarge.isElementType<double>());
  EXPECT_EQ(Spec1D.getElementCount(), 1);
  EXPECT_EQ(Spec2D.getElementCount(), 1);
  EXPECT_EQ(Spec1DLarge.getElementCount(), 10);
  EXPECT_EQ(Spec3DLarge.getElementCount(), 80);
  EXPECT_EQ(Spec3DLarge.getElementByteSize(), sizeof(float));
  EXPECT_EQ(Spec1D.getElementByteSize(), sizeof(int16_t));
}