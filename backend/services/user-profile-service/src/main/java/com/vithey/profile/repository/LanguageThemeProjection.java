package com.vithey.profile.repository;

import com.vithey.profile.entity.AppLanguage;
import com.vithey.profile.entity.AppTheme;

public interface LanguageThemeProjection {

  AppLanguage getLanguage();

  AppTheme getTheme();
}
