#-------------------------------------------------------------------------------------------------#
#----------------------- multiple plots with singe rater's ratings -------------------------------#
#------------------------------------- LIDO-TEMPLATES --------------------------------------------#
#-------------------------------------------------------------------------------------------------#

library(ggplot2)
library(dplyr)
library(hrbrthemes)
library(foreign)
library(R.matlab)
library(gridExtra)
library(png)
library(cowplot)
library(magick)




#-------------------------------------------------------------------------------------------------#
#--------------------------------------------- STUDY ---------------------------------------------#
#-------------------------------------------------------------------------------------------------#


# wd and data
setwd("/Users/alex/Dropbox/paperwriting/LIDO/LIDOQA/landmarks/figures/")
landmarks_YY <- readMat('/Users/alex/Dropbox/paperwriting/LIDO/LIDOQA/landmarks/STUDY/Distance_EPILandmarks_YY.mat', 
                        to.data.frame = TRUE)
ED_YY <- landmarks_YY$Distance.export
nSamples <- nrow(ED_YY)

# make df for each ROI
data_TBS <- data.frame(Rater = rep("YY", nSamples), Distance = ED_YY[,2])
data_OBSL <- data.frame(Rater = rep("YY", nSamples), Distance = ED_YY[,3])
data_OBSR <- data.frame(Rater = rep("YY", nSamples), Distance = ED_YY[,4])
data_LCL  <- data.frame(Rater = rep("YY", nSamples), Distance = ED_YY[,5])
data_LCR <- data.frame(Rater = rep("YY", nSamples), Distance = ED_YY[,6])
data_BBS <- data.frame(Rater = rep("YY", nSamples), Distance = ED_YY[,7])

# calc quick stats
m_TBS <- mean(data_TBS$Distance)
sd_TBS <- sd(data_TBS$Distance)
m_OBSL <- mean(data_OBSL$Distance)
sd_OBSL <- sd(data_OBSL$Distance)
m_OBSR <- mean(data_OBSR$Distance)
sd_OBSR <- sd(data_OBSR$Distance)
m_LCL <- mean(data_LCL$Distance)
sd_LCL <- sd(data_LCL$Distance)
m_LCR <- mean(data_LCR$Distance)
sd_LCR <- sd(data_LCR$Distance)
m_BBS <- mean(data_BBS$Distance)
sd_BBS <- sd(data_BBS$Distance)

# define common theme settings and limits
common_theme <- theme(
  plot.title = element_text(hjust = 0.5, size = 20, face = "bold"),
  axis.text.x = element_text(size = 20, face = "bold"),
  axis.text.y = element_text(size = 20, face = "bold"),
  axis.title.x = element_text(size = 20, face = "bold"),
  axis.title.y = element_text(size = 20, face = "bold")
)
xlims <- c(-0.1, 6)
ylims <- c(0, 75)

# draw base plots
p3 <- ggplot(data_TBS, aes(x = Distance, fill = Rater)) +
  geom_histogram(color = "#e9ecef", alpha = 0.6, binwidth = 0.2) +
  scale_fill_manual(values = c("#2d89e0")) +
  common_theme + xlim(xlims) + ylim(ylims) +
  labs(title = "Periaqueductal Grey", x = "mm", y = "Number of scans") +
  theme(legend.position = "none")

p4 <- ggplot(data_OBSL, aes(x = Distance, fill = Rater)) +
  geom_histogram(color = "#e9ecef", alpha = 0.6, binwidth = 0.2) +
  scale_fill_manual(values = c("#2d89e0")) +
  common_theme + xlim(xlims) + ylim(ylims) +
  labs(title = "Outline Brainstem (L)", x = "mm", y = "Number of scans") +
  theme(legend.position = "none")

p5 <- ggplot(data_OBSR, aes(x = Distance, fill = Rater)) +
  geom_histogram(color = "#e9ecef", alpha = 0.6, binwidth = 0.2) +
  scale_fill_manual(values = c("#2d89e0")) +
  common_theme + xlim(xlims) + ylim(ylims) +
  labs(title = "Outline Brainstem (R)", x = "mm", y = "Number of scans") +
  theme(legend.position = c(0.9, 0.25), legend.direction = "vertical", 
        legend.background = element_blank(), legend.text = element_text(face = "bold"), 
        legend.title = element_text(face = "bold"))

p6 <- ggplot(data_LCL, aes(x = Distance, fill = Rater)) +
  geom_histogram(color = "#e9ecef", alpha = 0.6, binwidth = 0.2) +
  scale_fill_manual(values = c("#2d89e0")) +
  common_theme + xlim(xlims) + ylim(ylims) +
  labs(title = "4th Ventricle Border (L)", x = "mm", y = "Number of scans") +
  theme(legend.position = "none") +
  geom_vline(xintercept = 2.5, color = "red", size = 1.2)

p7 <- ggplot(data_LCR, aes(x = Distance, fill = Rater)) +
  geom_histogram(color = "#e9ecef", alpha = 0.6, binwidth = 0.2) +
  scale_fill_manual(values = c("#2d89e0")) +
  common_theme + xlim(xlims) + ylim(ylims) +
  labs(title = "4th Ventricle Border (R)", x = "mm", y = "Number of scans") +
  theme(legend.position = c(0.9, 0.25), legend.direction = "vertical", 
        legend.background = element_blank(), legend.text = element_text(face = "bold"), 
        legend.title = element_text(face = "bold")) +
  geom_vline(xintercept = 2.5, color = "red", size = 1.2)

p8 <- ggplot(data_BBS, aes(x = Distance, fill = Rater)) +
  geom_histogram(color = "#e9ecef", alpha = 0.6, binwidth = 0.2) +
  scale_fill_manual(values = c("#2d89e0")) +
  common_theme + xlim(xlims) + ylim(ylims) +
  labs(title = "Perifastigial Sulcus", x = "mm", y = "Number of scans") +
  theme(legend.position = "none")

# draw inset images with stats underneath using cowplot
# adjust x&y coordinates if the positions are weird
p3_inset <- ggdraw(p3) +
  draw_image("/Users/alex/Dropbox/paperwriting/coreg/figures/PeriaqueductalGrey.png", 
             x = 0.68, y = 0.60, width = 0.3, height = 0.3) +
  draw_label(sprintf("Mean = %.2f\nSD = %.2f", m_TBS, sd_TBS), 
             x = 0.73 + 0.15, y = 0.60 - 0.02, hjust = 0.5, vjust = 1, size = 12)

p4_inset <- ggdraw(p4) +
  draw_image("/Users/alex/Dropbox/paperwriting/coreg/figures/OutlineBrainstem_left.png", 
             x = 0.68, y = 0.60, width = 0.3, height = 0.3) +
  draw_label(sprintf("Mean = %.2f\nSD = %.2f", m_OBSL, sd_OBSL), 
             x = 0.73 + 0.15, y = 0.60 - 0.02, hjust = 0.5, vjust = 1, size = 12)

p5_inset <- ggdraw(p5) +
  draw_image("/Users/alex/Dropbox/paperwriting/coreg/figures/OutlineBrainstem_right.png", 
             x = 0.68, y = 0.60, width = 0.3, height = 0.3) +
  draw_label(sprintf("Mean = %.2f\nSD = %.2f", m_OBSR, sd_OBSR), 
             x = 0.73 + 0.15, y = 0.60 - 0.02, hjust = 0.5, vjust = 1, size = 12)

p6_inset <- ggdraw(p6) +
  draw_image("/Users/alex/Dropbox/paperwriting/coreg/figures/LC_left.png", 
             x = 0.68, y = 0.60, width = 0.3, height = 0.3) +
  draw_label(sprintf("Mean = %.2f\nSD = %.2f", m_LCL, sd_LCL), 
             x = 0.73 + 0.15, y = 0.60 - 0.02, hjust = 0.5, vjust = 1, size = 12)

p7_inset <- ggdraw(p7) +
  draw_image("/Users/alex/Dropbox/paperwriting/coreg/figures/LC_right.png", 
             x = 0.68, y = 0.60, width = 0.3, height = 0.3) +
  draw_label(sprintf("Mean = %.2f\nSD = %.2f", m_LCR, sd_LCR), 
             x = 0.73 + 0.15, y = 0.60 - 0.02, hjust = 0.5, vjust = 1, size = 12)

p8_inset <- ggdraw(p8) +
  draw_image("/Users/alex/Dropbox/paperwriting/coreg/figures/PerifastigialSulcus.png", 
             x = 0.68, y = 0.60, width = 0.3, height = 0.3) +
  draw_label(sprintf("Mean = %.2f\nSD = %.2f", m_BBS, sd_BBS), 
             x = 0.73 + 0.15, y = 0.60 - 0.02, hjust = 0.5, vjust = 1, size = 12)

# assemble
plot_grid(p3_inset, p4_inset, p5_inset, p8_inset, p6_inset, p7_inset, nrow = 2)






#-------------------------------------------------------------------------------------------------#
#---------------------------------------------  YA   ---------------------------------------------#
#-------------------------------------------------------------------------------------------------#


# wd and data
setwd("/Users/alex/Dropbox/paperwriting/LIDO/LIDOQA/landmarks/figures/")
landmarks_YY <- readMat('/Users/alex/Dropbox/paperwriting/LIDO/LIDOQA/landmarks/YA/Distance_EPILandmarks_YY.mat', 
                        to.data.frame = TRUE)
ED_YY <- landmarks_YY$Distance.export
nSamples <- nrow(ED_YY)

# make df for each ROI
data_TBS <- data.frame(Rater = rep("YY", nSamples), Distance = ED_YY[,2])
data_OBSL <- data.frame(Rater = rep("YY", nSamples), Distance = ED_YY[,3])
data_OBSR <- data.frame(Rater = rep("YY", nSamples), Distance = ED_YY[,4])
data_LCL  <- data.frame(Rater = rep("YY", nSamples), Distance = ED_YY[,5])
data_LCR <- data.frame(Rater = rep("YY", nSamples), Distance = ED_YY[,6])
data_BBS <- data.frame(Rater = rep("YY", nSamples), Distance = ED_YY[,7])

# calc quick stats
m_TBS <- mean(data_TBS$Distance)
sd_TBS <- sd(data_TBS$Distance)
m_OBSL <- mean(data_OBSL$Distance)
sd_OBSL <- sd(data_OBSL$Distance)
m_OBSR <- mean(data_OBSR$Distance)
sd_OBSR <- sd(data_OBSR$Distance)
m_LCL <- mean(data_LCL$Distance)
sd_LCL <- sd(data_LCL$Distance)
m_LCR <- mean(data_LCR$Distance)
sd_LCR <- sd(data_LCR$Distance)
m_BBS <- mean(data_BBS$Distance)
sd_BBS <- sd(data_BBS$Distance)

# define common theme settings and limits
common_theme <- theme(
  plot.title = element_text(hjust = 0.5, size = 20, face = "bold"),
  axis.text.x = element_text(size = 20, face = "bold"),
  axis.text.y = element_text(size = 20, face = "bold"),
  axis.title.x = element_text(size = 20, face = "bold"),
  axis.title.y = element_text(size = 20, face = "bold")
)
xlims <- c(-0.1, 6)
ylims <- c(0, 31)

# draw base plots
p3 <- ggplot(data_TBS, aes(x = Distance, fill = Rater)) +
  geom_histogram(color = "#e9ecef", alpha = 0.6, binwidth = 0.2) +
  scale_fill_manual(values = c("#2d89e0")) +
  common_theme + xlim(xlims) + ylim(ylims) +
  labs(title = "Periaqueductal Grey", x = "mm", y = "Number of scans") +
  theme(legend.position = "none")

p4 <- ggplot(data_OBSL, aes(x = Distance, fill = Rater)) +
  geom_histogram(color = "#e9ecef", alpha = 0.6, binwidth = 0.2) +
  scale_fill_manual(values = c("#2d89e0")) +
  common_theme + xlim(xlims) + ylim(ylims) +
  labs(title = "Outline Brainstem (L)", x = "mm", y = "Number of scans") +
  theme(legend.position = "none")

p5 <- ggplot(data_OBSR, aes(x = Distance, fill = Rater)) +
  geom_histogram(color = "#e9ecef", alpha = 0.6, binwidth = 0.2) +
  scale_fill_manual(values = c("#2d89e0")) +
  common_theme + xlim(xlims) + ylim(ylims) +
  labs(title = "Outline Brainstem (R)", x = "mm", y = "Number of scans") +
  theme(legend.position = c(0.9, 0.25), legend.direction = "vertical", 
        legend.background = element_blank(), legend.text = element_text(face = "bold"), 
        legend.title = element_text(face = "bold"))

p6 <- ggplot(data_LCL, aes(x = Distance, fill = Rater)) +
  geom_histogram(color = "#e9ecef", alpha = 0.6, binwidth = 0.2) +
  scale_fill_manual(values = c("#2d89e0")) +
  common_theme + xlim(xlims) + ylim(ylims) +
  labs(title = "4th Ventricle Border (L)", x = "mm", y = "Number of scans") +
  theme(legend.position = "none") +
  geom_vline(xintercept = 2.5, color = "red", size = 1.2)

p7 <- ggplot(data_LCR, aes(x = Distance, fill = Rater)) +
  geom_histogram(color = "#e9ecef", alpha = 0.6, binwidth = 0.2) +
  scale_fill_manual(values = c("#2d89e0")) +
  common_theme + xlim(xlims) + ylim(ylims) +
  labs(title = "4th Ventricle Border (R)", x = "mm", y = "Number of scans") +
  theme(legend.position = c(0.9, 0.25), legend.direction = "vertical", 
        legend.background = element_blank(), legend.text = element_text(face = "bold"), 
        legend.title = element_text(face = "bold")) +
  geom_vline(xintercept = 2.5, color = "red", size = 1.2)

p8 <- ggplot(data_BBS, aes(x = Distance, fill = Rater)) +
  geom_histogram(color = "#e9ecef", alpha = 0.6, binwidth = 0.2) +
  scale_fill_manual(values = c("#2d89e0")) +
  common_theme + xlim(xlims) + ylim(ylims) +
  labs(title = "Perifastigial Sulcus", x = "mm", y = "Number of scans") +
  theme(legend.position = "none")

# draw inset images with stats underneath using cowplot
# adjust x&y coordinates if the positions are weird
p3_inset <- ggdraw(p3) +
  draw_image("/Users/alex/Dropbox/paperwriting/coreg/figures/PeriaqueductalGrey.png", 
             x = 0.68, y = 0.60, width = 0.3, height = 0.3) +
  draw_label(sprintf("Mean = %.2f\nSD = %.2f", m_TBS, sd_TBS), 
             x = 0.73 + 0.15, y = 0.60 - 0.02, hjust = 0.5, vjust = 1, size = 12)

p4_inset <- ggdraw(p4) +
  draw_image("/Users/alex/Dropbox/paperwriting/coreg/figures/OutlineBrainstem_left.png", 
             x = 0.68, y = 0.60, width = 0.3, height = 0.3) +
  draw_label(sprintf("Mean = %.2f\nSD = %.2f", m_OBSL, sd_OBSL), 
             x = 0.73 + 0.15, y = 0.60 - 0.02, hjust = 0.5, vjust = 1, size = 12)

p5_inset <- ggdraw(p5) +
  draw_image("/Users/alex/Dropbox/paperwriting/coreg/figures/OutlineBrainstem_right.png", 
             x = 0.68, y = 0.60, width = 0.3, height = 0.3) +
  draw_label(sprintf("Mean = %.2f\nSD = %.2f", m_OBSR, sd_OBSR), 
             x = 0.73 + 0.15, y = 0.60 - 0.02, hjust = 0.5, vjust = 1, size = 12)

p6_inset <- ggdraw(p6) +
  draw_image("/Users/alex/Dropbox/paperwriting/coreg/figures/LC_left.png", 
             x = 0.68, y = 0.60, width = 0.3, height = 0.3) +
  draw_label(sprintf("Mean = %.2f\nSD = %.2f", m_LCL, sd_LCL), 
             x = 0.73 + 0.15, y = 0.60 - 0.02, hjust = 0.5, vjust = 1, size = 12)

p7_inset <- ggdraw(p7) +
  draw_image("/Users/alex/Dropbox/paperwriting/coreg/figures/LC_right.png", 
             x = 0.68, y = 0.60, width = 0.3, height = 0.3) +
  draw_label(sprintf("Mean = %.2f\nSD = %.2f", m_LCR, sd_LCR), 
             x = 0.73 + 0.15, y = 0.60 - 0.02, hjust = 0.5, vjust = 1, size = 12)

p8_inset <- ggdraw(p8) +
  draw_image("/Users/alex/Dropbox/paperwriting/coreg/figures/PerifastigialSulcus.png", 
             x = 0.68, y = 0.60, width = 0.3, height = 0.3) +
  draw_label(sprintf("Mean = %.2f\nSD = %.2f", m_BBS, sd_BBS), 
             x = 0.73 + 0.15, y = 0.60 - 0.02, hjust = 0.5, vjust = 1, size = 12)

# assemble
plot_grid(p3_inset, p4_inset, p5_inset, p8_inset, p6_inset, p7_inset, nrow = 2)




#-------------------------------------------------------------------------------------------------#
#---------------------------------------------  OA   ---------------------------------------------#
#-------------------------------------------------------------------------------------------------#


# wd and data
setwd("/Users/alex/Dropbox/paperwriting/LIDO/LIDOQA/landmarks/figures/")
landmarks_YY <- readMat('/Users/alex/Dropbox/paperwriting/LIDO/LIDOQA/landmarks/OA/Distance_EPILandmarks_YY.mat', 
                        to.data.frame = TRUE)
ED_YY <- landmarks_YY$Distance.export
nSamples <- nrow(ED_YY)

# make df for each ROI
data_TBS <- data.frame(Rater = rep("YY", nSamples), Distance = ED_YY[,2])
data_OBSL <- data.frame(Rater = rep("YY", nSamples), Distance = ED_YY[,3])
data_OBSR <- data.frame(Rater = rep("YY", nSamples), Distance = ED_YY[,4])
data_LCL  <- data.frame(Rater = rep("YY", nSamples), Distance = ED_YY[,5])
data_LCR <- data.frame(Rater = rep("YY", nSamples), Distance = ED_YY[,6])
data_BBS <- data.frame(Rater = rep("YY", nSamples), Distance = ED_YY[,7])

# calc quick stats
m_TBS <- mean(data_TBS$Distance)
sd_TBS <- sd(data_TBS$Distance)
m_OBSL <- mean(data_OBSL$Distance)
sd_OBSL <- sd(data_OBSL$Distance)
m_OBSR <- mean(data_OBSR$Distance)
sd_OBSR <- sd(data_OBSR$Distance)
m_LCL <- mean(data_LCL$Distance)
sd_LCL <- sd(data_LCL$Distance)
m_LCR <- mean(data_LCR$Distance)
sd_LCR <- sd(data_LCR$Distance)
m_BBS <- mean(data_BBS$Distance)
sd_BBS <- sd(data_BBS$Distance)

# define common theme settings and limits
common_theme <- theme(
  plot.title = element_text(hjust = 0.5, size = 20, face = "bold"),
  axis.text.x = element_text(size = 20, face = "bold"),
  axis.text.y = element_text(size = 20, face = "bold"),
  axis.title.x = element_text(size = 20, face = "bold"),
  axis.title.y = element_text(size = 20, face = "bold")
)
xlims <- c(-0.1, 6)
ylims <- c(0, 31)

# draw base plots
p3 <- ggplot(data_TBS, aes(x = Distance, fill = Rater)) +
  geom_histogram(color = "#e9ecef", alpha = 0.6, binwidth = 0.2) +
  scale_fill_manual(values = c("#2d89e0")) +
  common_theme + xlim(xlims) + ylim(ylims) +
  labs(title = "Periaqueductal Grey", x = "mm", y = "Number of scans") +
  theme(legend.position = "none")

p4 <- ggplot(data_OBSL, aes(x = Distance, fill = Rater)) +
  geom_histogram(color = "#e9ecef", alpha = 0.6, binwidth = 0.2) +
  scale_fill_manual(values = c("#2d89e0")) +
  common_theme + xlim(xlims) + ylim(ylims) +
  labs(title = "Outline Brainstem (L)", x = "mm", y = "Number of scans") +
  theme(legend.position = "none")

p5 <- ggplot(data_OBSR, aes(x = Distance, fill = Rater)) +
  geom_histogram(color = "#e9ecef", alpha = 0.6, binwidth = 0.2) +
  scale_fill_manual(values = c("#2d89e0")) +
  common_theme + xlim(xlims) + ylim(ylims) +
  labs(title = "Outline Brainstem (R)", x = "mm", y = "Number of scans") +
  theme(legend.position = c(0.9, 0.25), legend.direction = "vertical", 
        legend.background = element_blank(), legend.text = element_text(face = "bold"), 
        legend.title = element_text(face = "bold"))

p6 <- ggplot(data_LCL, aes(x = Distance, fill = Rater)) +
  geom_histogram(color = "#e9ecef", alpha = 0.6, binwidth = 0.2) +
  scale_fill_manual(values = c("#2d89e0")) +
  common_theme + xlim(xlims) + ylim(ylims) +
  labs(title = "4th Ventricle Border (L)", x = "mm", y = "Number of scans") +
  theme(legend.position = "none") +
  geom_vline(xintercept = 2.5, color = "red", size = 1.2)

p7 <- ggplot(data_LCR, aes(x = Distance, fill = Rater)) +
  geom_histogram(color = "#e9ecef", alpha = 0.6, binwidth = 0.2) +
  scale_fill_manual(values = c("#2d89e0")) +
  common_theme + xlim(xlims) + ylim(ylims) +
  labs(title = "4th Ventricle Border (R)", x = "mm", y = "Number of scans") +
  theme(legend.position = c(0.9, 0.25), legend.direction = "vertical", 
        legend.background = element_blank(), legend.text = element_text(face = "bold"), 
        legend.title = element_text(face = "bold")) +
  geom_vline(xintercept = 2.5, color = "red", size = 1.2)

p8 <- ggplot(data_BBS, aes(x = Distance, fill = Rater)) +
  geom_histogram(color = "#e9ecef", alpha = 0.6, binwidth = 0.2) +
  scale_fill_manual(values = c("#2d89e0")) +
  common_theme + xlim(xlims) + ylim(ylims) +
  labs(title = "Perifastigial Sulcus", x = "mm", y = "Number of scans") +
  theme(legend.position = "none")

# draw inset images with stats underneath using cowplot
# adjust x&y coordinates if the positions are weird
p3_inset <- ggdraw(p3) +
  draw_image("/Users/alex/Dropbox/paperwriting/coreg/figures/PeriaqueductalGrey.png", 
             x = 0.68, y = 0.60, width = 0.3, height = 0.3) +
  draw_label(sprintf("Mean = %.2f\nSD = %.2f", m_TBS, sd_TBS), 
             x = 0.73 + 0.15, y = 0.60 - 0.02, hjust = 0.5, vjust = 1, size = 12)

p4_inset <- ggdraw(p4) +
  draw_image("/Users/alex/Dropbox/paperwriting/coreg/figures/OutlineBrainstem_left.png", 
             x = 0.68, y = 0.60, width = 0.3, height = 0.3) +
  draw_label(sprintf("Mean = %.2f\nSD = %.2f", m_OBSL, sd_OBSL), 
             x = 0.73 + 0.15, y = 0.60 - 0.02, hjust = 0.5, vjust = 1, size = 12)

p5_inset <- ggdraw(p5) +
  draw_image("/Users/alex/Dropbox/paperwriting/coreg/figures/OutlineBrainstem_right.png", 
             x = 0.68, y = 0.60, width = 0.3, height = 0.3) +
  draw_label(sprintf("Mean = %.2f\nSD = %.2f", m_OBSR, sd_OBSR), 
             x = 0.73 + 0.15, y = 0.60 - 0.02, hjust = 0.5, vjust = 1, size = 12)

p6_inset <- ggdraw(p6) +
  draw_image("/Users/alex/Dropbox/paperwriting/coreg/figures/LC_left.png", 
             x = 0.68, y = 0.60, width = 0.3, height = 0.3) +
  draw_label(sprintf("Mean = %.2f\nSD = %.2f", m_LCL, sd_LCL), 
             x = 0.73 + 0.15, y = 0.60 - 0.02, hjust = 0.5, vjust = 1, size = 12)

p7_inset <- ggdraw(p7) +
  draw_image("/Users/alex/Dropbox/paperwriting/coreg/figures/LC_right.png", 
             x = 0.68, y = 0.60, width = 0.3, height = 0.3) +
  draw_label(sprintf("Mean = %.2f\nSD = %.2f", m_LCR, sd_LCR), 
             x = 0.73 + 0.15, y = 0.60 - 0.02, hjust = 0.5, vjust = 1, size = 12)

p8_inset <- ggdraw(p8) +
  draw_image("/Users/alex/Dropbox/paperwriting/coreg/figures/PerifastigialSulcus.png", 
             x = 0.68, y = 0.60, width = 0.3, height = 0.3) +
  draw_label(sprintf("Mean = %.2f\nSD = %.2f", m_BBS, sd_BBS), 
             x = 0.73 + 0.15, y = 0.60 - 0.02, hjust = 0.5, vjust = 1, size = 12)

# assemble
plot_grid(p3_inset, p4_inset, p5_inset, p8_inset, p6_inset, p7_inset, nrow = 2)





#-------------------------------------------------------------------------------------------------#
#---------------------------------------------  AD   ---------------------------------------------#
#-------------------------------------------------------------------------------------------------#


# wd and data
setwd("/Users/alex/Dropbox/paperwriting/LIDO/LIDOQA/landmarks/figures/")
landmarks_YY <- readMat('/Users/alex/Dropbox/paperwriting/LIDO/LIDOQA/landmarks/AD/Distance_EPILandmarks_YY.mat', 
                        to.data.frame = TRUE)
ED_YY <- landmarks_YY$Distance.export
nSamples <- nrow(ED_YY)

# make df for each ROI
data_TBS <- data.frame(Rater = rep("YY", nSamples), Distance = ED_YY[,2])
data_OBSL <- data.frame(Rater = rep("YY", nSamples), Distance = ED_YY[,3])
data_OBSR <- data.frame(Rater = rep("YY", nSamples), Distance = ED_YY[,4])
data_LCL  <- data.frame(Rater = rep("YY", nSamples), Distance = ED_YY[,5])
data_LCR <- data.frame(Rater = rep("YY", nSamples), Distance = ED_YY[,6])
data_BBS <- data.frame(Rater = rep("YY", nSamples), Distance = ED_YY[,7])

# calc quick stats
m_TBS <- mean(data_TBS$Distance)
sd_TBS <- sd(data_TBS$Distance)
m_OBSL <- mean(data_OBSL$Distance)
sd_OBSL <- sd(data_OBSL$Distance)
m_OBSR <- mean(data_OBSR$Distance)
sd_OBSR <- sd(data_OBSR$Distance)
m_LCL <- mean(data_LCL$Distance)
sd_LCL <- sd(data_LCL$Distance)
m_LCR <- mean(data_LCR$Distance)
sd_LCR <- sd(data_LCR$Distance)
m_BBS <- mean(data_BBS$Distance)
sd_BBS <- sd(data_BBS$Distance)

# define common theme settings and limits
common_theme <- theme(
  plot.title = element_text(hjust = 0.5, size = 20, face = "bold"),
  axis.text.x = element_text(size = 20, face = "bold"),
  axis.text.y = element_text(size = 20, face = "bold"),
  axis.title.x = element_text(size = 20, face = "bold"),
  axis.title.y = element_text(size = 20, face = "bold")
)
xlims <- c(-0.1, 6)
ylims <- c(0, 31)

# draw base plots
p3 <- ggplot(data_TBS, aes(x = Distance, fill = Rater)) +
  geom_histogram(color = "#e9ecef", alpha = 0.6, binwidth = 0.2) +
  scale_fill_manual(values = c("#2d89e0")) +
  common_theme + xlim(xlims) + ylim(ylims) +
  labs(title = "Periaqueductal Grey", x = "mm", y = "Number of scans") +
  theme(legend.position = "none")

p4 <- ggplot(data_OBSL, aes(x = Distance, fill = Rater)) +
  geom_histogram(color = "#e9ecef", alpha = 0.6, binwidth = 0.2) +
  scale_fill_manual(values = c("#2d89e0")) +
  common_theme + xlim(xlims) + ylim(ylims) +
  labs(title = "Outline Brainstem (L)", x = "mm", y = "Number of scans") +
  theme(legend.position = "none")

p5 <- ggplot(data_OBSR, aes(x = Distance, fill = Rater)) +
  geom_histogram(color = "#e9ecef", alpha = 0.6, binwidth = 0.2) +
  scale_fill_manual(values = c("#2d89e0")) +
  common_theme + xlim(xlims) + ylim(ylims) +
  labs(title = "Outline Brainstem (R)", x = "mm", y = "Number of scans") +
  theme(legend.position = c(0.9, 0.25), legend.direction = "vertical", 
        legend.background = element_blank(), legend.text = element_text(face = "bold"), 
        legend.title = element_text(face = "bold"))

p6 <- ggplot(data_LCL, aes(x = Distance, fill = Rater)) +
  geom_histogram(color = "#e9ecef", alpha = 0.6, binwidth = 0.2) +
  scale_fill_manual(values = c("#2d89e0")) +
  common_theme + xlim(xlims) + ylim(ylims) +
  labs(title = "4th Ventricle Border (L)", x = "mm", y = "Number of scans") +
  theme(legend.position = "none") +
  geom_vline(xintercept = 2.5, color = "red", size = 1.2)

p7 <- ggplot(data_LCR, aes(x = Distance, fill = Rater)) +
  geom_histogram(color = "#e9ecef", alpha = 0.6, binwidth = 0.2) +
  scale_fill_manual(values = c("#2d89e0")) +
  common_theme + xlim(xlims) + ylim(ylims) +
  labs(title = "4th Ventricle Border (R)", x = "mm", y = "Number of scans") +
  theme(legend.position = c(0.9, 0.25), legend.direction = "vertical", 
        legend.background = element_blank(), legend.text = element_text(face = "bold"), 
        legend.title = element_text(face = "bold")) +
  geom_vline(xintercept = 2.5, color = "red", size = 1.2)

p8 <- ggplot(data_BBS, aes(x = Distance, fill = Rater)) +
  geom_histogram(color = "#e9ecef", alpha = 0.6, binwidth = 0.2) +
  scale_fill_manual(values = c("#2d89e0")) +
  common_theme + xlim(xlims) + ylim(ylims) +
  labs(title = "Perifastigial Sulcus", x = "mm", y = "Number of scans") +
  theme(legend.position = "none")

# draw inset images with stats underneath using cowplot
# adjust x&y coordinates if the positions are weird
p3_inset <- ggdraw(p3) +
  draw_image("/Users/alex/Dropbox/paperwriting/coreg/figures/PeriaqueductalGrey.png", 
             x = 0.68, y = 0.60, width = 0.3, height = 0.3) +
  draw_label(sprintf("Mean = %.2f\nSD = %.2f", m_TBS, sd_TBS), 
             x = 0.73 + 0.15, y = 0.60 - 0.02, hjust = 0.5, vjust = 1, size = 12)

p4_inset <- ggdraw(p4) +
  draw_image("/Users/alex/Dropbox/paperwriting/coreg/figures/OutlineBrainstem_left.png", 
             x = 0.68, y = 0.60, width = 0.3, height = 0.3) +
  draw_label(sprintf("Mean = %.2f\nSD = %.2f", m_OBSL, sd_OBSL), 
             x = 0.73 + 0.15, y = 0.60 - 0.02, hjust = 0.5, vjust = 1, size = 12)

p5_inset <- ggdraw(p5) +
  draw_image("/Users/alex/Dropbox/paperwriting/coreg/figures/OutlineBrainstem_right.png", 
             x = 0.68, y = 0.60, width = 0.3, height = 0.3) +
  draw_label(sprintf("Mean = %.2f\nSD = %.2f", m_OBSR, sd_OBSR), 
             x = 0.73 + 0.15, y = 0.60 - 0.02, hjust = 0.5, vjust = 1, size = 12)

p6_inset <- ggdraw(p6) +
  draw_image("/Users/alex/Dropbox/paperwriting/coreg/figures/LC_left.png", 
             x = 0.68, y = 0.60, width = 0.3, height = 0.3) +
  draw_label(sprintf("Mean = %.2f\nSD = %.2f", m_LCL, sd_LCL), 
             x = 0.73 + 0.15, y = 0.60 - 0.02, hjust = 0.5, vjust = 1, size = 12)

p7_inset <- ggdraw(p7) +
  draw_image("/Users/alex/Dropbox/paperwriting/coreg/figures/LC_right.png", 
             x = 0.68, y = 0.60, width = 0.3, height = 0.3) +
  draw_label(sprintf("Mean = %.2f\nSD = %.2f", m_LCR, sd_LCR), 
             x = 0.73 + 0.15, y = 0.60 - 0.02, hjust = 0.5, vjust = 1, size = 12)

p8_inset <- ggdraw(p8) +
  draw_image("/Users/alex/Dropbox/paperwriting/coreg/figures/PerifastigialSulcus.png", 
             x = 0.68, y = 0.60, width = 0.3, height = 0.3) +
  draw_label(sprintf("Mean = %.2f\nSD = %.2f", m_BBS, sd_BBS), 
             x = 0.73 + 0.15, y = 0.60 - 0.02, hjust = 0.5, vjust = 1, size = 12)

# assemble
plot_grid(p3_inset, p4_inset, p5_inset, p8_inset, p6_inset, p7_inset, nrow = 2)
