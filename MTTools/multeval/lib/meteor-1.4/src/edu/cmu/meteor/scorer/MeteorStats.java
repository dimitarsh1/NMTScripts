/*
 * Carnegie Mellon University
 * Copyright (c) 2004, 2010
 * 
 * This software is distributed under the terms of the GNU Lesser General
 * Public License.  See the included COPYING and COPYING.LESSER files.
 * 
 */

package edu.cmu.meteor.scorer;

import java.util.ArrayList;
import java.util.Scanner;

import edu.cmu.meteor.aligner.Alignment;
import edu.cmu.meteor.util.Constants;

/**
 * Class used to hold several Meteor statistics, including final score
 * 
 */
public class MeteorStats {

	public static final int STATS_LENGTH = 21;

	/* Aggregable statistics */

	public int testLength;
	public int referenceLength;

	public int testFunctionWords;
	public int referenceFunctionWords;

	public int testTotalMatches;
	public int referenceTotalMatches;

	public ArrayList<Integer> testStageMatchesContent;
	public ArrayList<Integer> referenceStageMatchesContent;

	public ArrayList<Integer> testStageMatchesFunction;
	public ArrayList<Integer> referenceStageMatchesFunction;

	public int chunks;

	// Different in case of character-based evaluation
	public int testWordMatches;
	public int referenceWordMatches;

	/* Calculated statistics */

	/**
	 * Sums weighted by parameters
	 */
	public double testWeightedMatches;
	public double referenceWeightedMatches;

	public double testWeightedLength;
	public double referenceWeightedLength;

	public double precision;
	public double recall;
	public double f1;
	public double fMean;
	public double fragPenalty;

	/**
	 * Score is required to select the best reference
	 */
	public double score;

	/**
	 * Also keep the underlying alignment if needed
	 */
	public Alignment alignment;

	public MeteorStats() {
		testLength = 0;
		referenceLength = 0;

		testFunctionWords = 0;
		referenceFunctionWords = 0;

		testTotalMatches = 0;
		referenceTotalMatches = 0;

		testStageMatchesContent = new ArrayList<Integer>();
		referenceStageMatchesContent = new ArrayList<Integer>();

		testStageMatchesFunction = new ArrayList<Integer>();
		referenceStageMatchesFunction = new ArrayList<Integer>();

		chunks = 0;

		testWordMatches = 0;
		referenceWordMatches = 0;

		testWeightedMatches = 0;
		referenceWeightedMatches = 0;

		testWeightedLength = 0;
		referenceWeightedLength = 0;
	}

	/**
	 * Aggregate SS (except score), result stored in this instance
	 * 
	 * @param ss
	 */
	public void addStats(MeteorStats ss) {

		testLength += ss.testLength;
		referenceLength += ss.referenceLength;

		testFunctionWords += ss.testFunctionWords;
		referenceFunctionWords += ss.referenceFunctionWords;

		testTotalMatches += ss.testTotalMatches;
		referenceTotalMatches += ss.referenceTotalMatches;

		int sizeDiff = ss.referenceStageMatchesContent.size()
				- referenceStageMatchesContent.size();
		for (int i = 0; i < sizeDiff; i++) {
			testStageMatchesContent.add(0);
			referenceStageMatchesContent.add(0);
			testStageMatchesFunction.add(0);
			referenceStageMatchesFunction.add(0);
		}
		for (int i = 0; i < ss.testStageMatchesContent.size(); i++)
			testStageMatchesContent.set(i, testStageMatchesContent.get(i)
					+ ss.testStageMatchesContent.get(i));
		for (int i = 0; i < ss.referenceStageMatchesContent.size(); i++)
			referenceStageMatchesContent.set(i,
					referenceStageMatchesContent.get(i)
							+ ss.referenceStageMatchesContent.get(i));
		for (int i = 0; i < ss.testStageMatchesFunction.size(); i++)
			testStageMatchesFunction.set(i, testStageMatchesFunction.get(i)
					+ ss.testStageMatchesFunction.get(i));
		for (int i = 0; i < ss.referenceStageMatchesFunction.size(); i++)
			referenceStageMatchesFunction.set(i,
					referenceStageMatchesFunction.get(i)
							+ ss.referenceStageMatchesFunction.get(i));

		if (!(ss.testTotalMatches == ss.testLength
				&& ss.referenceTotalMatches == ss.referenceLength && ss.chunks == 1))
			chunks += ss.chunks;

		testWordMatches += ss.testWordMatches;
		referenceWordMatches += ss.referenceWordMatches;

		// Score does not aggregate
	}

	/**
	 * Stats are output in lines:
	 * 
	 * tstLen refLen tstFuncWords refFuncWords stage1tstMatchesContent
	 * stage1refMatchesContent stage1tstMatchesFunction stage1refMatchesFunction
	 * s2tc s2rc s2tf s2rf s3tc s3rc s3tf s3rf s4tc s4rc s4tf s4rf chunks
	 * tstwordMatches refWordMatches
	 * 
	 * ex: 15 14 4 3 6 6 2 2 1 1 0 0 1 1 0 0 2 2 1 1 3 15 14
	 * 
	 * @param delim
	 */
	public String toString(String delim) {
		StringBuilder sb = new StringBuilder();
		sb.append(testLength + delim);
		sb.append(referenceLength + delim);
		sb.append(testFunctionWords + delim);
		sb.append(referenceFunctionWords + delim);
		for (int i = 0; i < Constants.MAX_MODULES; i++) {
			if (i < testStageMatchesContent.size()) {
				sb.append(testStageMatchesContent.get(i) + delim);
				sb.append(referenceStageMatchesContent.get(i) + delim);
				sb.append(testStageMatchesFunction.get(i) + delim);
				sb.append(referenceStageMatchesFunction.get(i) + delim);
			} else {
				sb.append(0 + delim);
				sb.append(0 + delim);
				sb.append(0 + delim);
				sb.append(0 + delim);
			}
		}
		sb.append(chunks + delim);
		sb.append(testWordMatches + delim);
		sb.append(referenceWordMatches + delim);
		return sb.toString().trim();
	}

	public String toString() {
		return this.toString(" ");
	}

	/**
	 * Some MERT implementations use int[] for sufficient statistics
	 * 
	 */

	// Does not matter for integers. If future stats require floats, higher
	// scale factor improves precision
	public static final int SCALE_FACTOR = 1;

	public int[] toIntArray() {
		int[] stats = new int[STATS_LENGTH];
		int idx = 0;
		stats[idx++] = testLength * SCALE_FACTOR;
		stats[idx++] = referenceLength * SCALE_FACTOR;
		stats[idx++] = testFunctionWords * SCALE_FACTOR;
		stats[idx++] = referenceFunctionWords * SCALE_FACTOR;
		for (int i = 0; i < Constants.MAX_MODULES; i++) {
			if (i < testStageMatchesContent.size()) {
				stats[idx++] = testStageMatchesContent.get(i) * SCALE_FACTOR;
				stats[idx++] = referenceStageMatchesContent.get(i)
						* SCALE_FACTOR;
				stats[idx++] = testStageMatchesFunction.get(i) * SCALE_FACTOR;
				stats[idx++] = referenceStageMatchesFunction.get(i)
						* SCALE_FACTOR;
			} else {
				stats[idx++] = 0;
				stats[idx++] = 0;
				stats[idx++] = 0;
				stats[idx++] = 0;
			}
		}
		stats[idx++] = chunks * SCALE_FACTOR;
		stats[idx++] = testWordMatches * SCALE_FACTOR;
		stats[idx++] = referenceWordMatches * SCALE_FACTOR;
		return stats;
	}

	/**
	 * Use a string from the toString() method to create a MeteorStats object.
	 * 
	 * @param ssString
	 */
	public MeteorStats(String ssString) {
		Scanner s = new Scanner(ssString);

		testLength = s.nextInt();
		referenceLength = s.nextInt();

		testFunctionWords = s.nextInt();
		referenceFunctionWords = s.nextInt();

		testTotalMatches = 0;
		referenceTotalMatches = 0;

		testStageMatchesContent = new ArrayList<Integer>();
		referenceStageMatchesContent = new ArrayList<Integer>();

		testStageMatchesFunction = new ArrayList<Integer>();
		referenceStageMatchesFunction = new ArrayList<Integer>();

		for (int i = 0; i < Constants.MAX_MODULES; i++) {

			int tstC = s.nextInt();
			int refC = s.nextInt();

			testTotalMatches += tstC;
			referenceTotalMatches += refC;

			testStageMatchesContent.add(tstC);
			referenceStageMatchesContent.add(refC);

			int tstF = s.nextInt();
			int refF = s.nextInt();

			testTotalMatches += tstF;
			referenceTotalMatches += refF;

			testStageMatchesFunction.add(tstF);
			referenceStageMatchesFunction.add(refF);
		}

		chunks = s.nextInt();

		testWordMatches = s.nextInt();
		referenceWordMatches = s.nextInt();
	}

	/**
	 * Some MERT implementations use int[] for sufficient statistics
	 * 
	 * @param stats
	 */
	public MeteorStats(int[] stats) {
		int idx = 0;

		testLength = stats[idx++] / SCALE_FACTOR;
		referenceLength = stats[idx++] / SCALE_FACTOR;

		testFunctionWords = stats[idx++] / SCALE_FACTOR;
		referenceFunctionWords = stats[idx++] / SCALE_FACTOR;

		testTotalMatches = 0;
		referenceTotalMatches = 0;

		testStageMatchesContent = new ArrayList<Integer>();
		referenceStageMatchesContent = new ArrayList<Integer>();

		testStageMatchesFunction = new ArrayList<Integer>();
		referenceStageMatchesFunction = new ArrayList<Integer>();

		for (int i = 0; i < Constants.MAX_MODULES; i++) {

			int tstC = stats[idx++] / SCALE_FACTOR;
			int refC = stats[idx++] / SCALE_FACTOR;

			testTotalMatches += tstC;
			referenceTotalMatches += refC;

			testStageMatchesContent.add(tstC);
			referenceStageMatchesContent.add(refC);

			int tstF = stats[idx++] / SCALE_FACTOR;
			int refF = stats[idx++] / SCALE_FACTOR;

			testTotalMatches += tstF;
			referenceTotalMatches += refF;

			testStageMatchesFunction.add(tstF);
			referenceStageMatchesFunction.add(refF);
		}

		chunks = stats[idx++] / SCALE_FACTOR;

		testWordMatches = stats[idx++] / SCALE_FACTOR;
		referenceWordMatches = stats[idx++] / SCALE_FACTOR;
	}
}