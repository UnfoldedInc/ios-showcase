// Copyright (c) 2020 Unfolded Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ManhattanPopulationDeck.h"

#include <arrow/filesystem/localfs.h>

#include "deck.gl/core.h"
#include "deck.gl/layers.h"
#include "loaders.gl/json.h"

using namespace deckgl;

#pragma mark - Utility

namespace {

loadersgl::JSONLoader jsonLoader;
auto fileSystem = std::make_shared<arrow::fs::LocalFileSystem>();

const mathgl::Vector4<float> maleColor{0.0f, 128.0f, 255.0f, 255.0f};
const mathgl::Vector4<float> femaleColor{255.0f, 0.0f, 128.0f, 255.0f};

auto createViewState(double bearing) -> std::shared_ptr<ViewState> {
  auto viewState = std::make_shared<ViewState>();
  viewState->latitude = 40.76f;
  viewState->longitude = -73.97f;
  viewState->zoom = 11.0f;
  viewState->pitch = 30.0f;
  viewState->bearing = bearing;

  return viewState;
}

auto createScatterplotLayer(const std::string &dataPath) -> std::shared_ptr<ScatterplotLayer::Props> {
  auto props = std::make_shared<ScatterplotLayer::Props>();
  props->id = "population";
  props->radiusScale = 30.0f;
  props->radiusMinPixels = 0.25f;
  props->getPosition = [](const Row &row) { return row.getVector3<float>("pos"); };
  props->getRadius = [](const Row &row) { return 1.0f; };
  props->getFillColor = [](const Row &row) { return row.getInt("gender") == 1 ? maleColor : femaleColor; };

  props->data = jsonLoader.loadTable(fileSystem->OpenInputStream(dataPath).ValueOrDie());

  return props;
}

}  // anonymous namespace

@interface ManhattanPopulationDeck ()

@property (nonatomic) std::shared_ptr<Deck> deck;

@end

@implementation ManhattanPopulationDeck

#pragma mark - DeckWrapper implementation

- (void)run:(MTKView *)view {
  auto populationDataPath = std::string([[[NSBundle mainBundle] pathForResource:@"manhattan" ofType:@"ndjson"] UTF8String]);

  auto deckProps = std::make_shared<Deck::Props>();
  deckProps->id = "Manhattan Population";
  deckProps->layers = {createScatterplotLayer(populationDataPath)};
  deckProps->initialViewState = createViewState(0.0);
  deckProps->views = {std::make_shared<MapView>()};
  deckProps->width = view.bounds.size.width;
  deckProps->height = view.bounds.size.height;

  deckProps->drawingOptions = std::make_shared<lumagl::MetalAnimationLoop::Options>(view);

  self.deck = std::make_shared<Deck>(deckProps);
  __weak ManhattanPopulationDeck* weakSelf = self;
  dispatch_queue_t renderingQueue = dispatch_queue_create("ai.unfolded.rendering", NULL);
  dispatch_async(renderingQueue, ^{
    weakSelf.deck->run([&deckProps](Deck *deck) {
      static double bearing = 0.0;
      deckProps->viewState = createViewState(bearing += 0.3);
      deck->setProps(deckProps);
    });
  });
}

- (void)stop {
  self.deck->stop();
}

- (void)setWidth:(int)width height:(int)height {
  auto deckProps = self.deck->props();
  deckProps->width = width;
  deckProps->height = height;

  self.deck->setProps(deckProps);
}

- (void)dealloc {
  [self stop];
}

@end
