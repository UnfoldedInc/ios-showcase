// Copyright (c) 2020 Unfolded, Inc.
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

#ifndef DECKGL_CORE_LIB_ATTRIBUTE_ATTRIBUTE_MANAGER_H
#define DECKGL_CORE_LIB_ATTRIBUTE_ATTRIBUTE_MANAGER_H

#include <arrow/table.h>

#include <memory>
#include <string>
#include <vector>

#include "luma.gl/garrow.h"

namespace deckgl {

/*
 * Automated attribute generation and management. Suitable when a set of
 * vertex shader attributes are generated by iteration over a data array,
 * and updates to these attributes are needed either when the data itself
 * changes, or when other data relevant to the calculations change.
 *
 * - First the application registers descriptions of its dynamic vertex
 *   attributes using AttributeManager.add().
 * - Then, when any change that affects attributes is detected by the
 *   application, the app will call AttributeManager.invalidate().
 * - Finally before it renders, it calls AttributeManager.update() to
 *   ensure that attributes are automatically rebuilt if anything has been
 *   invalidated.
 *
 * The application provided update functions describe how attributes
 * should be updated from a data array and are expected to traverse
 * that data array (or iterable) and fill in the attribute's typed array.
 *
 * Note that the attribute manager intentionally does not do advanced
 * change detection, but instead makes it easy to build such detection
 * by offering the ability to "invalidate" each attribute separately.
 */
class AttributeManager {
 public:
  AttributeManager(const std::string& id, wgpu::Device device) : id{id}, device{device} {}

  auto getNeedsRedraw(bool clearRedrawFlags = false) -> bool;
  void setNeedsRedraw();

  void add(const lumagl::garrow::ColumnBuilder& builder);

  void invalidate(const std::string& attributeName);
  void invalidateAll();

  auto update(const std::shared_ptr<arrow::Table>& table) -> std::shared_ptr<lumagl::garrow::Table>;

  std::string id;
  wgpu::Device device;

 private:
  bool _needsRedraw{false};
  std::vector<lumagl::garrow::ColumnBuilder> _builders;
};

}  // namespace deckgl

#endif  // DECKGL_CORE_LIB_ATTRIBUTE_ATTRIBUTE_MANAGER_H
