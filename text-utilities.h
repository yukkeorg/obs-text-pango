#pragma once

#include "text-pango.h"
#include <pango/pangocairo.h>
#include <util/platform.h>
#include <obs-module.h>


#define RGBA_CAIRO(c) \
	 (c & 0xff) / 256.0, \
	((c & 0xff00) >> 8) / 256.0, \
	((c & 0xff0000) >> 16) / 256.0, \
	((c & 0xff000000) >> 24) / 256.0

cairo_t *create_layout_context()
{
	cairo_surface_t *temp_surface;
	cairo_t *context;

	temp_surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 0, 0);
	context = cairo_create(temp_surface);
	cairo_surface_destroy(temp_surface);

	return context;
}

cairo_t *create_render_context(struct pango_source *src,
	cairo_surface_t **surface, uint8_t **surface_data)
{
	*surface_data = bzalloc(src->width * src->height * 4);
	*surface = cairo_image_surface_create_for_data(*surface_data,
			CAIRO_FORMAT_ARGB32,
			src->width, src->height, 4 * src->width);

	return cairo_create(*surface);
}

static void get_rendered_text_size(PangoLayout *layout, int *width, int *height)
{
	int w, h;

	pango_layout_get_size (layout, &w, &h);
	/* Divide by pango scale to get dimensions in pixels */
	*width = w / PANGO_SCALE;
	*height = h / PANGO_SCALE;
}

static void set_font(struct pango_source *src, PangoLayout *layout) {
	PangoFontDescription *desc;

	desc = pango_font_description_new ();
	pango_font_description_set_family(desc, src->font_name);
	pango_font_description_set_size(desc, src->font_size * PANGO_SCALE);
	pango_font_description_set_weight(desc, !!(src->font_flags & OBS_FONT_BOLD) ? PANGO_WEIGHT_BOLD : 0);
	pango_font_description_set_style(desc, !!(src->font_flags & OBS_FONT_ITALIC) ? PANGO_STYLE_ITALIC : 0);
	pango_layout_set_font_description(layout, desc);
	pango_font_description_free(desc);
}

static void set_halignment(struct pango_source *src, PangoLayout *layout) {
	PangoAlignment pangoAlignment;

	switch (src->align) {
	case ALIGN_RIGHT:
		pangoAlignment = PANGO_ALIGN_RIGHT;
		break;
	case ALIGN_CENTER:
		pangoAlignment = PANGO_ALIGN_CENTER;
		break;
	default:
		pangoAlignment = PANGO_ALIGN_LEFT;	
	}
	pango_layout_set_alignment(layout, pangoAlignment);
}

static bool pango_source_properties_outline_changed(obs_properties_t *props,
		obs_property_t *property, obs_data_t *settings)
{
	UNUSED_PARAMETER(property);
	obs_property_t *prop;

	bool enabled = obs_data_get_bool(settings, "outline");

	prop = obs_properties_get(props, "outline_width");
	obs_property_set_visible(prop, enabled);
	prop = obs_properties_get(props, "outline_color");
	obs_property_set_visible(prop, enabled);

	return true;
}

static bool pango_source_properties_drop_shadow_changed(obs_properties_t *props,
		obs_property_t *property, obs_data_t *settings)
{
	UNUSED_PARAMETER(property);
	obs_property_t *prop;

	bool enabled = obs_data_get_bool(settings, "drop_shadow");

	prop = obs_properties_get(props, "drop_shadow_offset");
	obs_property_set_visible(prop, enabled);
	prop = obs_properties_get(props, "drop_shadow_color");
	obs_property_set_visible(prop, enabled);

	return true;
}

static bool pango_source_properties_gradient_changed(obs_properties_t *props,
		obs_property_t *property, obs_data_t *settings)
{
	UNUSED_PARAMETER(property);
	obs_property_t *prop;

	bool enabled = obs_data_get_bool(settings, "gradient");

	prop = obs_properties_get(props, "color2");
	obs_property_set_visible(prop, enabled);

	return true;
}

static bool pango_source_properties_from_file_changed(obs_properties_t *props,
		obs_property_t *property, obs_data_t *settings)
{
	UNUSED_PARAMETER(property);
	obs_property_t *text_prop,*file_prop;

	bool enabled = obs_data_get_bool(settings, "from_file");

	text_prop = obs_properties_get(props, "text");
	file_prop = obs_properties_get(props, "text_file");
	obs_property_set_visible(text_prop, !enabled);
	obs_property_set_visible(file_prop, enabled);

	return true;
}

static bool pango_source_properties_log_mode_changed(obs_properties_t *props,
		obs_property_t *property, obs_data_t *settings)
{
	UNUSED_PARAMETER(property);
	obs_property_t *lines_prop;

	bool enabled = obs_data_get_bool(settings, "log_mode");

	lines_prop = obs_properties_get(props, "log_lines");
	obs_property_set_visible(lines_prop, enabled);

	return true;
}

static bool read_from_end(char **dst_buf, const char *filename, const int n_lines)
{
	FILE *tmp_file = NULL;
	uint32_t filesize = 0, cur_pos = 0;
	char *tmp_read = NULL;
	uint16_t value = 0, line_breaks = 0;
	size_t bytes_read;
	char bvalue;

	bool utf16 = false;

	tmp_file = fopen(filename, "rb");
	if (tmp_file == NULL) {
		blog(LOG_WARNING, "Failed to open file %s", filename);
		return false;
	}
	bytes_read = fread(&value, 2, 1, tmp_file);

	if (bytes_read == 2 && value == 0xFEFF) // Fails on alternate endianness
		utf16 = true;

	fseek(tmp_file, 0, SEEK_END);
	filesize = (uint32_t)ftell(tmp_file);
	cur_pos = filesize;

	while (line_breaks <= n_lines && cur_pos != 0) {
		if (!utf16) cur_pos--;
		else cur_pos -= 2;
		fseek(tmp_file, cur_pos, SEEK_SET);

		if (!utf16) {
			bytes_read = fread(&bvalue, 1, 1, tmp_file);
			if (bytes_read == 1 && bvalue == '\n')
				line_breaks++;
		}
		else {
			bytes_read = fread(&value, 2, 1, tmp_file);
			if (bytes_read == 2 && value == L'\n')
				line_breaks++;
		}
	}

	if (cur_pos != 0)
		cur_pos += (utf16) ? 2 : 1;

	fseek(tmp_file, cur_pos, SEEK_SET);

	// if (utf16) {
	// 	bytes_read = fread(*dst_buf, (filesize - cur_pos), 1,
	// 			tmp_file);

	// 	*dst_buf = bzalloc(filesize - cur_pos);
	// 	os_wcs_to_utf8(tmp_read, strlen(tmp_read),
	// 		*dst_buf, (filesize - cur_pos));
	
	// 	bfree(tmp_read);
	// 	fclose(tmp_file);
	// 	return true;
	// }

	*dst_buf = bzalloc(filesize - cur_pos + 1);
	bytes_read = fread(*dst_buf, filesize - cur_pos, 1, tmp_file);
	(*dst_buf)[filesize - cur_pos] = 0;
	fclose(tmp_file);
	return true;
}